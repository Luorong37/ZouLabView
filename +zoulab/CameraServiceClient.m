classdef CameraServiceClient < handle
    %CAMERASERVICECLIENT Main-process proxy for the persistent camera MATLAB.
    % Small commands and status use localhost TCP. Full uint16 preview frames
    % use PreviewSharedBuffer and never pass through the TCP control channel.

    properties
        Adaptor string = "hamamatsu"
        VideoFormats string = ["MONO16_2304x2304_Fast", "MONO16_2304x2304_Fast"]
        ROIs cell = {[896 896 512 512], [896 896 512 512]}
        ExposureTimes double = [2.4931e-3 2.4931e-3]
        Bins double = [1 1]
        SimulationMode logical = false
        ThirdPartyAdaptorLibrary string = ""
        ProfilePreviewDiagnostics logical = false
        % The app sets these from the private rig_wiring.json before the
        % child camera-owner process is launched.
        CameraSerials string = ["", ""]
        CameraBusTokens string = ["", ""]
        Serials string = ["", ""]
    end

    properties (SetAccess = private)
        Connected logical = false(1, 2)
        LogicalNames string = ["Camera 1 - USB", "Camera 2 - CXP"]
        DeviceNames string = ["", ""]
        State string = "OFF"
        ServicePID double = NaN
        ControlFolder string = ""
        Started logical = false
    end

    properties (Access = private)
        AppRoot string = ""
        Logger
        Process = []
        Tcp = []
        Port double = NaN
        NextRequestID uint64 = uint64(1)
        PreviewReaders cell = {[], []}
        PreviewMetrics cell = {struct(), struct()}
        ShuttingDown logical = false
        RequestInFlight logical = false
        HealthClock
        LastHealthCheckSeconds double = -Inf
    end

    methods
        function obj = CameraServiceClient(appRoot, logger, simulationMode)
            obj.AppRoot = string(appRoot);
            obj.Logger = logger;
            if nargin >= 3
                obj.SimulationMode = logical(simulationMode);
            end
            obj.HealthClock = tic;
        end

        function connect(obj, cameraIndices, logger)
            obj.ensureStarted();
            try
                response = obj.request("CONNECT", struct( ...
                    'cameras', double(cameraIndices(:).')));
                obj.applySnapshot(response.result.snapshot);
                logger.log('SUCCESS', 'CAMERA_SERVICE_CONNECT_CONFIRMED', ...
                    'Cameras=%s | ServicePID=%d | State=%s', ...
                    mat2str(cameraIndices), obj.ServicePID, obj.State);
            catch ME
                if ~obj.isRemoteCameraNotFound(ME)
                    rethrow(ME);
                end
                logger.log('WARNING', ...
                    'CAMERA_SERVICE_HOTPLUG_RECOVERY_REQUESTED', ...
                    ['Cameras=%s | ServicePID=%d | Cause=%s | ', ...
                     'Action=reset_child_IAT_and_reconnect'], ...
                    mat2str(cameraIndices), obj.ServicePID, ME.message);
                obj.rediscoverAndConnect(cameraIndices, logger);
            end
        end

        function configureCamera(obj, cameraIndex, exposure, roi, binFactor, logger)
            obj.ensureStarted();
            targetFormat = obj.formatForBin(binFactor);
            formatRestartRequired = obj.Connected(cameraIndex) && ...
                string(obj.VideoFormats(cameraIndex)) ~= targetFormat;
            if formatRestartRequired
                obj.restartForFormatChange(cameraIndex, exposure, roi, ...
                    binFactor, targetFormat, logger);
                return;
            end
            payload = struct('camera', cameraIndex, ...
                'exposure_seconds', exposure, 'roi', double(roi(:).'), ...
                'bin', binFactor, 'adaptor', char(obj.Adaptor), ...
                'video_formats', {cellstr(obj.VideoFormats)});
            response = obj.request("CONFIGURE_CAMERA", payload);
            obj.applySnapshot(response.result.snapshot);
            logger.log('SUCCESS', 'CAMERA_SERVICE_SETTINGS_CONFIRMED', ...
                ['Camera=%d | Exposure=%.9g | ROI=%s | Bin=%d | ', ...
                 'ServicePID=%d'], cameraIndex, exposure, mat2str(roi), ...
                binFactor, obj.ServicePID);
        end

        function startPreview(obj, cameraIndex, ~, logger)
            obj.ensureStarted();
            obj.closePreviewReader(cameraIndex);
            response = obj.request("START_PREVIEW", struct('camera', cameraIndex));
            obj.PreviewReaders{cameraIndex} = ...
                zoulab.PreviewSharedBuffer.openReader( ...
                string(response.result.preview_path));
            obj.applySnapshot(response.result.snapshot);
            obj.PreviewMetrics{cameraIndex} = struct( ...
                'FramesAcquired', 0, 'FramesAvailable', 0, ...
                'Running', "on", 'Logging', "on", 'FlushErrors', 0, ...
                'PublishLimitFPS', double(response.result.publish_limit_fps), ...
                'CapturedDatenum', NaN, 'Sequence', uint64(0));
            logger.log('SUCCESS', 'REMOTE_PREVIEW_READY', ...
                ['Camera=%d | LimitFPS=%.6g | FullResolutionUint16=1 | ', ...
                 'Downsampled=0 | Buffer=%s'], cameraIndex, ...
                double(response.result.publish_limit_fps), ...
                string(response.result.preview_path));
        end

        function stopPreview(obj, cameraIndex, logger)
            obj.closePreviewReader(cameraIndex);
            if obj.Started
                response = obj.request("STOP_PREVIEW", struct('camera', cameraIndex));
                obj.applySnapshot(response.result.snapshot);
            end
            logger.log('SUCCESS', 'REMOTE_PREVIEW_STOP_CONFIRMED', ...
                'Camera=%d | ServiceState=%s', cameraIndex, obj.State);
        end

        function [frame, metadata, updated] = pollPreview(obj, cameraIndex)
            frame = zeros(0, 0, 'uint16');
            metadata = struct();
            updated = false;
            reader = obj.PreviewReaders{cameraIndex};
            if isempty(reader)
                return;
            end
            obj.assertServiceAlive('preview_poll', false);
            [frame, metadata, updated] = reader.readLatest();
            if updated
                previous = obj.PreviewMetrics{cameraIndex};
                if isempty(fieldnames(previous))
                    previous = struct('FlushErrors', 0, 'PublishLimitFPS', NaN);
                end
                obj.PreviewMetrics{cameraIndex} = struct( ...
                    'FramesAcquired', metadata.frames_acquired, ...
                    'FramesAvailable', metadata.frames_available, ...
                    'Running', "on", 'Logging', "on", ...
                    'FlushErrors', previous.FlushErrors, ...
                    'PublishLimitFPS', previous.PublishLimitFPS, ...
                    'CapturedDatenum', metadata.captured_datenum, ...
                    'Sequence', metadata.sequence);
            end
        end

        function metrics = getPreviewMetrics(obj, cameraIndex)
            metrics = obj.PreviewMetrics{cameraIndex};
            if isempty(fieldnames(metrics))
                metrics = struct('FramesAcquired', NaN, ...
                    'FramesAvailable', NaN, 'Running', "off", ...
                    'Logging', "off", 'FlushErrors', 0, ...
                    'CapturedDatenum', NaN, 'Sequence', uint64(0));
            end
        end

        function settings = getActualSettings(obj, cameraIndex)
            settings = struct('ExposureTime', obj.ExposureTimes(cameraIndex), ...
                'ROI', obj.ROIs{cameraIndex}, 'Bin', obj.Bins(cameraIndex), ...
                'VideoFormat', char(obj.VideoFormats(cameraIndex)));
            if obj.Started && obj.Connected(cameraIndex)
                response = obj.request("GET_SETTINGS", struct('camera', cameraIndex));
                settings = response.result.settings;
                obj.applySnapshot(response.result.snapshot);
            end
        end

        function applyROI(obj, cameraIndex, roi, logger)
            obj.configureCamera(cameraIndex, obj.ExposureTimes(cameraIndex), ...
                roi, obj.Bins(cameraIndex), logger);
        end

        function [fps, propertyName] = getCameraReportedFPS(obj, cameraIndex)
            fps = NaN;
            propertyName = "unavailable";
            if ~obj.Started || ~obj.Connected(cameraIndex)
                return;
            end
            response = obj.request("GET_REPORTED_FPS", struct('camera', cameraIndex));
            if ~isempty(response.result.fps)
                fps = double(response.result.fps);
            end
            propertyName = string(response.result.property_name);
        end

        function frames = acquireInternalSnapshots(obj, cameraIndices, logger)
            obj.ensureStarted();
            response = obj.request("SNAP_INTERNAL", struct( ...
                'cameras', double(cameraIndices(:).')), 30);
            loaded = load(string(response.result.result_path), 'frames');
            frames = loaded.frames;
            obj.applySnapshot(response.result.snapshot);
            logger.log('SUCCESS', 'CAMERA_SERVICE_INTERNAL_SNAP_RECEIVED', ...
                'Cameras=%s | Result=%s', mat2str(cameraIndices), ...
                string(response.result.result_path));
        end

        function prepareExternalAcquisition(obj, cameraIndices, framesPerTrigger, logger)
            obj.ensureStarted();
            response = obj.request("PREPARE_EXTERNAL_SNAP", struct( ...
                'cameras', double(cameraIndices(:).'), ...
                'frames_per_trigger', framesPerTrigger), 30);
            obj.applySnapshot(response.result.snapshot);
            logger.log('SUCCESS', 'CAMERA_SERVICE_EXTERNAL_SNAP_READY', ...
                'Cameras=%s | FramesPerTrigger=%d', ...
                mat2str(cameraIndices), framesPerTrigger);
        end

        function frames = collectTriggeredFrames(obj, cameraIndices, timeoutSeconds, logger)
            response = obj.request("COLLECT_TRIGGERED_SNAP", struct( ...
                'cameras', double(cameraIndices(:).'), ...
                'timeout_seconds', timeoutSeconds), timeoutSeconds + 30);
            loaded = load(string(response.result.result_path), 'frames');
            frames = loaded.frames;
            obj.applySnapshot(response.result.snapshot);
            logger.log('SUCCESS', 'CAMERA_SERVICE_TRIGGERED_SNAP_RECEIVED', ...
                'Cameras=%s | Result=%s', mat2str(cameraIndices), ...
                string(response.result.result_path));
        end

        function ready = startRemoteRecord(obj, config, logger)
            obj.ensureStarted();
            response = obj.request("START_RECORD", config, 90);
            ready = response.result;
            obj.applySnapshot(ready.snapshot);
            logger.log('SUCCESS', 'CAMERA_SERVICE_RECORD_READY', ...
                ['RecordID=%s | Cameras=%s | TriggerMode=%s | ', ...
                 'FrameLimitMode=%s | ServicePID=%d'], ...
                string(config.record_id), mat2str(config.cameras), ...
                string(config.trigger_mode), string(config.frame_limit_mode), ...
                obj.ServicePID);
        end

        function ready = prepareRemoteRecordTask(obj, config, logger)
            obj.ensureStarted();
            response = obj.request("PREPARE_RECORD_TASK", config, 90);
            ready = response.result;
            obj.applySnapshot(ready.snapshot);
            logger.log('SUCCESS', 'CAMERA_RECORD_TASK_READY', ...
                ['RecordTaskID=%s | Cameras=%s | WriterThreads=%d | ', ...
                 'PreparedBeforeCycleClock=1'], ...
                string(config.record_task_id), mat2str(config.cameras), ...
                double(ready.writer_threads));
        end

        function result = stopRemoteRecord(obj, reason, logger, progressFcn)
            if nargin < 4
                progressFcn = [];
            end
            response = obj.request("STOP_RECORD", struct('reason', char(string(reason))), ...
                120, progressFcn);
            resultPath = string(response.result.result_path);
            loaded = load(resultPath, 'result');
            result = loaded.result;
            obj.applySnapshot(response.result.snapshot);
            logger.log('SUCCESS', 'CAMERA_SERVICE_RECORD_RESULT_RECEIVED', ...
                ['Status=%s | FramesRetrieved=%s | FramesWritten=%s | ', ...
                 'Result=%s'], string(result.status), ...
                mat2str(result.frames_retrieved), ...
                mat2str(result.frames_written), resultPath);
        end

        function result = endRemoteRecordTask(obj, reason, logger)
            if nargin < 2
                reason = 'all_cycles_complete';
            end
            if ~obj.Started
                result = struct('released', true, 'record_task_id', '');
                return;
            end
            response = obj.request("END_RECORD_TASK", struct( ...
                'reason', char(string(reason))), 60);
            result = response.result;
            obj.applySnapshot(result.snapshot);
            logger.log('SUCCESS', 'CAMERA_RECORD_TASK_RELEASE_CONFIRMED', ...
                ['RecordTaskID=%s | Reason=%s | ', ...
                 'AllCycleWriterResourcesReleased=1'], ...
                string(result.record_task_id), string(reason));
        end

        function requestRemoteRecordStop(obj, reason, logger)
            if ~obj.Started || strlength(obj.ControlFolder) == 0
                return;
            end
            request = struct('reason', char(string(reason)), ...
                'requested_utc', zoulab.BinInfo.utcNow(), ...
                'parent_pid', feature('getpid'));
            path = fullfile(obj.ControlFolder, ...
                'camera_service_record_stop.request.json');
            zoulab.BinInfo.write(path, request);
            logger.log('WARNING', ...
                'CAMERA_SERVICE_RECORD_STOP_FILE_WRITTEN', ...
                'Reason=%s | ServicePID=%d | Path=%s', ...
                reason, obj.ServicePID, path);
        end

        function emergencyRelease(obj, logger, reason)
            if nargin < 3
                reason = 'window_close_emergency';
            end
            for cameraIndex = 1:2
                obj.closePreviewReader(cameraIndex);
            end
            if ~obj.Started
                return;
            end
            request = struct('reason', char(string(reason)), ...
                'emergency', true, 'requested_utc', zoulab.BinInfo.utcNow(), ...
                'parent_pid', feature('getpid'));
            path = fullfile(obj.ControlFolder, ...
                'camera_service_shutdown.request.json');
            try
                zoulab.BinInfo.write(path, request);
                logger.log('WARNING', ...
                    'CAMERA_SERVICE_EMERGENCY_SHUTDOWN_REQUESTED', ...
                    'ServicePID=%d | Path=%s', obj.ServicePID, path);
            catch ME
                logger.logException( ...
                    'CAMERA_SERVICE_EMERGENCY_SHUTDOWN_FILE_FAILED', ME);
            end
            obj.Tcp = [];
            acknowledged = false;
            try
                if ~isempty(obj.Process)
                    acknowledged = obj.Process.WaitForExit(2000);
                end
            catch
            end
            forced = false;
            try
                if ~isempty(obj.Process) && ~obj.Process.HasExited
                    obj.Process.Kill();
                    obj.Process.WaitForExit(2000);
                    forced = true;
                end
            catch ME
                logger.logException( ...
                    'CAMERA_SERVICE_EMERGENCY_FORCE_TERMINATE_FAILED', ME);
            end
            logger.log('WARNING', 'CAMERA_SERVICE_EMERGENCY_RELEASE_COMPLETE', ...
                ['ServicePID=%d | GracefulAck=%d | ForcedTermination=%d | ', ...
                 'PartialRecordMayRequireRecovery=1'], ...
                obj.ServicePID, acknowledged, forced);
            obj.Started = false;
            obj.Connected(:) = false;
            obj.State = "OFF";
            obj.Process = [];
        end

        function markRemoteRecordStarted(obj, logger)
            response = obj.request("MARK_RECORD_STARTED", struct(), 10);
            obj.applySnapshot(response.result.snapshot);
            logger.log('SUCCESS', 'CAMERA_SERVICE_RECORD_START_MARKED', ...
                'ServicePID=%d | State=%s', obj.ServicePID, obj.State);
        end

        function restorePreviewConfiguration(obj, cameraIndices, logger)
            if ~obj.Started
                return;
            end
            response = obj.request("RESTORE_IDLE_CONFIGURATION", struct( ...
                'cameras', double(cameraIndices(:).')), 30);
            obj.applySnapshot(response.result.snapshot);
            logger.log('INFO', 'CAMERA_SERVICE_IDLE_CONFIGURATION_RESTORED', ...
                'Cameras=%s | ServicePID=%d', mat2str(cameraIndices), ...
                obj.ServicePID);
        end

        function status = queryStatus(obj)
            if ~obj.Started
                status = struct('state', 'OFF', 'pid', NaN);
                return;
            end
            obj.assertServiceAlive('status_query', true);
            response = obj.request("QUERY_STATUS", struct(), 5);
            status = response.result;
            obj.applySnapshot(status.snapshot);
        end

        function release(obj, logger)
            if obj.ShuttingDown
                return;
            end
            obj.ShuttingDown = true;
            cleanup = onCleanup(@() obj.finishShutdownFlag());
            for cameraIndex = 1:2
                obj.closePreviewReader(cameraIndex);
            end
            if ~obj.Started
                obj.Connected(:) = false;
                obj.State = "OFF";
                return;
            end
            try
                response = obj.request("SHUTDOWN", struct( ...
                    'reason', 'safe_app_exit'), 300);
                logger.log('SUCCESS', 'CAMERA_SERVICE_SAFE_EXIT_ACK', ...
                    ['ServicePID=%d | State=%s | CamerasReleased=%d | ', ...
                     'WritersClosed=%d'], obj.ServicePID, ...
                    string(response.result.final_state), ...
                    logical(response.result.cameras_released), ...
                    logical(response.result.writers_closed));
            catch ME
                logger.logException('CAMERA_SERVICE_SAFE_EXIT_FAILED', ME);
                try
                    fallback = struct('reason', 'safe_app_exit_tcp_fallback', ...
                        'requested_utc', zoulab.BinInfo.utcNow(), ...
                        'parent_pid', feature('getpid'));
                    zoulab.BinInfo.write(fullfile(obj.ControlFolder, ...
                        'camera_service_shutdown.request.json'), fallback);
                    logger.log('WARNING', ...
                        'CAMERA_SERVICE_SAFE_EXIT_FILE_FALLBACK_WRITTEN', ...
                        'ServicePID=%d | ControlFolder=%s', ...
                        obj.ServicePID, obj.ControlFolder);
                catch fallbackError
                    logger.logException( ...
                        'CAMERA_SERVICE_SAFE_EXIT_FILE_FALLBACK_FAILED', ...
                        fallbackError);
                end
            end
            obj.Tcp = [];
            try
                if ~isempty(obj.Process) && ~obj.Process.HasExited
                    obj.Process.WaitForExit(30000);
                end
            catch
            end
            try
                if ~isempty(obj.Process)
                    if obj.Process.HasExited
                        exitCode = double(obj.Process.ExitCode);
                        if exitCode == 0
                            logger.log('SUCCESS', ...
                                'CAMERA_SERVICE_PROCESS_EXIT_CONFIRMED', ...
                                'ServicePID=%d | ExitCode=%d', ...
                                obj.ServicePID, exitCode);
                        else
                            logger.log('ERROR', ...
                                'CAMERA_SERVICE_PROCESS_EXIT_ABNORMAL', ...
                                'ServicePID=%d | ExitCode=%d', ...
                                obj.ServicePID, exitCode);
                        end
                    else
                        logger.log('ERROR', 'CAMERA_SERVICE_EXIT_UNCONFIRMED', ...
                            ['ServicePID=%d | ForcedTermination=0 | ', ...
                             'ShutdownFallbackRetained=1'], obj.ServicePID);
                    end
                end
            catch
            end
            obj.Started = false;
            obj.Connected(:) = false;
            obj.State = "OFF";
            obj.Process = [];
        end

        function delete(obj)
            if obj.Started && ~obj.ShuttingDown
                try
                    obj.release(obj.Logger);
                catch
                end
            end
        end
    end

    methods (Access = private)
        function restartForFormatChange(obj, cameraIndex, exposure, roi, ...
                binFactor, targetFormat, logger)
            old = struct('formats', obj.VideoFormats, 'rois', {obj.ROIs}, ...
                'exposures', obj.ExposureTimes, 'bins', obj.Bins, ...
                'connected', obj.Connected, ...
                'preview', [~isempty(obj.PreviewReaders{1}), ...
                    ~isempty(obj.PreviewReaders{2})], ...
                'service_pid', obj.ServicePID);
            target = old;
            target.formats(cameraIndex) = targetFormat;
            target.rois{cameraIndex} = double(roi(:).');
            target.exposures(cameraIndex) = exposure;
            target.bins(cameraIndex) = binFactor;
            logger.log('INFO', 'CAMERA_FORMAT_SERVICE_RESTART_REQUESTED', ...
                ['Camera=%d | OldBin=%d | NewBin=%d | OldFormat=%s | ', ...
                 'NewFormat=%s | ConnectedBefore=%s | PreviewBefore=%s | ', ...
                 'OldServicePID=%d'], cameraIndex, old.bins(cameraIndex), ...
                binFactor, old.formats(cameraIndex), targetFormat, ...
                mat2str(old.connected), mat2str(old.preview), old.service_pid);
            logger.flush();
            try
                obj.stopServiceForRestart(logger, 'bin_format_change');
                obj.VideoFormats = target.formats;
                obj.ROIs = target.rois;
                obj.ExposureTimes = target.exposures;
                obj.Bins = target.bins;
                obj.ensureStarted();
                connectedIndices = find(old.connected);
                if ~isempty(connectedIndices)
                    obj.connect(connectedIndices, logger);
                end
                for previewIndex = find(old.preview)
                    obj.startPreview(previewIndex, [], logger);
                end
                actual = obj.getActualSettings(cameraIndex);
                logger.log('SUCCESS', ...
                    'CAMERA_FORMAT_SERVICE_RESTART_COMPLETED', ...
                    ['Camera=%d | NewServicePID=%d | ActualBin=%d | ', ...
                     'ActualROI=%s | ActualFormat=%s | PreviewRestored=%s'], ...
                    cameraIndex, obj.ServicePID, actual.Bin, ...
                    mat2str(actual.ROI), string(actual.VideoFormat), ...
                    mat2str(old.preview));
                logger.flush();
            catch restartError
                logger.logException( ...
                    'CAMERA_FORMAT_SERVICE_RESTART_FAILED', restartError);
                logger.log('WARNING', ...
                    'CAMERA_FORMAT_SERVICE_ROLLBACK_REQUESTED', ...
                    ['Camera=%d | RestoreBin=%d | RestoreROI=%s | ', ...
                     'RestoreFormat=%s'], cameraIndex, old.bins(cameraIndex), ...
                    mat2str(old.rois{cameraIndex}), ...
                    old.formats(cameraIndex));
                logger.flush();
                rollbackError = [];
                try
                    if obj.Started
                        obj.stopServiceForRestart(logger, ...
                            'failed_bin_change_rollback');
                    end
                    obj.VideoFormats = old.formats;
                    obj.ROIs = old.rois;
                    obj.ExposureTimes = old.exposures;
                    obj.Bins = old.bins;
                    obj.ensureStarted();
                    connectedIndices = find(old.connected);
                    if ~isempty(connectedIndices)
                        obj.connect(connectedIndices, logger);
                    end
                    for previewIndex = find(old.preview)
                        obj.startPreview(previewIndex, [], logger);
                    end
                    logger.log('SUCCESS', ...
                        'CAMERA_FORMAT_SERVICE_ROLLBACK_COMPLETED', ...
                        'Camera=%d | ServicePID=%d | PreviewRestored=%s', ...
                        cameraIndex, obj.ServicePID, mat2str(old.preview));
                catch caughtRollbackError
                    rollbackError = caughtRollbackError;
                    logger.logException( ...
                        'CAMERA_FORMAT_SERVICE_ROLLBACK_FAILED', ...
                        caughtRollbackError);
                end
                logger.flush();
                if ~isempty(rollbackError)
                    restartError = addCause(restartError, rollbackError);
                end
                rethrow(restartError);
            end
        end

        function stopServiceForRestart(obj, logger, reason)
            for cameraIndex = 1:2
                obj.closePreviewReader(cameraIndex);
            end
            if ~obj.Started
                return;
            end
            servicePID = obj.ServicePID;
            graceful = false;
            nativeExit = false;
            try
                response = obj.request("SHUTDOWN", struct( ...
                    'reason', char(string(reason))), 30);
                graceful = logical(response.result.cameras_released);
            catch ME
                processExited = false;
                try
                    processExited = ~isempty(obj.Process) && obj.Process.HasExited;
                catch
                end
                nativeExit = processExited;
                if processExited
                    logger.log('WARNING', ...
                        'CAMERA_SERVICE_EXITED_DURING_FORMAT_RESTART', ...
                        ['ServicePID=%d | Reason=%s | Error=%s | ', ...
                         'RestartContinuesInFreshProcess=1'], ...
                        servicePID, reason, ME.message);
                else
                    logger.logException( ...
                        'CAMERA_SERVICE_FORMAT_RESTART_SHUTDOWN_FAILED', ME);
                end
            end
            obj.Tcp = [];
            forced = false;
            try
                if ~isempty(obj.Process) && ~obj.Process.HasExited
                    obj.Process.WaitForExit(5000);
                end
                if ~isempty(obj.Process) && ~obj.Process.HasExited
                    obj.Process.Kill();
                    obj.Process.WaitForExit(5000);
                    forced = true;
                end
            catch ME
                logger.logException( ...
                    'CAMERA_SERVICE_FORMAT_RESTART_TERMINATE_FAILED', ME);
            end
            obj.Started = false;
            obj.Connected(:) = false;
            obj.State = "OFF";
            obj.Process = [];
            obj.RequestInFlight = false;
            logger.log('INFO', 'CAMERA_SERVICE_STOPPED_FOR_FORMAT_CHANGE', ...
                ['ServicePID=%d | Reason=%s | Graceful=%d | ', ...
                 'NativeExitObserved=%d | ForcedTermination=%d'], ...
                servicePID, reason, graceful, nativeExit, forced);
        end

        function ensureStarted(obj)
            if obj.Started
                try
                    if obj.assertServiceAlive('ensure_started', true)
                        return;
                    end
                catch ME
                    if ~strcmp(ME.identifier, 'ZouLab:CameraServiceExited')
                        rethrow(ME);
                    end
                    obj.Logger.log('INFO', ...
                        'CAMERA_SERVICE_FRESH_LAUNCH_AFTER_EXIT', ...
                        ['Previous service exit was confirmed. The current ', ...
                         'explicit camera command will launch a fresh service.']);
                end
            end
            obj.Port = zoulab.CameraServiceClient.reservePort();
            token = char(java.util.UUID.randomUUID());
            obj.ControlFolder = string(fullfile(obj.AppRoot, 'tmp', ...
                "camera_service_" + feature('getpid') + "_" + token));
            mkdir(obj.ControlFolder);
            config = struct('schema_version', '1.0.0', ...
                'app_root', char(obj.AppRoot), ...
                'control_folder', char(obj.ControlFolder), ...
                'log_folder', char(fullfile(obj.ControlFolder, 'logs')), ...
                'port', obj.Port, 'parent_pid', feature('getpid'), ...
                'session_token', token, ...
                'simulation_mode', obj.SimulationMode, ...
                'operator_id', char(obj.Logger.OperatorID), ...
                'operator_name', char(obj.Logger.OperatorName), ...
                'session_id', char(obj.Logger.SessionID), ...
                'adaptor', char(obj.Adaptor), ...
                'third_party_adaptor_library', ...
                    char(obj.ThirdPartyAdaptorLibrary), ...
                'profile_preview_diagnostics', obj.ProfilePreviewDiagnostics, ...
                'camera_serials', cellstr(obj.CameraSerials), ...
                'camera_bus_tokens', cellstr(obj.CameraBusTokens), ...
                'video_formats', {cellstr(obj.VideoFormats)}, ...
                'rois', {obj.ROIs}, ...
                'exposure_seconds', obj.ExposureTimes, 'bins', obj.Bins);
            configPath = fullfile(obj.ControlFolder, 'camera_service_config.json');
            zoulab.BinInfo.write(configPath, config);
            matlabExecutable = string(fullfile(matlabroot, 'bin', 'matlab.exe'));
            command = sprintf("addpath('%s'); zoulab.CameraService.run('%s');", ...
                zoulab.CameraServiceClient.matlabQuote(obj.AppRoot), ...
                zoulab.CameraServiceClient.matlabQuote(configPath));
            startInfo = System.Diagnostics.ProcessStartInfo();
            startInfo.FileName = char(matlabExecutable);
            childLogPath = fullfile(obj.ControlFolder, ...
                'camera_service_console.log');
            startInfo.Arguments = sprintf('-logfile "%s" -batch "%s"', ...
                char(childLogPath), command);
            startInfo.WorkingDirectory = char(obj.AppRoot);
            startInfo.UseShellExecute = false;
            startInfo.CreateNoWindow = true;
            startInfo.WindowStyle = System.Diagnostics.ProcessWindowStyle.Hidden;
            process = System.Diagnostics.Process();
            process.StartInfo = startInfo;
            if ~process.Start()
                error('ZouLab:CameraServiceLaunchFailed', ...
                    'Windows did not start the persistent camera MATLAB.');
            end
            obj.Process = process;
            readyPath = fullfile(obj.ControlFolder, 'camera_service_ready.json');
            errorPath = fullfile(obj.ControlFolder, 'camera_service_error.json');
            waitClock = tic;
            while ~isfile(readyPath)
                if isfile(errorPath)
                    value = jsondecode(fileread(errorPath));
                    error('ZouLab:CameraServiceRemoteError', '%s', ...
                        string(value.message));
                end
                if process.HasExited
                    % The child writes its diagnostic file during exception
                    % unwinding; allow that flush to complete before reporting
                    % only the generic process exit code.
                    pause(0.25);
                    if isfile(errorPath)
                        value = jsondecode(fileread(errorPath));
                        detail = "";
                        if isfield(value, 'report')
                            detail = " | " + string(value.report);
                        end
                        error('ZouLab:CameraServiceRemoteError', '%s%s', ...
                            string(value.message), detail);
                    end
                    error('ZouLab:CameraServiceExitedBeforeReady', ...
                        'Camera service exited with code %d.%s', ...
                        process.ExitCode, ...
                        zoulab.CameraServiceClient.consoleLogText(childLogPath));
                end
                if toc(waitClock) > 90
                    error('ZouLab:CameraServiceReadyTimeout', ...
                        'Camera service did not become ready within 90 seconds.');
                end
                pause(0.05);
                drawnow limitrate nocallbacks;
            end
            ready = jsondecode(fileread(readyPath));
            obj.ServicePID = double(ready.pid);
            obj.Tcp = tcpclient('127.0.0.1', obj.Port, ...
                'Timeout', 10, 'ConnectTimeout', 10, ...
                'EnableTransferDelay', false);
            configureTerminator(obj.Tcp, "LF");
            obj.Started = true;
            obj.LastHealthCheckSeconds = toc(obj.HealthClock);
            obj.State = "DISCONNECTED";
            obj.Logger.log('SUCCESS', 'CAMERA_SERVICE_STARTED', ...
                ['PID=%d | ParentPID=%d | Endpoint=127.0.0.1:%d | ', ...
                 'ControlTransport=localhost_TCP | PreviewTransport=memmap_uint16 | ', ...
                 'NetworkExternal=0 | CameraOwnership=persistent_service | ', ...
                 'ControlFolder=%s | ServiceConsoleLog=%s'], ...
                obj.ServicePID, feature('getpid'), obj.Port, ...
                obj.ControlFolder, childLogPath);
            obj.request("HELLO", struct('session_token', char(ready.session_token)), 10);
        end

        function response = request(obj, command, payload, timeoutSeconds, progressFcn)
            if nargin < 4
                timeoutSeconds = 30;
            end
            if nargin < 5
                progressFcn = [];
            end
            if isempty(obj.Tcp)
                error('ZouLab:CameraServiceNotConnected', ...
                    'The persistent camera service control channel is unavailable.');
            end
            if obj.RequestInFlight
                obj.Logger.log('WARNING', ...
                    'CAMERA_SERVICE_CONTROL_REENTRANCY_BLOCKED', ...
                    'RequestedCommand=%s | ExistingRequestMustFinish=1', ...
                    string(command));
                error('ZouLab:CameraServiceControlBusy', ...
                    ['Another camera command is still completing. Wait for its ', ...
                     'visible result before issuing the next camera command.']);
            end
            obj.RequestInFlight = true;
            requestCleanup = onCleanup(@() obj.finishRequest());
            requestID = obj.NextRequestID;
            obj.NextRequestID = obj.NextRequestID + uint64(1);
            message = struct('request_id', double(requestID), ...
                'command', char(upper(string(command))), 'payload', payload, ...
                'operator_id', char(obj.Logger.OperatorID), ...
                'operator_name', char(obj.Logger.OperatorName), ...
                'session_id', char(obj.Logger.SessionID), ...
                'requested_utc', zoulab.BinInfo.utcNow());
            writeline(obj.Tcp, jsonencode(message));
            waitClock = tic;
            while obj.Tcp.NumBytesAvailable < 1
                if ~isempty(obj.Process) && obj.Process.HasExited
                    exitCode = double(obj.Process.ExitCode);
                    obj.markServiceUnavailable("request_" + ...
                        lower(string(command)), exitCode);
                    error('ZouLab:CameraServiceExited', ...
                        'Camera service exited with code %d during %s.', ...
                        exitCode, command);
                end
                if toc(waitClock) > timeoutSeconds
                    error('ZouLab:CameraServiceCommandTimeout', ...
                        'Camera service command %s timed out after %.1f seconds.', ...
                        command, timeoutSeconds);
                end
                if ~isempty(progressFcn)
                    progressFcn(toc(waitClock), timeoutSeconds);
                end
                pause(0.005);
                % Do not admit a second UI callback while one request owns
                % the ordered request/response stream.  Reentrant callbacks
                % previously swapped adjacent response IDs.
                drawnow limitrate nocallbacks;
            end
            response = jsondecode(char(readline(obj.Tcp)));
            if double(response.request_id) ~= double(requestID)
                error('ZouLab:CameraServiceResponseMismatch', ...
                    'Expected response %d but received %d.', ...
                    requestID, response.request_id);
            end
            obj.State = string(response.service_state);
            if ~logical(response.success)
                error('ZouLab:CameraServiceCommandFailed', ...
                    'Camera service %s failed (%s): %s', command, ...
                    string(response.error_identifier), string(response.error));
            end
        end

        function rediscoverAndConnect(obj, cameraIndices, logger)
            hadReader = false(1, 2);
            for cameraIndex = 1:2
                hadReader(cameraIndex) = ~isempty(obj.PreviewReaders{cameraIndex});
                obj.closePreviewReader(cameraIndex);
            end
            response = obj.request("REDISCOVER_AND_CONNECT", struct( ...
                'cameras', double(cameraIndices(:).')), 120);
            result = response.result;
            obj.applySnapshot(result.snapshot);

            restarted = logical(result.preview_restarted(:).');
            paths = string(result.preview_paths(:).');
            limits = double(result.preview_limit_fps(:).');
            for cameraIndex = find(restarted)
                obj.PreviewReaders{cameraIndex} = ...
                    zoulab.PreviewSharedBuffer.openReader(paths(cameraIndex));
                obj.PreviewMetrics{cameraIndex} = struct( ...
                    'FramesAcquired', 0, 'FramesAvailable', 0, ...
                    'Running', "on", 'Logging', "on", 'FlushErrors', 0, ...
                    'PublishLimitFPS', limits(cameraIndex), ...
                    'CapturedDatenum', NaN, 'Sequence', uint64(0));
            end
            logger.log('INFO', ...
                'CAMERA_SERVICE_HOTPLUG_PREVIEW_REBOUND', ...
                'ReaderWasActive=%s | ReaderRestarted=%s', ...
                mat2str(hadReader), mat2str(restarted));

            missing = double(result.missing(:).');
            if ~isempty(missing)
                error('ZouLab:CameraHotplugRecoveryIncomplete', ...
                    ['Camera hardware was refreshed, but requested camera(s) %s ', ...
                     'are still unavailable. Check camera power, USB/CXP cable, ', ...
                     'and Windows device status, then click Connect camera(s) again.'], ...
                    mat2str(missing));
            end
            logger.log('SUCCESS', ...
                'CAMERA_SERVICE_HOTPLUG_RECOVERY_CONFIRMED', ...
                ['Requested=%s | Connected=%s | ServicePID=%d | ', ...
                 'PreviewRestarted=%s'], mat2str(cameraIndices), ...
                mat2str(find(obj.Connected)), obj.ServicePID, ...
                mat2str(restarted));
        end

        function tf = isRemoteCameraNotFound(~, exception)
            tf = strcmp(exception.identifier, ...
                'ZouLab:CameraServiceCommandFailed') && ...
                contains(string(exception.message), ...
                '(ZouLab:CameraNotFound)', 'IgnoreCase', true);
        end

        function applySnapshot(obj, snapshot)
            if isempty(snapshot)
                return;
            end
            obj.State = string(snapshot.state);
            obj.Connected = logical(snapshot.connected(:).');
            obj.VideoFormats = string(snapshot.video_formats(:).');
            obj.ExposureTimes = double(snapshot.exposure_seconds(:).');
            obj.Bins = double(snapshot.bins(:).');
            obj.ROIs = zoulab.CameraServiceClient.decodeRois(snapshot.rois);
            obj.LogicalNames = string(snapshot.logical_names(:).');
            obj.Serials = string(snapshot.serials(:).');
            obj.DeviceNames = string(snapshot.device_names(:).');
        end

        function alive = assertServiceAlive(obj, context, forceCheck)
            if nargin < 3
                forceCheck = false;
            end
            alive = obj.Started;
            if ~alive
                return;
            end
            nowSeconds = toc(obj.HealthClock);
            if ~forceCheck && nowSeconds - obj.LastHealthCheckSeconds < 1
                return;
            end
            obj.LastHealthCheckSeconds = nowSeconds;
            exitCode = NaN;
            try
                alive = ~isempty(obj.Process) && ~obj.Process.HasExited;
                if ~alive && ~isempty(obj.Process) && obj.Process.HasExited
                    exitCode = double(obj.Process.ExitCode);
                end
            catch
                alive = false;
            end
            if ~alive
                obj.markServiceUnavailable(context, exitCode);
                error('ZouLab:CameraServiceExited', ...
                    ['The persistent camera service exited unexpectedly. ', ...
                     'Camera state was cleared; click Preview to start a fresh ', ...
                     'service and reconnect the selected camera.']);
            end
        end

        function markServiceUnavailable(obj, context, exitCode)
            oldPID = obj.ServicePID;
            for cameraIndex = 1:2
                obj.closePreviewReader(cameraIndex);
            end
            obj.Tcp = [];
            obj.Process = [];
            obj.Started = false;
            obj.Connected(:) = false;
            obj.State = "ERROR";
            obj.RequestInFlight = false;
            obj.Logger.log('ERROR', 'CAMERA_SERVICE_UNEXPECTED_EXIT', ...
                ['ServicePID=%g | ExitCode=%g | Context=%s | ', ...
                 'ConnectedCleared=1 | PreviewReadersClosed=1 | ', ...
                 'AutomaticHardwareReconnect=0'], ...
                oldPID, exitCode, string(context));
        end

        function closePreviewReader(obj, cameraIndex)
            reader = obj.PreviewReaders{cameraIndex};
            if ~isempty(reader)
                try
                    delete(reader);
                catch
                end
            end
            obj.PreviewReaders{cameraIndex} = [];
            obj.PreviewMetrics{cameraIndex} = struct();
        end

        function finishShutdownFlag(obj)
            obj.ShuttingDown = false;
        end

        function finishRequest(obj)
            obj.RequestInFlight = false;
        end
    end

    methods (Static, Access = private)
        function format = formatForBin(binFactor)
            switch double(binFactor)
                case 1
                    format = "MONO16_2304x2304_Fast";
                case 2
                    format = "MONO16_BIN2x2_1152x1152_Fast";
                case 4
                    format = "MONO16_BIN4x4_576x576_Fast";
                otherwise
                    error('ZouLab:InvalidBin', ...
                        'Bin must be 1, 2, or 4.');
            end
        end

        function port = reservePort()
            listener = System.Net.Sockets.TcpListener( ...
                System.Net.IPAddress.Loopback, 0);
            listener.Start();
            cleanup = onCleanup(@() listener.Stop());
            endpoint = listener.LocalEndpoint;
            port = double(endpoint.Port);
        end

        function value = matlabQuote(textValue)
            value = strrep(char(string(textValue)), '''', '''''');
        end

        function rois = decodeRois(value)
            rois = {[896 896 512 512], [896 896 512 512]};
            if iscell(value)
                for index = 1:min(2, numel(value))
                    rois{index} = double(value{index}(:).');
                end
            elseif isnumeric(value) && size(value, 1) == 2
                rois = {double(value(1, :)), double(value(2, :))};
            end
        end


        function value = consoleLogText(path)
            value = '';
            try
                if isfile(path)
                    textValue = strtrim(fileread(path));
                    if ~isempty(textValue)
                        value = sprintf('\nChild MATLAB console:\n%s', textValue);
                    end
                end
            catch
            end
        end
    end
end
