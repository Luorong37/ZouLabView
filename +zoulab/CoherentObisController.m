classdef CoherentObisController < handle
    %COHERENTOBISCONTROLLER Safe serial controller for one Coherent OBIS.

    properties
        Port string = ""
        SimulationMode logical = false
        TimeoutSeconds double = 2
    end

    properties (SetAccess = private)
        Connected logical = false
        Serial = []
        WavelengthNm double = NaN
        RatedPowerMilliwatts double = NaN
        PowerMilliwatts double = NaN
        EmissionEnabled logical = false
        ModulationMode string = "unknown"
        OwnedEmission logical = false
        LastError string = ""
    end

    methods
        function obj = CoherentObisController(port, simulationMode)
            if nargin >= 1
                obj.Port = string(port);
            end
            if nargin >= 2
                obj.SimulationMode = logical(simulationMode);
            end
        end

        function info = connect(obj, logger)
            if obj.Connected
                info = obj.status();
                return;
            end
            try
                if obj.SimulationMode
                    if contains(obj.Port, '5')
                        obj.WavelengthNm = 446;
                        obj.RatedPowerMilliwatts = 75;
                    else
                        obj.WavelengthNm = 406;
                        obj.RatedPowerMilliwatts = 50;
                    end
                    obj.PowerMilliwatts = 0;
                    obj.EmissionEnabled = false;
                    obj.ModulationMode = "SIM";
                else
                    obj.Serial = serialport(obj.Port, 9600, 'Timeout', obj.TimeoutSeconds);
                    configureTerminator(obj.Serial, 'CR');
                    flush(obj.Serial);
                    obj.WavelengthNm = str2double(obj.query('syst:inf:wav?'));
                    obj.RatedPowerMilliwatts = 1000 * str2double(obj.query('syst:inf:pow?'));
                    obj.PowerMilliwatts = 1000 * str2double(obj.query('sour:pow:lev?'));
                    stateText = upper(strtrim(obj.query('sour:am:stat ?')));
                    obj.EmissionEnabled = contains(stateText, 'ON');
                end
                obj.Connected = true;
                obj.LastError = "";
                logger.log('SUCCESS', 'COHERENT_OBIS_CONNECT_SUCCESS', ...
                    ['Port=%s | WavelengthNm=%.6g | RatedPowerMilliwatts=%.6g | ', ...
                     'PowerMilliwatts=%.6g | Emission=%d | ConnectionMutatedHardware=0'], ...
                    obj.Port, obj.WavelengthNm, obj.RatedPowerMilliwatts, ...
                    obj.PowerMilliwatts, obj.EmissionEnabled);
                info = obj.status();
            catch ME
                obj.LastError = string(ME.message);
                obj.releaseSerial();
                logger.logException('COHERENT_OBIS_CONNECT_FAILED', ME);
                rethrow(ME);
            end
        end

        function actual = setPowerMilliwatts(obj, requested, logger)
            obj.assertConnected();
            requested = double(requested);
            if requested < 0 || requested > obj.RatedPowerMilliwatts
                error('ZouLab:ObisPowerOutsideRange', ...
                    'Requested %.4g mW; valid range is 0 to %.4g mW.', ...
                    requested, obj.RatedPowerMilliwatts);
            end
            if obj.SimulationMode
                actual = requested;
            else
                obj.command(sprintf('sour:pow:lev:imm:ampl %.9g', requested / 1000));
                actual = 1000 * str2double(obj.query('sour:pow:lev?'));
            end
            obj.PowerMilliwatts = actual;
            logger.log('SUCCESS', 'COHERENT_OBIS_POWER_CONFIRMED', ...
                'Port=%s | RequestedMilliwatts=%.6g | ActualMilliwatts=%.6g', ...
                obj.Port, requested, actual);
        end

        function actual = setManualState(obj, turnOn, logger)
            obj.assertConnected();
            turnOn = logical(turnOn);
            if obj.SimulationMode
                actual = turnOn;
                if turnOn
                    obj.ModulationMode = "CWP";
                else
                    obj.ModulationMode = "OFF";
                end
            else
                if turnOn
                    obj.command('sour:am:int CWP');
                    obj.ModulationMode = "CWP";
                end
                obj.command("sour:am:stat " + upper(string(obj.onOff(turnOn))));
                response = upper(strtrim(obj.query('sour:am:stat ?')));
                actual = contains(response, 'ON');
            end
            if actual ~= turnOn
                error('ZouLab:ObisStateMismatch', ...
                    'OBIS %s requested %s but reported %s.', obj.Port, ...
                    obj.onOff(turnOn), obj.onOff(actual));
            end
            obj.EmissionEnabled = actual;
            obj.OwnedEmission = actual;
            if ~actual
                obj.ModulationMode = "OFF";
            end
            logger.log('SUCCESS', 'COHERENT_OBIS_MANUAL_STATE_CONFIRMED', ...
                'Port=%s | Requested=%s | Actual=%s | Mode=%s', ...
                obj.Port, obj.onOff(turnOn), obj.onOff(actual), obj.ModulationMode);
        end

        function armDigital(obj, logger)
            obj.assertConnected();
            if ~obj.SimulationMode
                obj.command('sour:am:ext DIGITAL');
                obj.command('sour:am:stat ON');
            end
            obj.ModulationMode = "DIGITAL";
            obj.EmissionEnabled = true;
            obj.OwnedEmission = true;
            logger.log('SUCCESS', 'COHERENT_OBIS_DIGITAL_ARMED', ...
                ['Port=%s | PowerMilliwatts=%.6g | EmissionMaster=ON | ', ...
                 'OpticalStateControlledByExternalTTL=1'], ...
                obj.Port, obj.PowerMilliwatts);
        end

        function armMixed(obj, logger)
            obj.assertConnected();
            if ~obj.SimulationMode
                obj.command('sour:am:ext MIXED');
                obj.command('sour:am:stat ON');
            end
            obj.ModulationMode = "MIXED";
            obj.EmissionEnabled = true;
            obj.OwnedEmission = true;
            logger.log('SUCCESS', 'COHERENT_OBIS_MIXED_ARMED', ...
                ['Port=%s | EmissionMaster=ON | ExternalDigitalGate=1 | ', ...
                 'ExternalAnalogIntensity=1 | OpticalFeedbackAvailable=0'], ...
                obj.Port);
        end

        function disarm(obj, logger)
            if ~obj.Connected || ~obj.OwnedEmission
                return;
            end
            if ~obj.SimulationMode
                obj.command('sour:am:stat OFF');
            end
            obj.EmissionEnabled = false;
            obj.OwnedEmission = false;
            logger.log('INFO', 'COHERENT_OBIS_DISARMED', ...
                'Port=%s | EmissionMaster=OFF', obj.Port);
        end

        function info = status(obj)
            info = struct('port', char(obj.Port), 'connected', obj.Connected, ...
                'wavelength_nm', obj.WavelengthNm, ...
                'rated_power_mw', obj.RatedPowerMilliwatts, ...
                'power_mw', obj.PowerMilliwatts, ...
                'emission_enabled', obj.EmissionEnabled, ...
                'modulation_mode', char(obj.ModulationMode), ...
                'last_error', char(obj.LastError));
        end

        function disconnect(obj, logger)
            if obj.OwnedEmission
                try
                    obj.disarm(logger);
                catch ME
                    logger.logException('COHERENT_OBIS_SAFE_OFF_FAILED', ME);
                end
            end
            wasConnected = obj.Connected;
            obj.releaseSerial();
            if wasConnected
                logger.log('INFO', 'COHERENT_OBIS_DISCONNECTED', ...
                    'Port=%s | OwnedEmissionReturnedOff=1', obj.Port);
            end
        end

        function delete(obj)
            obj.releaseSerial();
        end
    end

    methods (Access = private)
        function response = query(obj, commandText)
            writeline(obj.Serial, commandText);
            response = string(strtrim(readline(obj.Serial)));
            acknowledgement = string(strtrim(readline(obj.Serial)));
            if ~strcmpi(acknowledgement, 'OK')
                error('ZouLab:ObisQueryFailed', ...
                    'OBIS %s query %s returned %s.', obj.Port, commandText, acknowledgement);
            end
        end

        function command(obj, commandText)
            writeline(obj.Serial, commandText);
            acknowledgement = string(strtrim(readline(obj.Serial)));
            if ~strcmpi(acknowledgement, 'OK')
                error('ZouLab:ObisCommandFailed', ...
                    'OBIS %s command returned %s.', obj.Port, acknowledgement);
            end
        end

        function assertConnected(obj)
            if ~obj.Connected
                error('ZouLab:ObisNotConnected', ...
                    'Connect the Coherent OBIS on %s first.', obj.Port);
            end
        end

        function releaseSerial(obj)
            obj.Serial = [];
            obj.Connected = false;
        end

        function value = onOff(~, state)
            if state
                value = 'ON';
            else
                value = 'OFF';
            end
        end
    end
end
