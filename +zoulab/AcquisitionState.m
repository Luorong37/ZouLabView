classdef AcquisitionState < handle
    %ACQUISITIONSTATE Single owner of capture, conversion and close lifecycle.
    % Status is a reported result/phase, not a substitute for resource ownership:
    % conversion may be queued before capture cleanup releases its controls.
    properties (SetAccess = private)
        AcquisitionRunning logical = false
        AcquisitionStopRequested logical = false
        ConversionRunning logical = false
        ConversionStopRequested logical = false
        Closing logical = false
        EmergencyClosing logical = false
        CloseAfterAcquisition logical = false
        Status string = "IDLE"
    end

    properties
        AcquisitionCycleIndex double = 0
        AcquisitionCycleResults struct = struct('cycle', {}, 'status', {}, ...
            'started_at', {}, 'completed_at', {}, 'files', {})
        FrozenAcquisitionPlan struct = struct()
    end

    methods
        function beginCapture(obj)
            obj.AcquisitionRunning = true;
            obj.AcquisitionStopRequested = false;
            obj.ConversionStopRequested = false;
            obj.AcquisitionCycleIndex = 0;
            obj.AcquisitionCycleResults = struct('cycle', {}, 'status', {}, ...
                'started_at', {}, 'completed_at', {}, 'files', {});
        end

        function finishCapture(obj)
            obj.AcquisitionRunning = false;
        end

        function requestCaptureStop(obj)
            obj.AcquisitionStopRequested = true;
        end

        function beginConversion(obj)
            obj.ConversionRunning = true;
        end

        function finishConversion(obj)
            obj.ConversionRunning = false;
        end

        function requestConversionStop(obj)
            obj.ConversionStopRequested = true;
        end

        function closeAfterCapture(obj)
            obj.CloseAfterAcquisition = true;
        end

        function beginClose(obj)
            obj.Closing = true;
        end

        function forceClose(obj)
            obj.EmergencyClosing = true;
            obj.Closing = true;
        end

        function setStatus(obj, value)
            obj.Status = string(value);
        end
    end

    methods (Static)
        function enabled = controlAvailability(context)
            % Preserve the existing armed-mode and standalone-preview policy.
            c = context;
            editable = c.identityReady && ~c.locked;
            anyArmed = c.visualArmed || c.lightArmed || c.ledArmed;
            enabled.AcquisitionStartButton = editable && ...
                ~c.visualPreviewRunning && ~c.conversionRunning;
            enabled.AcquisitionModeDropDown = editable && ~anyArmed;
            enabled.RecordDurationField = editable && ~anyArmed && ...
                c.mode == "Record" && c.recordLengthSource == "Custom";
            enabled.RecordLengthSourceDropDown = editable && c.mode == "Record" && ...
                ~c.visualArmed && ~c.ledArmed;
            enabled.RecordTiffCheckBox = editable && c.mode == "Record";
            enabled.TLIntervalField = editable && ~anyArmed && c.mode == "Time Lapse";
            enabled.TLPointsField = enabled.TLIntervalField;
            enabled.VisualArmButton = editable && ~anyArmed && c.visualScreenReady;
            enabled.VisualDisarmButton = editable && c.visualArmed;
            enabled.VisualPlayButton = editable && ~c.visualArmed && ~c.ledArmed && ...
                ~c.visualPreviewRunning && c.visualScreenReady;
            enabled.LightStimArmButton = editable && ~anyArmed;
            enabled.LightStimDisarmButton = editable && c.lightArmed;
            enabled.LedFlickerArmButton = editable && ~anyArmed;
            enabled.LedFlickerDisarmButton = editable && c.ledArmed;
        end
    end
end
