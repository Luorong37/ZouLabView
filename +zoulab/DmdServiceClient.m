classdef DmdServiceClient < handle
    %DMDSERVICECLIENT Main-process proxy for the persistent DMD MATLAB.

    properties
        SimulationMode logical = false
        DeviceID double = 1
        HostAddress string = ""
        HostPort double = 6002
        TargetAddress string = ""
        TargetPort double = 6003
        LibraryDirectory string = ""
    end

    properties (SetAccess = private)
        Connected logical = false
        State string = "DISCONNECTED"
        DeviceInfo struct = struct()
        Pattern struct = struct()
        LastFeedbackHex string = ""
        LastFeedbackUTC string = ""
        ServicePID double = NaN
        ControlPort double = NaN
        ControlFolder string = ""
        Started logical = false
    end

    properties (Access = private)
        AppRoot string
        Logger
        Process = []
        Tcp = []
        NextRequestID uint64 = uint64(1)
        SessionToken string = ""
        ShuttingDown logical = false
        RequestInFlight logical = false
    end

    methods
        function obj = DmdServiceClient(appRoot, libraryDirectory, logger, simulationMode)
            obj.AppRoot = string(appRoot);
            obj.LibraryDirectory = string(libraryDirectory);
            obj.Logger = logger;
            if nargin >= 4
                obj.SimulationMode = logical(simulationMode);
            end
        end

        function info = connect(obj, logger)
            obj.ensureStarted();
            response = obj.request("CONNECT", struct(), 20);
            obj.applySnapshot(response.result.snapshot);
            info = response.result.device_info;
            logger.log('SUCCESS', 'DMD_SERVICE_CONNECT_CONFIRMED', ...
                'ServicePID=%d | ControlPort=%d | State=%s', ...
                obj.ServicePID, obj.ControlPort, obj.State);
        end

        function info = queryDevice(obj, logger)
            response = obj.request("QUERY", struct(), 10);
            obj.applySnapshot(response.result.snapshot);
            info = response.result.device_info;
            logger.log('SUCCESS', 'DMD_SERVICE_QUERY_CONFIRMED', ...
                'ServicePID=%d | State=%s', obj.ServicePID, obj.State);
        end

        function folder = createBuiltInPattern(obj, name, rootFolder, logger)
            obj.ensureStarted();
            response = obj.request("CREATE_BUILTIN", struct( ...
                'name', char(string(name)), ...
                'root_folder', char(string(rootFolder))), 60);
            obj.applySnapshot(response.result.snapshot);
            folder = string(response.result.folder);
            logger.log('SUCCESS', 'DMD_SERVICE_BUILTIN_PATTERN_CONFIRMED', ...
                'Name=%s | Folder=%s | ServicePID=%d', ...
                string(name), folder, obj.ServicePID);
        end

        function loadCompiledPattern(obj, manifest, logger)
            response = obj.request("LOAD_COMPILED", struct( ...
                'manifest', manifest), 300);
            obj.applySnapshot(response.result.snapshot);
            logger.log('SUCCESS', 'DMD_SERVICE_PATTERN_LOAD_CONFIRMED', ...
                ['Folder=%s | UploadFiles=%d | BinaryFrames=%d | ', ...
                 'ServicePID=%d'], string(manifest.folder), ...
                double(manifest.upload_file_count), ...
                double(manifest.binary_frame_count), obj.ServicePID);
        end

        function loadPatternFolder(obj, folder, pictureCount, startPosition, ...
                logger, transferType, binaryFrameCount, bitDepth)
            if nargin < 6
                transferType = 1;
            end
            if nargin < 7
                binaryFrameCount = pictureCount;
            end
            if nargin < 8
                bitDepth = 1;
            end
            manifestPath = fullfile(string(folder), 'pattern_manifest.json');
            if isfile(manifestPath)
                obj.loadCompiledPattern(jsondecode(fileread(manifestPath)), logger);
                return;
            end
            payload = struct('folder', char(string(folder)), ...
                'upload_file_count', double(pictureCount), ...
                'start_binary_position', double(startPosition), ...
                'transfer_type', double(transferType), ...
                'binary_frame_count', double(binaryFrameCount), ...
                'bit_depth', double(bitDepth));
            response = obj.request("LOAD_FOLDER", payload, 300);
            obj.applySnapshot(response.result.snapshot);
            logger.log('WARNING', 'DMD_LEGACY_FOLDER_LOADED', ...
                ['Folder=%s | FileCount=%d | BitDepth=%d | ', ...
                 'BinaryFrameCount=%d | ManifestMissing=1'], string(folder), ...
                pictureCount, bitDepth, binaryFrameCount);
        end

        function setParameters1(obj, delayValue, grayBits, binaryCount, flag, logger)
            response = obj.request("SET_PARAM1", struct('delay', delayValue, ...
                'gray_bits', grayBits, 'binary_picture_count', binaryCount, ...
                'picture_count_flag', flag), 10);
            obj.applySnapshot(response.result.snapshot);
            logger.log('SUCCESS', 'DMD_SERVICE_PARAMETER_1_CONFIRMED', ...
                'ServicePID=%d', obj.ServicePID);
        end

        function setParameters2(obj, verticalMirror, dataReverse, rowAddressing, ...
                inputFalling, outputFalling, dividedFalling, division, logger)
            payload = struct('vertical_mirror', logical(verticalMirror), ...
                'data_reverse', logical(dataReverse), ...
                'row_addressing', logical(rowAddressing), ...
                'input_falling', logical(inputFalling), ...
                'output_falling', logical(outputFalling), ...
                'divided_falling', logical(dividedFalling), ...
                'division', double(division));
            response = obj.request("SET_PARAM2", payload, 10);
            obj.applySnapshot(response.result.snapshot);
            logger.log('SUCCESS', 'DMD_SERVICE_PARAMETER_2_CONFIRMED', ...
                'ServicePID=%d', obj.ServicePID);
        end

        function playInternal(obj, loopPlayback, logger)
            response = obj.request("PLAY_INTERNAL", struct( ...
                'loop', logical(loopPlayback)), 10);
            obj.applySnapshot(response.result.snapshot);
            logger.log('SUCCESS', 'DMD_SERVICE_INTERNAL_PLAY_CONFIRMED', ...
                'Loop=%d | State=%s', loopPlayback, obj.State);
        end

        function pausePlayback(obj, logger)
            response = obj.request("PAUSE", struct(), 10);
            obj.applySnapshot(response.result.snapshot);
            logger.log('SUCCESS', 'DMD_SERVICE_PAUSE_CONFIRMED', ...
                'State=%s', obj.State);
        end

        function armExternal(obj, loopPlayback, logger)
            response = obj.request("ARM_EXTERNAL", struct( ...
                'loop', logical(loopPlayback)), 10);
            obj.applySnapshot(response.result.snapshot);
            logger.log('SUCCESS', 'DMD_SERVICE_EXTERNAL_ARM_CONFIRMED', ...
                'Loop=%d | State=%s', loopPlayback, obj.State);
        end

        function stop(obj, logger)
            if ~obj.Started || ~obj.Connected
                return;
            end
            response = obj.request("STOP", struct(), 10);
            obj.applySnapshot(response.result.snapshot);
            logger.log('SUCCESS', 'DMD_SERVICE_STOP_CONFIRMED', ...
                'State=%s', obj.State);
        end

        function floatMirrors(obj, logger)
            response = obj.request("FLOAT", struct(), 10);
            obj.applySnapshot(response.result.snapshot);
            logger.log('SUCCESS', 'DMD_SERVICE_FLOAT_CONFIRMED', ...
                'State=%s', obj.State);
        end

        function status = queryStatus(obj)
            if ~obj.Started
                status = struct('state', 'DISCONNECTED', 'pid', NaN);
                return;
            end
            response = obj.request("QUERY_STATUS", struct(), 5);
            obj.applySnapshot(response.result.snapshot);
            status = response.result.snapshot;
        end

        function owner = hostPortOwner(obj)
            command = sprintf('netstat -ano -p UDP');
            [status, output] = system(command);
            if status ~= 0
                error('ZouLab:DmdPortInspectionFailed', ...
                    'Windows could not inspect UDP port %d: %s', ...
                    obj.HostPort, strtrim(output));
            end
            expression = sprintf( ...
                '(?m)^\\s*UDP\\s+\\S+:%d\\s+\\*:\\*\\s+(\\d+)\\s*$', ...
                round(obj.HostPort));
            tokens = regexp(output, expression, 'tokens');
            if isempty(tokens)
                owner = struct('found', false, 'pid', NaN, ...
                    'image_name', '', 'is_dmd_service', false);
                return;
            end
            pid = str2double(tokens{1}{1});
            [~, taskText] = system(sprintf( ...
                'tasklist /FI "PID eq %d" /FO CSV /NH', round(pid)));
            fields = regexp(strtrim(taskText), ...
                '^"([^"]+)"', 'tokens', 'once');
            imageName = 'unknown';
            if ~isempty(fields)
                imageName = fields{1};
            end
            owner = struct('found', true, 'pid', pid, ...
                'image_name', imageName, ...
                'is_dmd_service', pid == obj.ServicePID);
        end

        function recoverHostPort(obj, expectedPID, logger)
            if obj.Connected
                error('ZouLab:DmdPortRecoveryWhileConnected', ...
                    'Disconnect DMD normally; recovery is only for a failed connection.');
            end
            owner = obj.hostPortOwner();
            if ~owner.found
                logger.log('SUCCESS', 'DMD_UDP_PORT_ALREADY_FREE', ...
                    'Port=%d | HardwareCommandIssued=0', obj.HostPort);
                return;
            end
            if round(owner.pid) ~= round(expectedPID)
                error('ZouLab:DmdPortOwnerChanged', ...
                    ['UDP port %d owner changed from PID %d to PID %d. ', ...
                     'Inspect again before stopping a process.'], ...
                    obj.HostPort, expectedPID, owner.pid);
            end
            logger.log('WARNING', 'USER_DMD_UDP_PORT_RECOVERY_CONFIRMED', ...
                'Port=%d | PID=%d | Image=%s', obj.HostPort, ...
                owner.pid, owner.image_name);
            [status, output] = system(sprintf( ...
                'taskkill /F /PID %d', round(owner.pid)));
            if status ~= 0
                error('ZouLab:DmdPortOwnerStopFailed', ...
                    'Could not stop PID %d: %s', owner.pid, strtrim(output));
            end
            if owner.is_dmd_service
                obj.Tcp = [];
                obj.Process = [];
                obj.Started = false;
                obj.ServicePID = NaN;
                obj.ControlPort = NaN;
                obj.State = "DISCONNECTED";
            end
            pause(0.25);
            remaining = obj.hostPortOwner();
            if remaining.found
                error('ZouLab:DmdPortStillOccupied', ...
                    'UDP port %d is still owned by PID %d.', ...
                    obj.HostPort, remaining.pid);
            end
            logger.log('SUCCESS', 'DMD_UDP_PORT_RECOVERED', ...
                'Port=%d | StoppedPID=%d | PortFree=1', ...
                obj.HostPort, owner.pid);
        end

        function status = disconnect(obj, logger)
            status = struct('ack_received', false, ...
                'dmd_released_ack', false, 'udp_released_ack', false, ...
                'mirrors_floated_ack', false, 'child_exited', true, ...
                'host_port_free', true, 'complete', true);
            if obj.ShuttingDown
                return;
            end
            obj.ShuttingDown = true;
            cleanup = onCleanup(@() obj.finishShutdown());
            if ~obj.Started
                obj.Connected = false;
                obj.State = "DISCONNECTED";
                return;
            end
            try
                response = obj.request("SHUTDOWN", struct( ...
                    'reason', 'safe_app_exit'), 30);
                status.ack_received = true;
                status.dmd_released_ack = logical(response.result.dmd_released);
                status.udp_released_ack = logical(response.result.udp_released);
                status.mirrors_floated_ack = ...
                    logical(response.result.mirrors_floated);
                logger.log('SUCCESS', 'DMD_SERVICE_SAFE_EXIT_ACK', ...
                    ['ServicePID=%d | DmdReleased=%d | UDPReleased=%d | ', ...
                     'MirrorsFloated=%d'], obj.ServicePID, ...
                    logical(response.result.dmd_released), ...
                    logical(response.result.udp_released), ...
                    logical(response.result.mirrors_floated));
            catch ME
                logger.logException('DMD_SERVICE_SAFE_EXIT_FAILED', ME);
                fallback = struct('reason', 'safe_exit_tcp_fallback', ...
                    'requested_utc', zoulab.BinInfo.utcNow(), ...
                    'parent_pid', feature('getpid'));
                zoulab.BinInfo.write(fullfile(obj.ControlFolder, ...
                    'dmd_service_shutdown.request.json'), fallback);
            end
            obj.Tcp = [];
            childExited = false;
            try
                if ~isempty(obj.Process) && ~obj.Process.HasExited
                    obj.Process.WaitForExit(30000);
                end
                childExited = isempty(obj.Process) || obj.Process.HasExited;
            catch
            end
            status.child_exited = childExited;
            try
                owner = obj.hostPortOwner();
                status.host_port_free = ~owner.found;
            catch ME
                status.host_port_free = false;
                logger.logException('DMD_SAFE_EXIT_PORT_VERIFY_FAILED', ME);
            end
            status.complete = status.ack_received && ...
                status.dmd_released_ack && status.udp_released_ack && ...
                status.mirrors_floated_ack && status.child_exited && ...
                status.host_port_free;
            if status.complete
                logger.log('SUCCESS', 'DMD_SAFE_EXIT_VERIFIED', ...
                    ['ChildExited=1 | HostPortFree=1 | DmdReleasedAck=1 | ', ...
                     'UdpReleasedAck=1 | MirrorsFloatedAck=1']);
            else
                logger.log('ERROR', 'DMD_SAFE_EXIT_INCOMPLETE', ...
                    ['Ack=%d | ChildExited=%d | HostPortFree=%d | ', ...
                     'DmdReleasedAck=%d | UdpReleasedAck=%d | ', ...
                     'MirrorsFloatedAck=%d'], status.ack_received, ...
                    status.child_exited, status.host_port_free, ...
                    status.dmd_released_ack, status.udp_released_ack, ...
                    status.mirrors_floated_ack);
            end
            obj.Started = false;
            obj.Connected = false;
            obj.State = "DISCONNECTED";
            obj.Process = [];
        end

        function delete(obj)
            if obj.Started && ~obj.ShuttingDown
                try
                    obj.disconnect(obj.Logger);
                catch
                end
            end
        end
    end

    methods (Access = private)
        function ensureStarted(obj)
            if obj.Started
                return;
            end
            obj.ControlPort = zoulab.DmdServiceClient.reservePort();
            obj.SessionToken = string(char(java.util.UUID.randomUUID()));
            obj.ControlFolder = string(fullfile(obj.AppRoot, 'tmp', ...
                "dmd_service_" + feature('getpid') + "_" + obj.SessionToken));
            mkdir(obj.ControlFolder);
            config = struct('schema_version', '1.0.0', ...
                'app_root', char(obj.AppRoot), ...
                'library_directory', char(obj.LibraryDirectory), ...
                'control_folder', char(obj.ControlFolder), ...
                'log_folder', char(fullfile(obj.ControlFolder, 'logs')), ...
                'port', obj.ControlPort, 'parent_pid', feature('getpid'), ...
                'session_token', char(obj.SessionToken), ...
                'simulation_mode', obj.SimulationMode, ...
                'operator_id', char(obj.Logger.OperatorID), ...
                'operator_name', char(obj.Logger.OperatorName), ...
                'session_id', char(obj.Logger.SessionID), ...
                'device_id', obj.DeviceID, ...
                'host_address', char(obj.HostAddress), 'host_port', obj.HostPort, ...
                'target_address', char(obj.TargetAddress), ...
                'target_port', obj.TargetPort);
            configPath = fullfile(obj.ControlFolder, 'dmd_service_config.json');
            zoulab.BinInfo.write(configPath, config);
            executable = string(fullfile(matlabroot, 'bin', 'matlab.exe'));
            command = sprintf("addpath('%s'); zoulab.DmdService.run('%s');", ...
                zoulab.DmdServiceClient.matlabQuote(obj.AppRoot), ...
                zoulab.DmdServiceClient.matlabQuote(configPath));
            startInfo = System.Diagnostics.ProcessStartInfo();
            startInfo.FileName = char(executable);
            consolePath = fullfile(obj.ControlFolder, 'dmd_service_console.log');
            startInfo.Arguments = sprintf('-logfile "%s" -batch "%s"', ...
                char(consolePath), command);
            startInfo.WorkingDirectory = char(obj.AppRoot);
            startInfo.UseShellExecute = false;
            startInfo.CreateNoWindow = true;
            startInfo.WindowStyle = System.Diagnostics.ProcessWindowStyle.Hidden;
            process = System.Diagnostics.Process();
            process.StartInfo = startInfo;
            if ~process.Start()
                error('ZouLab:DmdServiceLaunchFailed', ...
                    'Windows did not start the persistent DMD MATLAB.');
            end
            obj.Process = process;
            readyPath = fullfile(obj.ControlFolder, 'dmd_service_ready.json');
            errorPath = fullfile(obj.ControlFolder, 'dmd_service_error.json');
            waitClock = tic;
            while ~isfile(readyPath)
                if isfile(errorPath)
                    value = jsondecode(fileread(errorPath));
                    error('ZouLab:DmdServiceRemoteError', '%s', ...
                        string(value.message));
                end
                if process.HasExited
                    pause(0.25);
                    if isfile(errorPath)
                        value = jsondecode(fileread(errorPath));
                        error('ZouLab:DmdServiceRemoteError', '%s', ...
                            string(value.message));
                    end
                    error('ZouLab:DmdServiceExitedBeforeReady', ...
                        'DMD service exited with code %d.', process.ExitCode);
                end
                if toc(waitClock) > 90
                    error('ZouLab:DmdServiceReadyTimeout', ...
                        'DMD service did not become ready within 90 seconds.');
                end
                pause(0.05);
                drawnow limitrate nocallbacks;
            end
            ready = jsondecode(fileread(readyPath));
            if ~strcmp(string(ready.service_kind), "DMD") || ...
                    string(ready.session_token) ~= obj.SessionToken
                error('ZouLab:DmdServiceHandshakeInvalid', ...
                    'DMD service identity or session token is invalid.');
            end
            obj.ServicePID = double(ready.pid);
            obj.Tcp = tcpclient('127.0.0.1', obj.ControlPort, ...
                'Timeout', 10, 'ConnectTimeout', 10, ...
                'EnableTransferDelay', false);
            configureTerminator(obj.Tcp, "LF");
            obj.Started = true;
            obj.Logger.log('SUCCESS', 'DMD_SERVICE_STARTED', ...
                ['PID=%d | ParentPID=%d | ControlEndpoint=127.0.0.1:%d | ', ...
                 'CameraControlPortShared=0 | SessionTokenRequired=1 | ', ...
                 'DmdUDPHost=%s:%d | DmdTarget=%s:%d | ControlFolder=%s'], ...
                obj.ServicePID, feature('getpid'), obj.ControlPort, ...
                obj.HostAddress, obj.HostPort, obj.TargetAddress, ...
                obj.TargetPort, obj.ControlFolder);
            response = obj.request("HELLO", struct( ...
                'session_token', char(obj.SessionToken)), 10);
            obj.applySnapshot(response.result.snapshot);
        end

        function response = request(obj, command, payload, timeoutSeconds)
            if obj.RequestInFlight
                error('ZouLab:DmdServiceControlBusy', ...
                    'Another DMD command is still completing.');
            end
            if isempty(obj.Tcp)
                error('ZouLab:DmdServiceNotConnected', ...
                    'DMD service control channel is unavailable.');
            end
            obj.RequestInFlight = true;
            cleanup = onCleanup(@() obj.finishRequest());
            requestID = obj.NextRequestID;
            obj.NextRequestID = obj.NextRequestID + uint64(1);
            value = struct('request_id', double(requestID), ...
                'command', char(upper(string(command))), 'payload', payload, ...
                'operator_id', char(obj.Logger.OperatorID), ...
                'operator_name', char(obj.Logger.OperatorName), ...
                'session_id', char(obj.Logger.SessionID), ...
                'requested_utc', zoulab.BinInfo.utcNow());
            writeline(obj.Tcp, jsonencode(value));
            waitClock = tic;
            while obj.Tcp.NumBytesAvailable < 1
                if ~isempty(obj.Process) && obj.Process.HasExited
                    error('ZouLab:DmdServiceExited', ...
                        'DMD service exited during %s.', command);
                end
                if toc(waitClock) > timeoutSeconds
                    error('ZouLab:DmdServiceCommandTimeout', ...
                        'DMD service command %s timed out after %.1f seconds.', ...
                        command, timeoutSeconds);
                end
                pause(0.005);
                drawnow limitrate nocallbacks;
            end
            response = jsondecode(char(readline(obj.Tcp)));
            if double(response.request_id) ~= double(requestID)
                error('ZouLab:DmdServiceResponseMismatch', ...
                    'Expected DMD response %d but received %d.', ...
                    requestID, response.request_id);
            end
            obj.State = string(response.service_state);
            if ~logical(response.success)
                error('ZouLab:DmdServiceCommandFailed', ...
                    'DMD service %s failed (%s): %s', command, ...
                    string(response.error_identifier), string(response.error));
            end
        end

        function applySnapshot(obj, value)
            obj.State = string(value.state);
            obj.Connected = logical(value.connected);
            obj.DeviceInfo = value.device_info;
            obj.Pattern = value.pattern;
            obj.LastFeedbackHex = string(value.last_feedback_hex);
            obj.LastFeedbackUTC = string(value.last_feedback_utc);
        end

        function finishRequest(obj)
            obj.RequestInFlight = false;
        end

        function finishShutdown(obj)
            obj.ShuttingDown = false;
        end
    end

    methods (Static, Access = private)
        function port = reservePort()
            listener = System.Net.Sockets.TcpListener( ...
                System.Net.IPAddress.Loopback, 0);
            listener.Start();
            cleanup = onCleanup(@() listener.Stop());
            port = double(listener.LocalEndpoint.Port);
        end

        function value = matlabQuote(textValue)
            value = strrep(char(string(textValue)), '''', '''''');
        end
    end
end
