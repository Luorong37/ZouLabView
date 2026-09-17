classdef CameraService < handle
    %CAMERASERVICE Persistent child-MATLAB owner for all camera hardware.
    % Control/status is newline-delimited JSON over localhost TCP. Preview
    % frames are full-resolution uint16 latest-frame memory maps. Record data
    % remains inside this process and is streamed to per-camera BIN writers.

    properties (Access = private)
        Config struct
        Logger
        Cameras
        Server = []
        State string = "BOOTING"
        StopLoop logical = false
        PreviewActive logical = false(1, 2)
        PreviewWriters cell = {[], []}
        PreviewPaths string = ["" ""]
        PreviewLimitFPS double = [60 60]
        PreviewNextDue double = [0 0]
        PreviewPublished double = [0 0]
        PreviewSyntheticFrames double = [0 0]
        PreviewClock
        LastPreviewHealth double = 0
        LastParentCheck double = 0
        LastLogFlush double = 0
        LogFlushIntervalSeconds double = 60
        Record struct = struct('active', false, 'id', '', 'indices', [], ...
            'recorder', [], 'clock', [], 'config', struct(), ...
            'protection_stop', false, 'max_frames_available', [0 0], ...
            'result_path', '', 'status', 'idle', 'started_record_utc', '', ...
            'capture_clock', [], 'capture_stopped', false)
        TaskRecorder = []
        RecordTaskId string = ""
        RecordTaskCameras double = zeros(1, 0)
    end

    methods (Static)
        function limitFPS = previewPublishLimitForSize(height, width)
            validateattributes(height, {'numeric'}, ...
                {'scalar','integer','positive','finite'});
            validateattributes(width, {'numeric'}, ...
                {'scalar','integer','positive','finite'});
            if max(double(height), double(width)) >= 2304
                limitFPS = 30;
            else
                limitFPS = 60;
            end
        end

        function run(configPath)
            configPath = string(configPath);
            try
                service = zoulab.CameraService(configPath);
                cleanup = onCleanup(@() service.cleanup());
                service.loop();
            catch ME
                % Constructor failures occur before the service logger/loop
                % exists, so explicitly return them to the parent process.
                try
                    config = jsondecode(fileread(configPath));
                    errorValue = struct('status', 'error', ...
                        'failed_utc', zoulab.BinInfo.utcNow(), ...
                        'identifier', ME.identifier, 'message', ME.message, ...
                        'report', getReport(ME, 'extended', ...
                            'hyperlinks', 'off'), ...
                        'pid', feature('getpid'), ...
                        'phase', 'service_constructor_or_loop');
                    zoulab.BinInfo.write(fullfile( ...
                        string(config.control_folder), ...
                        'camera_service_error.json'), errorValue);
                catch
                end
                rethrow(ME);
            end
        end
    end

    methods (Access = private)
        function obj = CameraService(configPath)
            obj.Config = jsondecode(fileread(configPath));
            addpath(string(obj.Config.app_root));
            obj.Logger = zoulab.AppLogger(string(obj.Config.log_folder));
            if isfield(obj.Config, 'operator_id') && ...
                    strlength(string(obj.Config.operator_id)) > 0
                obj.Logger.setIdentity(obj.Config.operator_id, ...
                    obj.Config.operator_name);
            end
            if isfield(obj.Config, 'session_id')
                obj.Logger.setSession(obj.Config.session_id);
            end
            if ~logical(obj.Config.simulation_mode) && ...
                    isfield(obj.Config, 'third_party_adaptor_library') && ...
                    strlength(string( ...
                        obj.Config.third_party_adaptor_library)) > 0
                adaptorLibrary = string( ...
                    obj.Config.third_party_adaptor_library);
                if ~isfile(adaptorLibrary)
                    error('ZouLab:ThirdPartyAdaptorLibraryMissing', ...
                        'Third-party adaptor library is missing: %s', ...
                        adaptorLibrary);
                end
                priorPaths = string(imaqregister);
                [~, selectedName] = fileparts(adaptorLibrary);
                for priorIndex = 1:numel(priorPaths)
                    [~, priorName] = fileparts(priorPaths(priorIndex));
                    if strcmpi(priorName, selectedName) && ...
                            ~strcmpi(priorPaths(priorIndex), adaptorLibrary)
                        imaqregister(char(priorPaths(priorIndex)), 'unregister');
                        obj.Logger.log('INFO', 'CAMERA_SERVICE_ADAPTOR_REPLACED', ...
                            'OldLibrary=%s | SelectedLibrary=%s', ...
                            priorPaths(priorIndex), adaptorLibrary);
                    end
                end
                registeredPaths = string(imaqregister(adaptorLibrary));
                % This is a new dedicated camera-service process, so it owns
                % no IAT objects yet.  Reset only its local adaptor cache.
                imaqreset;
                adaptorInfo = imaqhwinfo;
                installedAdaptors = string(adaptorInfo.InstalledAdaptors);
                requestedAdaptor = string(obj.Config.adaptor);
                if ~any(strcmpi(installedAdaptors, requestedAdaptor))
                    error('ZouLab:ThirdPartyAdaptorRegistrationFailed', ...
                        ['Adaptor %s is unavailable after registering %s ', ...
                         'inside the camera-service process.'], ...
                        requestedAdaptor, adaptorLibrary);
                end
                obj.Logger.log('SUCCESS', ...
                    'CAMERA_SERVICE_ADAPTOR_REGISTERED', ...
                    ['Adaptor=%s | Library=%s | RegisteredPaths=%s | ', ...
                     'Scope=child_process_IAT_cache'], requestedAdaptor, ...
                    adaptorLibrary, strjoin(registeredPaths, ','));
            end
            obj.Cameras = zoulab.CameraManager();
            obj.Cameras.SimulationMode = logical(obj.Config.simulation_mode);
            obj.Cameras.Adaptor = string(obj.Config.adaptor);
            obj.Cameras.Serials = string(obj.Config.camera_serials(:).');
            obj.Cameras.BusTokens = string(obj.Config.camera_bus_tokens(:).');
            obj.Cameras.VideoFormats = string(obj.Config.video_formats);
            obj.Cameras.ROIs = obj.decodeRois(obj.Config.rois);
            obj.Cameras.ExposureTimes = ...
                double(obj.Config.exposure_seconds(:).');
            obj.Cameras.Bins = double(obj.Config.bins(:).');
            obj.PreviewClock = tic;
            obj.Server = tcpserver('127.0.0.1', double(obj.Config.port), ...
                'Timeout', 10);
            configureTerminator(obj.Server, "LF");
            obj.State = "DISCONNECTED";
            ready = struct('schema_version', '1.0.0', ...
                'pid', feature('getpid'), 'parent_pid', obj.Config.parent_pid, ...
                'port', obj.Config.port, ...
                'session_token', obj.Config.session_token, ...
                'ready_utc', zoulab.BinInfo.utcNow(), ...
                'state', char(obj.State));
            zoulab.BinInfo.write(fullfile(string(obj.Config.control_folder), ...
                'camera_service_ready.json'), ready);
            obj.Logger.log('SUCCESS', 'CAMERA_SERVICE_READY', ...
                ['PID=%d | ParentPID=%d | Endpoint=127.0.0.1:%d | ', ...
                 'CameraOwnership=persistent_until_safe_exit | ', ...
                 'ControlTransport=localhost_TCP | ', ...
                 'PreviewTransport=full_resolution_uint16_memmap | ', ...
                 'ExternalNetworkUsed=0'], feature('getpid'), ...
                obj.Config.parent_pid, obj.Config.port);
        end

        function loop(obj)
            profilePreview = isfield(obj.Config, 'profile_preview_diagnostics') && ...
                logical(obj.Config.profile_preview_diagnostics);
            if profilePreview
                profile on;
            end
            try
                while ~obj.StopLoop
                    obj.processOneCommand();
                    obj.checkShutdownFile();
                    obj.checkRecordStopFile();
                    obj.pumpPreview();
                    obj.pumpRecord();
                    obj.checkParent();
                    pause(0.0005);
                end
                if profilePreview
                    profile off;
                    previewProfile = profile('info');
                    save(fullfile(obj.Config.control_folder, ...
                        'preview_child_profile.mat'), 'previewProfile');
                end
            catch ME
                obj.Logger.logException('CAMERA_SERVICE_FATAL_ERROR', ME);
                errorValue = struct('status', 'error', ...
                    'failed_utc', zoulab.BinInfo.utcNow(), ...
                    'identifier', ME.identifier, 'message', ME.message, ...
                    'pid', feature('getpid'), 'state', char(obj.State));
                zoulab.BinInfo.write(fullfile(string(obj.Config.control_folder), ...
                    'camera_service_error.json'), errorValue);
                rethrow(ME);
            end
        end

        function processOneCommand(obj)
            if isempty(obj.Server) || ~obj.Server.Connected || ...
                    obj.Server.NumBytesAvailable < 1
                return;
            end
            request = jsondecode(char(readline(obj.Server)));
            requestID = double(request.request_id);
            command = upper(string(request.command));
            if isfield(request, 'operator_id') && ...
                    strlength(string(request.operator_id)) > 0
                obj.Logger.setIdentity(request.operator_id, request.operator_name);
            end
            if isfield(request, 'session_id')
                obj.Logger.setSession(request.session_id);
            end
            obj.Logger.log('INFO', 'CAMERA_SERVICE_COMMAND_RECEIVED', ...
                'RequestID=%.0f | Command=%s | State=%s', ...
                requestID, command, obj.State);
            response = struct('request_id', requestID, 'success', false, ...
                'service_state', char(obj.State), 'result', struct(), ...
                'error_identifier', '', 'error', '', ...
                'completed_utc', '');
            try
                result = obj.handleCommand(command, request.payload);
                response.success = true;
                response.result = result;
                response.service_state = char(obj.State);
                obj.Logger.log('SUCCESS', 'CAMERA_SERVICE_COMMAND_COMPLETE', ...
                    'RequestID=%.0f | Command=%s | State=%s', ...
                    requestID, command, obj.State);
            catch ME
                response.error_identifier = ME.identifier;
                response.error = ME.message;
                response.service_state = char(obj.State);
                obj.Logger.logException(sprintf( ...
                    'CAMERA_SERVICE_COMMAND_%s_FAILED', command), ME);
            end
            response.completed_utc = zoulab.BinInfo.utcNow();
            writeline(obj.Server, jsonencode(response));
        end

        function result = handleCommand(obj, command, payload)
            switch command
                case "HELLO"
                    if string(payload.session_token) ~= ...
                            string(obj.Config.session_token)
                        error('ZouLab:CameraServiceTokenMismatch', ...
                            'Camera service session token does not match.');
                    end
                    result = struct('pid', feature('getpid'), ...
                        'snapshot', obj.snapshot());
                case "QUERY_STATUS"
                    result = obj.statusResult();
                case "CONFIGURE_CAMERA"
                    obj.requireNoRecord(command);
                    cameraIndex = double(payload.camera);
                    obj.stopPreviewIfActive(cameraIndex, 'settings_change');
                    if isfield(payload, 'adaptor')
                        obj.Cameras.Adaptor = string(payload.adaptor);
                    end
                    if isfield(payload, 'video_formats')
                        obj.Cameras.VideoFormats = string(payload.video_formats);
                    end
                    obj.Cameras.configureCamera(cameraIndex, ...
                        double(payload.exposure_seconds), ...
                        double(payload.roi(:).'), double(payload.bin), obj.Logger);
                    obj.updateIdleState();
                    result = struct('settings', ...
                        obj.Cameras.getActualSettings(cameraIndex), ...
                        'snapshot', obj.snapshot());
                case "CONNECT"
                    obj.requireNoRecord(command);
                    indices = obj.indices(payload.cameras);
                    obj.Cameras.connect(indices, obj.Logger);
                    obj.updateIdleState();
                    result = struct('snapshot', obj.snapshot());
                case "REDISCOVER_AND_CONNECT"
                    obj.requireNoRecord(command);
                    indices = obj.indices(payload.cameras);
                    result = obj.rediscoverAndConnect(indices);
                case "GET_SETTINGS"
                    cameraIndex = double(payload.camera);
                    result = struct('settings', ...
                        obj.Cameras.getActualSettings(cameraIndex), ...
                        'snapshot', obj.snapshot());
                case "GET_REPORTED_FPS"
                    cameraIndex = double(payload.camera);
                    [fps, propertyName] = ...
                        obj.Cameras.getCameraReportedFPS(cameraIndex);
                    result = struct('fps', fps, ...
                        'property_name', char(propertyName), ...
                        'snapshot', obj.snapshot());
                case "START_PREVIEW"
                    obj.requireNoRecord(command);
                    result = obj.startPreview(double(payload.camera));
                case "STOP_PREVIEW"
                    obj.stopPreviewIfActive(double(payload.camera), 'user');
                    obj.updateIdleState();
                    result = struct('snapshot', obj.snapshot());
                case "SNAP_INTERNAL"
                    obj.requireNoRecord(command);
                    result = obj.internalSnap(obj.indices(payload.cameras));
                case "PREPARE_EXTERNAL_SNAP"
                    obj.requireNoRecord(command);
                    indices = obj.indices(payload.cameras);
                    obj.stopAllPreviews('external_snap_prepare');
                    obj.Cameras.prepareExternalAcquisition(indices, ...
                        double(payload.frames_per_trigger), obj.Logger);
                    obj.State = "WAITING_TRIGGER";
                    result = struct('snapshot', obj.snapshot());
                case "COLLECT_TRIGGERED_SNAP"
                    indices = obj.indices(payload.cameras);
                    result = obj.triggeredSnap(indices, ...
                        double(payload.timeout_seconds));
                case "START_RECORD"
                    result = obj.startRecord(payload);
                case "PREPARE_RECORD_TASK"
                    result = obj.prepareRecordTask(payload);
                case "MARK_RECORD_STARTED"
                    if obj.Record.active
                        obj.State = "RECORDING";
                        obj.Record.status = 'recording';
                        obj.Record.capture_clock = tic;
                    end
                    result = struct('snapshot', obj.snapshot());
                case "RESTORE_IDLE_CONFIGURATION"
                    obj.requireNoRecord(command);
                    indices = obj.indices(payload.cameras);
                    obj.Cameras.restorePreviewConfiguration(indices, obj.Logger);
                    obj.updateIdleState();
                    result = struct('snapshot', obj.snapshot());
                case "STOP_RECORD"
                    resultPath = obj.completeRecord(string(payload.reason));
                    result = struct('result_path', char(resultPath), ...
                        'snapshot', obj.snapshot());
                case "END_RECORD_TASK"
                    result = obj.endRecordTask(string(payload.reason));
                case "SHUTDOWN"
                    shutdownResult = obj.safeShutdown(string(payload.reason));
                    result = shutdownResult;
                    obj.StopLoop = true;
                otherwise
                    error('ZouLab:CameraServiceCommandUnknown', ...
                        'Unknown camera service command: %s.', command);
            end
        end

        function result = startPreview(obj, cameraIndex)
            if ~obj.Cameras.Connected(cameraIndex)
                error('ZouLab:CameraServiceCameraDisconnected', ...
                    'Camera %d must be connected before Preview.', cameraIndex);
            end
            obj.stopPreviewIfActive(cameraIndex, 'restart');
            settings = obj.Cameras.getActualSettings(cameraIndex);
            height = double(settings.ROI(4));
            width = double(settings.ROI(3));
            limitFPS = zoulab.CameraService.previewPublishLimitForSize( ...
                height, width);
            token = char(java.util.UUID.randomUUID());
            path = string(fullfile(obj.Config.control_folder, sprintf( ...
                'preview_cam%d_%s.dat', cameraIndex, token)));
            writer = zoulab.PreviewSharedBuffer.createWriter(path, height, width);
            try
                obj.Cameras.startRemotePreview(cameraIndex, obj.Logger);
            catch ME
                delete(writer);
                if isfile(path)
                    delete(path);
                end
                rethrow(ME);
            end
            obj.PreviewWriters{cameraIndex} = writer;
            obj.PreviewPaths(cameraIndex) = path;
            obj.PreviewLimitFPS(cameraIndex) = limitFPS;
            obj.PreviewNextDue(cameraIndex) = 0;
            obj.PreviewPublished(cameraIndex) = 0;
            obj.PreviewSyntheticFrames(cameraIndex) = 0;
            obj.PreviewActive(cameraIndex) = true;
            obj.State = "PREVIEWING";
            obj.Logger.log('SUCCESS', 'CAMERA_SERVICE_PREVIEW_STARTED', ...
                ['Camera=%d | Size=%s | Class=uint16 | PublishLimitFPS=%g | ', ...
                 'FullResolution=1 | Downsampled=0 | Delivery=latest_frame_mailbox | ', ...
                 'Buffer=%s'], cameraIndex, mat2str([height width]), ...
                limitFPS, path);
            result = struct('camera', cameraIndex, 'preview_path', char(path), ...
                'publish_limit_fps', limitFPS, 'height', height, ...
                'width', width, 'class', 'uint16', 'downsampled', false, ...
                'snapshot', obj.snapshot());
        end

        function result = rediscoverAndConnect(obj, indices)
            previewWasActive = obj.PreviewActive;
            obj.stopAllPreviews('hardware_rediscovery');
            recovery = obj.Cameras.rediscoverAndConnect(indices, obj.Logger);

            previewPaths = repmat({''}, 1, 2);
            previewLimits = nan(1, 2);
            previewRestarted = false(1, 2);
            for cameraIndex = find(previewWasActive & obj.Cameras.Connected)
                try
                    previewResult = obj.startPreview(cameraIndex);
                    previewPaths{cameraIndex} = previewResult.preview_path;
                    previewLimits(cameraIndex) = ...
                        double(previewResult.publish_limit_fps);
                    previewRestarted(cameraIndex) = true;
                catch ME
                    obj.Logger.logException(sprintf( ...
                        'CAMERA_%d_PREVIEW_RESTART_AFTER_REDISCOVERY_FAILED', ...
                        cameraIndex), ME);
                end
            end
            obj.updateIdleState();
            result = struct( ...
                'requested', recovery.requested, ...
                'recovery_indices', recovery.recovery_indices, ...
                'connected', recovery.connected, ...
                'missing', recovery.missing, ...
                'error_identifiers', {recovery.error_identifiers}, ...
                'errors', {recovery.errors}, ...
                'preview_was_active', previewWasActive, ...
                'preview_restarted', previewRestarted, ...
                'preview_paths', {previewPaths}, ...
                'preview_limit_fps', previewLimits, ...
                'snapshot', obj.snapshot());
            obj.Logger.log('INFO', ...
                'CAMERA_HARDWARE_REDISCOVERY_PREVIEW_RESULT', ...
                'WasActive=%s | Restarted=%s', ...
                mat2str(previewWasActive), mat2str(previewRestarted));
        end

        function pumpPreview(obj)
            if ~any(obj.PreviewActive)
                return;
            end
            current = toc(obj.PreviewClock);
            for cameraIndex = find(obj.PreviewActive)
                if current < obj.PreviewNextDue(cameraIndex)
                    continue;
                end
                obj.PreviewNextDue(cameraIndex) = current + ...
                    1 / obj.PreviewLimitFPS(cameraIndex);
                [frame, metrics, available] = ...
                    obj.Cameras.takeLatestPreviewFrame(cameraIndex, obj.Logger);
                if ~available
                    continue;
                end
                if obj.Cameras.SimulationMode
                    obj.PreviewSyntheticFrames(cameraIndex) = ...
                        obj.PreviewSyntheticFrames(cameraIndex) + ...
                        max(1, round(400 / obj.PreviewLimitFPS(cameraIndex)));
                    metrics.FramesAcquired = ...
                        obj.PreviewSyntheticFrames(cameraIndex);
                end
                obj.PreviewWriters{cameraIndex}.publish(frame, ...
                    metrics.FramesAcquired, metrics.FramesAvailable, ...
                    convertTo(datetime('now'), 'datenum'));
                obj.PreviewPublished(cameraIndex) = ...
                    obj.PreviewPublished(cameraIndex) + 1;
                if obj.PreviewPublished(cameraIndex) == 1
                    obj.Logger.log('SUCCESS', ...
                        sprintf('CAMERA_%d_REMOTE_PREVIEW_FIRST_FRAME', cameraIndex), ...
                        ['Size=%s | Class=%s | RawMin=%g | RawMax=%g | ', ...
                         'FullResolution=1 | Downsampled=0'], ...
                        mat2str(size(frame)), class(frame), ...
                        min(frame, [], 'all'), max(frame, [], 'all'));
                end
            end
            if current - obj.LastPreviewHealth >= 10
                obj.Logger.log('INFO', 'CAMERA_SERVICE_PREVIEW_HEALTH', ...
                    ['Active=%s | Published=%s | LimitsFPS=%s | ', ...
                     'Delivery=latest_only_no_backlog'], ...
                    mat2str(obj.PreviewActive), ...
                    mat2str(obj.PreviewPublished), ...
                    mat2str(obj.PreviewLimitFPS));
                obj.LastPreviewHealth = current;
            end
        end

        function stopPreviewIfActive(obj, cameraIndex, reason)
            if ~obj.PreviewActive(cameraIndex)
                return;
            end
            obj.Cameras.stopPreview(cameraIndex, obj.Logger);
            writer = obj.PreviewWriters{cameraIndex};
            if ~isempty(writer)
                delete(writer);
            end
            obj.PreviewWriters{cameraIndex} = [];
            obj.PreviewActive(cameraIndex) = false;
            path = obj.PreviewPaths(cameraIndex);
            obj.PreviewPaths(cameraIndex) = "";
            if strlength(path) > 0 && isfile(path)
                try
                    delete(path);
                catch ME
                    obj.Logger.log('WARNING', ...
                        'CAMERA_SERVICE_PREVIEW_BUFFER_DELETE_DEFERRED', ...
                        'Camera=%d | Buffer=%s | Error=%s', ...
                        cameraIndex, path, ME.message);
                end
            end
            obj.Logger.log('SUCCESS', 'CAMERA_SERVICE_PREVIEW_STOPPED', ...
                'Camera=%d | Reason=%s | PublishedFrames=%d', ...
                cameraIndex, reason, obj.PreviewPublished(cameraIndex));
        end

        function stopAllPreviews(obj, reason)
            for cameraIndex = find(obj.PreviewActive)
                obj.stopPreviewIfActive(cameraIndex, reason);
            end
            obj.updateIdleState();
        end

        function result = internalSnap(obj, indices)
            obj.stopAllPreviews('internal_snap');
            frames = obj.Cameras.acquireInternalSnapshots(indices, obj.Logger);
            path = obj.uniqueResultPath('snapshot_internal');
            save(path, 'frames', '-v7.3');
            obj.updateIdleState();
            result = struct('result_path', char(path), ...
                'snapshot', obj.snapshot());
        end

        function result = triggeredSnap(obj, indices, timeoutSeconds)
            frames = obj.Cameras.collectTriggeredFrames( ...
                indices, timeoutSeconds, obj.Logger);
            path = obj.uniqueResultPath('snapshot_triggered');
            save(path, 'frames', '-v7.3');
            obj.Cameras.restorePreviewConfiguration(indices, obj.Logger);
            obj.updateIdleState();
            result = struct('result_path', char(path), ...
                'snapshot', obj.snapshot());
        end

        function result = startRecord(obj, config)
            obj.requireNoRecord("START_RECORD");
            indices = obj.indices(config.cameras);
            if any(~obj.Cameras.Connected(indices))
                error('ZouLab:CameraServiceRecordCameraDisconnected', ...
                    'All record cameras must be connected.');
            end
            obj.stopAllPreviews('record_prepare');
            frameSizes = {[], []};
            outputFolders = {"", ""};
            cameraMetadata = {struct(), struct()};
            expectedFrames = double(config.expected_frames(:).');
            expectedFPS = double(config.expected_fps(:).');
            for cameraIndex = indices
                settings = obj.Cameras.getActualSettings(cameraIndex);
                frameSizes{cameraIndex} = [settings.ROI(4) settings.ROI(3)];
                outputFolders{cameraIndex} = string( ...
                    config.output_folders{cameraIndex});
                cameraMetadata{cameraIndex} = struct( ...
                    'logical_name', char(obj.Cameras.LogicalNames(cameraIndex)), ...
                    'serial', char(obj.Cameras.Serials(cameraIndex)), ...
                    'device_name', char(obj.Cameras.DeviceNames(cameraIndex)), ...
                    'format', settings.VideoFormat, 'roi_xywh', settings.ROI, ...
                    'bin', settings.Bin, ...
                    'exposure_seconds', settings.ExposureTime);
            end
            policy = obj.bufferPolicy(indices, frameSizes);
            taskID = string(config.record_id);
            standaloneWriterTask = ~isfield(config, 'record_task_id');
            if ~standaloneWriterTask
                taskID = string(config.record_task_id);
            end
            config.standalone_writer_task = standaloneWriterTask;
            preallocation = struct([]);
            if isfield(config, 'preallocation')
                preallocation = config.preallocation;
            end
            if isempty(obj.TaskRecorder)
                obj.TaskRecorder = zoulab.BufferedBinRecorder( ...
                    indices, outputFolders, frameSizes, expectedFrames, ...
                    expectedFPS, obj.Logger, policy, cameraMetadata, ...
                    preallocation, false);
                obj.RecordTaskId = taskID;
                obj.RecordTaskCameras = indices;
                memoryState = obj.processMemorySnapshot();
                obj.Logger.log('SUCCESS', 'CAMERA_RECORD_TASK_WRITERS_STARTED', ...
                    ['RecordTaskID=%s | Cameras=%s | WriterThreads=%d | ', ...
                     'CyclesShareWriterResources=1 | WorkingSetBytes=%.0f | ', ...
                     'PrivateBytes=%.0f | MatlabAvailableBytes=%s'], ...
                    taskID, mat2str(indices), numel(indices), ...
                    memoryState.working_set_bytes, ...
                    memoryState.private_bytes, ...
                    zoulab.BufferedBinRecorder.numberText( ...
                    memoryState.matlab_available_bytes));
            else
                if taskID ~= obj.RecordTaskId || ...
                        ~isequal(indices, obj.RecordTaskCameras)
                    error('ZouLab:CameraRecordTaskMismatch', ...
                        ['Existing writer task %s owns cameras %s; requested ', ...
                         'task %s cameras %s. End the existing Record task first.'], ...
                        obj.RecordTaskId, mat2str(obj.RecordTaskCameras), ...
                        taskID, mat2str(indices));
                end
                try
                    obj.TaskRecorder.beginCycle(outputFolders, frameSizes, ...
                        expectedFrames, expectedFPS, policy, cameraMetadata, ...
                        preallocation);
                catch ME
                    try
                        obj.endRecordTask("cycle_begin_failed");
                    catch cleanupError
                        obj.Logger.logException( ...
                            'CAMERA_RECORD_TASK_CYCLE_BEGIN_CLEANUP_FAILED', ...
                            cleanupError);
                    end
                    rethrow(ME);
                end
                obj.Logger.log('SUCCESS', ...
                    'CAMERA_RECORD_TASK_WRITERS_REUSED_FOR_CYCLE', ...
                    ['RecordTaskID=%s | Cameras=%s | ', ...
                     'NewWriterFutureCreated=0 | NewQueueCreated=0'], ...
                    taskID, mat2str(indices));
            end
            recorder = obj.TaskRecorder;
            try
                useExternal = strcmpi(string(config.trigger_mode), 'external');
                finite = strcmpi(string(config.frame_limit_mode), 'finite');
                if finite
                    obj.Cameras.prepareFiniteAcquisition(indices, ...
                        expectedFrames(indices), useExternal, obj.Logger);
                else
                    obj.Cameras.prepareOpenEndedAcquisition(indices, ...
                        useExternal, obj.Logger);
                end
            catch ME
                try
                    obj.endRecordTask("camera_prepare_failed");
                catch cleanupError
                    obj.Logger.logException( ...
                        'CAMERA_RECORD_TASK_PREPARE_CLEANUP_FAILED', cleanupError);
                end
                rethrow(ME);
            end
            obj.Record = struct('active', true, ...
                'id', char(string(config.record_id)), 'indices', indices, ...
                'recorder', recorder, 'clock', tic, 'config', config, ...
                'protection_stop', false, 'max_frames_available', [0 0], ...
                'result_path', '', 'status', 'armed', ...
                'started_record_utc', char(zoulab.BinInfo.utcNow()), ...
                'capture_clock', [], 'capture_stopped', false);
            if useExternal
                obj.State = "WAITING_TRIGGER";
            else
                obj.State = "RECORDING";
                obj.Record.status = 'recording';
                obj.Record.capture_clock = tic;
            end
            obj.Logger.log('SUCCESS', 'CAMERA_SERVICE_RECORD_ARMED', ...
                ['RecordID=%s | Cameras=%s | TriggerMode=%s | ', ...
                 'FrameLimitMode=%s | ExpectedFrames=%s | ', ...
                 'CaptureDeadlineSeconds=%s | CaptureGuardSeconds=%s | ', ...
                 'WriterThreads=%d | CameraObjectsReused=1'], ...
                obj.Record.id, mat2str(indices), string(config.trigger_mode), ...
                string(config.frame_limit_mode), ...
                mat2str(expectedFrames(indices)), ...
                obj.optionalNumberText(config, 'capture_duration_seconds'), ...
                obj.optionalNumberText(config, 'capture_stop_guard_seconds'), ...
                numel(indices));
            result = struct('record_id', obj.Record.id, ...
                'state', char(obj.State), 'snapshot', obj.snapshot());
        end

        function result = prepareRecordTask(obj, config)
            obj.requireNoRecord("PREPARE_RECORD_TASK");
            if ~isempty(obj.TaskRecorder)
                error('ZouLab:CameraRecordTaskAlreadyPrepared', ...
                    'A Record writer task is already prepared: %s.', ...
                    obj.RecordTaskId);
            end
            indices = obj.indices(config.cameras);
            if any(~obj.Cameras.Connected(indices))
                error('ZouLab:CameraServiceRecordCameraDisconnected', ...
                    'All Record cameras must be connected before writer preparation.');
            end
            obj.stopAllPreviews('record_task_prepare');
            frameSizes = {[], []};
            cameraMetadata = {struct(), struct()};
            for cameraIndex = indices
                settings = obj.Cameras.getActualSettings(cameraIndex);
                frameSizes{cameraIndex} = [settings.ROI(4) settings.ROI(3)];
                cameraMetadata{cameraIndex} = struct( ...
                    'logical_name', char(obj.Cameras.LogicalNames(cameraIndex)), ...
                    'serial', char(obj.Cameras.Serials(cameraIndex)), ...
                    'device_name', char(obj.Cameras.DeviceNames(cameraIndex)), ...
                    'format', settings.VideoFormat, 'roi_xywh', settings.ROI, ...
                    'bin', settings.Bin, ...
                    'exposure_seconds', settings.ExposureTime);
            end
            policy = obj.bufferPolicy(indices, frameSizes);
            taskID = string(config.record_task_id);
            obj.TaskRecorder = zoulab.BufferedBinRecorder(indices, ...
                {"", ""}, frameSizes, [0 0], [NaN NaN], obj.Logger, ...
                policy, cameraMetadata, struct([]), true);
            obj.RecordTaskId = taskID;
            obj.RecordTaskCameras = indices;
            obj.Logger.log('SUCCESS', 'CAMERA_RECORD_TASK_PREPARED', ...
                ['RecordTaskID=%s | Cameras=%s | WriterThreads=%d | ', ...
                 'FirstCycleOpenDeferred=1'], taskID, mat2str(indices), ...
                numel(indices));
            result = struct('record_task_id', char(taskID), ...
                'writer_threads', numel(indices), 'snapshot', obj.snapshot());
        end

        function pumpRecord(obj)
            if ~obj.Record.active
                return;
            end
            recorder = obj.Record.recorder;
            indices = obj.Record.indices;
            recorder.processMessages(0);
            finite = strcmpi(string( ...
                obj.Record.config.frame_limit_mode), 'finite');
            if ~finite && obj.captureDeadlineReached()
                obj.stopRecordCaptureOnly("planned_camera_window_complete");
            end
            if obj.Cameras.SimulationMode
                obj.pumpSimulationRecord(recorder, indices);
                return;
            end
            metrics = obj.Cameras.bufferedAcquisitionMetrics(indices);
            obj.Record.max_frames_available(indices) = max( ...
                obj.Record.max_frames_available(indices), ...
                [metrics.FramesAvailable]);
            frameSizes = recorder.FrameSizes;
            if obj.protectionRequired(metrics, indices, frameSizes, ...
                    recorder.IatBufferPolicy)
                obj.Record.protection_stop = true;
                obj.Logger.log('ERROR', ...
                    'IAT_BUFFER_80_PERCENT_PROTECTION_TRIGGERED', ...
                    ['FramesAvailable=%s | StopFraction=%.3f | ', ...
                     'AcquisitionStopped=1 | BufferedFramesWillDrain=1'], ...
                    mat2str([metrics.FramesAvailable]), ...
                    recorder.IatBufferPolicy.iat_stop_fraction);
                obj.completeRecord("iat_protection_stop");
                return;
            end
            obj.drainAvailable(recorder, indices, metrics, false, 2);
            watchdog = double(obj.Record.config.watchdog_seconds);
            if toc(obj.Record.clock) > watchdog
                obj.Logger.log('ERROR', 'CAMERA_SERVICE_RECORD_WATCHDOG', ...
                    'Elapsed=%.6g | Limit=%.6g | SafeStop=1', ...
                    toc(obj.Record.clock), watchdog);
                obj.completeRecord("watchdog_stop");
            end
        end

        function resultPath = completeRecord(obj, reason)
            if ~obj.Record.active
                resultPath = string(obj.Record.result_path);
                if strlength(resultPath) == 0 || ~isfile(resultPath)
                    error('ZouLab:CameraServiceNoRecordResult', ...
                        'No active or completed remote record result exists.');
                end
                return;
            end
            obj.State = "STOPPING";
            indices = obj.Record.indices;
            recorder = obj.Record.recorder;
            reason = obj.waitForFiniteFrameTarget(reason);
            try
                obj.Cameras.stopBufferedAcquisition(indices, obj.Logger, char(reason));
                obj.Record.capture_stopped = true;
                obj.State = "FLUSHING";
                if ~obj.Cameras.SimulationMode
                    obj.drainStopped(recorder, indices);
                end
                streamManifest = recorder.finish(90);
            catch ME
                obj.abandonFailedRecord(recorder, reason, ME);
                rethrow(ME);
            end
            if obj.Cameras.SimulationMode
                acquired = recorder.RetrievedFrames(indices);
            else
                metrics = obj.Cameras.bufferedAcquisitionMetrics(indices);
                acquired = [metrics.FramesAcquired];
            end
            measuredFPS = nan(1, numel(indices));
            for position = 1:numel(indices)
                cameraIndex = indices(position);
                span = recorder.LastTimestamp(cameraIndex) - ...
                    recorder.FirstTimestamp(cameraIndex);
                if recorder.RetrievedFrames(cameraIndex) > 1 && span > 0
                    measuredFPS(position) = ...
                        (recorder.RetrievedFrames(cameraIndex) - 1) / span;
                end
            end
            status = 'complete';
            if reason == "iat_protection_stop"
                status = 'iat_protection_stop';
            elseif reason == "watchdog_stop"
                status = 'watchdog_stop';
            elseif contains(lower(reason), "error") || ...
                    contains(lower(reason), "safe_exit") || ...
                    contains(lower(reason), "parent_exit")
                status = 'incomplete';
            end
            expectedFrames = recorder.ExpectedFrames(indices);
            retrievedFrames = recorder.RetrievedFrames(indices);
            writtenFrames = recorder.WrittenFrames(indices);
            frameTargetComplete = acquired >= expectedFrames & ...
                retrievedFrames >= expectedFrames & ...
                writtenFrames >= expectedFrames;
            finite = strcmpi(string( ...
                obj.Record.config.frame_limit_mode), 'finite');
            if finite && ~all(frameTargetComplete)
                status = 'incomplete';
                obj.Logger.log('ERROR', ...
                    'FINITE_FRAME_TARGET_INCOMPLETE', ...
                    ['RecordID=%s | Expected=%s | Acquired=%s | ', ...
                     'Retrieved=%s | Written=%s | ResultStatus=incomplete'], ...
                    obj.Record.id, mat2str(expectedFrames), ...
                    mat2str(acquired), mat2str(retrievedFrames), ...
                    mat2str(writtenFrames));
            end
            result = struct('status', status, 'record_id', obj.Record.id, ...
                'service_started_record_utc', obj.Record.started_record_utc, ...
                'completed_utc', zoulab.BinInfo.utcNow(), ...
                'elapsed_seconds', toc(obj.Record.clock), 'cameras', indices, ...
                'frames_acquired', acquired, ...
                'frames_retrieved', retrievedFrames, ...
                'frames_written', writtenFrames, ...
                'expected_frames', expectedFrames, ...
                'frame_target_complete', frameTargetComplete, ...
                'metadata_measured_fps', measuredFPS, ...
                'max_frames_available', ...
                    obj.Record.max_frames_available(indices), ...
                'stream_manifest', streamManifest, ...
                'worker_log', char(obj.Logger.FilePath), ...
                'camera_service_pid', feature('getpid'), ...
                'camera_objects_reused', true, ...
                'stop_reason', char(reason));
            resultPath = obj.uniqueResultPath("record_" + string(obj.Record.id));
            save(resultPath, 'result', '-v7.3');
            obj.Record.active = false;
            obj.Record.recorder = [];
            obj.Record.result_path = char(resultPath);
            obj.Record.status = status;
            obj.updateIdleState();
            obj.Logger.log('SUCCESS', 'CAMERA_SERVICE_RECORD_COMPLETE', ...
                ['RecordID=%s | Status=%s | Acquired=%s | Retrieved=%s | ', ...
                 'Written=%s | Result=%s | CameraObjectsRemainConnected=1 | ', ...
                 'WriterResourcesRetainedUntilRecordTaskEnd=1'], ...
                obj.Record.id, status, mat2str(result.frames_acquired), ...
                mat2str(result.frames_retrieved), ...
                mat2str(result.frames_written), resultPath);
            if isfield(obj.Record.config, 'standalone_writer_task') && ...
                    logical(obj.Record.config.standalone_writer_task)
                obj.endRecordTask("standalone_record_complete");
            end
        end

        function result = endRecordTask(obj, reason)
            if obj.Record.active
                error('ZouLab:CameraRecordTaskStillCapturing', ...
                    'Cannot end the Record writer task during an active Cycle.');
            end
            if isempty(obj.TaskRecorder)
                result = struct('released', true, 'record_task_id', '', ...
                    'snapshot', obj.snapshot());
                return;
            end
            before = obj.processMemorySnapshot();
            taskID = obj.RecordTaskId;
            recorder = obj.TaskRecorder;
            recorder.finishTask(30);
            delete(recorder);
            obj.TaskRecorder = [];
            obj.RecordTaskId = "";
            obj.RecordTaskCameras = zeros(1, 0);
            after = obj.processMemorySnapshot();
            obj.Logger.log('SUCCESS', 'CAMERA_RECORD_TASK_WRITERS_RELEASED', ...
                ['RecordTaskID=%s | Reason=%s | FuturesDeleted=1 | ', ...
                 'QueuesCleared=1 | ReleaseBoundary=whole_record_task | ', ...
                 'WorkingSetBeforeBytes=%.0f | WorkingSetAfterBytes=%.0f | ', ...
                 'PrivateBeforeBytes=%.0f | PrivateAfterBytes=%.0f | ', ...
                 'MatlabAvailableBeforeBytes=%s | MatlabAvailableAfterBytes=%s'], ...
                taskID, reason, before.working_set_bytes, ...
                after.working_set_bytes, before.private_bytes, ...
                after.private_bytes, ...
                zoulab.BufferedBinRecorder.numberText( ...
                before.matlab_available_bytes), ...
                zoulab.BufferedBinRecorder.numberText( ...
                after.matlab_available_bytes));
            result = struct('released', true, ...
                'record_task_id', char(taskID), ...
                'memory_before', before, 'memory_after', after, ...
                'snapshot', obj.snapshot());
        end

        function drainAvailable(obj, recorder, indices, metrics, ...
                includePartial, maxBlocks)
            for position = 1:numel(indices)
                cameraIndex = indices(position);
                available = double(metrics(position).FramesAvailable);
                blocks = 0;
                while available > 0 && blocks < maxBlocks
                    if ~includePartial && available < ...
                            zoulab.BufferedBinRecorder.BlockFrames
                        break;
                    end
                    if ~recorder.canAccept(cameraIndex)
                        break;
                    end
                    take = min(available, ...
                        zoulab.BufferedBinRecorder.BlockFrames);
                    block = obj.Cameras.takeBufferedFrames(cameraIndex, take);
                    recorder.ingest(cameraIndex, block.Data, block.Times, ...
                        block.Metadata);
                    available = available - take;
                    blocks = blocks + 1;
                end
            end
        end

        function pumpSimulationRecord(obj, recorder, indices)
            if string(obj.Record.status) ~= "recording"
                return;
            end
            elapsed = toc(obj.Record.clock);
            finite = strcmpi(string( ...
                obj.Record.config.frame_limit_mode), 'finite');
            maxBlocks = 2;
            for cameraIndex = indices
                expectedFPS = recorder.ExpectedFPS(cameraIndex);
                target = floor(elapsed * expectedFPS);
                if finite
                    target = min(target, recorder.ExpectedFrames(cameraIndex));
                end
                blocks = 0;
                while recorder.RetrievedFrames(cameraIndex) < target && ...
                        blocks < maxBlocks && recorder.canAccept(cameraIndex)
                    first = recorder.RetrievedFrames(cameraIndex) + 1;
                    take = min(zoulab.BufferedBinRecorder.BlockFrames, ...
                        target - first + 1);
                    frameSize = recorder.FrameSizes{cameraIndex};
                    data = uint16(randi([500 60000], frameSize(1), ...
                        frameSize(2), 1, take));
                    numbers = first:first + take - 1;
                    times = (numbers(:) - 1) / expectedFPS;
                    metadata = repmat(struct('AbsTime', [], ...
                        'FrameNumber', 0, 'RelativeFrame', 0, ...
                        'TriggerIndex', 1), take, 1);
                    for localIndex = 1:take
                        metadata(localIndex).FrameNumber = numbers(localIndex);
                        metadata(localIndex).RelativeFrame = numbers(localIndex);
                    end
                    recorder.ingest(cameraIndex, data, times, metadata);
                    blocks = blocks + 1;
                end
            end
        end

        function drainStopped(obj, recorder, indices)
            drainClock = tic;
            while true
                recorder.processMessages(0);
                recorder.assertWritersHealthy(indices);
                metrics = obj.Cameras.bufferedAcquisitionMetrics(indices);
                if all([metrics.FramesAvailable] == 0)
                    break;
                end
                obj.drainAvailable(recorder, indices, metrics, true, 8);
                if toc(drainClock) > 90
                    error('ZouLab:CameraServiceIatDrainTimeout', ...
                        'Persistent service could not drain IAT within 90 seconds.');
                end
                pause(0.0005);
            end
            obj.Logger.log('SUCCESS', 'CAMERA_SERVICE_IAT_DRAIN_COMPLETE', ...
                'Cameras=%s | Retrieved=%s | Elapsed=%.6g', ...
                mat2str(indices), mat2str(recorder.RetrievedFrames(indices)), ...
                toc(drainClock));
        end

        function result = safeShutdown(obj, reason)
            writersClosed = true;
            if obj.Record.active
                try
                    obj.completeRecord("safe_exit_" + reason);
                catch ME
                    writersClosed = false;
                    obj.Logger.logException( ...
                        'CAMERA_SERVICE_SAFE_EXIT_RECORD_FAILED', ME);
                end
            end
            if ~isempty(obj.TaskRecorder)
                try
                    obj.endRecordTask("safe_exit_" + reason);
                catch ME
                    writersClosed = false;
                    obj.Logger.logException( ...
                        'CAMERA_SERVICE_SAFE_EXIT_WRITER_TASK_FAILED', ME);
                end
            end
            obj.stopAllPreviews('safe_exit');
            obj.State = "SHUTTING_DOWN";
            obj.Logger.log('INFO', 'CAMERA_SERVICE_HARDWARE_RELEASE_BEGIN', ...
                'Reason=%s | ReleaseOrder=source_before_videoinput', reason);
            releaseResult = obj.Cameras.release(obj.Logger, ...
                "safe_exit_" + reason);
            obj.State = "OFF";
            result = struct('final_state', 'OFF', ...
                'cameras_released', releaseResult.all_released, ...
                'writers_closed', writersClosed, ...
                'reason', char(reason), 'completed_utc', zoulab.BinInfo.utcNow());
            obj.Logger.log('SUCCESS', 'CAMERA_SERVICE_SAFE_EXIT_COMPLETE', ...
                ['Reason=%s | CamerasReleased=1 | WritersClosed=%d | ', ...
                 'ProcessWillExit=1'], reason, writersClosed);
        end

        function result = statusResult(obj)
            recordStatus = struct('active', obj.Record.active, ...
                'id', obj.Record.id, 'status', obj.Record.status, ...
                'frames_retrieved', [0 0], 'frames_written', [0 0], ...
                'frames_available', [0 0]);
            if obj.Record.active
                metrics = obj.Cameras.bufferedAcquisitionMetrics( ...
                    obj.Record.indices);
                recordStatus.frames_retrieved(obj.Record.indices) = ...
                    obj.Record.recorder.RetrievedFrames(obj.Record.indices);
                recordStatus.frames_written(obj.Record.indices) = ...
                    obj.Record.recorder.WrittenFrames(obj.Record.indices);
                recordStatus.frames_available(obj.Record.indices) = ...
                    [metrics.FramesAvailable];
            end
            result = struct('pid', feature('getpid'), ...
                'state', char(obj.State), ...
                'preview_active', obj.PreviewActive, ...
                'preview_published', obj.PreviewPublished, ...
                'preview_limit_fps', obj.PreviewLimitFPS, ...
                'record', recordStatus, 'snapshot', obj.snapshot());
        end

        function value = snapshot(obj)
            value = struct('state', char(obj.State), ...
                'connected', obj.Cameras.Connected, ...
                'video_formats', {cellstr(obj.Cameras.VideoFormats)}, ...
                'rois', {obj.Cameras.ROIs}, ...
                'exposure_seconds', obj.Cameras.ExposureTimes, ...
                'bins', obj.Cameras.Bins, ...
                'logical_names', {cellstr(obj.Cameras.LogicalNames)}, ...
                'serials', {cellstr(obj.Cameras.Serials)}, ...
                'device_names', {cellstr(obj.Cameras.DeviceNames)}, ...
                'preview_active', obj.PreviewActive);
        end

        function updateIdleState(obj)
            if obj.Record.active
                return;
            elseif any(obj.PreviewActive)
                obj.State = "PREVIEWING";
            elseif any(obj.Cameras.Connected)
                obj.State = "CONNECTED_IDLE";
            else
                obj.State = "DISCONNECTED";
            end
        end

        function flushLogIfIdle(obj, current)
            if obj.Record.active || current - obj.LastLogFlush < ...
                    obj.LogFlushIntervalSeconds
                return;
            end
            try
                obj.Logger.flush();
                obj.LastLogFlush = current;
            catch ME
                % Keep queued lines for the next idle attempt.  Do not log
                % this through AppLogger because that would grow the queue.
                fprintf(2, 'Camera-service idle log flush failed: %s\n', ...
                    ME.message);
            end
        end

        function requireNoRecord(obj, command)
            if obj.Record.active
                error('ZouLab:CameraServiceRecordBusy', ...
                    '%s is unavailable while Record is active.', command);
            end
        end

        function checkParent(obj)
            current = toc(obj.PreviewClock);
            if current - obj.LastParentCheck < 2
                return;
            end
            obj.LastParentCheck = current;
            obj.flushLogIfIdle(current);
            try
                parent = System.Diagnostics.Process.GetProcessById( ...
                    int32(obj.Config.parent_pid)); %#ok<NASGU>
            catch
                obj.Logger.log('ERROR', 'CAMERA_SERVICE_PARENT_EXITED', ...
                    ['ParentPID=%d | State=%s | SafeStopAndRelease=1 | ', ...
                     'PartialRecordPreserved=1'], ...
                    obj.Config.parent_pid, obj.State);
                obj.safeShutdown("parent_exit");
                obj.StopLoop = true;
            end
        end

        function checkShutdownFile(obj)
            path = string(fullfile(obj.Config.control_folder, ...
                'camera_service_shutdown.request.json'));
            if ~isfile(path)
                return;
            end
            reason = "shutdown_file";
            try
                request = jsondecode(fileread(path));
                if isfield(request, 'reason')
                    reason = string(request.reason);
                end
            catch ME
                obj.Logger.logException( ...
                    'CAMERA_SERVICE_SHUTDOWN_FILE_READ_FAILED', ME);
            end
            emergency = false;
            if exist('request', 'var') && isfield(request, 'emergency')
                emergency = logical(request.emergency);
            end
            obj.Logger.log('WARNING', ...
                'CAMERA_SERVICE_SHUTDOWN_FILE_ACCEPTED', ...
                'Reason=%s | Emergency=%d | SafeStopAndRelease=1', reason, emergency);
            if emergency
                obj.emergencyShutdown(reason);
            else
                obj.safeShutdown(reason);
            end
            obj.StopLoop = true;
        end

        function checkRecordStopFile(obj)
            path = string(fullfile(obj.Config.control_folder, ...
                'camera_service_record_stop.request.json'));
            if ~isfile(path)
                return;
            end
            reason = "operator_stop_file";
            try
                request = jsondecode(fileread(path));
                if isfield(request, 'reason')
                    reason = string(request.reason);
                end
                delete(path);
            catch ME
                obj.Logger.logException( ...
                    'CAMERA_SERVICE_RECORD_STOP_FILE_READ_FAILED', ME);
            end
            if obj.Record.active && ~obj.Record.capture_stopped
                obj.stopRecordCaptureOnly(reason);
            else
                obj.Logger.log('INFO', ...
                    'CAMERA_SERVICE_RECORD_STOP_FILE_NOOP', ...
                    'Reason=%s | RecordActive=%d', reason, obj.Record.active);
            end
        end

        function reached = captureDeadlineReached(obj)
            reached = false;
            if ~obj.Record.active || obj.Record.capture_stopped || ...
                    string(obj.Record.status) ~= "recording" || ...
                    isempty(obj.Record.capture_clock) || ...
                    ~isfield(obj.Record.config, 'capture_duration_seconds')
                return;
            end
            duration = double(obj.Record.config.capture_duration_seconds);
            guard = 0;
            if isfield(obj.Record.config, 'capture_stop_guard_seconds')
                guard = max(0, double( ...
                    obj.Record.config.capture_stop_guard_seconds));
            end
            reached = isfinite(duration) && duration > 0 && ...
                toc(obj.Record.capture_clock) >= duration + guard;
        end

        function reason = waitForFiniteFrameTarget(obj, reason)
            reason = string(reason);
            finite = strcmpi(string( ...
                obj.Record.config.frame_limit_mode), 'finite');
            interruptTokens = ["operator", "user", "error", "safe_exit", ...
                "parent_exit", "shutdown", "watchdog", "protection", ...
                "abort", "cancel", "stopped"];
            interruptRequested = any(contains(lower(reason), interruptTokens));
            if ~finite || interruptRequested
                return;
            end

            recorder = obj.Record.recorder;
            indices = obj.Record.indices;
            expectedFrames = recorder.ExpectedFrames(indices);
            while true
                recorder.processMessages(0);
                recorder.assertWritersHealthy(indices);
                if obj.Cameras.SimulationMode
                    obj.pumpSimulationRecord(recorder, indices);
                    acquired = recorder.RetrievedFrames(indices);
                else
                    metrics = obj.Cameras.bufferedAcquisitionMetrics(indices);
                    acquired = [metrics.FramesAcquired];
                    obj.Record.max_frames_available(indices) = max( ...
                        obj.Record.max_frames_available(indices), ...
                        [metrics.FramesAvailable]);
                    frameSizes = recorder.FrameSizes;
                    if obj.protectionRequired(metrics, indices, frameSizes, ...
                            recorder.IatBufferPolicy)
                        obj.Record.protection_stop = true;
                        obj.Logger.log('ERROR', ...
                            'IAT_BUFFER_80_PERCENT_PROTECTION_TRIGGERED', ...
                            ['FramesAvailable=%s | StopFraction=%.3f | ', ...
                             'AcquisitionStopped=1 | BufferedFramesWillDrain=1'], ...
                            mat2str([metrics.FramesAvailable]), ...
                            recorder.IatBufferPolicy.iat_stop_fraction);
                        reason = "iat_protection_stop";
                        return;
                    end
                    obj.drainAvailable(recorder, indices, metrics, false, 2);
                end
                if all(acquired >= expectedFrames)
                    obj.Logger.log('SUCCESS', ...
                        'FINITE_FRAME_TARGET_REACHED_BEFORE_STOP', ...
                        'Cameras=%s | Expected=%s | Acquired=%s', ...
                        mat2str(indices), mat2str(expectedFrames), ...
                        mat2str(acquired));
                    return;
                end
                watchdog = double(obj.Record.config.watchdog_seconds);
                if toc(obj.Record.clock) > watchdog
                    obj.Logger.log('ERROR', ...
                        'CAMERA_SERVICE_RECORD_WATCHDOG', ...
                        ['Elapsed=%.6g | Limit=%.6g | Expected=%s | ', ...
                         'Acquired=%s | SafeStop=1'], ...
                        toc(obj.Record.clock), watchdog, ...
                        mat2str(expectedFrames), mat2str(acquired));
                    reason = "watchdog_stop";
                    return;
                end
                pause(0.001);
            end
        end

        function stopRecordCaptureOnly(obj, reason)
            if ~obj.Record.active || obj.Record.capture_stopped
                return;
            end
            indices = obj.Record.indices;
            elapsed = NaN;
            if ~isempty(obj.Record.capture_clock)
                elapsed = toc(obj.Record.capture_clock);
            end
            obj.Cameras.stopBufferedAcquisition(indices, obj.Logger, char(reason));
            obj.Record.capture_stopped = true;
            obj.Record.status = 'capture_stopped';
            obj.State = "CAPTURE_STOPPED";
            obj.Logger.log('SUCCESS', ...
                'CAMERA_SERVICE_CAPTURE_STOPPED_INDEPENDENTLY', ...
                ['Reason=%s | TriggerElapsedSeconds=%.6g | Cameras=%s | ', ...
                 'IATFramesPreserved=1 | WriterDrainDeferred=1'], ...
                reason, elapsed, mat2str(indices));
        end

        function abandonFailedRecord(obj, recorder, reason, failure)
            try
                obj.Cameras.stopBufferedAcquisition( ...
                    obj.Record.indices, obj.Logger, 'writer_failure_abort');
            catch stopError
                obj.Logger.logException( ...
                    'CAMERA_SERVICE_FAILED_RECORD_STOP_FAILED', stopError);
            end
            try
                recorder.finishTask(5);
            catch
            end
            try
                delete(recorder);
            catch
            end
            if ~isempty(obj.TaskRecorder) && ...
                    isequal(obj.TaskRecorder, recorder)
                obj.TaskRecorder = [];
                obj.RecordTaskId = "";
                obj.RecordTaskCameras = zeros(1, 0);
            end
            obj.Logger.log('ERROR', 'CAMERA_SERVICE_RECORD_ABANDONED', ...
                ['RecordID=%s | Reason=%s | Failure=%s | ', ...
                 'RecordStateReset=1 | CamerasStopped=1'], ...
                obj.Record.id, reason, failure.message);
            obj.Record.active = false;
            obj.Record.recorder = [];
            obj.Record.status = 'failed';
            obj.Record.capture_stopped = true;
            obj.updateIdleState();
        end

        function emergencyShutdown(obj, reason)
            if obj.Record.active
                try
                    obj.Cameras.stopBufferedAcquisition( ...
                        obj.Record.indices, obj.Logger, 'emergency_window_close');
                catch ME
                    obj.Logger.logException( ...
                        'CAMERA_SERVICE_EMERGENCY_CAMERA_STOP_FAILED', ME);
                end
                try
                    delete(obj.Record.recorder);
                catch
                end
                obj.Record.active = false;
                obj.Record.recorder = [];
                obj.Record.status = 'emergency_stopped';
                obj.Record.capture_stopped = true;
            end
            if ~isempty(obj.TaskRecorder)
                try
                    delete(obj.TaskRecorder);
                catch ME
                    obj.Logger.logException( ...
                        'CAMERA_SERVICE_EMERGENCY_WRITER_RELEASE_FAILED', ME);
                end
                obj.TaskRecorder = [];
                obj.RecordTaskId = "";
                obj.RecordTaskCameras = zeros(1, 0);
            end
            obj.stopAllPreviews('emergency_window_close');
            obj.State = "SHUTTING_DOWN";
            obj.Cameras.release(obj.Logger, ...
                "emergency_" + reason);
            obj.State = "OFF";
            obj.Logger.log('WARNING', ...
                'CAMERA_SERVICE_EMERGENCY_SHUTDOWN_COMPLETE', ...
                ['Reason=%s | PartialWriterDataMayBeIncomplete=1 | ', ...
                 'CamerasReleased=1'], reason);
        end

        function cleanup(obj)
            try
                if obj.State ~= "OFF"
                    obj.safeShutdown("service_cleanup");
                end
            catch ME
                if ~isempty(obj.Logger)
                    obj.Logger.logException('CAMERA_SERVICE_CLEANUP_FAILED', ME);
                end
            end
            obj.Server = [];
            if ~isempty(obj.Logger)
                obj.Logger.close();
            end
        end

        function path = uniqueResultPath(obj, prefix)
            token = char(java.util.UUID.randomUUID());
            path = string(fullfile(obj.Config.control_folder, ...
                sprintf('%s_%s.mat', char(prefix), token)));
        end

        function indices = indices(~, value)
            indices = unique(double(value(:).'), 'stable');
            if isempty(indices) || any(~ismember(indices, [1 2]))
                error('ZouLab:CameraServiceIndicesInvalid', ...
                    'Camera indices must contain Camera 1 and/or Camera 2.');
            end
        end

        function rois = decodeRois(~, value)
            rois = {[896 896 512 512], [896 896 512 512]};
            if iscell(value)
                for index = 1:min(2, numel(value))
                    rois{index} = double(value{index}(:).');
                end
            elseif isnumeric(value) && size(value, 1) == 2
                rois = {double(value(1, :)), double(value(2, :))};
            end
        end

        function value = optionalNumberText(~, source, fieldName)
            value = 'not_configured';
            if isfield(source, fieldName)
                number = double(source.(fieldName));
                if isscalar(number) && isfinite(number)
                    value = sprintf('%.6g', number);
                end
            end
        end

        function policy = bufferPolicy(~, indices, frameSizes)
            queueBytes = 0;
            for cameraIndex = indices
                queueBytes = queueBytes + ...
                    zoulab.BufferedBinRecorder.MaxInFlightBlocksPerCamera * ...
                    zoulab.BufferedBinRecorder.BlockFrames * ...
                    prod(frameSizes{cameraIndex}) * 2;
            end
            availableBytes = Inf;
            try
                info = memory;
                availableBytes = double(info.MemAvailableAllArrays);
            catch
            end
            policy = zoulab.BufferedBinRecorder.computeIatBufferPolicy( ...
                availableBytes, queueBytes);
        end

        function value = protectionRequired(~, metrics, indices, ...
                frameSizes, policy)
            bytesPerFrame = zeros(1, numel(indices));
            for position = 1:numel(indices)
                bytesPerFrame(position) = ...
                    prod(frameSizes{indices(position)}) * 2;
            end
            pressure = zoulab.BufferedBinRecorder.computeIatPressure( ...
                [metrics.FramesAvailable], bytesPerFrame, policy);
            value = any([metrics.Running]) && pressure.stop_required;
        end

        function value = processMemorySnapshot(~)
            value = struct('working_set_bytes', NaN, ...
                'private_bytes', NaN, 'matlab_available_bytes', Inf);
            try
                process = System.Diagnostics.Process.GetCurrentProcess();
                value.working_set_bytes = double(process.WorkingSet64);
                value.private_bytes = double(process.PrivateMemorySize64);
            catch
            end
            try
                info = memory;
                value.matlab_available_bytes = ...
                    double(info.MemAvailableAllArrays);
            catch
            end
        end
    end
end
