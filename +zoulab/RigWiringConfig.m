classdef RigWiringConfig < handle
    %RIGWIRINGCONFIG Load and validate the editable rig wiring JSON.

    properties (SetAccess = private)
        FilePath string
        Value struct = struct()
        LoadedAt string = ""
    end

    methods
        function obj = RigWiringConfig(filePath)
            obj.FilePath = string(filePath);
        end

        function value = load(obj, logger)
            if ~isfile(obj.FilePath)
                error('ZouLab:WiringConfigMissing', ...
                    ['Rig wiring JSON does not exist: %s. Copy ', ...
                     'config/rig_wiring.example.json to rig_wiring.json and ', ...
                     'enter this workstation''s private hardware mapping.'], ...
                    obj.FilePath);
            end
            try
                value = jsondecode(fileread(obj.FilePath));
            catch ME
                error('ZouLab:WiringConfigJsonInvalid', ...
                    'Rig wiring JSON could not be parsed: %s', ME.message);
            end
            obj.validate(value);
            obj.Value = value;
            obj.LoadedAt = string(datetime('now', ...
                'Format', 'yyyy-MM-dd HH:mm:ss.SSS'));
            logger.log('SUCCESS', 'RIG_WIRING_CONFIG_LOADED', ...
                ['File=%s | Schema=%s | Device=%s | DummyInput=%s | DigitalOutputs=%s | ', ...
                 'AnalogOutputs=%s | CameraCounters=%s,%s | DmdOut1=%s'], ...
                obj.FilePath, value.schema_version, value.daq.device_id, ...
                value.daq.dummy_input, ...
                strjoin(string({value.digital_outputs.tag}), ','), ...
                strjoin(string({value.analog_outputs.tag}), ','), ...
                value.counter_inputs.camera1_vsync, ...
                value.counter_inputs.camera2_vsync, ...
                obj.configuredText(value.counter_inputs.dmd_out1));
        end

        function saveTextAndReload(obj, jsonText, logger)
            try
                candidate = jsondecode(char(join(string(jsonText), newline)));
            catch ME
                error('ZouLab:WiringConfigJsonInvalid', ...
                    'JSON was not saved because it could not be parsed: %s', ME.message);
            end
            obj.validate(candidate);
            previous = fileread(obj.FilePath);
            stamp = string(datetime('now', 'Format', 'yyyyMMdd_HHmmss_SSS'));
            backupPath = obj.FilePath + "." + stamp + ".bak";
            fileID = fopen(backupPath, 'w', 'n', 'UTF-8');
            if fileID < 0
                error('ZouLab:WiringConfigBackupFailed', ...
                    'Could not create wiring backup: %s', backupPath);
            end
            cleanup = onCleanup(@() fclose(fileID));
            fwrite(fileID, previous, 'char');
            clear cleanup;
            encoded = jsonencode(candidate, 'PrettyPrint', true);
            temporaryPath = obj.FilePath + "." + stamp + ".tmp";
            fileID = fopen(temporaryPath, 'w', 'n', 'UTF-8');
            if fileID < 0
                error('ZouLab:WiringConfigWriteFailed', ...
                    'Could not create temporary wiring JSON: %s', temporaryPath);
            end
            cleanup = onCleanup(@() fclose(fileID));
            fwrite(fileID, encoded, 'char');
            clear cleanup;
            [moved, message] = movefile(temporaryPath, obj.FilePath, 'f');
            if ~moved
                if isfile(temporaryPath)
                    delete(temporaryPath);
                end
                error('ZouLab:WiringConfigWriteFailed', ...
                    'Validated JSON could not replace %s: %s', ...
                    obj.FilePath, message);
            end
            logger.log('SUCCESS', 'RIG_WIRING_CONFIG_SAVED', ...
                'File=%s | Backup=%s | ValidatedBeforeWrite=1', ...
                obj.FilePath, backupPath);
            obj.load(logger);
        end

        function textValue = prettyText(obj)
            if isempty(fieldnames(obj.Value))
                textValue = string(fileread(obj.FilePath));
            else
                textValue = string(jsonencode(obj.Value, 'PrettyPrint', true));
            end
        end
    end

    methods (Access = private)
        function validate(~, value)
            requiredTop = {'schema_version','daq','digital_outputs','analog_outputs', ...
                'counter_inputs','serial','dmd_network','camera'};
            for k = 1:numel(requiredTop)
                if ~isfield(value, requiredTop{k})
                    error('ZouLab:WiringConfigFieldMissing', ...
                        'Rig wiring JSON is missing %s.', requiredTop{k});
                end
            end
            if ~isfield(value.serial, 'spectrax')
                error('ZouLab:WiringConfigSpectraXPortMissing', ...
                    'serial.spectrax must specify the fixed Spectra X COM port.');
            end
            if ~isfield(value.camera, 'serials') || ...
                    ~isfield(value.camera, 'bus_tokens') || ...
                    numel(value.camera.serials) ~= 2 || ...
                    numel(value.camera.bus_tokens) ~= 2 || ...
                    any(strlength(strtrim(string(value.camera.serials))) == 0) || ...
                    any(strlength(strtrim(string(value.camera.bus_tokens))) == 0)
                error('ZouLab:WiringConfigCameraIdentityInvalid', ...
                    ['camera.serials and camera.bus_tokens must each contain ', ...
                     'two nonempty camera identity values.']);
            end
            spectraPort = strtrim(string(value.serial.spectrax));
            if strlength(spectraPort) == 0 || strcmpi(spectraPort, 'auto') || ...
                    isempty(regexp(char(spectraPort), '^COM\d+$', 'once'))
                error('ZouLab:WiringConfigSpectraXPortInvalid', ...
                    ['serial.spectrax must be a fixed Windows COM port such as COM3; ', ...
                     'automatic serial-port discovery is disabled.']);
            end
            requiredTags = ["camera1","camera2","visual_stamp", ...
                "dmd_trigger","led_flicker_enable", ...
                "light_Laser405","light_Laser445", ...
                "light_LEDcyan","light_LEDgreen","light_LEDred"];
            tags = string({value.digital_outputs.tag});
            ports = string({value.digital_outputs.port});
            missing = requiredTags(~ismember(requiredTags, tags));
            if ~isempty(missing)
                error('ZouLab:WiringConfigTagMissing', ...
                    'Rig wiring JSON is missing output tag(s): %s.', ...
                    strjoin(missing, ', '));
            end
            assignedPorts = ports(strlength(ports) > 0);
            if numel(unique(lower(assignedPorts))) ~= numel(assignedPorts)
                error('ZouLab:WiringConfigDuplicatePort', ...
                    'Two output tags cannot own the same DAQ port.');
            end
            optionalEmpty = tags == "dmd_trigger";
            if any(strlength(tags) == 0) || ...
                    any(strlength(ports(~optionalEmpty)) == 0)
                error('ZouLab:WiringConfigEmptyOutput', ...
                    ['Every digital output except dmd_trigger requires a nonempty port. ', ...
                     'An unconfirmed DMD connection must remain blank.']);
            end
            requiredAnalogTags = ["light_stim_AO_Laser405", ...
                "light_stim_AO_Laser445","led_flicker_frequency"];
            analogTags = string({value.analog_outputs.tag});
            analogPorts = string({value.analog_outputs.port});
            missingAnalog = requiredAnalogTags(~ismember(requiredAnalogTags, analogTags));
            if ~isempty(missingAnalog)
                error('ZouLab:WiringConfigAnalogTagMissing', ...
                    'Rig wiring JSON is missing analog output tag(s): %s.', ...
                    strjoin(missingAnalog, ', '));
            end
            if any(strlength(analogTags) == 0) || any(strlength(analogPorts) == 0)
                error('ZouLab:WiringConfigEmptyAnalogOutput', ...
                    'Every analog output requires a nonempty tag and port.');
            end
            if numel(unique(lower(analogPorts))) ~= numel(analogPorts)
                error('ZouLab:WiringConfigDuplicateAnalogPort', ...
                    'Two analog output tags cannot own the same DAQ port.');
            end
            for analogIndex = 1:numel(value.analog_outputs)
                entry = value.analog_outputs(analogIndex);
                mustBeFinite(entry.minimum_voltage);
                mustBeFinite(entry.maximum_voltage);
                mustBeFinite(entry.safe_voltage);
                if entry.maximum_voltage <= entry.minimum_voltage || ...
                        entry.safe_voltage < entry.minimum_voltage || ...
                        entry.safe_voltage > entry.maximum_voltage
                    error('ZouLab:WiringConfigAnalogRangeInvalid', ...
                        ['Analog output %s requires minimum < maximum and a safe ', ...
                         'voltage inside that closed range.'], entry.tag);
                end
            end
            ledAnalog = value.analog_outputs(analogTags == ...
                "led_flicker_frequency");
            if ~isfield(ledAnalog, 'frequency_hz_per_volt') || ...
                    ~isscalar(ledAnalog.frequency_hz_per_volt) || ...
                    ~isfinite(ledAnalog.frequency_hz_per_volt) || ...
                    ledAnalog.frequency_hz_per_volt <= 0
                error('ZouLab:WiringConfigLedScaleInvalid', ...
                    ['led_flicker_frequency requires a positive ', ...
                     'frequency_hz_per_volt calibration.']);
            end
            mustBePositive(value.daq.input_sample_rate_hz);
            if ~isfield(value.daq, 'dummy_input') || ...
                    strlength(strtrim(string(value.daq.dummy_input))) == 0
                error('ZouLab:WiringConfigDummyInputMissing', ...
                    'daq.dummy_input must name the analog clock channel, for example ai0.');
            end
            if isempty(regexp(char(string(value.daq.dummy_input)), ...
                    '^ai\d+$', 'once'))
                error('ZouLab:WiringConfigDummyInputInvalid', ...
                    'daq.dummy_input must be an NI analog input such as ai0.');
            end
            if ~ismember(value.daq.light_active_value, [0 1])
                error('ZouLab:WiringConfigPolarityInvalid', ...
                    'daq.light_active_value must be 0 or 1.');
            end
            mustBePositive(value.daq.camera_start_pulse_seconds);
            if value.dmd_network.host_port < 1 || value.dmd_network.host_port > 65535 || ...
                    value.dmd_network.target_port < 1 || ...
                    value.dmd_network.target_port > 65535
                error('ZouLab:WiringConfigNetworkPortInvalid', ...
                    'DMD UDP ports must be between 1 and 65535.');
            end
        end

        function value = configuredText(~, textValue)
            if strlength(string(textValue)) == 0
                value = 'unconfigured';
            else
                value = char(string(textValue));
            end
        end
    end
end
