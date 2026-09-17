classdef DmdController < handle
    %DMDCONTROLLER Built-in controller for the F4320 HC DMD library.
    % Commands are sent directly to the vendor DLL; the legacy HC/iDMD UI
    % is not instantiated.

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
        LibraryAlias string = "zoulab_fd_dlp_hc"
        LastError string = ""
        LastFeedbackHex string = ""
        LastFeedbackUTC string = ""
    end

    properties (Constant, Access = private)
        CommandInternalSingle = 1
        CommandInternalLoop = 2
        CommandExternalSingle = 3
        CommandExternalLoop = 4
        CommandStop = 5
        CommandQuery = 7
        CommandReset = 9
        CommandFloat = 10
        CommandPause = 11
        CommandDeviceReset = 13
    end

    methods
        function obj = DmdController(libraryDirectory, simulationMode)
            if nargin >= 1
                obj.LibraryDirectory = string(libraryDirectory);
            end
            if nargin >= 2
                obj.SimulationMode = logical(simulationMode);
            end
        end

        function info = connect(obj, logger)
            if obj.Connected
                info = obj.DeviceInfo;
                return;
            end
            try
                if obj.SimulationMode
                    obj.DeviceInfo = obj.simulatedInfo();
                else
                    obj.loadVendorLibrary();
                    result = calllib(obj.LibraryAlias, 'FD_DLP_HC_Init', ...
                        int32(obj.DeviceID), char(obj.HostAddress), ...
                        int32(obj.HostPort), char(obj.TargetAddress), ...
                        int32(obj.TargetPort));
                    obj.assertResult(result, 'UDP initialization');
                    obj.Connected = true;
                    obj.State = "CONNECTED_STOPPED";
                    obj.DeviceInfo = obj.queryDevice(logger);
                end
                obj.Connected = true;
                obj.State = "CONNECTED_STOPPED";
                obj.LastError = "";
                logger.log('SUCCESS', 'DMD_CONNECT_SUCCESS', ...
                    ['DeviceID=%d | Host=%s:%d | Target=%s:%d | ', ...
                     'Resolution=%dx%d | Storage=%s | StorageCount=%g | ', ...
                     'RequiredImageMultiple=%g | Simulation=%d'], ...
                    obj.DeviceID, obj.HostAddress, obj.HostPort, ...
                    obj.TargetAddress, obj.TargetPort, ...
                    obj.DeviceInfo.width, obj.DeviceInfo.height, ...
                    obj.DeviceInfo.storage_type, obj.DeviceInfo.storage_count, ...
                    obj.DeviceInfo.required_image_multiple, obj.SimulationMode);
                info = obj.DeviceInfo;
            catch ME
                obj.LastError = string(ME.message);
                obj.State = "ERROR";
                obj.Connected = false;
                logger.logException('DMD_CONNECT_FAILED', ME);
                rethrow(ME);
            end
        end

        function info = queryDevice(obj, logger)
            obj.assertConnected();
            if obj.SimulationMode
                info = obj.simulatedInfo();
                obj.DeviceInfo = info;
                return;
            end
            result = calllib(obj.LibraryAlias, ...
                'FD_DLP_HC_Send_Fixed_Cmd_Noparam', ...
                int32(obj.DeviceID), int32(obj.CommandQuery));
            obj.assertResult(result, 'query command');
            bytes = zeros(1, 0, 'uint8');
            waitClock = tic;
            while numel(bytes) < 32 && toc(waitClock) < 3
                response = libpointer('uint8Ptr', zeros(1, 64, 'uint8'));
                received = calllib(obj.LibraryAlias, 'FD_DLP_HC_Reveive', ...
                    int32(obj.DeviceID), response);
                if received > 0
                    packet = uint8(response.Value(1:min(64, received)));
                    bytes = [bytes packet]; %#ok<AGROW>
                    obj.LastFeedbackHex = upper(reshape(dec2hex(packet, 2).', 1, []));
                    obj.LastFeedbackUTC = zoulab.BinInfo.utcNow();
                    logger.log('INFO', 'DMD_FEEDBACK_PACKET_RECEIVED', ...
                        'Bytes=%d | TotalQueryBytes=%d | Raw=%s', ...
                        numel(packet), numel(bytes), obj.LastFeedbackHex);
                else
                    pause(0.01);
                end
            end
            if numel(bytes) < 32
                error('ZouLab:DmdQueryNoResponse', ...
                    'DMD query returned %d of 32 required bytes.', numel(bytes));
            end
            bytes = bytes(1:32);
            analysisText = obj.analyseDevice(bytes);
            info = obj.parseDeviceBytes(bytes);
            info.analysis_text = char(analysisText);
            obj.DeviceInfo = info;
            logger.log('SUCCESS', 'DMD_QUERY_SUCCESS', ...
                ['Raw=%s | Resolution=%dx%d | Storage=%s | StorageCount=%g | ', ...
                 'RequiredImageMultiple=%g | LoadedImages=%g'], ...
                upper(reshape(dec2hex(bytes, 2).', 1, [])), ...
                info.width, info.height, info.storage_type, ...
                info.storage_count, info.required_image_multiple, ...
                info.loaded_image_count);
        end

        function folder = createBuiltInPattern(obj, presetName, rootFolder, logger)
            obj.assertConnected();
            presetName = upper(string(presetName));
            if ~any(presetName == ["ALL_OFF", "ALL_ON"])
                error('ZouLab:DmdPresetInvalid', ...
                    'Built-in DMD preset must be ALL_OFF or ALL_ON.');
            end
            multiple = obj.DeviceInfo.required_image_multiple;
            if ~isfinite(multiple)
                error('ZouLab:DmdImageMultipleUnknown', ...
                    'Query the DMD before generating a built-in pattern.');
            end
            stamp = char(datetime('now', 'Format', 'yyyyMMdd_HHmmss_SSS'));
            folder = string(fullfile(rootFolder, ...
                lower(presetName) + "_" + stamp));
            manifest = zoulab.DmdPatternCompiler.compileBuiltIn( ...
                presetName, folder, 8, multiple, logger);
            obj.Pattern = manifest;
        end

        function loadPatternFolder(obj, folder, pictureCount, startPosition, ...
                logger, transferType, binaryFrameCount, bitDepth)
            obj.assertStopped();
            folder = string(folder);
            pictureCount = round(double(pictureCount));
            startPosition = round(double(startPosition));
            if nargin < 6
                transferType = 1;
            end
            if nargin < 7
                binaryFrameCount = pictureCount;
            end
            if nargin < 8
                bitDepth = 1;
            end
            if ~isfolder(folder)
                error('ZouLab:DmdPatternFolderMissing', ...
                    'DMD pattern folder does not exist: %s', folder);
            end
            multiple = obj.DeviceInfo.required_image_multiple;
            if ~isfinite(multiple) || mod(binaryFrameCount, multiple) ~= 0
                error('ZouLab:DmdPatternCountInvalid', ...
                    ['DMD requires the binary playback frame count to be a ', ...
                     'multiple of %g.'], multiple);
            end
            if startPosition < 1
                error('ZouLab:DmdPatternStartInvalid', ...
                    'DMD start position must be at least 1.');
            end
            bmpCount = numel(dir(fullfile(folder, '*.bmp')));
            if bmpCount < pictureCount
                error('ZouLab:DmdPatternFilesMissing', ...
                    'Folder has %d BMP files but %d were requested.', ...
                    bmpCount, pictureCount);
            end
            if ~obj.SimulationMode
                result = calllib(obj.LibraryAlias, 'FD_DLP_HC_Send_PICDATA', ...
                    int32(obj.DeviceID), int32(transferType), char(folder), ...
                    int32(pictureCount), int32(startPosition), '');
                obj.assertResult(result, 'pattern transfer');
            end
            obj.Pattern = struct('name', 'folder', 'folder', char(folder), ...
                'upload_file_count', pictureCount, ...
                'binary_frame_count', binaryFrameCount, ...
                'start_binary_position', startPosition, ...
                'transfer_type', transferType, 'bit_depth', bitDepth, ...
                'raw_pixel_value', NaN, ...
                'optical_meaning_requires_polarity_calibration', true);
            obj.State = "PATTERN_LOADED";
            logger.log('SUCCESS', 'DMD_PATTERN_LOAD_COMMAND_SUCCESS', ...
                ['Folder=%s | UploadFiles=%d | BitDepth=%d | ', ...
                 'BinaryFrames=%d | StartBinaryPosition=%d | ', ...
                 'RequiredBinaryMultiple=%g | TransferType=%d | ', ...
                 'TransferCompletion=command_accepted_feedback_pending'], ...
                folder, pictureCount, bitDepth, binaryFrameCount, ...
                startPosition, multiple, transferType);
        end

        function loadCompiledPattern(obj, manifest, logger)
            zoulab.DmdPatternCompiler.validateManifest(manifest);
            obj.loadPatternFolder(string(manifest.folder), ...
                double(manifest.upload_file_count), ...
                double(manifest.start_binary_position), logger, ...
                double(manifest.transfer_type), ...
                double(manifest.binary_frame_count), ...
                double(manifest.bit_depth));
            obj.Pattern = manifest;
        end

        function armExternal(obj, loopPlayback, logger)
            obj.assertStopped();
            if isempty(fieldnames(obj.Pattern))
                error('ZouLab:DmdPatternRequired', ...
                    'Load a DMD pattern before arming external playback.');
            end
            if loopPlayback
                command = obj.CommandExternalLoop;
                mode = "EXTERNAL_LOOP";
            else
                command = obj.CommandExternalSingle;
                mode = "EXTERNAL_SINGLE";
            end
            if ~obj.SimulationMode
                result = calllib(obj.LibraryAlias, 'FD_DLP_HC_Send_CMD_Play', ...
                    int32(obj.DeviceID), int32(command), ...
                    int32(obj.patternStart()), int32(obj.patternBinaryCount()));
                obj.assertResult(result, 'external playback arm');
            end
            obj.State = "ARMED_" + mode;
            logger.log('SUCCESS', 'DMD_EXTERNAL_PLAYBACK_ARMED', ...
                ['Mode=%s | StartPosition=%d | PictureCount=%d | ', ...
                 'TriggerInput=IN1 | TriggerLevel=5V_CMOS | CommonGroundRequired=1'], ...
                mode, obj.patternStart(), obj.patternBinaryCount());
        end

        function playInternal(obj, loopPlayback, logger)
            if obj.State == "PAUSED_INTERNAL"
                obj.assertConnected();
            else
                obj.assertStopped();
            end
            if isempty(fieldnames(obj.Pattern))
                error('ZouLab:DmdPatternRequired', ...
                    'Load a DMD pattern before starting internal playback.');
            end
            if loopPlayback
                command = obj.CommandInternalLoop;
                mode = "INTERNAL_LOOP";
            else
                command = obj.CommandInternalSingle;
                mode = "INTERNAL_SINGLE";
            end
            if ~obj.SimulationMode
                result = calllib(obj.LibraryAlias, 'FD_DLP_HC_Send_CMD_Play', ...
                    int32(obj.DeviceID), int32(command), ...
                    int32(obj.patternStart()), int32(obj.patternBinaryCount()));
                obj.assertResult(result, 'internal playback');
            end
            obj.State = "PLAYING_" + mode;
            logger.log('SUCCESS', 'DMD_INTERNAL_PLAYBACK_STARTED', ...
                ['Mode=%s | StartBinaryPosition=%d | BinaryFrameCount=%d | ', ...
                 'ExternalTriggerUsed=0'], mode, obj.patternStart(), ...
                obj.patternBinaryCount());
        end

        function pausePlayback(obj, logger)
            obj.assertConnected();
            if startsWith(obj.State, 'ARMED')
                error('ZouLab:DmdPauseExternalUnsupported', ...
                    'DMD Pause is not supported during external playback.');
            end
            if ~startsWith(obj.State, 'PLAYING')
                error('ZouLab:DmdPauseStateInvalid', ...
                    'DMD Pause requires active internal playback.');
            end
            if ~obj.SimulationMode
                result = calllib(obj.LibraryAlias, ...
                    'FD_DLP_HC_Send_Fixed_Cmd_Noparam', ...
                    int32(obj.DeviceID), int32(obj.CommandPause));
                obj.assertResult(result, 'pause');
            end
            obj.State = "PAUSED_INTERNAL";
            logger.log('SUCCESS', 'DMD_INTERNAL_PLAYBACK_PAUSED', ...
                'ExternalPlayback=0 | ResumeUsesPlayCommand=1');
        end

        function setParameters1(obj, delayValue, grayBits, binaryPictureCount, ...
                pictureCountFlag, logger)
            obj.assertStopped();
            if ~obj.SimulationMode
                result = calllib(obj.LibraryAlias, ...
                    'FD_DLP_HC_Send_Cmd_SetParam1', int32(obj.DeviceID), ...
                    int32(delayValue), int32(grayBits), ...
                    int32(binaryPictureCount), int32(pictureCountFlag));
                obj.assertResult(result, 'parameter set 1');
            end
            logger.log('SUCCESS', 'DMD_PARAMETER_SET_1_CONFIRMED', ...
                'Delay=%d | GrayBits=%d | BinaryPictureCount=%d | CountFlag=%d', ...
                delayValue, grayBits, binaryPictureCount, pictureCountFlag);
        end

        function setParameters2(obj, verticalMirror, dataReverse, rowAddressing, ...
                inputFalling, outputFalling, dividedFalling, division, logger)
            obj.assertStopped();
            primary = libpointer('int8Ptr', int8([verticalMirror, ...
                dataReverse, rowAddressing]));
            triggers = libpointer('int8Ptr', int8([inputFalling, ...
                outputFalling, dividedFalling]));
            if ~obj.SimulationMode
                result = calllib(obj.LibraryAlias, ...
                    'FD_DLP_HC_Send_Cmd_SetParam2', int32(obj.DeviceID), ...
                    primary, triggers, int32(division));
                obj.assertResult(result, 'parameter set 2');
            end
            logger.log('SUCCESS', 'DMD_PARAMETER_SET_2_CONFIRMED', ...
                ['VerticalMirror=%d | DataReverse=%d | RowAddressing=%d | ', ...
                 'InputEdge=%s | OutputEdge=%s | DividedEdge=%s | Division=%d'], ...
                verticalMirror, dataReverse, rowAddressing, ...
                obj.edgeText(inputFalling), obj.edgeText(outputFalling), ...
                obj.edgeText(dividedFalling), division);
        end

        function packet = pollFeedback(obj, logger)
            packet = zeros(1, 0, 'uint8');
            if ~obj.Connected || obj.SimulationMode
                return;
            end
            response = libpointer('uint8Ptr', zeros(1, 256, 'uint8'));
            received = calllib(obj.LibraryAlias, 'FD_DLP_HC_Reveive', ...
                int32(obj.DeviceID), response);
            if received > 0
                packet = uint8(response.Value(1:min(256, received)));
                obj.LastFeedbackHex = upper(reshape(dec2hex(packet, 2).', 1, []));
                obj.LastFeedbackUTC = zoulab.BinInfo.utcNow();
                if nargin >= 2 && ~isempty(logger)
                    logger.log('INFO', 'DMD_ASYNC_FEEDBACK_RECEIVED', ...
                        'Bytes=%d | Raw=%s', numel(packet), ...
                        obj.LastFeedbackHex);
                end
            end
        end

        function stop(obj, logger)
            if ~obj.Connected
                return;
            end
            if ~obj.SimulationMode
                result = calllib(obj.LibraryAlias, ...
                    'FD_DLP_HC_Send_Fixed_Cmd_Noparam', ...
                    int32(obj.DeviceID), int32(obj.CommandStop));
                obj.assertResult(result, 'stop');
                result = calllib(obj.LibraryAlias, ...
                    'FD_DLP_HC_Send_Fixed_Cmd_Noparam', ...
                    int32(obj.DeviceID), int32(obj.CommandReset));
                obj.assertResult(result, 'DMD reset');
            end
            obj.State = "CONNECTED_STOPPED";
            logger.log('INFO', 'DMD_STOPPED_AND_RESET', ...
                'MirrorsResetToImage0=1 | FloatCommandSent=0');
        end

        function floatMirrors(obj, logger)
            obj.assertConnected();
            if ~obj.SimulationMode
                result = calllib(obj.LibraryAlias, ...
                    'FD_DLP_HC_Send_Fixed_Cmd_Noparam', ...
                    int32(obj.DeviceID), int32(obj.CommandFloat));
                obj.assertResult(result, 'float mirrors');
            end
            obj.State = "FLOAT";
            logger.log('WARNING', 'DMD_MIRRORS_FLOATED', ...
                'IntendedUse=before_hardware_power_off');
        end

        function disconnect(obj, logger, floatBeforeDisconnect)
            if nargin < 3
                floatBeforeDisconnect = false;
            end
            if obj.Connected
                try
                    obj.stop(logger);
                catch ME
                    logger.logException('DMD_STOP_ON_DISCONNECT_FAILED', ME);
                end
                if floatBeforeDisconnect
                    try
                        obj.floatMirrors(logger);
                    catch ME
                        logger.logException('DMD_FLOAT_ON_DISCONNECT_FAILED', ME);
                    end
                end
                if ~obj.SimulationMode && libisloaded(obj.LibraryAlias)
                    calllib(obj.LibraryAlias, 'FD_DLP_HC_DeInit', int32(obj.DeviceID));
                end
                logger.log('INFO', 'DMD_DISCONNECTED', ...
                    'DeviceID=%d | MirrorsFloated=%d', obj.DeviceID, ...
                    logical(floatBeforeDisconnect));
            end
            obj.Connected = false;
            obj.State = "DISCONNECTED";
        end

        function delete(obj)
            if ~obj.SimulationMode && libisloaded(obj.LibraryAlias)
                try
                    calllib(obj.LibraryAlias, 'FD_DLP_HC_DeInit', int32(obj.DeviceID));
                catch
                end
            end
            obj.Connected = false;
        end
    end

    methods (Access = private)
        function loadVendorLibrary(obj)
            if libisloaded(obj.LibraryAlias)
                return;
            end
            folder = char(obj.LibraryDirectory);
            dllPath = fullfile(folder, 'libFD_DLP_HC.dll');
            prototypePath = fullfile(folder, 'mylibrarymfile.m');
            thunkPath = fullfile(folder, 'libFD_DLP_HC_thunk_pcwin64.dll');
            if ~isfile(dllPath) || ~isfile(prototypePath) || ~isfile(thunkPath)
                error('ZouLab:DmdVendorRuntimeMissing', ...
                    'DMD vendor runtime is incomplete: %s', folder);
            end
            oldPath = path;
            cleanup = onCleanup(@() path(oldPath));
            addpath(folder);
            loadlibrary(dllPath, @mylibrarymfile, 'alias', obj.LibraryAlias);
            clear cleanup;
        end

        function info = parseDeviceBytes(~, bytes)
            bytes = uint8(bytes(:).');
            storageIsSsd = bitand(bytes(18), hex2dec('18')) == hex2dec('18');
            if storageIsSsd
                storageType = "SSD";
            else
                storageType = "DDR";
            end
            storageCount = double(bitshift(bitand(bytes(18), 7), 1) + ...
                bitshift(bytes(19), -7));
            resolutionCode = bitand(bytes(20), 15);
            [width, height, resolutionLabel] = ...
                zoulab.DmdController.resolutionFromCode(resolutionCode);
            loaded = double(bytes(21)) * 2^24 + double(bytes(22)) * 2^16 + ...
                double(bytes(23)) * 2^8 + double(bytes(24));
            requiredMultiple = NaN;
            if any(resolutionCode == [0 14])
                if storageIsSsd && storageCount == 12
                    requiredMultiple = 32;
                elseif ~storageIsSsd || storageCount == 8
                    requiredMultiple = 16;
                end
            end
            info = struct( ...
                'width', width, 'height', height, ...
                'resolution', char(resolutionLabel), ...
                'resolution_code', double(resolutionCode), ...
                'storage_type', char(storageType), ...
                'storage_count', storageCount, ...
                'loaded_image_count', loaded, ...
                'required_image_multiple', requiredMultiple, ...
                'raw_query_bytes', bytes);
        end

        function textValue = analyseDevice(obj, bytes)
            receivePointer = libpointer('uint8Ptr', uint8(bytes));
            deviceInfo = libpointer('uint8Ptr', zeros(1, 2048, 'uint8'));
            deviceLength = libpointer('int32Ptr', int32(0));
            result = calllib(obj.LibraryAlias, 'FD_DLP_HC_AnalysisDevice', ...
                int32(obj.DeviceID), receivePointer, deviceInfo, deviceLength);
            obj.assertResult(result, 'device analysis');
            lengthValue = double(deviceLength.Value);
            if lengthValue <= 0 || lengthValue > 2048
                error('ZouLab:DmdAnalysisLengthInvalid', ...
                    'DMD analysis returned invalid text length %d.', lengthValue);
            end
            textValue = string(char(deviceInfo.Value(1:lengthValue)));
        end

        function value = patternStart(obj)
            if isfield(obj.Pattern, 'start_binary_position')
                value = double(obj.Pattern.start_binary_position);
            elseif isfield(obj.Pattern, 'start_position')
                value = double(obj.Pattern.start_position);
            else
                value = 1;
            end
        end

        function value = patternBinaryCount(obj)
            if isfield(obj.Pattern, 'binary_frame_count')
                value = double(obj.Pattern.binary_frame_count);
            elseif isfield(obj.Pattern, 'count')
                value = double(obj.Pattern.count);
            else
                error('ZouLab:DmdPatternCountMissing', ...
                    'Loaded DMD pattern has no binary frame count.');
            end
        end

        function value = edgeText(~, falling)
            if logical(falling)
                value = 'falling';
            else
                value = 'rising';
            end
        end

        function info = simulatedInfo(~)
            info = struct('width', 1920, 'height', 1080, ...
                'resolution', '0.95 1080P', 'resolution_code', 0, ...
                'storage_type', 'DDR', 'storage_count', 2, ...
                'loaded_image_count', 0, 'required_image_multiple', 16, ...
                'raw_query_bytes', zeros(1, 32, 'uint8'));
        end

        function assertConnected(obj)
            if ~obj.Connected
                error('ZouLab:DmdNotConnected', 'Connect and query the DMD first.');
            end
        end

        function assertStopped(obj)
            obj.assertConnected();
            if startsWith(obj.State, 'ARMED') || ...
                    startsWith(obj.State, 'PLAYING') || ...
                    startsWith(obj.State, 'PAUSED')
                error('ZouLab:DmdMustBeStopped', ...
                    'Stop DMD playback before changing patterns or parameters.');
            end
        end

        function assertResult(~, result, action)
            if result ~= 0
                error('ZouLab:DmdVendorCommandFailed', ...
                    'DMD %s failed with vendor code %d.', action, result);
            end
        end
    end

    methods (Static, Access = private)
        function [width, height, label] = resolutionFromCode(code)
            switch double(code)
                case 0
                    width = 1920; height = 1080; label = "0.95 1080P";
                case 1
                    width = 1024; height = 768; label = "0.7 XGA";
                case 2
                    width = 1024; height = 768; label = "0.55 XGA";
                case 5
                    width = 1920; height = 1200; label = "0.96 WUXGA";
                case 7
                    width = 1280; height = 800; label = "0.65 WXGA";
                case 14
                    width = 1920; height = 1080; label = "0.65 1080P";
                case 15
                    width = 2560; height = 1600; label = "0.9 WQXGA";
                otherwise
                    width = NaN; height = NaN; label = "UNKNOWN";
            end
        end
    end
end
