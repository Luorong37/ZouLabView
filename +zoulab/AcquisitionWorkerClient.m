classdef AcquisitionWorkerClient < handle
    %ACQUISITIONWORKERCLIENT Launch and supervise the camera MATLAB process.

    properties (SetAccess = private)
        ControlFolder string = ""
        ConfigPath string = ""
        Process = []
        Ready logical = false
        StopRequested logical = false
        Completed logical = false
    end

    properties (Access = private)
        Logger
    end

    methods
        function obj = AcquisitionWorkerClient(config, logger)
            obj.Logger = logger;
            obj.ControlFolder = string(config.control_folder);
            if ~exist(obj.ControlFolder, 'dir')
                mkdir(obj.ControlFolder);
            end
            obj.ConfigPath = fullfile(obj.ControlFolder, 'worker_config.json');
            zoulab.BinInfo.write(obj.ConfigPath, config);
            matlabExecutable = string(fullfile(matlabroot, 'bin', 'matlab.exe'));
            appRoot = string(config.app_root);
            command = sprintf("addpath('%s'); zoulab.AcquisitionWorkerService.run('%s');", ...
                zoulab.AcquisitionWorkerClient.matlabQuote(appRoot), ...
                zoulab.AcquisitionWorkerClient.matlabQuote(obj.ConfigPath));
            startInfo = System.Diagnostics.ProcessStartInfo();
            startInfo.FileName = char(matlabExecutable);
            startInfo.Arguments = sprintf('-batch "%s"', command);
            startInfo.WorkingDirectory = char(appRoot);
            startInfo.UseShellExecute = false;
            startInfo.CreateNoWindow = true;
            startInfo.WindowStyle = System.Diagnostics.ProcessWindowStyle.Hidden;
            process = System.Diagnostics.Process();
            process.StartInfo = startInfo;
            if ~process.Start()
                error('ZouLab:AcquisitionWorkerLaunchFailed', ...
                    'Windows did not start the acquisition worker MATLAB.');
            end
            obj.Process = process;
            logger.log('SUCCESS', 'ACQUISITION_WORKER_PROCESS_STARTED', ...
                ['PID=%d | Config=%s | ControlFolder=%s | ', ...
                 'CameraOwnership=worker | PTBOwnership=main | ', ...
                 'DaqOwnership=main'], process.Id, obj.ConfigPath, ...
                obj.ControlFolder);
        end

        function ready = waitReady(obj, timeoutSeconds, progressFcn)
            if nargin < 3
                progressFcn = [];
            end
            readyPath = fullfile(obj.ControlFolder, 'worker_ready.json');
            errorPath = fullfile(obj.ControlFolder, 'worker_error.json');
            waitClock = tic;
            while ~isfile(readyPath)
                obj.throwWorkerErrorIfPresent(errorPath);
                if ~isempty(obj.Process) && obj.Process.HasExited
                    error('ZouLab:AcquisitionWorkerExitedBeforeReady', ...
                        'Acquisition worker exited with code %d before ready.', ...
                        obj.Process.ExitCode);
                end
                if toc(waitClock) > timeoutSeconds
                    error('ZouLab:AcquisitionWorkerReadyTimeout', ...
                        'Acquisition worker was not ready within %.1f seconds.', ...
                        timeoutSeconds);
                end
                if ~isempty(progressFcn)
                    progressFcn(toc(waitClock), timeoutSeconds);
                end
                pause(0.05);
                drawnow limitrate;
            end
            ready = jsondecode(fileread(readyPath));
            obj.Ready = true;
            obj.Logger.log('SUCCESS', 'ACQUISITION_WORKER_READY_CONFIRMED', ...
                'PID=%d | WaitSeconds=%.6g | ReadyUtc=%s', ...
                obj.Process.Id, toc(waitClock), string(ready.ready_utc));
        end

        function requestStop(obj, reason)
            if nargin < 2
                reason = 'main_acquisition_window_complete';
            end
            if obj.StopRequested || obj.Completed
                return;
            end
            value = struct('requested_utc', zoulab.BinInfo.utcNow(), ...
                'reason', char(string(reason)));
            zoulab.BinInfo.write(fullfile(obj.ControlFolder, ...
                'worker_stop.request.json'), value);
            obj.StopRequested = true;
            obj.Logger.log('INFO', 'ACQUISITION_WORKER_STOP_REQUESTED', ...
                'PID=%d | Reason=%s', obj.Process.Id, string(reason));
        end

        function result = waitComplete(obj, timeoutSeconds, progressFcn)
            if nargin < 3
                progressFcn = [];
            end
            completePath = fullfile(obj.ControlFolder, 'worker_complete.json');
            errorPath = fullfile(obj.ControlFolder, 'worker_error.json');
            resultPath = fullfile(obj.ControlFolder, 'worker_result.mat');
            waitClock = tic;
            while ~isfile(completePath)
                obj.throwWorkerErrorIfPresent(errorPath);
                if ~isempty(obj.Process) && obj.Process.HasExited
                    pause(0.1);
                    obj.throwWorkerErrorIfPresent(errorPath);
                    if ~isfile(completePath)
                        error('ZouLab:AcquisitionWorkerExitedIncomplete', ...
                            ['Acquisition worker exited with code %d without ', ...
                             'a completion result.'], obj.Process.ExitCode);
                    end
                end
                if toc(waitClock) > timeoutSeconds
                    error('ZouLab:AcquisitionWorkerCompleteTimeout', ...
                        'Acquisition worker did not complete within %.1f seconds.', ...
                        timeoutSeconds);
                end
                if ~isempty(progressFcn)
                    progressFcn(toc(waitClock), timeoutSeconds);
                end
                pause(0.05);
                drawnow limitrate;
            end
            if ~isfile(resultPath)
                error('ZouLab:AcquisitionWorkerResultMissing', ...
                    'Worker completion exists but result MAT is missing: %s', ...
                    resultPath);
            end
            loaded = load(resultPath, 'result');
            result = loaded.result;
            obj.Completed = true;
            obj.Logger.log('SUCCESS', 'ACQUISITION_WORKER_RESULT_RECEIVED', ...
                ['PID=%d | WaitSeconds=%.6g | Status=%s | ', ...
                 'FramesRetrieved=%s | FramesWritten=%s'], obj.Process.Id, ...
                toc(waitClock), string(result.status), ...
                mat2str(result.frames_retrieved), ...
                mat2str(result.frames_written));
        end

        function delete(obj)
            if isempty(obj.Process)
                return;
            end
            try
                if ~obj.Process.HasExited && ~obj.Completed
                    obj.requestStop('client_cleanup');
                    if ~obj.Process.WaitForExit(15000)
                        obj.Logger.log('WARNING', ...
                            'ACQUISITION_WORKER_STILL_RUNNING_AFTER_CLEANUP', ...
                            ['PID=%d | ForcedTermination=0 | ', ...
                             'SafeStopRequestRetained=1'], obj.Process.Id);
                    end
                end
            catch ME
                obj.Logger.logException('ACQUISITION_WORKER_CLEANUP_FAILED', ME);
            end
        end
    end

    methods (Access = private)
        function throwWorkerErrorIfPresent(~, errorPath)
            if ~isfile(errorPath)
                return;
            end
            value = jsondecode(fileread(errorPath));
            error('ZouLab:AcquisitionWorkerRemoteError', ...
                'Worker failed (%s): %s', string(value.identifier), ...
                string(value.message));
        end
    end

    methods (Static, Access = private)
        function value = matlabQuote(textValue)
            value = strrep(char(string(textValue)), '''', '''''');
        end
    end
end
