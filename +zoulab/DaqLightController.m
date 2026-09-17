classdef DaqLightController < handle
    %DAQLIGHTCONTROLLER NI-DAQ camera trigger and light TTL controller.
    %
    % The line polarity defaults to the value used by the rebuilt lab
    % script: 1 = asserted/on, 0 = safe/off.  This may differ from the
    % SPECTRA X bare DB-15 default because the installed interface can invert
    % the signal.  The selected polarity is always included in the log.

    properties
        DeviceID string = ""
        LightActiveValue double = 1
        InputSampleRateHz double = 2000
        DummyInput string = ""
        PulseWidthSeconds double = 0.001
        DmdTriggerPort string = ""
        CameraPorts string = ["", ""]
        CameraTimingPorts string = ["", ""]
        VisualStampPort string = ""
        VisualStampInput string = ""
        LedFlickerEnablePort string = ""
        LedFlickerFrequencyPort string = ""
        LedFlickerMinimumVolts double = 0
        LedFlickerMaximumVolts double = 5
        LedFlickerSafeVolts double = 0
        LedFlickerHzPerVolt double = 1
        LightNames string = ["Laser405", "Laser445", "LEDcyan", "LEDgreen", "LEDred"]
        LightPorts string = ["", "", "", "", ""]
        AnalogLightNames string = ["Laser405", "Laser445"]
        AnalogLightPorts string = ["", ""]
        AnalogMinimumVolts double = [0 0]
        AnalogMaximumVolts double = [5 5]
        AnalogSafeVolts double = [0 0]
    end

    properties (SetAccess = private)
        Connected logical = false
        LastError string = ""
        Output = []
        ChannelTags string = strings(1, 0)
        OutputState double = zeros(1, 0)
        VisualInput = []
        VisualInputTags string = strings(1, 0)
        VisualSyncRunning logical = false
        FinitePlanRunning logical = false
        LastFinitePlan struct = struct()
    end

    properties (Constant)
        CameraNames = ["Camera 1 - USB", "Camera 2 - CXP"]
        % Optional reachability indicator only; USB serial is the control path.
        SpectraAddress = ""
    end

    methods
        function applyWiringConfig(obj, config, logger)
            if obj.Connected
                error('ZouLab:DaqConnectedConfigLocked', ...
                    'Disconnect DAQ before applying a changed wiring configuration.');
            end
            obj.DeviceID = string(config.daq.device_id);
            obj.LightActiveValue = double(config.daq.light_active_value);
            obj.InputSampleRateHz = double(config.daq.input_sample_rate_hz);
            obj.DummyInput = string(config.daq.dummy_input);
            obj.PulseWidthSeconds = double(config.daq.camera_start_pulse_seconds);
            outputs = config.digital_outputs;
            obj.CameraPorts = [obj.portFor(outputs, "camera1"), ...
                obj.portFor(outputs, "camera2")];
            obj.VisualStampPort = obj.portFor(outputs, "visual_stamp");
            obj.DmdTriggerPort = obj.portFor(outputs, "dmd_trigger");
            obj.LedFlickerEnablePort = obj.portFor( ...
                outputs, "led_flicker_enable");
            obj.LightNames = ["Laser405", "Laser445", "LEDcyan", "LEDgreen", "LEDred"];
            obj.LightPorts = [obj.portFor(outputs, "light_Laser405"), ...
                obj.portFor(outputs, "light_Laser445"), ...
                obj.portFor(outputs, "light_LEDcyan"), ...
                obj.portFor(outputs, "light_LEDgreen"), ...
                obj.portFor(outputs, "light_LEDred")];
            analogOutputs = config.analog_outputs;
            analogEntries = [obj.entryFor(analogOutputs, "light_stim_AO_Laser405"), ...
                obj.entryFor(analogOutputs, "light_stim_AO_Laser445")];
            obj.AnalogLightPorts = string({analogEntries.port});
            obj.AnalogMinimumVolts = double([analogEntries.minimum_voltage]);
            obj.AnalogMaximumVolts = double([analogEntries.maximum_voltage]);
            obj.AnalogSafeVolts = double([analogEntries.safe_voltage]);
            ledEntry = obj.entryFor(analogOutputs, "led_flicker_frequency");
            obj.LedFlickerFrequencyPort = string(ledEntry.port);
            obj.LedFlickerMinimumVolts = double(ledEntry.minimum_voltage);
            obj.LedFlickerMaximumVolts = double(ledEntry.maximum_voltage);
            obj.LedFlickerSafeVolts = double(ledEntry.safe_voltage);
            obj.LedFlickerHzPerVolt = double(ledEntry.frequency_hz_per_volt);
            counters = config.counter_inputs;
            obj.CameraTimingPorts = [string(counters.camera1_vsync), ...
                string(counters.camera2_vsync)];
            obj.VisualStampInput = string(counters.visual_stamp);
            logger.log('INFO', 'DAQ_WIRING_CONFIG_APPLIED', ...
                ['Device=%s | InputRateHz=%.6g | DummyInput=%s | CameraStart=%s | CameraVsync=%s | ', ...
                 'VisualStamp=%s->%s | DMD=%s | LedFlicker=%s,%s@%.6gHzPerV | Lights=%s | Analog=%s | ', ...
                 'AnalogRangeVolts=%s..%s | ActiveValue=%g'], ...
                obj.DeviceID, obj.InputSampleRateHz, obj.DummyInput, ...
                strjoin(obj.CameraPorts, ','), ...
                strjoin(obj.CameraTimingPorts, ','), obj.VisualStampPort, ...
                obj.VisualStampInput, obj.DmdTriggerPort, ...
                obj.LedFlickerEnablePort, obj.LedFlickerFrequencyPort, ...
                obj.LedFlickerHzPerVolt, ...
                strjoin(obj.LightPorts, ','), strjoin(obj.AnalogLightPorts, ','), ...
                mat2str(obj.AnalogMinimumVolts), mat2str(obj.AnalogMaximumVolts), ...
                obj.LightActiveValue);
        end

        function connect(obj, logger)
            if obj.Connected
                return;
            end
            try
                available = daqlist("ni");
                if isempty(available)
                    error('ZouLab:DaqNotFound', 'No NI-DAQ device was detected.');
                end
                ids = string(available.DeviceID);
                if ~any(ids == obj.DeviceID)
                    error('ZouLab:DaqDeviceNotFound', ...
                        'DAQ %s was not found. Detected: %s', obj.DeviceID, strjoin(ids, ', '));
                end

                obj.Output = daq("ni");
                obj.ChannelTags = strings(1, 0);
                for k = 1:numel(obj.CameraPorts)
                    addoutput(obj.Output, obj.DeviceID, obj.CameraPorts(k), "Digital");
                    obj.ChannelTags(end + 1) = "camera" + k;
                end
                addoutput(obj.Output, obj.DeviceID, obj.VisualStampPort, "Digital");
                obj.ChannelTags(end + 1) = "visual_stamp";
                addoutput(obj.Output, obj.DeviceID, ...
                    obj.LedFlickerEnablePort, "Digital");
                obj.ChannelTags(end + 1) = "led_flicker_enable";
                for k = 1:numel(obj.LightPorts)
                    addoutput(obj.Output, obj.DeviceID, obj.LightPorts(k), "Digital");
                    obj.ChannelTags(end + 1) = "light_" + obj.LightNames(k);
                end
                for k = 1:numel(obj.AnalogLightPorts)
                    addoutput(obj.Output, obj.DeviceID, obj.AnalogLightPorts(k), "Voltage");
                    obj.ChannelTags(end + 1) = "light_stim_AO_" + ...
                        obj.AnalogLightNames(k);
                end
                addoutput(obj.Output, obj.DeviceID, ...
                    obj.LedFlickerFrequencyPort, "Voltage");
                obj.ChannelTags(end + 1) = "led_flicker_frequency";
                if strlength(obj.DmdTriggerPort) > 0
                    addoutput(obj.Output, obj.DeviceID, obj.DmdTriggerPort, "Digital");
                    obj.ChannelTags(end + 1) = "dmd_trigger";
                end
                obj.OutputState = obj.offVector();
                write(obj.Output, obj.OutputState);
                obj.Connected = true;
                obj.LastError = "";
                logger.log('SUCCESS', 'DAQ_CONNECT_SUCCESS', ...
                    ['Device=%s | CameraPorts=%s | LightPorts=%s | ', ...
                     'AnalogPorts=%s | AnalogSafeVolts=%s | ', ...
                     'DmdTriggerPort=%s | ActiveValue=%g'], ...
                    obj.DeviceID, strjoin(obj.CameraPorts, ','), ...
                    strjoin(obj.LightPorts, ','), strjoin(obj.AnalogLightPorts, ','), ...
                    mat2str(obj.AnalogSafeVolts), ...
                    obj.configuredText(obj.DmdTriggerPort), ...
                    obj.LightActiveValue);
            catch ME
                obj.Connected = false;
                obj.LastError = string(ME.message);
                obj.Output = [];
                logger.logException('DAQ_CONNECT_FAILED', ME);
                rethrow(ME);
            end
        end

        function assertReady(obj)
            if ~obj.Connected || isempty(obj.Output)
                error('ZouLab:DaqRequired', ...
                    ['NI-DAQ is required for synchronized dual-camera Snap/Time Lapse. ', ...
                     'Connect Dev1 before acquisition; sequential fallback is disabled.']);
            end
        end

        function pulseCameras(obj, cameraIndices, logger)
            obj.assertReady();
            cameraIndices = unique(double(cameraIndices(:).'));
            values = obj.OutputState;
            for cameraIndex = cameraIndices
                values(obj.ChannelTags == "camera" + cameraIndex) = 1;
            end
            write(obj.Output, values);
            pause(obj.PulseWidthSeconds);
            write(obj.Output, obj.OutputState);
            logger.log('INFO', 'DAQ_CAMERA_TRIGGER_PULSE', ...
                'Cameras=%s | Width=%.6f s', mat2str(cameraIndices), obj.PulseWidthSeconds);
        end

        function beginVisualSync(obj, cameraIndices, logger)
            obj.assertReady();
            cameraIndices = unique(double(cameraIndices(:).'));
            obj.abortVisualSync();
            try
                inputSession = daq("ni");
                inputSession.Rate = obj.InputSampleRateHz;
                addinput(inputSession, obj.DeviceID, obj.DummyInput, "Voltage");
                tags = "dummy_clock";
                for cameraIndex = cameraIndices
                    addinput(inputSession, obj.DeviceID, ...
                        obj.CameraTimingPorts(cameraIndex), "EdgeCount");
                    tags(end + 1) = "camera" + cameraIndex; %#ok<AGROW>
                end
                addinput(inputSession, obj.DeviceID, obj.VisualStampInput, "Position");
                tags(end + 1) = "visual_stamp";
                resetcounters(inputSession);
                flush(inputSession);
                obj.VisualInput = inputSession;
                obj.VisualInputTags = tags;
                obj.setVisualStamp(false);
                start(obj.VisualInput, "continuous");
                obj.VisualSyncRunning = true;
                logger.log('SUCCESS', 'DAQ_VISUAL_SYNC_STARTED', ...
                    ['Device=%s | Rate=%.6g | DummyInput=%s | Cameras=%s | CameraTimingPorts=%s | ', ...
                     'StampInput=%s | StampOutput=%s'], ...
                    obj.DeviceID, obj.VisualInput.Rate, obj.DummyInput, ...
                    mat2str(cameraIndices), ...
                    strjoin(obj.CameraTimingPorts(cameraIndices), ','), ...
                    obj.VisualStampInput, obj.VisualStampPort);
            catch ME
                obj.abortVisualSync();
                logger.logException('DAQ_VISUAL_SYNC_START_FAILED', ME);
                rethrow(ME);
            end
        end

        function stampVisualFrame(obj)
            if ~obj.VisualSyncRunning
                return;
            end
            values = obj.OutputState;
            stampIndex = obj.ChannelTags == "visual_stamp";
            values(stampIndex) = 1;
            write(obj.Output, values);
            write(obj.Output, values);
            write(obj.Output, values);
            values(stampIndex) = 0;
            write(obj.Output, values);
        end

        function [rawData, syncTable] = finishVisualSync(obj, cameraIndices, vbl, logger)
            rawData = table();
            syncTable = table();
            cameraIndices = unique(double(cameraIndices(:).'));
            if isempty(obj.VisualInput)
                logger.log('WARNING', 'DAQ_VISUAL_SYNC_EMPTY', ...
                    'No visual synchronization input session was active.');
                return;
            end
            totalClock = tic;
            try
                stopElapsed = 0;
                if obj.VisualSyncRunning
                    logger.log('INFO', 'DAQ_VISUAL_SYNC_STOP_BEGIN', ...
                        'Cameras=%s | Running=1', mat2str(cameraIndices));
                    stageClock = tic;
                    stop(obj.VisualInput);
                    stopElapsed = toc(stageClock);
                    logger.log('INFO', 'DAQ_VISUAL_SYNC_STOP_COMPLETE', ...
                        'Cameras=%s | ElapsedSeconds=%.6f', ...
                        mat2str(cameraIndices), stopElapsed);
                else
                    logger.log('INFO', 'DAQ_VISUAL_SYNC_STOP_SKIPPED', ...
                        'Cameras=%s | Running=0 | ElapsedSeconds=0', ...
                        mat2str(cameraIndices));
                end
                obj.VisualSyncRunning = false;
                logger.log('INFO', 'DAQ_VISUAL_SYNC_READ_BEGIN', ...
                    'Cameras=%s | ReadMode=all', mat2str(cameraIndices));
                stageClock = tic;
                rawData = read(obj.VisualInput, "all");
                readElapsed = toc(stageClock);
                logger.log('INFO', 'DAQ_VISUAL_SYNC_READ_COMPLETE', ...
                    ['Cameras=%s | Samples=%d | Variables=%d | ', ...
                     'ElapsedSeconds=%.6f'], mat2str(cameraIndices), ...
                    height(rawData), width(rawData), readElapsed);
                logger.log('INFO', 'DAQ_VISUAL_SYNC_ALIGNMENT_BEGIN', ...
                    'Cameras=%s | VisualFlips=%d | Samples=%d', ...
                    mat2str(cameraIndices), numel(vbl), height(rawData));
                stageClock = tic;
                syncTable = obj.buildVisualSyncTable(rawData, cameraIndices, vbl);
                alignmentElapsed = toc(stageClock);
                logger.log('INFO', 'DAQ_VISUAL_SYNC_ALIGNMENT_COMPLETE', ...
                    ['Cameras=%s | VisualFlips=%d | MatchedFlips=%d | ', ...
                     'ElapsedSeconds=%.6f'], mat2str(cameraIndices), ...
                    numel(vbl), height(syncTable), alignmentElapsed);
                logger.log('SUCCESS', 'DAQ_VISUAL_SYNC_COMPLETE', ...
                    ['Samples=%d | VisualFlips=%d | MatchedFlips=%d | ', ...
                     'Cameras=%s | InputTags=%s | StopSeconds=%.6f | ', ...
                     'ReadSeconds=%.6f | AlignmentSeconds=%.6f | ', ...
                     'TotalSeconds=%.6f'], ...
                    height(rawData), numel(vbl), height(syncTable), ...
                    mat2str(cameraIndices), strjoin(obj.VisualInputTags, ','), ...
                    stopElapsed, readElapsed, alignmentElapsed, toc(totalClock));
            catch ME
                logger.log('ERROR', 'DAQ_VISUAL_SYNC_FINISH_FAILED', ...
                    ['Identifier=%s | Message=%s | Cameras=%s | ', ...
                     'ElapsedSeconds=%.6f'], ME.identifier, ME.message, ...
                    mat2str(cameraIndices), toc(totalClock));
                logger.logException('DAQ_VISUAL_SYNC_FINISH_EXCEPTION', ME);
                rethrow(ME);
            end
        end

        function [rawData, syncTable] = finishFiniteEventSync( ...
                obj, cameraIndices, plannedEventSeconds, logger)
            rawData = table();
            syncTable = table();
            cameraIndices = unique(double(cameraIndices(:).'));
            if isempty(obj.VisualInput)
                logger.log('WARNING', 'DAQ_FINITE_EVENT_SYNC_EMPTY', ...
                    'No counter input session was active; acquisition continues.');
                return;
            end
            try
                if obj.VisualSyncRunning
                    stop(obj.VisualInput);
                end
                obj.VisualSyncRunning = false;
                rawData = read(obj.VisualInput, "all");
                syncTable = obj.buildFiniteEventSyncTable( ...
                    rawData, cameraIndices, plannedEventSeconds);
                matched = height(syncTable);
                planned = numel(plannedEventSeconds);
                if matched ~= planned
                    level = 'WARNING';
                    eventName = 'DAQ_FINITE_EVENT_COUNT_MISMATCH';
                else
                    level = 'SUCCESS';
                    eventName = 'DAQ_FINITE_EVENT_SYNC_COMPLETE';
                end
                logger.log(level, eventName, ...
                    ['Samples=%d | PlannedEvents=%d | MatchedEvents=%d | ', ...
                     'Cameras=%s | AcquisitionStoppedOnMismatch=0'], ...
                    height(rawData), planned, matched, ...
                    mat2str(cameraIndices));
            catch ME
                logger.logException( ...
                    'DAQ_FINITE_EVENT_SYNC_FINISH_FAILED', ME);
                rethrow(ME);
            end
        end

        function abortVisualSync(obj)
            if ~isempty(obj.VisualInput)
                try
                    if obj.VisualSyncRunning
                        stop(obj.VisualInput);
                    end
                catch
                end
                try
                    flush(obj.VisualInput);
                catch
                end
            end
            obj.VisualInput = [];
            obj.VisualInputTags = strings(1, 0);
            obj.VisualSyncRunning = false;
            try
                obj.setVisualStamp(false);
            catch
            end
        end

        function setLights(obj, lightNames, turnOn, logger)
            obj.assertReady();
            lightNames = string(lightNames);
            values = obj.OutputState;
            for k = 1:numel(lightNames)
                idx = find(obj.LightNames == lightNames(k), 1);
                if isempty(idx)
                    error('ZouLab:UnknownLight', 'Unknown light: %s', lightNames(k));
                end
                if turnOn
                    values(obj.ChannelTags == "light_" + obj.LightNames(idx)) = obj.LightActiveValue;
                else
                    values(obj.ChannelTags == "light_" + obj.LightNames(idx)) = 1 - obj.LightActiveValue;
                end
            end
            write(obj.Output, values);
            obj.OutputState = values;
            if turnOn
                state = 'ON';
            else
                state = 'OFF';
            end
            logger.log('INFO', 'LIGHT_STATE_CHANGED', ...
                ['Lights=%s | State=%s | ActiveValue=%g | ', ...
                 'CameraStartValues=%s | CameraStartCommandIssued=0'], ...
                strjoin(lightNames, ','), state, obj.LightActiveValue, ...
                 mat2str(values(ismember(obj.ChannelTags, ["camera1","camera2"]))));
        end

        function [state, known] = commandedLightState(obj, lightName)
            % Return the logical state commanded on the DAQ TTL line.  This
            % is command-state evidence, not an optical power measurement.
            lightName = string(lightName);
            tag = "light_" + lightName;
            state = false;
            known = obj.Connected && numel(obj.OutputState) == ...
                numel(obj.ChannelTags) && any(obj.ChannelTags == tag);
            if ~known
                return;
            end
            state = obj.OutputState(obj.ChannelTags == tag) == ...
                obj.LightActiveValue;
        end

        function actualVolts = setLaserAnalogVoltage(obj, lightName, requestedVolts, logger)
            obj.assertReady();
            if obj.FinitePlanRunning
                error('ZouLab:DaqAnalogOutputLocked', ...
                    'Analog intensity cannot be changed while a finite DAQ plan is running.');
            end
            lightName = string(lightName);
            index = find(obj.AnalogLightNames == lightName, 1);
            if isempty(index)
                error('ZouLab:UnknownAnalogLight', ...
                    'No analog intensity output is configured for %s.', lightName);
            end
            requestedVolts = double(requestedVolts);
            if ~isscalar(requestedVolts) || ~isfinite(requestedVolts) || ...
                    requestedVolts < obj.AnalogMinimumVolts(index) || ...
                    requestedVolts > obj.AnalogMaximumVolts(index)
                error('ZouLab:AnalogVoltageOutsideRange', ...
                    'Requested %.6g V for %s; valid range is %.6g to %.6g V.', ...
                    requestedVolts, lightName, obj.AnalogMinimumVolts(index), ...
                    obj.AnalogMaximumVolts(index));
            end
            tag = "light_stim_AO_" + lightName;
            values = obj.OutputState;
            values(obj.ChannelTags == tag) = requestedVolts;
            write(obj.Output, values);
            obj.OutputState = values;
            actualVolts = requestedVolts;
            logger.log('SUCCESS', 'DAQ_ANALOG_LIGHT_VOLTAGE_CONFIRMED', ...
                ['Light=%s | Port=%s | RequestedVolts=%.6g | ', ...
                 'CommandedVolts=%.6g | CameraStartValues=%s | ', ...
                 'CameraStartCommandIssued=0 | OpticalFeedbackAvailable=0'], ...
                lightName, obj.AnalogLightPorts(index), requestedVolts, actualVolts, ...
                mat2str(values(ismember(obj.ChannelTags, ["camera1","camera2"]))));
        end

        function startFinitePlan(obj, plan, logger)
            obj.assertReady();
            if obj.FinitePlanRunning
                error('ZouLab:DaqPlanAlreadyRunning', ...
                    'A finite DAQ output plan is already running.');
            end
            if ~isfield(plan, 'channel_names') || ~isfield(plan, 'output') || ...
                    ~isfield(plan, 'sample_rate_hz')
                error('ZouLab:DaqPlanInvalid', ...
                    'DAQ plan must contain channel_names, output, and sample_rate_hz.');
            end
            sourceNames = string(plan.channel_names);
            dmdSource = find(sourceNames == "dmd_trigger", 1);
            if ~isempty(dmdSource) && any(plan.output(:, dmdSource) ~= 0) && ...
                    ~any(obj.ChannelTags == "dmd_trigger")
                error('ZouLab:DmdDaqPortRequired', ...
                    ['DMD stimulus is armed, but its DAQ output line is not configured. ', ...
                     'Set DMD IN1 output in Advanced after confirming the physical wiring.']);
            end
            scanData = zeros(size(plan.output, 1), numel(obj.ChannelTags));
            for channel = 1:numel(obj.ChannelTags)
                sourceIndex = find(sourceNames == obj.ChannelTags(channel), 1);
                if ~isempty(sourceIndex)
                    scanData(:, channel) = plan.output(:, sourceIndex);
                end
            end
            lightColumns = ismember(obj.ChannelTags, "light_" + obj.LightNames);
            if obj.LightActiveValue == 0
                scanData(:, lightColumns) = 1 - scanData(:, lightColumns);
            end
            for analogIndex = 1:numel(obj.AnalogLightNames)
                analogColumn = obj.ChannelTags == ...
                    "light_stim_AO_" + obj.AnalogLightNames(analogIndex);
                if ~any(analogColumn)
                    continue;
                end
                values = scanData(:, analogColumn);
                if any(~isfinite(values)) || ...
                        any(values < obj.AnalogMinimumVolts(analogIndex)) || ...
                        any(values > obj.AnalogMaximumVolts(analogIndex))
                    error('ZouLab:DaqPlanAnalogRangeInvalid', ...
                        ['DAQ plan for %s contains values outside %.6g to %.6g V. ', ...
                         'No hardware output was started.'], ...
                        obj.AnalogLightNames(analogIndex), ...
                        obj.AnalogMinimumVolts(analogIndex), ...
                        obj.AnalogMaximumVolts(analogIndex));
                end
            end
            ledColumn = obj.ChannelTags == "led_flicker_frequency";
            if any(ledColumn)
                ledValues = scanData(:, ledColumn);
                if any(~isfinite(ledValues)) || ...
                        any(ledValues < obj.LedFlickerMinimumVolts) || ...
                        any(ledValues > obj.LedFlickerMaximumVolts)
                    error('ZouLab:DaqPlanLedFlickerRangeInvalid', ...
                        ['LED flicker AO contains values outside %.6g to ', ...
                         '%.6g V. No hardware output was started.'], ...
                        obj.LedFlickerMinimumVolts, ...
                        obj.LedFlickerMaximumVolts);
                end
            end
            scanData(end, :) = obj.offVector();
            try
                stop(obj.Output);
            catch
            end
            flush(obj.Output);
            obj.Output.Rate = plan.sample_rate_hz;
            preload(obj.Output, scanData);
            start(obj.Output);
            obj.FinitePlanRunning = true;
            obj.LastFinitePlan = plan;
            logger.log('SUCCESS', 'DAQ_FINITE_PLAN_STARTED', ...
                ['Rate=%.6g | Samples=%d | DurationSeconds=%.6g | ', ...
                 'Channels=%s | LightActiveValue=%g'], ...
                plan.sample_rate_hz, size(scanData, 1), ...
                (size(scanData, 1) - 1) / plan.sample_rate_hz, ...
                strjoin(obj.ChannelTags, ','), obj.LightActiveValue);
        end

        function finishFinitePlan(obj, logger)
            if isempty(obj.Output)
                obj.FinitePlanRunning = false;
                return;
            end
            try
                if obj.FinitePlanRunning
                    stop(obj.Output);
                end
                flush(obj.Output);
                obj.OutputState = obj.offVector();
                write(obj.Output, obj.OutputState);
                logger.log('INFO', 'DAQ_FINITE_PLAN_FINISHED', ...
                    'All owned output channels returned to safe state.');
            catch ME
                logger.logException('DAQ_FINITE_PLAN_FINISH_FAILED', ME);
                rethrow(ME);
            end
            obj.FinitePlanRunning = false;
        end

        function success = safeOff(obj)
            success = true;
            if ~isempty(obj.Output)
                try
                    obj.abortVisualSync();
                    if obj.FinitePlanRunning
                        stop(obj.Output);
                    end
                    obj.FinitePlanRunning = false;
                    obj.OutputState = obj.offVector();
                    write(obj.Output, obj.OutputState);
                catch
                    success = false;
                end
            end
        end

        function disconnect(obj, logger)
            obj.abortVisualSync();
            if ~isempty(obj.Output)
                obj.safeOff();
                obj.Output = [];
            end
            if obj.Connected
                logger.log('INFO', 'DAQ_DISCONNECTED', 'All owned output lines returned to safe state.');
            end
            obj.Connected = false;
        end

        function delete(obj)
            obj.safeOff();
            obj.Output = [];
            obj.Connected = false;
        end
    end

    methods (Access = private)
        function port = portFor(~, entries, tag)
            tags = string({entries.tag});
            index = find(tags == string(tag), 1);
            if isempty(index)
                error('ZouLab:WiringTagMissing', ...
                    'Wiring configuration is missing tag "%s".', tag);
            end
            port = string(entries(index).port);
        end

        function entry = entryFor(~, entries, tag)
            tags = string({entries.tag});
            index = find(tags == string(tag), 1);
            if isempty(index)
                error('ZouLab:WiringTagMissing', ...
                    'Wiring configuration is missing tag "%s".', tag);
            end
            entry = entries(index);
        end

        function value = configuredText(~, textValue)
            if strlength(string(textValue)) == 0
                value = 'unconfigured';
            else
                value = char(string(textValue));
            end
        end

        function setVisualStamp(obj, state)
            if isempty(obj.Output)
                return;
            end
            values = obj.OutputState;
            values(obj.ChannelTags == "visual_stamp") = double(logical(state));
            write(obj.Output, values);
            obj.OutputState = values;
        end

        function sync = buildVisualSyncTable(obj, rawData, cameraIndices, vbl)
            sync = table();
            if isempty(rawData) || isempty(vbl)
                return;
            end
            variableNames = string(rawData.Properties.VariableNames);
            stampVariable = find(contains(variableNames, obj.VisualStampInput, ...
                'IgnoreCase', true), 1);
            if isempty(stampVariable)
                error('ZouLab:VisualStampInputMissing', ...
                    'DAQ visual sync data does not contain %s.', obj.VisualStampInput);
            end
            stampCounter = double(rawData.(variableNames(stampVariable)));
            onsets = find(diff(stampCounter) > 0) + 1;
            commonCount = min(numel(onsets), numel(vbl));
            if commonCount == 0
                return;
            end
            onsets = onsets(1:commonCount);
            sync.StimulusFrame = (0:commonCount - 1).';
            sync.PTBVBLTime = double(vbl(1:commonCount));
            sync.DAQTimestampSeconds = seconds(rawData.Time(onsets));
            for cameraIndex = cameraIndices
                port = obj.CameraTimingPorts(cameraIndex);
                variableIndex = find(contains(variableNames, port, ...
                    'IgnoreCase', true), 1);
                if isempty(variableIndex)
                    sync.(sprintf('Camera%dFrame', cameraIndex)) = ...
                        nan(commonCount, 1);
                else
                    values = double(rawData.(variableNames(variableIndex)));
                    sync.(sprintf('Camera%dFrame', cameraIndex)) = values(onsets);
                end
            end
        end

        function sync = buildFiniteEventSyncTable( ...
                obj, rawData, cameraIndices, plannedEventSeconds)
            sync = table();
            if isempty(rawData)
                return;
            end
            variableNames = string(rawData.Properties.VariableNames);
            stampVariable = find(contains(variableNames, ...
                obj.VisualStampInput, 'IgnoreCase', true), 1);
            if isempty(stampVariable)
                error('ZouLab:VisualStampInputMissing', ...
                    'DAQ event-sync data does not contain %s.', ...
                    obj.VisualStampInput);
            end
            stampCounter = double(rawData.(variableNames(stampVariable)));
            onsets = find(diff(stampCounter) > 0) + 1;
            commonCount = min(numel(onsets), numel(plannedEventSeconds));
            if commonCount == 0
                return;
            end
            onsets = onsets(1:commonCount);
            planned = double(plannedEventSeconds(1:commonCount)).';
            daqTime = seconds(rawData.Time(onsets));
            sync.EventIndex = (1:commonCount).';
            sync.PlannedSeconds = planned;
            sync.DAQTimestampSeconds = daqTime;
            sync.DAQRelativeSeconds = daqTime - daqTime(1);
            sync.PlannedRelativeSeconds = planned - planned(1);
            sync.TimingErrorSeconds = sync.DAQRelativeSeconds - ...
                sync.PlannedRelativeSeconds;
            for cameraIndex = cameraIndices
                port = obj.CameraTimingPorts(cameraIndex);
                variableIndex = find(contains(variableNames, port, ...
                    'IgnoreCase', true), 1);
                if isempty(variableIndex)
                    values = nan(commonCount, 1);
                else
                    counterValues = double(rawData.( ...
                        variableNames(variableIndex)));
                    values = counterValues(onsets);
                end
                sync.(sprintf('Camera%dFrame', cameraIndex)) = values;
            end
        end

        function values = offVector(obj)
            values = zeros(1, numel(obj.ChannelTags));
            lightMask = ismember(obj.ChannelTags, "light_" + obj.LightNames);
            values(lightMask) = 1 - obj.LightActiveValue;
            for analogIndex = 1:numel(obj.AnalogLightNames)
                analogMask = obj.ChannelTags == ...
                    "light_stim_AO_" + obj.AnalogLightNames(analogIndex);
                values(analogMask) = obj.AnalogSafeVolts(analogIndex);
            end
            values(obj.ChannelTags == "led_flicker_enable") = 0;
            values(obj.ChannelTags == "led_flicker_frequency") = ...
                obj.LedFlickerSafeVolts;
        end
    end
end
