classdef LedFlickerController < handle
    %LEDFLICKERCONTROLLER Own the DAQ-driven LED visual-stimulus plan.

    properties (SetAccess = private)
        Spec struct
        Armed logical = false
        State string = "OFF"
    end

    methods
        function obj = LedFlickerController()
            obj.Spec = obj.defaultSpec();
        end

        function configure(obj, spec, logger)
            spec = obj.normalizeSpec(spec);
            obj.validateSpec(spec);
            obj.Spec = spec;
            logger.log('SUCCESS', 'LED_FLICKER_CONFIGURATION_VALIDATED', ...
                ['DelaySeconds=%.6g | DurationSeconds=%.6g | ', ...
                 'HzPerVolt=%.6g | DOPoints=%s | AOPointsHzVolts=%s'], ...
                spec.delay_seconds, obj.requiredWindowSeconds(), ...
                spec.hz_per_volt, mat2str(spec.do_points, 8), ...
                mat2str(spec.ao_points, 8));
        end

        function arm(obj, logger)
            obj.Armed = true;
            obj.State = "ARMED";
            logger.log('SUCCESS', 'LED_FLICKER_ARMED', ...
                ['DAQDriven=1 | CameraTrigger=single_START_then_free_run | ', ...
                 'FrameLimit=finite | PhysicalBinCrop=0 | ', ...
                 'TimingBasis=shared_finite_DAQ_output_matrix | ', ...
                 'VisualStampUsed=0']);
        end

        function disarm(obj, logger, reason)
            if nargin < 3
                reason = 'unspecified';
            end
            wasArmed = obj.Armed;
            obj.Armed = false;
            obj.State = "OFF";
            logger.log('INFO', 'LED_FLICKER_DISARMED', ...
                'Reason=%s | WasArmed=%d | HardwareCommandIssued=0', ...
                reason, wasArmed);
        end

        function secondsValue = requiredWindowSeconds(obj)
            secondsValue = obj.Spec.delay_seconds + max( ...
                obj.Spec.do_points(end, 1), obj.Spec.ao_points(end, 1));
        end

        function value = snapshot(obj)
            value = struct('state', char(obj.State), 'armed', obj.Armed, ...
                'spec', obj.Spec);
        end
    end

    methods (Static)
        function spec = defaultSpec()
            spec = struct( ...
                'delay_seconds', 0, ...
                'hz_per_volt', 24, ...
                'do_points', [0 0; 0 1; 1 1; 1 0], ...
                'ao_points', [0 0 0; 0 60 2.5; 1 60 2.5; 1 0 0]);
        end

        function points = generatePreset(onSeconds, offSeconds, cycles, ...
                frequencyHz, hzPerVolt)
            validateattributes(onSeconds, {'numeric'}, ...
                {'scalar','finite','positive'});
            validateattributes(offSeconds, {'numeric'}, ...
                {'scalar','finite','nonnegative'});
            validateattributes(cycles, {'numeric'}, ...
                {'scalar','finite','integer','positive'});
            validateattributes(frequencyHz, {'numeric'}, ...
                {'scalar','finite','>=',0,'<=',5 * hzPerVolt});
            doPoints = zoulab.StimulusWaveformCompiler.expandDigitalOnOff( ...
                onSeconds, offSeconds, cycles);
            voltage = frequencyHz / hzPerVolt;
            aoPoints = zoulab.StimulusWaveformCompiler.expandAnalogPreset( ...
                'Constant', onSeconds, offSeconds, cycles, ...
                0, voltage, 0);
            points = struct('do_points', doPoints, ...
                'ao_points', [aoPoints(:, 1), ...
                aoPoints(:, 2) * hzPerVolt, aoPoints(:, 2)]);
        end

        function value = hzToVoltage(hz, hzPerVolt)
            value = double(hz) ./ double(hzPerVolt);
        end

        function value = voltageToHz(volts, hzPerVolt)
            value = double(volts) .* double(hzPerVolt);
        end
    end

    methods (Access = private)
        function spec = normalizeSpec(obj, incoming)
            spec = obj.Spec;
            names = fieldnames(incoming);
            for index = 1:numel(names)
                spec.(names{index}) = incoming.(names{index});
            end
            spec.delay_seconds = double(spec.delay_seconds);
            spec.hz_per_volt = double(spec.hz_per_volt);
            spec.do_points = double(spec.do_points);
            spec.ao_points = double(spec.ao_points);
        end

        function validateSpec(~, spec)
            validateattributes(spec.delay_seconds, {'numeric'}, ...
                {'scalar','finite','nonnegative'});
            validateattributes(spec.hz_per_volt, {'numeric'}, ...
                {'scalar','finite','positive'});
            if size(spec.do_points, 2) ~= 2 || isempty(spec.do_points)
                error('ZouLab:LedFlickerDoTableInvalid', ...
                    'LED DO table must contain Time and Enable columns.');
            end
            if size(spec.ao_points, 2) ~= 3 || isempty(spec.ao_points)
                error('ZouLab:LedFlickerAoTableInvalid', ...
                    'LED AO table must contain Time, Frequency, and Voltage columns.');
            end
            zoulab.StimulusWaveformCompiler.validateDigitalPointWaveform( ...
                spec.do_points(:, 1), spec.do_points(:, 2), 1);
            zoulab.StimulusWaveformCompiler.validatePointWaveform( ...
                spec.ao_points(:, 1), spec.ao_points(:, 3), 1, ...
                'LED flicker AO');
            if any(spec.ao_points(:, 2) < 0 | spec.ao_points(:, 2) > 120) || ...
                    any(spec.ao_points(:, 3) < 0 | spec.ao_points(:, 3) > 5)
                error('ZouLab:LedFlickerAoRangeInvalid', ...
                    'LED frequency must be 0-120 Hz and AO voltage 0-5 V.');
            end
            expectedHz = spec.ao_points(:, 3) .* spec.hz_per_volt;
            if any(abs(expectedHz - spec.ao_points(:, 2)) > 1e-9)
                error('ZouLab:LedFlickerAoColumnsInconsistent', ...
                    'Each LED AO row must satisfy Frequency = Voltage x HzPerVolt.');
            end
        end
    end
end
