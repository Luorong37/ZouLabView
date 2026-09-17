classdef SpectraXSerialController < handle
    %SPECTRAXSERIALCONTROLLER Lumencor STANDARD-mode USB serial control.

    properties
        BaudRate double = 115200
        TimeoutSeconds double = 0.5
        WarmupTimeoutSeconds double = 60
        ConfiguredPort string = ""
    end

    properties (SetAccess = private)
        Port string = ""
        Connected logical = false
        SerialObject = []
        Model string = ""
        SerialNumber string = ""
        FirmwareVersion string = ""
        ChannelNames string = strings(1, 0)
        MaxIntensity double = 1000
        Intensities double = zeros(1, 0)
        RequestedStates logical = false(1, 0)
        ActualStates logical = false(1, 0)
        TTLPins double = zeros(1, 0)
        TTLStates logical = false(1, 0)
        TTLInputsEnabled logical = false
        DeviceStatus double = NaN
        ChannelStatuses double = nan(1, 0)
        PowerLevels double = nan(1, 0)
        PowerMilliwatts double = nan(1, 0)
        PowerRegulationLocks double = nan(1, 0)
        PowerEvidenceAvailable logical = false(1, 0)
        SessionOwnedOn logical = false(1, 0)
        OriginalTTLInputsEnabled logical = false
        TTLControlChangedBySession logical = false
        TTLArmedChannels double = zeros(1, 0)
    end

    methods
        function connectConfiguredPort(obj, logger)
            if obj.Connected
                return;
            end
            configuredPort = strtrim(string(obj.ConfiguredPort));
            if strlength(configuredPort) == 0 || strcmpi(configuredPort, 'auto')
                error('ZouLab:SpectraXPortNotConfigured', ...
                    ['Spectra X requires one fixed COM port in rig_wiring.json; ', ...
                     'automatic serial-port discovery is disabled.']);
            end
            port = configuredPort;
            logger.log('INFO', 'SPECTRAX_SERIAL_CONNECT_START', ...
                'ConfiguredPort=%s | Baud=%d | AutomaticDiscovery=0', ...
                port, obj.BaudRate);
            try
                serialObject = serialport(port, obj.BaudRate, ...
                    'Timeout', obj.TimeoutSeconds);
            catch ME
                logger.log('ERROR', 'SPECTRAX_CONFIGURED_PORT_MISSING', ...
                    'ConfiguredPort=%s | CheckUSB=1 | Error=%s', ...
                    port, ME.message);
                error('ZouLab:ConfiguredSpectraXPortUnavailable', ...
                    ['No corresponding Spectra X serial port %s could be opened. ', ...
                     'Check the Spectra X USB connection, Windows COM-port ', ...
                     'assignment, and whether another program is using the port.'], ...
                    port);
            end
            try
                configureTerminator(serialObject, 'LF');
                flush(serialObject);
                writeline(serialObject, 'GET MODEL');
                deadline = tic;
                while serialObject.NumBytesAvailable == 0 && ...
                        toc(deadline) < obj.TimeoutSeconds
                    pause(0.01);
                end
                if serialObject.NumBytesAvailable > 0
                    response = strtrim(string(readline(serialObject)));
                else
                    response = "";
                end
                logger.log('INFO', 'SPECTRAX_CONFIGURED_PORT_RESPONSE', ...
                    'Port=%s | Response=%s', port, response);
                if ~(isscalar(response) && strlength(response) > 0 && ...
                        startsWith(response, "A MODEL") && ...
                        contains(response, "SPECTRAX", 'IgnoreCase', true))
                    error('ZouLab:ConfiguredPortIsNotSpectraX', ...
                        ['The configured Spectra X port %s did not return a valid ', ...
                         'Spectra X model response. Check rig_wiring.json.'], port);
                end
                obj.SerialObject = serialObject;
                obj.Port = port;
                obj.Connected = true;
                obj.Model = strtrim(extractAfter(response, "A MODEL"));
                obj.refresh(logger, true);
                logger.log('SUCCESS', 'SPECTRAX_SERIAL_CONNECT_SUCCESS', ...
                    ['Port=%s | Model=%s | Serial=%s | Firmware=%s | ', ...
                     'Channels=%s | AutomaticDiscovery=0'], ...
                    obj.Port, obj.Model, obj.SerialNumber, obj.FirmwareVersion, ...
                    strjoin(obj.ChannelNames, ','));
            catch ME
                try
                    clear serialObject;
                catch
                end
                obj.SerialObject = [];
                obj.Port = "";
                obj.Connected = false;
                logger.log('ERROR', 'SPECTRAX_CONFIGURED_PORT_CONNECT_FAILED', ...
                    'Port=%s | Error=%s', port, ME.message);
                rethrow(ME);
            end
        end

        function refresh(obj, logger, writeLog)
            if nargin < 3
                writeLog = false;
            end
            obj.assertConnected();
            obj.Model = obj.valueAfter('GET MODEL', 'A MODEL');
            obj.SerialNumber = obj.valueAfter('GET SN', 'A SN');
            obj.FirmwareVersion = obj.valueAfter('GET VER', 'A VER');
            channelMapText = obj.valueAfter('GET CHMAP', 'A CHMAP');
            obj.MaxIntensity = obj.numericScalarAfter('GET MAXINT', 'A MAXINT');
            if obj.MaxIntensity <= 0
                error('ZouLab:SpectraXInvalidScalarResponse', ...
                    'GET MAXINT returned %g; expected a positive scalar.', obj.MaxIntensity);
            end
            obj.DeviceStatus = obj.numericScalarAfter('GET STAT', 'A STAT');
            ttlEnabled = obj.numericScalarAfter('GET TTLENABLE', 'A TTLENABLE');
            if ~ismember(ttlEnabled, [0 1])
                error('ZouLab:SpectraXInvalidStateResponse', ...
                    'GET TTLENABLE returned %g; expected 0 or 1.', ttlEnabled);
            end
            obj.TTLInputsEnabled = logical(ttlEnabled);
            obj.Intensities = obj.numericVectorAfter('GET MULCHINT', 'A MULCHINT');
            requestedStates = obj.numericVectorAfter('GET MULCH', 'A MULCH');
            actualStates = obj.numericVectorAfter('GET MULCHACT', 'A MULCHACT');
            ttlStates = obj.numericVectorAfter('GET MULCHTTL', 'A MULCHTTL');
            obj.TTLPins = obj.numericVectorAfter('GET MULTTLPIN', 'A MULTTLPIN');
            coreVectors = {obj.Intensities, requestedStates, actualStates, ...
                ttlStates, obj.TTLPins};
            coreNames = ["MULCHINT" "MULCH" "MULCHACT" "MULCHTTL" ...
                "MULTTLPIN"];
            channelCount = zoulab.SpectraXSerialController. ...
                validateChannelVectors(coreVectors, coreNames);
            if any(~ismember(requestedStates, [0 1])) || ...
                    any(~ismember(actualStates, [0 1])) || ...
                    any(~ismember(ttlStates, [0 1]))
                error('ZouLab:SpectraXInvalidStateVectorResponse', ...
                    ['Spectra X channel state vectors must contain only ', ...
                     '0 or 1 values.']);
            end
            obj.RequestedStates = logical(requestedStates);
            obj.ActualStates = logical(actualStates);
            obj.TTLStates = logical(ttlStates);
            [obj.ChannelNames, usedChannelMapFallback] = ...
                zoulab.SpectraXSerialController.resolveChannelNames( ...
                channelMapText, channelCount, obj.Model);
            if usedChannelMapFallback
                logger.log('WARNING', 'SPECTRAX_CHANNEL_MAP_FALLBACK', ...
                    ['Port=%s | Model=%s | CHMAPResponse=%s | ', ...
                     'Evidence=core_vectors | ChannelCount=%d | ', ...
                     'ResolvedNames=%s | NumericChannelIDsAuthoritative=1'], ...
                    obj.Port, obj.Model, channelMapText, channelCount, ...
                    strjoin(obj.ChannelNames, ','));
            end
            obj.ChannelStatuses = obj.optionalNumericVectorAfter( ...
                'GET MULCHSTAT', 'A MULCHSTAT', channelCount, logger);
            obj.PowerLevels = obj.optionalNumericVectorAfter( ...
                'GET MULCHPWR', 'A MULCHPWR', channelCount, logger);
            obj.PowerMilliwatts = obj.optionalNumericVectorAfter( ...
                'GET MULCHPWRWATTS', 'A MULCHPWRWATTS', channelCount, logger);
            obj.PowerRegulationLocks = obj.optionalNumericVectorAfter( ...
                'GET MULPWRLOCK', 'A MULPWRLOCK', channelCount, logger);
            obj.PowerEvidenceAvailable = isfinite(obj.PowerLevels) | ...
                isfinite(obj.PowerMilliwatts);
            if numel(obj.SessionOwnedOn) ~= numel(obj.ChannelNames)
                obj.SessionOwnedOn = false(1, numel(obj.ChannelNames));
            end
            if writeLog
                logger.log('INFO', 'SPECTRAX_STATUS_REFRESHED', ...
                    ['Port=%s | DeviceStatus=%g | TTLInputsEnabled=%d | TTLStates=%s | ', ...
                     'Intensities=%s | RequestedStates=%s | ActualStates=%s | ', ...
                     'TTLPins=%s | ChannelStatuses=%s | PowerLevels=%s | ', ...
                     'PowerMilliwatts=%s | PowerRegulationLocks=%s'], ...
                    obj.Port, obj.DeviceStatus, obj.TTLInputsEnabled, ...
                    mat2str(obj.TTLStates), ...
                    mat2str(obj.Intensities), mat2str(obj.RequestedStates), ...
                    mat2str(obj.ActualStates), ...
                    mat2str(obj.TTLPins), mat2str(obj.ChannelStatuses), ...
                    mat2str(obj.PowerLevels), mat2str(obj.PowerMilliwatts), ...
                    mat2str(obj.PowerRegulationLocks));
            end
        end

        function actualPercent = setIntensityPercent(obj, channelIndex, percent, logger)
            obj.validateChannel(channelIndex);
            validateattributes(percent, {'numeric'}, {'scalar','finite','>=',0,'<=',100});
            rawValue = round(percent * obj.MaxIntensity / 100);
            obj.command(sprintf('SET CHINT %d %d', channelIndex - 1, rawValue), 'A CHINT');
            actualRaw = obj.numericScalarAfter( ...
                sprintf('GET CHINT %d', channelIndex - 1), 'A CHINT');
            if actualRaw < 0 || actualRaw > obj.MaxIntensity
                error('ZouLab:SpectraXInvalidIntensityResponse', ...
                    'Channel %d returned raw intensity %g outside [0,%g].', ...
                    channelIndex - 1, actualRaw, obj.MaxIntensity);
            end
            obj.Intensities(channelIndex) = actualRaw;
            actualPercent = actualRaw * 100 / obj.MaxIntensity;
            logger.log('SUCCESS', 'SPECTRAX_INTENSITY_SET', ...
                'ChannelID=%d | Channel=%s | RequestedPercent=%.3f | Raw=%d | ActualPercent=%.3f', ...
                channelIndex - 1, obj.ChannelNames(channelIndex), percent, rawValue, actualPercent);
        end

        function actualOn = setChannelState(obj, channelIndex, turnOn, logger)
            obj.validateChannel(channelIndex);
            if turnOn
                error('ZouLab:SpectraXSerialOnDisabled', ...
                    ['Spectra X serial ON/OFF control is disabled in this APP. ', ...
                     'USB serial configures intensity only; use the mapped ', ...
                     'DAQ TTL output to switch the source.']);
            end
            obj.command(sprintf('SET CH %d 0', channelIndex - 1), 'A CH');
            requested = obj.numericScalarAfter( ...
                sprintf('GET CH %d', channelIndex - 1), 'A CH');
            if requested ~= 0
                error('ZouLab:SpectraXSerialOffFailed', ...
                    'Channel %d serial switch remained %g instead of 0.', ...
                    channelIndex - 1, requested);
            end
            obj.RequestedStates(channelIndex) = false;
            obj.ActualStates(channelIndex) = false;
            obj.SessionOwnedOn(channelIndex) = false;
            actualOn = false;
            logger.log('SUCCESS', 'SPECTRAX_SERIAL_SWITCH_FORCED_OFF', ...
                ['ChannelID=%d | Channel=%s | SerialSwitch=0 | ', ...
                 'USBRole=intensity_only | SwitchOwner=DAQ_TTL'], ...
                channelIndex - 1, obj.ChannelNames(channelIndex));
        end

        function turnOffOwned(obj, logger)
            if ~obj.Connected || isempty(obj.SessionOwnedOn)
                return;
            end
            owned = find(obj.SessionOwnedOn);
            for channelIndex = owned
                try
                    obj.setChannelState(channelIndex, false, logger);
                catch ME
                    logger.logException('SPECTRAX_OWNED_CHANNEL_OFF_FAILED', ME);
                end
            end
            logger.log('INFO', 'SPECTRAX_OWNED_CHANNELS_OFF', ...
                'ChannelIndices=%s', mat2str(owned - 1));
        end

        function allOff(obj, logger, source)
            obj.assertConnected();
            zerosText = strjoin(repmat("0", 1, numel(obj.ChannelNames)), ' ');
            obj.command("SET MULCH " + zerosText, 'A MULCH');
            obj.RequestedStates(:) = false;
            obj.ActualStates(:) = false;
            obj.SessionOwnedOn(:) = false;
            obj.TTLArmedChannels = zeros(1, 0);
            logger.log('SUCCESS', 'SPECTRAX_ALL_OFF', 'Source=%s | Channels=%d', ...
                source, numel(obj.ChannelNames));
        end

        function armTTLInputs(obj, logger)
            obj.assertConnected();
            if ~obj.TTLControlChangedBySession
                obj.OriginalTTLInputsEnabled = obj.TTLInputsEnabled;
            end
            if ~obj.TTLInputsEnabled
                obj.command('SET TTLENABLE 1', 'A TTLENABLE');
                obj.TTLInputsEnabled = true;
                obj.TTLControlChangedBySession = true;
            end
            logger.log('SUCCESS', 'SPECTRAX_TTL_MASTER_ARMED', ...
                ['TTLInputsEnabled=%d | OriginalTTLInputsEnabled=%d | ', ...
                 'SessionSwitchingPolicy=DAQ_TTL_ONLY'], obj.TTLInputsEnabled, ...
                obj.OriginalTTLInputsEnabled);
        end

        function result = armTTLChannels(obj, channelIndices, logger)
            obj.assertConnected();
            channelIndices = unique(double(channelIndices(:).'), 'stable');
            for channelIndex = channelIndices
                obj.validateChannel(channelIndex);
            end
            obj.armTTLInputs(logger);
            serialSwitches = false(1, numel(channelIndices));
            actual = false(1, numel(channelIndices));
            try
                for position = 1:numel(channelIndices)
                    channelIndex = channelIndices(position);
                    % Lumencor requires serial ON/OFF controls to remain OFF
                    % while external TTL inputs switch the source.  USB is
                    % therefore intensity-only throughout the APP session.
                    obj.command(sprintf('SET CH %d 0', ...
                        channelIndex - 1), 'A CH');
                    requestedValue = obj.numericScalarAfter(sprintf( ...
                        'GET CH %d', channelIndex - 1), 'A CH');
                    actualValue = obj.numericScalarAfter(sprintf( ...
                        'GET CHACT %d', channelIndex - 1), 'A CHACT');
                    if requestedValue ~= 0 || ...
                            ~ismember(actualValue, [0 1])
                        error('ZouLab:SpectraXInvalidStateResponse', ...
                            ['TTL preparation did not clear the serial switch: ', ...
                             'requested=%g actual=%g for channel %d.'], ...
                            requestedValue, actualValue, ...
                            channelIndex - 1);
                    end
                    serialSwitches(position) = logical(requestedValue);
                    actual(position) = logical(actualValue);
                    obj.RequestedStates(channelIndex) = false;
                    obj.ActualStates(channelIndex) = logical(actualValue);
                    logger.log('SUCCESS', ...
                        'SPECTRAX_TTL_CHANNEL_PREPARED', ...
                        ['ChannelID=%d | Channel=%s | SerialSwitch=%d | ', ...
                         'ReportedActualState=%d | TTLMaster=%d | ', ...
                         'SwitchOwner=DAQ_TTL'], ...
                        channelIndex - 1, obj.ChannelNames(channelIndex), ...
                        requestedValue, actualValue, obj.TTLInputsEnabled);
                end
            catch ME
                for channelIndex = channelIndices
                    obj.safeChannelOff(channelIndex, logger, ...
                        'ttl_arm_transaction_failed');
                end
                obj.restoreTTLMaster(logger, 'ttl_arm_transaction_failed');
                rethrow(ME);
            end
            obj.TTLArmedChannels = unique( ...
                [obj.TTLArmedChannels channelIndices], 'stable');
            result = struct('channels', channelIndices, ...
                'serial_switch_states', serialSwitches, ...
                'reported_actual_states', actual, ...
                'ttl_master_enabled', obj.TTLInputsEnabled);
            logger.log('SUCCESS', 'SPECTRAX_TTL_CHANNEL_SET_PREPARED', ...
                ['Channels=%s | SerialSwitches=%s | ', ...
                 'ReportedActualStates=%s | TTLMaster=%d | ', ...
                 'USBRole=intensity_only | SwitchOwner=DAQ_TTL'], ...
                mat2str(channelIndices - 1), mat2str(serialSwitches), ...
                mat2str(actual), obj.TTLInputsEnabled);
        end

        function disarmTTLChannels(obj, logger, reason)
            obj.assertConnected();
            channels = obj.TTLArmedChannels;
            for channelIndex = channels
                try
                    obj.command(sprintf('SET CH %d 0', ...
                        channelIndex - 1), 'A CH');
                    obj.RequestedStates(channelIndex) = false;
                    obj.ActualStates(channelIndex) = false;
                    obj.SessionOwnedOn(channelIndex) = false;
                catch ME
                    logger.logException( ...
                        'SPECTRAX_TTL_CHANNEL_DISARM_FAILED', ME);
                end
            end
            obj.TTLArmedChannels = zeros(1, 0);
            logger.log('INFO', 'SPECTRAX_TTL_CHANNEL_SET_DISARMED', ...
                ['Channels=%s | ChannelSwitchesForcedOff=1 | ', ...
                 'TTLMasterKeptEnabledForSession=%d | Reason=%s'], ...
                mat2str(channels - 1), obj.TTLInputsEnabled, reason);
        end

        function restoreTTLInputs(obj, logger, reason)
            obj.assertConnected();
            obj.restoreTTLMaster(logger, reason);
        end

        function disconnect(obj, logger)
            if ~obj.Connected
                return;
            end
            obj.turnOffOwned(logger);
            if obj.TTLControlChangedBySession
                obj.restoreTTLMaster(logger, 'disconnect');
            end
            port = obj.Port;
            obj.SerialObject = [];
            obj.Connected = false;
            obj.Port = "";
            logger.log('INFO', 'SPECTRAX_SERIAL_DISCONNECTED', ...
                'Port=%s | OnlySessionOwnedChannelsWereTurnedOff=1', port);
        end

        function delete(obj)
            obj.SerialObject = [];
            obj.Connected = false;
        end
    end

    methods (Static)
        function [names, usedFallback] = resolveChannelNames( ...
                channelMapText, channelCount, model)
            validateattributes(channelCount, {'numeric'}, ...
                {'scalar','integer','positive','finite'});
            textValue = strtrim(char(string(channelMapText)));
            if isempty(textValue)
                names = strings(1, 0);
            else
                names = string(regexp(textValue, '[,;|\s]+', 'split'));
                names(names == "") = [];
            end
            if ~isempty(names) && numel(names) ~= channelCount
                error('ZouLab:SpectraXChannelMapCountMismatch', ...
                    ['GET CHMAP described %d channels but the core status ', ...
                     'vectors contain %d channels. CHMAP="%s"'], ...
                    numel(names), channelCount, textValue);
            end
            usedFallback = isempty(names);
            if ~usedFallback
                return;
            end
            if channelCount == 6 && contains(string(model), ...
                    'SpectraX', 'IgnoreCase', true)
                % This numeric order is the rig's existing authoritative
                % Spectra X table and matches channel IDs 0..5.
                names = ["UV" "BLUE" "CYAN" "GREEN" "RED" "NIR"];
            else
                names = "Channel" + string(0:channelCount - 1);
            end
        end

        function channelCount = validateChannelVectors(vectors, names)
            if numel(vectors) ~= numel(names) || isempty(vectors)
                error('ZouLab:SpectraXChannelVectorDefinitionInvalid', ...
                    'Core vector values and names must be nonempty and aligned.');
            end
            counts = cellfun(@numel, vectors);
            if any(counts < 1) || numel(unique(counts)) ~= 1
                details = strings(1, numel(names));
                for index = 1:numel(names)
                    details(index) = names(index) + "=" + counts(index);
                end
                error('ZouLab:SpectraXChannelVectorCountMismatch', ...
                    ['Core Spectra X channel vectors are inconsistent: %s. ', ...
                     'No light command was issued.'], strjoin(details, ','));
            end
            for index = 1:numel(vectors)
                if any(~isfinite(double(vectors{index})))
                    error('ZouLab:SpectraXChannelVectorNonfinite', ...
                        'Core Spectra X vector %s contains nonfinite values.', ...
                        names(index));
                end
            end
            channelCount = counts(1);
        end
    end

    methods (Access = private)
        function safeChannelOff(obj, channelIndex, logger, reason)
            try
                obj.command(sprintf('SET CH %d 0', channelIndex - 1), 'A CH');
                obj.RequestedStates(channelIndex) = false;
                obj.ActualStates(channelIndex) = false;
                obj.SessionOwnedOn(channelIndex) = false;
                logger.log('INFO', 'SPECTRAX_CHANNEL_SAFE_OFF', ...
                    'ChannelID=%d | Reason=%s', channelIndex - 1, reason);
            catch ME
                logger.logException('SPECTRAX_CHANNEL_SAFE_OFF_FAILED', ME);
            end
        end

        function restoreTTLMaster(obj, logger, reason)
            if ~obj.TTLControlChangedBySession
                return;
            end
            obj.command(sprintf('SET TTLENABLE %d', ...
                obj.OriginalTTLInputsEnabled), 'A TTLENABLE');
            obj.TTLInputsEnabled = obj.OriginalTTLInputsEnabled;
            obj.TTLControlChangedBySession = false;
            logger.log('SUCCESS', 'SPECTRAX_TTL_MASTER_RESTORED', ...
                'RestoredTTLInputsEnabled=%d | Reason=%s', ...
                obj.OriginalTTLInputsEnabled, reason);
        end

        function response = command(obj, commandText, expectedPrefix)
            obj.assertConnected();
            flush(obj.SerialObject);
            writeline(obj.SerialObject, commandText);
            response = strtrim(string(readline(obj.SerialObject)));
            if ~startsWith(response, string(expectedPrefix))
                error('ZouLab:SpectraXCommandFailed', ...
                    'Command "%s" returned "%s".', commandText, response);
            end
        end

        function value = valueAfter(obj, commandText, prefix)
            response = obj.command(commandText, prefix);
            value = strtrim(extractAfter(response, string(prefix)));
        end

        function values = numericVectorAfter(obj, commandText, prefix)
            textValue = obj.valueAfter(commandText, prefix);
            values = sscanf(char(textValue), '%f').';
        end

        function value = numericScalarAfter(obj, commandText, prefix)
            textValue = obj.valueAfter(commandText, prefix);
            values = sscanf(char(textValue), '%f');
            if ~isscalar(values) || ~isfinite(values)
                error('ZouLab:SpectraXInvalidScalarResponse', ...
                    'Command "%s" returned non-scalar numeric data "%s".', ...
                    commandText, textValue);
            end
            value = double(values);
        end

        function values = optionalNumericVectorAfter(obj, commandText, prefix, ...
                expectedLength, logger)
            try
                values = obj.numericVectorAfter(commandText, prefix);
                if numel(values) ~= expectedLength || any(~isfinite(values))
                    error('ZouLab:SpectraXInvalidOptionalVectorResponse', ...
                        'Command "%s" returned %d values; expected %d finite values.', ...
                        commandText, numel(values), expectedLength);
                end
            catch ME
                values = nan(1, expectedLength);
                logger.log('WARNING', 'SPECTRAX_OPTIONAL_DIAGNOSTIC_UNAVAILABLE', ...
                    'Command=%s | ErrorID=%s | Error=%s', ...
                    commandText, ME.identifier, ME.message);
            end
        end

        function [value, available] = optionalNumericScalarAfter(obj, ...
                commandText, prefix, logger)
            try
                value = obj.numericScalarAfter(commandText, prefix);
                available = true;
            catch ME
                value = NaN;
                available = false;
                logger.log('WARNING', 'SPECTRAX_OPTIONAL_DIAGNOSTIC_UNAVAILABLE', ...
                    'Command=%s | ErrorID=%s | Error=%s', ...
                    commandText, ME.identifier, ME.message);
            end
        end

        function assertConnected(obj)
            if ~obj.Connected || isempty(obj.SerialObject)
                error('ZouLab:SpectraXNotConnected', 'Connect the Spectra X USB serial interface first.');
            end
        end

        function validateChannel(obj, channelIndex)
            obj.assertConnected();
            validateattributes(channelIndex, {'numeric'}, ...
                {'scalar','integer','>=',1,'<=',numel(obj.ChannelNames)});
        end
    end

    methods (Static, Access = private)
        function value = stateText(flag)
            if flag
                value = 'ON';
            else
                value = 'OFF';
            end
        end
    end
end
