classdef AcquisitionCoordinator < handle
    %ACQUISITIONCOORDINATOR Owns acquisition lifecycle and cycle scheduling.
    % Hardware services keep their existing ownership. Callbacks are explicit
    % operations (UI feedback, plan preparation and per-cycle capture backends),
    % not an App object or a generic method dispatcher. No pixel data is copied
    % through a new process and no trigger/timing algorithms are changed.
    properties (Access = private)
        RunState
        Logger
        Sessions
        DaqController
        Cameras
        Callbacks struct
    end

    methods
        function obj = AcquisitionCoordinator(state, logger, sessions, daq, cameras, callbacks)
            obj.RunState = state;
            obj.Logger = logger;
            obj.Sessions = sessions;
            obj.DaqController = daq;
            obj.Cameras = cameras;
            obj.Callbacks = callbacks;
        end

        function startAcquisition(obj, modeName, visualPreviewRunning)
            obj.Callbacks.beginAction('START_ACQUISITION', ...
                sprintf('Starting %s acquisition...', modeName));
            if obj.RunState.AcquisitionRunning
                obj.Logger.log('WARNING', 'ACQUISITION_START_REJECTED_RUNNING', ...
                    'State=%s | CurrentCycle=%d', obj.RunState.Status, ...
                    obj.RunState.AcquisitionCycleIndex);
                obj.Callbacks.finishAction('START_ACQUISITION', false, ...
                    'An acquisition is already running.');
                return;
            end
            if obj.RunState.ConversionRunning
                obj.Logger.log('WARNING', ...
                    'ACQUISITION_START_REJECTED_TIFF_CONVERSION', ...
                    'ConversionRecordPath=%s | NewCaptureBlocked=1 | OtherUIRemainsAvailable=1', ...
                    obj.Callbacks.conversionRecordPath());
                obj.Callbacks.finishAction('START_ACQUISITION', false, ...
                    ['A Record TIFF conversion is still running. Wait for ', ...
                     'completion; Preview and setup controls remain available.']);
                return;
            end
            if visualPreviewRunning
                obj.Logger.log('WARNING', ...
                    'ACQUISITION_START_REJECTED_VISUAL_PREVIEW', ...
                    'Stop standalone visual preview playback first.');
                obj.Callbacks.finishAction('START_ACQUISITION', false, ...
                    'Stop visual preview playback before Acquisition.');
                return;
            end
            recordPath = "";
            try
                obj.Callbacks.requireIdentity('start acquisition');
                % The frozen plan and preflight read current controls directly.
                % Cancel a pending cosmetic refresh so it cannot contend with
                % acquisition startup or PTB timing on the UI thread.
                obj.Callbacks.cancelExpensiveUiRefresh();
                plan = obj.Callbacks.freezeAcquisitionPlan();
                plan = obj.Callbacks.preflightAcquisition(plan);
                obj.RunState.FrozenAcquisitionPlan = plan;
                obj.Sessions.resetRecord();
                [recordPath, ~] = obj.Callbacks.ensureRecord();
                lightRows = obj.Callbacks.imagingLightRowsFor(plan.cameras);
                aliases = obj.Callbacks.lightAliases(lightRows);
                frozenDaqPlan = obj.Callbacks.compileFrozenDaqPlan( ...
                    plan, lightRows, aliases);
                obj.Callbacks.saveDaqPlanArtifacts(recordPath, frozenDaqPlan, plan);
                obj.RunState.beginCapture();
                obj.Callbacks.setAcquisitionControlsLocked(true);
                obj.Callbacks.setAcquisitionState('PREPARING', ...
                    'Preparing Record resources before the Cycle clock starts.');
                obj.Logger.log('SUCCESS', 'ACQUISITION_STARTED', ...
                    'RecordPath=%s | Plan=%s', recordPath, jsonencode(plan));
                obj.runAcquisitionCycles(plan, recordPath, frozenDaqPlan);
                conversionResult = struct('status', 'not_requested');
                postProcessingRequired = strcmp(plan.mode, 'record') && ...
                    (plan.visual_stimulus_armed || ...
                    plan.convert_record_to_tiff);
                if postProcessingRequired
                    if ~obj.RunState.AcquisitionStopRequested && ...
                            numel(obj.RunState.AcquisitionCycleResults) == plan.cycles
                        conversionResult = ...
                            obj.Callbacks.startRecordConversionBackground( ...
                            plan, recordPath);
                    else
                        conversionResult = obj.Callbacks.markRecordConversionSkipped( ...
                            plan, recordPath, ...
                            'capture did not complete every requested cycle');
                    end
                end
                if obj.RunState.AcquisitionStopRequested
                    finalState = 'STOPPED';
                    finalMessage = sprintf('Stopped after %d/%d cycle(s).', ...
                        obj.RunState.AcquisitionCycleIndex, plan.cycles);
                elseif string(conversionResult.status) == "queued"
                    finalState = 'CONVERTING';
                    finalMessage = sprintf( ...
                        'Capture complete %d/%d; Record post-processing queued.', ...
                        obj.RunState.AcquisitionCycleIndex, plan.cycles);
                elseif any(string({obj.RunState.AcquisitionCycleResults.status}) ~= ...
                        "complete") || ~any(string(conversionResult.status) == ...
                        ["not_requested","complete"])
                    finalState = 'COMPLETED_WITH_WARNINGS';
                    finalMessage = sprintf( ...
                        'Completed %d/%d cycle(s) with warnings; review logs and manifests.', ...
                        obj.RunState.AcquisitionCycleIndex, plan.cycles);
                else
                    finalState = 'COMPLETED';
                    finalMessage = sprintf('Completed %d/%d cycle(s).', ...
                        obj.RunState.AcquisitionCycleIndex, plan.cycles);
                end
                obj.writeAcquisitionManifest(recordPath, finalState, '');
                obj.Callbacks.setAcquisitionState(finalState, finalMessage);
                obj.Callbacks.finishAction('START_ACQUISITION', true, finalMessage);
            catch ME
                stoppedByUser = strcmp(ME.identifier, 'ZouLab:AcquisitionStopped');
                try
                    if strlength(recordPath) > 0
                        if stoppedByUser
                            manifestState = 'STOPPED';
                        else
                            manifestState = 'ERROR';
                        end
                        obj.writeAcquisitionManifest(recordPath, manifestState, ME.message);
                    end
                catch manifestError
                    obj.Logger.logException('ACQUISITION_MANIFEST_WRITE_FAILED', ...
                        manifestError);
                end
                if strcmp(ME.identifier, 'ZouLab:OperatorRequired')
                    obj.Callbacks.setAcquisitionState('ERROR', ME.message);
                    obj.Callbacks.identityBlocked();
                elseif stoppedByUser
                    obj.Callbacks.setAcquisitionState('STOPPED', ME.message);
                    obj.Logger.log('INFO', 'ACQUISITION_STOP_COMPLETED', ...
                        'CurrentCycle=%d | Message=%s', ...
                        obj.RunState.AcquisitionCycleIndex, ME.message);
                else
                    obj.Callbacks.setAcquisitionState('ERROR', ME.message);
                    obj.Callbacks.handleError('ACQUISITION_FAILED', ME);
                end
            end
            obj.DaqController.abortVisualSync();
            obj.DaqController.safeOff();
            obj.RunState.finishCapture();
            obj.Callbacks.setAcquisitionControlsLocked(false);
            obj.Callbacks.updateVisualStimulusStatus();
            if obj.RunState.CloseAfterAcquisition
                obj.Logger.log('INFO', 'APP_CLOSE_AFTER_ACQUISITION_CLEANUP', ...
                    'Acquisition cleanup completed; closing obj now.');
                obj.Callbacks.closeApp();
            end
        end

        function requestAcquisitionStop(obj)
            obj.Logger.log('INFO', 'USER_ACQUISITION_STOP_CLICKED', ...
                'Running=%d | State=%s | CurrentCycle=%d', ...
                obj.RunState.AcquisitionRunning, obj.RunState.Status, ...
                obj.RunState.AcquisitionCycleIndex);
            if ~obj.RunState.AcquisitionRunning
                obj.Logger.log('INFO', 'ACQUISITION_STOP_NOOP', ...
                    'No acquisition was running.');
                obj.Callbacks.setAcquisitionState('IDLE', 'No acquisition is running.');
                return;
            end
            obj.RunState.requestCaptureStop();
            try
                obj.Callbacks.forceAcquisitionOutputsSafe('operator_stop');
            catch ME
                obj.Logger.logException( ...
                    'ACQUISITION_STOP_SAFE_OUTPUT_FAILED', ME);
            end
            if isa(obj.Cameras, 'zoulab.CameraServiceClient')
                try
                    obj.Cameras.requestRemoteRecordStop( ...
                        'operator_stop', obj.Logger);
                catch ME
                    obj.Logger.logException( ...
                        'ACQUISITION_STOP_CAMERA_SIGNAL_FAILED', ME);
                end
            end
            obj.Callbacks.setAcquisitionState('STOPPING', ...
                'Stop requested; preserving acquired data and finishing cleanup.');
        end

        function runAcquisitionCycles(obj, plan, recordPath, frozenDaqPlan)
            if nargin < 4
                frozenDaqPlan = struct();
            end
            recordTaskCleanup = [];
            recordPreparation = struct();
            if strcmp(plan.mode, 'record')
                taskPreviewMask = obj.Callbacks.previewMask();
                for cameraIndex = plan.cameras
                    if obj.Callbacks.isPreviewActive(cameraIndex)
                        obj.Callbacks.stopCameraPreview(cameraIndex, ...
                            'record_task_prepare');
                    end
                end
                if isfield(obj.Callbacks, 'prepareRecordTask')
                    try
                        recordPreparation = obj.Callbacks.prepareRecordTask( ...
                            plan, recordPath);
                    catch ME
                        obj.finishRecordTask(plan.cameras, taskPreviewMask);
                        rethrow(ME);
                    end
                end
                recordTaskCleanup = onCleanup(@() obj.finishPreparedRecordTask( ...
                    plan.cameras, taskPreviewMask, recordPreparation));
                obj.Logger.log('INFO', 'RECORD_TASK_PREPARED', ...
                    ['Cycles=%d | Cameras=%s | PreviewStoppedOnce=1 | ', ...
                     'PreviewRestoreDeferredUntilRecordEnd=1 | ', ...
                     'InitialPreviewMask=%s'], plan.cycles, ...
                    mat2str(plan.cameras), mat2str(taskPreviewMask));
            end
            % Cycle 1 is the timing origin. Record directory allocation,
            % BIN reservation and writer startup are deliberately excluded.
            experimentClock = tic;
            obj.Logger.log('INFO', 'CYCLE_SCHEDULE_CLOCK_STARTED', ...
                ['Origin=cycle_1_execution_begin_after_record_prepare | ', ...
                 'IntervalSemantics=cycle_start_to_next_cycle_start']);
            for cycleIndex = 1:plan.cycles
                targetStart = (cycleIndex - 1) * plan.cycle_start_interval_seconds;
                remaining = targetStart - toc(experimentClock);
                if remaining > 0
                    if ~obj.Callbacks.waitForNextCycle(remaining, cycleIndex, plan.cycles)
                        return;
                    end
                elseif cycleIndex > 1
                    obj.Logger.log('WARNING', 'CYCLE_INTERVAL_OVERRUN', ...
                        ['Cycle=%d | TargetStartSeconds=%.6g | ActualReadySeconds=%.6g | ', ...
                         'OverrunSeconds=%.6g | NextCycleStartedImmediately=1'], ...
                        cycleIndex, targetStart, toc(experimentClock), ...
                        toc(experimentClock) - targetStart);
                end
                if obj.RunState.AcquisitionStopRequested
                    return;
                end
                obj.RunState.AcquisitionCycleIndex = cycleIndex;
                actualStart = toc(experimentClock);
                if isfield(recordPreparation, 'cycle_paths') && ...
                        numel(recordPreparation.cycle_paths) >= cycleIndex
                    cyclePath = string(recordPreparation.cycle_paths(cycleIndex));
                else
                    cyclePath = obj.Sessions.newCycleFolder(cycleIndex);
                end
                startedAt = char(datetime('now', ...
                    'Format', 'yyyy-MM-dd HH:mm:ss.SSS'));
                obj.Callbacks.setAcquisitionState('RUNNING', sprintf( ...
                    '%s — Cycle %d/%d started.', ...
                    obj.acquisitionModeDisplayName(plan.mode), ...
                    cycleIndex, plan.cycles));
                obj.Logger.log('INFO', 'ACQUISITION_CYCLE_BEGIN', ...
                    ['Cycle=%d/%d | TargetStartSeconds=%.6g | ', ...
                     'ActualStartSeconds=%.6g | Folder=%s'], ...
                    cycleIndex, plan.cycles, targetStart, actualStart, cyclePath);
                files = strings(1, 0);
                cycleStatus = 'complete';
                try
                    switch plan.mode
                        case 'snap'
                            frames = obj.Callbacks.captureCameras(plan.cameras, ...
                                sprintf('acquisition_cycle_%d_snap', cycleIndex), true);
                            files = obj.Callbacks.saveFrameSet(frames, cyclePath, 'Snap', plan.cameras);
                        case 'time_lapse'
                            files = obj.runTimeLapseCycle(plan, cyclePath, cycleIndex);
                        case 'record'
                            if isfield(recordPreparation, 'cycles')
                                cyclePreparation = ...
                                    recordPreparation.cycles(cycleIndex);
                                [files, cycleStatus] = obj.Callbacks.runRecordCycle( ...
                                    plan, cyclePath, cycleIndex, ...
                                    frozenDaqPlan, cyclePreparation);
                            else
                                [files, cycleStatus] = obj.Callbacks.runRecordCycle( ...
                                    plan, cyclePath, cycleIndex);
                            end
                    end
                catch ME
                    cycleStatus = 'error';
                    obj.appendCycleResult(cycleIndex, cycleStatus, startedAt, files);
                    obj.Callbacks.writeCycleManifest(cyclePath, plan, cycleIndex, ...
                        cycleStatus, files, ME.message);
                    rethrow(ME);
                end
                if obj.RunState.AcquisitionStopRequested && strcmp(cycleStatus, 'complete')
                    cycleStatus = 'stopped';
                end
                obj.appendCycleResult(cycleIndex, cycleStatus, startedAt, files);
                obj.Callbacks.writeCycleManifest(cyclePath, plan, cycleIndex, ...
                    cycleStatus, files, '');
                obj.Logger.log('SUCCESS', 'ACQUISITION_CYCLE_END', ...
                    'Cycle=%d/%d | Status=%s | Elapsed=%.6g | Files=%s', ...
                    cycleIndex, plan.cycles, cycleStatus, ...
                    toc(experimentClock) - actualStart, strjoin(files, ','));
                if obj.RunState.AcquisitionStopRequested
                    return;
                end
            end
            clear recordTaskCleanup
            obj.Logger.log('SUCCESS', 'ACQUISITION_ALL_CYCLES_COMPLETE', ...
                'Cycles=%d | Elapsed=%.6g | RecordPath=%s', ...
                plan.cycles, toc(experimentClock), recordPath);
        end

        function finishPreparedRecordTask(obj, indices, previewMask, preparation)
            obj.finishRecordTask(indices, previewMask);
            if isfield(obj.Callbacks, 'cleanupRecordPreparation') && ...
                    ~isempty(preparation)
                obj.Callbacks.cleanupRecordPreparation(preparation, ...
                    obj.RunState.AcquisitionCycleIndex + 1);
            end
        end

        function files = runTimeLapseCycle(obj, plan, cyclePath, cycleIndex)
            timeLapsePath = obj.Sessions.newCycleTimeLapseFolder(cyclePath);
            files = strings(1, 0);
            records = struct('point', {}, 'captured_at', {}, 'files', {});
            for point = 1:plan.time_lapse_points
                if obj.RunState.AcquisitionStopRequested
                    break;
                end
                obj.Callbacks.setAcquisitionState('RUNNING', sprintf( ...
                    'Cycle %d/%d | Time Lapse %d/%d', cycleIndex, ...
                    plan.cycles, point, plan.time_lapse_points));
                obj.Logger.log('INFO', 'ACQUISITION_TIMELAPSE_POINT_BEGIN', ...
                    'Cycle=%d | Point=%d/%d | Cameras=%s', cycleIndex, point, ...
                    plan.time_lapse_points, mat2str(plan.cameras));
                frames = obj.Callbacks.captureCameras(plan.cameras, sprintf( ...
                    'cycle_%d_time_lapse_%d', cycleIndex, point), true);
                pointFiles = obj.Callbacks.saveFrameSet(frames, timeLapsePath, ...
                    sprintf('F%06d', point), plan.cameras);
                files = [files pointFiles]; %#ok<AGROW>
                records(end + 1) = struct( ...
                    'point', point, ...
                    'captured_at', char(datetime('now', ...
                        'Format', 'yyyy-MM-dd HH:mm:ss.SSS')), ...
                    'files', {cellstr(pointFiles)}); %#ok<AGROW>
                obj.Logger.log('SUCCESS', 'ACQUISITION_TIMELAPSE_POINT_COMPLETE', ...
                    'Cycle=%d | Point=%d/%d | Files=%s', cycleIndex, point, ...
                    plan.time_lapse_points, strjoin(pointFiles, ','));
                if point < plan.time_lapse_points && ...
                        ~obj.Callbacks.waitInterruptible(plan.time_lapse_interval_seconds, ...
                        sprintf('Cycle %d Time Lapse interval after point %d', ...
                        cycleIndex, point))
                    break;
                end
            end
            manifest = struct( ...
                'schema_version', '3.0.0', ...
                'kind', 'time_lapse', ...
                'cycle', cycleIndex, ...
                'requested_points', plan.time_lapse_points, ...
                'saved_points', numel(records), ...
                'interval_seconds', plan.time_lapse_interval_seconds, ...
                'interval_semantics', plan.time_lapse_interval_semantics, ...
                'records', records);
            zoulab.SessionManager.writeJson(fullfile(timeLapsePath, ...
                'timelapse_manifest.json'), manifest);
        end

        function finishRecordTask(obj, indices, previewMask)
            writerTaskReleased = true;
            if isa(obj.Cameras, 'zoulab.CameraServiceClient')
                try
                    obj.Cameras.endRemoteRecordTask( ...
                        'whole_record_task_cleanup', obj.Logger);
                catch ME
                    writerTaskReleased = false;
                    obj.Logger.logException( ...
                        'RECORD_TASK_WRITER_RELEASE_FAILED', ME);
                end
            end
            try
                obj.Cameras.restorePreviewConfiguration(indices, obj.Logger);
                restored = true;
            catch ME
                restored = false;
                obj.Logger.logException( ...
                    'RECORD_TASK_CAMERA_CONFIGURATION_RESTORE_FAILED', ME);
            end
            obj.Callbacks.restartPreviewMask(previewMask, 'record_task_complete');
            obj.Callbacks.updateVisualStimulusStatus();
            obj.Logger.log('INFO', 'RECORD_TASK_CLEANUP_COMPLETE', ...
                ['Cameras=%s | WriterTaskReleased=%d | ', ...
                 'CameraConfigurationRestored=%d | ', ...
                 'PreviewRestartMask=%s | RestoreBoundary=whole_record_task'], ...
                mat2str(indices), writerTaskReleased, restored, ...
                mat2str(previewMask));
        end

        function appendCycleResult(obj, cycleIndex, status, startedAt, files)
            obj.RunState.AcquisitionCycleResults(end + 1) = struct( ...
                'cycle', cycleIndex, ...
                'status', char(string(status)), ...
                'started_at', startedAt, ...
                'completed_at', char(datetime('now', ...
                    'Format', 'yyyy-MM-dd HH:mm:ss.SSS')), ...
                'files', {cellstr(files)});
        end

        function writeAcquisitionManifest(obj, recordPath, status, errorMessage)
            manifest = struct( ...
                'schema_version', '3.0.0', ...
                'level', 'acquisition', ...
                'status', char(string(status)), ...
                'completed_at', char(datetime('now', ...
                    'Format', 'yyyy-MM-dd HH:mm:ss.SSS')), ...
                'operator_id', char(obj.Logger.OperatorID), ...
                'operator_name', char(obj.Logger.OperatorName), ...
                'plan', obj.RunState.FrozenAcquisitionPlan, ...
                'cycles', obj.RunState.AcquisitionCycleResults, ...
                'error', char(string(errorMessage)));
            zoulab.SessionManager.writeJson(fullfile(recordPath, ...
                'acquisition_manifest.json'), manifest);
            obj.Logger.log('INFO', 'ACQUISITION_MANIFEST_WRITTEN', ...
                'RecordPath=%s | Status=%s | Cycles=%d', recordPath, ...
                status, numel(obj.RunState.AcquisitionCycleResults));
        end

        function name = acquisitionModeDisplayName(~, mode)
            switch string(mode)
                case "record"
                    name = 'Record';
                case "time_lapse"
                    name = 'Time Lapse';
                otherwise
                    name = 'Snap';
            end
        end

    end
end
