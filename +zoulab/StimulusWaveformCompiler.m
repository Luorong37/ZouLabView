classdef StimulusWaveformCompiler
    %STIMULUSWAVEFORMCOMPILER Build the exact finite DAQ output matrix.

    methods (Static)
        function plan = compile(spec, channelNames)
            arguments
                spec struct
                channelNames string = ["camera1", "camera2", "visual_stamp", ...
                    "light_Laser405", "light_Laser445", ...
                    "light_stim_AO_Laser405", "light_stim_AO_Laser445", ...
                    "light_LEDcyan", "light_LEDgreen", "light_LEDred", ...
                    "dmd_trigger", "led_flicker_enable", ...
                    "led_flicker_frequency"]
            end

            spec = zoulab.StimulusWaveformCompiler.withDefaults(spec);
            zoulab.StimulusWaveformCompiler.validateSpec(spec);
            rate = double(spec.sample_rate_hz);
            relativeStart = 0;
            if ~isempty(spec.imaging_light_names)
                relativeStart = min(relativeStart, ...
                    spec.imaging_light_start_offset_seconds);
            end
            if spec.light_stimulus_armed
                relativeStart = min(relativeStart, ...
                    spec.light_stimulus_start_offset_seconds);
                selectedAnalog = intersect(string(spec.stimulus_light_names), ...
                    ["Laser405","Laser445"], 'stable');
                for analogName = selectedAnalog(:).'
                    analogSpec = zoulab.StimulusWaveformCompiler.analogSpecFor( ...
                        spec.analog_waveforms, analogName);
                    relativeStart = min(relativeStart, analogSpec.delay_seconds);
                end
            end
            if spec.led_flicker_armed
                relativeStart = min(relativeStart, ...
                    spec.led_flicker_start_offset_seconds);
            end
            if spec.dmd_armed
                relativeStart = min(relativeStart, ...
                    spec.dmd_start_offset_seconds);
            end
            relativeEnd = spec.camera_window_seconds;
            if ~isempty(spec.imaging_light_names)
                relativeEnd = max(relativeEnd, spec.camera_window_seconds + ...
                    spec.imaging_light_end_offset_seconds);
            end
            % Put the complete plan on one authoritative integer sample grid.
            % Flooring the earliest offset and ceiling the latest endpoint
            % preserve every requested event without floating-point boundary
            % loss at decimal offsets such as 0.25 s.
            startSample = floor(relativeStart * rate);
            endSample = ceil(relativeEnd * rate);
            if endSample <= startSample
                endSample = startSample + 1;
            end
            sampleNumbers = (startSample:endSample).';
            sampleCount = numel(sampleNumbers);
            time = sampleNumbers ./ rate;
            daqTime = (sampleNumbers - startSample) ./ rate;
            relativeStart = time(1);
            relativeEnd = time(end);
            totalSeconds = relativeEnd - relativeStart;
            output = zeros(sampleCount, numel(channelNames));

            cameraStartDaq = -relativeStart;
            cameraEndDaq = cameraStartDaq + spec.camera_window_seconds;
            output = zoulab.StimulusWaveformCompiler.addPulse(output, channelNames, ...
                "camera1", cameraStartDaq, spec.camera_trigger_width_seconds, rate, ...
                any(spec.cameras == 1));
            output = zoulab.StimulusWaveformCompiler.addPulse(output, channelNames, ...
                "camera2", cameraStartDaq, spec.camera_trigger_width_seconds, rate, ...
                any(spec.cameras == 2));

            imagingNames = string(spec.imaging_light_names);
            for name = imagingNames(:).'
                ttlName = "light_" + name;
                output = zoulab.StimulusWaveformCompiler.addWindow(output, ...
                    channelNames, ttlName, ...
                    cameraStartDaq + spec.imaging_light_start_offset_seconds, ...
                    cameraEndDaq + spec.imaging_light_end_offset_seconds, rate, true);
                analogName = "light_stim_AO_" + name;
                analogIndex = find(channelNames == analogName, 1);
                if ~isempty(analogIndex)
                    volts = zoulab.StimulusWaveformCompiler.imagingVoltage( ...
                        spec.imaging_light_analog_volts, name);
                    ttlIndex = find(channelNames == ttlName, 1);
                    if isempty(ttlIndex)
                        output(:, analogIndex) = 0;
                    else
                        output(:, analogIndex) = volts .* ...
                            double(output(:, ttlIndex) > 0);
                    end
                end
            end

            stimulusStart = spec.light_stimulus_start_offset_seconds;
            if spec.light_stimulus_armed
                lightNames = string(spec.stimulus_light_names);
                stimulusMask = zoulab.StimulusWaveformCompiler.waveformMask( ...
                    time, stimulusStart, spec);
                for name = lightNames(:).'
                    index = find(channelNames == "light_" + name, 1);
                    if ~isempty(index)
                        output(:, index) = max(output(:, index), stimulusMask);
                    end
                    analogIndex = find(channelNames == ...
                        "light_stim_AO_" + name, 1);
                    if ~isempty(analogIndex)
                        analogSpec = zoulab.StimulusWaveformCompiler.analogSpecFor( ...
                            spec.analog_waveforms, name);
                        analogValues = zoulab.StimulusWaveformCompiler.analogWaveform( ...
                            time, 0, analogSpec);
                        output(:, analogIndex) = analogValues .* stimulusMask;
                    end
                end
                stimulusColumns = ismember(channelNames, ...
                    ["light_" + lightNames, ...
                     "light_stim_AO_" + lightNames]);
                output(time > spec.camera_window_seconds, stimulusColumns) = 0;
            end

            ledEventTimes = zeros(1, 0);
            if spec.led_flicker_armed
                ledStart = spec.led_flicker_start_offset_seconds;
                doTimes = double(spec.led_flicker_do_points(:, 1));
                doValues = double(spec.led_flicker_do_points(:, 2));
                aoTimes = double(spec.led_flicker_ao_points(:, 1));
                aoVolts = double(spec.led_flicker_ao_points(:, 3));
                ledEnd = ledStart + max(doTimes(end), aoTimes(end));
                doColumn = find(channelNames == "led_flicker_enable", 1);
                if ~isempty(doColumn)
                    output(:, doColumn) = ...
                        zoulab.StimulusWaveformCompiler.sampleCyclicDigital( ...
                            time, ledStart, doTimes, doValues, 1);
                    output(time > spec.camera_window_seconds, doColumn) = 0;
                end
                aoColumn = find(channelNames == "led_flicker_frequency", 1);
                if ~isempty(aoColumn)
                    output(:, aoColumn) = ...
                        zoulab.StimulusWaveformCompiler.sampleCyclicPoints( ...
                            time, ledStart, aoTimes, aoVolts, 1);
                    output(time > spec.camera_window_seconds, aoColumn) = 0;
                end
                % LED flicker and camera START are channels in the same
                % finite DAQ output matrix.  Their relative timing is
                % therefore defined by that matrix; visual_stamp is
                % reserved exclusively for software-timed PTB flips.
                ledEventTimes = ledStart + unique([doTimes; aoTimes], ...
                    'stable').';
            end

            if spec.dmd_armed
                dmdIndex = find(channelNames == "dmd_trigger", 1);
                if ~isempty(dmdIndex)
                    dmdStart = spec.dmd_start_offset_seconds;
                    if ~isempty(spec.dmd_trigger_point_times_seconds)
                        pointTimes = double( ...
                            spec.dmd_trigger_point_times_seconds(:));
                        pointValues = double(spec.dmd_trigger_point_values(:));
                        repeatCount = 1;
                        if spec.dmd_repeat_to_fill_timeline && pointTimes(end) > 0
                            repeatCount = max(1, ceil( ...
                                (spec.camera_window_seconds - dmdStart) / ...
                                pointTimes(end)));
                        end
                        output(:, dmdIndex) = max(output(:, dmdIndex), ...
                            zoulab.StimulusWaveformCompiler.sampleCyclicDigital( ...
                            time, dmdStart, pointTimes, pointValues, repeatCount));
                        output(time > spec.camera_window_seconds, dmdIndex) = 0;
                        triggerCount = nnz(output(:, dmdIndex) == 1 & ...
                            [true; output(1:end - 1, dmdIndex) == 0]);
                    elseif ~isempty(spec.dmd_trigger_times_seconds)
                        baseOnsets = double(spec.dmd_trigger_times_seconds(:).');
                        onsets = zeros(1, numel(baseOnsets) * ...
                            spec.dmd_trigger_repeat_count);
                        cursor = 0;
                        for repeatIndex = 0:spec.dmd_trigger_repeat_count - 1
                            range = cursor + (1:numel(baseOnsets));
                            onsets(range) = dmdStart + baseOnsets + ...
                                repeatIndex * spec.dmd_trigger_cycle_seconds;
                            cursor = cursor + numel(baseOnsets);
                        end
                        triggerCount = numel(onsets);
                    elseif isfinite(spec.dmd_trigger_count)
                        triggerCount = double(spec.dmd_trigger_count);
                        onsets = dmdStart + ...
                            (0:triggerCount - 1) ./ spec.dmd_frame_rate_hz;
                    else
                        dmdEnd = spec.camera_window_seconds;
                        triggerCount = max(0, floor((dmdEnd - dmdStart) * ...
                            spec.dmd_frame_rate_hz + 1e-9));
                        onsets = dmdStart + ...
                            (0:triggerCount - 1) ./ spec.dmd_frame_rate_hz;
                    end
                    if isempty(spec.dmd_trigger_point_times_seconds)
                        onsets = onsets(onsets + ...
                            spec.dmd_trigger_width_seconds <= ...
                            spec.camera_window_seconds + 1 / rate);
                        triggerCount = numel(onsets);
                        for onset = onsets
                            output = zoulab.StimulusWaveformCompiler.addPulse(output, ...
                                channelNames, "dmd_trigger", onset, ...
                                spec.dmd_trigger_width_seconds, rate, true);
                        end
                    end
                end
            end

            output(end, :) = 0;
            metrics = zoulab.StimulusWaveformCompiler.metrics(output, ...
                channelNames, rate);
            finiteFirst = isfinite(metrics.FirstOnsetSeconds);
            finiteLast = isfinite(metrics.LastOffsetSeconds);
            metrics.FirstOnsetSeconds(finiteFirst) = ...
                metrics.FirstOnsetSeconds(finiteFirst) + relativeStart;
            metrics.LastOffsetSeconds(finiteLast) = ...
                metrics.LastOffsetSeconds(finiteLast) + relativeStart;
            plan = struct( ...
                'schema_version', '1.0.0', ...
                'sample_rate_hz', rate, ...
                'time_seconds', time, ...
                'daq_time_seconds', daqTime, ...
                'channel_names', channelNames, ...
                'output', output, ...
                'duration_seconds', (sampleCount - 1) / rate, ...
                'camera_start_seconds', 0, ...
                'camera_end_seconds', spec.camera_window_seconds, ...
                'camera_start_daq_seconds', cameraStartDaq, ...
                'camera_end_daq_seconds', cameraEndDaq, ...
                'timeline_start_relative_seconds', relativeStart, ...
                'timeline_end_relative_seconds', relativeEnd, ...
                'stimulus_origin_seconds', 0, ...
                'led_flicker_event_times_seconds', ledEventTimes, ...
                'metrics', metrics, ...
                'spec', spec, ...
                'camera_trigger_semantics', ...
                    'one external START pulse per enabled camera; not one pulse per frame');
        end

        function spec = withDefaults(spec)
            hasImagingStartOffset = isfield(spec, ...
                'imaging_light_start_offset_seconds');
            hasImagingEndOffset = isfield(spec, ...
                'imaging_light_end_offset_seconds');
            hasLightStartOffset = isfield(spec, ...
                'light_stimulus_start_offset_seconds');
            hasDmdStartOffset = isfield(spec, 'dmd_start_offset_seconds');
            hasLedStartOffset = isfield(spec, ...
                'led_flicker_start_offset_seconds');
            defaults = struct( ...
                'sample_rate_hz', 10000, ...
                'cameras', [1 2], ...
                'camera_window_seconds', 30, ...
                'camera_trigger_width_seconds', 0.001, ...
                'imaging_light_lead_seconds', 1, ...
                'imaging_light_tail_seconds', 0, ...
                'camera_pre_stim_seconds', 0, ...
                'imaging_light_start_offset_seconds', -1, ...
                'imaging_light_end_offset_seconds', 0, ...
                'light_stimulus_start_offset_seconds', 0, ...
                'imaging_light_names', strings(1, 0), ...
                'imaging_light_analog_volts', struct( ...
                    'Laser405', 0, 'Laser445', 0), ...
                'light_stimulus_armed', false, ...
                'stimulus_light_names', "Laser405", ...
                'waveform_type', "Step", ...
                'digital_table_helper', "Pulse", ...
                'stimulus_delay_seconds', 0, ...
                'stimulus_duration_seconds', 1, ...
                'pulse_width_seconds', 0.1, ...
                'pulse_period_seconds', 1, ...
                'digital_point_times_seconds', [0 0 0.1 0.1 1], ...
                'digital_point_values', [0 1 1 0 0], ...
                'digital_repeat_count', 1, ...
                'digital_points_are_expanded', false, ...
                'custom_onsets_seconds', zeros(1, 0), ...
                'custom_durations_seconds', zeros(1, 0), ...
                'analog_waveforms', ...
                    zoulab.StimulusWaveformCompiler.defaultAnalogWaveforms(), ...
                'dmd_armed', false, ...
                'dmd_frame_rate_hz', 10, ...
                'dmd_trigger_count', NaN, ...
                'dmd_trigger_times_seconds', zeros(1, 0), ...
                'dmd_trigger_frame_indices', zeros(1, 0), ...
                'dmd_trigger_point_times_seconds', zeros(1, 0), ...
                'dmd_trigger_point_values', zeros(1, 0), ...
                'dmd_trigger_points_are_expanded', true, ...
                'dmd_trigger_repeat_count', 1, ...
                'dmd_trigger_cycle_seconds', 0.1, ...
                'dmd_trigger_width_seconds', 0.001, ...
                'dmd_start_offset_seconds', 0, ...
                'dmd_repeat_to_fill_timeline', false);
            defaults.led_flicker_armed = false;
            defaults.led_flicker_delay_seconds = 0;
            defaults.led_flicker_start_offset_seconds = 0;
            defaults.led_flicker_hz_per_volt = 24;
            defaults.led_flicker_do_points = [0 0; 0 1; 1 1; 1 0];
            defaults.led_flicker_ao_points = ...
                [0 0 0; 0 60 2.5; 1 60 2.5; 1 0 0];
            names = fieldnames(defaults);
            for k = 1:numel(names)
                if ~isfield(spec, names{k}) || isempty(spec.(names{k}))
                    spec.(names{k}) = defaults.(names{k});
                end
            end
            % Legacy plans used one shared PRE/HEAD/TAIL origin.  Preserve
            % their executed timing when an explicit camera-relative offset
            % is absent; all newly generated plans provide the new fields.
            if ~hasImagingStartOffset
                spec.imaging_light_start_offset_seconds = ...
                    -double(spec.imaging_light_lead_seconds);
            end
            if ~hasImagingEndOffset
                spec.imaging_light_end_offset_seconds = ...
                    double(spec.imaging_light_tail_seconds);
            end
            if ~hasLightStartOffset
                spec.light_stimulus_start_offset_seconds = ...
                    double(spec.camera_pre_stim_seconds) + ...
                    double(spec.stimulus_delay_seconds);
            end
            if ~hasDmdStartOffset
                spec.dmd_start_offset_seconds = ...
                    double(spec.camera_pre_stim_seconds) + ...
                    double(spec.stimulus_delay_seconds);
            end
            if ~hasLedStartOffset
                spec.led_flicker_start_offset_seconds = ...
                    double(spec.camera_pre_stim_seconds) + ...
                    double(spec.led_flicker_delay_seconds);
            end
            spec.waveform_type = string(spec.waveform_type);
            spec.imaging_light_names = string(spec.imaging_light_names);
            spec.stimulus_light_names = string(spec.stimulus_light_names);
            spec.cameras = unique(double(spec.cameras(:).'));
            analogDefaults = zoulab.StimulusWaveformCompiler.defaultAnalogWaveforms();
            laserNames = ["Laser405", "Laser445"];
            for laserName = laserNames
                field = char(laserName);
                if ~isfield(spec.analog_waveforms, field)
                    spec.analog_waveforms.(field) = analogDefaults.(field);
                else
                    spec.analog_waveforms.(field) = ...
                        zoulab.StimulusWaveformCompiler.mergeStruct( ...
                        analogDefaults.(field), spec.analog_waveforms.(field));
                end
            end
        end

        function validateSpec(spec)
            mustBePositive(spec.sample_rate_hz);
            mustBePositive(spec.camera_window_seconds);
            mustBeFinite(spec.imaging_light_start_offset_seconds);
            mustBeFinite(spec.imaging_light_end_offset_seconds);
            mustBeFinite(spec.light_stimulus_start_offset_seconds);
            mustBeFinite(spec.dmd_start_offset_seconds);
            mustBeFinite(spec.led_flicker_start_offset_seconds);
            mustBePositive(spec.camera_trigger_width_seconds);
            mustBeNonnegative(spec.stimulus_duration_seconds);
            mustBePositive(spec.dmd_frame_rate_hz);
            mustBePositive(spec.dmd_trigger_width_seconds);
            mustBePositive(spec.dmd_trigger_cycle_seconds);
            if spec.led_flicker_armed
                mustBeNonnegative(spec.led_flicker_delay_seconds);
                mustBePositive(spec.led_flicker_hz_per_volt);
                doPoints = double(spec.led_flicker_do_points);
                aoPoints = double(spec.led_flicker_ao_points);
                if size(doPoints, 2) ~= 2 || size(aoPoints, 2) ~= 3
                    error('ZouLab:LedFlickerPointColumnsInvalid', ...
                        ['LED DO needs [time enable]; LED AO needs ', ...
                         '[time frequency_hz voltage_v].']);
                end
                zoulab.StimulusWaveformCompiler.validateDigitalPointWaveform( ...
                    doPoints(:, 1), doPoints(:, 2), 1);
                zoulab.StimulusWaveformCompiler.validatePointWaveform( ...
                    aoPoints(:, 1), aoPoints(:, 3), 1, 'LED flicker AO');
                if any(aoPoints(:, 2) < 0 | aoPoints(:, 2) > 120) || ...
                        any(aoPoints(:, 3) < 0 | aoPoints(:, 3) > 5) || ...
                        any(abs(aoPoints(:, 2) - aoPoints(:, 3) .* ...
                        spec.led_flicker_hz_per_volt) > 1e-9)
                    error('ZouLab:LedFlickerAoInvalid', ...
                        ['LED AO must stay within 0-5 V / 0-120 Hz and ', ...
                         'Frequency must equal Voltage x HzPerVolt.']);
                end
            end
            if ~isscalar(spec.dmd_trigger_repeat_count) || ...
                    ~isfinite(spec.dmd_trigger_repeat_count) || ...
                    spec.dmd_trigger_repeat_count < 1 || ...
                    fix(spec.dmd_trigger_repeat_count) ~= spec.dmd_trigger_repeat_count
                error('ZouLab:DmdTriggerRepeatInvalid', ...
                    'DMD IN1 sequence cycles must be a positive integer.');
            end
            triggerTimes = double(spec.dmd_trigger_times_seconds(:));
            if any(~isfinite(triggerTimes)) || any(triggerTimes < 0) || ...
                    any(diff(triggerTimes) <= 0) || ...
                    (~isempty(triggerTimes) && ...
                    triggerTimes(end) >= spec.dmd_trigger_cycle_seconds)
                error('ZouLab:DmdTriggerTimesInvalid', ...
                    ['DMD IN1 edge times must be finite, nonnegative, strictly ', ...
                     'increasing, and inside one trigger cycle.']);
            end
            triggerFrames = double(spec.dmd_trigger_frame_indices(:));
            if ~isempty(triggerFrames) && ...
                    (numel(triggerFrames) ~= numel(triggerTimes) || ...
                    any(~isfinite(triggerFrames)) || any(triggerFrames < 1) || ...
                    any(fix(triggerFrames) ~= triggerFrames))
                error('ZouLab:DmdTriggerFrameAnnotationInvalid', ...
                    ['DMD expected-frame annotations must contain one positive ', ...
                     'integer for every IN1 edge.']);
            end
            triggerPointTimes = double( ...
                spec.dmd_trigger_point_times_seconds(:));
            triggerPointValues = double(spec.dmd_trigger_point_values(:));
            if ~isempty(triggerPointTimes) || ~isempty(triggerPointValues)
                zoulab.StimulusWaveformCompiler.validateDigitalPointWaveform( ...
                    triggerPointTimes, triggerPointValues, 1);
                pointTriggerCount = nnz(triggerPointValues == 1 & ...
                    [true; triggerPointValues(1:end - 1) == 0]);
                if isfinite(spec.dmd_trigger_count) && ...
                        pointTriggerCount ~= spec.dmd_trigger_count
                    error('ZouLab:DmdTriggerPointCountMismatch', ...
                        ['DMD IN1 point table contains %d rising edges, but ', ...
                         'dmd_trigger_count is %d.'], pointTriggerCount, ...
                        spec.dmd_trigger_count);
                end
            end
            if isfinite(spec.dmd_trigger_count) && ...
                    (~isscalar(spec.dmd_trigger_count) || ...
                     spec.dmd_trigger_count < 0 || ...
                     fix(spec.dmd_trigger_count) ~= spec.dmd_trigger_count)
                error('ZouLab:DmdTriggerCountInvalid', ...
                    'DMD trigger count must be a nonnegative integer.');
            end
            if spec.dmd_armed && isfinite(spec.dmd_trigger_count) && ...
                    spec.dmd_trigger_count == 0
                error('ZouLab:DmdTriggerCountMissing', ...
                    ['DMD is armed but its compiled pattern has no binary-frame ', ...
                     'trigger count. Load a compiled pattern first.']);
            end
            if ~all(ismember(spec.cameras, [1 2]))
                error('ZouLab:WaveformCameraInvalid', ...
                    'Cameras must contain Camera 1, Camera 2, or both.');
            end
            supported = ["Points", "Step", "Constant (Line)", "Pulse", "Custom"];
            if ~any(strcmpi(spec.waveform_type, supported))
                error('ZouLab:WaveformTypeInvalid', ...
                    ['Waveform must be Points, Step, Constant (Line), Pulse, ', ...
                     'or Custom.']);
            end
            if strcmpi(spec.waveform_type, 'Points')
                zoulab.StimulusWaveformCompiler.validateDigitalPointWaveform( ...
                    spec.digital_point_times_seconds, ...
                    spec.digital_point_values, spec.digital_repeat_count);
            elseif strcmpi(spec.waveform_type, 'Pulse')
                mustBePositive(spec.pulse_width_seconds);
                mustBePositive(spec.pulse_period_seconds);
                if spec.pulse_width_seconds > spec.pulse_period_seconds
                    error('ZouLab:PulseWidthInvalid', ...
                        'Pulse width cannot exceed the pulse period.');
                end
            elseif strcmpi(spec.waveform_type, 'Custom')
                onsets = double(spec.custom_onsets_seconds(:));
                durations = double(spec.custom_durations_seconds(:));
                if numel(onsets) ~= numel(durations) || any(onsets < 0) || ...
                        any(durations <= 0)
                    error('ZouLab:CustomWaveformInvalid', ...
                        ['Custom onset and duration lists must have equal lengths; ', ...
                         'onsets must be >= 0 and durations must be > 0.']);
                end
            end
            selectedAnalog = intersect(string(spec.stimulus_light_names), ...
                ["Laser405", "Laser445"], 'stable');
            for laserName = selectedAnalog(:).'
                analogSpec = zoulab.StimulusWaveformCompiler.analogSpecFor( ...
                    spec.analog_waveforms, laserName);
                zoulab.StimulusWaveformCompiler.validateAnalogSpec( ...
                    analogSpec, laserName);
            end
            imagingLaserNames = intersect(string(spec.imaging_light_names), ...
                ["Laser405", "Laser445"]);
            for laserName = imagingLaserNames(:).'
                volts = zoulab.StimulusWaveformCompiler.imagingVoltage( ...
                    spec.imaging_light_analog_volts, laserName);
                if ~isscalar(volts) || ~isfinite(volts) || volts < 0 || volts > 5
                    error('ZouLab:ImagingAnalogVoltageInvalid', ...
                        'Imaging AO for %s must be between 0 and 5 V.', laserName);
                end
            end
            overlap = intersect(imagingLaserNames, selectedAnalog);
            if spec.light_stimulus_armed && ~isempty(overlap)
                error('ZouLab:ImagingStimulusLaserConflict', ...
                    ['The same Coherent laser cannot be both Imaging and Stimulus ', ...
                     'in one acquisition: %s.'], strjoin(overlap, ', '));
            end
        end

        function metricsTable = metrics(output, channelNames, rate)
            count = zeros(numel(channelNames), 1);
            first = nan(numel(channelNames), 1);
            last = nan(numel(channelNames), 1);
            high = zeros(numel(channelNames), 1);
            minWidth = nan(numel(channelNames), 1);
            maxWidth = nan(numel(channelNames), 1);
            for channel = 1:numel(channelNames)
                values = output(:, channel) > 0;
                starts = find(diff([false; values]) == 1);
                stops = find(diff([values; false]) == -1);
                widths = (stops - starts + 1) ./ rate;
                count(channel) = numel(starts);
                high(channel) = sum(values) / rate;
                if ~isempty(starts)
                    first(channel) = (starts(1) - 1) / rate;
                    last(channel) = (stops(end) - 1) / rate;
                    minWidth(channel) = min(widths);
                    maxWidth(channel) = max(widths);
                end
            end
            peak = max(double(output), [], 1).';
            area = sum(double(output), 1).' ./ rate;
            metricsTable = table(channelNames(:), count, first, last, high, ...
                minWidth, maxWidth, peak, area, 'VariableNames', ...
                {'Channel','PulseCount','FirstOnsetSeconds','LastOffsetSeconds', ...
                 'TotalHighSeconds','MinPulseSeconds','MaxPulseSeconds', ...
                 'PeakValue','AreaValueSeconds'});
        end

        function value = defaultAnalogWaveforms()
            entry = struct( ...
                'waveform_type', 'Step', ...
                'table_helper', 'Constant', ...
                'timing_mode', 'Follow DO', ...
                'delay_seconds', 0, ...
                'duration_seconds', 1, ...
                'point_times_seconds', [0 0 0.1 0.1 1], ...
                'point_values_volts', [0 1 1 0 0], ...
                'repeat_count', 1, ...
                'points_are_expanded', false, ...
                'cycle_on_seconds', 0.1, ...
                'cycle_off_seconds', 0.9, ...
                'off_voltage', 0, ...
                'step_voltages', 1, ...
                'step_durations_seconds', zeros(1, 0), ...
                'pulse_high_voltage', 1, ...
                'pulse_low_voltage', 0, ...
                'pulse_width_seconds', 0.1, ...
                'pulse_period_seconds', 1, ...
                'custom_onsets_seconds', zeros(1, 0), ...
                'custom_durations_seconds', zeros(1, 0), ...
                'custom_voltages', zeros(1, 0));
            value = struct('Laser405', entry, 'Laser445', entry);
        end

        function points = expandDigitalOnOff(onSeconds, offSeconds, cycles)
            zoulab.StimulusWaveformCompiler.validateCycleDefinition( ...
                onSeconds, offSeconds, cycles, 'DO');
            cycleSeconds = onSeconds + offSeconds;
            points = zeros(5 * cycles, 2);
            for cycleIndex = 1:cycles
                startTime = (cycleIndex - 1) * cycleSeconds;
                onEnd = startTime + onSeconds;
                cycleEnd = startTime + cycleSeconds;
                rows = (cycleIndex - 1) * 5 + (1:5);
                points(rows, :) = [startTime 0; startTime 1; onEnd 1; ...
                    onEnd 0; cycleEnd 0];
            end
        end

        function points = expandAnalogPreset(preset, onSeconds, offSeconds, ...
                cycles, startVoltage, endVoltage, offVoltage)
            zoulab.StimulusWaveformCompiler.validateCycleDefinition( ...
                onSeconds, offSeconds, cycles, 'AO');
            zoulab.StimulusWaveformCompiler.validateVoltages( ...
                [startVoltage endVoltage offVoltage], 'AO preset');
            preset = string(preset);
            cycleSeconds = onSeconds + offSeconds;
            switch preset
                case "Constant"
                    template = [0 offVoltage; 0 endVoltage; ...
                        onSeconds endVoltage; onSeconds offVoltage; ...
                        cycleSeconds offVoltage];
                case "Linear"
                    template = [0 offVoltage; 0 startVoltage; ...
                        onSeconds endVoltage; onSeconds offVoltage; ...
                        cycleSeconds offVoltage];
                case "Triangle"
                    template = [0 offVoltage; 0 startVoltage; ...
                        onSeconds / 2 endVoltage; onSeconds startVoltage; ...
                        onSeconds offVoltage; cycleSeconds offVoltage];
                otherwise
                    error('ZouLab:AnalogPresetCustomRequiresManualTable', ...
                        'Custom AO uses the editable full-sequence table and is not generated.');
            end
            points = zoulab.StimulusWaveformCompiler.expandPointTemplate( ...
                template(:, 1), template(:, 2), cycles);
        end

        function points = expandPointTemplate(times, values, cycles)
            times = double(times(:));
            values = double(values(:));
            if numel(times) < 2 || numel(times) ~= numel(values) || ...
                    abs(times(1)) > 1e-12 || times(end) <= 0 || ...
                    any(diff(times) < 0)
                error('ZouLab:PointTemplateInvalid', ...
                    'A point template must start at 0 and end after 0 s.');
            end
            if ~isscalar(cycles) || ~isfinite(cycles) || cycles < 1 || ...
                    fix(cycles) ~= cycles
                error('ZouLab:PointTemplateCycleCountInvalid', ...
                    'Template cycles must be a positive integer.');
            end
            rowCount = numel(times);
            points = zeros(rowCount * cycles, 2);
            for cycleIndex = 1:cycles
                rows = (cycleIndex - 1) * rowCount + (1:rowCount);
                points(rows, 1) = times + (cycleIndex - 1) * times(end);
                points(rows, 2) = values;
            end
        end

        function validateCycleDefinition(onSeconds, offSeconds, cycles, label)
            if ~isscalar(onSeconds) || ~isfinite(onSeconds) || onSeconds < 0 || ...
                    ~isscalar(offSeconds) || ~isfinite(offSeconds) || offSeconds < 0 || ...
                    onSeconds + offSeconds <= 0
                error('ZouLab:WaveformCycleDurationInvalid', ...
                    '%s cycle ON/OFF lengths must be nonnegative and sum above 0 s.', ...
                    label);
            end
            if ~isscalar(cycles) || ~isfinite(cycles) || cycles < 1 || ...
                    fix(cycles) ~= cycles
                error('ZouLab:WaveformCycleCountInvalid', ...
                    '%s cycles must be a positive integer.', label);
            end
        end
    end

    methods (Static)
        function mask = waveformMask(time, stimulusStart, spec)
            mask = zeros(size(time));
            stimulusEnd = stimulusStart + spec.stimulus_duration_seconds;
            switch lower(char(spec.waveform_type))
                case 'points'
                    repeatCount = spec.digital_repeat_count;
                    if logical(spec.digital_points_are_expanded)
                        repeatCount = 1;
                    end
                    mask = zoulab.StimulusWaveformCompiler.sampleCyclicDigital( ...
                        time, stimulusStart, spec.digital_point_times_seconds, ...
                        spec.digital_point_values, repeatCount);
                    mask(time < stimulusStart | time >= stimulusEnd) = 0;
                case {'step','constant (line)','constant','line'}
                    mask(time >= stimulusStart & time < stimulusEnd) = 1;
                case 'pulse'
                    onsets = stimulusStart:spec.pulse_period_seconds:...
                        max(stimulusStart, stimulusEnd - eps);
                    for onset = onsets
                        mask(time >= onset & time < min(stimulusEnd, ...
                            onset + spec.pulse_width_seconds)) = 1;
                    end
                case 'custom'
                    onsets = stimulusStart + double(spec.custom_onsets_seconds(:));
                    durations = double(spec.custom_durations_seconds(:));
                    for k = 1:numel(onsets)
                        mask(time >= onsets(k) & time < min(stimulusEnd, ...
                            onsets(k) + durations(k))) = 1;
                    end
            end
        end

        function values = analogWaveform(time, cameraStart, spec)
            values = zeros(size(time));
            waveformStart = cameraStart + spec.delay_seconds;
            waveformEnd = waveformStart + spec.duration_seconds;
            switch lower(char(spec.waveform_type))
                case 'points'
                    repeatCount = spec.repeat_count;
                    if isfield(spec, 'points_are_expanded') && ...
                            logical(spec.points_are_expanded)
                        repeatCount = 1;
                    end
                    values = zoulab.StimulusWaveformCompiler.sampleCyclicPoints( ...
                        time, waveformStart, spec.point_times_seconds, ...
                        spec.point_values_volts, repeatCount);
                case {'constant (line)','constant','line'}
                    voltage = double(spec.step_voltages(1));
                    values(time >= waveformStart & time < waveformEnd) = voltage;
                case 'step'
                    voltages = double(spec.step_voltages(:).');
                    durations = double(spec.step_durations_seconds(:).');
                    if isempty(durations)
                        durations = repmat(spec.duration_seconds / numel(voltages), ...
                            size(voltages));
                    end
                    onset = waveformStart;
                    for index = 1:numel(voltages)
                        offset = onset + durations(index);
                        values(time >= onset & time < offset) = voltages(index);
                        onset = offset;
                    end
                case 'pulse'
                    inside = time >= waveformStart & time < waveformEnd;
                    values(inside) = spec.pulse_low_voltage;
                    onsets = waveformStart:spec.pulse_period_seconds:...
                        max(waveformStart, waveformEnd - eps);
                    for onset = onsets
                        pulseEnd = min(waveformEnd, ...
                            onset + spec.pulse_width_seconds);
                        values(time >= onset & time < pulseEnd) = ...
                            spec.pulse_high_voltage;
                    end
                case 'custom'
                    onsets = waveformStart + ...
                        double(spec.custom_onsets_seconds(:));
                    durations = double(spec.custom_durations_seconds(:));
                    voltages = double(spec.custom_voltages(:));
                    for index = 1:numel(onsets)
                        offset = min(waveformEnd, onsets(index) + durations(index));
                        values(time >= onsets(index) & time < offset) = ...
                            voltages(index);
                    end
            end
        end

        function validateAnalogSpec(spec, laserName)
            mustBeFinite(spec.delay_seconds);
            mustBePositive(spec.duration_seconds);
            supported = ["Points", "Step", "Constant (Line)", "Pulse", "Custom"];
            if ~any(strcmpi(string(spec.waveform_type), supported))
                error('ZouLab:AnalogWaveformTypeInvalid', ...
                    ['AO waveform for %s must be Points or a supported legacy ', ...
                     'waveform.'], laserName);
            end
            switch lower(char(spec.waveform_type))
                case 'points'
                    zoulab.StimulusWaveformCompiler.validatePointWaveform( ...
                        spec.point_times_seconds, spec.point_values_volts, ...
                        spec.repeat_count, laserName);
                case {'constant (line)','constant','line'}
                    voltages = double(spec.step_voltages(:));
                    if numel(voltages) ~= 1
                        error('ZouLab:AnalogConstantVoltageInvalid', ...
                            'AO Constant (Line) for %s requires exactly one voltage.', ...
                            laserName);
                    end
                    zoulab.StimulusWaveformCompiler.validateVoltages( ...
                        voltages, laserName);
                case 'step'
                    voltages = double(spec.step_voltages(:));
                    if isempty(voltages)
                        error('ZouLab:AnalogStepVoltageMissing', ...
                            'AO Step for %s requires at least one voltage.', laserName);
                    end
                    zoulab.StimulusWaveformCompiler.validateVoltages( ...
                        voltages, laserName);
                    durations = double(spec.step_durations_seconds(:));
                    if ~isempty(durations)
                        if numel(durations) ~= numel(voltages) || ...
                                any(~isfinite(durations)) || any(durations <= 0)
                            error('ZouLab:AnalogStepDurationInvalid', ...
                                ['AO Step durations for %s must be empty or contain ', ...
                                 'one positive duration per voltage.'], laserName);
                        end
                        tolerance = max(1e-9, spec.duration_seconds * 1e-9);
                        if abs(sum(durations) - spec.duration_seconds) > tolerance
                            error('ZouLab:AnalogStepDurationMismatch', ...
                                ['AO Step durations for %s sum to %.9g s but AO ', ...
                                 'duration is %.9g s.'], laserName, ...
                                sum(durations), spec.duration_seconds);
                        end
                    end
                case 'pulse'
                    zoulab.StimulusWaveformCompiler.validateVoltages( ...
                        [spec.pulse_low_voltage; spec.pulse_high_voltage], laserName);
                    mustBePositive(spec.pulse_width_seconds);
                    mustBePositive(spec.pulse_period_seconds);
                    if spec.pulse_width_seconds > spec.pulse_period_seconds
                        error('ZouLab:AnalogPulseWidthInvalid', ...
                            'AO pulse width for %s cannot exceed its period.', laserName);
                    end
                case 'custom'
                    onsets = double(spec.custom_onsets_seconds(:));
                    durations = double(spec.custom_durations_seconds(:));
                    voltages = double(spec.custom_voltages(:));
                    if isempty(onsets) || numel(onsets) ~= numel(durations) || ...
                            numel(onsets) ~= numel(voltages) || ...
                            any(~isfinite(onsets)) || any(onsets < 0) || ...
                            any(~isfinite(durations)) || any(durations <= 0) || ...
                            any(onsets + durations > spec.duration_seconds + 1e-12)
                        error('ZouLab:AnalogCustomWaveformInvalid', ...
                            ['AO Custom onset, duration, and voltage lists for %s ', ...
                             'must be equal length and lie inside AO duration.'], laserName);
                    end
                    zoulab.StimulusWaveformCompiler.validateVoltages( ...
                        voltages, laserName);
            end
        end

        function validateVoltages(values, laserName)
            if any(~isfinite(values)) || any(values < 0) || any(values > 5)
                error('ZouLab:AnalogVoltageOutsideRange', ...
                    'Every AO voltage for %s must be between 0 and 5 V.', laserName);
            end
        end

        function validatePointWaveform(times, values, repeatCount, laserName)
            times = double(times(:));
            values = double(values(:));
            if numel(times) < 2 || numel(times) ~= numel(values) || ...
                    any(~isfinite(times)) || any(~isfinite(values))
                error('ZouLab:AnalogPointTableInvalid', ...
                    'AO point table for %s requires at least two finite [time,value] rows.', ...
                    laserName);
            end
            if abs(times(1)) > 1e-12 || times(end) <= 0 || any(diff(times) < 0)
                error('ZouLab:AnalogPointTimeInvalid', ...
                    ['AO point times for %s must start at 0, be nondecreasing, ', ...
                     'and end after 0 s.'], laserName);
            end
            zoulab.StimulusWaveformCompiler.validateVoltages(values, laserName);
            if ~isscalar(repeatCount) || ~isfinite(repeatCount) || ...
                    repeatCount < 1 || fix(repeatCount) ~= repeatCount
                error('ZouLab:AnalogRepeatCountInvalid', ...
                    'AO cycle count for %s must be a positive integer.', laserName);
            end
            if abs(values(end) - values(1)) > 1e-12
                error('ZouLab:AnalogCycleDiscontinuous', ...
                    ['AO point table for %s is cyclic: its final voltage must ', ...
                     'equal its starting voltage.'], laserName);
            end
        end

        function validateDigitalPointWaveform(times, values, repeatCount)
            times = double(times(:));
            values = double(values(:));
            if numel(times) < 2 || numel(times) ~= numel(values) || ...
                    any(~isfinite(times)) || any(~isfinite(values))
                error('ZouLab:DigitalPointTableInvalid', ...
                    'Laser DO point table requires at least two finite [time,state] rows.');
            end
            if abs(times(1)) > 1e-12 || times(end) <= 0 || any(diff(times) < 0)
                error('ZouLab:DigitalPointTimeInvalid', ...
                    ['Laser DO point times must start at 0, be nondecreasing, ', ...
                     'and end after 0 s.']);
            end
            if any(values ~= 0 & values ~= 1)
                error('ZouLab:DigitalPointStateInvalid', ...
                    'Every Laser DO state must be exactly 0 or 1.');
            end
            if ~isscalar(repeatCount) || ~isfinite(repeatCount) || ...
                    repeatCount < 1 || fix(repeatCount) ~= repeatCount
                error('ZouLab:DigitalRepeatCountInvalid', ...
                    'Laser DO cycle count must be a positive integer.');
            end
            if values(end) ~= values(1)
                error('ZouLab:DigitalCycleDiscontinuous', ...
                    ['Laser DO table is cyclic: its final state must equal ', ...
                     'its starting state.']);
            end
        end

        function output = sampleCyclicPoints(time, startTime, times, values, repeatCount)
            times = double(times(:));
            values = double(values(:));
            zoulab.StimulusWaveformCompiler.validatePointWaveform( ...
                times, values, repeatCount, 'point waveform');
            cycleDuration = times(end);
            totalDuration = cycleDuration * repeatCount;
            output = zeros(size(time));
            active = time >= startTime & time < startTime + totalDuration;
            local = mod(time(active) - startTime, cycleDuration);
            sampled = zeros(size(local));
            % Iterate over the small breakpoint template, not over every DAQ
            % sample. Duplicate-time rows form an instantaneous vertical edge:
            % the zero-duration segment is skipped and the following segment
            % supplies the post-edge value.
            for pointIndex = 1:numel(times) - 1
                leftTime = times(pointIndex);
                rightTime = times(pointIndex + 1);
                if rightTime <= leftTime
                    continue;
                end
                segment = local >= leftTime & local < rightTime;
                fraction = (local(segment) - leftTime) ./ ...
                    (rightTime - leftTime);
                sampled(segment) = values(pointIndex) + fraction .* ...
                    (values(pointIndex + 1) - values(pointIndex));
            end
            output(active) = sampled;
        end

        function output = sampleCyclicDigital(time, startTime, times, values, repeatCount)
            times = double(times(:));
            values = double(values(:));
            zoulab.StimulusWaveformCompiler.validateDigitalPointWaveform( ...
                times, values, repeatCount);
            cycleDuration = times(end);
            totalDuration = cycleDuration * repeatCount;
            output = zeros(size(time));
            active = time >= startTime & time < startTime + totalDuration;
            local = mod(time(active) - startTime, cycleDuration);
            sampled = zeros(size(local));
            for pointIndex = 1:numel(times) - 1
                leftTime = times(pointIndex);
                rightTime = times(pointIndex + 1);
                if rightTime <= leftTime
                    continue;
                end
                segment = local >= leftTime & local < rightTime;
                sampled(segment) = values(pointIndex);
            end
            output(active) = sampled;
        end

        function [points, repeatCount] = legacyDigitalToPoints(spec)
            waveformType = string(spec.waveform_type);
            duration = max(eps, double(spec.stimulus_duration_seconds));
            repeatCount = 1;
            switch lower(char(waveformType))
                case 'pulse'
                    period = min(duration, double(spec.pulse_period_seconds));
                    width = min(period, double(spec.pulse_width_seconds));
                    points = [0 0; 0 1; width 1; width 0; period 0];
                    repeatCount = max(1, ceil(duration / period - 1e-12));
                case 'custom'
                    onsets = double(spec.custom_onsets_seconds(:));
                    widths = double(spec.custom_durations_seconds(:));
                    points = [0 0];
                    for index = 1:numel(onsets)
                        points(end + 1, :) = [onsets(index) 0]; %#ok<AGROW>
                        points(end + 1, :) = [onsets(index) 1]; %#ok<AGROW>
                        points(end + 1, :) = ...
                            [min(duration, onsets(index) + widths(index)) 1]; %#ok<AGROW>
                        points(end + 1, :) = ...
                            [min(duration, onsets(index) + widths(index)) 0]; %#ok<AGROW>
                    end
                    points(end + 1, :) = [duration 0]; %#ok<AGROW>
                    points = sortrows(points, 1, 'ascend');
                otherwise
                    points = [0 0; 0 1; duration 1; duration 0];
            end
            zoulab.StimulusWaveformCompiler.validateDigitalPointWaveform( ...
                points(:, 1), points(:, 2), repeatCount);
        end

        function [points, repeatCount] = legacyAnalogToPoints(spec)
            spec = zoulab.StimulusWaveformCompiler.mergeStruct( ...
                zoulab.StimulusWaveformCompiler.defaultAnalogWaveforms().Laser405, ...
                spec);
            repeatCount = 1;
            duration = double(spec.duration_seconds);
            switch lower(char(spec.waveform_type))
                case 'points'
                    points = [double(spec.point_times_seconds(:)), ...
                        double(spec.point_values_volts(:))];
                    repeatCount = double(spec.repeat_count);
                case {'constant (line)','constant','line'}
                    value = double(spec.step_voltages(1));
                    points = [0 value; duration value];
                case 'pulse'
                    low = double(spec.pulse_low_voltage);
                    high = double(spec.pulse_high_voltage);
                    width = min(duration, double(spec.pulse_width_seconds));
                    period = min(duration, double(spec.pulse_period_seconds));
                    points = [0 low; 0 high; width high; width low; period low];
                    repeatCount = max(1, floor(duration / period + 1e-9));
                case 'step'
                    voltages = double(spec.step_voltages(:).');
                    durations = double(spec.step_durations_seconds(:).');
                    if isempty(durations)
                        durations = repmat(duration / numel(voltages), ...
                            size(voltages));
                    end
                    points = [0 voltages(1)];
                    elapsed = 0;
                    for index = 1:numel(voltages)
                        if index > 1
                            points(end + 1, :) = [elapsed voltages(index)]; %#ok<AGROW>
                        end
                        elapsed = elapsed + durations(index);
                        points(end + 1, :) = [elapsed voltages(index)]; %#ok<AGROW>
                    end
                    if points(end, 2) ~= points(1, 2)
                        points(end + 1, :) = [elapsed points(1, 2)]; %#ok<AGROW>
                    end
                otherwise
                    onsets = double(spec.custom_onsets_seconds(:));
                    durations = double(spec.custom_durations_seconds(:));
                    volts = double(spec.custom_voltages(:));
                    points = [0 0];
                    for index = 1:numel(onsets)
                        points(end + 1, :) = [onsets(index) 0]; %#ok<AGROW>
                        points(end + 1, :) = [onsets(index) volts(index)]; %#ok<AGROW>
                        points(end + 1, :) = [onsets(index) + durations(index) volts(index)]; %#ok<AGROW>
                        points(end + 1, :) = [onsets(index) + durations(index) 0]; %#ok<AGROW>
                    end
                    points(end + 1, :) = [duration 0]; %#ok<AGROW>
            end
            zoulab.StimulusWaveformCompiler.validatePointWaveform( ...
                points(:, 1), points(:, 2), repeatCount, 'legacy migration');
        end

        function spec = analogSpecFor(allSpecs, name)
            field = char(string(name));
            if ~isfield(allSpecs, field)
                error('ZouLab:AnalogWaveformMissing', ...
                    'AO waveform configuration is missing %s.', name);
            end
            spec = allSpecs.(field);
        end

        function volts = imagingVoltage(allValues, name)
            field = char(string(name));
            if isstruct(allValues) && isfield(allValues, field)
                volts = double(allValues.(field));
            else
                volts = 0;
            end
        end

        function output = mergeStruct(defaults, incoming)
            output = defaults;
            names = fieldnames(incoming);
            for index = 1:numel(names)
                output.(names{index}) = incoming.(names{index});
            end
        end

        function output = addPulse(output, channelNames, name, onset, width, rate, enabled)
            if ~enabled
                return;
            end
            output = zoulab.StimulusWaveformCompiler.addWindow(output, ...
                channelNames, name, onset, onset + width, rate, true);
        end

        function output = addWindow(output, channelNames, name, onset, offset, rate, enabled)
            if ~enabled
                return;
            end
            index = find(channelNames == name, 1);
            if isempty(index)
                return;
            end
            first = max(1, floor(onset * rate) + 1);
            last = min(size(output, 1), max(first, ceil(offset * rate)));
            output(first:last, index) = 1;
        end
    end
end
