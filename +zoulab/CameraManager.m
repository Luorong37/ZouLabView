classdef CameraManager < handle
    %CAMERAMANAGER Owns and configures only this app's Hamamatsu objects.

    properties
        Adaptor string = "hamamatsu"
        VideoFormats string = ["MONO16_2304x2304_Fast", "MONO16_2304x2304_Fast"]
        ROIs cell = {[896 896 512 512], [896 896 512 512]}
        ExposureTimes double = [2.4931e-3 2.4931e-3]
        Bins double = [1 1]
        SimulationMode logical = false
        PreviewBufferFlushFrames double = 100
    end

    properties (SetAccess = private)
        VideoObjects cell = {[], []}
        SourceObjects cell = {[], []}
        Connected logical = false(1, 2)
        LogicalNames string = ["Camera 1 - USB", "Camera 2 - CXP"]
        % Rig-specific identity is loaded from config/rig_wiring.json.
        % Public source deliberately contains no laboratory serial numbers.
        Serials string = ["", ""]
        BusTokens string = ["", ""]
        DeviceNames string = ["", ""]
        PreviewFlushErrors double = [0 0]
    end

    methods
        function connect(obj, cameraIndices, logger)
            cameraIndices = unique(double(cameraIndices(:).'));
            if obj.SimulationMode
                obj.Connected(cameraIndices) = true;
                logger.log('INFO', 'CAMERA_SIMULATION_CONNECTED', 'Cameras=%s', mat2str(cameraIndices));
                return;
            end

            existing = imaqfind('AdaptorName', char(obj.Adaptor));
            owned = obj.VideoObjects(~cellfun(@isempty, obj.VideoObjects));
            foreign = existing;
            for k = 1:numel(owned)
                foreign(foreign == owned{k}) = [];
            end
            if ~isempty(foreign)
                error('ZouLab:ForeignCameraObject', ...
                    ['Existing Hamamatsu objects belong to another script/app. ', ...
                     'Close that owner first; this app will not call imaqreset.']);
            end

            info = imaqhwinfo(char(obj.Adaptor));
            deviceInfo = info.DeviceInfo;
            names = string({deviceInfo.DeviceName});
            for k = 1:numel(deviceInfo)
                logger.log('INFO', 'CAMERA_DEVICE_DETECTED', ...
                    'ListIndex=%d | DeviceID=%s | Name=%s', k, ...
                    string(deviceInfo(k).DeviceID), names(k));
            end

            for cameraIndex = cameraIndices
                if obj.Connected(cameraIndex)
                    continue;
                end
                if strlength(strtrim(obj.Serials(cameraIndex))) == 0 || ...
                        strlength(strtrim(obj.BusTokens(cameraIndex))) == 0
                    error('ZouLab:CameraIdentityNotConfigured', ...
                        ['Camera %d identity is not configured. Set camera.serials ', ...
                         'and camera.bus_tokens in the private rig_wiring.json.'], ...
                        cameraIndex);
                end
                match = find(contains(names, obj.Serials(cameraIndex), 'IgnoreCase', true) & ...
                    contains(names, obj.BusTokens(cameraIndex), 'IgnoreCase', true), 1);
                if isempty(match)
                    error('ZouLab:CameraNotFound', ...
                        '%s not found (serial %s, bus %s).', obj.LogicalNames(cameraIndex), ...
                        obj.Serials(cameraIndex), obj.BusTokens(cameraIndex));
                end
                deviceID = deviceInfo(match).DeviceID;
                requestedFormat = obj.VideoFormats(cameraIndex);
                requestedROI = obj.ROIs{cameraIndex};
                requestedExposure = obj.ExposureTimes(cameraIndex);
                formats = string(deviceInfo(match).SupportedFormats);
                if ~any(formats == requestedFormat)
                    error('ZouLab:FormatUnsupported', '%s does not support %s.', ...
                        obj.LogicalNames(cameraIndex), requestedFormat);
                end
                vid = videoinput(char(obj.Adaptor), deviceID, char(requestedFormat));
                vid.ROIPosition = requestedROI;
                vid.PreviewFullBitDepth = 'on';
                vid.LoggingMode = 'memory';
                vid.FramesPerTrigger = Inf;
                vid.TriggerRepeat = 0;
                triggerconfig(vid, 'immediate');
                src = getselectedsource(vid);
                src.TriggerSource = 'internal';
                src.ExposureTime = requestedExposure;
                obj.VideoObjects{cameraIndex} = vid;
                obj.SourceObjects{cameraIndex} = src;
                obj.DeviceNames(cameraIndex) = names(match);
                obj.Connected(cameraIndex) = true;
                logger.log('SUCCESS', 'CAMERA_CONNECT_SUCCESS', ...
                    ['Camera=%d | LogicalName=%s | Serial=%s | DeviceID=%s | ', ...
                    'Format=%s | ROI=%s | Exposure=%.9g | PreviewFullBitDepth=on'], ...
                    cameraIndex, obj.LogicalNames(cameraIndex), obj.Serials(cameraIndex), ...
                    string(deviceID), requestedFormat, mat2str(requestedROI), requestedExposure);
            end
        end

        function configureExposure(obj, cameraIndices, exposure, logger)
            validateattributes(exposure, {'numeric'}, {'scalar','positive','finite'});
            for cameraIndex = cameraIndices
                oldExposure = obj.ExposureTimes(cameraIndex);
                obj.ExposureTimes(cameraIndex) = exposure;
                if obj.Connected(cameraIndex) && ~obj.SimulationMode
                    obj.SourceObjects{cameraIndex}.ExposureTime = exposure;
                end
                logger.log('INFO', 'EXPOSURE_CHANGED', ...
                    'Camera=%d | Requested=%.9g s | Previous=%.9g s | Actual=%.9g s', ...
                    cameraIndex, exposure, oldExposure, obj.actualExposure(cameraIndex));
            end
        end

        function [newROI, oldROI, oldBin] = scaleROIForBin(obj, cameraIndex, newBin)
            obj.validateBin(newBin);
            oldROI = obj.ROIs{cameraIndex};
            oldBin = obj.Bins(cameraIndex);
            newROI = round(double(oldROI) .* oldBin ./ newBin);
            newROI(3:4) = max(newROI(3:4), 1);
        end

        function configureCamera(obj, cameraIndex, exposure, roi, binFactor, logger)
            validateattributes(cameraIndex, {'numeric'}, {'scalar','integer','>=',1,'<=',2});
            validateattributes(exposure, {'numeric'}, {'scalar','positive','finite'});
            obj.validateBin(binFactor);
            obj.validateROI(roi, binFactor);
            oldBin = obj.Bins(cameraIndex);
            oldROI = obj.ROIs{cameraIndex};
            oldExposure = obj.ExposureTimes(cameraIndex);
            oldFormat = obj.VideoFormats(cameraIndex);
            newFormat = obj.formatForBin(binFactor);
            needsRebuild = obj.Connected(cameraIndex) && oldFormat ~= newFormat;

            if needsRebuild && ~obj.SimulationMode
                logger.log('ERROR', ...
                    'CAMERA_IN_PROCESS_FORMAT_REBUILD_BLOCKED', ...
                    ['Camera=%d | OldFormat=%s | NewFormat=%s | ', ...
                     'RequiredAction=restart_camera_service'], ...
                    cameraIndex, oldFormat, newFormat);
                logger.flush();
                error('ZouLab:CameraFormatRestartRequired', ...
                    ['Changing Bin changes the read-only VideoFormat. Restart ', ...
                     'the camera service with the target format instead of ', ...
                     'deleting a live Hamamatsu videoinput object.']);
            end

            obj.Bins(cameraIndex) = binFactor;
            obj.ROIs{cameraIndex} = double(roi);
            obj.ExposureTimes(cameraIndex) = exposure;
            obj.VideoFormats(cameraIndex) = newFormat;

            if needsRebuild
                obj.releaseCamera(cameraIndex, logger, 'bin_format_change');
                obj.connect(cameraIndex, logger);
            elseif obj.Connected(cameraIndex) && ~obj.SimulationMode
                vid = obj.VideoObjects{cameraIndex};
                if strcmpi(vid.Previewing, 'on')
                    stoppreview(vid);
                end
                if strcmpi(vid.Running, 'on')
                    stop(vid);
                end
                vid.ROIPosition = roi;
                obj.SourceObjects{cameraIndex}.ExposureTime = exposure;
            end

            actual = obj.getActualSettings(cameraIndex);
            logger.log('SUCCESS', 'CAMERA_SETTINGS_APPLIED', ...
                ['Camera=%d | OldBin=%d | NewBin=%d | OldROI=%s | RequestedROI=%s | ', ...
                 'ActualROI=%s | OldExposure=%.9g | RequestedExposure=%.9g | ', ...
                 'ActualExposure=%.9g | Format=%s | Rebuilt=%d'], ...
                cameraIndex, oldBin, binFactor, mat2str(oldROI), mat2str(roi), ...
                mat2str(actual.ROI), oldExposure, exposure, actual.ExposureTime, ...
                actual.VideoFormat, needsRebuild);
        end

        function startPreview(obj, cameraIndex, imageHandle, logger)
            if obj.SimulationMode
                return;
            end
            vid = obj.VideoObjects{cameraIndex};
            if strcmpi(vid.Previewing, 'on')
                stoppreview(vid);
            end
            if strcmpi(vid.Running, 'on')
                stop(vid);
            end
            obj.disablePreviewBufferDrain(vid);
            flushdata(vid);
            vid.LoggingMode = 'memory';
            vid.FramesPerTrigger = Inf;
            vid.TriggerRepeat = 0;
            vid.TriggerFrameDelay = 0;
            vid.FrameGrabInterval = 1;
            triggerconfig(vid, 'immediate');
            obj.SourceObjects{cameraIndex}.TriggerSource = 'internal';
            obj.PreviewFlushErrors(cameraIndex) = 0;
            vid.FramesAcquiredFcnCount = obj.PreviewBufferFlushFrames;
            vid.FramesAcquiredFcn = @(videoObject, ~) ...
                obj.flushPreviewBuffer(videoObject, cameraIndex, logger);
            try
                start(vid);
                preview(vid, imageHandle);
            catch ME
                obj.disablePreviewBufferDrain(vid);
                if strcmpi(vid.Previewing, 'on')
                    stoppreview(vid);
                end
                if strcmpi(vid.Running, 'on')
                    stop(vid);
                end
                if vid.FramesAvailable > 0
                    flushdata(vid);
                end
                rethrow(ME);
            end
            logger.log('INFO', 'PREVIEW_COMMAND_SUCCESS', ...
                ['Camera=%d | Previewing=%s | Running=%s | Logging=%s | ', ...
                 'StreamCounter=FramesAcquired | BufferFlushEveryFrames=%d'], ...
                cameraIndex, string(vid.Previewing), string(vid.Running), ...
                string(vid.Logging), obj.PreviewBufferFlushFrames);
        end

        function startRemotePreview(obj, cameraIndex, logger)
            % Start a UI-independent preview stream owned by a camera service.
            % The service uses peekdata to publish only the newest uint16 frame
            % and flushes obsolete preview-only frames after each publication.
            if obj.SimulationMode
                logger.log('INFO', 'REMOTE_PREVIEW_SIMULATION_STARTED', ...
                    'Camera=%d', cameraIndex);
                return;
            end
            vid = obj.VideoObjects{cameraIndex};
            if strcmpi(vid.Previewing, 'on')
                stoppreview(vid);
            end
            if strcmpi(vid.Running, 'on')
                stop(vid);
            end
            obj.disablePreviewBufferDrain(vid);
            if vid.FramesAvailable > 0
                flushdata(vid);
            end
            vid.LoggingMode = 'memory';
            vid.FramesPerTrigger = Inf;
            vid.TriggerRepeat = 0;
            vid.TriggerFrameDelay = 0;
            vid.FrameGrabInterval = 1;
            triggerconfig(vid, 'immediate');
            obj.SourceObjects{cameraIndex}.TriggerSource = 'internal';
            obj.PreviewFlushErrors(cameraIndex) = 0;
            start(vid);
            logger.log('SUCCESS', 'REMOTE_PREVIEW_STREAM_STARTED', ...
                ['Camera=%d | Running=%s | LoggingMode=%s | ', ...
                 'FrameSelection=latest_peekdata | OldPreviewFramesFlushed=1'], ...
                cameraIndex, string(vid.Running), string(vid.LoggingMode));
        end

        function [frame, metrics, available] = takeLatestPreviewFrame( ...
                obj, cameraIndex, logger)
            metrics = obj.getPreviewMetrics(cameraIndex);
            frame = zeros(0, 0, 'uint16');
            available = false;
            if obj.SimulationMode
                roi = obj.ROIs{cameraIndex};
                frame = uint16(randi([500 60000], roi(4), roi(3)));
                metrics = struct('FramesAcquired', NaN, ...
                    'FramesAvailable', 1, 'Running', "on", ...
                    'Logging', "on", 'FlushErrors', 0);
                available = true;
                return;
            end
            vid = obj.VideoObjects{cameraIndex};
            if ~strcmpi(vid.Running, 'on') || vid.FramesAvailable < 1
                return;
            end
            try
                data = peekdata(vid, 1);
                if ~isempty(data)
                    frame = uint16(reshape(data, size(data, 1), size(data, 2)));
                    available = true;
                end
                residual = double(vid.FramesAvailable);
                if residual > 0
                    flushdata(vid);
                end
                metrics = obj.getPreviewMetrics(cameraIndex);
                metrics.FramesAvailableBeforeFlush = residual;
            catch ME
                obj.PreviewFlushErrors(cameraIndex) = ...
                    obj.PreviewFlushErrors(cameraIndex) + 1;
                logger.logException(sprintf( ...
                    'CAMERA_%d_REMOTE_PREVIEW_READ_FAILED', cameraIndex), ME);
                metrics = obj.getPreviewMetrics(cameraIndex);
            end
        end

        function stopPreview(obj, cameraIndex, logger)
            if ~obj.Connected(cameraIndex) || obj.SimulationMode
                return;
            end
            vid = obj.VideoObjects{cameraIndex};
            if strcmpi(vid.Previewing, 'on')
                stoppreview(vid);
            end
            if strcmpi(vid.Running, 'on')
                stop(vid);
            end
            obj.disablePreviewBufferDrain(vid);
            framesAcquired = double(vid.FramesAcquired);
            framesAvailable = double(vid.FramesAvailable);
            if framesAvailable > 0
                flushdata(vid);
            end
            logger.log('INFO', 'CAMERA_PREVIEW_STOPPED', ...
                ['Camera=%d | Previewing=%s | Running=%s | StreamFramesAcquired=%d | ', ...
                 'ResidualFramesFlushed=%d | BufferFlushErrors=%d'], ...
                cameraIndex, string(vid.Previewing), string(vid.Running), ...
                framesAcquired, framesAvailable, obj.PreviewFlushErrors(cameraIndex));
        end

        function metrics = getPreviewMetrics(obj, cameraIndex)
            metrics = struct('FramesAcquired', NaN, 'FramesAvailable', NaN, ...
                'Running', "off", 'Logging', "off", 'FlushErrors', 0);
            if obj.SimulationMode || ~obj.Connected(cameraIndex)
                return;
            end
            vid = obj.VideoObjects{cameraIndex};
            metrics.FramesAcquired = double(vid.FramesAcquired);
            metrics.FramesAvailable = double(vid.FramesAvailable);
            metrics.Running = string(vid.Running);
            metrics.Logging = string(vid.Logging);
            metrics.FlushErrors = obj.PreviewFlushErrors(cameraIndex);
        end

        function prepareExternalAcquisition(obj, cameraIndices, framesPerTrigger, logger)
            if obj.SimulationMode
                return;
            end
            for cameraIndex = cameraIndices
                vid = obj.VideoObjects{cameraIndex};
                obj.disablePreviewBufferDrain(vid);
                if strcmpi(vid.Previewing, 'on')
                    stoppreview(vid);
                end
                if strcmpi(vid.Running, 'on')
                    stop(vid);
                end
                flushdata(vid);
                vid.FramesPerTrigger = framesPerTrigger;
                vid.TriggerRepeat = 0;
                % Preserve the validated Hamamatsu scheme from the rebuilt
                % script: the Image Acquisition trigger remains immediate,
                % while the camera source waits for an external start edge.
                triggerconfig(vid, 'immediate');
                obj.SourceObjects{cameraIndex}.TriggerSource = 'external';
                if isprop(obj.SourceObjects{cameraIndex}, 'TriggerPolarity')
                    obj.SourceObjects{cameraIndex}.TriggerPolarity = 'positive';
                end
                if isprop(obj.SourceObjects{cameraIndex}, 'TriggerMode')
                    obj.SourceObjects{cameraIndex}.TriggerMode = 'start';
                end
                obj.configureVsyncOutput(cameraIndex, logger);
                start(vid);
            end
            logger.log('INFO', 'CAMERAS_ARMED_EXTERNAL_TRIGGER', ...
                'Cameras=%s | FramesPerTrigger=%d', mat2str(cameraIndices), framesPerTrigger);
        end

        function prepareFiniteAcquisition(obj, cameraIndices, frameCounts, ...
                useExternalTrigger, logger)
            cameraIndices = unique(double(cameraIndices(:).'));
            frameCounts = double(frameCounts(:).');
            if isscalar(frameCounts)
                frameCounts = repmat(frameCounts, 1, numel(cameraIndices));
            end
            if numel(frameCounts) ~= numel(cameraIndices) || ...
                    any(frameCounts < 1) || any(mod(frameCounts, 1) ~= 0)
                error('ZouLab:FiniteFrameCountInvalid', ...
                    'Finite frame counts must provide one positive integer per camera.');
            end
            if obj.SimulationMode
                logger.log('INFO', 'FINITE_ACQUISITION_SIMULATION_PREPARED', ...
                    'Cameras=%s | FrameCounts=%s | ExternalTrigger=%d', ...
                    mat2str(cameraIndices), mat2str(frameCounts), useExternalTrigger);
                return;
            end
            for position = 1:numel(cameraIndices)
                cameraIndex = cameraIndices(position);
                vid = obj.VideoObjects{cameraIndex};
                obj.disablePreviewBufferDrain(vid);
                if strcmpi(vid.Previewing, 'on')
                    stoppreview(vid);
                end
                if strcmpi(vid.Running, 'on')
                    stop(vid);
                end
                if vid.FramesAvailable > 0
                    flushdata(vid);
                end
                vid.LoggingMode = 'memory';
                vid.FramesPerTrigger = frameCounts(position);
                vid.TriggerRepeat = 0;
                vid.TriggerFrameDelay = 0;
                vid.FrameGrabInterval = 1;
                triggerconfig(vid, 'immediate');
                if useExternalTrigger
                    obj.SourceObjects{cameraIndex}.TriggerSource = 'external';
                    if isprop(obj.SourceObjects{cameraIndex}, 'TriggerPolarity')
                        obj.SourceObjects{cameraIndex}.TriggerPolarity = 'positive';
                    end
                    if isprop(obj.SourceObjects{cameraIndex}, 'TriggerMode')
                        obj.SourceObjects{cameraIndex}.TriggerMode = 'start';
                    end
                    obj.configureVsyncOutput(cameraIndex, logger);
                else
                    obj.SourceObjects{cameraIndex}.TriggerSource = 'internal';
                end
                start(vid);
            end
            logger.log('SUCCESS', 'FINITE_ACQUISITION_PREPARED', ...
                ['Cameras=%s | FrameCounts=%s | ExternalTrigger=%d | ', ...
                 'LoggingMode=memory | FrameGrabInterval=1'], ...
                mat2str(cameraIndices), mat2str(frameCounts), useExternalTrigger);
        end

        function prepareOpenEndedAcquisition(obj, cameraIndices, ...
                useExternalTrigger, logger)
            cameraIndices = unique(double(cameraIndices(:).'));
            if obj.SimulationMode
                logger.log('INFO', 'OPEN_ENDED_ACQUISITION_SIMULATION_PREPARED', ...
                    'Cameras=%s | ExternalTrigger=%d', ...
                    mat2str(cameraIndices), useExternalTrigger);
                return;
            end
            for cameraIndex = cameraIndices
                vid = obj.VideoObjects{cameraIndex};
                obj.disablePreviewBufferDrain(vid);
                if strcmpi(vid.Previewing, 'on')
                    stoppreview(vid);
                end
                if strcmpi(vid.Running, 'on')
                    stop(vid);
                end
                if vid.FramesAvailable > 0
                    flushdata(vid);
                end
                vid.LoggingMode = 'memory';
                vid.FramesPerTrigger = Inf;
                vid.TriggerRepeat = 0;
                vid.TriggerFrameDelay = 0;
                vid.FrameGrabInterval = 1;
                triggerconfig(vid, 'immediate');
                if useExternalTrigger
                    obj.SourceObjects{cameraIndex}.TriggerSource = 'external';
                    if isprop(obj.SourceObjects{cameraIndex}, 'TriggerPolarity')
                        obj.SourceObjects{cameraIndex}.TriggerPolarity = 'positive';
                    end
                    if isprop(obj.SourceObjects{cameraIndex}, 'TriggerMode')
                        obj.SourceObjects{cameraIndex}.TriggerMode = 'start';
                    end
                    obj.configureVsyncOutput(cameraIndex, logger);
                else
                    obj.SourceObjects{cameraIndex}.TriggerSource = 'internal';
                end
                start(vid);
            end
            logger.log('SUCCESS', 'OPEN_ENDED_ACQUISITION_PREPARED', ...
                ['Cameras=%s | FramesPerTrigger=Inf | ExternalTrigger=%d | ', ...
                 'LoggingMode=memory | StopRequired=1'], ...
                mat2str(cameraIndices), useExternalTrigger);
        end

        function [movies, timestamps, counts, completed] = collectFiniteAcquisition( ...
                obj, cameraIndices, frameCounts, timeoutSeconds, ...
                stopRequestedFcn, progressFcn, logger)
            cameraIndices = unique(double(cameraIndices(:).'));
            frameCounts = double(frameCounts(:).');
            if isscalar(frameCounts)
                frameCounts = repmat(frameCounts, 1, numel(cameraIndices));
            end
            movies = cell(1, 2);
            timestamps = cell(1, 2);
            counts = zeros(1, 2);
            completed = false;
            if obj.SimulationMode
                for position = 1:numel(cameraIndices)
                    cameraIndex = cameraIndices(position);
                    roi = obj.ROIs{cameraIndex};
                    frameCount = frameCounts(position);
                    movies{cameraIndex} = uint16(randi([500 60000], ...
                        roi(4), roi(3), frameCount));
                    timestamps{cameraIndex} = (0:frameCount - 1).' / 10;
                    counts(cameraIndex) = frameCount;
                    if ~isempty(progressFcn)
                        progressFcn(counts, cameraIndices, frameCounts);
                    end
                end
                completed = true;
                logger.log('SUCCESS', 'FINITE_ACQUISITION_SIMULATION_COMPLETE', ...
                    'Cameras=%s | FrameCounts=%s | SimulationFPS=10', ...
                    mat2str(cameraIndices), mat2str(frameCounts));
                return;
            end

            waitClock = tic;
            stoppedByUser = false;
            while toc(waitClock) < timeoutSeconds
                available = zeros(1, numel(cameraIndices));
                for position = 1:numel(cameraIndices)
                    available(position) = double( ...
                        obj.VideoObjects{cameraIndices(position)}.FramesAvailable);
                    counts(cameraIndices(position)) = available(position);
                end
                if ~isempty(progressFcn)
                    progressFcn(counts, cameraIndices, frameCounts);
                end
                if all(available >= frameCounts)
                    completed = true;
                    break;
                end
                drawnow limitrate;
                if ~isempty(stopRequestedFcn) && stopRequestedFcn()
                    stoppedByUser = true;
                    break;
                end
                pause(0.01);
            end
            for position = 1:numel(cameraIndices)
                cameraIndex = cameraIndices(position);
                vid = obj.VideoObjects{cameraIndex};
                if strcmpi(vid.Running, 'on')
                    stop(vid);
                end
                available = double(vid.FramesAvailable);
                retrieveCount = min(available, frameCounts(position));
                if retrieveCount > 0
                    [data, timeValues] = getdata(vid, retrieveCount, 'uint16');
                    movies{cameraIndex} = reshape(data, size(data, 1), ...
                        size(data, 2), retrieveCount);
                    timestamps{cameraIndex} = double(timeValues(:));
                else
                    roi = obj.ROIs{cameraIndex};
                    movies{cameraIndex} = zeros(roi(4), roi(3), 0, 'uint16');
                    timestamps{cameraIndex} = zeros(0, 1);
                end
                counts(cameraIndex) = retrieveCount;
                logger.log('INFO', 'FINITE_CAMERA_FRAMES_COLLECTED', ...
                    ['Camera=%d | ExpectedFrames=%d | RetrievedFrames=%d | ', ...
                     'FramesAvailableBeforeRead=%d | StoppedByUser=%d | Class=uint16'], ...
                    cameraIndex, frameCounts(position), retrieveCount, ...
                    available, stoppedByUser);
            end
            completed = completed && all(counts(cameraIndices) >= frameCounts);
            if completed
                logger.log('SUCCESS', 'FINITE_ACQUISITION_COMPLETE', ...
                    'Cameras=%s | Expected=%s | Retrieved=%s | Elapsed=%.6g', ...
                    mat2str(cameraIndices), mat2str(frameCounts), ...
                    mat2str(counts(cameraIndices)), toc(waitClock));
            else
                logger.log('WARNING', 'FINITE_ACQUISITION_INCOMPLETE', ...
                    ['Cameras=%s | Expected=%s | Retrieved=%s | Elapsed=%.6g | ', ...
                     'StoppedByUser=%d | PartialDataPreserved=1'], ...
                    mat2str(cameraIndices), mat2str(frameCounts), ...
                    mat2str(counts(cameraIndices)), toc(waitClock), stoppedByUser);
            end
        end

        function abortFiniteAcquisition(obj, cameraIndices, logger)
            if obj.SimulationMode
                return;
            end
            for cameraIndex = unique(double(cameraIndices(:).'))
                if ~obj.Connected(cameraIndex)
                    continue;
                end
                vid = obj.VideoObjects{cameraIndex};
                obj.disablePreviewBufferDrain(vid);
                if strcmpi(vid.Running, 'on')
                    stop(vid);
                end
            end
            logger.log('INFO', 'FINITE_ACQUISITION_ABORTED', ...
                'Cameras=%s | BufferedFramesPreservedUntilCollectionOrFlush=1', ...
                mat2str(cameraIndices));
        end

        function [movies, timestamps, counts] = stopAndCollectAvailable(obj, ...
                cameraIndices, simulationFrameCounts, logger)
            cameraIndices = unique(double(cameraIndices(:).'));
            movies = cell(1, 2);
            timestamps = cell(1, 2);
            counts = zeros(1, 2);
            if obj.SimulationMode
                simulationFrameCounts = double(simulationFrameCounts(:).');
                if isscalar(simulationFrameCounts)
                    simulationFrameCounts = repmat(simulationFrameCounts, ...
                        1, numel(cameraIndices));
                end
                for position = 1:numel(cameraIndices)
                    cameraIndex = cameraIndices(position);
                    roi = obj.ROIs{cameraIndex};
                    count = simulationFrameCounts(position);
                    movies{cameraIndex} = uint16(randi([500 60000], ...
                        roi(4), roi(3), count));
                    timestamps{cameraIndex} = (0:count - 1).' / 10;
                    counts(cameraIndex) = count;
                end
                logger.log('SUCCESS', 'AVAILABLE_FRAMES_SIMULATION_COLLECTED', ...
                    'Cameras=%s | Counts=%s | SimulationFPS=10', ...
                    mat2str(cameraIndices), mat2str(counts(cameraIndices)));
                return;
            end
            for cameraIndex = cameraIndices
                vid = obj.VideoObjects{cameraIndex};
                if strcmpi(vid.Running, 'on')
                    stop(vid);
                end
                available = double(vid.FramesAvailable);
                if available > 0
                    [data, timeValues] = getdata(vid, available, 'uint16');
                    movies{cameraIndex} = reshape(data, size(data, 1), ...
                        size(data, 2), available);
                    timestamps{cameraIndex} = double(timeValues(:));
                else
                    roi = obj.ROIs{cameraIndex};
                    movies{cameraIndex} = zeros(roi(4), roi(3), 0, 'uint16');
                    timestamps{cameraIndex} = zeros(0, 1);
                end
                counts(cameraIndex) = available;
                logger.log('INFO', 'AVAILABLE_CAMERA_FRAMES_COLLECTED', ...
                    'Camera=%d | RetrievedFrames=%d | Class=uint16', ...
                    cameraIndex, available);
            end
            logger.log('SUCCESS', 'AVAILABLE_FRAMES_COLLECTION_COMPLETE', ...
                'Cameras=%s | Counts=%s', mat2str(cameraIndices), ...
                mat2str(counts(cameraIndices)));
        end

        function metrics = bufferedAcquisitionMetrics(obj, cameraIndices)
            cameraIndices = unique(double(cameraIndices(:).'), 'stable');
            metrics = repmat(struct('Camera', NaN, 'FramesAcquired', NaN, ...
                'FramesAvailable', NaN, 'Running', false), 1, ...
                numel(cameraIndices));
            for position = 1:numel(cameraIndices)
                cameraIndex = cameraIndices(position);
                metrics(position).Camera = cameraIndex;
                if obj.SimulationMode
                    continue;
                end
                vid = obj.VideoObjects{cameraIndex};
                metrics(position).FramesAcquired = double(vid.FramesAcquired);
                metrics(position).FramesAvailable = double(vid.FramesAvailable);
                metrics(position).Running = strcmpi(vid.Running, 'on');
            end
        end

        function block = takeBufferedFrames(obj, cameraIndex, frameCount)
            validateattributes(frameCount, {'numeric'}, ...
                {'scalar','integer','positive','finite'});
            if obj.SimulationMode
                error('ZouLab:SimulationBufferedReadUnsupported', ...
                    'Simulation frames are generated by the acquisition coordinator.');
            end
            vid = obj.VideoObjects{cameraIndex};
            available = double(vid.FramesAvailable);
            if available < frameCount
                error('ZouLab:BufferedFramesNotReady', ...
                    'Camera %d has %d buffered frames; %d were requested.', ...
                    cameraIndex, available, frameCount);
            end
            [data, timeValues, metadata] = getdata( ...
                vid, frameCount, 'uint16');
            block = struct( ...
                'Data', reshape(data, size(data, 1), size(data, 2), 1, ...
                    frameCount), ...
                'Times', double(timeValues(:)), ...
                'Metadata', metadata);
        end

        function stopBufferedAcquisition(obj, cameraIndices, logger, reason)
            cameraIndices = unique(double(cameraIndices(:).'), 'stable');
            if nargin < 4
                reason = 'buffered_record_complete';
            end
            if obj.SimulationMode
                logger.log('INFO', 'BUFFERED_ACQUISITION_SIMULATION_STOPPED', ...
                    'Cameras=%s | Reason=%s', mat2str(cameraIndices), reason);
                return;
            end
            videoCells = obj.VideoObjects(cameraIndices);
            beforeCounts = zeros(1, numel(videoCells));
            for position = 1:numel(videoCells)
                beforeCounts(position) = ...
                    double(videoCells{position}.FramesAcquired);
            end
            stopClock = tic;
            stop([videoCells{:}]);
            arrayStopElapsed = toc(stopClock);
            afterArrayCounts = zeros(1, numel(videoCells));
            runningAfterArray = strings(1, numel(videoCells));
            for position = 1:numel(videoCells)
                afterArrayCounts(position) = ...
                    double(videoCells{position}.FramesAcquired);
                runningAfterArray(position) = ...
                    string(videoCells{position}.Running);
            end
            fallbackPositions = find(runningAfterArray == "on");
            for position = fallbackPositions
                stop(videoCells{position});
            end
            finalCounts = zeros(1, numel(videoCells));
            for position = 1:numel(videoCells)
                finalCounts(position) = ...
                    double(videoCells{position}.FramesAcquired);
            end
            logger.log('INFO', 'BUFFERED_ACQUISITION_STOPPED', ...
                ['Cameras=%s | Reason=%s | BufferedFramesPreserved=1 | ', ...
                 'MetadataCheckPendingForUnreadFrames=1 | ', ...
                 'StopDispatch=single_object_array_call | ', ...
                 'ArrayStopElapsed=%.6g | FramesBefore=%s | ', ...
                 'FramesAfterArray=%s | FramesDuringArrayStop=%s | ', ...
                 'RunningAfterArray=%s | SequentialSafetyFallback=%s | ', ...
                 'FinalFrames=%s'], mat2str(cameraIndices), reason, ...
                arrayStopElapsed, mat2str(beforeCounts), ...
                mat2str(afterArrayCounts), ...
                mat2str(afterArrayCounts - beforeCounts), ...
                strjoin(runningAfterArray, ','), ...
                mat2str(cameraIndices(fallbackPositions)), ...
                mat2str(finalCounts));
        end

        function frames = collectTriggeredFrames(obj, cameraIndices, timeoutSeconds, logger)
            frames = cell(1, 2);
            if obj.SimulationMode
                for cameraIndex = cameraIndices
                    roi = obj.ROIs{cameraIndex};
                    frames{cameraIndex} = uint16(randi([500 60000], roi(4), roi(3)));
                end
                return;
            end
            deadline = tic;
            while toc(deadline) < timeoutSeconds
                ready = true;
                for cameraIndex = cameraIndices
                    ready = ready && obj.VideoObjects{cameraIndex}.FramesAvailable >= 1;
                end
                if ready
                    break;
                end
                pause(0.005);
            end
            for cameraIndex = cameraIndices
                vid = obj.VideoObjects{cameraIndex};
                if vid.FramesAvailable < 1
                    error('ZouLab:TriggeredFrameTimeout', ...
                        'Camera %d did not return a triggered frame within %.3f s.', ...
                        cameraIndex, timeoutSeconds);
                end
                frames{cameraIndex} = squeeze(getdata(vid, 1, 'uint16'));
                logger.log('SUCCESS', 'TRIGGERED_FRAME_RECEIVED', ...
                    'Camera=%d | Size=%s | Class=%s | RawMin=%g | RawMax=%g', ...
                    cameraIndex, mat2str(size(frames{cameraIndex})), ...
                    class(frames{cameraIndex}), min(frames{cameraIndex}, [], 'all'), ...
                    max(frames{cameraIndex}, [], 'all'));
            end
        end

        function restorePreviewConfiguration(obj, cameraIndices, logger)
            if obj.SimulationMode
                return;
            end
            for cameraIndex = cameraIndices
                vid = obj.VideoObjects{cameraIndex};
                obj.disablePreviewBufferDrain(vid);
                if strcmpi(vid.Running, 'on')
                    stop(vid);
                end
                flushdata(vid);
                vid.FramesPerTrigger = Inf;
                triggerconfig(vid, 'immediate');
                obj.SourceObjects{cameraIndex}.TriggerSource = 'internal';
            end
            logger.log('INFO', 'CAMERAS_RESTORED_INTERNAL_TRIGGER', ...
                'Cameras=%s', mat2str(cameraIndices));
        end

        function frames = acquireInternalSnapshots(obj, cameraIndices, logger)
            frames = cell(1, 2);
            if obj.SimulationMode
                for cameraIndex = cameraIndices
                    roi = obj.ROIs{cameraIndex};
                    frames{cameraIndex} = uint16(randi([500 60000], roi(4), roi(3)));
                end
                return;
            end
            for cameraIndex = cameraIndices
                frames{cameraIndex} = uint16(getsnapshot(obj.VideoObjects{cameraIndex}));
                logger.log('SUCCESS', 'INTERNAL_SNAPSHOT_RECEIVED', ...
                    'Camera=%d | Size=%s | Class=%s | RawMin=%g | RawMax=%g', ...
                    cameraIndex, mat2str(size(frames{cameraIndex})), ...
                    class(frames{cameraIndex}), min(frames{cameraIndex}, [], 'all'), ...
                    max(frames{cameraIndex}, [], 'all'));
            end
        end

        function applyROI(obj, cameraIndex, roi, logger)
            validateattributes(roi, {'numeric'}, {'vector','numel',4,'integer','nonnegative'});
            obj.validateROI(roi, obj.Bins(cameraIndex));
            if ~obj.SimulationMode
                vid = obj.VideoObjects{cameraIndex};
                if strcmpi(vid.Previewing, 'on')
                    stoppreview(vid);
                end
                if strcmpi(vid.Running, 'on')
                    stop(vid);
                end
                vid.ROIPosition = roi;
            end
            obj.ROIs{cameraIndex} = double(roi);
            logger.log('INFO', 'CAMERA_ROI_APPLIED', ...
                'Camera=%d | Bin=%d | RequestedROI=%s | ActualROI=%s', ...
                cameraIndex, obj.Bins(cameraIndex), mat2str(roi), ...
                mat2str(obj.getActualSettings(cameraIndex).ROI));
        end

        function [fps, propertyName] = getCameraReportedFPS(obj, cameraIndex)
            fps = NaN;
            propertyName = "unavailable";
            if ~obj.Connected(cameraIndex) || obj.SimulationMode || ...
                    isempty(obj.SourceObjects{cameraIndex})
                if obj.SimulationMode
                    fps = 1 / obj.ExposureTimes(cameraIndex);
                    propertyName = "simulation_exposure_limit";
                end
                return;
            end
            source = obj.SourceObjects{cameraIndex};
            candidates = ["InternalFrameRate", "FrameRate", "ResultingFrameRate", ...
                "AcquisitionFrameRate", "ActualFrameRate"];
            for candidate = candidates
                if isprop(source, candidate)
                    value = double(source.(candidate));
                    if isscalar(value) && isfinite(value) && value > 0
                        fps = value;
                        propertyName = candidate;
                        return;
                    end
                end
            end
        end

        function settings = getActualSettings(obj, cameraIndex)
            settings = struct( ...
                'Bin', obj.Bins(cameraIndex), ...
                'ROI', obj.ROIs{cameraIndex}, ...
                'ExposureTime', obj.ExposureTimes(cameraIndex), ...
                'VideoFormat', char(obj.VideoFormats(cameraIndex)));
            if obj.Connected(cameraIndex) && ~obj.SimulationMode
                settings.ROI = double(obj.VideoObjects{cameraIndex}.ROIPosition);
                settings.ExposureTime = double(obj.SourceObjects{cameraIndex}.ExposureTime);
                settings.VideoFormat = char(string(obj.VideoObjects{cameraIndex}.VideoFormat));
            end
        end

        function result = rediscoverAndConnect(obj, cameraIndices, logger)
            % Rebuild this process's IAT adaptor state after a camera is
            % powered on while another camera is already connected.  The
            % persistent camera service is the sole IAT owner in its child
            % MATLAB, so imaqreset is scoped to that dedicated process.
            requested = unique(double(cameraIndices(:).'));
            previouslyConnected = find(obj.Connected);
            recoveryIndices = unique([previouslyConnected requested]);
            logger.log('WARNING', 'CAMERA_HARDWARE_REDISCOVERY_BEGIN', ...
                ['Requested=%s | PreviouslyConnected=%s | RecoverySet=%s | ', ...
                 'Reason=hot_plug_not_visible_to_loaded_adaptor'], ...
                mat2str(requested), mat2str(previouslyConnected), ...
                mat2str(recoveryIndices));

            if obj.SimulationMode
                obj.Connected(:) = false;
                obj.connect(recoveryIndices, logger);
                result = struct( ...
                    'requested', requested, ...
                    'recovery_indices', recoveryIndices, ...
                    'connected', obj.Connected, ...
                    'missing', zeros(1, 0), ...
                    'error_identifiers', {cell(1, 2)}, ...
                    'errors', {cell(1, 2)});
                logger.log('SUCCESS', ...
                    'CAMERA_HARDWARE_REDISCOVERY_SUCCESS', ...
                    ['Requested=%s | Connected=%s | Simulation=1 | ', ...
                     'IatResetSkipped=1'], mat2str(requested), ...
                    mat2str(find(obj.Connected)));
                return;
            end

            obj.release(logger, 'hardware_rediscovery');
            imaqreset;
            logger.log('INFO', 'CAMERA_IAT_ADAPTOR_RESET_COMPLETE', ...
                ['Scope=dedicated_camera_service_process | ', ...
                 'ExternalMATLABObjectsAffected=0']);

            failures = strings(1, 2);
            identifiers = strings(1, 2);
            for cameraIndex = recoveryIndices
                try
                    obj.connect(cameraIndex, logger);
                catch ME
                    failures(cameraIndex) = string(ME.message);
                    identifiers(cameraIndex) = string(ME.identifier);
                    logger.logException(sprintf( ...
                        'CAMERA_%d_REDISCOVERY_CONNECT_FAILED', cameraIndex), ME);
                end
            end

            missing = requested(~obj.Connected(requested));
            result = struct( ...
                'requested', requested, ...
                'recovery_indices', recoveryIndices, ...
                'connected', obj.Connected, ...
                'missing', missing, ...
                'error_identifiers', {cellstr(identifiers)}, ...
                'errors', {cellstr(failures)});
            if isempty(missing)
                logger.log('SUCCESS', 'CAMERA_HARDWARE_REDISCOVERY_SUCCESS', ...
                    'Requested=%s | Connected=%s', mat2str(requested), ...
                    mat2str(find(obj.Connected)));
            else
                logger.log('ERROR', 'CAMERA_HARDWARE_REDISCOVERY_INCOMPLETE', ...
                    'Requested=%s | Connected=%s | Missing=%s', ...
                    mat2str(requested), mat2str(find(obj.Connected)), ...
                    mat2str(missing));
            end
        end

        function result = release(obj, logger, reason)
            if nargin < 3
                reason = 'app_release';
            end
            released = false(1, 2);
            for cameraIndex = 1:2
                released(cameraIndex) = obj.releaseCamera( ...
                    cameraIndex, logger, reason);
            end
            result = struct('released', released, ...
                'all_released', all(released));
            if ~result.all_released
                logger.log('ERROR', 'CAMERAS_RELEASE_INCOMPLETE', ...
                    'Reason=%s | Released=%s', reason, mat2str(released));
                error('ZouLab:CameraReleaseIncomplete', ...
                    'One or more camera objects could not be released.');
            end
            logger.log('INFO', 'CAMERAS_RELEASED', ...
                ['Reason=%s | Only videoinput objects owned by this ', ...
                 'camera-service process were released.'], reason);
        end

        function delete(obj)
            for cameraIndex = 1:2
                vid = obj.VideoObjects{cameraIndex};
                % A source object is owned by its videoinput object.  Drop
                % the source reference while the parent is still valid;
                % destroying a dangling source after delete(vid) can crash
                % the Image Acquisition Toolbox native adaptor.
                obj.SourceObjects{cameraIndex} = [];
                obj.VideoObjects{cameraIndex} = [];
                obj.Connected(cameraIndex) = false;
                if ~isempty(vid)
                    try
                        obj.disablePreviewBufferDrain(vid);
                        if isvalid(vid) && strcmpi(vid.Previewing, 'on')
                            stoppreview(vid);
                        end
                        if isvalid(vid) && strcmpi(vid.Running, 'on')
                            stop(vid);
                        end
                        delete(vid);
                    catch
                    end
                end
            end
        end
    end

    methods (Access = private)
        function released = releaseCamera(obj, cameraIndex, logger, reason)
            released = true;
            vid = obj.VideoObjects{cameraIndex};
            if isempty(vid)
                obj.SourceObjects{cameraIndex} = [];
                obj.Connected(cameraIndex) = false;
                return;
            end
            logger.log('INFO', 'CAMERA_RELEASE_BEGIN', ...
                'Camera=%d | Reason=%s', cameraIndex, reason);
            try
                if isvalid(vid)
                    obj.disablePreviewBufferDrain(vid);
                    if strcmpi(vid.Previewing, 'on')
                        stoppreview(vid);
                    end
                    if strcmpi(vid.Running, 'on')
                        stop(vid);
                    end
                    % The source proxy must be released before its parent
                    % videoinput object.  Clear manager-owned references
                    % first as well, so a later destructor cannot attempt a
                    % second delete if native teardown raises an exception.
                    obj.SourceObjects{cameraIndex} = [];
                    obj.VideoObjects{cameraIndex} = [];
                    obj.Connected(cameraIndex) = false;
                    logger.log('INFO', 'CAMERA_RELEASE_REFERENCES_DETACHED', ...
                        'Camera=%d | SourceBeforeVideoDelete=1', cameraIndex);
                    delete(vid);
                end
                logger.log('INFO', 'CAMERA_RELEASED', ...
                    'Camera=%d | Reason=%s', cameraIndex, reason);
            catch ME
                released = false;
                logger.logException('CAMERA_RELEASE_FAILED', ME);
            end
            % These assignments are intentionally idempotent.  In the
            % normal path the potentially fragile MCOS references were
            % already detached before delete(vid).
            obj.VideoObjects{cameraIndex} = [];
            obj.SourceObjects{cameraIndex} = [];
            obj.Connected(cameraIndex) = false;
        end

        function flushPreviewBuffer(obj, vid, cameraIndex, logger)
            try
                if isvalid(vid) && vid.FramesAvailable > 0
                    flushdata(vid);
                end
            catch ME
                obj.PreviewFlushErrors(cameraIndex) = ...
                    obj.PreviewFlushErrors(cameraIndex) + 1;
                try
                    obj.disablePreviewBufferDrain(vid);
                catch
                end
                logger.logException('PREVIEW_BUFFER_FLUSH_FAILED', ME);
                logger.log('ERROR', 'PREVIEW_BUFFER_FLUSH_DISABLED', ...
                    'Camera=%d | FlushErrors=%d | Memory growth must be monitored.', ...
                    cameraIndex, obj.PreviewFlushErrors(cameraIndex));
            end
        end

        function disablePreviewBufferDrain(~, vid)
            if isempty(vid) || ~isvalid(vid)
                return;
            end
            vid.FramesAcquiredFcn = [];
            vid.FramesAcquiredFcnCount = 0;
        end

        function configureVsyncOutput(obj, cameraIndex, logger)
            source = obj.SourceObjects{cameraIndex};
            required = {'OutputTriggerKindOpt1', ...
                'OutputTriggerSourceOpt1', 'OutputTriggerPolarityOpt1'};
            missing = required(~cellfun(@(name) isprop(source, name), required));
            if ~isempty(missing)
                error('ZouLab:CameraVsyncOutputUnavailable', ...
                    ['Camera %d cannot expose its frame counter to DAQ because ', ...
                     'the Hamamatsu source lacks: %s.'], cameraIndex, ...
                    strjoin(missing, ', '));
            end
            source.OutputTriggerKindOpt1 = 'programable';
            source.OutputTriggerSourceOpt1 = 'vsync';
            source.OutputTriggerPolarityOpt1 = 'positive';
            logger.log('SUCCESS', 'CAMERA_VSYNC_OUTPUT_CONFIGURED', ...
                ['Camera=%d | Kind=%s | Source=%s | Polarity=%s | ', ...
                 'Purpose=DAQ_frame_counter_alignment'], cameraIndex, ...
                string(source.OutputTriggerKindOpt1), ...
                string(source.OutputTriggerSourceOpt1), ...
                string(source.OutputTriggerPolarityOpt1));
        end

        function exposure = actualExposure(obj, cameraIndex)
            exposure = obj.ExposureTimes(cameraIndex);
            if obj.Connected(cameraIndex) && ~obj.SimulationMode
                exposure = double(obj.SourceObjects{cameraIndex}.ExposureTime);
            end
        end

        function validateBin(~, binFactor)
            if ~isscalar(binFactor) || ~ismember(double(binFactor), [1 2 4])
                error('ZouLab:UnsupportedBin', 'Bin must be 1, 2, or 4.');
            end
        end

        function validateROI(~, roi, binFactor)
            validateattributes(roi, {'numeric'}, {'vector','numel',4,'integer','nonnegative'});
            limit = 2304 / binFactor;
            if any(roi(3:4) < 1) || roi(1) + roi(3) > limit || roi(2) + roi(4) > limit
                error('ZouLab:ROIOutOfBounds', ...
                    'ROI %s is outside the %dx%d Bin%d image.', ...
                    mat2str(roi), limit, limit, binFactor);
            end
        end

        function format = formatForBin(~, binFactor)
            switch binFactor
                case 1
                    format = "MONO16_2304x2304_Fast";
                case 2
                    format = "MONO16_BIN2x2_1152x1152_Fast";
                case 4
                    format = "MONO16_BIN4x4_576x576_Fast";
            end
        end
    end
end
