classdef VisualStimulusController < handle
    %VISUALSTIMULUSCONTROLLER Owns Psychtoolbox stimulus state and timing.

    properties (SetAccess = private)
        Armed logical = false
        Running logical = false
        SimulationMode logical = false
        State string = "OFF"
        ScreenReady logical = false
        ScreenIndex double = NaN
        Spec struct = struct()
        Runtime struct = struct()
        DisplayConfig struct = struct()
    end

    properties (Access = private)
        InteractivePreview logical = false
    end

    methods
        function setupScreen(obj, screenIndex, simulationMode, logger, displayConfig)
            if nargin < 5
                displayConfig = struct();
            end
            displayConfig = obj.normalizeDisplayConfig(displayConfig);
            if obj.Running
                error('ZouLab:VisualStimRunning', ...
                    'Stop visual playback before changing the PTB Screen.');
            end
            if obj.Armed
                error('ZouLab:VisualStimArmed', ...
                    'Disarm Visual Stimulus before changing the PTB Screen.');
            end
            validateattributes(screenIndex, {'numeric'}, ...
                {'scalar','integer','nonnegative','finite'});
            requestedSimulation = logical(simulationMode);
            if obj.ScreenReady && obj.ScreenIndex == screenIndex && ...
                    obj.SimulationMode == requestedSimulation
                obj.applyStandbyAppearance(displayConfig, logger);
                logger.log('INFO', 'PTB_SCREEN_SETUP_NOOP_ALREADY_READY', ...
                    ['Screen=%d | Simulation=%d | IFI=%.9g | ', ...
                     'IdleColor=%s'], screenIndex, requestedSimulation, ...
                    obj.Runtime.ifi, mat2str(displayConfig.idle_color));
                return;
            end
            obj.closeRuntime();
            obj.ScreenReady = false;
            obj.ScreenIndex = NaN;
            obj.SimulationMode = requestedSimulation;
            obj.DisplayConfig = displayConfig;
            obj.State = "SCREEN_SETUP";
            logger.log('INFO', 'USER_PTB_SCREEN_SETUP_REQUESTED', ...
                'Screen=%d | Simulation=%d | PlaybackStarted=0', ...
                screenIndex, requestedSimulation);
            try
                if obj.SimulationMode
                    obj.Runtime = struct('initialized', true, 'ifi', 1/60, ...
                        'window', [], 'windowRect', [0 0 1024 768], ...
                        'gratingtex', [], 'phaseinc', [], ...
                        'gratingsize', [], 'screen_index', screenIndex, ...
                        'idle_color', displayConfig.idle_color);
                else
                    obj.initializePsychtoolboxScreen(screenIndex);
                end
                obj.ScreenReady = true;
                obj.ScreenIndex = double(screenIndex);
                obj.State = "SCREEN_READY";
                logger.log('SUCCESS', 'PTB_SCREEN_READY', ...
                    ['Screen=%d | Simulation=%d | IFI=%.9g | ', ...
                     'WindowRect=%s | PlaybackStarted=0 | IdleColor=%s'], ...
                    obj.ScreenIndex, obj.SimulationMode, obj.Runtime.ifi, ...
                    mat2str(obj.Runtime.windowRect), ...
                    mat2str(displayConfig.idle_color));
            catch ME
                obj.closeRuntime();
                obj.ScreenReady = false;
                obj.ScreenIndex = NaN;
                obj.State = "ERROR";
                logger.logException('PTB_SCREEN_SETUP_FAILED', ME);
                rethrow(ME);
            end
        end

        function applyStandbyAppearance(obj, config, logger)
            if obj.Running || obj.Armed
                error('ZouLab:VisualStimBusy', ...
                    'Disarm and stop visual stimulation before changing PTB display parameters.');
            end
            value = obj.normalizeDisplayConfig(config);
            previous = obj.DisplayConfig;
            obj.DisplayConfig = value;
            if obj.ScreenReady
                if obj.SimulationMode
                    obj.Runtime.idle_color = value.idle_color;
                else
                    Screen('FillRect', obj.Runtime.window, value.idle_color);
                    Screen('Flip', obj.Runtime.window);
                end
            end
            if nargin >= 3 && ~isempty(logger)
                logger.log('SUCCESS', 'PTB_STANDBY_APPEARANCE_APPLIED', ...
                    ['ScreenReady=%d | IdleColor=%s | BaselineColor=%s | ', ...
                     'FlipDeadlineFraction=%.6g | InitialPhaseDeg=%.6g | ', ...
                     'Previous=%s'], obj.ScreenReady, ...
                    mat2str(value.idle_color), mat2str(value.gray_color), ...
                    value.flip_deadline_fraction, value.initial_phase_deg, ...
                    jsonencode(previous));
            end
        end

        function closeScreen(obj, logger)
            wasReady = obj.ScreenReady;
            previousScreen = obj.ScreenIndex;
            obj.closeRuntime();
            obj.ScreenReady = false;
            obj.ScreenIndex = NaN;
            obj.Armed = false;
            obj.Running = false;
            obj.InteractivePreview = false;
            obj.State = "OFF";
            if ~isempty(logger)
                logger.log('INFO', 'PTB_SCREEN_CLOSED', ...
                    ['PreviousScreen=%s | WasReady=%d | ', ...
                     'KeyboardInputRestored=1'], ...
                    mat2str(previousScreen), wasReady);
            end
        end

        function arm(obj, config, simulationMode, logger)
            if obj.Running
                error('ZouLab:VisualStimRunning', ...
                    'Visual stimulus cannot be reconfigured while it is running.');
            end
            obj.Spec = obj.buildSpec(config);
            obj.requirePreparedScreen(obj.Spec.screen_index, ...
                logical(simulationMode));
            obj.releaseStimulusRuntime();
            obj.State = "ARMING";
            logger.log('INFO', 'VISUAL_STIM_ARM_REQUESTED', ...
                'Program=%s | Screen=%d | Simulation=%d | EstimatedDuration=%.6g', ...
                obj.Spec.program, obj.Spec.screen_index, obj.SimulationMode, ...
                obj.Spec.estimated_duration_seconds);
            try
                obj.prepareStimulusRuntime();
                obj.Armed = true;
                obj.State = "ARMED";
                logger.log('SUCCESS', 'VISUAL_STIM_ARMED', ...
                    ['Program=%s | Label=%s | Screen=%d | IFI=%.9g | ', ...
                     'EstimatedDuration=%.6g | Config=%s'], ...
                    obj.Spec.program, obj.Spec.label, obj.Spec.screen_index, ...
                    obj.Runtime.ifi, obj.Spec.estimated_duration_seconds, ...
                    jsonencode(obj.Spec.config));
            catch ME
                obj.releaseStimulusRuntime();
                obj.Armed = false;
                obj.State = "ERROR";
                logger.logException('VISUAL_STIM_ARM_FAILED', ME);
                rethrow(ME);
            end
        end

        function disarm(obj, logger, writeLog)
            if nargin < 3
                writeLog = true;
            end
            wasArmed = obj.Armed;
            obj.releaseStimulusRuntime();
            obj.Armed = false;
            obj.Running = false;
            if obj.ScreenReady
                obj.State = "SCREEN_READY";
            else
                obj.State = "OFF";
            end
            if writeLog && wasArmed && ~isempty(logger)
                logger.log('INFO', 'VISUAL_STIM_DISARMED', ...
                    ['Stimulus resources released; PTB Screen remains %s. ', ...
                     'Use Close Screen to close the PTB window.'], obj.State);
            end
        end

        function logs = run(obj, logger, stampFcn, stopRequestedFcn)
            if nargin < 3
                stampFcn = [];
            end
            if nargin < 4
                stopRequestedFcn = [];
            end
            if ~obj.Armed
                error('ZouLab:VisualStimNotArmed', ...
                    'Arm Visual Stimulus in the Stimulus Setup tab first.');
            end
            obj.Running = true;
            obj.State = "RUNNING";
            cleanup = onCleanup(@() obj.finishRunState());
            logger.log('INFO', 'VISUAL_STIM_RUN_BEGIN', ...
                ['Program=%s | EstimatedDuration=%.6g | Simulation=%d | ', ...
                 'EpochOrder=%s'], ...
                obj.Spec.program, obj.Spec.estimated_duration_seconds, ...
                obj.SimulationMode, obj.Spec.epoch_order);
            startTime = tic;
            angleSequence = zeros(1, 0);
            if ismember(obj.Spec.program, ...
                    ["drifting_grating", "random_drifting_grating"])
                angleSequence = obj.resolveAngleSequence();
            end
            if obj.SimulationMode
                obj.simulateRun(stopRequestedFcn);
                logs = struct( ...
                    'program', char(obj.Spec.program), ...
                    'label', char(obj.Spec.label), ...
                    'vbl', zeros(0, 1), ...
                    'simulation', true, ...
                    'elapsed_seconds', toc(startTime), ...
                    'spec', obj.serializableSpec(), ...
                    'stimulus', obj.stimulusLog(angleSequence));
                logger.log('SUCCESS', 'VISUAL_STIM_RUN_COMPLETE', ...
                    'Program=%s | Simulation=1 | Elapsed=%.6g | FlipCount=0', ...
                    obj.Spec.program, logs.elapsed_seconds);
                return;
            end

            vbl = Screen('Flip', obj.Runtime.window);
            vblLog = zeros(1, max(16, ceil(obj.Spec.estimated_duration_seconds / ...
                obj.Runtime.ifi) + 4));
            flipCount = 0;
            [vbl, vblLog, flipCount] = obj.recordFlip( ...
                vbl, vblLog, flipCount, stampFcn, stopRequestedFcn);
            try
                switch obj.Spec.program
                    case {"drifting_grating", "random_drifting_grating"}
                        for angle = angleSequence
                            [vbl, vblLog, flipCount] = obj.drawSolidFrames( ...
                                obj.Spec.colors.gray, obj.Spec.isi_seconds, ...
                                vbl, vblLog, flipCount, stampFcn, stopRequestedFcn);
                            phase = obj.Spec.initial_phase_deg;
                            frameCount = max(1, round(obj.Spec.duration_seconds / ...
                                obj.Runtime.ifi));
                            for frameIndex = 1:frameCount
                                phase = phase + obj.Runtime.phaseinc;
                                Screen('DrawTexture', obj.Runtime.window, ...
                                    obj.Runtime.gratingtex, [], [], angle, [], [], [], [], [], ...
                                    [phase, obj.Spec.cpp, obj.Spec.amplitude, 0]);
                                [vbl, vblLog, flipCount] = obj.recordFlip( ...
                                    vbl, vblLog, flipCount, stampFcn, stopRequestedFcn);
                            end
                        end
                    case {"gray_blue_gray", "gray_white_gray_black", "flash"}
                        for repeatIndex = 1:obj.Spec.repeats
                            for blockIndex = 1:size(obj.Spec.block_colors, 1)
                                [vbl, vblLog, flipCount] = obj.drawSolidFrames( ...
                                    obj.Spec.block_colors(blockIndex, :), ...
                                    obj.Spec.block_durations(blockIndex), ...
                                    vbl, vblLog, flipCount, stampFcn, stopRequestedFcn);
                            end
                        end
                    case "white_black_flicker"
                        [~, vblLog, flipCount] = obj.drawFlicker( ...
                            obj.Spec.colors.white, obj.Spec.colors.black, ...
                            obj.Spec.duration_seconds, obj.Spec.frequency_hz, ...
                            vbl, vblLog, flipCount, stampFcn, stopRequestedFcn);
                    case "step_flicker"
                        for frequency = obj.Spec.sequence
                            if frequency == 0
                                [vbl, vblLog, flipCount] = obj.drawSolidFrames( ...
                                    obj.Spec.colors.gray, obj.Spec.duration_seconds, ...
                                    vbl, vblLog, flipCount, stampFcn, stopRequestedFcn);
                            else
                                [vbl, vblLog, flipCount] = obj.drawFlicker( ...
                                    obj.Spec.colors.white, obj.Spec.colors.gray, ...
                                    obj.Spec.duration_seconds, frequency, ...
                                    vbl, vblLog, flipCount, stampFcn, stopRequestedFcn);
                            end
                        end
                    case "contrast_reverse"
                        [~, vblLog, flipCount] = obj.drawContrastReverse( ...
                            vbl, vblLog, flipCount, stampFcn, stopRequestedFcn);
                    otherwise
                        error('ZouLab:VisualProgramUnsupported', ...
                            'Unsupported visual stimulus program: %s.', obj.Spec.program);
                end
                Screen('FillRect', obj.Runtime.window, obj.Spec.colors.idle);
                Screen('Flip', obj.Runtime.window);
            catch ME
                try
                    Screen('FillRect', obj.Runtime.window, obj.Spec.colors.idle);
                    Screen('Flip', obj.Runtime.window);
                catch
                end
                logger.logException('VISUAL_STIM_RUN_FAILED', ME);
                rethrow(ME);
            end
            logs = struct( ...
                'program', char(obj.Spec.program), ...
                'label', char(obj.Spec.label), ...
                'vbl', vblLog(1:flipCount).', ...
                'simulation', false, ...
                'elapsed_seconds', toc(startTime), ...
                'spec', obj.serializableSpec(), ...
                'stimulus', obj.stimulusLog(angleSequence));
            logger.log('SUCCESS', 'VISUAL_STIM_RUN_COMPLETE', ...
                'Program=%s | Simulation=0 | Elapsed=%.6g | FlipCount=%d', ...
                obj.Spec.program, logs.elapsed_seconds, flipCount);
        end

        function logs = playPreview(obj, config, simulationMode, logger, ...
                selectionMode, fixedAngle, stopRequestedFcn)
            if nargin < 5 || strlength(string(selectionMode)) == 0
                selectionMode = 'full';
            end
            if nargin < 6
                fixedAngle = NaN;
            end
            if nargin < 7
                stopRequestedFcn = [];
            end
            if obj.Armed || obj.Running
                error('ZouLab:VisualStimBusy', ...
                    'Disarm or stop the current visual stimulus before preview playback.');
            end
            obj.Spec = obj.buildSpec(config);
            obj.requirePreparedScreen(obj.Spec.screen_index, ...
                logical(simulationMode));
            obj.releaseStimulusRuntime();
            selectionMode = lower(string(selectionMode));
            chosenAngle = NaN;
            if selectionMode ~= "full"
                if ~ismember(obj.Spec.program, ...
                        ["drifting_grating", "random_drifting_grating"])
                    error('ZouLab:DirectionPreviewRequiresGrating', ...
                        'Fixed or random direction playback requires a grating program.');
                end
                if selectionMode == "fixed"
                    validateattributes(fixedAngle, {'numeric'}, ...
                        {'scalar','finite'});
                    chosenAngle = double(fixedAngle);
                elseif selectionMode == "random"
                    candidates = obj.Spec.sequence;
                    chosenAngle = candidates(randi(numel(candidates)));
                else
                    error('ZouLab:VisualPreviewModeInvalid', ...
                        'Preview mode must be full, fixed, or random.');
                end
                obj.Spec.program = "drifting_grating";
                obj.Spec.label = "Drifting grating preview";
                obj.Spec.sequence = chosenAngle;
                obj.Spec.repeats = 1;
                obj.Spec.estimated_duration_seconds = ...
                    obj.Spec.duration_seconds + obj.Spec.isi_seconds;
                obj.Spec.config.program = 'drifting_grating';
                obj.Spec.config.sequence = chosenAngle;
                obj.Spec.config.repeats = 1;
            end
            obj.State = "PREVIEW";
            logger.log('INFO', 'VISUAL_PREVIEW_PLAY_REQUESTED', ...
                ['Selection=%s | Program=%s | FixedRequested=%s | ', ...
                 'ChosenAngle=%s | CameraPreviewMayRemainActive=1 | DAQUsed=0'], ...
                selectionMode, obj.Spec.program, mat2str(fixedAngle), ...
                mat2str(chosenAngle));
            try
                obj.prepareStimulusRuntime();
                obj.Armed = true;
                obj.InteractivePreview = true;
                cleanup = onCleanup(@() obj.finishPreview());
                logs = obj.run(logger, [], stopRequestedFcn);
                logs.preview_selection = char(selectionMode);
                logs.preview_chosen_angle = chosenAngle;
                logs.daq_used = false;
                logger.log('SUCCESS', 'VISUAL_PREVIEW_PLAY_COMPLETE', ...
                    ['Selection=%s | Program=%s | ChosenAngle=%s | ', ...
                     'Elapsed=%.6g | DAQUsed=0'], selectionMode, ...
                    logs.program, mat2str(chosenAngle), logs.elapsed_seconds);
            catch ME
                if strcmp(ME.identifier, 'ZouLab:AcquisitionStopped')
                    logger.log('INFO', 'VISUAL_PREVIEW_PLAY_STOPPED', ...
                        'Selection=%s | ChosenAngle=%s | DAQUsed=0', ...
                        selectionMode, mat2str(chosenAngle));
                else
                    logger.logException('VISUAL_PREVIEW_PLAY_FAILED', ME);
                end
                rethrow(ME);
            end
        end

        function duration = estimatedDuration(obj)
            duration = NaN;
            if ~isempty(fieldnames(obj.Spec)) && ...
                    isfield(obj.Spec, 'estimated_duration_seconds')
                duration = obj.Spec.estimated_duration_seconds;
            end
        end

        function value = manifest(obj)
            value = struct('state', char(obj.State), 'armed', obj.Armed, ...
                'running', obj.Running, 'simulation', obj.SimulationMode, ...
                'screen_ready', obj.ScreenReady, ...
                'screen_index', obj.ScreenIndex, ...
                'spec', obj.serializableSpec());
        end

        function value = legacyStimSpec(obj, cameraFPS)
            if nargin < 2
                cameraFPS = NaN;
            end
            value = obj.toLegacyStimSpec(obj.Spec, obj.Runtime, cameraFPS);
        end

        function value = legacyRuntime(obj)
            value = struct();
            if isstruct(obj.Runtime) && isfield(obj.Runtime, 'ifi')
                value.ifi = obj.Runtime.ifi;
            end
            if isstruct(obj.Runtime) && isfield(obj.Runtime, 'windowRect')
                value.windowRect = obj.Runtime.windowRect;
            end
        end

        function delete(obj)
            obj.closeRuntime();
            obj.ScreenReady = false;
            obj.ScreenIndex = NaN;
        end
    end

    methods (Access = private)
        function initializePsychtoolboxScreen(obj, screenIndex)
            required = {'PsychDefaultSetup','PsychImaging','Screen','AssertOpenGL'};
            for index = 1:numel(required)
                if exist(required{index}, 'file') == 0
                    error('ZouLab:PsychtoolboxMissing', ...
                        'Psychtoolbox function %s is unavailable.', required{index});
                end
            end
            ListenChar(2);
            PsychDefaultSetup(2);
            screens = Screen('Screens');
            if ~ismember(screenIndex, screens)
                error('ZouLab:StimulusScreenUnavailable', ...
                    'Screen %d is unavailable. Detected screens: %s.', ...
                    screenIndex, mat2str(screens));
            end
            AssertOpenGL;
            Screen('Preference', 'WindowShieldingLevel', 0);
            Screen('Preference', 'SkipSyncTests', 0);
            Screen('Preference', 'Verbosity', 4);
            Screen('Preference', 'VisualDebugLevel', 3);
            [window, windowRect] = PsychImaging('OpenWindow', ...
                screenIndex, obj.DisplayConfig.idle_color);
            priority = MaxPriority(window);
            Priority(priority);
            ifi = Screen('GetFlipInterval', window);
            runtime = struct('initialized', true, 'window', window, ...
                'windowRect', windowRect, 'ifi', ifi, 'priority', priority, ...
                'gratingtex', [], 'phaseinc', [], 'gratingsize', [], ...
                'screen_index', screenIndex);
            obj.Runtime = runtime;
        end

        function prepareStimulusRuntime(obj)
            if ismember(obj.Spec.program, ...
                    ["drifting_grating","random_drifting_grating","contrast_reverse"])
                width = obj.Runtime.windowRect(3) - obj.Runtime.windowRect(1);
                height = obj.Runtime.windowRect(4) - obj.Runtime.windowRect(2);
                obj.Runtime.gratingsize = ceil(sqrt(width^2 + height^2));
                if ~obj.SimulationMode
                    obj.Runtime.gratingtex = CreateProceduralSineGrating( ...
                        obj.Runtime.window, obj.Runtime.gratingsize, ...
                        obj.Runtime.gratingsize, [obj.Spec.colors.gray 0]);
                end
                obj.Runtime.phaseinc = ...
                    obj.Spec.frequency_hz * 360 * obj.Runtime.ifi;
                totalVisualAngle = 2 * atand((obj.Spec.screen_width_cm / 2) / ...
                    obj.Spec.viewing_distance_cm);
                pixelsPerDegree = width / totalVisualAngle;
                obj.Spec.cpp = obj.Spec.spatial_frequency_cpd / pixelsPerDegree;
            end
        end

        function [vbl, vblLog, flipCount] = drawSolidFrames(obj, color, duration, ...
                vbl, vblLog, flipCount, stampFcn, stopRequestedFcn)
            frameCount = max(1, round(duration / obj.Runtime.ifi));
            for frameIndex = 1:frameCount
                Screen('FillRect', obj.Runtime.window, color);
                [vbl, vblLog, flipCount] = obj.recordFlip( ...
                    vbl, vblLog, flipCount, stampFcn, stopRequestedFcn);
            end
        end

        function [vbl, vblLog, flipCount] = drawFlicker(obj, highColor, lowColor, ...
                duration, frequency, vbl, vblLog, flipCount, stampFcn, stopRequestedFcn)
            halfCycleFrames = max(1, round((1 / (2 * frequency)) / obj.Runtime.ifi));
            totalFrames = max(1, round(duration / obj.Runtime.ifi));
            rendered = 0;
            halfCycle = 1;
            while rendered < totalFrames
                if mod(halfCycle, 2) == 1
                    color = highColor;
                else
                    color = lowColor;
                end
                framesThisHalf = min(halfCycleFrames, totalFrames - rendered);
                [vbl, vblLog, flipCount] = obj.drawSolidFrames(color, ...
                    framesThisHalf * obj.Runtime.ifi, vbl, vblLog, flipCount, ...
                    stampFcn, stopRequestedFcn);
                rendered = rendered + framesThisHalf;
                halfCycle = halfCycle + 1;
            end
        end

        function [vbl, vblLog, flipCount] = drawContrastReverse(obj, ...
                vbl, vblLog, flipCount, stampFcn, stopRequestedFcn)
            halfCycleFrames = max(1, round((1 / (2 * obj.Spec.frequency_hz)) / ...
                obj.Runtime.ifi));
            totalFrames = max(1, round(obj.Spec.duration_seconds / obj.Runtime.ifi));
            width = obj.Runtime.windowRect(3) - obj.Runtime.windowRect(1);
            height = obj.Runtime.windowRect(4) - obj.Runtime.windowRect(2);
            destination = CenterRectOnPoint([0 0 obj.Runtime.gratingsize ...
                obj.Runtime.gratingsize], width / 2, height / 2);
            for frameIndex = 1:totalFrames
                halfCycle = floor((frameIndex - 1) / halfCycleFrames);
                amplitude = obj.Spec.amplitude * (-1)^halfCycle;
                Screen('DrawTexture', obj.Runtime.window, obj.Runtime.gratingtex, ...
                    [], destination, obj.Spec.sequence(1), [], [], [], [], [], ...
                    [obj.Spec.initial_phase_deg, obj.Spec.cpp, amplitude, 0]);
                [vbl, vblLog, flipCount] = obj.recordFlip( ...
                    vbl, vblLog, flipCount, stampFcn, stopRequestedFcn);
            end
        end

        function [vbl, vblLog, flipCount] = recordFlip(obj, vbl, vblLog, ...
                flipCount, stampFcn, stopRequestedFcn)
            vbl = Screen('Flip', obj.Runtime.window, vbl + ...
                obj.Spec.flip_deadline_fraction * obj.Runtime.ifi);
            flipCount = flipCount + 1;
            if flipCount > numel(vblLog)
                vblLog(end + 1024) = 0;
            end
            vblLog(flipCount) = vbl;
            if ~isempty(stampFcn)
                stampFcn();
            end
            if obj.InteractivePreview || ~isempty(stopRequestedFcn)
                drawnow limitrate;
                if ~isempty(stopRequestedFcn) && stopRequestedFcn()
                    error('ZouLab:AcquisitionStopped', ...
                        'Stop was requested during visual stimulation.');
                end
            end
        end

        function angles = resolveAngleSequence(obj)
            angles = repmat(obj.Spec.sequence, 1, obj.Spec.repeats);
            if obj.Spec.program == "random_drifting_grating"
                angles = angles(randperm(numel(angles)));
            end
        end

        function simulateRun(obj, stopRequestedFcn)
            duration = obj.Spec.estimated_duration_seconds;
            started = tic;
            while toc(started) < duration
                pause(min(0.02, duration - toc(started)));
                drawnow limitrate;
                if ~isempty(stopRequestedFcn) && stopRequestedFcn()
                    error('ZouLab:AcquisitionStopped', ...
                        'Acquisition stop was requested during simulated visual stimulation.');
                end
            end
        end

        function finishRunState(obj)
            obj.Running = false;
            if obj.Armed
                obj.State = "ARMED";
            elseif obj.ScreenReady
                obj.State = "SCREEN_READY";
            else
                obj.State = "OFF";
            end
        end

        function finishPreview(obj)
            obj.InteractivePreview = false;
            obj.releaseStimulusRuntime();
            obj.Armed = false;
            obj.Running = false;
            if obj.ScreenReady
                obj.State = "SCREEN_READY";
            else
                obj.State = "OFF";
            end
        end

        function value = stimulusLog(obj, angleSequence)
            value = struct('program', string(obj.Spec.program), ...
                'label', string(obj.Spec.label), ...
                'epochOrder', string(obj.Spec.epoch_order));
            if ismember(obj.Spec.program, ...
                    ["drifting_grating", "random_drifting_grating"])
                value.angleSequence = double(angleSequence(:).');
                if isfield(obj.Spec, 'random_drifting_grating')
                    value.randomDriftingGrating = ...
                        obj.Spec.random_drifting_grating;
                elseif isfield(obj.Spec, 'config') && ...
                        strcmp(string(obj.Spec.config.program), ...
                        "random_drifting_grating")
                    value.randomDriftingGrating = struct( ...
                        'baseAngles', double(obj.Spec.config.sequence(:).'), ...
                        'repeatsPerAngle', double(obj.Spec.config.repeats), ...
                        'angleSequence', double(angleSequence(:).'));
                end
            elseif obj.Spec.program == "step_flicker"
                value.frequencySequence = obj.Spec.sequence;
            end
        end

        function closeRuntime(obj)
            if ~isempty(obj.Runtime) && isstruct(obj.Runtime) && ...
                    isfield(obj.Runtime, 'initialized') && obj.Runtime.initialized && ...
                    ~obj.SimulationMode
                try
                    if isfield(obj.Runtime, 'gratingtex') && ...
                            ~isempty(obj.Runtime.gratingtex)
                        Screen('Close', obj.Runtime.gratingtex);
                    end
                    if isfield(obj.Runtime, 'window') && ~isempty(obj.Runtime.window)
                        Screen('Close', obj.Runtime.window);
                    end
                catch
                end
                try
                    Priority(0);
                    ListenChar(0);
                catch
                end
            end
            obj.Runtime = struct();
        end

        function releaseStimulusRuntime(obj)
            if isempty(obj.Runtime) || ~isstruct(obj.Runtime)
                return;
            end
            if isfield(obj.Runtime, 'gratingtex') && ...
                    ~isempty(obj.Runtime.gratingtex) && ~obj.SimulationMode
                try
                    Screen('Close', obj.Runtime.gratingtex);
                catch
                end
            end
            if isfield(obj.Runtime, 'gratingtex')
                obj.Runtime.gratingtex = [];
            end
            if isfield(obj.Runtime, 'phaseinc')
                obj.Runtime.phaseinc = [];
            end
            if isfield(obj.Runtime, 'gratingsize')
                obj.Runtime.gratingsize = [];
            end
        end

        function requirePreparedScreen(obj, requestedScreen, requestedSimulation)
            if ~obj.ScreenReady
                error('ZouLab:VisualScreenNotReady', ...
                    ['PTB Screen is not ready. Click Set Screen before Play ', ...
                     'Preview or Arm Visual Stimulus.']);
            end
            if obj.ScreenIndex ~= requestedScreen
                error('ZouLab:VisualScreenSelectionChanged', ...
                    ['PTB Screen %d is open, but Screen %d is selected. ', ...
                     'Close or Set Screen again before Play or Arm.'], ...
                    obj.ScreenIndex, requestedScreen);
            end
            if obj.SimulationMode ~= requestedSimulation
                error('ZouLab:VisualScreenModeMismatch', ...
                    'PTB Screen mode changed; run Set Screen again.');
            end
        end

        function value = serializableSpec(obj)
            value = obj.Spec;
            if isempty(fieldnames(value))
                return;
            end
            if isfield(value, 'colors')
                value = rmfield(value, 'colors');
            end
            if isfield(value, 'block_colors')
                value = rmfield(value, 'block_colors');
            end
        end
    end

    methods (Static)
        function spec = buildSpec(config)
            required = {'program','screen_index','duration_seconds', ...
                'frequency_hz','isi_seconds','repeats','sequence'};
            for index = 1:numel(required)
                if ~isfield(config, required{index})
                    error('ZouLab:VisualConfigMissing', ...
                        'Visual stimulus configuration is missing %s.', required{index});
                end
            end
            program = string(config.program);
            supported = ["drifting_grating","random_drifting_grating", ...
                "gray_blue_gray","gray_white_gray_black","flash", ...
                "contrast_reverse"];
            if ~ismember(program, supported)
                error('ZouLab:VisualProgramUnsupported', ...
                    'Unsupported visual stimulus program: %s.', program);
            end
            validateattributes(config.screen_index, {'numeric'}, ...
                {'scalar','integer','nonnegative','finite'});
            validateattributes(config.duration_seconds, {'numeric'}, ...
                {'scalar','positive','finite'});
            validateattributes(config.frequency_hz, {'numeric'}, ...
                {'scalar','positive','finite'});
            validateattributes(config.isi_seconds, {'numeric'}, ...
                {'scalar','nonnegative','finite'});
            validateattributes(config.repeats, {'numeric'}, ...
                {'scalar','integer','positive','finite'});
            sequence = double(config.sequence(:).');
            if isempty(sequence) || any(~isfinite(sequence))
                error('ZouLab:VisualSequenceInvalid', ...
                    'Visual sequence must contain finite numeric values.');
            end
            if ~isfield(config, 'amplitude')
                config.amplitude = 0.5;
            end
            if ~isfield(config, 'spatial_frequency_cpd')
                config.spatial_frequency_cpd = 0.04;
            end
            if ~isfield(config, 'viewing_distance_cm')
                config.viewing_distance_cm = 9;
            end
            if ~isfield(config, 'screen_width_cm')
                config.screen_width_cm = 11;
            end
            validateattributes(config.amplitude, {'numeric'}, ...
                {'scalar','finite','nonnegative','<=',1});
            validateattributes(config.spatial_frequency_cpd, {'numeric'}, ...
                {'scalar','finite','positive'});
            validateattributes(config.viewing_distance_cm, {'numeric'}, ...
                {'scalar','finite','positive'});
            validateattributes(config.screen_width_cm, {'numeric'}, ...
                {'scalar','finite','positive'});
            displayConfig = zoulab.VisualStimulusController. ...
                normalizeDisplayConfig(config);
            config.idle_color = displayConfig.idle_color;
            config.gray_color = displayConfig.gray_color;
            config.blue_color = displayConfig.blue_color;
            config.white_color = displayConfig.white_color;
            config.black_color = displayConfig.black_color;
            config.flip_deadline_fraction = ...
                displayConfig.flip_deadline_fraction;
            config.initial_phase_deg = displayConfig.initial_phase_deg;
            colors = struct('idle', displayConfig.idle_color, ...
                'gray', displayConfig.gray_color, ...
                'blue', displayConfig.blue_color, ...
                'white', displayConfig.white_color, ...
                'black', displayConfig.black_color);
            labels = struct( ...
                'drifting_grating', 'Drifting grating', ...
                'random_drifting_grating', 'Random drifting grating', ...
                'gray_blue_gray', 'Gray-Blue-Gray', ...
                'gray_white_gray_black', 'Gray-White-Gray-Black', ...
                'flash', 'Flash', ...
                'contrast_reverse', 'Contrast Reverse');
            spec = struct( ...
                'program', program, ...
                'label', string(labels.(char(program))), ...
                'screen_index', double(config.screen_index), ...
                'duration_seconds', double(config.duration_seconds), ...
                'frequency_hz', double(config.frequency_hz), ...
                'isi_seconds', double(config.isi_seconds), ...
                'repeats', double(config.repeats), ...
                'sequence', sequence, ...
                'colors', colors, ...
                'block_colors', zeros(0, 3), ...
                'block_durations', zeros(1, 0), ...
                'amplitude', double(config.amplitude), ...
                'spatial_frequency_cpd', ...
                    double(config.spatial_frequency_cpd), ...
                'viewing_distance_cm', double(config.viewing_distance_cm), ...
                'screen_width_cm', double(config.screen_width_cm), ...
                'flip_deadline_fraction', ...
                    displayConfig.flip_deadline_fraction, ...
                'initial_phase_deg', displayConfig.initial_phase_deg, ...
                'cpp', NaN, ...
                'epoch_order', "program_defined", ...
                'estimated_duration_seconds', NaN, ...
                'config', config);
            switch program
                case {"drifting_grating","random_drifting_grating"}
                    spec.epoch_order = "isi_then_grating";
                    spec.estimated_duration_seconds = numel(sequence) * ...
                        spec.repeats * (spec.duration_seconds + spec.isi_seconds);
                case "gray_blue_gray"
                    if numel(sequence) ~= 3
                        error('ZouLab:VisualSequenceLength', ...
                            'Gray-Blue-Gray requires three block durations.');
                    end
                    if any(sequence <= 0)
                        error('ZouLab:VisualDurationInvalid', ...
                            'Gray-Blue-Gray block durations must all be positive.');
                    end
                    spec.block_colors = [colors.gray; colors.blue; colors.gray];
                    spec.block_durations = sequence;
                    spec.estimated_duration_seconds = sum(sequence) * spec.repeats;
                case "gray_white_gray_black"
                    if numel(sequence) ~= 4
                        error('ZouLab:VisualSequenceLength', ...
                            'Gray-White-Gray-Black requires four block durations.');
                    end
                    if any(sequence <= 0)
                        error('ZouLab:VisualDurationInvalid', ...
                            ['Gray-White-Gray-Black block durations must all ', ...
                             'be positive.']);
                    end
                    spec.block_colors = [colors.gray; colors.white; colors.gray; colors.black];
                    spec.block_durations = sequence;
                    spec.estimated_duration_seconds = sum(sequence) * spec.repeats;
                case "flash"
                    if numel(sequence) ~= 3
                        error('ZouLab:VisualSequenceLength', ...
                            'Flash requires three block durations.');
                    end
                    if any(sequence <= 0)
                        error('ZouLab:VisualDurationInvalid', ...
                            'Flash block durations must all be positive.');
                    end
                    spec.block_colors = [colors.gray; colors.white; colors.gray];
                    spec.block_durations = sequence;
                    spec.estimated_duration_seconds = sum(sequence) * spec.repeats;
                case "white_black_flicker"
                    spec.estimated_duration_seconds = spec.duration_seconds;
                case "step_flicker"
                    if any(sequence < 0)
                        error('ZouLab:VisualFrequencyInvalid', ...
                            'Step-flicker frequencies must be nonnegative.');
                    end
                    spec.estimated_duration_seconds = numel(sequence) * ...
                        spec.duration_seconds;
                case "contrast_reverse"
                    spec.sequence = sequence(1);
                    spec.estimated_duration_seconds = spec.duration_seconds;
            end
        end

        function value = normalizeDisplayConfig(config)
            value = struct( ...
                'idle_color', [0 0 0], ...
                'gray_color', repmat(128 / 255, 1, 3), ...
                'blue_color', [0 0 1], ...
                'white_color', [1 1 1], ...
                'black_color', [0 0 0], ...
                'flip_deadline_fraction', 0.5, ...
                'initial_phase_deg', 0);
            names = ["idle_color","gray_color","blue_color", ...
                "white_color","black_color"];
            for name = names
                field = char(name);
                if isfield(config, field)
                    candidate = double(config.(field)(:).');
                    validateattributes(candidate, {'numeric'}, ...
                        {'size',[1 3],'finite','real','>=',0,'<=',1});
                    value.(field) = candidate;
                end
            end
            if isfield(config, 'flip_deadline_fraction')
                validateattributes(config.flip_deadline_fraction, {'numeric'}, ...
                    {'scalar','finite','>',0,'<=',1});
                value.flip_deadline_fraction = ...
                    double(config.flip_deadline_fraction);
            end
            if isfield(config, 'initial_phase_deg')
                validateattributes(config.initial_phase_deg, {'numeric'}, ...
                    {'scalar','finite','real'});
                value.initial_phase_deg = double(config.initial_phase_deg);
            end
        end

        function schedule = gratingEpochSchedule(spec, startTime)
            if nargin < 2
                startTime = 0;
            end
            if ~ismember(string(spec.program), ...
                    ["drifting_grating","random_drifting_grating"])
                error('ZouLab:VisualScheduleProgram', ...
                    'A grating epoch schedule requires a grating program.');
            end
            validateattributes(startTime, {'numeric'}, ...
                {'scalar','finite','nonnegative'});
            epochCount = numel(spec.sequence) * spec.repeats;
            intervalStart = zeros(epochCount, 1);
            intervalEnd = zeros(epochCount, 1);
            gratingStart = zeros(epochCount, 1);
            gratingEnd = zeros(epochCount, 1);
            cursor = double(startTime);
            for epochIndex = 1:epochCount
                intervalStart(epochIndex) = cursor;
                intervalEnd(epochIndex) = cursor + spec.isi_seconds;
                gratingStart(epochIndex) = intervalEnd(epochIndex);
                gratingEnd(epochIndex) = gratingStart(epochIndex) + ...
                    spec.duration_seconds;
                cursor = gratingEnd(epochIndex);
            end
            schedule = table(intervalStart, intervalEnd, ...
                gratingStart, gratingEnd, ...
                'VariableNames', {'IntervalStartSeconds', ...
                    'IntervalEndSeconds','GratingStartSeconds', ...
                    'GratingEndSeconds'});
        end

        function stimSpec = toLegacyStimSpec(spec, runtime, cameraFPS)
            if nargin < 2 || isempty(runtime)
                runtime = struct();
            end
            if nargin < 3
                cameraFPS = NaN;
            end
            if isempty(spec) || ~isstruct(spec) || isempty(fieldnames(spec))
                stimSpec = struct('enabled', false, 'mode', 'record');
                return;
            end
            width = 1024;
            height = 768;
            if isfield(runtime, 'windowRect') && numel(runtime.windowRect) == 4
                width = runtime.windowRect(3) - runtime.windowRect(1);
                height = runtime.windowRect(4) - runtime.windowRect(2);
            end
            grayValue = 128;
            colors = struct('gray', repmat(double(grayValue) / 255, 1, 3), ...
                'blue', [0 0 1], 'white', [1 1 1], 'black', [0 0 0]);
            stimSpec = struct( ...
                'enabled', true, 'mode', 'visualstim', ...
                'videoWidth', width, 'videoHeight', height, ...
                'camFPS', double(cameraFPS), 'grayValue', grayValue, ...
                'colors', colors, ...
                'selectedProgram', string(spec.program), ...
                'selectedLabel', string(spec.label), ...
                'blockSequence', struct('labels', {{}}, ...
                    'colors', zeros(0, 3), 'durations', [], 'repeatCount', 1), ...
                'flicker', struct('duration', [], 'frequencyHz', [], ...
                    'highColor', [], 'lowColor', []), ...
                'stepFlicker', struct('durationPerStep', [], ...
                    'frequencyHz', [], 'highColor', [], 'baselineColor', []), ...
                'contrastReverse', struct('duration', [], ...
                    'frequencyHz', [], 'angle', [], 'phase', []));
            switch string(spec.program)
                case {"drifting_grating", "random_drifting_grating"}
                    stimSpec.numorien = numel(spec.sequence);
                    stimSpec.orientations = double(spec.sequence(:).');
                    stimSpec.amp = spec.amplitude;
                    stimSpec.SF = spec.spatial_frequency_cpd;
                    stimSpec.TF = spec.frequency_hz;
                    stimSpec.distToScreen = spec.viewing_distance_cm;
                    stimSpec.screenWidthCm = spec.screen_width_cm;
                    stimSpec.totalVisualAngle = 2 * atand( ...
                        (stimSpec.screenWidthCm / 2) / stimSpec.distToScreen);
                    stimSpec.pixelsPerDegree = width / stimSpec.totalVisualAngle;
                    stimSpec.cps = stimSpec.TF;
                    stimSpec.cpp = stimSpec.SF / stimSpec.pixelsPerDegree;
                    stimSpec.duration = spec.duration_seconds;
                    stimSpec.isi = spec.isi_seconds;
                    if string(spec.program) == "random_drifting_grating"
                        stimSpec.randomDriftingGrating = struct( ...
                            'baseAngles', double(spec.sequence(:).'), ...
                            'repeatsPerAngle', double(spec.repeats));
                    end
                case {"gray_blue_gray", "gray_white_gray_black", "flash"}
                    labels = cell(1, size(spec.block_colors, 1));
                    for index = 1:numel(labels)
                        labels{index} = sprintf('block_%d', index);
                    end
                    if string(spec.program) == "gray_blue_gray"
                        labels = {'gray','blue','gray'};
                    elseif string(spec.program) == "gray_white_gray_black"
                        labels = {'gray','white','gray','black'};
                    elseif string(spec.program) == "flash"
                        labels = {'gray','white','gray'};
                    end
                    stimSpec.blockSequence = struct('labels', {labels}, ...
                        'colors', spec.block_colors, ...
                        'durations', spec.block_durations, ...
                        'repeatCount', spec.repeats);
                case "white_black_flicker"
                    stimSpec.flicker = struct('duration', spec.duration_seconds, ...
                        'frequencyHz', spec.frequency_hz, ...
                        'highColor', colors.white, 'lowColor', colors.black);
                case "step_flicker"
                    stimSpec.stepFlicker = struct( ...
                        'durationPerStep', spec.duration_seconds, ...
                        'frequencyHz', spec.sequence, ...
                        'highColor', colors.white, 'baselineColor', colors.gray);
                case "contrast_reverse"
                    stimSpec.numorien = 1;
                    stimSpec.orientations = spec.sequence(1);
                    stimSpec.amp = spec.amplitude;
                    stimSpec.SF = spec.spatial_frequency_cpd;
                    stimSpec.TF = spec.frequency_hz;
                    stimSpec.distToScreen = spec.viewing_distance_cm;
                    stimSpec.screenWidthCm = spec.screen_width_cm;
                    stimSpec.totalVisualAngle = 2 * atand( ...
                        (stimSpec.screenWidthCm / 2) / stimSpec.distToScreen);
                    stimSpec.pixelsPerDegree = width / stimSpec.totalVisualAngle;
                    stimSpec.cps = stimSpec.TF;
                    stimSpec.cpp = stimSpec.SF / stimSpec.pixelsPerDegree;
                    stimSpec.contrastReverse = struct( ...
                        'duration', spec.duration_seconds, ...
                        'frequencyHz', spec.frequency_hz, ...
                        'angle', spec.sequence(1), 'phase', 0);
            end
        end

        function config = fromLegacyStimSpec(stimSpec)
            if ~isstruct(stimSpec) || ~isfield(stimSpec, 'selectedProgram')
                error('ZouLab:LegacyStimSpecInvalid', ...
                    'The selected file does not contain stimSpec.selectedProgram.');
            end
            program = string(stimSpec.selectedProgram);
            config = struct('program', char(program), 'screen_index', 1, ...
                'duration_seconds', 2, 'frequency_hz', 2, ...
                'isi_seconds', 1, 'repeats', 1, 'sequence', 0, ...
                'amplitude', double(zoulab.VisualStimulusController.legacyField( ...
                    stimSpec, 'amp', 0.5)), ...
                'spatial_frequency_cpd', double( ...
                    zoulab.VisualStimulusController.legacyField( ...
                    stimSpec, 'SF', 0.04)), ...
                'viewing_distance_cm', double( ...
                    zoulab.VisualStimulusController.legacyField( ...
                    stimSpec, 'distToScreen', 9)), ...
                'screen_width_cm', double( ...
                    zoulab.VisualStimulusController.legacyField( ...
                    stimSpec, 'screenWidthCm', 11)));
            switch program
                case {"drifting_grating", "random_drifting_grating"}
                    config.duration_seconds = double( ...
                        zoulab.VisualStimulusController.legacyField( ...
                        stimSpec, 'duration', 2));
                    config.frequency_hz = double( ...
                        zoulab.VisualStimulusController.legacyField( ...
                        stimSpec, 'TF', 2));
                    config.isi_seconds = double( ...
                        zoulab.VisualStimulusController.legacyField( ...
                        stimSpec, 'isi', 1));
                    if program == "random_drifting_grating" && ...
                            isfield(stimSpec, 'randomDriftingGrating')
                        random = stimSpec.randomDriftingGrating;
                        config.sequence = double(random.baseAngles(:).');
                        config.repeats = double(random.repeatsPerAngle);
                    else
                        config.sequence = double(stimSpec.orientations(:).');
                    end
                case {"gray_blue_gray", "gray_white_gray_black", "flash"}
                    block = stimSpec.blockSequence;
                    config.sequence = double(block.durations(:).');
                    config.repeats = double(block.repeatCount);
                    config.duration_seconds = 1;
                    config.frequency_hz = 1;
                    config.isi_seconds = 0;
                case "white_black_flicker"
                    config.duration_seconds = double(stimSpec.flicker.duration);
                    config.frequency_hz = double(stimSpec.flicker.frequencyHz);
                    config.isi_seconds = 0;
                case "step_flicker"
                    config.duration_seconds = double( ...
                        stimSpec.stepFlicker.durationPerStep);
                    config.frequency_hz = 1;
                    config.isi_seconds = 0;
                    config.sequence = double(stimSpec.stepFlicker.frequencyHz(:).');
                case "contrast_reverse"
                    config.duration_seconds = double( ...
                        stimSpec.contrastReverse.duration);
                    config.frequency_hz = double( ...
                        stimSpec.contrastReverse.frequencyHz);
                    config.isi_seconds = 0;
                    config.sequence = double(stimSpec.contrastReverse.angle);
                otherwise
                    error('ZouLab:VisualProgramUnsupported', ...
                        'Unsupported legacy visual stimulus program: %s.', program);
            end
            zoulab.VisualStimulusController.buildSpec(config);
        end

        function config = loadLegacyConfig(filePath)
            filePath = string(filePath);
            [~, ~, extension] = fileparts(filePath);
            if strcmpi(extension, '.json')
                value = jsondecode(fileread(filePath));
            else
                value = load(filePath);
            end
            stimSpec = struct();
            if isfield(value, 'stimSpec')
                stimSpec = value.stimSpec;
            elseif isfield(value, 'manifest') && isfield(value.manifest, 'spec') && ...
                    isfield(value.manifest.spec, 'stimSpec')
                stimSpec = value.manifest.spec.stimSpec;
            elseif isfield(value, 'spec') && isfield(value.spec, 'stimSpec')
                stimSpec = value.spec.stimSpec;
            end
            if isempty(fieldnames(stimSpec))
                error('ZouLab:LegacyStimSpecMissing', ...
                    'No stimSpec was found in %s.', filePath);
            end
            config = zoulab.VisualStimulusController.fromLegacyStimSpec(stimSpec);
        end

        function value = legacyField(source, name, fallback)
            value = fallback;
            if isstruct(source) && isfield(source, name) && ...
                    ~isempty(source.(name))
                value = source.(name);
            end
        end
    end
end
