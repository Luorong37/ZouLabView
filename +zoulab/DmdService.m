classdef DmdService < handle
    %DMDSERVICE Persistent child-MATLAB owner for the F4320 DLL and UDP port.
    % Control/status uses newline-delimited JSON on a dedicated localhost
    % TCP port. Pattern pixels remain on disk and are never copied through
    % the control connection.

    properties (Access = private)
        Config struct
        Logger
        Controller
        Server = []
        StopLoop logical = false
        LastFeedbackPoll double = 0
        LastParentCheck double = 0
        LastLogFlush double = 0
    end

    methods (Static)
        function run(configPath)
            configPath = string(configPath);
            try
                service = zoulab.DmdService(configPath);
                cleanup = onCleanup(@() service.cleanup());
                service.loop();
            catch ME
                try
                    config = jsondecode(fileread(configPath));
                    value = struct('status', 'error', ...
                        'failed_utc', zoulab.BinInfo.utcNow(), ...
                        'identifier', ME.identifier, 'message', ME.message, ...
                        'report', getReport(ME, 'extended', 'hyperlinks', 'off'), ...
                        'pid', feature('getpid'));
                    zoulab.BinInfo.write(fullfile( ...
                        string(config.control_folder), ...
                        'dmd_service_error.json'), value);
                catch
                end
                rethrow(ME);
            end
        end
    end

    methods (Access = private)
        function obj = DmdService(configPath)
            obj.Config = jsondecode(fileread(configPath));
            addpath(string(obj.Config.app_root));
            obj.Logger = zoulab.AppLogger(string(obj.Config.log_folder));
            obj.Logger.setIdentity(obj.Config.operator_id, ...
                obj.Config.operator_name);
            obj.Logger.setSession(obj.Config.session_id);
            obj.Controller = zoulab.DmdController( ...
                string(obj.Config.library_directory), ...
                logical(obj.Config.simulation_mode));
            obj.Controller.DeviceID = double(obj.Config.device_id);
            obj.Controller.HostAddress = string(obj.Config.host_address);
            obj.Controller.HostPort = double(obj.Config.host_port);
            obj.Controller.TargetAddress = string(obj.Config.target_address);
            obj.Controller.TargetPort = double(obj.Config.target_port);
            obj.Server = tcpserver('127.0.0.1', double(obj.Config.port), ...
                'Timeout', 10);
            configureTerminator(obj.Server, "LF");
            ready = struct('schema_version', '1.0.0', ...
                'service_kind', 'DMD', 'pid', feature('getpid'), ...
                'parent_pid', obj.Config.parent_pid, 'port', obj.Config.port, ...
                'session_token', obj.Config.session_token, ...
                'ready_utc', zoulab.BinInfo.utcNow(), ...
                'state', char(obj.Controller.State));
            zoulab.BinInfo.write(fullfile(string(obj.Config.control_folder), ...
                'dmd_service_ready.json'), ready);
            obj.Logger.log('SUCCESS', 'DMD_SERVICE_READY', ...
                ['PID=%d | ParentPID=%d | ControlEndpoint=127.0.0.1:%d | ', ...
                 'DmdUDP=%s:%d->%s:%d | SessionTokenRequired=1 | ', ...
                 'PatternTransport=shared_filesystem_path | ExternalNetworkControl=0'], ...
                feature('getpid'), obj.Config.parent_pid, obj.Config.port, ...
                obj.Controller.HostAddress, obj.Controller.HostPort, ...
                obj.Controller.TargetAddress, obj.Controller.TargetPort);
        end

        function loop(obj)
            clockValue = tic;
            while ~obj.StopLoop
                obj.processOneCommand();
                nowValue = toc(clockValue);
                if nowValue - obj.LastFeedbackPoll >= 0.1
                    obj.Controller.pollFeedback(obj.Logger);
                    obj.LastFeedbackPoll = nowValue;
                end
                if nowValue - obj.LastParentCheck >= 1
                    obj.checkParent();
                    obj.checkShutdownFile();
                    obj.LastParentCheck = nowValue;
                end
                if nowValue - obj.LastLogFlush >= 60
                    obj.Logger.flush();
                    obj.LastLogFlush = nowValue;
                end
                pause(0.001);
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
            if isfield(request, 'operator_id')
                obj.Logger.setIdentity(request.operator_id, request.operator_name);
            end
            if isfield(request, 'session_id')
                obj.Logger.setSession(request.session_id);
            end
            obj.Logger.log('INFO', 'DMD_SERVICE_COMMAND_RECEIVED', ...
                'RequestID=%.0f | Command=%s | State=%s', ...
                requestID, command, obj.Controller.State);
            response = struct('request_id', requestID, 'success', false, ...
                'service_state', char(obj.Controller.State), ...
                'result', struct(), 'error_identifier', '', 'error', '', ...
                'completed_utc', '');
            try
                response.result = obj.handleCommand(command, request.payload);
                response.success = true;
                response.service_state = char(obj.Controller.State);
                obj.Logger.log('SUCCESS', 'DMD_SERVICE_COMMAND_COMPLETE', ...
                    'RequestID=%.0f | Command=%s | State=%s', ...
                    requestID, command, obj.Controller.State);
            catch ME
                response.error_identifier = ME.identifier;
                response.error = ME.message;
                response.service_state = char(obj.Controller.State);
                obj.Logger.logException(sprintf( ...
                    'DMD_SERVICE_COMMAND_%s_FAILED', command), ME);
            end
            response.completed_utc = zoulab.BinInfo.utcNow();
            writeline(obj.Server, jsonencode(response));
        end

        function result = handleCommand(obj, command, payload)
            switch command
                case "HELLO"
                    if string(payload.session_token) ~= ...
                            string(obj.Config.session_token)
                        error('ZouLab:DmdServiceTokenMismatch', ...
                            'DMD service session token does not match.');
                    end
                    result = struct('pid', feature('getpid'), ...
                        'snapshot', obj.snapshot());
                case "CONNECT"
                    info = obj.Controller.connect(obj.Logger);
                    result = struct('device_info', info, ...
                        'snapshot', obj.snapshot());
                case "QUERY"
                    info = obj.Controller.queryDevice(obj.Logger);
                    result = struct('device_info', info, ...
                        'snapshot', obj.snapshot());
                case "CREATE_BUILTIN"
                    folder = obj.Controller.createBuiltInPattern( ...
                        string(payload.name), string(payload.root_folder), ...
                        obj.Logger);
                    result = struct('folder', char(folder), ...
                        'pattern', obj.Controller.Pattern, ...
                        'snapshot', obj.snapshot());
                case "LOAD_COMPILED"
                    obj.Controller.loadCompiledPattern(payload.manifest, obj.Logger);
                    result = struct('pattern', obj.Controller.Pattern, ...
                        'snapshot', obj.snapshot());
                case "LOAD_FOLDER"
                    obj.Controller.loadPatternFolder(string(payload.folder), ...
                        double(payload.upload_file_count), ...
                        double(payload.start_binary_position), obj.Logger, ...
                        double(payload.transfer_type), ...
                        double(payload.binary_frame_count), ...
                        double(payload.bit_depth));
                    result = struct('pattern', obj.Controller.Pattern, ...
                        'snapshot', obj.snapshot());
                case "SET_PARAM1"
                    obj.Controller.setParameters1(double(payload.delay), ...
                        double(payload.gray_bits), ...
                        double(payload.binary_picture_count), ...
                        double(payload.picture_count_flag), obj.Logger);
                    result = struct('snapshot', obj.snapshot());
                case "SET_PARAM2"
                    obj.Controller.setParameters2( ...
                        logical(payload.vertical_mirror), ...
                        logical(payload.data_reverse), ...
                        logical(payload.row_addressing), ...
                        logical(payload.input_falling), ...
                        logical(payload.output_falling), ...
                        logical(payload.divided_falling), ...
                        double(payload.division), obj.Logger);
                    result = struct('snapshot', obj.snapshot());
                case "PLAY_INTERNAL"
                    obj.Controller.playInternal(logical(payload.loop), obj.Logger);
                    result = struct('snapshot', obj.snapshot());
                case "PAUSE"
                    obj.Controller.pausePlayback(obj.Logger);
                    result = struct('snapshot', obj.snapshot());
                case "ARM_EXTERNAL"
                    obj.Controller.armExternal(logical(payload.loop), obj.Logger);
                    result = struct('snapshot', obj.snapshot());
                case "STOP"
                    obj.Controller.stop(obj.Logger);
                    result = struct('snapshot', obj.snapshot());
                case "FLOAT"
                    obj.Controller.floatMirrors(obj.Logger);
                    result = struct('snapshot', obj.snapshot());
                case "QUERY_STATUS"
                    result = struct('snapshot', obj.snapshot());
                case "SHUTDOWN"
                    obj.safeShutdown(string(payload.reason));
                    result = struct('final_state', 'DISCONNECTED', ...
                        'dmd_released', true, 'udp_released', true, ...
                        'mirrors_floated', true);
                otherwise
                    error('ZouLab:DmdServiceCommandUnknown', ...
                        'Unknown DMD service command: %s', command);
            end
        end

        function value = snapshot(obj)
            value = struct('state', char(obj.Controller.State), ...
                'connected', obj.Controller.Connected, ...
                'device_info', obj.Controller.DeviceInfo, ...
                'pattern', obj.Controller.Pattern, ...
                'last_feedback_hex', char(obj.Controller.LastFeedbackHex), ...
                'last_feedback_utc', char(obj.Controller.LastFeedbackUTC), ...
                'pid', feature('getpid'), 'port', obj.Config.port, ...
                'service_kind', 'DMD');
        end

        function safeShutdown(obj, reason)
            obj.Logger.log('INFO', 'DMD_SERVICE_SAFE_EXIT_REQUESTED', ...
                'Reason=%s | State=%s', reason, obj.Controller.State);
            obj.Controller.disconnect(obj.Logger, true);
            obj.StopLoop = true;
            obj.Logger.log('SUCCESS', 'DMD_SERVICE_SAFE_EXIT_COMPLETE', ...
                'Reason=%s | StopResetFloatDeinit=1', reason);
            obj.Logger.flush();
        end

        function checkParent(obj)
            try
                process = System.Diagnostics.Process.GetProcessById( ...
                    int32(obj.Config.parent_pid));
                alive = ~process.HasExited;
            catch
                alive = false;
            end
            if ~alive
                obj.safeShutdown("parent_process_missing");
            end
        end

        function checkShutdownFile(obj)
            pathText = fullfile(string(obj.Config.control_folder), ...
                'dmd_service_shutdown.request.json');
            if isfile(pathText)
                obj.safeShutdown("shutdown_file");
            end
        end

        function cleanup(obj)
            if ~isempty(obj.Controller) && obj.Controller.Connected
                try
                    obj.Controller.disconnect(obj.Logger, true);
                catch ME
                    obj.Logger.logException('DMD_SERVICE_CLEANUP_FAILED', ME);
                end
            end
            try
                obj.Logger.flush();
            catch
            end
        end
    end
end
