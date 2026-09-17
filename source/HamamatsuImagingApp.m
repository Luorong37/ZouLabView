classdef HamamatsuImagingApp < matlab.apps.AppBase
    %HAMAMATSUIMAGINGAPP Operator-facing dual-camera acquisition app.
    % Raw images are uint16 and are never transposed while saving.
    % Camera 1 is transposed for display and registration by default.

    properties (Access = public)
        UIFigure
    end

    properties (Access = private)
        RunState
        Acquisition
        RootGrid
        CameraPanels cell = {[], []}
        CameraAxes cell = {[], []}
        ImageHandles cell = {[], []}
        CameraTitleLabels cell = {[], []}
        CameraModeLabels cell = {[], []}
        FPSLabels cell = {[], []}
        ImagingLabels cell = {[], []}
        CameraStatusLabels cell = {[], []}
        ExposurePresetDropDowns cell = {[], []}
        ExposureFields cell = {[], []}
        ROIPresetDropDowns cell = {[], []}
        ROIFields cell = {[], []}
        BinDropDowns cell = {[], []}
        CameraApplyButtons cell = {[], []}
        CameraPreviewStartButtons cell = {[], []}
        CameraPreviewStopButtons cell = {[], []}
        CameraSnapButtons cell = {[], []}
        ContrastModes cell = {[], []}
        ContrastLowFields cell = {[], []}
        ContrastHighFields cell = {[], []}
        TransposeChecks cell = {[], []}

        OperatorNameField
        OperatorUserDropDown
        OpenUserButton
        OperatorPanel
        OperatorLamp
        OperatorStatusLabel
        CameraModeDropDown
        RootPathField
        MethodNoteField
        Camera1LabelField
        Camera2LabelField
        HardwareStatusLabel
        CameraLamps cell = {[], []}
        CameraStateLabels cell = {[], []}
        DAQLamp
        DAQStatusLabel
        LightLamp
        SpectraStateLabel
        LightStatusLabel
        LightTable
        LightIntensitySlider
        LightIntensityField
        LightIntensityUnitLabel
        ObisLamps cell = {[], []}
        ObisStatusLabels cell = {[], []}
        RegistrationStatusLabel
        AutoRegistrationButton
        ManualRegistrationButton
        LoadRegistrationButton
        AcquisitionStatusLabel
        AcquisitionStorageEstimateLabel
        AcquisitionLamp
        AcquisitionStateLabel
        AcquisitionModeDropDown
        CycleCountField
        CycleIntervalField
        RecordDurationField
        RecordLengthSourceDropDown
        RecordLengthSummaryLabel
        RecordTiffCheckBox
        TLIntervalField
        TLPointsField
        VisualStimLamp
        VisualStimStatusLabel
        LightStimLamp
        LightStimStatusLabel
        VisualProgramDropDown
        VisualScreenField
        VisualScreenSetupButton
        VisualScreenCloseButton
        VisualScreenLamp
        VisualScreenStatusLabel
        VisualDurationField
        VisualFrequencyField
        VisualISIField
        VisualRepeatsField
        VisualSequenceLabel
        VisualSequenceField
        VisualAmplitudeField
        VisualSpatialFrequencyField
        VisualViewingDistanceField
        VisualScreenWidthField
        VisualIdleColorField
        VisualBaselineColorField
        VisualWhiteColorField
        VisualBlackColorField
        VisualBlueColorField
        VisualInitialPhaseField
        VisualFlipDeadlineField
        CameraPreStimField
        CameraPostStimField
        LightLeadField
        LightTailField
        AdvancedTimingSummaryLabel
        VisualPresetDropDown
        VisualMethodNameField
        VisualPresetStatusLabel
        VisualPreviewModeDropDown
        VisualPreviewAngleField
        VisualPlayButton
        VisualStopPlaybackButton
        VisualSummaryLabel
        VisualArmButton
        VisualDisarmButton
        LedFlickerLamp
        LedFlickerStatusLabel
        LedFlickerDelayField
        LedFlickerOnField
        LedFlickerOffField
        LedFlickerCyclesField
        LedFlickerFrequencyField
        LedFlickerDoTable
        LedFlickerAoTable
        LedFlickerArmButton
        LedFlickerDisarmButton
        LedMethodDropDown
        LedMethodNameField
        LedMethodStatusLabel
        LightStimFrameworkStatusLabel
        LightStimSourceDropDown
        LightStimWaveformDropDown
        LightStimDelayField
        LightStimDurationField
        LightStimPulseWidthField
        LightStimPulsePeriodField
        LightStimDigitalRepeatField
        LightStimDigitalPointTable
        LightStimAnalogTargetDropDown
        LightStimAnalogTimingModeDropDown
        LightStimAnalogWaveformDropDown
        LightStimAnalogDelayField
        LightStimAnalogDurationField
        LightStimAnalogStepVoltagesField
        LightStimAnalogStepDurationsField
        LightStimAnalogHighVoltageField
        LightStimAnalogLowVoltageField
        LightStimAnalogOffVoltageField
        LightStimAnalogPulseWidthField
        LightStimAnalogCalculatedDurationField
        LightStimAnalogPulsePeriodField
        LightStimAnalogCustomOnsetsField
        LightStimAnalogCustomDurationsField
        LightStimAnalogCustomVoltagesField
        LightStimAnalogRepeatField
        LightStimAnalogPointTable
        LightStimAnalogGenerateButton
        LightStimDmdSwitch
        LightStimDmdPatternDropDown
        LightStimDmdLoopSwitch
        LightStimDmdRateField
        LightStimDmdPulseField
        LightStimTimelinePreviewButton
        LightStimArmButton
        LightStimDisarmButton
        DmdLamp
        DmdStatusLabel
        DmdPatternLamp
        DmdPatternStateLabel
        DmdPatternFolderField
        DmdStartPositionField
        DmdPictureCountField
        DmdTriggerTable
        DmdTriggerRepeatField
        DmdTriggerDelayField
        DmdTriggerPeriodField
        DmdTotalTriggerField
        DmdCalibrationCameraDropDown
        DmdCalibrationRootField
        DmdCalibrationTiffField
        DmdCalibrationMatrixField
        DmdCalibrationLamp
        DmdCalibrationStatusLabel
        DmdCalibrationSourceDropDown
        DmdGridModeDropDown
        DmdGridResolvedPathField
        DmdHostAddressField
        DmdHostPortField
        DmdTargetAddressField
        DmdTargetPortField
        DmdDaqPortField
        DmdInternalRateField
        DmdVerticalMirrorCheckBox
        DmdDataReverseCheckBox
        DmdRowAddressingCheckBox
        DmdInputEdgeDropDown
        DmdOutputEdgeDropDown
        DmdDividedEdgeDropDown
        DmdTriggerDivisionField
        DmdPictureCountActionDropDown
        DmdApplyParametersButton
        DmdMaskModeDropDown
        DmdMaskSourceField
        DmdMaskThresholdField
        DmdMaskMinAreaField
        DmdMaskExpansionField
        DmdMaskEachRoiCheckBox
        DmdInsertOffBetweenRoisCheckBox
        DmdMaskReverseCheckBox
        DmdMaskStatusLabel
        DmdMaskGenerateButton
        DmdBitDepthDropDown
        DmdTrailingOffPaddingCheckBox
        DmdRepeatToFillTimelineCheckBox
        DmdPauseButton
        DmdRecoverPortButton
        DmdAdminRecoverButton
        DmdTriggerModeDropDown
        DmdPlayButton
        DmdPatternSummaryLabel
        DmdMethodDropDown
        DmdMethodNameField
        DmdMethodStatusLabel
        DaqSampleRateField
        WiringJsonArea
        WiringConfigPathField
        WiringConfigStatusLabel
        LightPresetDropDown
        LightPresetNameField
        LightPresetStatusLabel
        DaqTimelineAxes
        DaqTimelineMetricsTable
        DaqTimelineStatusLabel
        MainStatusArea
        ConversionDetailArea
        LogArea
        PreviewStartButton
        PreviewStopButton
        SnapButton
        TLStartButton
        TLStopButton
        AcquisitionStartButton
        AcquisitionStopButton
        SafeExitButton

        Logger
        WiringConfig
        Cameras
        DaqController
        SpectraController
        CoherentControllers cell = {[], []}
        DmdController
        DmdGridSet struct = struct()
        DmdCalibrationData struct = struct()
        DmdOperationalPatternLoaded logical = false
        DmdMaskData struct = struct()
        DmdCompiledManifest struct = struct()
        DmdManualMaskActive logical = false
        DmdManualMaskCameraIndex double = 0
        DmdManualMaskFrame = []
        DmdManualMaskSourcePath string = ""
        DmdManualMaskOutputFolder string = ""
        DmdManualMaskPolygons cell = {}
        DmdManualMaskCurrentVertices double = zeros(0, 2)
        DmdManualMaskOverlays cell = {}
        DmdManualMaskPreviousFigureKeyPressFcn = []
        DmdManualMaskPreviousPointer string = "arrow"
        DmdManualMaskPreviousImageButtonDownFcn = []
        DmdManualMaskPreviousAxesButtonDownFcn = []
        LightStimulusController
        ModuleMethods
        ModuleMethodState struct = struct()
        VisualStimulusController
        LedFlickerController
        VisualPresets
        Sessions
        SimulationMode logical = false
        IdentityConfirmed logical = false
        UserSettingsDirty logical = false
        ManualRegistrationActive logical = false
        ManualRegistrationStage double = 0
        ManualRegistrationVertices cell = {zeros(0, 2), zeros(0, 2)}
        ManualRegistrationFrames cell = {[], []}
        ManualRegistrationOverlays cell = {[], []}
        ManualRegistrationPreviousPreview logical = false(1, 2)
        ManualRegistrationPreviousFigureKeyPressFcn = []
        ManualRegistrationPreviousPointer string = "arrow"
        ManualRegistrationPreviousImageButtonDownFcn cell = {[], []}
        ManualRegistrationPreviousAxesButtonDownFcn cell = {[], []}
        ManualRegistrationLockedControls cell = {}
        ManualRegistrationLockedEnableStates cell = {}
        SettingsDirty logical = false(1, 2)
        PreviewActive logical = false(1, 2)
        TransposeDisplay logical = [true false]
        FirstFrame logical = false(1, 2)
        ImagingSuccess logical = false(1, 2)
        LatestFrames cell = {[], []}
        PreviewFrameCounts double = [0 0]
        LastFPSSampleCounts double = [0 0]
        LastStreamFrameCounts double = [0 0]
        LastStreamCaptureTimes double = [NaN NaN]
        PreviewFPS double = [NaN NaN]
        StreamFPS double = [NaN NaN]
        StreamFPSSamples cell = {zeros(0, 2), zeros(0, 2)}
        PreviewStartTimes double = [NaN NaN]
        StreamLowSince double = [NaN NaN]
        StreamLowWarningActive logical = false(1, 2)
        RecordStatus string = ["--" "--"]
        PreviewCallbackErrors double = [0 0]
        LastRenderTime double = [0 0]
        LastContrastUpdate double = [0 0]
        PreviewClock
        LastStatusTime double = 0
        LastHealthLogTime double = 0
        LogFlushIntervalSeconds double = 60
        PreviewRenderLimitFPS double = 60
        AutoContrastLimitFPS double = 120
        AutoContrastSampleMaxPixels double = 512
        PreviewWarmupSeconds double = 2
        StreamWindowSeconds double = 2
        StreamLowDurationSeconds double = 3
        StreamWarningFraction double = 0.95
        StatusTimer = []
        LogFlushTimer = []
        SimulationTimer = []
        RemotePreviewTimer = []
        TimeLapseTimer = []
        UiRefreshDebounceTimer = []
        PendingTimelineRefresh logical = false
        PendingDoWaveformRegeneration logical = false
        PendingStorageRefresh logical = false
        PendingStorageRefreshLog logical = false
        PendingUiRefreshReason string = ""
        TimelineRefreshRunning logical = false
        DoWaveformRegenerationRunning logical = false
        UiRefreshDebounceSeconds double = 0.25
        TimeLapseIndex double = 0
        TimeLapseFolder string = ""
        TimeLapseRecords struct = struct('index', {}, 'timestamp', {}, 'files', {})
        ConversionJob = []
        ConversionTimer = []
        ConversionConfig struct = struct()
        ConversionRecordPath string = ""
        ConversionLastLoggedFraction double = -1
        ConversionLastLogTime double = 0
        CameraPreStimSeconds double = 0
        CameraPostStimSeconds double = 0
        LightLeadSeconds double = -1
        LightTailSeconds double = 0
        SimulationRecordFPS double = 10
        RegistrationResult struct = struct()
        SelectedLightRow double = 1
        LightSafetyConfirmed logical = false
        LastLayoutBucket string = ""
        ApplyingUserSettings logical = false
        IdentityGatedControls cell = {}
        IdentityGatedEnableStates cell = {}
        VisualPreviewRunning logical = false
        VisualPreviewStopRequested logical = false
        RecordImagingLightsOn logical = false
        DaqControlledLightsPrepared logical = false
        DaqTimelineHiddenNames string = strings(1, 0)
        LastDaqTimelinePlan struct = struct()
        LightStimAnalogDraft struct = struct()
        LightStimDigitalSelectedRows double = zeros(1, 0)
        LightStimAnalogSelectedRows double = zeros(1, 0)
        DmdTriggerSelectedRows double = zeros(1, 0)
        LedFlickerDoSelectedRows double = zeros(1, 0)
        LedFlickerAoSelectedRows double = zeros(1, 0)
        LightStimTimelinePreview logical = false
        WriterBackpressureActive logical = false(1, 2)
        IatProtectionTriggered logical = false
        ActiveAcquisitionWorker = []
        AppRoot string = ""
        SafeExitConfirmationProvider = []
        CameraSettingsConfirmationProvider = []
        SafeExitTerminationProvider = []
        TerminateHostOnDelete logical = false
        PreviewDiagnosticsEnabled logical = false
        PreviewDiagnosticsClock = []
        PreviewDiagnosticsData double = zeros(0, 23)
        PreviewDiagnosticsCount double = 0
        PreviewDiagnosticsPending logical = false
        PreviewDiagnosticsMemory double = zeros(0, 6)
        PreviewDiagnosticsMemoryCount double = 0
        PreviewDiagnosticsDurationSeconds double = 30
        PreviewRenderFlushStrategy string = "callback_return"
        PreviewAxesImplementation string = "axes"
        DmdCalibrationSelectionProvider = []
        ManualRegistrationArtifactFolder string = ""
    end

    methods (Access = public)
        function app = HamamatsuImagingApp(varargin)
            app.RunState = zoulab.AcquisitionState();
            parser = inputParser;
            addParameter(parser, 'SimulationMode', false, @(x) islogical(x) || isnumeric(x));
            addParameter(parser, 'PreviewDiagnostics', false, ...
                @(x) islogical(x) && isscalar(x));
            addParameter(parser, 'PreviewDiagnosticsDurationSeconds', 30, ...
                @(x) isnumeric(x) && isscalar(x) && isfinite(x) && ...
                x >= 5 && x <= 3600);
            addParameter(parser, 'PreviewRenderFlushStrategy', ...
                "callback_return", @(x) any(strcmpi(string(x), ...
                ["synchronous_drawnow","callback_return"])));
            addParameter(parser, 'PreviewAxesImplementation', "axes", ...
                @(x) any(strcmpi(string(x), ["uiaxes","axes"])));
            addParameter(parser, 'DmdCalibrationSelectionProvider', [], ...
                @(x) isempty(x) || isa(x, 'function_handle'));
            addParameter(parser, 'Visible', 'on', @(x) any(strcmpi(string(x), ["on","off"])));
            addParameter(parser, 'UserDataRoot', "", ...
                @(x) ischar(x) || isstring(x));
            % Retained only so older launch scripts do not fail. The former
            % global repository is no longer read or shown in the UI.
            addParameter(parser, 'MethodRepositoryRoot', "", ...
                @(x) ischar(x) || isstring(x));
            addParameter(parser, 'ConfirmationProvider', [], ...
                @(x) isempty(x) || isa(x, 'function_handle'));
            addParameter(parser, 'CameraSettingsConfirmationProvider', [], ...
                @(x) isempty(x) || isa(x, 'function_handle'));
            addParameter(parser, 'TerminationProvider', [], ...
                @(x) isempty(x) || isa(x, 'function_handle'));
            parse(parser, varargin{:});
            app.SimulationMode = logical(parser.Results.SimulationMode);
            app.PreviewDiagnosticsEnabled = parser.Results.PreviewDiagnostics;
            app.PreviewDiagnosticsDurationSeconds = double( ...
                parser.Results.PreviewDiagnosticsDurationSeconds);
            app.PreviewRenderFlushStrategy = lower(string( ...
                parser.Results.PreviewRenderFlushStrategy));
            app.PreviewAxesImplementation = lower(string( ...
                parser.Results.PreviewAxesImplementation));
            app.DmdCalibrationSelectionProvider = ...
                parser.Results.DmdCalibrationSelectionProvider;
            if app.PreviewDiagnosticsEnabled
                % Bounded in-memory capture; no per-frame file writes.
                app.PreviewDiagnosticsData = nan(ceil( ...
                    app.PreviewDiagnosticsDurationSeconds * 80) + 1000, 23);
                % Sampled by the 1 Hz status timer, never by the frame path.
                app.PreviewDiagnosticsMemory = nan(ceil( ...
                    app.PreviewDiagnosticsDurationSeconds) + 30, 6);
            end
            app.SafeExitConfirmationProvider = ...
                parser.Results.ConfirmationProvider;
            app.CameraSettingsConfirmationProvider = ...
                parser.Results.CameraSettingsConfirmationProvider;
            app.SafeExitTerminationProvider = ...
                parser.Results.TerminationProvider;

            classFolder = fileparts(mfilename('fullpath'));
            [~, classFolderName] = fileparts(classFolder);
            if strcmpi(classFolderName, 'source')
                appRoot = fileparts(classFolder);
            else
                appRoot = classFolder;
            end
            app.AppRoot = string(appRoot);
            userDataRoot = string(parser.Results.UserDataRoot);
            if strlength(userDataRoot) == 0
                userDataRoot = string(fullfile(appRoot, 'user_data'));
            end
            app.Logger = zoulab.AppLogger(fullfile(appRoot, 'logs'));
            app.WiringConfig = zoulab.RigWiringConfig( ...
                fullfile(appRoot, 'config', 'rig_wiring.json'));
            wiring = app.WiringConfig.load(app.Logger);
            if app.SimulationMode
                app.Cameras = zoulab.CameraManager();
                app.Cameras.SimulationMode = true;
                app.Cameras.Serials = string(wiring.camera.serials(:).');
                app.Cameras.BusTokens = string(wiring.camera.bus_tokens(:).');
            else
                % The client is lazy: no child MATLAB and no hardware object
                % exists until an identity-confirmed camera action is made.
                app.Cameras = zoulab.CameraServiceClient( ...
                    app.AppRoot, app.Logger, false);
                app.Cameras.CameraSerials = string(wiring.camera.serials(:).');
                app.Cameras.CameraBusTokens = string(wiring.camera.bus_tokens(:).');
                app.Cameras.Serials = string(wiring.camera.serials(:).');
                % This rig's .15 adaptor applies Fast/ROI correctly at start.
                % Register it only inside the camera-owning child process.
                app.Cameras.ThirdPartyAdaptorLibrary = string(fullfile( ...
                    getenv('APPDATA'), 'MathWorks', 'MATLAB Add-Ons', ...
                    'Toolboxes', 'Hamamatsu Image Acquisition', 'hamamatsu.dll'));
                app.Logger.log('INFO', 'CAMERA_ADAPTOR_SELECTED', ...
                    'Library=%s | ValidatedVersion=2.3.2300.15 | LoadScope=child_only', ...
                    app.Cameras.ThirdPartyAdaptorLibrary);
            end
            app.DaqController = zoulab.DaqLightController();
            app.DaqController.applyWiringConfig(wiring, app.Logger);
            app.SpectraController = zoulab.SpectraXSerialController();
            app.SpectraController.ConfiguredPort = string(wiring.serial.spectrax);
            app.CoherentControllers = { ...
                zoulab.CoherentObisController(string(wiring.serial.obis405), ...
                    app.SimulationMode), ...
                zoulab.CoherentObisController(string(wiring.serial.obis445), ...
                    app.SimulationMode)};
            app.DmdController = zoulab.DmdServiceClient(appRoot, ...
                fullfile(appRoot, 'vendor', 'dmd', 'win64'), ...
                app.Logger, app.SimulationMode);
            app.applyWiringToNonDaqControllers(wiring);
            app.LightStimulusController = zoulab.LightStimulusController();
            app.LightStimAnalogDraft = ...
                zoulab.StimulusWaveformCompiler.defaultAnalogWaveforms();
            app.ModuleMethods = zoulab.ModuleMethodManager();
            app.initializeModuleMethodState();
            app.VisualStimulusController = zoulab.VisualStimulusController();
            app.LedFlickerController = zoulab.LedFlickerController();
            app.VisualPresets = zoulab.VisualPresetManager(userDataRoot);
            app.Sessions = zoulab.SessionManager();
            callbacks.beginAction = ...
                @(name, message) app.beginAction(name, message, app.AcquisitionStatusLabel);
            callbacks.cancelExpensiveUiRefresh = ...
                @(varargin) app.cancelExpensiveUiRefresh(varargin{:});
            callbacks.captureCameras = ...
                @(varargin) app.captureCameras(varargin{:});
            callbacks.compileFrozenDaqPlan = ...
                @(varargin) app.compileFrozenDaqPlan(varargin{:});
            callbacks.ensureRecord = ...
                @(varargin) app.ensureRecord(varargin{:});
            callbacks.finishAction = ...
                @(name, success, message) app.finishAction(name, success, message, app.AcquisitionStatusLabel);
            callbacks.forceAcquisitionOutputsSafe = ...
                @(varargin) app.forceAcquisitionOutputsSafe(varargin{:});
            callbacks.freezeAcquisitionPlan = ...
                @(varargin) app.freezeAcquisitionPlan(varargin{:});
            callbacks.handleError = ...
                @(name, exception) app.handleError(name, exception, app.AcquisitionStatusLabel);
            callbacks.identityBlocked = ...
                @() app.identityBlocked(app.AcquisitionStatusLabel);
            callbacks.imagingLightRowsFor = ...
                @(varargin) app.imagingLightRowsFor(varargin{:});
            callbacks.lightAliases = ...
                @(varargin) app.lightAliases(varargin{:});
            callbacks.markRecordConversionSkipped = ...
                @(varargin) app.markRecordConversionSkipped(varargin{:});
            callbacks.preflightAcquisition = ...
                @(varargin) app.preflightAcquisition(varargin{:});
            callbacks.prepareRecordTask = ...
                @(varargin) app.prepareRecordTask(varargin{:});
            callbacks.cleanupRecordPreparation = ...
                @(varargin) app.cleanupRecordPreparation(varargin{:});
            callbacks.requireIdentity = ...
                @(varargin) app.requireIdentity(varargin{:});
            callbacks.restartPreviewMask = ...
                @(varargin) app.restartPreviewMask(varargin{:});
            callbacks.runRecordCycle = ...
                @(varargin) app.runRecordCycle(varargin{:});
            callbacks.saveDaqPlanArtifacts = ...
                @(varargin) app.saveDaqPlanArtifacts(varargin{:});
            callbacks.saveFrameSet = ...
                @(varargin) app.saveFrameSet(varargin{:});
            callbacks.setAcquisitionControlsLocked = ...
                @(varargin) app.setAcquisitionControlsLocked(varargin{:});
            callbacks.setAcquisitionState = ...
                @(varargin) app.setAcquisitionState(varargin{:});
            callbacks.startRecordConversionBackground = ...
                @(varargin) app.startRecordConversionBackground(varargin{:});
            callbacks.stopCameraPreview = ...
                @(varargin) app.stopCameraPreview(varargin{:});
            callbacks.updateVisualStimulusStatus = ...
                @(varargin) app.updateVisualStimulusStatus(varargin{:});
            callbacks.waitForNextCycle = ...
                @(varargin) app.waitForNextCycle(varargin{:});
            callbacks.waitInterruptible = ...
                @(varargin) app.waitInterruptible(varargin{:});
            callbacks.writeCycleManifest = ...
                @(varargin) app.writeCycleManifest(varargin{:});
            callbacks.conversionRecordPath = @() app.ConversionRecordPath;
            callbacks.previewMask = @() app.PreviewActive;
            callbacks.isPreviewActive = @(index) app.PreviewActive(index);
            callbacks.closeApp = @() delete(app);
            app.Acquisition = zoulab.AcquisitionCoordinator(app.RunState, ...
                app.Logger, app.Sessions, app.DaqController, app.Cameras, callbacks);
            app.PreviewClock = tic;
            app.createComponents();
            app.setIdentityGate(true, 'startup_operator_required');
            registerApp(app, app.UIFigure);
            app.UIFigure.Visible = char(parser.Results.Visible);
            app.startStatusTimer();
            app.startLogFlushTimer();
            app.Logger.log('INFO', 'APP_STARTED', ...
                ['MATLAB=%s | SimulationMode=%d | Layout=three_columns_plus_persistent_bottom | ', ...
                 'CameraOwnership=%s | CameraServiceStart=lazy_after_operator_action | ', ...
                 'PreviewPixels=full_resolution_uint16_memmap_latest_only | ', ...
                 ['PreviewRenderLimitFPS=%g | AutoContrastLimitFPS=%g | ', ...
                  'AutoContrastSampleMaxPixels=%g | PreviewWarmupSeconds=%g | '], ...
                 'StreamMedianWindowSeconds=%g | StreamLowWarningFraction=%g | ', ...
                 ['StreamLowDurationSeconds=%g | ', ...
                  'PreviewRenderFlush=%s | PreviewAxes=%s']], ...
                version, app.SimulationMode, app.cameraOwnershipText(), ...
                app.PreviewRenderLimitFPS, app.AutoContrastLimitFPS, ...
                app.AutoContrastSampleMaxPixels, ...
                app.PreviewWarmupSeconds, app.StreamWindowSeconds, ...
                app.StreamWarningFraction, app.StreamLowDurationSeconds, ...
                app.PreviewRenderFlushStrategy, ...
                app.PreviewAxesImplementation);
            if strlength(string(parser.Results.MethodRepositoryRoot)) > 0
                app.Logger.log('WARNING', ...
                    'LEGACY_GLOBAL_METHOD_REPOSITORY_IGNORED', ...
                    ['ConfiguredPath=%s | Reason=module_scoped_methods_only | ', ...
                     'ExistingFilesModified=0'], ...
                    string(parser.Results.MethodRepositoryRoot));
            end
            app.Logger.log('INFO', 'FPS_DISPLAY_SEMANTICS', ...
                ['Stream=2s median of physical FramesAcquired/captured-time rates after warmup | ', ...
                 'View=preview callbacks received per second | ', ...
                 'Record=saved frames in the current frame set; single-frame capture has no FPS | ', ...
                 'Preview event.FrameRate and InternalFrameRate are diagnostic-only and not displayed.']);
            app.Logger.log('INFO', 'ACQUISITION_DEFAULTS', ...
                ['Mode=Record | RecordDurationSeconds=30 | Cycles=1 | ', ...
                 'CycleIntervalSeconds=45 | CycleIntervalSemantics=start_to_start | ', ...
                 'CameraPreStimSeconds=%g | CameraPostStimSeconds=%g | ', ...
                 'LightLeadSeconds=%g | LightTailSeconds=%g | ', ...
                  'RecordCaptureFormat=bin | ConvertRecordToTiff=0 | ', ...
                  'BinSegmentSeconds=%g | BinBlockFrames=%d | ', ...
                  'WriterQueueBlocksPerCamera=%d | ', ...
                  'IatCapacity=available_memory_minus_full_writer_queue | ', ...
                  'IatProtectionFraction=%.3f | ', ...
                 'TiffSplitBytes=%g | TiffConversion=after_all_record_cycles | ', ...
                 'TiffUnit=cycle_camera | TiffUnitSuccessDeletesItsSourceBin=1 | ', ...
                 'VisualStimRequiresMode=Record | ', ...
                 'LightStimulusFrameworkOnly=0 | WiringConfig=%s'], ...
                app.CameraPreStimSeconds, app.CameraPostStimSeconds, ...
                app.LightLeadSeconds, app.LightTailSeconds, ...
                zoulab.BufferedBinRecorder.SegmentSeconds, ...
                zoulab.BufferedBinRecorder.BlockFrames, ...
                zoulab.BufferedBinRecorder.MaxInFlightBlocksPerCamera, ...
                zoulab.BufferedBinRecorder.IatProtectionFraction, ...
                zoulab.TiffStackWriter.MaxBytesPerStack, app.WiringConfig.FilePath);
            app.Logger.log('INFO', 'VISUAL_RECORD_WINDOW_COMPATIBILITY', ...
                ['DefaultCameraWindow=stimulus_only | RebuiltCompatible=1 | ', ...
                 'PreviousAppDefaultPostTailSeconds=2 | CurrentDefaultPostTailSeconds=0']);
            app.setStatus(sprintf('Ready. Log: %s', app.Logger.FilePath));
            app.refreshLogView();
            if nargout == 0
                clear app
            end
        end

        function fig = getUIFigure(app)
            fig = app.UIFigure;
        end

        function beginPreviewDiagnostics(app)
            % Public only for diagnostics: arm after every selected camera
            % has entered Preview so connection latency is not measured as
            % rendering latency. No hardware command is issued here.
            app.PreviewDiagnosticsClock = [];
            app.PreviewDiagnosticsData = nan(ceil( ...
                app.PreviewDiagnosticsDurationSeconds * 80) + 1000, 23);
            app.PreviewDiagnosticsCount = 0;
            app.PreviewDiagnosticsPending = false;
            app.PreviewDiagnosticsMemory = nan(ceil( ...
                app.PreviewDiagnosticsDurationSeconds) + 30, 6);
            app.PreviewDiagnosticsMemoryCount = 0;
            app.PreviewDiagnosticsEnabled = true;
            app.Logger.log('INFO', 'PREVIEW_DIAGNOSTICS_ARMED', ...
                ['Start=next_remote_preview_tick | RenderFlush=%s | ', ...
                 'PreviewAxes=%s | HardwareCommandsAdded=0'], ...
                app.PreviewRenderFlushStrategy, ...
                app.PreviewAxesImplementation);
        end

        function delete(app)
            % App Designer serialization can construct an incomplete object
            % whose default-valued properties are still empty and then invoke
            % its destructor.  That is not a live application session and
            % must not enter hardware cleanup.
            if isempty(app) || isempty(app.RunState)
                return;
            end
            if app.RunState.Closing
                return;
            end
            terminateHost = app.TerminateHostOnDelete;
            terminationProvider = app.SafeExitTerminationProvider;
            app.RunState.beginClose();
            app.cleanupManualRegistrationInteraction('app_close');
            app.cleanupDmdManualMaskInteraction('app_close');
            app.stopAndDeleteTimer('TimeLapseTimer');
            app.stopAndDeleteTimer('SimulationTimer');
            app.stopAndDeleteTimer('RemotePreviewTimer');
            app.stopAndDeleteTimer('StatusTimer');
            app.stopAndDeleteTimer('LogFlushTimer');
            app.stopAndDeleteTimer('UiRefreshDebounceTimer');
            app.stopAndDeleteTimer('ConversionTimer');

            % Phase 1: stop new activity and put every owned output into a
            % safe state before waiting for any child process or disk job.
            % A child may need time to drain acquired frames, but light and
            % trigger outputs must not remain active during that wait.
            app.Logger.log('INFO', 'SAFE_EXIT_PHASE_BEGIN', ...
                'Phase=quiesce_outputs_and_signal_workers');
            if ~isempty(app.ActiveAcquisitionWorker)
                try
                    app.ActiveAcquisitionWorker.requestStop('safe_app_exit');
                catch ME
                    app.Logger.logException( ...
                        'ACQUISITION_WORKER_SAFE_EXIT_STOP_REQUEST_FAILED', ME);
                end
            end
            if ~isempty(app.DaqController)
                try
                    safeOffSucceeded = app.DaqController.safeOff();
                    if safeOffSucceeded
                        app.Logger.log('SUCCESS', 'DAQ_SAFE_OFF_ON_CLOSE', ...
                            'AllOwnedOutputsWrittenToSafeState=1');
                    else
                        app.Logger.log('ERROR', 'DAQ_SAFE_OFF_ON_CLOSE_FAILED', ...
                            'AllOwnedOutputsWrittenToSafeState=0');
                    end
                catch ME
                    app.Logger.logException('DAQ_SAFE_OFF_ON_CLOSE_FAILED', ME);
                end
            end
            if ~isempty(app.VisualStimulusController)
                try
                    app.VisualStimulusController.disarm(app.Logger);
                    app.VisualStimulusController.closeScreen(app.Logger);
                catch ME
                    app.Logger.logException('VISUAL_STIM_SAFE_CLOSE_FAILED', ME);
                end
            end
            if ~isempty(app.LedFlickerController)
                try
                    app.LedFlickerController.disarm( ...
                        app.Logger, 'app_close');
                catch ME
                    app.Logger.logException( ...
                        'LED_FLICKER_SAFE_CLOSE_FAILED', ME);
                end
            end
            if ~isempty(app.LightStimulusController)
                try
                    app.LightStimulusController.disarm( ...
                        app.DmdController, app.Logger);
                catch ME
                    app.Logger.logException( ...
                        'LIGHT_STIMULUS_SAFE_CLOSE_FAILED', ME);
                end
            end
            if ~isempty(app.SpectraController)
                try
                    if app.SpectraController.Connected
                        app.SpectraController.allOff(app.Logger, 'safe_app_exit');
                    end
                catch ME
                    app.Logger.logException('SPECTRAX_SAFE_OFF_ON_CLOSE_FAILED', ME);
                end
            end
            for laserIndex = 1:numel(app.CoherentControllers)
                if ~isempty(app.CoherentControllers{laserIndex})
                    try
                        app.CoherentControllers{laserIndex}.disarm(app.Logger);
                    catch ME
                        app.Logger.logException('COHERENT_SAFE_OFF_ON_CLOSE_FAILED', ME);
                    end
                end
            end
            if ~isempty(app.DmdController)
                try
                    app.DmdController.stop(app.Logger);
                catch ME
                    app.Logger.logException('DMD_STOP_ON_CLOSE_FAILED', ME);
                end
            end
            app.Logger.log('SUCCESS', 'SAFE_EXIT_PHASE_COMPLETE', ...
                'Phase=quiesce_outputs_and_signal_workers');

            % Phase 2: reap hardware-owning child MATLAB processes before
            % spending time on settings or post-processing cleanup.
            app.Logger.log('INFO', 'SAFE_EXIT_PHASE_BEGIN', ...
                'Phase=child_process_teardown');
            if ~isempty(app.ActiveAcquisitionWorker)
                worker = app.ActiveAcquisitionWorker;
                try
                    if app.RunState.EmergencyClosing
                        worker.waitComplete(2);
                    else
                        worker.waitComplete(300);
                    end
                catch ME
                    app.Logger.logException( ...
                        'ACQUISITION_WORKER_SAFE_EXIT_FAILED', ME);
                end
                try
                    delete(worker);
                catch ME
                    app.Logger.logException( ...
                        'ACQUISITION_WORKER_CLIENT_DELETE_FAILED', ME);
                end
                app.ActiveAcquisitionWorker = [];
            end
            if ~isempty(app.Cameras)
                try
                    app.Cameras.release(app.Logger);
                catch ME
                    app.Logger.logException( ...
                        'CAMERA_SERVICE_RELEASE_ON_CLOSE_FAILED', ME);
                end
            end
            if ~isempty(app.DmdController)
                try
                    dmdExit = app.DmdController.disconnect(app.Logger);
                    app.Logger.log('INFO', 'DMD_SAFE_EXIT_RESULT_RECORDED', ...
                        'Result=%s', jsonencode(dmdExit));
                catch ME
                    app.Logger.logException('DMD_DISCONNECT_ON_CLOSE_FAILED', ME);
                end
            end
            app.shutdownRecordConversion('app_close');
            app.Logger.log('SUCCESS', 'SAFE_EXIT_PHASE_COMPLETE', ...
                'Phase=child_process_teardown');

            % Phase 3: persist user state and release controller handles.
            app.Logger.log('INFO', 'SAFE_EXIT_PHASE_BEGIN', ...
                'Phase=persist_and_disconnect_controllers');
            if app.IdentityConfirmed
                try
                    app.persistUserSettings('app_close');
                catch ME
                    app.Logger.logException('USER_SETTINGS_SAVE_ON_CLOSE_FAILED', ME);
                end
            end
            if ~isempty(app.SpectraController)
                try
                    app.SpectraController.disconnect(app.Logger);
                catch ME
                    app.Logger.logException('SPECTRAX_DISCONNECT_ON_CLOSE_FAILED', ME);
                end
            end
            for laserIndex = 1:numel(app.CoherentControllers)
                if ~isempty(app.CoherentControllers{laserIndex})
                    try
                        app.CoherentControllers{laserIndex}.disconnect(app.Logger);
                    catch ME
                        app.Logger.logException('COHERENT_DISCONNECT_ON_CLOSE_FAILED', ME);
                    end
                end
            end
            if ~isempty(app.DaqController)
                try
                    app.DaqController.disconnect(app.Logger);
                catch ME
                    app.Logger.logException('DAQ_DISCONNECT_ON_CLOSE_FAILED', ME);
                end
            end
            if ~isempty(app.Logger)
                app.Logger.log('SUCCESS', 'SAFE_EXIT_PHASE_COMPLETE', ...
                    'Phase=persist_and_disconnect_controllers');
                if terminateHost
                    app.Logger.log('INFO', 'HOST_MATLAB_EXIT_REQUESTED', ...
                        ['Reason=user_safe_exit | Timing=after_hardware_cleanup_and_log_flush | ', ...
                         'WindowHelperTermination=parent_matlab_session_exit']);
                end
                app.Logger.log('INFO', 'APP_CLOSED', 'Application shutdown completed.');
                app.Logger.close();
            end
            if ~isempty(app.UIFigure) && isvalid(app.UIFigure)
                delete(app.UIFigure);
            end
            if terminateHost
                try
                    if isempty(terminationProvider)
                        exit;
                    else
                        terminationProvider();
                    end
                catch ME
                    fprintf(2, 'ZouLab Safe Exit could not terminate MATLAB: %s\n', ...
                        ME.message);
                end
            end
        end
    end

    methods (Access = private)
        function createComponents(app)
            screenSize = get(groot, 'ScreenSize');
            margin = min(16, floor(min(screenSize(3:4)) / 50));
            figureWidth = max(1, screenSize(3) - 2 * margin);
            figureHeight = max(1, screenSize(4) - 2 * margin);
            app.UIFigure = uifigure('Visible', 'off', ...
                'Name', 'Zou Lab Hamamatsu Imaging', ...
                'Position', [screenSize(1)+margin, screenSize(2)+margin, ...
                    figureWidth, figureHeight], 'Color', [0.96 0.97 0.98]);
            app.UIFigure.AutoResizeChildren = 'off';
            app.UIFigure.CloseRequestFcn = @(~,~) app.forceWindowClose();
            app.UIFigure.SizeChangedFcn = @(~,~) app.responsiveLayout();
            if isprop(app.UIFigure, 'WindowState')
                app.UIFigure.WindowState = 'maximized';
            end

            app.RootGrid = uigridlayout(app.UIFigure, [2 3]);
            app.RootGrid.Tag = 'RootGrid';
            % The experiment column contains dense PTB/DAQ forms.  Keep it
            % wide enough for their labelled controls while preserving two
            % equal camera-preview columns.
            app.RootGrid.ColumnWidth = {'1x', '1x', 760};
            app.RootGrid.RowHeight = {'1x', 270};
            app.RootGrid.Padding = [10 10 10 10];
            app.RootGrid.ColumnSpacing = 8;
            for cameraIndex = 1:2
                app.createCameraPanel(cameraIndex);
            end
            app.createExperimentPanel();
            app.createDaqTimelinePanel();
            app.createAcquisitionPanel(app.RootGrid);
            app.refreshDaqTimeline('startup');
            app.updateCameraLayout();
            app.responsiveLayout();
        end

        function createCameraPanel(app, cameraIndex)
            callbacks = struct();
            callbacks.applyCameraSettings = ...
                @(varargin) app.applyCameraSettings(varargin{:});
            callbacks.applyContrast = ...
                @(varargin) app.applyContrast(varargin{:});
            callbacks.binChanged = ...
                @(varargin) app.binChanged(varargin{:});
            callbacks.contrastBoundEdited = ...
                @(varargin) app.contrastBoundEdited(varargin{:});
            callbacks.contrastModeChanged = ...
                @(varargin) app.contrastModeChanged(varargin{:});
            callbacks.exposurePresetChanged = ...
                @(varargin) app.exposurePresetChanged(varargin{:});
            callbacks.exposureValueEdited = ...
                @(varargin) app.exposureValueEdited(varargin{:});
            callbacks.previewFrameCallback = ...
                @(varargin) app.previewFrameCallback(varargin{:});
            callbacks.roiPresetChanged = ...
                @(varargin) app.roiPresetChanged(varargin{:});
            callbacks.roiValueEdited = ...
                @(varargin) app.roiValueEdited(varargin{:});
            callbacks.startCameraPreviewClicked = ...
                @(varargin) app.startCameraPreviewClicked(varargin{:});
            callbacks.stopCameraPreview = ...
                @(varargin) app.stopCameraPreview(varargin{:});
            callbacks.takeSnap = ...
                @(varargin) app.takeSnap(varargin{:});
            callbacks.transposeChanged = ...
                @(varargin) app.transposeChanged(varargin{:});
            view = zoulab.ui.CameraPanel(app.RootGrid, cameraIndex, ...
                app.TransposeDisplay(cameraIndex), callbacks, ...
                app.PreviewAxesImplementation);
            app.BinDropDowns{cameraIndex} = view.BinDropDowns;
            app.CameraApplyButtons{cameraIndex} = view.CameraApplyButtons;
            app.CameraAxes{cameraIndex} = view.CameraAxes;
            app.CameraModeLabels{cameraIndex} = view.CameraModeLabels;
            app.CameraPanels{cameraIndex} = view.CameraPanels;
            app.CameraPreviewStartButtons{cameraIndex} = view.CameraPreviewStartButtons;
            app.CameraPreviewStopButtons{cameraIndex} = view.CameraPreviewStopButtons;
            app.CameraSnapButtons{cameraIndex} = view.CameraSnapButtons;
            app.CameraStatusLabels{cameraIndex} = view.CameraStatusLabels;
            app.CameraTitleLabels{cameraIndex} = view.CameraTitleLabels;
            app.ContrastHighFields{cameraIndex} = view.ContrastHighFields;
            app.ContrastLowFields{cameraIndex} = view.ContrastLowFields;
            app.ContrastModes{cameraIndex} = view.ContrastModes;
            app.ExposureFields{cameraIndex} = view.ExposureFields;
            app.ExposurePresetDropDowns{cameraIndex} = view.ExposurePresetDropDowns;
            app.FPSLabels{cameraIndex} = view.FPSLabels;
            app.ImageHandles{cameraIndex} = view.ImageHandles;
            app.ImagingLabels{cameraIndex} = view.ImagingLabels;
            app.ROIFields{cameraIndex} = view.ROIFields;
            app.ROIPresetDropDowns{cameraIndex} = view.ROIPresetDropDowns;
            app.TransposeChecks{cameraIndex} = view.TransposeChecks;
            app.updateCameraTitle(cameraIndex);
            app.updateCameraModeLabel(cameraIndex, 'requested');
        end

        function createExperimentPanel(app)
            outer = uipanel(app.RootGrid, 'Title', 'Experiment & Save', ...
                'FontWeight', 'bold', 'FontSize', 14);
            outer.Layout.Row = 1;
            outer.Layout.Column = 3;
            outerGrid = uigridlayout(outer, [1 1]);
            outerGrid.Padding = [4 4 4 4];
            tabs = uitabgroup(outerGrid, 'SelectionChangedFcn', ...
                @(~,event) app.experimentTabChanged(event));
            home = uitab(tabs, 'Title', 'Home');
            visual = uitab(tabs, 'Title', 'Visual Stimulus');
            lightStimulus = uitab(tabs, 'Title', 'Light Stimulus');
            advanced = uitab(tabs, 'Title', 'Advanced');
            details = uitab(tabs, 'Title', 'Developer & Logs');

            homeGrid = uigridlayout(home, [6 1]);
            % responsiveLayout increases the Light Sources row on tall
            % displays; 350 px remains the readable minimum on smaller ones.
            homeGrid.RowHeight = {126,126,122,350,92,62};
            homeGrid.Tag = 'HomeTabGrid';
            homeGrid.Padding = [6 6 6 6];
            homeGrid.RowSpacing = 6;
            if isprop(homeGrid, 'Scrollable')
                homeGrid.Scrollable = 'on';
            end
            app.createOperatorPanel(homeGrid);
            app.createSessionPanel(homeGrid);
            app.createHardwarePanel(homeGrid);
            app.createLightPanel(homeGrid);
            app.createRegistrationPanel(homeGrid);
            app.MainStatusArea = uitextarea(homeGrid, 'Editable', 'off', ...
                'Value', {'Ready'}, 'FontName', 'Consolas', 'Tag', 'MainStatusArea');
            app.createAdvancedTab(advanced);
            app.createVisualStimulusTab(visual);
            app.createLightStimulusTab(lightStimulus);
            app.createDetailsTab(details);
        end

        function createOperatorPanel(app, parent)
            panel = uipanel(parent, 'Title', 'Operator', 'Tag', 'OperatorPanel');
            app.OperatorPanel = panel;
            grid = uigridlayout(panel, [3 3]);
            grid.RowHeight = {30,30,26};
            grid.ColumnWidth = {58,'1x',150};
            grid.Padding = [5 4 5 4];
            grid.RowSpacing = 2;
            uilabel(grid, 'Text', 'Existing');
            app.OperatorUserDropDown = uidropdown(grid, ...
                'Items', {'(no users)'}, 'ItemsData', {''}, ...
                'Tag', 'OperatorUserDropDown', ...
                'ValueChangedFcn', @(source,event) app.userSelectionChanged( ...
                    event.PreviousValue, source.Value));
            app.OperatorUserDropDown.Layout.Column = 2;
            app.OpenUserButton = uibutton(grid, 'push', 'Text', 'Start Session', ...
                'Tag', 'OpenUserButton', ...
                'ButtonPushedFcn', @(~,~) app.openUser());
            app.OpenUserButton.Layout.Row = [1 2];
            app.OpenUserButton.Layout.Column = 3;
            nameLabel = uilabel(grid, 'Text', 'Name');
            nameLabel.Layout.Row = 2;
            nameLabel.Layout.Column = 1;
            app.OperatorNameField = uieditfield(grid, 'text', ...
                'Placeholder', 'Enter your name', 'Tag', 'OperatorNameField', ...
                'ValueChangedFcn', @(source,event) app.operatorNameEdited( ...
                    event.PreviousValue, source.Value));
            app.OperatorNameField.Layout.Row = 2;
            app.OperatorNameField.Layout.Column = 2;
            operatorState = uigridlayout(grid, [1 2]);
            operatorState.Layout.Column = [1 3];
            operatorState.ColumnWidth = {22,'1x'};
            operatorState.Padding = [0 0 0 0];
            operatorState.ColumnSpacing = 5;
            app.OperatorLamp = uilamp(operatorState, ...
                'Color', [0.65 0.65 0.65], 'Tag', 'OperatorLamp');
            app.OperatorStatusLabel = uilabel(operatorState, 'Text', 'Not confirmed', ...
                'FontColor', [0.75 0.15 0.12], 'Tag', 'OperatorStatusLabel');
            app.refreshUserDropDown();
            app.updateOperatorActionAvailability();
        end

        function createSessionPanel(app, parent)
            panel = uipanel(parent, 'Title', 'Experiment & Save');
            grid = uigridlayout(panel, [3 1]);
            grid.RowHeight = {30,30,24};
            grid.Padding = [5 4 5 4];
            modePath = uigridlayout(grid, [1 5]);
            modePath.ColumnWidth = {40,120,58,'1x',74};
            modePath.Padding = [0 0 0 0];
            uilabel(modePath, 'Text', 'Mode');
            app.CameraModeDropDown = uidropdown(modePath, ...
                'Items', {'Dual','Camera 1 only','Camera 2 only'}, 'Value', 'Dual', ...
                'Tag', 'CameraModeDropDown', 'ValueChangedFcn', @(~,~) app.cameraModeChanged());
            uilabel(modePath, 'Text', 'Save root');
            app.RootPathField = uieditfield(modePath, 'text', ...
                'Value', char(app.AppRoot), 'Tag', 'RootPathField', ...
                'ValueChangedFcn', @(source,event) app.textSettingEdited( ...
                    'SaveRoot', event.PreviousValue, source.Value));
            uibutton(modePath, 'push', 'Text', 'Browse', ...
                'Tag', 'BrowseRootButton', 'ButtonPushedFcn', @(~,~) app.chooseRoot());
            naming = uigridlayout(grid, [1 6]);
            naming.ColumnWidth = {46,'1x',38,65,38,65};
            naming.Padding = [0 0 0 0];
            uilabel(naming, 'Text', 'Note');
            app.MethodNoteField = uieditfield(naming, 'text', 'Value', 'default', ...
                'ValueChangedFcn', @(source,event) app.textSettingEdited( ...
                    'Method', event.PreviousValue, source.Value));
            uilabel(naming, 'Text', 'Cam1');
            app.Camera1LabelField = uieditfield(naming, 'text', 'Value', 'cyan', ...
                'ValueChangedFcn', @(source,event) app.textSettingEdited( ...
                    'Cam1Label', event.PreviousValue, source.Value));
            uilabel(naming, 'Text', 'Cam2');
            app.Camera2LabelField = uieditfield(naming, 'text', 'Value', 'red', ...
                'ValueChangedFcn', @(source,event) app.textSettingEdited( ...
                    'Cam2Label', event.PreviousValue, source.Value));
            uilabel(grid, ...
                'Text', ['Record: RecN_note_YYMMDDhhmm | module methods are ', ...
                    'selected inside Visual Stimulus and Light Stimulus'], ...
                'FontColor', [0.3 0.3 0.3], ...
                'Tag', 'RecordMethodSummaryLabel');
        end

        function createModuleMethodPanel(app, parent, moduleName, titleText)
            moduleName = string(moduleName);
            panel = uipanel(parent, 'Title', titleText, ...
                'Tag', char(app.moduleMethodTag(moduleName, 'Panel')));
            grid = uigridlayout(panel, [3 3]);
            grid.RowHeight = {26,26,22};
            grid.ColumnWidth = {56,'1x',72};
            grid.Padding = [5 3 5 3];
            grid.RowSpacing = 2;
            uilabel(grid, 'Text', 'Method');
            dropDown = uidropdown(grid, ...
                'Items', {'Manual / current settings'}, ...
                'Value', 'Manual / current settings', ...
                'Tag', char(app.moduleMethodTag(moduleName, 'DropDown')), ...
                'ValueChangedFcn', @(source,event) ...
                    app.moduleMethodSelectionChanged(moduleName, ...
                    event.PreviousValue, source.Value));
            loadButton = uibutton(grid, 'push', 'Text', 'Load', ...
                'Tag', char(app.moduleMethodTag(moduleName, 'LoadButton')), ...
                'ButtonPushedFcn', @(~,~) app.loadModuleMethod(moduleName));
            uilabel(grid, 'Text', 'Name');
            nameField = uieditfield(grid, 'text', ...
                'Placeholder', 'New method name', ...
                'Tag', char(app.moduleMethodTag(moduleName, 'NameField')));
            saveButton = uibutton(grid, 'push', 'Text', 'Save As', ...
                'Tag', char(app.moduleMethodTag(moduleName, 'SaveButton')), ...
                'ButtonPushedFcn', @(~,~) app.saveModuleMethod(moduleName));
            statusLabel = uilabel(grid, ...
                'Text', 'Start a user session to use methods.', ...
                'FontColor', [0.30 0.30 0.30], ...
                'Tag', char(app.moduleMethodTag(moduleName, 'StatusLabel')));
            statusLabel.Layout.Column = [1 3];
            switch moduleName
                case "visual_ptb"
                    app.VisualPresetDropDown = dropDown;
                    app.VisualMethodNameField = nameField;
                    app.VisualPresetStatusLabel = statusLabel;
                case "visual_led"
                    app.LedMethodDropDown = dropDown;
                    app.LedMethodNameField = nameField;
                    app.LedMethodStatusLabel = statusLabel;
                case "light_stim_laser"
                    app.LightPresetDropDown = dropDown;
                    app.LightPresetNameField = nameField;
                    app.LightPresetStatusLabel = statusLabel;
                case "dmd"
                    app.DmdMethodDropDown = dropDown;
                    app.DmdMethodNameField = nameField;
                    app.DmdMethodStatusLabel = statusLabel;
            end
        end

        function createHardwarePanel(app, parent)
            panel = uipanel(parent, 'Title', 'Hardware');
            grid = uigridlayout(panel, [3 1]);
            grid.RowHeight = {34,28,24};
            grid.Padding = [5 4 5 4];
            grid.RowSpacing = 3;
            buttons = uigridlayout(grid, [1 2]);
            buttons.ColumnWidth = {'1x','1x'};
            buttons.Padding = [0 0 0 0];
            uibutton(buttons, 'push', 'Text', 'Connect camera(s)', ...
                'Tag', 'ConnectCamerasButton', 'ButtonPushedFcn', @(~,~) app.connectCameras());
            uibutton(buttons, 'push', 'Text', 'Connect DAQ', ...
                'Tag', 'ConnectDAQButton', 'ButtonPushedFcn', @(~,~) app.connectDAQ());
            indicators = uigridlayout(grid, [1 3]);
            indicators.ColumnWidth = {'1x','1x','1x'};
            indicators.Padding = [0 0 0 0];
            indicators.ColumnSpacing = 6;
            for cameraIndex = 1:2
                cameraState = uigridlayout(indicators, [1 2]);
                cameraState.ColumnWidth = {22,'1x'};
                cameraState.Padding = [0 0 0 0];
                app.CameraLamps{cameraIndex} = uilamp(cameraState, ...
                    'Color', [0.65 0.65 0.65], ...
                    'Tag', sprintf('Camera%dLamp', cameraIndex));
                app.CameraStateLabels{cameraIndex} = uilabel(cameraState, ...
                    'Text', sprintf('CAM%d OFF', cameraIndex), 'FontWeight', 'bold');
            end
            daqState = uigridlayout(indicators, [1 2]);
            daqState.ColumnWidth = {22,'1x'};
            daqState.Padding = [0 0 0 0];
            app.DAQLamp = uilamp(daqState, ...
                'Color', [0.65 0.65 0.65], 'Tag', 'DAQLamp');
            app.DAQStatusLabel = uilabel(daqState, ...
                'Text', 'DAQ OFF', 'FontWeight', 'bold', ...
                'Tag', 'DAQStatusLabel');
            app.HardwareStatusLabel = uilabel(grid, ...
                'Text', 'Ready to connect hardware.', 'Tag', 'HardwareActionStatus');
        end

        function createLightPanel(app, parent)
            callbacks = struct();
            callbacks.allLightsOff = ...
                @(varargin) app.allLightsOff(varargin{:});
            callbacks.connectLightSources = ...
                @(varargin) app.connectLightSources(varargin{:});
            callbacks.lightNumericChanged = ...
                @(varargin) app.lightNumericChanged(varargin{:});
            callbacks.lightSelectionChanged = ...
                @(varargin) app.lightSelectionChanged(varargin{:});
            callbacks.lightSliderChanged = ...
                @(varargin) app.lightSliderChanged(varargin{:});
            callbacks.lightSliderChanging = ...
                @(varargin) app.lightSliderChanging(varargin{:});
            callbacks.lightTableEdited = ...
                @(varargin) app.lightTableEdited(varargin{:});
            callbacks.refreshLightSources = ...
                @(varargin) app.refreshLightSources(varargin{:});
            view = zoulab.ui.LightSourcesPanel(parent, callbacks);
            app.LightIntensityField = view.LightIntensityField;
            app.LightIntensitySlider = view.LightIntensitySlider;
            app.LightIntensityUnitLabel = view.LightIntensityUnitLabel;
            app.LightLamp = view.LightLamp;
            app.LightStatusLabel = view.LightStatusLabel;
            app.LightTable = view.LightTable;
            app.ObisLamps = view.ObisLamps;
            app.ObisStatusLabels = view.ObisStatusLabels;
            app.SpectraStateLabel = view.SpectraStateLabel;
        end

        function createRegistrationPanel(app, parent)
            panel = uipanel(parent, 'Title', 'Registration (Dual only; light auto ON/OFF)');
            grid = uigridlayout(panel, [2 3]);
            grid.RowHeight = {34,24};
            grid.ColumnWidth = {'1x','1x','1x'};
            grid.Padding = [5 4 5 4];
            app.AutoRegistrationButton = uibutton(grid, 'push', 'Text', 'Auto Register', ...
                'Tag', 'AutoRegistrationButton', ...
                'ButtonPushedFcn', @(~,~) app.runRegistration('auto'));
            app.ManualRegistrationButton = uibutton(grid, 'push', 'Text', 'Manual Register', ...
                'Tag', 'ManualRegistrationButton', ...
                'ButtonPushedFcn', @(~,~) app.runRegistration('manual'));
            app.LoadRegistrationButton = uibutton(grid, 'push', ...
                'Text', 'Load', 'Tag', 'LoadRegistrationButton', ...
                'ButtonPushedFcn', @(~,~) app.loadRegistration());
            app.RegistrationStatusLabel = uilabel(grid, 'Text', 'Ready', ...
                'Tag', 'RegistrationStatusLabel');
            app.RegistrationStatusLabel.Layout.Column = [1 3];
        end

        function createAcquisitionPanel(app, parent)
            callbacks = struct();
            callbacks.acquisitionModeChanged = ...
                @(varargin) app.acquisitionModeChanged(varargin{:});
            callbacks.acquisitionSettingEdited = ...
                @(varargin) app.acquisitionSettingEdited(varargin{:});
            callbacks.recordLengthSourceChanged = ...
                @(varargin) app.recordLengthSourceChanged(varargin{:});
            callbacks.safeExitClicked = ...
                @(varargin) app.safeExitClicked(varargin{:});
            callbacks.startAcquisition = ...
                @(varargin) app.startAcquisition(varargin{:});
            callbacks.requestAcquisitionStop = @() app.Acquisition.requestAcquisitionStop();
            view = zoulab.ui.AcquisitionPanel(parent, parent == app.RootGrid, callbacks);
            app.AcquisitionLamp = view.AcquisitionLamp;
            app.AcquisitionModeDropDown = view.AcquisitionModeDropDown;
            app.AcquisitionStartButton = view.AcquisitionStartButton;
            app.AcquisitionStateLabel = view.AcquisitionStateLabel;
            app.AcquisitionStatusLabel = view.AcquisitionStatusLabel;
            app.AcquisitionStopButton = view.AcquisitionStopButton;
            app.AcquisitionStorageEstimateLabel = view.AcquisitionStorageEstimateLabel;
            app.CycleCountField = view.CycleCountField;
            app.CycleIntervalField = view.CycleIntervalField;
            app.LightStimLamp = view.LightStimLamp;
            app.LightStimStatusLabel = view.LightStimStatusLabel;
            app.RecordDurationField = view.RecordDurationField;
            app.RecordLengthSourceDropDown = view.RecordLengthSourceDropDown;
            app.RecordLengthSummaryLabel = view.RecordLengthSummaryLabel;
            app.RecordTiffCheckBox = view.RecordTiffCheckBox;
            app.SafeExitButton = view.SafeExitButton;
            app.TLIntervalField = view.TLIntervalField;
            app.TLPointsField = view.TLPointsField;
            app.VisualStimLamp = view.VisualStimLamp;
            app.VisualStimStatusLabel = view.VisualStimStatusLabel;
            app.acquisitionModeChanged('', app.AcquisitionModeDropDown.Value, false);
        end

        function createVisualStimulusTab(app, parent)
            callbacks = struct();
            callbacks.armVisualStimulus = ...
                @(varargin) app.armVisualStimulus(varargin{:});
            callbacks.closeVisualScreen = ...
                @(varargin) app.closeVisualScreen(varargin{:});
            callbacks.createModuleMethodPanel = ...
                @(varargin) app.createModuleMethodPanel(varargin{:});
            callbacks.disarmVisualStimulus = ...
                @(varargin) app.disarmVisualStimulus(varargin{:});
            callbacks.playVisualPreview = ...
                @(varargin) app.playVisualPreview(varargin{:});
            callbacks.setupVisualScreen = ...
                @(varargin) app.setupVisualScreen(varargin{:});
            callbacks.stopVisualPreview = ...
                @(varargin) app.stopVisualPreview(varargin{:});
            callbacks.visualPreviewModeChanged = ...
                @(varargin) app.visualPreviewModeChanged(varargin{:});
            callbacks.visualProgramChanged = ...
                @(varargin) app.visualProgramChanged(varargin{:});
            callbacks.visualSettingEdited = ...
                @(varargin) app.visualSettingEdited(varargin{:});
            view = zoulab.ui.VisualStimulusPanel(parent, callbacks);
            app.VisualArmButton = view.VisualArmButton;
            app.VisualDisarmButton = view.VisualDisarmButton;
            app.VisualDurationField = view.VisualDurationField;
            app.VisualFrequencyField = view.VisualFrequencyField;
            app.VisualISIField = view.VisualISIField;
            app.VisualPlayButton = view.VisualPlayButton;
            app.VisualPreviewAngleField = view.VisualPreviewAngleField;
            app.VisualPreviewModeDropDown = view.VisualPreviewModeDropDown;
            app.VisualProgramDropDown = view.VisualProgramDropDown;
            app.VisualRepeatsField = view.VisualRepeatsField;
            app.VisualScreenCloseButton = view.VisualScreenCloseButton;
            app.VisualScreenField = view.VisualScreenField;
            app.VisualScreenLamp = view.VisualScreenLamp;
            app.VisualScreenSetupButton = view.VisualScreenSetupButton;
            app.VisualScreenStatusLabel = view.VisualScreenStatusLabel;
            app.VisualSequenceField = view.VisualSequenceField;
            app.VisualSequenceLabel = view.VisualSequenceLabel;
            app.VisualStopPlaybackButton = view.VisualStopPlaybackButton;
            app.VisualSummaryLabel = view.VisualSummaryLabel;
            app.visualProgramChanged('', app.VisualProgramDropDown.Value, false);
            app.refreshModuleMethodDropDown('visual_ptb');
            app.updateVisualScreenStatus();
            app.createLedFlickerPanel(view.LedTab);
        end

        function createLedFlickerPanel(app, parent)
            callbacks = struct();
            callbacks.armLedFlicker = ...
                @(varargin) app.armLedFlicker(varargin{:});
            callbacks.createModuleMethodPanel = ...
                @(varargin) app.createModuleMethodPanel(varargin{:});
            callbacks.disarmLedFlicker = ...
                @(varargin) app.disarmLedFlicker(varargin{:});
            callbacks.generateLedFlickerPreset = ...
                @(varargin) app.generateLedFlickerPreset(varargin{:});
            callbacks.ledFlickerAoEdited = ...
                @(varargin) app.ledFlickerAoEdited(varargin{:});
            callbacks.ledFlickerDoEdited = ...
                @(varargin) app.ledFlickerDoEdited(varargin{:});
            callbacks.ledFlickerRowsSelected = ...
                @(varargin) app.ledFlickerRowsSelected(varargin{:});
            callbacks.ledFlickerSettingEdited = ...
                @(varargin) app.ledFlickerSettingEdited(varargin{:});
            callbacks.ledFlickerTableButtons = ...
                @(varargin) app.ledFlickerTableButtons(varargin{:});
            callbacks.resetLedFlicker = ...
                @(varargin) app.resetLedFlicker(varargin{:});
            view = zoulab.ui.LedFlickerPanel(parent, callbacks);
            app.LedFlickerAoTable = view.LedFlickerAoTable;
            app.LedFlickerArmButton = view.LedFlickerArmButton;
            app.LedFlickerCyclesField = view.LedFlickerCyclesField;
            app.LedFlickerDelayField = view.LedFlickerDelayField;
            app.LedFlickerDisarmButton = view.LedFlickerDisarmButton;
            app.LedFlickerDoTable = view.LedFlickerDoTable;
            app.LedFlickerFrequencyField = view.LedFlickerFrequencyField;
            app.LedFlickerLamp = view.LedFlickerLamp;
            app.LedFlickerOffField = view.LedFlickerOffField;
            app.LedFlickerOnField = view.LedFlickerOnField;
            app.LedFlickerStatusLabel = view.LedFlickerStatusLabel;
            app.refreshModuleMethodDropDown('visual_led');
        end

        function ledFlickerTableButtons(app, parent, tableName)
            labels = {'Add','Insert','Delete','Clear','Reset'};
            for index = 1:numel(labels)
                action = lower(labels{index});
                uibutton(parent, 'push', 'Text', labels{index}, ...
                    'ButtonPushedFcn', @(~,~) ...
                    app.ledFlickerTableAction(tableName, action));
            end
        end

        function ledFlickerRowsSelected(app, tableName, indices)
            rows = unique(indices(:, 1)).';
            if string(tableName) == "do"
                app.LedFlickerDoSelectedRows = rows;
            else
                app.LedFlickerAoSelectedRows = rows;
            end
        end

        function generateLedFlickerPreset(app)
            app.beginAction('GENERATE_LED_FLICKER_PRESET', ...
                'Generating finite LED DO/AO tables...', ...
                app.LedFlickerStatusLabel);
            try
                points = zoulab.LedFlickerController.generatePreset( ...
                    app.LedFlickerOnField.Value, ...
                    app.LedFlickerOffField.Value, ...
                    round(app.LedFlickerCyclesField.Value), ...
                    app.LedFlickerFrequencyField.Value, ...
                    app.DaqController.LedFlickerHzPerVolt);
                app.LedFlickerDoTable.Data = points.do_points;
                app.LedFlickerAoTable.Data = points.ao_points;
                app.ledFlickerConfigurationChanged('preset_generated');
                app.finishAction('GENERATE_LED_FLICKER_PRESET', true, ...
                    sprintf('%d cycle(s), %.4g Hz LED plan generated.', ...
                    round(app.LedFlickerCyclesField.Value), ...
                    app.LedFlickerFrequencyField.Value), ...
                    app.LedFlickerStatusLabel);
            catch ME
                app.handleError('GENERATE_LED_FLICKER_PRESET_FAILED', ...
                    ME, app.LedFlickerStatusLabel);
            end
        end

        function ledFlickerDoEdited(app, source, event)
            previous = source.Data;
            previous(event.Indices(1), event.Indices(2)) = event.PreviousData;
            try
                app.ledFlickerConfigurationChanged('do_table_edited');
            catch ME
                source.Data = previous;
                app.Logger.logException('LED_FLICKER_DO_EDIT_REJECTED', ME);
                app.LedFlickerStatusLabel.Text = "Invalid DO table: " + ...
                    string(ME.message);
            end
        end

        function ledFlickerAoEdited(app, source, event)
            previous = source.Data;
            previous(event.Indices(1), event.Indices(2)) = event.PreviousData;
            try
                data = double(source.Data);
                row = event.Indices(1);
                column = event.Indices(2);
                scale = app.DaqController.LedFlickerHzPerVolt;
                if column == 2
                    data(row, 3) = zoulab.LedFlickerController. ...
                        hzToVoltage(data(row, 2), scale);
                elseif column == 3
                    data(row, 2) = zoulab.LedFlickerController. ...
                        voltageToHz(data(row, 3), scale);
                end
                source.Data = data;
                app.ledFlickerConfigurationChanged('ao_table_edited');
            catch ME
                source.Data = previous;
                app.Logger.logException('LED_FLICKER_AO_EDIT_REJECTED', ME);
                app.LedFlickerStatusLabel.Text = "Invalid AO table: " + ...
                    string(ME.message);
            end
        end

        function ledFlickerSettingEdited(app, settingName, previousValue, newValue)
            app.Logger.log('INFO', 'USER_LED_FLICKER_SETTING_EDITED', ...
                'Setting=%s | Previous=%s | New=%s', settingName, ...
                string(previousValue), string(newValue));
            app.ledFlickerConfigurationChanged( ...
                "setting_" + string(settingName));
        end

        function ledFlickerTableAction(app, tableName, action)
            app.Logger.log('INFO', 'USER_LED_FLICKER_TABLE_ACTION', ...
                'Table=%s | Action=%s', tableName, action);
            if string(tableName) == "do"
                tableHandle = app.LedFlickerDoTable;
                selected = app.LedFlickerDoSelectedRows;
                safeRow = [0 0];
            else
                tableHandle = app.LedFlickerAoTable;
                selected = app.LedFlickerAoSelectedRows;
                safeRow = [0 0 0];
            end
            data = double(tableHandle.Data);
            switch string(action)
                case "add"
                    if size(data, 1) < 2
                        data = [safeRow; safeRow + [1 zeros(1, size(data,2)-1)]];
                    else
                        newRow = (data(end - 1, :) + data(end, :)) / 2;
                        data = [data(1:end - 1, :); newRow; data(end, :)];
                    end
                case "insert"
                    if isempty(selected)
                        app.ledFlickerTableAction(tableName, 'add');
                        return;
                    end
                    row = min(max(1, selected(1)), size(data, 1) - 1);
                    newRow = (data(row, :) + data(row + 1, :)) / 2;
                    data = [data(1:row, :); newRow; data(row + 1:end, :)];
                case "delete"
                    selected = intersect(selected, 2:size(data, 1) - 1);
                    if isempty(selected)
                        app.LedFlickerStatusLabel.Text = ...
                            'Select an interior row before Delete.';
                        return;
                    end
                    data(selected, :) = [];
                case "clear"
                    if string(tableName) == "do"
                        data = [0 0; 1 0];
                    else
                        data = [0 0 0; 1 0 0];
                    end
                case "reset"
                    defaults = zoulab.LedFlickerController.defaultSpec();
                    if string(tableName) == "do"
                        data = defaults.do_points;
                    else
                        data = defaults.ao_points;
                    end
            end
            tableHandle.Data = data;
            app.ledFlickerConfigurationChanged( ...
                "table_" + string(tableName) + "_" + string(action));
        end

        function resetLedFlicker(app)
            defaults = zoulab.LedFlickerController.defaultSpec();
            app.LedFlickerDelayField.Value = defaults.delay_seconds;
            app.LedFlickerDoTable.Data = defaults.do_points;
            app.LedFlickerAoTable.Data = defaults.ao_points;
            app.LedFlickerOnField.Value = 1;
            app.LedFlickerOffField.Value = 0;
            app.LedFlickerCyclesField.Value = 1;
            app.LedFlickerFrequencyField.Value = 60;
            app.ledFlickerConfigurationChanged('reset_default');
        end

        function spec = currentLedFlickerSpec(app)
            spec = struct( ...
                'delay_seconds', app.LedFlickerDelayField.Value, ...
                'hz_per_volt', app.DaqController.LedFlickerHzPerVolt, ...
                'helper_on_seconds', app.LedFlickerOnField.Value, ...
                'helper_off_seconds', app.LedFlickerOffField.Value, ...
                'helper_cycles', round(app.LedFlickerCyclesField.Value), ...
                'helper_frequency_hz', app.LedFlickerFrequencyField.Value, ...
                'do_points', double(app.LedFlickerDoTable.Data), ...
                'ao_points', double(app.LedFlickerAoTable.Data));
        end

        function applyLedFlickerMethodSpec(app, spec)
            defaults = zoulab.LedFlickerController.defaultSpec();
            app.LedFlickerDelayField.Value = app.structFieldOr( ...
                spec, 'delay_seconds', defaults.delay_seconds);
            app.LedFlickerDoTable.Data = app.structFieldOr( ...
                spec, 'do_points', defaults.do_points);
            app.LedFlickerAoTable.Data = app.structFieldOr( ...
                spec, 'ao_points', defaults.ao_points);
            app.LedFlickerOnField.Value = app.structFieldOr( ...
                spec, 'helper_on_seconds', 1);
            app.LedFlickerOffField.Value = app.structFieldOr( ...
                spec, 'helper_off_seconds', 0);
            app.LedFlickerCyclesField.Value = app.structFieldOr( ...
                spec, 'helper_cycles', 1);
            app.LedFlickerFrequencyField.Value = app.structFieldOr( ...
                spec, 'helper_frequency_hz', 60);
            app.LedFlickerController.configure( ...
                app.currentLedFlickerSpec(), app.Logger);
        end

        function ledFlickerConfigurationChanged(app, reason)
            if app.LedFlickerController.Armed
                app.disarmLedFlicker('configuration_changed');
            end
            app.LedFlickerController.configure( ...
                app.currentLedFlickerSpec(), app.Logger);
            app.LedFlickerStatusLabel.Text = ...
                'Configuration valid; click Arm LED Flicker.';
            app.scheduleExpensiveUiRefresh( ...
                "led_flicker_" + string(reason), true, true, true);
            app.UserSettingsDirty = true;
            app.refreshModuleMethodStatus('visual_led');
        end

        function armLedFlicker(app)
            app.beginAction('ARM_LED_FLICKER', ...
                'Validating LED flicker and finite camera window...', ...
                app.LedFlickerStatusLabel);
            try
                app.requireIdentity('arm LED flicker');
                if app.VisualStimulusController.Armed || ...
                        app.LightStimulusController.Armed
                    error('ZouLab:CombinedStimulusNotYetSupported', ...
                        ['Disarm PTB Visual Stimulus and Light Stimulus before ', ...
                         'arming LED Flicker.']);
                end
                app.LedFlickerController.configure( ...
                    app.currentLedFlickerSpec(), app.Logger);
                if ~app.SimulationMode
                    app.DaqController.assertReady();
                end
                app.LedFlickerController.arm(app.Logger);
                app.AcquisitionModeDropDown.Value = 'Record';
                previousLengthSource = string( ...
                    app.RecordLengthSourceDropDown.Value);
                app.RecordLengthSourceDropDown.Value = 'Custom';
                app.RecordDurationField.Value = app.CameraPreStimSeconds + ...
                    app.LedFlickerController.requiredWindowSeconds() + ...
                    app.CameraPostStimSeconds;
                app.updateRecordLengthSummary();
                app.Logger.log('INFO', ...
                    'LED_FLICKER_RECORD_LENGTH_AUTHORITY_SET', ...
                    ['PreviousSource=%s | Source=Custom | ', ...
                     'ResolvedCameraWindowSeconds=%.9g'], ...
                    previousLengthSource, app.RecordDurationField.Value);
                app.LedFlickerLamp.Color = [0.10 0.75 0.20];
                app.VisualStimLamp.Color = [0.10 0.75 0.20];
                app.VisualStimStatusLabel.Text = 'Visual: LED Flicker ARMED';
                app.LedFlickerArmButton.Enable = 'off';
                app.LedFlickerDisarmButton.Enable = 'on';
                app.LedFlickerStatusLabel.Text = ...
                    'ARMED — next Record includes DAQ LED Flicker.';
                app.updateAcquisitionControlAvailability(false);
                app.refreshDaqTimeline('led_flicker_armed');
                app.finishAction('ARM_LED_FLICKER', true, ...
                    'LED Flicker armed; finite Record duration is locked.', ...
                    app.LedFlickerStatusLabel);
            catch ME
                app.disarmLedFlicker('arm_failed');
                app.handleError('ARM_LED_FLICKER_FAILED', ME, ...
                    app.LedFlickerStatusLabel);
            end
        end

        function disarmLedFlicker(app, reason)
            app.LedFlickerController.disarm(app.Logger, reason);
            app.LedFlickerLamp.Color = [0.65 0.65 0.65];
            app.LedFlickerArmButton.Enable = 'on';
            app.LedFlickerDisarmButton.Enable = 'off';
            app.LedFlickerStatusLabel.Text = ...
                "OFF (" + string(reason) + ")";
            app.updateVisualStimulusStatus();
            app.updateAcquisitionControlAvailability(false);
            app.refreshDaqTimeline("led_flicker_disarmed_" + string(reason));
        end

        function createLightStimulusTab(app, parent)
            callbacks = struct();
            callbacks.addDmdTriggerEdge = ...
                @(varargin) app.addDmdTriggerEdge(varargin{:});
            callbacks.addWaveformPoint = ...
                @(varargin) app.addWaveformPoint(varargin{:});
            callbacks.armLightStimulus = ...
                @(varargin) app.armLightStimulus(varargin{:});
            callbacks.browseDmdPatternFolder = ...
                @(varargin) app.browseDmdPatternFolder(varargin{:});
            callbacks.chooseDmdCalibrationTiff = ...
                @(varargin) app.chooseDmdCalibrationTiff(varargin{:});
            callbacks.clearDmdTriggerTable = ...
                @(varargin) app.clearDmdTriggerTable(varargin{:});
            callbacks.clearWaveformPoints = ...
                @(varargin) app.clearWaveformPoints(varargin{:});
            callbacks.connectDmd = ...
                @(varargin) app.connectDmd(varargin{:});
            callbacks.createModuleMethodPanel = ...
                @(varargin) app.createModuleMethodPanel(varargin{:});
            callbacks.deleteDmdTriggerEdges = ...
                @(varargin) app.deleteDmdTriggerEdges(varargin{:});
            callbacks.deleteWaveformPoints = ...
                @(varargin) app.deleteWaveformPoints(varargin{:});
            callbacks.disarmLightStimulus = ...
                @(varargin) app.disarmLightStimulus(varargin{:});
            callbacks.dmdCalibrationCameraChanged = ...
                @(varargin) app.dmdCalibrationCameraChanged(varargin{:});
            callbacks.dmdCalibrationPathEdited = ...
                @(varargin) app.dmdCalibrationPathEdited(varargin{:});
            callbacks.dmdCalibrationSourceChanged = ...
                @(varargin) app.dmdCalibrationSourceChanged(varargin{:});
            callbacks.dmdGridModeChanged = ...
                @(varargin) app.dmdGridModeChanged(varargin{:});
            callbacks.dmdMaskModeChanged = ...
                @(varargin) app.dmdMaskModeChanged(varargin{:});
            callbacks.dmdMaskSettingEdited = ...
                @(varargin) app.dmdMaskSettingEdited(varargin{:});
            callbacks.dmdPatternSettingEdited = ...
                @(varargin) app.dmdPatternSettingEdited(varargin{:});
            callbacks.dmdTotalTriggerEdited = ...
                @(varargin) app.dmdTotalTriggerEdited(varargin{:});
            callbacks.dmdTriggerGeneratorSettingEdited = ...
                @(varargin) app.dmdTriggerGeneratorSettingEdited(varargin{:});
            callbacks.dmdTriggerModeChanged = ...
                @(varargin) app.dmdTriggerModeChanged(varargin{:});
            callbacks.dmdTriggerTableEdited = ...
                @(varargin) app.dmdTriggerTableEdited(varargin{:});
            callbacks.generateAnalogPointTable = ...
                @(varargin) app.generateAnalogPointTable(varargin{:});
            callbacks.generateDmdCalibrationGrids = ...
                @(varargin) app.generateDmdCalibrationGrids(varargin{:});
            callbacks.generateDmdMask = ...
                @(varargin) app.generateDmdMask(varargin{:});
            callbacks.insertDmdTriggerEdge = ...
                @(varargin) app.insertDmdTriggerEdge(varargin{:});
            callbacks.insertWaveformPoint = ...
                @(varargin) app.insertWaveformPoint(varargin{:});
            callbacks.lightStimulusAnalogHelperEdited = ...
                @(varargin) app.lightStimulusAnalogHelperEdited(varargin{:});
            callbacks.lightStimulusAnalogPointTableEdited = ...
                @(varargin) app.lightStimulusAnalogPointTableEdited(varargin{:});
            callbacks.lightStimulusAnalogSettingEdited = ...
                @(varargin) app.lightStimulusAnalogSettingEdited(varargin{:});
            callbacks.lightStimulusAnalogTargetChanged = ...
                @(varargin) app.lightStimulusAnalogTargetChanged(varargin{:});
            callbacks.lightStimulusAnalogTimingModeChanged = ...
                @(varargin) app.lightStimulusAnalogTimingModeChanged(varargin{:});
            callbacks.lightStimulusDigitalModeChanged = ...
                @(varargin) app.lightStimulusDigitalModeChanged(varargin{:});
            callbacks.lightStimulusDigitalParameterEdited = ...
                @(varargin) app.lightStimulusDigitalParameterEdited(varargin{:});
            callbacks.lightStimulusDigitalPointTableEdited = ...
                @(varargin) app.lightStimulusDigitalPointTableEdited(varargin{:});
            callbacks.lightStimulusSettingEdited = ...
                @(varargin) app.lightStimulusSettingEdited(varargin{:});
            callbacks.loadDmdCalibration = ...
                @(varargin) app.loadDmdCalibration(varargin{:});
            callbacks.loadDmdMaskSource = ...
                @(varargin) app.loadDmdMaskSource(varargin{:});
            callbacks.loadDmdPattern = ...
                @(varargin) app.loadDmdPattern(varargin{:});
            callbacks.pauseDmd = ...
                @(varargin) app.pauseDmd(varargin{:});
            callbacks.previewDmdPattern = ...
                @(varargin) app.previewDmdPattern(varargin{:});
            callbacks.projectDmdCalibrationGrid = ...
                @(varargin) app.projectDmdCalibrationGrid(varargin{:});
            callbacks.recoverDmdHostPort = ...
                @(varargin) app.recoverDmdHostPort(varargin{:});
            callbacks.resetDigitalPointTable = ...
                @(varargin) app.resetDigitalPointTable(varargin{:});
            callbacks.resetDmdTriggerTableForPattern = ...
                @(varargin) app.resetDmdTriggerTableForPattern(varargin{:});
            callbacks.runDmdAdminPortKill = ...
                @(varargin) app.runDmdAdminPortKill(varargin{:});
            callbacks.saveDmdCalibrationPreview = ...
                @(varargin) app.saveDmdCalibrationPreview(varargin{:});
            callbacks.snapAndSolveDmdCalibration = ...
                @(varargin) app.snapAndSolveDmdCalibration(varargin{:});
            callbacks.snapDmdMaskSource = ...
                @(varargin) app.snapDmdMaskSource(varargin{:});
            callbacks.solveDmdCalibration = ...
                @(varargin) app.solveDmdCalibration(varargin{:});
            callbacks.stopDmd = ...
                @(varargin) app.stopDmd(varargin{:});
            callbacks.toggleLightStimulusTimeline = ...
                @(varargin) app.toggleLightStimulusTimeline(varargin{:});
            callbacks.waveformTableSelectionChanged = ...
                @(varargin) app.waveformTableSelectionChanged(varargin{:});
            view = zoulab.ui.LightStimulusPanel(parent, callbacks);
            app.DmdAdminRecoverButton = view.DmdAdminRecoverButton;
            app.DmdCalibrationCameraDropDown = view.DmdCalibrationCameraDropDown;
            app.DmdCalibrationLamp = view.DmdCalibrationLamp;
            app.DmdCalibrationMatrixField = view.DmdCalibrationMatrixField;
            app.DmdCalibrationRootField = view.DmdCalibrationRootField;
            app.DmdCalibrationSourceDropDown = view.DmdCalibrationSourceDropDown;
            app.DmdCalibrationStatusLabel = view.DmdCalibrationStatusLabel;
            app.DmdCalibrationTiffField = view.DmdCalibrationTiffField;
            app.DmdGridModeDropDown = view.DmdGridModeDropDown;
            app.DmdGridResolvedPathField = view.DmdGridResolvedPathField;
            app.DmdInsertOffBetweenRoisCheckBox = view.DmdInsertOffBetweenRoisCheckBox;
            app.DmdLamp = view.DmdLamp;
            app.DmdMaskEachRoiCheckBox = view.DmdMaskEachRoiCheckBox;
            app.DmdMaskExpansionField = view.DmdMaskExpansionField;
            app.DmdMaskGenerateButton = view.DmdMaskGenerateButton;
            app.DmdMaskMinAreaField = view.DmdMaskMinAreaField;
            app.DmdMaskModeDropDown = view.DmdMaskModeDropDown;
            app.DmdMaskReverseCheckBox = view.DmdMaskReverseCheckBox;
            app.DmdMaskSourceField = view.DmdMaskSourceField;
            app.DmdMaskStatusLabel = view.DmdMaskStatusLabel;
            app.DmdMaskThresholdField = view.DmdMaskThresholdField;
            app.DmdPatternFolderField = view.DmdPatternFolderField;
            app.DmdPatternLamp = view.DmdPatternLamp;
            app.DmdPatternStateLabel = view.DmdPatternStateLabel;
            app.DmdPatternSummaryLabel = view.DmdPatternSummaryLabel;
            app.DmdPauseButton = view.DmdPauseButton;
            app.DmdPictureCountField = view.DmdPictureCountField;
            app.DmdPlayButton = view.DmdPlayButton;
            app.DmdRecoverPortButton = view.DmdRecoverPortButton;
            app.DmdStartPositionField = view.DmdStartPositionField;
            app.DmdStatusLabel = view.DmdStatusLabel;
            app.DmdTotalTriggerField = view.DmdTotalTriggerField;
            app.DmdTriggerDelayField = view.DmdTriggerDelayField;
            app.DmdTriggerModeDropDown = view.DmdTriggerModeDropDown;
            app.DmdTriggerPeriodField = view.DmdTriggerPeriodField;
            app.DmdTriggerRepeatField = view.DmdTriggerRepeatField;
            app.DmdTriggerTable = view.DmdTriggerTable;
            app.LightStimAnalogCalculatedDurationField = view.LightStimAnalogCalculatedDurationField;
            app.LightStimAnalogDelayField = view.LightStimAnalogDelayField;
            app.LightStimAnalogDurationField = view.LightStimAnalogDurationField;
            app.LightStimAnalogGenerateButton = view.LightStimAnalogGenerateButton;
            app.LightStimAnalogHighVoltageField = view.LightStimAnalogHighVoltageField;
            app.LightStimAnalogLowVoltageField = view.LightStimAnalogLowVoltageField;
            app.LightStimAnalogOffVoltageField = view.LightStimAnalogOffVoltageField;
            app.LightStimAnalogPointTable = view.LightStimAnalogPointTable;
            app.LightStimAnalogPulseWidthField = view.LightStimAnalogPulseWidthField;
            app.LightStimAnalogRepeatField = view.LightStimAnalogRepeatField;
            app.LightStimAnalogTargetDropDown = view.LightStimAnalogTargetDropDown;
            app.LightStimAnalogTimingModeDropDown = view.LightStimAnalogTimingModeDropDown;
            app.LightStimAnalogWaveformDropDown = view.LightStimAnalogWaveformDropDown;
            app.LightStimArmButton = view.LightStimArmButton;
            app.LightStimDelayField = view.LightStimDelayField;
            app.LightStimDigitalPointTable = view.LightStimDigitalPointTable;
            app.LightStimDigitalRepeatField = view.LightStimDigitalRepeatField;
            app.LightStimDisarmButton = view.LightStimDisarmButton;
            app.LightStimDmdLoopSwitch = view.LightStimDmdLoopSwitch;
            app.LightStimDmdPatternDropDown = view.LightStimDmdPatternDropDown;
            app.LightStimDmdPulseField = view.LightStimDmdPulseField;
            app.LightStimDmdSwitch = view.LightStimDmdSwitch;
            app.LightStimDurationField = view.LightStimDurationField;
            app.LightStimFrameworkStatusLabel = view.LightStimFrameworkStatusLabel;
            app.LightStimPulsePeriodField = view.LightStimPulsePeriodField;
            app.LightStimPulseWidthField = view.LightStimPulseWidthField;
            app.LightStimSourceDropDown = view.LightStimSourceDropDown;
            app.LightStimTimelinePreviewButton = view.LightStimTimelinePreviewButton;
            app.LightStimWaveformDropDown = view.LightStimWaveformDropDown;
            app.refreshModuleMethodDropDown('light_stim_laser');
            app.refreshModuleMethodDropDown('dmd');
        end

        function createAdvancedTab(app, parent)
            values = struct('pre',app.CameraPreStimSeconds, ...
                'post',app.CameraPostStimSeconds, 'lead',app.LightLeadSeconds, ...
                'tail',app.LightTailSeconds, 'dmdTriggerPort',app.DaqController.DmdTriggerPort, ...
                'dmdNetwork',app.WiringConfig.Value.dmd_network);
            callbacks = struct();
            callbacks.advancedHardwareSettingEdited = ...
                @(varargin) app.advancedHardwareSettingEdited(varargin{:});
            callbacks.advancedTimingEdited = ...
                @(varargin) app.advancedTimingEdited(varargin{:});
            callbacks.advancedVisualDisplayEdited = ...
                @(varargin) app.advancedVisualDisplayEdited(varargin{:});
            callbacks.applyDmdDeviceParametersClicked = ...
                @(varargin) app.applyDmdDeviceParametersClicked(varargin{:});
            callbacks.dmdDeviceParameterEdited = ...
                @(varargin) app.dmdDeviceParameterEdited(varargin{:});
            callbacks.dmdPatternSettingEdited = ...
                @(varargin) app.dmdPatternSettingEdited(varargin{:});
            callbacks.dmdRepeatToFillEdited = ...
                @(varargin) app.dmdRepeatToFillEdited(varargin{:});
            callbacks.dmdTriggerRateEdited = ...
                @(varargin) app.dmdTriggerRateEdited(varargin{:});
            callbacks.visualSettingEdited = ...
                @(varargin) app.visualSettingEdited(varargin{:});
            view = zoulab.ui.AdvancedPanel(parent, values, callbacks);
            app.AdvancedTimingSummaryLabel = view.AdvancedTimingSummaryLabel;
            app.CameraPostStimField = view.CameraPostStimField;
            app.CameraPreStimField = view.CameraPreStimField;
            app.DaqSampleRateField = view.DaqSampleRateField;
            app.DmdApplyParametersButton = view.DmdApplyParametersButton;
            app.DmdBitDepthDropDown = view.DmdBitDepthDropDown;
            app.DmdDaqPortField = view.DmdDaqPortField;
            app.DmdDataReverseCheckBox = view.DmdDataReverseCheckBox;
            app.DmdDividedEdgeDropDown = view.DmdDividedEdgeDropDown;
            app.DmdHostAddressField = view.DmdHostAddressField;
            app.DmdHostPortField = view.DmdHostPortField;
            app.DmdInputEdgeDropDown = view.DmdInputEdgeDropDown;
            app.DmdInternalRateField = view.DmdInternalRateField;
            app.DmdOutputEdgeDropDown = view.DmdOutputEdgeDropDown;
            app.DmdPictureCountActionDropDown = view.DmdPictureCountActionDropDown;
            app.DmdRepeatToFillTimelineCheckBox = view.DmdRepeatToFillTimelineCheckBox;
            app.DmdRowAddressingCheckBox = view.DmdRowAddressingCheckBox;
            app.DmdTargetAddressField = view.DmdTargetAddressField;
            app.DmdTargetPortField = view.DmdTargetPortField;
            app.DmdTrailingOffPaddingCheckBox = view.DmdTrailingOffPaddingCheckBox;
            app.DmdTriggerDivisionField = view.DmdTriggerDivisionField;
            app.DmdVerticalMirrorCheckBox = view.DmdVerticalMirrorCheckBox;
            app.LightLeadField = view.LightLeadField;
            app.LightStimDmdRateField = view.LightStimDmdRateField;
            app.LightTailField = view.LightTailField;
            app.VisualAmplitudeField = view.VisualAmplitudeField;
            app.VisualBaselineColorField = view.VisualBaselineColorField;
            app.VisualBlackColorField = view.VisualBlackColorField;
            app.VisualBlueColorField = view.VisualBlueColorField;
            app.VisualFlipDeadlineField = view.VisualFlipDeadlineField;
            app.VisualIdleColorField = view.VisualIdleColorField;
            app.VisualInitialPhaseField = view.VisualInitialPhaseField;
            app.VisualScreenWidthField = view.VisualScreenWidthField;
            app.VisualSpatialFrequencyField = view.VisualSpatialFrequencyField;
            app.VisualViewingDistanceField = view.VisualViewingDistanceField;
            app.VisualWhiteColorField = view.VisualWhiteColorField;
        end

        function createDaqTimelinePanel(app)
            panel = uipanel(app.RootGrid, ...
                'Title', 'Acquisition Timeline - overlaid commands and events', ...
                'Tag', 'DAQTimelinePanel');
            panel.Layout.Row = 2;
            panel.Layout.Column = [1 2];
            grid = uigridlayout(panel, [2 1]);
            grid.RowHeight = {26,'1x'};
            grid.Padding = [6 4 6 4];
            app.DaqTimelineStatusLabel = uilabel(grid, ...
                'Text', ['DAQ outputs are exact commands; Visual is a software/PTB ', ...
                    'plan and is not a DAQ output.'], ...
                'FontColor', [0.15 0.32 0.50], 'Tag', 'DaqTimelineStatusLabel');
            body = uigridlayout(grid, [1 2]);
            body.ColumnWidth = {'1x', 450};
            body.Padding = [0 0 0 0];
            app.DaqTimelineAxes = uiaxes(body, 'Tag', 'DaqTimelineAxes');
            app.DaqTimelineAxes.Toolbar.Visible = 'off';
            app.DaqTimelineAxes.YTick = [];
            app.DaqTimelineAxes.Box = 'on';
            app.DaqTimelineAxes.XGrid = 'on';
            app.DaqTimelineAxes.YGrid = 'on';
            xlabel(app.DaqTimelineAxes, 'Time from cycle output start (s)');
            app.DaqTimelineMetricsTable = uitable(body, ...
                'ColumnName', {'Show','Signal','Control','N','Min (s)','On (s)'}, ...
                'ColumnEditable', [true false false false false false], 'RowName', {}, ...
                'ColumnFormat', {'logical','char','char','numeric','char','char'}, ...
                'ColumnWidth', {48,140,90,40,62,62}, ...
                'CellEditCallback', @(source,event) ...
                    app.timelineVisibilityChanged(source, event), ...
                'Tag', 'DaqTimelineMetricsTable');
        end

        function createDetailsTab(app, parent)
            grid = uigridlayout(parent, [3 1]);
            grid.RowHeight = {310,300,'1x'};
            grid.Padding = [8 8 8 8];
            grid.RowSpacing = 8;
            if isprop(grid, 'Scrollable')
                grid.Scrollable = 'on';
            end

            app.createWiringJsonPanel(grid);

            diagnosticsPanel = uipanel(grid, 'Title', ...
                'Developer Diagnostics — read-only operational semantics');
            diagnosticsGrid = uigridlayout(diagnosticsPanel, [6 1]);
            diagnosticsGrid.RowHeight = {28,32,46,46,46,28};
            diagnosticsGrid.Padding = [6 5 6 5];
            uilabel(diagnosticsGrid, 'Text', ...
                'Raw: uint16 | Sensor: 2304×2304 | Bin: 1× / 2× / 4×');
            uilabel(diagnosticsGrid, 'Text', sprintf( ...
                ['DAQ %s | input %.0f Hz | output %.0f Hz | Cam1 USB %s/%s | ', ...
                 'Cam2 CXP %s/%s | start %.3g ms'], ...
                app.DaqController.DeviceID, app.DaqController.InputSampleRateHz, ...
                app.DaqSampleRateField.Value, app.DaqController.CameraPorts(1), ...
                app.DaqController.CameraTimingPorts(1), ...
                app.DaqController.CameraPorts(2), ...
                app.DaqController.CameraTimingPorts(2), ...
                1000 * app.DaqController.PulseWidthSeconds));
            uilabel(diagnosticsGrid, 'Text', ...
                ['FPS: Stream is the physical FramesAcquired counter rate; View is UI ', ...
                 'callback/render delivery; Record is the saved-frame result.'], ...
                'WordWrap', 'on');
            uilabel(diagnosticsGrid, 'Text', ...
                ['Spectra X uses STANDARD-mode USB serial. OBIS serial defaults are ', ...
                 'read-only identified at startup and all state-changing commands are logged.'], ...
                'WordWrap', 'on', 'FontColor', [0.65 0.25 0.05]);
            uilabel(diagnosticsGrid, 'Text', ...
                ['DMD OUT1 feedback is unassigned. Commanded DMD timing is therefore ', ...
                 'reported as unverified; mirror Float is reserved for power-off.'], ...
                'WordWrap', 'on');
            uilabel(diagnosticsGrid, 'Text', ...
                sprintf(['Record: 60 s headerless uint16 BIN segments | ', ...
                'Optional TIFF split: %.3f GiB after capture | Raw transpose: OFF'], ...
                zoulab.TiffStackWriter.MaxBytesPerStack / 2^30));

            logPanel = uipanel(grid, 'Title', ...
                'Diagnostic Log & Record Post-processing');
            logGrid = uigridlayout(logPanel, [3 1]);
            logGrid.RowHeight = {72,'1x',34};
            logGrid.Padding = [6 5 6 5];
            app.ConversionDetailArea = uitextarea(logGrid, ...
                'Editable', 'off', 'FontName', 'Consolas', ...
                'Value', {'Record post-processing: idle.'}, ...
                'Tag', 'ConversionDetailArea', ...
                'Tooltip', ['BIN crop and TIFF conversion progress is shown here; ', ...
                    'the acquisition panel keeps only a short status.']);
            app.LogArea = uitextarea(logGrid, 'Editable', 'off', 'FontName', 'Consolas');
            controls = uigridlayout(logGrid, [1 2]);
            controls.ColumnWidth = {'1x','1x'};
            controls.Padding = [0 0 0 0];
            uibutton(controls, 'push', 'Text', 'Refresh log', ...
                'ButtonPushedFcn', @(~,~) app.refreshLogClicked());
            uibutton(controls, 'push', 'Text', 'Open log folder', ...
                'ButtonPushedFcn', @(~,~) app.openLogFolder());
        end

        function createWiringJsonPanel(app, parent)
            wiringPanel = uipanel(parent, 'Title', ...
                'Rig Wiring JSON — rebuilt-based, developer access', ...
                'Tag', 'RigWiringJsonPanel');
            wiringGrid = uigridlayout(wiringPanel, [3 1]);
            wiringGrid.RowHeight = {30,'1x',34};
            wiringGrid.Padding = [6 5 6 5];
            header = uigridlayout(wiringGrid, [1 4]);
            header.ColumnWidth = {74,'1x',112,112};
            header.Padding = [0 0 0 0];
            uilabel(header, 'Text', 'JSON file');
            app.WiringConfigPathField = uieditfield(header, 'text', ...
                'Value', char(app.WiringConfig.FilePath), 'Editable', 'off', ...
                'Tag', 'WiringConfigPathField');
            uibutton(header, 'push', 'Text', 'Reload disk', ...
                'Tag', 'ReloadWiringJsonButton', ...
                'ButtonPushedFcn', @(~,~) app.reloadWiringJson());
            uibutton(header, 'push', 'Text', 'Validate & save', ...
                'Tag', 'SaveWiringJsonButton', ...
                'ButtonPushedFcn', @(~,~) app.saveWiringJson());
            app.WiringJsonArea = uitextarea(wiringGrid, ...
                'Value', cellstr(splitlines(app.WiringConfig.prettyText())), ...
                'FontName', 'Consolas', 'Tag', 'WiringJsonArea', ...
                'ValueChangedFcn', @(source,~) app.wiringJsonEdited(source.Value));
            app.WiringConfigStatusLabel = uilabel(wiringGrid, ...
                'Text', "Loaded and validated: " + app.WiringConfig.LoadedAt, ...
                'FontColor', [0.08 0.45 0.18], 'Tag', 'WiringConfigStatusLabel');
        end

        function label = sectionLabel(~, parent, textValue)
            label = uilabel(parent, 'Text', textValue, 'FontWeight', 'bold', ...
                'FontColor', [0.08 0.28 0.48]);
        end

        function experimentTabChanged(app, event)
            previous = "";
            current = "";
            if ~isempty(event.OldValue) && isvalid(event.OldValue)
                previous = string(event.OldValue.Title);
            end
            if ~isempty(event.NewValue) && isvalid(event.NewValue)
                current = string(event.NewValue.Title);
            end
            app.Logger.log('INFO', 'USER_EXPERIMENT_TAB_CHANGED', ...
                'Previous=%s | New=%s', previous, current);
        end

        function operatorNameEdited(app, previousValue, newValue)
            app.Logger.log('INFO', 'USER_OPERATOR_NAME_EDITED', ...
                'Previous=%s | New=%s', string(previousValue), string(newValue));
            if ~isempty(app.OperatorUserDropDown.ItemsData)
                app.OperatorUserDropDown.Value = '';
            end
            if app.IdentityConfirmed
                app.OperatorStatusLabel.Text = sprintf( ...
                    'Active: %s | click Start Session to switch', ...
                    app.Logger.OperatorName);
            else
                app.OperatorStatusLabel.Text = ...
                    'Name entered; click Start Session';
            end
            app.OperatorStatusLabel.FontColor = [0.75 0.45 0.05];
            app.OperatorLamp.Color = [0.95 0.65 0.10];
            app.updateOperatorActionAvailability();
        end

        function userSelectionChanged(app, previousValue, newValue)
            app.Logger.log('INFO', 'USER_PROFILE_DROPDOWN_CHANGED', ...
                'Previous=%s | New=%s', string(previousValue), string(newValue));
            if strlength(string(newValue)) == 0
                return;
            end
            users = app.VisualPresets.listUsers();
            match = find(strcmpi(string({users.canonical_name}), ...
                string(newValue)), 1);
            if ~isempty(match)
                app.OperatorNameField.Value = users(match).display_name;
                app.OperatorStatusLabel.Text = ...
                    'Existing user selected; click Start Session';
                app.OperatorStatusLabel.FontColor = [0.75 0.45 0.05];
                app.OperatorLamp.Color = [0.95 0.65 0.10];
            end
            app.updateOperatorActionAvailability();
        end

        function openUser(app)
            name = strtrim(string(app.OperatorNameField.Value));
            selected = string(app.OperatorUserDropDown.Value);
            if strlength(selected) > 0
                name = selected;
            end
            app.beginAction('START_USER_SESSION', "Starting session for " + name, ...
                app.OperatorStatusLabel);
            try
                app.prepareUserSwitch();
                users = app.VisualPresets.listUsers();
                match = find(strcmpi(string({users.canonical_name}), name) | ...
                    strcmpi(string({users.display_name}), name), 1);
                isNew = isempty(match);
                if isNew
                    profile = app.VisualPresets.createUser(name);
                else
                    profile = app.VisualPresets.openUser( ...
                        users(match).canonical_name);
                end
                app.activateUser(profile, isNew);
                suffix = "";
                if isNew
                    suffix = " (new user created)";
                end
                app.finishAction('START_USER_SESSION', true, ...
                    "Active: " + string(profile.display_name) + suffix, ...
                    app.OperatorStatusLabel);
            catch ME
                app.OperatorLamp.Color = [0.85 0.15 0.12];
                app.handleError('START_USER_SESSION_FAILED', ME, ...
                    app.OperatorStatusLabel);
            end
        end

        function prepareUserSwitch(app)
            if app.RunState.AcquisitionRunning || ~isempty(app.TimeLapseTimer) || ...
                    app.VisualPreviewRunning
                error('ZouLab:UserSwitchBusy', ...
                    'Stop Acquisition, Time Lapse, and stimulus preview before switching user.');
            end
            if app.IdentityConfirmed
                app.persistUserSettings('before_user_switch');
            end
            if any(app.PreviewActive)
                app.stopPreviews();
            end
            if app.DaqController.Connected
                safeOffConfirmed = app.DaqController.safeOff();
                if safeOffConfirmed
                    safeLevel = 'SUCCESS';
                else
                    safeLevel = 'ERROR';
                end
                app.Logger.log(safeLevel, ...
                    'OPERATOR_SWITCH_DAQ_LIGHTS_FORCED_SAFE', ...
                    'AllTTLOutputsSafe=%d | SwitchOwner=DAQ_TTL', ...
                    safeOffConfirmed);
            end
            if app.SpectraController.Connected
                app.SpectraController.allOff(app.Logger, 'operator_switch');
                app.refreshLightTableFromController();
                app.Logger.log('INFO', 'OPERATOR_SWITCH_LIGHTS_FORCED_OFF', ...
                    'Reason=safe handover | HardwareCommandIssued=1');
            end
            if app.VisualStimulusController.Armed
                app.disarmVisualStimulus('operator_switch');
            end
            if app.VisualStimulusController.ScreenReady
                app.VisualStimulusController.closeScreen(app.Logger);
                app.updateVisualScreenStatus();
                app.Logger.log('INFO', 'OPERATOR_SWITCH_PTB_SCREEN_CLOSED', ...
                    'Reason=safe_handover | ScreenStateNotTransferredBetweenUsers=1');
            end
        end

        function activateUser(app, profile, isNew)
            previousID = app.Logger.OperatorID;
            previousName = app.Logger.OperatorName;
            app.Logger.log('INFO', 'OPERATOR_PROFILE_ACTIVATION_BEGIN', ...
                ['PreviousID=%s | PreviousName=%s | RequestedID=%s | ', ...
                 'RequestedName=%s | NewUser=%d'], previousID, previousName, ...
                profile.canonical_name, profile.display_name, isNew);
            app.IdentityConfirmed = false;
            app.setIdentityGate(true, 'operator_profile_loading');
            app.Logger.clearIdentity("activating_profile_" + ...
                string(profile.canonical_name));
            app.OperatorLamp.Color = [0.95 0.65 0.10];
            app.OperatorStatusLabel.Text = ...
                "Loading user settings: " + string(profile.display_name);
            app.OperatorStatusLabel.FontColor = [0.75 0.45 0.05];
            usedDefaults = logical(isNew);
            try
                app.initializeModuleMethodState();
                app.ModuleMethods.setActiveUserFolder(profile.folder);
                if ~isNew
                    usedDefaults = app.loadUserSettings();
                end
                app.refreshAllModuleMethodDropDowns();
            catch ME
                app.IdentityConfirmed = false;
                app.setIdentityGate(true, 'operator_profile_load_failed');
                app.OperatorLamp.Color = [0.85 0.15 0.12];
                app.OperatorStatusLabel.Text = ...
                    "User start failed; controls remain locked: " + ...
                    string(ME.message);
                app.OperatorStatusLabel.FontColor = [0.75 0.15 0.12];
                app.Logger.log('ERROR', 'OPERATOR_PROFILE_ACTIVATION_FAILED', ...
                    'RequestedID=%s | RequestedName=%s | ControlsLocked=1', ...
                    profile.canonical_name, profile.display_name);
                rethrow(ME);
            end
            app.Logger.setIdentity(profile.canonical_name, profile.display_name);
            app.IdentityConfirmed = true;
            app.OperatorNameField.Value = profile.display_name;
            app.refreshUserDropDown();
            app.OperatorUserDropDown.Value = profile.canonical_name;
            app.OperatorLamp.Color = [0.10 0.75 0.20];
            app.OperatorStatusLabel.Text = "Active: " + string(profile.display_name);
            app.OperatorStatusLabel.FontColor = [0.08 0.55 0.18];
            app.setIdentityGate(false, 'operator_profile_activated');
            app.refreshAllModuleMethodStatuses();
            if usedDefaults
                app.persistUserSettings('user_defaults');
            end
            app.updateOperatorActionAvailability();
            app.Logger.log('SUCCESS', 'OPERATOR_PROFILE_ACTIVATED', ...
                ['PreviousID=%s | PreviousName=%s | NewID=%s | NewName=%s | ', ...
                 'NewUser=%d | Folder=%s | CaseInsensitiveIdentity=1'], ...
                previousID, previousName, profile.canonical_name, ...
                profile.display_name, isNew, profile.folder);
            if app.DaqController.Connected
                app.Logger.log('INFO', 'AUTO_DAQ_CONNECT_SKIPPED', ...
                    'Reason=already_connected | SessionRemainsActive=1');
            else
                app.Logger.log('INFO', 'AUTO_DAQ_CONNECT_REQUESTED', ...
                    ['Reason=session_started | FailurePolicy=session_remains_active ', ...
                     'and_manual_retry_available']);
                app.connectDAQ();
            end
        end

        function refreshUserDropDown(app)
            users = app.VisualPresets.listUsers();
            items = ["(type a name or select)" string({users.display_name})];
            data = ["" string({users.canonical_name})];
            app.OperatorUserDropDown.Items = cellstr(items);
            app.OperatorUserDropDown.ItemsData = cellstr(data);
            app.OperatorUserDropDown.Value = '';
            app.updateOperatorActionAvailability();
        end

        function updateOperatorActionAvailability(app)
            if isempty(app.OpenUserButton) || ~isvalid(app.OpenUserButton)
                return;
            end
            hasName = strlength(strtrim(string( ...
                app.OperatorNameField.Value))) > 0;
            hasSelection = strlength(string( ...
                app.OperatorUserDropDown.Value)) > 0;
            app.OpenUserButton.Enable = app.onOff(hasName || hasSelection);
        end

        function setIdentityGate(app, locked, reason)
            if nargin < 3
                reason = 'unspecified';
            end
            if locked
                if isempty(app.IdentityGatedControls)
                    candidates = findall(app.UIFigure, '-property', 'Enable');
                    controls = cell(1, 0);
                    states = cell(1, 0);
                    for index = 1:numel(candidates)
                        control = candidates(index);
                        % Keep both the Operator subtree and every container
                        % above it enabled.  Disabling an ancestor panel makes
                        % an enabled/editable name field mouse- and
                        % keyboard-inaccessible even though code can still
                        % assign its Value.
                        if app.isDescendantOf(control, app.OperatorPanel) || ...
                                app.isDescendantOf(app.OperatorPanel, control)
                            continue;
                        end
                        if isprop(control, 'Tag') && ...
                                string(control.Tag) == "SafeExitButton"
                            continue;
                        end
                        controls{end + 1} = control; %#ok<AGROW>
                        states{end + 1} = control.Enable; %#ok<AGROW>
                    end
                    app.IdentityGatedControls = controls;
                    app.IdentityGatedEnableStates = states;
                end
                for index = 1:numel(app.IdentityGatedControls)
                    control = app.IdentityGatedControls{index};
                    if isvalid(control)
                        control.Enable = 'off';
                    end
                end
                app.OperatorUserDropDown.Enable = 'on';
                app.OperatorNameField.Enable = 'on';
                app.updateOperatorActionAvailability();
            else
                for index = 1:numel(app.IdentityGatedControls)
                    control = app.IdentityGatedControls{index};
                    if isvalid(control)
                        control.Enable = ...
                            app.IdentityGatedEnableStates{index};
                    end
                end
                app.IdentityGatedControls = {};
                app.IdentityGatedEnableStates = {};
                for cameraIndex = 1:2
                    manual = strcmp(app.ContrastModes{cameraIndex}.Value, ...
                        'Manual');
                    app.ContrastLowFields{cameraIndex}.Enable = ...
                        app.onOff(manual);
                    app.ContrastHighFields{cameraIndex}.Enable = ...
                        app.onOff(manual);
                end
                app.updatePreviewButtons();
                app.updateLightStimulusFieldAvailability();
                app.updateAcquisitionControlAvailability( ...
                    app.RunState.AcquisitionRunning);
                app.updateOperatorActionAvailability();
            end
            app.updateVisualScreenStatus();
            app.Logger.log('INFO', 'OPERATOR_IDENTITY_GATE_CHANGED', ...
                ['Locked=%d | Reason=%s | GatedControls=%d | ', ...
                 'OperatorControlsAvailable=1'], locked, string(reason), ...
                numel(app.IdentityGatedControls));
        end

        function value = isDescendantOf(~, child, parent)
            value = false;
            node = child;
            while ~isempty(node) && isvalid(node)
                if isequal(node, parent)
                    value = true;
                    return;
                end
                try
                    node = node.Parent;
                catch
                    return;
                end
            end
        end

        function settings = collectUserSettings(app)
            for cameraIndex = 1:2
                cameraValue = struct( ...
                    'exposure_ms', app.ExposureFields{cameraIndex}.Value, ...
                    'roi', char(string(app.ROIFields{cameraIndex}.Value)), ...
                    'bin', app.BinDropDowns{cameraIndex}.Value, ...
                    'contrast_mode', char(string( ...
                        app.ContrastModes{cameraIndex}.Value)), ...
                    'contrast_low', ...
                        app.ContrastLowFields{cameraIndex}.Value, ...
                    'contrast_high', ...
                        app.ContrastHighFields{cameraIndex}.Value, ...
                    'display_transpose', app.TransposeDisplay(cameraIndex));
                if cameraIndex == 1
                    cameras = cameraValue;
                else
                    cameras(cameraIndex) = cameraValue;
                end
            end
            settings = struct( ...
                'session', struct( ...
                    'camera_mode', char(string(app.CameraModeDropDown.Value)), ...
                    'save_root', char(string(app.RootPathField.Value)), ...
                    'method_note', char(string(app.MethodNoteField.Value)), ...
                    'camera1_label', char(string(app.Camera1LabelField.Value)), ...
                    'camera2_label', char(string(app.Camera2LabelField.Value))), ...
                'cameras', cameras, ...
                'acquisition', struct( ...
                    'mode', char(string(app.AcquisitionModeDropDown.Value)), ...
                    'cycles', app.CycleCountField.Value, ...
                    'cycle_start_interval_seconds', ...
                        app.CycleIntervalField.Value, ...
                    'daq_sample_rate_hz', app.DaqSampleRateField.Value, ...
                    'record_duration_seconds', app.RecordDurationField.Value, ...
                    'record_length_source', char(string( ...
                        app.RecordLengthSourceDropDown.Value)), ...
                    'convert_record_to_tiff', app.RecordTiffCheckBox.Value, ...
                    'time_lapse_interval_seconds', app.TLIntervalField.Value, ...
                    'time_lapse_points', app.TLPointsField.Value), ...
                'light', struct('table_data', {app.LightTable.Data}, ...
                    'selected_row', app.SelectedLightRow, ...
                    'level_semantics', ...
                        'Coherent=AO_percent_0_to_5V; Spectra=USB_percent', ...
                    'state_restore_policy', ...
                        'saved for audit; always restored OFF without hardware command'), ...
                'visual', app.visualConfiguration(), ...
                'visual_timing', struct( ...
                    'camera_pre_stim_seconds', app.CameraPreStimField.Value, ...
                    'camera_post_stim_seconds', app.CameraPostStimField.Value, ...
                    'light_lead_seconds', app.LightLeadField.Value, ...
                    'light_tail_seconds', app.LightTailField.Value, ...
                    'ptb_start_offset_seconds', app.CameraPreStimField.Value, ...
                    'ptb_end_padding_seconds', app.CameraPostStimField.Value, ...
                    'imaging_light_start_offset_seconds', ...
                        app.LightLeadField.Value, ...
                    'imaging_light_end_offset_seconds', ...
                        app.LightTailField.Value), ...
                'visual_preview', struct( ...
                    'mode', char(string(app.VisualPreviewModeDropDown.Value)), ...
                    'fixed_angle', app.VisualPreviewAngleField.Value), ...
                'led_flicker', struct( ...
                    'spec', app.currentLedFlickerSpec(), ...
                    'preset_on_seconds', app.LedFlickerOnField.Value, ...
                    'preset_off_seconds', app.LedFlickerOffField.Value, ...
                    'preset_cycles', app.LedFlickerCyclesField.Value, ...
                    'preset_frequency_hz', ...
                        app.LedFlickerFrequencyField.Value, ...
                    'restore_policy', ...
                        'configuration restored; always restored disarmed'), ...
                'light_stimulus', struct( ...
                    'spec', app.currentLightStimulusSpec(), ...
                    'ao_editor_target', char(string( ...
                        app.LightStimAnalogTargetDropDown.Value)), ...
                    'dmd_pattern_folder', char(string( ...
                        app.DmdPatternFolderField.Value)), ...
                    'dmd_start_position', app.DmdStartPositionField.Value, ...
                    'dmd_picture_count', app.DmdPictureCountField.Value, ...
                    'dmd_trigger_generator', struct( ...
                        'first_delay_seconds', app.DmdTriggerDelayField.Value, ...
                        'trigger_period_seconds', app.DmdTriggerPeriodField.Value, ...
                        'sequence_cycles', app.DmdTriggerRepeatField.Value, ...
                        'total_trigger_count', app.DmdTotalTriggerField.Value, ...
                        'repeat_to_fill_timeline', ...
                            app.DmdRepeatToFillTimelineCheckBox.Value), ...
                    'dmd_mask_options', struct( ...
                        'create_each_roi', app.DmdMaskEachRoiCheckBox.Value, ...
                        'insert_off_after_each_roi', ...
                            app.DmdInsertOffBetweenRoisCheckBox.Value, ...
                        'create_reverse', app.DmdMaskReverseCheckBox.Value, ...
                        'compile_depth', char(string( ...
                            app.DmdBitDepthDropDown.Value)), ...
                        'append_trailing_off_block_fill', ...
                            app.DmdTrailingOffPaddingCheckBox.Value), ...
                    'dmd_trigger_mode', char(string( ...
                        app.DmdTriggerModeDropDown.Value)), ...
                    'dmd_grid_source', char(string( ...
                        app.DmdGridModeDropDown.Value)), ...
                    'dmd_calibration_snap_source', char(string( ...
                        app.DmdCalibrationSourceDropDown.Value)), ...
                    'dmd_calibration_camera', char(string( ...
                        app.DmdCalibrationCameraDropDown.Value)), ...
                    'dmd_calibration_root', char(string( ...
                        app.DmdCalibrationRootField.Value)), ...
                    'dmd_calibration_tiff', char(string( ...
                        app.DmdCalibrationTiffField.Value)), ...
                    'dmd_calibration_matrix', char(string( ...
                        app.DmdCalibrationMatrixField.Value)), ...
                    'dmd_device_parameters', struct( ...
                        'internal_playback_hz', app.DmdInternalRateField.Value, ...
                        'vertical_mirror', app.DmdVerticalMirrorCheckBox.Value, ...
                        'data_reverse', app.DmdDataReverseCheckBox.Value, ...
                        'row_addressing', app.DmdRowAddressingCheckBox.Value, ...
                        'input_trigger_edge', char(string( ...
                            app.DmdInputEdgeDropDown.Value)), ...
                        'output_trigger_edge', char(string( ...
                            app.DmdOutputEdgeDropDown.Value)), ...
                        'divided_trigger_edge', char(string( ...
                            app.DmdDividedEdgeDropDown.Value)), ...
                        'trigger_division', app.DmdTriggerDivisionField.Value, ...
                        'picture_count_register', char(string( ...
                            app.DmdPictureCountActionDropDown.Value))), ...
                    'restore_policy', ...
                        'configuration restored; stimulus always restored disarmed'), ...
                'timeline_display', struct( ...
                    'hidden_signals', {cellstr(app.DaqTimelineHiddenNames)}, ...
                    'new_signals_visible_by_default', true, ...
                    'visual_trace_semantics', ...
                        'software/PTB plan overlay; not a DAQ output'), ...
                'rig_wiring_reference', struct( ...
                    'file', char(app.WiringConfig.FilePath), ...
                    'schema_version', char(string( ...
                        app.WiringConfig.Value.schema_version)), ...
                    'restore_policy', 'shared rig configuration; not user-specific'));
        end

        function persistUserSettings(app, reason)
            if app.IdentityConfirmed && ~app.ApplyingUserSettings
                app.refreshAllModuleMethodStatuses();
            end
            if ~app.IdentityConfirmed || app.ApplyingUserSettings || ...
                    isempty(app.VisualPresets) || ...
                    strlength(app.VisualPresets.ActiveFolder) == 0
                return;
            end
            reason = string(reason);
            saveNow = any(reason == ["app_close", "before_user_switch"]);
            if ~saveNow
                % Every edit is logged at its callback.  The full settings
                % snapshot is intentionally deferred so ordinary UI edits do
                % not perform synchronous MAT-file I/O on the UI thread.
                app.UserSettingsDirty = true;
                return;
            end
            settings = app.collectUserSettings();
            app.VisualPresets.saveAppSettings(settings);
            app.UserSettingsDirty = false;
            app.Logger.log('SUCCESS', 'USER_APP_SETTINGS_SAVED', ...
                'Reason=%s | File=%s | AdjustableValues=%s', ...
                string(reason), fullfile(app.VisualPresets.ActiveFolder, ...
                'app_settings.mat'), jsonencode(settings));
        end

        function usedDefaults = loadUserSettings(app)
            usedDefaults = false;
            settings = app.VisualPresets.loadAppSettings();
            if isempty(fieldnames(settings))
                usedDefaults = true;
                app.Logger.log('INFO', 'USER_APP_SETTINGS_DEFAULTED', ...
                    ['No saved app_settings.mat existed; current UI defaults will ', ...
                     'be saved when this operator exits or switches user.']);
                return;
            end
            app.ApplyingUserSettings = true;
            cleanup = onCleanup(@() app.finishApplyingUserSettings());
            try
                session = settings.session;
                app.CameraModeDropDown.Value = session.camera_mode;
                app.RootPathField.Value = session.save_root;
                app.MethodNoteField.Value = session.method_note;
                app.Camera1LabelField.Value = session.camera1_label;
                app.Camera2LabelField.Value = session.camera2_label;
                for cameraIndex = 1:min(2, numel(settings.cameras))
                    camera = settings.cameras(cameraIndex);
                    app.ExposureFields{cameraIndex}.Value = camera.exposure_ms;
                    app.ROIFields{cameraIndex}.Value = camera.roi;
                    app.BinDropDowns{cameraIndex}.Value = camera.bin;
                    app.syncExposurePreset(cameraIndex);
                    app.syncRoiPreset(cameraIndex);
                    app.ContrastModes{cameraIndex}.Value = camera.contrast_mode;
                    app.ContrastLowFields{cameraIndex}.Value = camera.contrast_low;
                    app.ContrastHighFields{cameraIndex}.Value = camera.contrast_high;
                    app.TransposeDisplay(cameraIndex) = ...
                        logical(camera.display_transpose);
                    app.TransposeChecks{cameraIndex}.Value = ...
                        app.TransposeDisplay(cameraIndex);
                    manual = strcmp(camera.contrast_mode, 'Manual');
                    app.ContrastLowFields{cameraIndex}.Enable = app.onOff(manual);
                    app.ContrastHighFields{cameraIndex}.Enable = app.onOff(manual);
                    app.CameraAxes{cameraIndex}.CLim = app.sanitizeLimits( ...
                        [camera.contrast_low camera.contrast_high]);
                    app.updateCameraTitle(cameraIndex);
                end
                acquisition = settings.acquisition;
                app.AcquisitionModeDropDown.Value = acquisition.mode;
                app.CycleCountField.Value = acquisition.cycles;
                app.CycleIntervalField.Value = ...
                    acquisition.cycle_start_interval_seconds;
                if isfield(acquisition, 'daq_sample_rate_hz')
                    app.DaqSampleRateField.Value = ...
                        acquisition.daq_sample_rate_hz;
                end
                app.RecordDurationField.Value = ...
                    acquisition.record_duration_seconds;
                if isfield(acquisition, 'record_length_source')
                    item = zoulab.UserSettings.canonicalDropDownItem( ...
                        app.RecordLengthSourceDropDown.Items, ...
                        acquisition.record_length_source);
                    if strlength(item) > 0
                        app.RecordLengthSourceDropDown.Value = char(item);
                    end
                end
                if isfield(acquisition, 'convert_record_to_tiff')
                    app.RecordTiffCheckBox.Value = logical( ...
                        acquisition.convert_record_to_tiff);
                else
                    app.RecordTiffCheckBox.Value = false;
                end
                app.TLIntervalField.Value = ...
                    acquisition.time_lapse_interval_seconds;
                app.TLPointsField.Value = acquisition.time_lapse_points;
                if isfield(settings, 'light') && ...
                        isfield(settings.light, 'table_data')
                    savedLight = settings.light.table_data;
                    [currentLight, selectedRow, migration] = ...
                        zoulab.UserSettings.migrateSavedLightTable( ...
                            app.LightTable.Data, savedLight, settings.light);
                    app.LightTable.Data = currentLight;
                    app.SelectedLightRow = selectedRow;
                    app.Logger.log('INFO', 'USER_LIGHT_TABLE_SETTINGS_MIGRATED', ...
                        '%s', migration);
                    app.syncSelectedLightControls();
                end
                app.applyVisualConfiguration(settings.visual, 'user_app_settings');
                if isfield(settings, 'visual_timing')
                    timing = settings.visual_timing;
                    [restoredTiming, legacyLead] = ...
                        zoulab.UserSettings.restoreTiming(timing);
                    app.CameraPreStimField.Value = restoredTiming.pre;
                    app.CameraPostStimField.Value = restoredTiming.post;
                    app.LightLeadField.Value = restoredTiming.lead;
                    if legacyLead
                        app.Logger.log('INFO', ...
                            'USER_TIMING_LEGACY_LIGHT_LEAD_MIGRATED', ...
                            'LegacyLead=%g | StartOffset=%g', ...
                            -restoredTiming.lead, app.LightLeadField.Value);
                    end
                    app.LightTailField.Value = restoredTiming.tail;
                    app.CameraPreStimSeconds = app.CameraPreStimField.Value;
                    app.CameraPostStimSeconds = app.CameraPostStimField.Value;
                    app.LightLeadSeconds = app.LightLeadField.Value;
                    app.LightTailSeconds = app.LightTailField.Value;
                end
                if isfield(settings, 'visual_preview')
                    app.VisualPreviewModeDropDown.Value = ...
                        settings.visual_preview.mode;
                    app.VisualPreviewAngleField.Value = ...
                        settings.visual_preview.fixed_angle;
                    app.VisualPreviewAngleField.Enable = app.onOff( ...
                        string(settings.visual_preview.mode) == "fixed");
                end
                if isfield(settings, 'led_flicker')
                    led = settings.led_flicker;
                    if isfield(led, 'spec')
                        app.LedFlickerDelayField.Value = ...
                            led.spec.delay_seconds;
                        app.LedFlickerDoTable.Data = led.spec.do_points;
                        app.LedFlickerAoTable.Data = led.spec.ao_points;
                        app.LedFlickerController.configure( ...
                            app.currentLedFlickerSpec(), app.Logger);
                    end
                    if isfield(led, 'preset_on_seconds')
                        app.LedFlickerOnField.Value = led.preset_on_seconds;
                        app.LedFlickerOffField.Value = led.preset_off_seconds;
                        app.LedFlickerCyclesField.Value = led.preset_cycles;
                        app.LedFlickerFrequencyField.Value = ...
                            led.preset_frequency_hz;
                    end
                    app.disarmLedFlicker('user_settings_loaded');
                end
                if isfield(settings, 'light_stimulus')
                    lightStim = settings.light_stimulus;
                    if isfield(lightStim, 'spec')
                        app.applyLightStimulusSpec(lightStim.spec);
                        app.LightStimulusController.configure( ...
                            app.currentLightStimulusSpec(), app.Logger);
                    end
                    if isfield(lightStim, 'ao_editor_target') && ...
                            any(strcmp(string(lightStim.ao_editor_target), ["405","445"]))
                        app.LightStimAnalogTargetDropDown.Value = ...
                            lightStim.ao_editor_target;
                        app.loadLightStimulusAnalogControls( ...
                            string(lightStim.ao_editor_target));
                    end
                    if isfield(lightStim, 'dmd_pattern_folder')
                        app.DmdPatternFolderField.Value = ...
                            lightStim.dmd_pattern_folder;
                    end
                    if isfield(lightStim, 'dmd_start_position')
                        app.DmdStartPositionField.Value = ...
                            lightStim.dmd_start_position;
                    end
                    if isfield(lightStim, 'dmd_picture_count')
                        app.DmdPictureCountField.Value = ...
                            lightStim.dmd_picture_count;
                    end
                    if isfield(lightStim, 'dmd_trigger_generator')
                        generator = lightStim.dmd_trigger_generator;
                        if isfield(generator, 'first_delay_seconds')
                            app.DmdTriggerDelayField.Value = ...
                                generator.first_delay_seconds;
                        end
                        if isfield(generator, 'trigger_period_seconds')
                            app.DmdTriggerPeriodField.Value = ...
                                generator.trigger_period_seconds;
                            app.LightStimDmdRateField.Value = ...
                                1 / generator.trigger_period_seconds;
                        end
                        if isfield(generator, 'sequence_cycles')
                            app.DmdTriggerRepeatField.Value = ...
                                generator.sequence_cycles;
                        end
                        if isfield(generator, 'total_trigger_count')
                            app.DmdTotalTriggerField.Value = ...
                                generator.total_trigger_count;
                        end
                        if isfield(generator, 'repeat_to_fill_timeline')
                            app.DmdRepeatToFillTimelineCheckBox.Value = logical( ...
                                generator.repeat_to_fill_timeline);
                        end
                    end
                    if isfield(lightStim, 'dmd_mask_options')
                        options = lightStim.dmd_mask_options;
                        if isfield(options, 'create_each_roi')
                            app.DmdMaskEachRoiCheckBox.Value = logical( ...
                                options.create_each_roi);
                        end
                        if isfield(options, 'insert_off_after_each_roi')
                            app.DmdInsertOffBetweenRoisCheckBox.Value = logical( ...
                                options.insert_off_after_each_roi);
                        end
                        if isfield(options, 'create_reverse')
                            app.DmdMaskReverseCheckBox.Value = logical( ...
                                options.create_reverse);
                        end
                        if isfield(options, 'compile_depth')
                            item = zoulab.UserSettings.canonicalDropDownItem( ...
                                app.DmdBitDepthDropDown.Items, ...
                                options.compile_depth);
                            if strlength(item) > 0
                                app.DmdBitDepthDropDown.Value = char(item);
                            end
                        end
                        if isfield(options, 'append_trailing_off_block_fill')
                            app.DmdTrailingOffPaddingCheckBox.Value = logical( ...
                                options.append_trailing_off_block_fill);
                        end
                    end
                    if isfield(lightStim, 'dmd_trigger_mode')
                        item = zoulab.UserSettings.canonicalDropDownItem( ...
                            app.DmdTriggerModeDropDown.Items, ...
                            lightStim.dmd_trigger_mode);
                        if strlength(item) > 0
                            app.DmdTriggerModeDropDown.Value = char(item);
                        end
                    end
                    if isfield(lightStim, 'dmd_grid_source')
                        item = zoulab.UserSettings.canonicalDropDownItem( ...
                            app.DmdGridModeDropDown.Items, ...
                            lightStim.dmd_grid_source);
                        if strlength(item) > 0
                            app.DmdGridModeDropDown.Value = char(item);
                        end
                    end
                    if isfield(lightStim, 'dmd_calibration_snap_source')
                        item = zoulab.UserSettings.canonicalDropDownItem( ...
                            app.DmdCalibrationSourceDropDown.Items, ...
                            lightStim.dmd_calibration_snap_source);
                        if strlength(item) > 0
                            app.DmdCalibrationSourceDropDown.Value = char(item);
                        end
                    end
                    if isfield(lightStim, 'dmd_calibration_camera') && ...
                            any(strcmp(string(lightStim.dmd_calibration_camera), ...
                            string(app.DmdCalibrationCameraDropDown.Items)))
                        app.DmdCalibrationCameraDropDown.Value = ...
                            lightStim.dmd_calibration_camera;
                    end
                    if isfield(lightStim, 'dmd_calibration_root')
                        app.DmdCalibrationRootField.Value = ...
                            lightStim.dmd_calibration_root;
                    end
                    if isfield(lightStim, 'dmd_calibration_tiff')
                        app.DmdCalibrationTiffField.Value = ...
                            lightStim.dmd_calibration_tiff;
                    end
                    if isfield(lightStim, 'dmd_calibration_matrix') && ...
                            isfile(string(lightStim.dmd_calibration_matrix))
                        cameraIndex = app.selectedDmdCalibrationCamera();
                        app.DmdCalibrationData = ...
                            zoulab.DmdCalibration.loadCalibration( ...
                            lightStim.dmd_calibration_matrix, cameraIndex);
                        app.DmdCalibrationMatrixField.Value = ...
                            lightStim.dmd_calibration_matrix;
                        app.DmdCalibrationLamp.Color = [0.10 0.75 0.20];
                        app.DmdCalibrationStatusLabel.Text = sprintf( ...
                            'CALIBRATED — Camera %d matrix restored', cameraIndex);
                    end
                    if isfield(lightStim, 'dmd_device_parameters')
                        app.restoreDmdDeviceParameters( ...
                            lightStim.dmd_device_parameters);
                    end
                    app.DmdOperationalPatternLoaded = false;
                    app.updateDmdGridResolvedPath();
                    app.updateLightStimulusFieldAvailability();
                    app.disarmLightStimulus('user_settings_loaded');
                end
                if isfield(settings, 'timeline_display') && ...
                        isfield(settings.timeline_display, 'hidden_signals')
                    app.DaqTimelineHiddenNames = string( ...
                        settings.timeline_display.hidden_signals);
                    app.DaqTimelineHiddenNames = ...
                        app.DaqTimelineHiddenNames(:).';
                end
                app.SettingsDirty(:) = true;
                app.updateCameraLayout();
                app.updateRecordLengthSummary();
                app.updateAcquisitionControlAvailability(false);
                app.updateVisualConfigurationSummary();
                app.updateAcquisitionStorageEstimate( ...
                    'user_settings_loaded', false);
                app.refreshDaqTimeline('user_settings_loaded');
                app.Logger.log('SUCCESS', 'USER_APP_SETTINGS_LOADED', ...
                    ['File=%s | HardwareCommandsIssued=0 | LightStateForcedOff=1 | ', ...
                     'CameraSettingsPendingApply=1'], ...
                    fullfile(app.VisualPresets.ActiveFolder, 'app_settings.mat'));
                app.setStatus("User settings loaded for " + ...
                    string(app.VisualPresets.ActiveProfile.display_name) + ...
                    ". Light states remain OFF; camera changes apply on connect/apply.");
            catch ME
                app.Logger.logException('USER_APP_SETTINGS_LOAD_FAILED', ME);
                rethrow(ME);
            end
        end

        function finishApplyingUserSettings(app)
            app.ApplyingUserSettings = false;
        end

        function restoreApplyingUserSettings(app, value)
            app.ApplyingUserSettings = logical(value);
        end

        function requireIdentity(app, actionName)
            if app.IdentityConfirmed
                return;
            end
            app.Logger.log('WARNING', 'ACTION_BLOCKED_OPERATOR_REQUIRED', 'Action=%s', actionName);
            app.setStatus("BLOCKED: confirm operator name before " + string(actionName) + ".");
            uialert(app.UIFigure, '请先在首页输入并确认操作者姓名。', 'Operator Required');
            error('ZouLab:OperatorRequired', 'Operator name is not confirmed.');
        end

        function textSettingEdited(app, settingName, previousValue, newValue)
            app.Logger.log('INFO', 'USER_TEXT_SETTING_EDITED', ...
                'Setting=%s | Previous=%s | New=%s', settingName, ...
                string(previousValue), string(newValue));
            app.setStatus(sprintf('%s updated to %s.', settingName, string(newValue)));
            if string(settingName) == "SaveRoot"
                app.scheduleExpensiveUiRefresh( ...
                    'save_root_changed', false, true, true);
            end
            app.persistUserSettings("text_setting_" + string(settingName));
        end

        function initializeModuleMethodState(app)
            emptyState = struct('name', 'Manual', 'source', 'manual', ...
                'signature', '', 'file', '');
            app.ModuleMethodState = struct( ...
                'visual_ptb', emptyState, 'visual_led', emptyState, ...
                'light_stim_laser', emptyState, 'dmd', emptyState);
        end

        function tag = moduleMethodTag(~, moduleName, suffix)
            switch string(moduleName)
                case "visual_ptb"
                    prefix = "VisualMethod";
                case "visual_led"
                    prefix = "LedMethod";
                case "light_stim_laser"
                    prefix = "LaserMethod";
                case "dmd"
                    prefix = "DmdMethod";
                otherwise
                    error('ZouLab:ModuleMethodNameInvalid', ...
                        'Unsupported method module: %s', moduleName);
            end
            tag = prefix + string(suffix);
        end

        function controls = moduleMethodControls(app, moduleName)
            switch string(moduleName)
                case "visual_ptb"
                    controls = struct('dropdown', app.VisualPresetDropDown, ...
                        'name', app.VisualMethodNameField, ...
                        'status', app.VisualPresetStatusLabel);
                case "visual_led"
                    controls = struct('dropdown', app.LedMethodDropDown, ...
                        'name', app.LedMethodNameField, ...
                        'status', app.LedMethodStatusLabel);
                case "light_stim_laser"
                    controls = struct('dropdown', app.LightPresetDropDown, ...
                        'name', app.LightPresetNameField, ...
                        'status', app.LightPresetStatusLabel);
                case "dmd"
                    controls = struct('dropdown', app.DmdMethodDropDown, ...
                        'name', app.DmdMethodNameField, ...
                        'status', app.DmdMethodStatusLabel);
                otherwise
                    error('ZouLab:ModuleMethodNameInvalid', ...
                        'Unsupported method module: %s', moduleName);
            end
        end

        function refreshAllModuleMethodDropDowns(app)
            modules = ["visual_ptb","visual_led", ...
                "light_stim_laser","dmd"];
            for moduleName = modules
                app.refreshModuleMethodDropDown(moduleName);
            end
        end

        function refreshModuleMethodDropDown(app, moduleName)
            controls = app.moduleMethodControls(moduleName);
            if isempty(controls.dropdown) || ~isvalid(controls.dropdown)
                return;
            end
            if string(moduleName) == "visual_ptb"
                entries = app.VisualPresets.listPresets();
            else
                entries = app.ModuleMethods.list(moduleName);
            end
            names = string({entries.name});
            current = string(controls.dropdown.Value);
            items = ["Manual / current settings", names];
            controls.dropdown.Items = cellstr(items);
            match = find(strcmpi(items, current), 1);
            if isempty(match)
                controls.dropdown.Value = 'Manual / current settings';
            else
                controls.dropdown.Value = char(items(match));
            end
            app.refreshModuleMethodStatus(moduleName);
        end

        function moduleMethodSelectionChanged(app, moduleName, ...
                previousValue, newValue)
            controls = app.moduleMethodControls(moduleName);
            app.Logger.log('INFO', ...
                'USER_MODULE_METHOD_SELECTION_CHANGED', ...
                ['Module=%s | Previous=%s | New=%s | Applied=0 | ', ...
                 'HardwareCommandIssued=0'], moduleName, ...
                string(previousValue), string(newValue));
            if string(newValue) == "Manual / current settings"
                controls.status.Text = ...
                    'Manual selected — current controls remain unchanged.';
            else
                controls.status.Text = ...
                    "Selected " + string(newValue) + " — click Load.";
            end
            controls.status.FontColor = [0.75 0.45 0.05];
        end

        function saveModuleMethod(app, moduleName)
            controls = app.moduleMethodControls(moduleName);
            name = strtrim(string(controls.name.Value));
            eventName = "SAVE_MODULE_METHOD_" + upper(string(moduleName));
            app.beginAction(eventName, ...
                "Saving " + string(moduleName) + " method " + name + "...", ...
                controls.status);
            try
                app.requireIdentity('save module method');
                app.assertModuleMethodEditable(moduleName);
                spec = app.currentModuleMethodSpec(moduleName);
                if string(moduleName) == "visual_ptb"
                    entry = app.VisualPresets.savePresetAs(name, spec);
                    source = "user";
                    filePath = "";
                    savedName = string(entry.name);
                else
                    entry = app.ModuleMethods.saveAs(moduleName, name, spec);
                    source = "user";
                    filePath = string(entry.file);
                    savedName = string(entry.name);
                end
                app.setLoadedModuleMethod(moduleName, savedName, source, ...
                    filePath, spec);
                app.refreshModuleMethodDropDown(moduleName);
                controls.dropdown.Value = char(savedName);
                app.Logger.log('SUCCESS', 'MODULE_METHOD_SAVED', ...
                    ['Module=%s | Name=%s | File=%s | ', ...
                     'OnlyModuleParametersStored=1 | HardwareCommandIssued=0'], ...
                    moduleName, savedName, filePath);
                app.finishAction(eventName, true, ...
                    "Saved " + savedName + ".", controls.status);
            catch ME
                app.handleError(eventName + "_FAILED", ME, controls.status);
            end
        end

        function loadModuleMethod(app, moduleName)
            controls = app.moduleMethodControls(moduleName);
            name = string(controls.dropdown.Value);
            eventName = "LOAD_MODULE_METHOD_" + upper(string(moduleName));
            app.beginAction(eventName, ...
                "Loading " + string(moduleName) + " method " + name + "...", ...
                controls.status);
            try
                app.requireIdentity('load module method');
                app.assertModuleMethodEditable(moduleName);
                if name == "Manual / current settings"
                    app.clearLoadedModuleMethod(moduleName);
                    app.finishAction(eventName, true, ...
                        'Manual mode selected; no controls were changed.', ...
                        controls.status);
                    return;
                end
                if string(moduleName) == "visual_ptb"
                    entry = app.VisualPresets.getPreset(name);
                    spec = entry.value;
                    if entry.builtin
                        source = "builtin";
                    else
                        source = "user";
                    end
                    filePath = "";
                else
                    entry = app.ModuleMethods.load(moduleName, name);
                    spec = entry.spec;
                    source = "user";
                    filePath = string(entry.file);
                end
                app.applyModuleMethodSpec(moduleName, spec, name);
                actualSpec = app.currentModuleMethodSpec(moduleName);
                app.setLoadedModuleMethod(moduleName, string(entry.name), ...
                    source, filePath, actualSpec);
                app.Logger.log('SUCCESS', 'MODULE_METHOD_LOADED', ...
                    ['Module=%s | Name=%s | Source=%s | File=%s | ', ...
                     'OtherModulesChanged=0 | HardwareCommandIssued=0'], ...
                    moduleName, string(entry.name), source, filePath);
                app.scheduleExpensiveUiRefresh( ...
                    "module_method_loaded_" + string(moduleName), ...
                    true, true, true);
                app.finishAction(eventName, true, ...
                    "Loaded " + string(entry.name) + ...
                    "; review, then Arm if required.", controls.status);
            catch ME
                app.handleError(eventName + "_FAILED", ME, controls.status);
            end
        end

        function assertModuleMethodEditable(app, moduleName)
            if app.RunState.AcquisitionRunning
                error('ZouLab:ModuleMethodAcquisitionLocked', ...
                    'Wait for Acquisition to finish before changing a method.');
            end
            switch string(moduleName)
                case "visual_ptb"
                    armed = app.VisualStimulusController.Armed;
                case "visual_led"
                    armed = app.LedFlickerController.Armed;
                otherwise
                    armed = app.LightStimulusController.Armed;
            end
            if armed
                error('ZouLab:ModuleMethodArmed', ...
                    'Disarm %s before loading or saving its method.', ...
                    moduleName);
            end
        end

        function setLoadedModuleMethod(app, moduleName, name, source, ...
                filePath, spec)
            state = struct('name', char(string(name)), ...
                'source', char(string(source)), ...
                'signature', char(app.methodSpecSignature(spec)), ...
                'file', char(string(filePath)));
            app.ModuleMethodState.(char(moduleName)) = state;
            app.refreshModuleMethodStatus(moduleName);
        end

        function clearLoadedModuleMethod(app, moduleName)
            app.ModuleMethodState.(char(moduleName)) = struct( ...
                'name', 'Manual', 'source', 'manual', ...
                'signature', '', 'file', '');
            app.refreshModuleMethodStatus(moduleName);
        end

        function refreshAllModuleMethodStatuses(app)
            modules = ["visual_ptb","visual_led", ...
                "light_stim_laser","dmd"];
            for moduleName = modules
                app.refreshModuleMethodStatus(moduleName);
            end
        end

        function refreshModuleMethodStatus(app, moduleName)
            controls = app.moduleMethodControls(moduleName);
            if isempty(controls.status) || ~isvalid(controls.status)
                return;
            end
            state = app.ModuleMethodState.(char(moduleName));
            if ~app.IdentityConfirmed
                controls.status.Text = 'Start a user session to use methods.';
                controls.status.FontColor = [0.30 0.30 0.30];
                return;
            end
            if strlength(string(state.signature)) == 0
                controls.status.Text = 'Manual — current module controls.';
                controls.status.FontColor = [0.30 0.30 0.30];
                return;
            end
            try
                currentSignature = app.methodSpecSignature( ...
                    app.currentModuleMethodSpec(moduleName));
                if currentSignature == string(state.signature)
                    controls.status.Text = ...
                        "Loaded: " + string(state.name);
                    controls.status.FontColor = [0.08 0.55 0.18];
                else
                    controls.status.Text = ...
                        "Modified from: " + string(state.name);
                    controls.status.FontColor = [0.80 0.48 0.05];
                end
            catch ME
                controls.status.Text = "Invalid current method: " + ...
                    string(ME.message);
                controls.status.FontColor = [0.78 0.18 0.12];
            end
        end

        function spec = currentModuleMethodSpec(app, moduleName)
            switch string(moduleName)
                case "visual_ptb"
                    spec = app.visualConfiguration();
                case "visual_led"
                    spec = app.currentLedFlickerSpec();
                case "light_stim_laser"
                    spec = app.currentLaserMethodSpec();
                case "dmd"
                    spec = app.currentDmdMethodSpec();
                otherwise
                    error('ZouLab:ModuleMethodNameInvalid', ...
                        'Unsupported method module: %s', moduleName);
            end
        end

        function applyModuleMethodSpec(app, moduleName, spec, sourceName)
            previousApplying = app.ApplyingUserSettings;
            app.ApplyingUserSettings = true;
            cleanup = onCleanup(@() app.restoreApplyingUserSettings( ...
                previousApplying)); %#ok<NASGU>
            switch string(moduleName)
                case "visual_ptb"
                    app.applyVisualConfiguration(spec, ...
                        "method:" + string(sourceName), false);
                case "visual_led"
                    app.applyLedFlickerMethodSpec(spec);
                case "light_stim_laser"
                    app.applyLaserMethodSpec(spec);
                case "dmd"
                    app.applyDmdMethodSpec(spec);
            end
            app.updateAcquisitionControlAvailability(false);
        end

        function signature = methodSpecSignature(~, spec)
            signatureSpec = spec;
            if isfield(signatureSpec, 'actual')
                signatureSpec = rmfield(signatureSpec, 'actual');
            end
            signature = string(jsonencode(signatureSpec));
        end

        function numericSettingEdited(app, settingName, previousValue, newValue)
            app.Logger.log('INFO', 'USER_NUMERIC_SETTING_EDITED', ...
                'Setting=%s | Previous=%.9g | New=%.9g', settingName, previousValue, newValue);
            app.setStatus(sprintf('%s updated to %.9g.', settingName, newValue));
            app.persistUserSettings("numeric_setting_" + string(settingName));
        end

        function exposurePresetChanged(app, cameraIndex, previousPreset, newPreset)
            preset = string(newPreset);
            app.Logger.log('INFO', 'USER_CAMERA_EXPOSURE_PRESET_SELECTED', ...
                'Camera=%d | PreviousPreset=%s | NewPreset=%s', ...
                cameraIndex, previousPreset, preset);
            if preset == "Custom (saved)"
                app.setCameraStatus(cameraIndex, ...
                    'Custom exposure selected; edit the value, then click Apply.', ...
                    'working');
                return;
            end
            exposureMs = sscanf(char(preset), '%f', 1);
            previousValue = app.ExposureFields{cameraIndex}.Value;
            app.ExposureFields{cameraIndex}.Value = exposureMs;
            app.cameraParameterEdited(cameraIndex, 'ExposureMsPreset', ...
                previousValue, exposureMs);
        end

        function exposureValueEdited(app, cameraIndex, previousValue, newValue)
            app.syncExposurePreset(cameraIndex);
            app.cameraParameterEdited(cameraIndex, 'ExposureMs', ...
                previousValue, newValue);
        end

        function syncExposurePreset(app, cameraIndex)
            value = double(app.ExposureFields{cameraIndex}.Value);
            presetValues = [2.493 10 40 100];
            presetNames = ["2.493 ms" "10 ms" "40 ms" "100 ms"];
            tolerance = max(1e-3, abs(presetValues) * 1e-6);
            matched = find(abs(value - presetValues) <= tolerance, 1);
            if isempty(matched)
                app.ExposurePresetDropDowns{cameraIndex}.Value = ...
                    'Custom (saved)';
            else
                app.ExposurePresetDropDowns{cameraIndex}.Value = ...
                    char(presetNames(matched));
            end
        end

        function roiPresetChanged(app, cameraIndex, previousPreset, newPreset)
            preset = string(newPreset);
            app.Logger.log('INFO', 'USER_CAMERA_ROI_PRESET_SELECTED', ...
                'Camera=%d | PreviousPreset=%s | NewPreset=%s | Bin=%d', ...
                cameraIndex, previousPreset, preset, ...
                app.BinDropDowns{cameraIndex}.Value);
            if preset == "Custom (saved)"
                app.setCameraStatus(cameraIndex, ...
                    'Custom ROI selected; edit [x y w h], then click Apply.', ...
                    'working');
                return;
            end
            sensorSize = sscanf(char(preset), '%f', 1);
            binFactor = app.BinDropDowns{cameraIndex}.Value;
            roi = app.centeredRoiPreset(sensorSize, binFactor);
            previousValue = app.ROIFields{cameraIndex}.Value;
            app.ROIFields{cameraIndex}.Value = mat2str(roi);
            app.Logger.log('SUCCESS', 'CAMERA_ROI_PRESET_RESOLVED', ...
                ['Camera=%d | PresetSensorPixels=%d | Bin=%d | ', ...
                 'SensorOffset=%d | CameraROI=%s | AppliedToHardware=0'], ...
                cameraIndex, sensorSize, binFactor, ...
                (2304 - sensorSize) / 2, mat2str(roi));
            app.cameraParameterEdited(cameraIndex, 'ROIPreset', ...
                previousValue, app.ROIFields{cameraIndex}.Value);
        end

        function roiValueEdited(app, cameraIndex, previousValue, newValue)
            app.syncRoiPreset(cameraIndex);
            app.cameraParameterEdited(cameraIndex, 'ROI', ...
                previousValue, newValue);
        end

        function syncRoiPreset(app, cameraIndex)
            preset = "Custom (saved)";
            try
                roi = zoulab.UserSettings.parseROI(app.ROIFields{cameraIndex}.Value);
                binFactor = app.BinDropDowns{cameraIndex}.Value;
                sensorRoi = roi .* binFactor;
                sensorSizes = [512 1024 2304];
                presetNames = ["512 center" "1024 center" "2304 full"];
                for index = 1:numel(sensorSizes)
                    expected = app.centeredRoiPreset(sensorSizes(index), 1);
                    if isequal(sensorRoi, expected)
                        preset = presetNames(index);
                        break;
                    end
                end
            catch
            end
            app.ROIPresetDropDowns{cameraIndex}.Value = char(preset);
        end

        function roi = centeredRoiPreset(~, sensorSize, binFactor)
            sensorSize = double(sensorSize);
            binFactor = double(binFactor);
            if ~ismember(sensorSize, [512 1024 2304]) || ...
                    ~ismember(binFactor, [1 2 4])
                error('ZouLab:CameraPresetInvalid', ...
                    'ROI preset and Bin must be one of the displayed choices.');
            end
            sensorOffset = (2304 - sensorSize) / 2;
            roi = [sensorOffset sensorOffset sensorSize sensorSize] / binFactor;
        end

        function cameraParameterEdited(app, cameraIndex, settingName, previousValue, newValue)
            app.SettingsDirty(cameraIndex) = true;
            app.Logger.log('INFO', 'USER_CAMERA_PARAMETER_EDITED', ...
                'Camera=%d | Setting=%s | Previous=%s | New=%s | AppliedToHardware=0', ...
                cameraIndex, settingName, string(previousValue), string(newValue));
            app.updateCameraModeLabel(cameraIndex, 'pending');
            app.setCameraStatus(cameraIndex, sprintf('%s edited; click Apply.', settingName), 'working');
            app.scheduleExpensiveUiRefresh(sprintf( ...
                'camera%d_%s_edited', cameraIndex, settingName), ...
                false, true, true);
            app.persistUserSettings(sprintf('camera%d_%s_edited', ...
                cameraIndex, settingName));
        end

        function binChanged(app, cameraIndex, oldBin, newBin)
            app.Logger.log('INFO', 'USER_CAMERA_BIN_CHANGED', ...
                'Camera=%d | PreviousBin=%d | RequestedBin=%d', cameraIndex, oldBin, newBin);
            try
                currentROI = zoulab.UserSettings.parseROI(app.ROIFields{cameraIndex}.Value);
                requestedROI = round(double(currentROI) .* double(oldBin) ./ double(newBin));
                requestedROI(3:4) = max(requestedROI(3:4), 1);
                zoulab.UserSettings.validateROIForBin(requestedROI, newBin);
                app.ROIFields{cameraIndex}.Value = mat2str(requestedROI);
                app.syncRoiPreset(cameraIndex);
                app.SettingsDirty(cameraIndex) = true;
                app.updateCameraModeLabel(cameraIndex, 'pending');
                app.Logger.log('SUCCESS', 'BIN_ROI_AUTO_SCALED', ...
                    ['Camera=%d | OldBin=%d | NewBin=%d | OldROI=%s | ', ...
                     'RequestedROI=%s | AppliedToHardware=0'], ...
                    cameraIndex, oldBin, newBin, mat2str(currentROI), mat2str(requestedROI));
                app.setCameraStatus(cameraIndex, sprintf( ...
                    'Bin %dx→%dx; ROI scaled to %s. Click Apply.', ...
                    oldBin, newBin, mat2str(requestedROI)), 'working');
                app.scheduleExpensiveUiRefresh(sprintf( ...
                    'camera%d_bin_roi_scaled', cameraIndex), ...
                    false, true, true);
                app.persistUserSettings(sprintf('camera%d_bin_roi_scaled', ...
                    cameraIndex));
            catch ME
                app.BinDropDowns{cameraIndex}.Value = oldBin;
                app.Logger.logException('BIN_ROI_AUTO_SCALE_FAILED', ME);
                app.setCameraStatus(cameraIndex, "Bin change rejected: " + string(ME.message), 'error');
                app.showError(ME);
            end
        end

        function success = applyCameraSettings(app, cameraIndex)
            success = false;
            wasPreview = false;
            confirmed = struct( ...
                'exposure', app.Cameras.ExposureTimes(cameraIndex), ...
                'roi', app.Cameras.ROIs{cameraIndex}, ...
                'bin', app.Cameras.Bins(cameraIndex));
            app.beginAction(sprintf('CAMERA_%d_APPLY_SETTINGS', cameraIndex), ...
                sprintf('Applying Camera %d settings...', cameraIndex), ...
                app.CameraStatusLabels{cameraIndex});
            try
                app.requireIdentity(sprintf('apply Camera %d settings', cameraIndex));
                exposure = app.ExposureFields{cameraIndex}.Value / 1000;
                roi = zoulab.UserSettings.parseROI(app.ROIFields{cameraIndex}.Value);
                binFactor = app.BinDropDowns{cameraIndex}.Value;
                zoulab.UserSettings.validateROIForBin(roi, binFactor);
                wasPreview = app.PreviewActive(cameraIndex);
                if wasPreview
                    app.stopCameraPreview(cameraIndex, 'settings_apply');
                end
                app.Cameras.configureCamera(cameraIndex, exposure, roi, binFactor, app.Logger);
                actual = app.Cameras.getActualSettings(cameraIndex);
                app.ExposureFields{cameraIndex}.Value = actual.ExposureTime * 1000;
                app.ROIFields{cameraIndex}.Value = mat2str(actual.ROI);
                app.BinDropDowns{cameraIndex}.Value = actual.Bin;
                app.syncExposurePreset(cameraIndex);
                app.syncRoiPreset(cameraIndex);
                app.SettingsDirty(cameraIndex) = false;
                app.updateCameraModeLabel(cameraIndex, 'actual');
                if wasPreview
                    app.startCameraPreview(cameraIndex, 'settings_apply_restart');
                end
                app.finishAction(sprintf('CAMERA_%d_APPLY_SETTINGS', cameraIndex), true, ...
                    sprintf('Applied: Bin%dx, ROI %s, %.4g ms', actual.Bin, ...
                    mat2str(actual.ROI), actual.ExposureTime * 1000), ...
                    app.CameraStatusLabels{cameraIndex});
                app.updateAcquisitionStorageEstimate(sprintf( ...
                    'camera%d_settings_applied', cameraIndex), true);
                success = true;
            catch ME
                app.ExposureFields{cameraIndex}.Value = ...
                    confirmed.exposure * 1000;
                app.ROIFields{cameraIndex}.Value = mat2str(confirmed.roi);
                app.BinDropDowns{cameraIndex}.Value = confirmed.bin;
                app.syncExposurePreset(cameraIndex);
                app.syncRoiPreset(cameraIndex);
                app.SettingsDirty(cameraIndex) = false;
                app.updateCameraModeLabel(cameraIndex, 'actual');
                app.Logger.log('WARNING', ...
                    'CAMERA_SETTINGS_UI_ROLLED_BACK', ...
                    ['Camera=%d | Bin=%d | ROI=%s | Exposure=%.9g | ', ...
                     'Reason=%s'], cameraIndex, confirmed.bin, ...
                    mat2str(confirmed.roi), confirmed.exposure, ME.message);
                if wasPreview && ~app.PreviewActive(cameraIndex)
                    app.restartPreviewMask([cameraIndex == 1, cameraIndex == 2], ...
                        'settings_apply_failed');
                end
                if strcmp(ME.identifier, 'ZouLab:OperatorRequired')
                    app.identityBlocked(app.CameraStatusLabels{cameraIndex});
                else
                    app.handleError('CAMERA_SETTINGS_UI_FAILED', ME, ...
                        app.CameraStatusLabels{cameraIndex});
                end
                app.Logger.flush();
            end
        end

        function cameraModeChanged(app)
            app.Logger.log('INFO', 'USER_CAMERA_MODE_CHANGED', ...
                'RequestedMode=%s', app.CameraModeDropDown.Value);
            if any(app.PreviewActive)
                app.stopPreviews();
            end
            app.updateCameraLayout();
            indices = app.activeCameraIndices();
            app.Logger.log('SUCCESS', 'CAMERA_MODE_APPLIED', ...
                'Mode=%s | ActiveCameras=%s', app.CameraModeDropDown.Value, mat2str(indices));
            app.setStatus(sprintf('Camera mode: %s. Active: %s.', ...
                app.CameraModeDropDown.Value, mat2str(indices)));
            app.scheduleExpensiveUiRefresh( ...
                'camera_mode_changed', true, true, true);
            app.persistUserSettings('camera_mode_changed');
        end

        function updateCameraLayout(app)
            mode = string(app.CameraModeDropDown.Value);
            for cameraIndex = 1:2
                app.CameraPanels{cameraIndex}.Visible = 'on';
                app.CameraPanels{cameraIndex}.Layout.Column = cameraIndex;
            end
            dual = mode == "Dual";
            if mode == "Camera 1 only"
                app.CameraPanels{1}.Layout.Column = [1 2];
                app.CameraPanels{2}.Visible = 'off';
            elseif mode == "Camera 2 only"
                app.CameraPanels{2}.Layout.Column = [1 2];
                app.CameraPanels{1}.Visible = 'off';
            end
            app.AutoRegistrationButton.Enable = app.onOff(dual);
            app.ManualRegistrationButton.Enable = app.onOff(dual);
            app.LoadRegistrationButton.Enable = app.onOff(dual);
            if dual
                app.RegistrationStatusLabel.Text = 'Ready';
            else
                app.RegistrationStatusLabel.Text = 'Unavailable in single-camera mode';
            end
        end

        function indices = activeCameraIndices(app)
            switch string(app.CameraModeDropDown.Value)
                case "Camera 1 only"
                    indices = 1;
                case "Camera 2 only"
                    indices = 2;
                otherwise
                    indices = [1 2];
            end
        end

        function connectCameras(app)
            indices = app.activeCameraIndices();
            app.beginAction('CONNECT_CAMERAS', ...
                sprintf('Connecting camera(s) for %s...', app.CameraModeDropDown.Value), ...
                app.HardwareStatusLabel);
            try
                app.requireIdentity('connect cameras');
                for cameraIndex = indices
                    app.CameraLamps{cameraIndex}.Color = [0.95 0.65 0.10];
                    app.CameraStateLabels{cameraIndex}.Text = ...
                        sprintf('CAM%d CONNECT', cameraIndex);
                end
                drawnow limitrate nocallbacks;
                for cameraIndex = indices
                    exposure = app.ExposureFields{cameraIndex}.Value / 1000;
                    roi = zoulab.UserSettings.parseROI(app.ROIFields{cameraIndex}.Value);
                    binFactor = app.BinDropDowns{cameraIndex}.Value;
                    app.Cameras.configureCamera(cameraIndex, exposure, roi, binFactor, app.Logger);
                    app.SettingsDirty(cameraIndex) = false;
                end
                app.Cameras.connect(indices, app.Logger);
                for cameraIndex = indices
                    app.updateCameraModeLabel(cameraIndex, 'actual');
                end
                app.updateHardwareStatus();
                app.finishAction('CONNECT_CAMERAS', true, ...
                    sprintf('Connected camera(s): %s', mat2str(indices)), app.HardwareStatusLabel);
            catch ME
                if strcmp(ME.identifier, 'ZouLab:OperatorRequired')
                    app.identityBlocked(app.HardwareStatusLabel);
                else
                    app.updateHardwareStatus();
                    for cameraIndex = indices
                        if ~app.Cameras.Connected(cameraIndex)
                            app.CameraLamps{cameraIndex}.Color = [0.85 0.15 0.12];
                            app.CameraStateLabels{cameraIndex}.Text = ...
                                sprintf('CAM%d ERROR', cameraIndex);
                        end
                    end
                    app.handleError('CAMERA_CONNECT_UI_FAILED', ME, app.HardwareStatusLabel);
                end
            end
        end

        function connectDAQ(app)
            app.beginAction('CONNECT_DAQ', ...
                sprintf('Connecting DAQ %s...', app.DaqController.DeviceID), app.DAQStatusLabel);
            app.DAQLamp.Color = [0.95 0.65 0.10];
            try
                app.requireIdentity('connect DAQ');
                if app.SimulationMode
                    app.Logger.log('INFO', 'DAQ_SIMULATION_BYPASS', ...
                        'No physical DAQ opened in simulation mode.');
                else
                    app.DaqController.connect(app.Logger);
                end
                app.updateHardwareStatus();
                app.finishAction('CONNECT_DAQ', true, ...
                    'DAQ ready for simultaneous trigger', app.DAQStatusLabel);
            catch ME
                app.DAQLamp.Color = [0.85 0.15 0.12];
                if strcmp(ME.identifier, 'ZouLab:OperatorRequired')
                    app.identityBlocked(app.DAQStatusLabel);
                else
                    app.handleError('DAQ_CONNECT_UI_FAILED', ME, app.DAQStatusLabel);
                end
            end
        end

        function updateHardwareStatus(app)
            for cameraIndex = 1:2
                if app.SimulationMode && app.Cameras.Connected(cameraIndex)
                    app.CameraLamps{cameraIndex}.Color = [0.10 0.55 0.95];
                    app.CameraStateLabels{cameraIndex}.Text = sprintf('CAM%d SIM', cameraIndex);
                elseif app.Cameras.Connected(cameraIndex)
                    app.CameraLamps{cameraIndex}.Color = [0.10 0.75 0.20];
                    app.CameraStateLabels{cameraIndex}.Text = sprintf('CAM%d READY', cameraIndex);
                else
                    app.CameraLamps{cameraIndex}.Color = [0.65 0.65 0.65];
                    app.CameraStateLabels{cameraIndex}.Text = sprintf('CAM%d OFF', cameraIndex);
                end
            end
            if app.SimulationMode
                app.DAQLamp.Color = [0.10 0.55 0.95];
                app.DAQStatusLabel.Text = 'DAQ SIM';
            elseif app.DaqController.Connected
                app.DAQLamp.Color = [0.10 0.75 0.20];
                app.DAQStatusLabel.Text = 'DAQ READY';
            else
                app.DAQLamp.Color = [0.65 0.65 0.65];
                app.DAQStatusLabel.Text = 'DAQ OFF';
            end
            app.Logger.log('INFO', 'HARDWARE_STATUS', ...
                '%s | %s | %s', app.CameraStateLabels{1}.Text, ...
                app.CameraStateLabels{2}.Text, app.DAQStatusLabel.Text);
        end

        function startPreviews(app)
            indices = app.activeCameraIndices();
            app.beginAction('START_ACTIVE_PREVIEWS', ...
                sprintf('Starting preview for %s...', mat2str(indices)), ...
                app.AcquisitionStatusLabel);
            try
                for cameraIndex = indices
                    app.startCameraPreview(cameraIndex, 'active_group_button');
                end
                app.finishAction('START_ACTIVE_PREVIEWS', true, ...
                    sprintf('Preview running: %s', mat2str(indices)), ...
                    app.AcquisitionStatusLabel);
            catch ME
                if strcmp(ME.identifier, 'ZouLab:OperatorRequired')
                    app.identityBlocked(app.AcquisitionStatusLabel);
                else
                    app.handleError('START_ACTIVE_PREVIEWS_FAILED', ME, ...
                        app.AcquisitionStatusLabel);
                end
            end
        end

        function startCameraPreviewClicked(app, cameraIndex)
            try
                app.startCameraPreview(cameraIndex, 'camera_button');
            catch ME
                if strcmp(ME.identifier, 'ZouLab:OperatorRequired')
                    app.setCameraStatus(cameraIndex, ...
                        'Blocked: confirm operator name first.', 'error');
                else
                    app.handleError(sprintf('CAMERA_%d_PREVIEW_START_FAILED', cameraIndex), ...
                        ME, app.CameraStatusLabels{cameraIndex});
                end
            end
        end

        function startCameraPreview(app, cameraIndex, source)
            app.beginAction(sprintf('CAMERA_%d_START_PREVIEW', cameraIndex), ...
                sprintf('Camera %d preview starting...', cameraIndex), ...
                app.CameraStatusLabels{cameraIndex});
            app.requireIdentity(sprintf('start Camera %d preview', cameraIndex));
            if app.PreviewActive(cameraIndex)
                app.Logger.log('INFO', 'PREVIEW_START_NOOP_ALREADY_ACTIVE', ...
                    'Camera=%d | Source=%s', cameraIndex, source);
                app.finishAction(sprintf('CAMERA_%d_START_PREVIEW', cameraIndex), true, ...
                    'Preview already running.', app.CameraStatusLabels{cameraIndex});
                return;
            end
            if app.SettingsDirty(cameraIndex)
                error('ZouLab:CameraSettingsPending', ...
                    'Camera %d settings were edited. Click Apply before Preview.', cameraIndex);
            end
            if ~app.Cameras.Connected(cameraIndex)
                exposure = app.ExposureFields{cameraIndex}.Value / 1000;
                roi = zoulab.UserSettings.parseROI(app.ROIFields{cameraIndex}.Value);
                binFactor = app.BinDropDowns{cameraIndex}.Value;
                app.Cameras.configureCamera(cameraIndex, exposure, roi, binFactor, app.Logger);
                app.Cameras.connect(cameraIndex, app.Logger);
                app.updateCameraModeLabel(cameraIndex, 'actual');
            end
            app.FirstFrame(cameraIndex) = false;
            app.ImagingSuccess(cameraIndex) = false;
            app.PreviewFrameCounts(cameraIndex) = 0;
            app.LastFPSSampleCounts(cameraIndex) = 0;
            app.LastStreamFrameCounts(cameraIndex) = 0;
            app.LastStreamCaptureTimes(cameraIndex) = NaN;
            app.PreviewFPS(cameraIndex) = NaN;
            app.StreamFPS(cameraIndex) = NaN;
            app.StreamFPSSamples{cameraIndex} = zeros(0, 2);
            app.PreviewStartTimes(cameraIndex) = NaN;
            app.StreamLowSince(cameraIndex) = NaN;
            app.StreamLowWarningActive(cameraIndex) = false;
            app.PreviewCallbackErrors(cameraIndex) = 0;
            app.LastRenderTime(cameraIndex) = 0;
            % Ordinary preview axes can inherit the figure's default
            % colormap after MLAPP deserialization. Reassert grayscale once
            % per Preview start; raw uint16 pixels and CLim are unchanged.
            app.CameraAxes{cameraIndex}.Colormap = gray(256);
            app.Logger.log('INFO', 'PREVIEW_DISPLAY_COLORMAP_SET', ...
                'Camera=%d | Colormap=gray | RawDataUnchanged=1', ...
                cameraIndex);
            app.FPSLabels{cameraIndex}.BackgroundColor = [1 1 1];
            app.refreshFPSLabel(cameraIndex, true);
            try
                if app.SimulationMode
                    app.PreviewActive(cameraIndex) = true;
                    app.PreviewStartTimes(cameraIndex) = toc(app.PreviewClock);
                    app.ensureSimulationPreviewTimer();
                else
                    app.Cameras.startPreview(cameraIndex, ...
                        app.ImageHandles{cameraIndex}, app.Logger);
                    app.PreviewActive(cameraIndex) = true;
                    app.ensureRemotePreviewTimer();
                    metrics = app.Cameras.getPreviewMetrics(cameraIndex);
                    app.LastStreamFrameCounts(cameraIndex) = ...
                        metrics.FramesAcquired;
                    app.LastStreamCaptureTimes(cameraIndex) = ...
                        metrics.CapturedDatenum;
                    app.PreviewStartTimes(cameraIndex) = toc(app.PreviewClock);
                end
            catch ME
                app.rollbackFailedPreviewStart(cameraIndex, source, ME);
                rethrow(ME);
            end
            app.updatePreviewButtons();
            app.updateHardwareStatus();
            app.Logger.log('SUCCESS', 'PREVIEW_START_SUCCESS', ...
                ['Camera=%d | Source=%s | RenderLimitFPS=%g | ', ...
                 'StreamWarmupSeconds=%g | StreamMedianWindowSeconds=%g | ', ...
                 'ExpectedStreamFPS=%s'], ...
                cameraIndex, source, app.PreviewRenderLimitFPS, ...
                app.PreviewWarmupSeconds, app.StreamWindowSeconds, ...
                app.fpsText(app.expectedStreamFPS(cameraIndex)));
            app.finishAction(sprintf('CAMERA_%d_START_PREVIEW', cameraIndex), true, ...
                'Preview running; waiting for uint16 frame.', ...
                app.CameraStatusLabels{cameraIndex});
        end

        function rollbackFailedPreviewStart(app, cameraIndex, source, exception)
            if ~app.SimulationMode
                try
                    app.Cameras.stopPreview(cameraIndex, app.Logger);
                catch cleanupError
                    app.Logger.logException( ...
                        'PREVIEW_START_ROLLBACK_REMOTE_STOP_FAILED', ...
                        cleanupError);
                end
            end
            app.PreviewActive(cameraIndex) = false;
            app.PreviewFPS(cameraIndex) = NaN;
            app.StreamFPS(cameraIndex) = NaN;
            app.StreamFPSSamples{cameraIndex} = zeros(0, 2);
            app.LastStreamFrameCounts(cameraIndex) = 0;
            app.LastStreamCaptureTimes(cameraIndex) = NaN;
            app.PreviewStartTimes(cameraIndex) = NaN;
            app.StreamLowSince(cameraIndex) = NaN;
            app.StreamLowWarningActive(cameraIndex) = false;
            app.FPSLabels{cameraIndex}.BackgroundColor = [1 1 1];
            app.refreshFPSLabel(cameraIndex, false);
            if ~any(app.PreviewActive)
                app.stopAndDeleteTimer('SimulationTimer');
                app.stopAndDeleteTimer('RemotePreviewTimer');
            end
            app.updatePreviewButtons();
            app.Logger.log('WARNING', 'PREVIEW_START_ROLLED_BACK', ...
                ['Camera=%d | Source=%s | LocalPreviewActive=0 | ', ...
                 'RemoteStopAttempted=%d | ErrorID=%s'], ...
                cameraIndex, source, ~app.SimulationMode, exception.identifier);
        end

        function stopPreviews(app)
            indices = app.activeCameraIndices();
            app.beginAction('STOP_ACTIVE_PREVIEWS', ...
                sprintf('Stopping preview for %s...', mat2str(indices)), ...
                app.AcquisitionStatusLabel);
            for cameraIndex = indices
                app.stopCameraPreview(cameraIndex, 'active_group_button');
            end
            app.finishAction('STOP_ACTIVE_PREVIEWS', true, ...
                sprintf('Preview stopped: %s', mat2str(indices)), ...
                app.AcquisitionStatusLabel);
        end

        function stopCameraPreview(app, cameraIndex, source)
            app.beginAction(sprintf('CAMERA_%d_STOP_PREVIEW', cameraIndex), ...
                sprintf('Stopping Camera %d preview...', cameraIndex), ...
                app.CameraStatusLabels{cameraIndex});
            remoteStopped = true;
            stopError = [];
            try
                app.Cameras.stopPreview(cameraIndex, app.Logger);
            catch ME
                remoteStopped = false;
                stopError = ME;
                app.Logger.logException('PREVIEW_STOP_CAMERA_FAILED', ME);
            end
            app.PreviewActive(cameraIndex) = false;
            app.PreviewFPS(cameraIndex) = NaN;
            app.StreamFPS(cameraIndex) = NaN;
            app.StreamFPSSamples{cameraIndex} = zeros(0, 2);
            app.LastStreamFrameCounts(cameraIndex) = 0;
            app.LastStreamCaptureTimes(cameraIndex) = NaN;
            app.PreviewStartTimes(cameraIndex) = NaN;
            app.StreamLowSince(cameraIndex) = NaN;
            app.StreamLowWarningActive(cameraIndex) = false;
            app.FPSLabels{cameraIndex}.BackgroundColor = [1 1 1];
            app.refreshFPSLabel(cameraIndex, false);
            if ~any(app.PreviewActive)
                app.stopAndDeleteTimer('SimulationTimer');
                app.stopAndDeleteTimer('RemotePreviewTimer');
            end
            app.updatePreviewButtons();
            if remoteStopped
                app.Logger.log('SUCCESS', 'PREVIEW_STOP_SUCCESS', ...
                    'Camera=%d | Source=%s', cameraIndex, source);
                app.finishAction(sprintf('CAMERA_%d_STOP_PREVIEW', cameraIndex), true, ...
                    'Preview stopped; camera remains connected.', ...
                    app.CameraStatusLabels{cameraIndex});
            else
                app.Logger.log('WARNING', 'PREVIEW_LOCAL_STOP_ONLY', ...
                    ['Camera=%d | Source=%s | RemoteStopConfirmed=0 | ', ...
                     'ErrorID=%s'], cameraIndex, source, stopError.identifier);
                app.finishAction(sprintf('CAMERA_%d_STOP_PREVIEW', cameraIndex), false, ...
                    ['Local preview stopped, but the camera service did not ', ...
                     'confirm the command. Click Preview to reconnect.'], ...
                    app.CameraStatusLabels{cameraIndex});
            end
        end

        function updatePreviewButtons(app)
            for cameraIndex = 1:2
                app.CameraPreviewStartButtons{cameraIndex}.Enable = ...
                    app.onOff(app.IdentityConfirmed && ...
                    ~app.PreviewActive(cameraIndex) && ...
                    ~app.RunState.AcquisitionRunning);
                app.CameraPreviewStopButtons{cameraIndex}.Enable = ...
                    app.onOff(app.IdentityConfirmed && ...
                    app.PreviewActive(cameraIndex) && ...
                    ~app.RunState.AcquisitionRunning);
            end
        end

        function previewFrameCallback(app, cameraIndex, event, imageObject)
            if app.RunState.Closing || ~app.PreviewActive(cameraIndex)
                return;
            end
            try
                frame = uint16(event.Data);
                frameRate = NaN;
                rawFrameRate = [];
                try
                    rawFrameRate = event.FrameRate;
                    frameRate = app.parseFrameRate(rawFrameRate);
                catch
                end
                if ~app.FirstFrame(cameraIndex)
                    app.Logger.log('INFO', ...
                        sprintf('CAMERA_%d_FRAME_RATE_FIELD', cameraIndex), ...
                        'RawClass=%s | RawValue=%s | ParsedFPS=%.3f', ...
                        class(rawFrameRate), app.diagnosticValueText(rawFrameRate), ...
                        frameRate);
                end
                timestamp = string(datetime('now', 'Format', 'HH:mm:ss.SSS'));
                try
                    reportedTimestamp = string(event.Timestamp);
                    if isscalar(reportedTimestamp) && strlength(reportedTimestamp) > 0
                        timestamp = reportedTimestamp;
                    end
                catch
                end
                app.ingestPreviewFrame(cameraIndex, frame, frameRate, timestamp, imageObject);
            catch ME
                app.PreviewCallbackErrors(cameraIndex) = ...
                    app.PreviewCallbackErrors(cameraIndex) + 1;
                app.Logger.logException(sprintf('CAMERA_%d_PREVIEW_CALLBACK_FAILED', ...
                    cameraIndex), ME);
                app.Logger.log('ERROR', 'PREVIEW_CALLBACK_HEALTH', ...
                    'Camera=%d | CallbackErrors=%d | FramesAccepted=%d', ...
                    cameraIndex, app.PreviewCallbackErrors(cameraIndex), ...
                    app.PreviewFrameCounts(cameraIndex));
                app.setCameraStatus(cameraIndex, ...
                    sprintf('Preview callback error (%d); see log.', ...
                    app.PreviewCallbackErrors(cameraIndex)), 'error');
            end
        end

        function rendered = ingestPreviewFrame(app, cameraIndex, frame, frameRate, timestamp, imageObject)
            rendered = false;
            if ~app.PreviewActive(cameraIndex)
                return;
            end
            app.LatestFrames{cameraIndex} = frame;
            app.PreviewFrameCounts(cameraIndex) = app.PreviewFrameCounts(cameraIndex) + 1;
            elapsed = toc(app.PreviewClock);
            if app.SimulationMode && isscalar(frameRate) && ...
                    isfinite(frameRate) && frameRate > 0
                previewAge = elapsed - app.PreviewStartTimes(cameraIndex);
                if previewAge >= app.PreviewWarmupSeconds
                    app.StreamFPSSamples{cameraIndex}(end + 1, :) = ...
                        [elapsed double(frameRate)];
                end
            end
            if strcmp(app.ContrastModes{cameraIndex}.Value, 'Auto') && ...
                    (~app.FirstFrame(cameraIndex) || ...
                     elapsed - app.LastContrastUpdate(cameraIndex) >= ...
                        1 / app.AutoContrastLimitFPS)
                app.applyAutoContrast(cameraIndex, frame, ...
                    ~app.FirstFrame(cameraIndex));
                app.LastContrastUpdate(cameraIndex) = elapsed;
            end
            freezeForDmdMask = app.DmdManualMaskActive && ...
                cameraIndex == app.DmdManualMaskCameraIndex;
            if ~app.ManualRegistrationActive && ~freezeForDmdMask && ...
                    (~app.FirstFrame(cameraIndex) || ...
                    elapsed - app.LastRenderTime(cameraIndex) >= ...
                    1 / app.PreviewRenderLimitFPS)
                if app.TransposeDisplay(cameraIndex)
                    imageObject.CData = frame.';
                else
                    imageObject.CData = frame;
                end
                app.LastRenderTime(cameraIndex) = elapsed;
                rendered = true;
            end
            if ~app.FirstFrame(cameraIndex)
                app.FirstFrame(cameraIndex) = true;
                rawMin = min(frame, [], 'all');
                rawMax = max(frame, [], 'all');
                app.Logger.log('INFO', sprintf('CAMERA_%d_FIRST_FRAME', cameraIndex), ...
                    ['Size=%s | Class=%s | RawMin=%g | RawMax=%g | Timestamp=%s | ', ...
                     'PreviewEventFrameRateFPS=%.3f | DisplayTranspose=%d'], ...
                    mat2str(size(frame)), class(frame), rawMin, rawMax, timestamp, ...
                    frameRate, app.TransposeDisplay(cameraIndex));
            end
            if ~app.ImagingSuccess(cameraIndex) && isa(frame, 'uint16') && ...
                    max(frame, [], 'all') > min(frame, [], 'all')
                app.ImagingSuccess(cameraIndex) = true;
                app.ImagingLabels{cameraIndex}.Text = 'Imaging: SUCCESS';
                app.ImagingLabels{cameraIndex}.FontColor = [0.05 0.55 0.15];
                app.Logger.log('SUCCESS', sprintf('CAMERA_%d_IMAGING_SUCCESS', cameraIndex), ...
                    'uint16=1 | NonzeroDynamicRange=1 | PreviewEventFrameRateFPS=%.3f', ...
                    frameRate);
                app.setCameraStatus(cameraIndex, 'Imaging success: uint16 with contrast.', 'success');
            end
        end

        function startStatusTimer(app)
            app.stopAndDeleteTimer('StatusTimer');
            app.LastStatusTime = toc(app.PreviewClock);
            app.LastHealthLogTime = app.LastStatusTime;
            app.StatusTimer = timer('ExecutionMode', 'fixedSpacing', 'Period', 1, ...
                'Name', 'ZouLabPreviewHealth', ...
                'BusyMode', 'drop', 'TimerFcn', @(~,~) app.statusTick());
            start(app.StatusTimer);
        end

        function statusTick(app)
            if app.RunState.Closing
                return;
            end
            if app.PreviewDiagnosticsEnabled && ...
                    ~isempty(app.PreviewDiagnosticsClock)
                app.samplePreviewDiagnosticsMemory();
            end
            if app.PreviewDiagnosticsEnabled && ...
                    ~isempty(app.PreviewDiagnosticsClock) && ...
                    toc(app.PreviewDiagnosticsClock) >= ...
                    app.PreviewDiagnosticsDurationSeconds
                app.PreviewDiagnosticsEnabled = false;
                app.PreviewDiagnosticsPending = true;
            end
            if app.PreviewDiagnosticsPending && ~app.RunState.AcquisitionRunning
                app.savePreviewDiagnostics();
            end
            elapsed = toc(app.PreviewClock);
            deltaT = max(elapsed - app.LastStatusTime, eps);
            for cameraIndex = 1:2
                if app.PreviewActive(cameraIndex)
                    deltaFrames = app.PreviewFrameCounts(cameraIndex) - ...
                        app.LastFPSSampleCounts(cameraIndex);
                    app.PreviewFPS(cameraIndex) = deltaFrames / deltaT;
                    previewAge = elapsed - app.PreviewStartTimes(cameraIndex);
                    metrics = struct('FramesAcquired', NaN, 'FramesAvailable', NaN, ...
                        'Running', "simulation", 'Logging', "simulation", ...
                        'FlushErrors', 0, 'CapturedDatenum', NaN, ...
                        'Sequence', uint64(0));
                    if ~app.SimulationMode
                        try
                            metrics = app.Cameras.getPreviewMetrics(cameraIndex);
                            acquiredFrames = metrics.FramesAcquired;
                            capturedDatenum = metrics.CapturedDatenum;
                            previousFrames = app.LastStreamFrameCounts(cameraIndex);
                            previousCaptured = app.LastStreamCaptureTimes(cameraIndex);
                            if isfinite(acquiredFrames) && isfinite(capturedDatenum) && ...
                                    (acquiredFrames ~= previousFrames || ...
                                     capturedDatenum ~= previousCaptured)
                                deltaAcquired = acquiredFrames - previousFrames;
                                deltaCaptureSeconds = ...
                                    (capturedDatenum - previousCaptured) * 86400;
                                app.LastStreamFrameCounts(cameraIndex) = acquiredFrames;
                                app.LastStreamCaptureTimes(cameraIndex) = capturedDatenum;
                                if previewAge >= app.PreviewWarmupSeconds && ...
                                        isfinite(previousCaptured) && ...
                                        deltaAcquired >= 0 && deltaCaptureSeconds > 0 && ...
                                        metrics.Running == "on"
                                    app.StreamFPSSamples{cameraIndex}(end + 1, :) = ...
                                        [elapsed deltaAcquired / deltaCaptureSeconds];
                                end
                            end
                        catch ME
                            app.Logger.log('WARNING', 'PREVIEW_STREAM_COUNTER_QUERY_FAILED', ...
                                'Camera=%d | Error=%s', cameraIndex, ME.message);
                        end
                    end
                    samples = app.StreamFPSSamples{cameraIndex};
                    if ~isempty(samples)
                        samples = samples(samples(:, 1) >= ...
                            elapsed - app.StreamWindowSeconds, :);
                    end
                    app.StreamFPSSamples{cameraIndex} = samples;
                    if isempty(samples)
                        app.StreamFPS(cameraIndex) = NaN;
                    else
                        app.StreamFPS(cameraIndex) = median(samples(:, 2));
                    end
                    app.updateStreamWarning(cameraIndex, elapsed);
                    app.refreshFPSLabel(cameraIndex, ...
                        previewAge < app.PreviewWarmupSeconds);
                    if elapsed - app.LastHealthLogTime >= 10
                        app.Logger.log('INFO', 'PREVIEW_HEALTH', ...
                            ['Camera=%d | StreamFPS=%s | StreamMeasurement=FramesAcquired/captured-time | ', ...
                             'StreamSampleCount=%d | FramesAcquired=%s | FramesAvailable=%s | ', ...
                             'VideoRunning=%s | VideoLogging=%s | BufferFlushErrors=%d | ', ...
                             'PreviewUpdateFPS=%.3f | Record=%s | ExpectedStreamFPS=%s | ', ...
                             'WarningThresholdFraction=%.3f | LowWarning=%d | ', ...
                             'RenderLimitFPS=%.3f | Frames=%d | CallbackErrors=%d'], ...
                            cameraIndex, app.fpsText(app.StreamFPS(cameraIndex)), ...
                            size(samples, 1), app.diagnosticValueText(metrics.FramesAcquired), ...
                            app.diagnosticValueText(metrics.FramesAvailable), ...
                            metrics.Running, metrics.Logging, metrics.FlushErrors, ...
                            app.PreviewFPS(cameraIndex), ...
                            app.RecordStatus(cameraIndex), ...
                            app.fpsText(app.expectedStreamFPS(cameraIndex)), ...
                            app.StreamWarningFraction, ...
                            app.StreamLowWarningActive(cameraIndex), ...
                            app.PreviewRenderLimitFPS, ...
                            app.PreviewFrameCounts(cameraIndex), ...
                            app.PreviewCallbackErrors(cameraIndex));
                    end
                end
            end
            app.LastFPSSampleCounts = app.PreviewFrameCounts;
            app.LastStatusTime = elapsed;
            if elapsed - app.LastHealthLogTime >= 10
                app.LastHealthLogTime = elapsed;
            end
        end

        function startLogFlushTimer(app)
            % Log persistence must not depend on the preview/status timer.
            % A callback error in preview health reporting must never leave
            % the diagnostic log buffered indefinitely.
            app.stopAndDeleteTimer('LogFlushTimer');
            app.LogFlushTimer = timer('ExecutionMode', 'fixedSpacing', ...
                'Period', app.LogFlushIntervalSeconds, ...
                'Name', 'ZouLabIdleLogFlush', 'BusyMode', 'drop', ...
                'TimerFcn', @(~,~) app.logFlushTick());
            start(app.LogFlushTimer);
        end

        function logFlushTick(app)
            if app.RunState.Closing
                return;
            end
            app.flushLogNowIfIdle(false);
        end

        function flushed = flushLogNowIfIdle(app, refreshView)
            if nargin < 2
                refreshView = true;
            end
            busy = app.RunState.AcquisitionRunning || ~isempty(app.TimeLapseTimer) || ...
                app.VisualPreviewRunning || app.RunState.ConversionRunning;
            flushed = false;
            if busy
                return;
            end
            try
                app.Logger.flush();
                flushed = true;
                if refreshView
                    app.refreshLogView();
                end
            catch ME
                % Retain the queued lines for the next idle flush attempt.
                fprintf(2, 'ZouLab idle log flush failed: %s\n', ME.message);
            end
        end

        function refreshFPSLabel(app, cameraIndex, estimating)
            if estimating
                streamText = 'estimating';
            else
                streamText = strtrim(app.fpsText(app.StreamFPS(cameraIndex)));
            end
            if app.PreviewActive(cameraIndex)
                viewText = strtrim(app.fpsText(app.PreviewFPS(cameraIndex)));
            else
                viewText = '--';
            end
            app.FPSLabels{cameraIndex}.Value = sprintf( ...
                'Stream %s | View %s | Record %s', ...
                streamText, viewText, app.RecordStatus(cameraIndex));
        end

        function updateStreamWarning(app, cameraIndex, elapsed)
            streamFPS = app.StreamFPS(cameraIndex);
            expectedFPS = app.expectedStreamFPS(cameraIndex);
            if ~isfinite(streamFPS) || ~isfinite(expectedFPS)
                return;
            end
            threshold = expectedFPS * app.StreamWarningFraction;
            if streamFPS < threshold
                if ~isfinite(app.StreamLowSince(cameraIndex))
                    app.StreamLowSince(cameraIndex) = elapsed;
                end
                if ~app.StreamLowWarningActive(cameraIndex) && ...
                        elapsed - app.StreamLowSince(cameraIndex) >= ...
                        app.StreamLowDurationSeconds
                    app.StreamLowWarningActive(cameraIndex) = true;
                    app.FPSLabels{cameraIndex}.BackgroundColor = [1 0.93 0.68];
                    app.Logger.log('WARNING', 'PREVIEW_STREAM_LOW_WARNING', ...
                        ['Camera=%d | StreamFPS=%.3f | ExpectedFPS=%.3f | ', ...
                         'ThresholdFPS=%.3f | ThresholdFraction=%.3f | ', ...
                         'RequiredDuration=%.3f s | Measurement=2s_sliding_median'], ...
                        cameraIndex, streamFPS, expectedFPS, threshold, ...
                        app.StreamWarningFraction, app.StreamLowDurationSeconds);
                    app.setCameraStatus(cameraIndex, sprintf( ...
                        'Warning: Stream %.1f FPS is below %.1f FPS.', ...
                        streamFPS, threshold), 'warning');
                end
                return;
            end

            if app.StreamLowWarningActive(cameraIndex)
                app.Logger.log('SUCCESS', 'PREVIEW_STREAM_RECOVERED', ...
                    'Camera=%d | StreamFPS=%.3f | ExpectedFPS=%.3f', ...
                    cameraIndex, streamFPS, expectedFPS);
                app.setCameraStatus(cameraIndex, sprintf( ...
                    'Stream recovered: %.1f FPS.', streamFPS), 'success');
            end
            app.StreamLowSince(cameraIndex) = NaN;
            app.StreamLowWarningActive(cameraIndex) = false;
            app.FPSLabels{cameraIndex}.BackgroundColor = [1 1 1];
        end

        function expectedFPS = expectedStreamFPS(app, cameraIndex)
            if app.SimulationMode
                expectedFPS = 100;
                return;
            end
            expectedFPS = NaN;
            roi = app.Cameras.ROIs{cameraIndex};
            isValidatedConfiguration = app.Cameras.Bins(cameraIndex) == 1 && ...
                isequal(double(roi(3:4)), [512 512]) && ...
                contains(string(app.Cameras.VideoFormats(cameraIndex)), 'Fast', ...
                'IgnoreCase', true);
            if isValidatedConfiguration
                expectedFPS = min(400, 1 / app.Cameras.ExposureTimes(cameraIndex));
            end
        end

        function ensureSimulationPreviewTimer(app)
            if ~isempty(app.SimulationTimer) && isvalid(app.SimulationTimer)
                return;
            end
            app.SimulationTimer = timer('ExecutionMode', 'fixedSpacing', ...
                'Name', 'ZouLabSimulationPreview', ...
                'Period', 0.017, 'BusyMode', 'drop', ...
                'TimerFcn', @(~,~) app.simulationTick());
            start(app.SimulationTimer);
            app.Logger.log('INFO', 'SIMULATION_PREVIEW_STARTED', ...
                ['GeneratorPeriodSeconds=0.017 | GeneratorLimitFPS<=60 | BusyMode=drop | ', ...
                 'RenderFlush=drawnow_nocallbacks_once_per_tick | RenderLimitFPS=%g'], ...
                app.PreviewRenderLimitFPS);
        end

        function ensureRemotePreviewTimer(app)
            if ~isempty(app.RemotePreviewTimer) && isvalid(app.RemotePreviewTimer)
                return;
            end
            % Schedule after the preceding callback finishes, rather than
            % waiting for a fixed refresh beat. ingestPreviewFrame retains
            % the display FPS cap; the shared mailbox retains only new frames.
            app.RemotePreviewTimer = timer('ExecutionMode', 'fixedSpacing', ...
                'Name', 'ZouLabRemotePreview', 'Period', 0.001, ...
                'TimerFcn', @(~,~) app.remotePreviewTick());
            start(app.RemotePreviewTimer);
            app.Logger.log('INFO', 'REMOTE_PREVIEW_UI_TIMER_STARTED', ...
                ['Scheduling=after_previous_callback | YieldSeconds=0.001 | ', ...
                 'RenderLimitFPS=%g | FullResolution=1 | ', ...
                 'PixelTransport=memory_mapped_latest_frame | ', ...
                 'RenderFlush=%s | PreviewAxes=%s'], ...
                app.PreviewRenderLimitFPS, app.PreviewRenderFlushStrategy, ...
                app.PreviewAxesImplementation);
        end

        function remotePreviewTick(app)
            if app.RunState.Closing || app.SimulationMode || ~any(app.PreviewActive)
                return;
            end
            diagnostic = app.PreviewDiagnosticsEnabled;
            if diagnostic && app.RunState.AcquisitionRunning
                app.PreviewDiagnosticsEnabled = false;
                app.PreviewDiagnosticsPending = app.PreviewDiagnosticsCount > 0;
                diagnostic = false;
            end
            if diagnostic
                if isempty(app.PreviewDiagnosticsClock)
                    app.PreviewDiagnosticsClock = tic;
                    app.Logger.log('INFO', 'PREVIEW_DIAGNOSTICS_STARTED', ...
                        ['DurationSeconds=%g | Storage=in_memory | ', ...
                         'PerFrameDiskWrites=0 | RenderFlush=%s | ', ...
                         'PreviewAxes=%s'], ...
                        app.PreviewDiagnosticsDurationSeconds, ...
                        app.PreviewRenderFlushStrategy, ...
                        app.PreviewAxesImplementation);
                end
                tickClock = tic;
                timing = nan(1,23);
                timing(1) = toc(app.PreviewDiagnosticsClock);
                timing(2:13) = 0;
                timing(22:23) = app.PreviewActive;
            end
            renderedAny = false;
            for cameraIndex = find(app.PreviewActive)
                try
                    if diagnostic, stageClock = tic; end
                    [frame, metadata, updated] = ...
                        app.Cameras.pollPreview(cameraIndex);
                    if diagnostic
                        timing(1 + cameraIndex) = toc(stageClock) * 1000;
                        timing(9 + cameraIndex) = updated;
                    end
                    if ~updated
                        continue;
                    end
                    if diagnostic
                        timing(13 + cameraIndex) = double(metadata.sequence);
                        timing(15 + cameraIndex) = metadata.frames_acquired;
                        timing(17 + cameraIndex) = metadata.captured_datenum;
                        stageClock = tic;
                    end
                    timestamp = string(datetime(metadata.captured_datenum, ...
                        'ConvertFrom', 'datenum', 'Format', 'HH:mm:ss.SSS'));
                    if diagnostic
                        timing(3 + cameraIndex) = toc(stageClock) * 1000;
                        stageClock = tic;
                    end
                    rendered = app.ingestPreviewFrame(cameraIndex, frame, NaN, ...
                        timestamp, app.ImageHandles{cameraIndex});
                    if diagnostic
                        timing(5 + cameraIndex) = toc(stageClock) * 1000;
                        timing(11 + cameraIndex) = rendered;
                    end
                    renderedAny = renderedAny || rendered;
                catch ME
                    app.PreviewCallbackErrors(cameraIndex) = ...
                        app.PreviewCallbackErrors(cameraIndex) + 1;
                    app.Logger.logException(sprintf( ...
                        'CAMERA_%d_REMOTE_PREVIEW_POLL_FAILED', cameraIndex), ME);
                end
            end
            % Commit both camera CData assignments as one graphics batch.
            % nocallbacks prevents UI callbacks from re-entering this timer.
            % fixedSpacing schedules the next tick after this one finishes;
            % the shared mailbox skips obsolete preview frames.
            if renderedAny
                if diagnostic, stageClock = tic; end
                if app.PreviewRenderFlushStrategy == "synchronous_drawnow"
                    drawnow nocallbacks;
                    if diagnostic, timing(8) = toc(stageClock) * 1000; end
                elseif diagnostic
                    % The callback returns immediately after CData assignment,
                    % matching the explicit behavior of MATLAB's native
                    % Image Acquisition preview callback.
                    timing(8) = 0;
                end
            end
            if diagnostic
                timing(9) = toc(tickClock) * 1000;
                timing(20:21) = app.PreviewCallbackErrors;
                app.PreviewDiagnosticsCount = app.PreviewDiagnosticsCount + 1;
                app.PreviewDiagnosticsData(app.PreviewDiagnosticsCount,:) = timing;
                if toc(app.PreviewDiagnosticsClock) >= ...
                        app.PreviewDiagnosticsDurationSeconds || ...
                        app.PreviewDiagnosticsCount >= size(app.PreviewDiagnosticsData,1)
                    app.PreviewDiagnosticsEnabled = false;
                    app.PreviewDiagnosticsPending = true;
                end
            end
        end

        function samplePreviewDiagnosticsMemory(app)
            % This runs at 1 Hz in statusTick, not in the preview frame path.
            % matlabwindowhelper values are system-wide totals because the
            % public .NET process API does not expose parent PID directly.
            if app.PreviewDiagnosticsMemoryCount >= ...
                    size(app.PreviewDiagnosticsMemory, 1)
                return;
            end
            elapsedSeconds = toc(app.PreviewDiagnosticsClock);
            matlabWorkingMiB = NaN;
            matlabPrivateMiB = NaN;
            helperCount = NaN;
            helperWorkingMiB = NaN;
            helperPrivateMiB = NaN;
            try
                process = System.Diagnostics.Process.GetCurrentProcess();
                matlabWorkingMiB = double(process.WorkingSet64) / 2^20;
                matlabPrivateMiB = double(process.PrivateMemorySize64) / 2^20;
                process.Dispose();
                helpers = System.Diagnostics.Process.GetProcessesByName( ...
                    'matlabwindowhelper');
                helperCount = numel(helpers);
                helperWorkingMiB = 0;
                helperPrivateMiB = 0;
                for helperIndex = 1:helperCount
                    try
                        helperWorkingMiB = helperWorkingMiB + ...
                            double(helpers(helperIndex).WorkingSet64) / 2^20;
                        helperPrivateMiB = helperPrivateMiB + ...
                            double(helpers(helperIndex).PrivateMemorySize64) / 2^20;
                        helpers(helperIndex).Dispose();
                    catch
                        % A helper can exit between enumeration and sampling.
                    end
                end
            catch
                % Timing data remains useful if process counters are absent.
            end
            app.PreviewDiagnosticsMemoryCount = ...
                app.PreviewDiagnosticsMemoryCount + 1;
            app.PreviewDiagnosticsMemory( ...
                app.PreviewDiagnosticsMemoryCount, :) = ...
                [elapsedSeconds matlabWorkingMiB matlabPrivateMiB ...
                 helperCount helperWorkingMiB helperPrivateMiB];
        end

        function savePreviewDiagnostics(app)
            % Never flush a timing report in a recording/cycle callback.
            if app.RunState.AcquisitionRunning || ~app.PreviewDiagnosticsPending
                return;
            end
            app.PreviewDiagnosticsPending = false;
            try
                names = {'elapsed_s','poll_cam1_ms','poll_cam2_ms', ...
                    'timestamp_cam1_ms','timestamp_cam2_ms', ...
                    'ingest_cam1_ms','ingest_cam2_ms','drawnow_ms','tick_ms', ...
                    'updated_cam1','updated_cam2','rendered_cam1','rendered_cam2', ...
                    'sequence_cam1','sequence_cam2','acquired_cam1','acquired_cam2', ...
                    'captured_datenum_cam1','captured_datenum_cam2', ...
                    'errors_cam1','errors_cam2','active_cam1','active_cam2'};
                samples = array2table(app.PreviewDiagnosticsData( ...
                    1:app.PreviewDiagnosticsCount,:), 'VariableNames', names);
                samples.callback_interval_ms = [NaN; diff(samples.elapsed_s)*1000];
                samples.gap_after_previous_callback_ms = ...
                    samples.callback_interval_ms - [NaN; samples.tick_ms(1:end-1)];
                memoryNames = {'elapsed_s','matlab_working_mib', ...
                    'matlab_private_mib','helper_count', ...
                    'helper_working_mib','helper_private_mib'};
                memorySamples = array2table(app.PreviewDiagnosticsMemory( ...
                    1:app.PreviewDiagnosticsMemoryCount,:), ...
                    'VariableNames', memoryNames);
                folder = fullfile(app.AppRoot, 'reports', ...
                    ['preview_live_' char(datetime('now','Format','yyyyMMdd_HHmmss_SSS'))]);
                mkdir(folder);
                info = struct('matlab',version, 'app_log',app.Logger.FilePath, ...
                    'requested_seconds',app.PreviewDiagnosticsDurationSeconds, ...
                    'sample_count',height(samples), ...
                    'render_flush_strategy',app.PreviewRenderFlushStrategy, ...
                    'preview_axes_implementation',app.PreviewAxesImplementation, ...
                    'semantics','rendered means CData submitted, not physical screen presentation', ...
                    'memory_semantics', ...
                    ['MATLAB counters belong to this process; helper counters ', ...
                     'are totals for all matlabwindowhelper processes on the host'], ...
                    'created_local',char(datetime('now','Format','yyyy-MM-dd HH:mm:ss.SSS')));
                save(fullfile(folder,'preview_timing.mat'), ...
                    'samples','memorySamples','info');
                writetable(samples,fullfile(folder,'preview_timing.csv'));
                writetable(memorySamples,fullfile(folder,'process_memory.csv'));
                app.PreviewDiagnosticsData = zeros(0,23);
                app.PreviewDiagnosticsMemory = zeros(0,6);
                app.Logger.log('SUCCESS', 'PREVIEW_DIAGNOSTICS_SAVED', ...
                    ['Folder=%s | Samples=%d | MemorySamples=%d | ', ...
                     'RenderFlush=%s | PreviewAxes=%s | HardwareCommandsAdded=0'], ...
                    folder,height(samples),height(memorySamples), ...
                    app.PreviewRenderFlushStrategy, ...
                    app.PreviewAxesImplementation);
                app.setStatus("Preview timing saved: " + string(folder));
            catch ME
                % Keep collected data in memory; do not repeatedly retry and
                % perturb preview on every status tick after a disk failure.
                app.Logger.logException('PREVIEW_DIAGNOSTICS_SAVE_FAILED', ME);
            end
        end

        function simulationTick(app)
            if app.RunState.Closing || ~any(app.PreviewActive)
                return;
            end
            renderedAny = false;
            for cameraIndex = find(app.PreviewActive)
                roi = app.Cameras.ROIs{cameraIndex};
                width = roi(3);
                height = roi(4);
                [x, y] = meshgrid(1:width, 1:height);
                cx = width * (0.35 + 0.12 * cameraIndex) + ...
                    width * 0.04 * sin(toc(app.PreviewClock));
                cy = height * 0.5;
                scale = max(10, min(width, height)^2 / 30);
                frame = uint16(1500 + 50000 * exp(-((x-cx).^2 + (y-cy).^2) / scale) + ...
                    2500 * rand(height, width));
                rendered = app.ingestPreviewFrame(cameraIndex, frame, 100, ...
                    string(datetime('now', 'Format', 'HH:mm:ss.SSS')), ...
                    app.ImageHandles{cameraIndex});
                renderedAny = renderedAny || rendered;
            end
            if renderedAny
                drawnow nocallbacks;
            end
        end

        function contrastModeChanged(app, cameraIndex)
            mode = app.ContrastModes{cameraIndex}.Value;
            app.Logger.log('INFO', 'USER_CONTRAST_MODE_CHANGED', ...
                'Camera=%d | Mode=%s', cameraIndex, mode);
            isManual = strcmp(mode, 'Manual');
            app.ContrastLowFields{cameraIndex}.Enable = app.onOff(isManual);
            app.ContrastHighFields{cameraIndex}.Enable = app.onOff(isManual);
            if isManual
                limits = app.sanitizeLimits(app.CameraAxes{cameraIndex}.CLim);
                app.ContrastLowFields{cameraIndex}.Value = limits(1);
                app.ContrastHighFields{cameraIndex}.Value = limits(2);
                app.setCameraStatus(cameraIndex, 'Manual contrast selected; set bounds and Apply.', 'working');
            elseif ~isempty(app.LatestFrames{cameraIndex})
                app.applyAutoContrast(cameraIndex, app.LatestFrames{cameraIndex}, true);
                app.setCameraStatus(cameraIndex, 'Auto contrast enabled.', 'success');
            end
            app.persistUserSettings(sprintf('camera%d_contrast_mode', cameraIndex));
        end

        function contrastBoundEdited(app, cameraIndex, boundName, previousValue, newValue)
            app.Logger.log('INFO', 'USER_CONTRAST_BOUND_EDITED', ...
                'Camera=%d | Bound=%s | Previous=%g | New=%g | Applied=0', ...
                cameraIndex, boundName, previousValue, newValue);
            app.setCameraStatus(cameraIndex, sprintf( ...
                'Contrast %s=%g edited; click contrast Apply.', boundName, newValue), ...
                'working');
            app.persistUserSettings(sprintf('camera%d_contrast_%s', ...
                cameraIndex, boundName));
        end

        function applyContrast(app, cameraIndex)
            app.beginAction(sprintf('CAMERA_%d_APPLY_CONTRAST', cameraIndex), ...
                sprintf('Applying Camera %d contrast...', cameraIndex), ...
                app.CameraStatusLabels{cameraIndex});
            low = app.ContrastLowFields{cameraIndex}.Value;
            high = app.ContrastHighFields{cameraIndex}.Value;
            if low >= high
                app.Logger.log('WARNING', 'CONTRAST_REJECTED', ...
                    'Camera=%d | Low=%g | High=%g | Required Low < High', ...
                    cameraIndex, low, high);
                app.finishAction(sprintf('CAMERA_%d_APPLY_CONTRAST', cameraIndex), false, ...
                    'Rejected: Low must be less than High.', app.CameraStatusLabels{cameraIndex});
                uialert(app.UIFigure, '对比度必须满足 Low < High。', 'Invalid Contrast');
                return;
            end
            app.ContrastModes{cameraIndex}.Value = 'Manual';
            app.ContrastLowFields{cameraIndex}.Enable = 'on';
            app.ContrastHighFields{cameraIndex}.Enable = 'on';
            app.CameraAxes{cameraIndex}.CLim = [low high];
            app.Logger.log('SUCCESS', 'MANUAL_CONTRAST_APPLIED', ...
                'Camera=%d | CLim=%s | RawDataUnchanged=1', ...
                cameraIndex, mat2str([low high]));
            app.finishAction(sprintf('CAMERA_%d_APPLY_CONTRAST', cameraIndex), true, ...
                sprintf('Contrast [%g %g] applied; raw unchanged.', low, high), ...
                app.CameraStatusLabels{cameraIndex});
            app.persistUserSettings(sprintf('camera%d_contrast_applied', cameraIndex));
        end

        function applyAutoContrast(app, cameraIndex, frame, writeLog)
            limits = [double(min(frame, [], 'all')), double(max(frame, [], 'all'))];
            sampleStride = max(1, ceil(max(size(frame, 1), size(frame, 2)) / ...
                app.AutoContrastSampleMaxPixels));
            sampledFrame = frame(1:sampleStride:end, 1:sampleStride:end);
            try
                normalized = stretchlim(sampledFrame, [0.01 0.995]);
                limits = double(normalized(:).') * 65535;
            catch
            end
            limits = app.sanitizeLimits(limits);
            app.CameraAxes{cameraIndex}.CLim = limits;
            app.ContrastLowFields{cameraIndex}.Value = round(limits(1));
            app.ContrastHighFields{cameraIndex}.Value = round(limits(2));
            if writeLog
                app.Logger.log('SUCCESS', 'AUTO_CONTRAST_APPLIED', ...
                    ['Camera=%d | Percentiles=[1 99.5] | CLim=%s | ', ...
                     'RefreshLimitFPS=%g | RenderLimitFPS=%g | SampleStride=%d | ', ...
                     'RawDataUnchanged=1'], cameraIndex, mat2str(limits), ...
                    app.AutoContrastLimitFPS, app.PreviewRenderLimitFPS, ...
                    sampleStride);
            end
        end

        function limits = sanitizeLimits(~, limits)
            limits = double(limits(:).');
            if numel(limits) ~= 2 || any(~isfinite(limits))
                limits = [0 65535];
            end
            limits = min(max(limits, 0), 65535);
            if limits(1) >= limits(2)
                limits = [0 65535];
            end
        end

        function transposeChanged(app, cameraIndex, value)
            oldValue = app.TransposeDisplay(cameraIndex);
            app.TransposeDisplay(cameraIndex) = logical(value);
            if ~isempty(app.LatestFrames{cameraIndex})
                if app.TransposeDisplay(cameraIndex)
                    app.ImageHandles{cameraIndex}.CData = app.LatestFrames{cameraIndex}.';
                else
                    app.ImageHandles{cameraIndex}.CData = app.LatestFrames{cameraIndex};
                end
            else
                app.ImageHandles{cameraIndex}.CData = app.ImageHandles{cameraIndex}.CData.';
            end
            app.updateCameraTitle(cameraIndex);
            app.Logger.log('SUCCESS', 'DISPLAY_TRANSPOSE_CHANGED', ...
                'Camera=%d | Previous=%d | Transpose=%d | RawDataUnchanged=1', ...
                cameraIndex, oldValue, app.TransposeDisplay(cameraIndex));
            app.setCameraStatus(cameraIndex, sprintf( ...
                'Display transpose %s; raw uint16 unchanged.', ...
                upper(app.onOff(app.TransposeDisplay(cameraIndex)))), 'success');
            app.persistUserSettings(sprintf('camera%d_transpose_changed', cameraIndex));
        end

        function updateCameraTitle(app, cameraIndex)
            if app.TransposeDisplay(cameraIndex)
                orientation = 'TRANSPOSED display';
            else
                orientation = 'NORMAL display';
            end
            app.CameraTitleLabels{cameraIndex}.Text = sprintf('%s | S/N %s | %s', ...
                app.Cameras.LogicalNames(cameraIndex), app.Cameras.Serials(cameraIndex), orientation);
        end

        function updateCameraModeLabel(app, cameraIndex, requestedState)
            if nargin < 3
                requestedState = 'requested';
            end
            connected = app.Cameras.Connected(cameraIndex);
            if connected && strcmpi(requestedState, 'actual')
                settings = app.Cameras.getActualSettings(cameraIndex);
                prefix = 'Actual';
                binFactor = settings.Bin;
                roi = settings.ROI;
                format = string(settings.VideoFormat);
            else
                prefix = 'Requested';
                if strcmpi(requestedState, 'pending')
                    prefix = 'Pending';
                end
                binFactor = app.BinDropDowns{cameraIndex}.Value;
                try
                    roi = zoulab.UserSettings.parseROI(app.ROIFields{cameraIndex}.Value);
                catch
                    roi = [NaN NaN NaN NaN];
                end
                format = "MONO16_" + round(2304 / binFactor) + "x" + ...
                    round(2304 / binFactor) + "_Fast";
            end
            resolutionTokens = regexp(char(format), '(\d+)x(\d+)', 'tokens');
            if isempty(resolutionTokens)
                formatResolution = sprintf('%dx%d', round(2304 / binFactor), ...
                    round(2304 / binFactor));
            else
                formatResolution = sprintf('%sx%s', resolutionTokens{end}{1}, ...
                    resolutionTokens{end}{2});
            end
            bitToken = regexp(char(format), 'MONO(\d+)', 'tokens', 'once');
            if isempty(bitToken)
                bitText = '16-bit';
            else
                bitText = sprintf('%s-bit', bitToken{1});
            end
            if contains(format, 'Fast', 'IgnoreCase', true)
                speedText = 'Fast';
            else
                speedText = char(format);
            end
            if all(isfinite(roi))
                roiText = sprintf('%dx%d', roi(3), roi(4));
            else
                roiText = 'invalid';
            end
            textValue = sprintf('%s: %s | %s | Bin%d | %s | ROI %s', ...
                prefix, formatResolution, bitText, binFactor, speedText, roiText);
            app.CameraModeLabels{cameraIndex}.Text = textValue;
            app.Logger.log('INFO', 'CAMERA_MODE_DISPLAY_UPDATED', ...
                ['Camera=%d | State=%s | Format=%s | Bin=%d | ROI=%s | ', ...
                 'DisplayText=%s'], cameraIndex, prefix, format, binFactor, ...
                mat2str(roi), textValue);
        end

        function chooseRoot(app)
            app.beginAction('BROWSE_SAVE_ROOT', 'Opening save-root chooser...', []);
            selected = uigetdir(app.RootPathField.Value, 'Choose experiment save root');
            if isequal(selected, 0)
                app.Logger.log('INFO', 'ROOT_SELECTION_CANCELLED', 'User cancelled folder selection.');
                app.finishAction('BROWSE_SAVE_ROOT', false, 'Save-root selection cancelled.', []);
                return;
            end
            previous = app.RootPathField.Value;
            app.RootPathField.Value = selected;
            app.Logger.log('SUCCESS', 'ROOT_SELECTED', ...
                'Previous=%s | Root=%s', previous, selected);
            app.finishAction('BROWSE_SAVE_ROOT', true, "Save root: " + string(selected), []);
            app.updateAcquisitionStorageEstimate('save_root_browsed', true);
            app.persistUserSettings('save_root_browsed');
        end

        function connectLightSources(app)
            app.beginAction('CONNECT_LIGHT_SOURCES', ...
                'Connecting Spectra X and Coherent OBIS sources...', ...
                app.LightStatusLabel);
            try
                app.requireIdentity('connect light sources');
                successes = strings(1, 0);
                failures = strings(1, 0);
                if ~app.SimulationMode
                    try
                        app.SpectraController.connectConfiguredPort(app.Logger);
                        app.refreshLightTableFromController();
                        app.LightLamp.Color = [0.10 0.75 0.20];
                        app.SpectraStateLabel.Text = 'Spectra READY';
                        successes(end + 1) = "Spectra X"; %#ok<AGROW>
                    catch ME
                        app.LightLamp.Color = [0.85 0.15 0.12];
                        app.SpectraStateLabel.Text = 'Spectra ERROR';
                        app.Logger.logException('SPECTRAX_CONNECT_PARTIAL_FAILED', ME);
                        failures(end + 1) = "Spectra X: " + string(ME.message); %#ok<AGROW>
                    end
                else
                    app.LightLamp.Color = [0.55 0.55 0.55];
                    app.SpectraStateLabel.Text = 'Spectra SIM';
                end
                displayWavelengths = [405 445];
                for laserIndex = 1:2
                    try
                        info = app.CoherentControllers{laserIndex}.connect(app.Logger);
                        app.updateObisRow(laserIndex, info);
                        app.ObisLamps{laserIndex}.Color = [0.10 0.75 0.20];
                        app.ObisStatusLabels{laserIndex}.Text = sprintf( ...
                            '%d READY', displayWavelengths(laserIndex));
                        successes(end + 1) = "OBIS " + ...
                            string(displayWavelengths(laserIndex)); %#ok<AGROW>
                    catch ME
                        app.ObisLamps{laserIndex}.Color = [0.85 0.15 0.12];
                        app.ObisStatusLabels{laserIndex}.Text = sprintf( ...
                            '%d ERROR', displayWavelengths(laserIndex));
                        app.Logger.logException('COHERENT_CONNECT_PARTIAL_FAILED', ME);
                        failures(end + 1) = "OBIS " + ...
                            string(displayWavelengths(laserIndex)) + ...
                            ": " + string(ME.message); %#ok<AGROW>
                    end
                end
                if isempty(successes)
                    error('ZouLab:NoLightSourceConnected', ...
                        'No light source connected. %s', strjoin(failures, ' | '));
                end
                app.finishAction('CONNECT_LIGHT_SOURCES', true, ...
                    sprintf('Connected: %s | Failed: %s', ...
                    strjoin(successes, ', '), strjoin(failures, ' | ')), ...
                    app.LightStatusLabel);
            catch ME
                if strcmp(ME.identifier, 'ZouLab:OperatorRequired')
                    app.identityBlocked(app.LightStatusLabel);
                else
                    app.handleError('CONNECT_LIGHT_SOURCES_FAILED', ME, ...
                        app.LightStatusLabel);
                end
            end
        end

        function refreshLightSources(app)
            app.beginAction('REFRESH_LIGHT_SOURCES', ...
                'Reading connected light-source state...', app.LightStatusLabel);
            try
                app.requireIdentity('refresh light sources');
                if app.SpectraController.Connected
                    app.SpectraController.refresh(app.Logger, true);
                    app.refreshLightTableFromController();
                end
                for laserIndex = 1:2
                    controller = app.CoherentControllers{laserIndex};
                    if controller.Connected
                        app.updateObisRow(laserIndex, controller.status());
                    end
                end
                app.finishAction('REFRESH_LIGHT_SOURCES', true, ...
                    'Connected light-source status refreshed.', app.LightStatusLabel);
            catch ME
                app.handleError('REFRESH_LIGHT_SOURCES_FAILED', ME, ...
                    app.LightStatusLabel);
            end
        end

        function updateObisRow(app, laserIndex, info)
            data = app.LightTable.Data;
            data{laserIndex,8} = app.lightStateText(info.emission_enabled);
            app.LightTable.Data = data;
            app.Logger.log('INFO', 'COHERENT_OBIS_UI_STATUS_REFRESHED', ...
                ['LaserIndex=%d | WavelengthNm=%.6g | SerialPowerMilliwatts=%.6g | ', ...
                 'HomeLevelSemantics=AO_percent | HomeLevelPercent=%.6g | ', ...
                 'Emission=%d'], laserIndex, info.wavelength_nm, info.power_mw, ...
                double(data{laserIndex,7}), info.emission_enabled);
            app.syncSelectedLightControls();
        end

        function connectSpectraX(app)
            app.beginAction('CONNECT_SPECTRAX_USB', ...
                'Scanning serial ports for Spectra X...', app.LightStatusLabel);
            app.LightLamp.Color = [0.95 0.65 0.10];
            try
                app.requireIdentity('connect Spectra X');
                if app.SimulationMode
                    error('ZouLab:SpectraXSimulationUnavailable', ...
                        'Physical Spectra X USB control is disabled in simulation mode.');
                end
                app.SpectraController.connectConfiguredPort(app.Logger);
                app.refreshLightTableFromController();
                app.LightLamp.Color = [0.10 0.75 0.20];
                app.SpectraStateLabel.Text = 'Spectra READY';
                app.finishAction('CONNECT_SPECTRAX_USB', true, ...
                    sprintf('%s on %s', app.SpectraController.Model, app.SpectraController.Port), ...
                    app.LightStatusLabel);
            catch ME
                app.LightLamp.Color = [0.85 0.15 0.12];
                if strcmp(ME.identifier, 'ZouLab:OperatorRequired')
                    app.identityBlocked(app.LightStatusLabel);
                else
                    app.handleError('SPECTRAX_CONNECT_UI_FAILED', ME, app.LightStatusLabel);
                end
            end
        end

        function refreshSpectraX(app)
            app.beginAction('REFRESH_SPECTRAX', 'Reading Spectra X status...', app.LightStatusLabel);
            try
                app.requireIdentity('refresh Spectra X');
                app.SpectraController.refresh(app.Logger, true);
                app.refreshLightTableFromController();
                app.LightLamp.Color = [0.10 0.75 0.20];
                app.finishAction('REFRESH_SPECTRAX', true, ...
                    sprintf('Status refreshed on %s', app.SpectraController.Port), ...
                    app.LightStatusLabel);
            catch ME
                if strcmp(ME.identifier, 'ZouLab:OperatorRequired')
                    app.identityBlocked(app.LightStatusLabel);
                else
                    app.handleError('SPECTRAX_REFRESH_FAILED', ME, app.LightStatusLabel);
                end
            end
        end

        function refreshLightTableFromController(app)
            data = app.LightTable.Data;
            for row = 3:size(data, 1)
                channel = app.spectraChannelForRow(row);
                data{row,7} = app.SpectraController.Intensities(channel) * 100 / ...
                    app.SpectraController.MaxIntensity;
                [ttlState, ttlStateKnown] = ...
                    app.DaqController.commandedLightState(string(data{row,4}));
                if ttlStateKnown
                    data{row,8} = app.lightStateText(ttlState);
                else
                    data{row,8} = 'OFF';
                end
            end
            app.LightTable.Data = data;
            app.syncSelectedLightControls();
            app.SpectraStateLabel.Text = sprintf('Spectra %s', app.SpectraController.Port);
            app.LightStatusLabel.Text = sprintf('%s | %s | FW %s', ...
                app.SpectraController.Port, app.SpectraController.Model, ...
                app.SpectraController.FirmwareVersion);
        end

        function lightSelectionChanged(app, event)
            if isempty(event.Indices)
                return;
            end
            app.SelectedLightRow = event.Indices(1);
            app.syncSelectedLightControls();
            data = app.LightTable.Data;
            app.Logger.log('INFO', 'USER_LIGHT_ROW_SELECTED', ...
                'Row=%d | ChannelID=%d | Channel=%s | Alias=%s', ...
                app.SelectedLightRow, data{app.SelectedLightRow,2}, ...
                data{app.SelectedLightRow,3}, data{app.SelectedLightRow,4});
            app.LightStatusLabel.Text = sprintf('Selected: %s (%s)', ...
                data{app.SelectedLightRow,4}, data{app.SelectedLightRow,3});
            app.persistUserSettings('light_row_selected');
        end

        function syncSelectedLightControls(app)
            row = min(max(1, app.SelectedLightRow), size(app.LightTable.Data, 1));
            value = double(app.LightTable.Data{row,7});
            limits = [0 100];
            if row <= 2
                app.LightIntensityUnitLabel.Text = 'AO %';
            else
                app.LightIntensityUnitLabel.Text = '%';
            end
            app.LightIntensitySlider.Limits = limits;
            app.LightIntensityField.Limits = limits;
            app.LightIntensitySlider.MajorTicks = linspace(limits(1), limits(2), 6);
            value = min(max(value, limits(1)), limits(2));
            app.LightIntensitySlider.Value = value;
            app.LightIntensityField.Value = value;
        end

        function lightSliderChanging(app, ~, event)
            app.LightIntensityField.Value = event.Value;
            data = app.LightTable.Data;
            app.LightStatusLabel.Text = sprintf('Editing %s: %.3g %s (release to update)', ...
                data{app.SelectedLightRow,4}, event.Value, app.lightLevelUnit(app.SelectedLightRow));
        end

        function lightSliderChanged(app, value)
            row = app.SelectedLightRow;
            previous = double(app.LightTable.Data{row,7});
            app.LightIntensityField.Value = value;
            app.Logger.log('INFO', 'USER_LIGHT_INTENSITY_SLIDER_CHANGED', ...
                'Row=%d | PreviousConfirmed=%.3f | Requested=%.3f | CommitOnRelease=1', ...
                row, previous, value);
            app.commitLightIntensity(row, value, previous, 'slider_release');
        end

        function lightNumericChanged(app, previousValue, newValue)
            row = app.SelectedLightRow;
            previousConfirmed = double(app.LightTable.Data{row,7});
            app.LightIntensitySlider.Value = newValue;
            app.Logger.log('INFO', 'USER_LIGHT_INTENSITY_NUMBER_CHANGED', ...
                ['Row=%d | PreviousField=%.3f | PreviousConfirmed=%.3f | ', ...
                 'Requested=%.3f | CommitOnEnter=1'], ...
                row, previousValue, previousConfirmed, newValue);
            app.commitLightIntensity(row, newValue, previousConfirmed, 'numeric_commit');
        end

        function commitLightIntensity(app, row, requested, previousConfirmed, source)
            data = app.LightTable.Data;
            alias = string(data{row,4});
            app.beginAction('SET_LIGHT_INTENSITY', ...
                sprintf('Updating %s intensity to %.4g %s...', alias, requested, ...
                app.lightLevelUnit(row)), ...
                app.LightStatusLabel);
            try
                app.requireIdentity('set light intensity');
                app.assertLightControlEditable();
                if row <= 2
                    actual = requested;
                    volts = app.lightLevelPercentToVolts(row, requested);
                    stateOn = string(data{row,8}) == "ON";
                    if app.SimulationMode
                        app.Logger.log('SUCCESS', ...
                            'SIMULATION_COHERENT_AO_LEVEL_CONFIGURED', ...
                            ['Row=%d | Alias=%s | Percent=%.6g | Volts=%.6g | ', ...
                             'ManualStateOn=%d | HardwareCommandIssued=0'], ...
                            row, alias, actual, volts, stateOn);
                    elseif stateOn
                        app.DaqController.setLaserAnalogVoltage( ...
                            alias, volts, app.Logger);
                    else
                        app.Logger.log('SUCCESS', ...
                            'COHERENT_AO_SETPOINT_CONFIGURED_WHILE_OFF', ...
                            ['Row=%d | Alias=%s | Percent=%.6g | Volts=%.6g | ', ...
                             'HardwareCommandIssued=0 | Reason=manual_state_off'], ...
                            row, alias, actual, volts);
                    end
                else
                    actual = app.SpectraController.setIntensityPercent( ...
                        app.spectraChannelForRow(row), requested, app.Logger);
                end
                data = app.LightTable.Data;
                data{row,7} = actual;
                app.LightTable.Data = data;
                app.LightIntensitySlider.Value = actual;
                app.LightIntensityField.Value = actual;
                if row <= 2
                    confirmation = sprintf( ...
                        '%s intensity configured: %.4g AO %% = %.4g V', ...
                        data{row,4}, actual, ...
                        app.lightLevelPercentToVolts(row, actual));
                else
                    confirmation = sprintf('%s intensity confirmed: %.4g %%', ...
                        data{row,4}, actual);
                end
                app.finishAction('SET_LIGHT_INTENSITY', true, ...
                    confirmation, ...
                    app.LightStatusLabel);
                app.persistUserSettings(sprintf('light%d_intensity_confirmed', row));
            catch ME
                data = app.LightTable.Data;
                data{row,7} = previousConfirmed;
                app.LightTable.Data = data;
                app.LightIntensitySlider.Value = previousConfirmed;
                app.LightIntensityField.Value = previousConfirmed;
                app.Logger.log('WARNING', 'LIGHT_INTENSITY_UI_REVERTED', ...
                    ['Row=%d | Alias=%s | Source=%s | Requested=%.3f | ', ...
                     'RevertedTo=%.3f | ErrorID=%s'], ...
                    row, alias, source, requested, previousConfirmed, ME.identifier);
                if strcmp(ME.identifier, 'ZouLab:OperatorRequired')
                    app.identityBlocked(app.LightStatusLabel);
                else
                    app.handleError('LIGHT_INTENSITY_SET_FAILED', ME, app.LightStatusLabel);
                end
            end
        end

        function setLightRowState(app, row, turnOn, previousState, source)
            data = app.LightTable.Data;
            previewStateBefore = app.PreviewActive;
            previewIsolation = onCleanup(@() app.verifyLightPreviewIsolation( ...
                previewStateBefore, row, turnOn, source)); %#ok<NASGU>
            action = "OFF";
            if turnOn
                action = "ON";
            end
            app.beginAction('SET_LIGHT_STATE', ...
                sprintf('Setting %s %s...', data{row,4}, action), app.LightStatusLabel);
            app.Logger.log('INFO', 'USER_LIGHT_STATE_EDITED', ...
                ['Row=%d | Alias=%s | Source=%s | Previous=%s | ', ...
                 'Requested=%s'], row, data{row,4}, source, previousState, action);
            try
                app.requireIdentity("turn light " + action);
                if turnOn && ~app.LightSafetyConfirmed
                    choice = uiconfirm(app.UIFigure, ...
                        ['The selected light will emit. Confirm the optical path, ', ...
                         'sample, and personnel are safe.'], ...
                        'Confirm Light ON', 'Options', {'Confirm ON','Cancel'}, ...
                        'DefaultOption', 2, 'CancelOption', 2);
                    if strcmp(choice, 'Cancel')
                        app.Logger.log('WARNING', 'LIGHT_ON_SAFETY_CONFIRMATION_CANCELLED', ...
                            'Row=%d | Alias=%s', row, data{row,4});
                        data{row,8} = char(previousState);
                        app.LightTable.Data = data;
                        app.finishAction('SET_LIGHT_STATE', false, ...
                            'Light ON cancelled; State reverted.', app.LightStatusLabel);
                        return;
                    end
                    app.LightSafetyConfirmed = true;
                    app.Logger.log('INFO', 'LIGHT_ON_SAFETY_CONFIRMED', ...
                        'Operator=%s | OneTimePerAppSession=1', app.Logger.OperatorName);
                end
                app.assertLightControlEditable();
                if row <= 2
                    if app.SimulationMode
                        actualOn = turnOn;
                        app.Logger.log('SUCCESS', ...
                            'SIMULATION_COHERENT_MIXED_STATE_CONFIRMED', ...
                            ['Row=%d | Alias=%s | RequestedOn=%d | ', ...
                             'AOSetpointVolts=%.6g | HardwareCommandIssued=0'], ...
                            row, data{row,4}, turnOn, ...
                            app.lightLevelPercentToVolts(row, data{row,7}));
                    else
                        [actualOn, ~] = app.commandCoherentManualState( ...
                            row, turnOn);
                    end
                else
                    if app.SimulationMode
                        actualOn = turnOn;
                        app.Logger.log('SUCCESS', ...
                            'SIMULATION_SPECTRAX_TTL_STATE_CONFIRMED', ...
                            ['Row=%d | Alias=%s | RequestedOn=%d | ', ...
                             'USBRole=intensity_only | HardwareCommandIssued=0'], ...
                            row, data{row,4}, turnOn);
                    else
                        app.DaqController.assertReady();
                        if app.SpectraController.Connected
                            app.SpectraController.armTTLChannels( ...
                                app.spectraChannelForRow(row), app.Logger);
                        else
                            app.Logger.log('WARNING', ...
                                'SPECTRAX_TTL_MODE_UNVERIFIED_MANUAL', ...
                                ['Row=%d | Alias=%s | SpectraConnected=0 | ', ...
                                 'DAQCommandAllowed=1'], row, data{row,4});
                        end
                        app.DaqController.setLights(string(data{row,4}), ...
                            turnOn, app.Logger);
                        actualOn = turnOn;
                    end
                end
                data{row,8} = app.lightStateText(actualOn);
                app.LightTable.Data = data;
                app.finishAction('SET_LIGHT_STATE', actualOn == turnOn, ...
                    sprintf('%s TTL command: %s | USB controls intensity only', ...
                    data{row,4}, data{row,8}), ...
                    app.LightStatusLabel);
                app.persistUserSettings(sprintf('light%d_state_confirmed', row));
            catch ME
                data = app.LightTable.Data;
                revertedState = string(previousState);
                data{row,8} = char(revertedState);
                app.LightTable.Data = data;
                app.Logger.log('WARNING', 'LIGHT_STATE_UI_REVERTED', ...
                    ['Row=%d | Alias=%s | Source=%s | Requested=%s | ', ...
                     'RevertedTo=%s | ErrorID=%s'], ...
                    row, data{row,4}, source, action, revertedState, ME.identifier);
                if strcmp(ME.identifier, 'ZouLab:OperatorRequired')
                    app.identityBlocked(app.LightStatusLabel);
                else
                    app.handleError('SPECTRAX_LIGHT_STATE_FAILED', ME, app.LightStatusLabel);
                end
            end
        end

        function allLightsOff(app)
            app.beginAction('ALL_LIGHTS_OFF', 'Sending All OFF...', app.LightStatusLabel);
            try
                app.requireIdentity('turn all lights off');
                if app.DaqController.Connected
                    safeOffConfirmed = app.DaqController.safeOff();
                    if ~safeOffConfirmed
                        error('ZouLab:DaqSafeOffFailed', ...
                            'DAQ did not confirm that all owned outputs returned safe.');
                    end
                    app.Logger.log('SUCCESS', 'ALL_DAQ_LIGHT_OUTPUTS_FORCED_SAFE', ...
                        ['LaserDO=OFF | LaserAO=0V | SpectraDO=OFF | ', ...
                         'FinitePlanStoppedIfRunning=1']);
                end
                if app.SpectraController.Connected
                    app.SpectraController.allOff(app.Logger, 'user_button');
                    app.refreshLightTableFromController();
                end
                data = app.LightTable.Data;
                displayWavelengths = [405 445];
                for laserIndex = 1:2
                    controller = app.CoherentControllers{laserIndex};
                    if controller.Connected
                        controller.setManualState(false, app.Logger);
                        data{laserIndex,8} = 'OFF';
                        app.ObisStatusLabels{laserIndex}.Text = sprintf('%d READY', ...
                            displayWavelengths(laserIndex));
                    end
                end
                app.LightTable.Data = data;
                app.finishAction('ALL_LIGHTS_OFF', true, ...
                    'All connected Spectra X and Coherent sources are OFF.', ...
                    app.LightStatusLabel);
                app.persistUserSettings('all_lights_off');
            catch ME
                if strcmp(ME.identifier, 'ZouLab:OperatorRequired')
                    app.identityBlocked(app.LightStatusLabel);
                else
                    app.handleError('SPECTRAX_ALL_OFF_FAILED', ME, app.LightStatusLabel);
                end
            end
        end

        function lightTableEdited(app, event)
            row = event.Indices(1);
            column = event.Indices(2);
            lightName = string(app.LightTable.Data{row,4});
            if column == 8
                requestedState = upper(strtrim(string(event.NewData)));
                previousState = upper(strtrim(string(event.PreviousData)));
                app.setLightRowState(row, requestedState == "ON", ...
                    previousState, 'state_table');
                return;
            end
            app.Logger.log('SUCCESS', 'USER_LIGHT_MAPPING_EDITED', ...
                'Row=%d | Column=%d | Alias=%s | Previous=%s | New=%s', ...
                row, column, lightName, string(event.PreviousData), string(event.NewData));
            app.LightStatusLabel.Text = sprintf('Mapping edited: %s (saved in record manifest)', lightName);
            app.persistUserSettings(sprintf('light%d_mapping_edited', row));
        end

        function validateLightMapping(app, cameraIndices)
            data = app.LightTable.Data;
            ignoredRows = zeros(1, 0);
            zeroLevelRows = zeros(1, 0);
            unmappedStimulusRows = zeros(1, 0);
            for row = 1:size(data, 1)
                enabled = logical(data{row,1});
                role = string(data{row,5});
                camera = string(data{row,6});
                if ~enabled
                    ignoredRows(end + 1) = row; %#ok<AGROW>
                    continue;
                end
                if role == "Stimulus" && camera == "None"
                    unmappedStimulusRows(end + 1) = row; %#ok<AGROW>
                end
                if role == "Imaging" && double(data{row,7}) <= 0
                    zeroLevelRows(end + 1) = row; %#ok<AGROW>
                end
            end
            activeImagingRows = app.imagingLightRowsFor(cameraIndices);
            app.Logger.log('SUCCESS', 'LIGHT_MAPPING_VALIDATED', ...
                ['Cameras=%s | ActiveImagingRows=%s | NoImagingLightAllowed=%d | ', ...
                 'ZeroImagingLevelRows=%s | ZeroLevelAllowed=%d | ', ...
                 'UseFalseRowsIgnored=%s | StimulusRowsWithoutCamera=%s | ', ...
                 'StimulusCameraMappingRequired=0 | Mapping=%s'], ...
                mat2str(cameraIndices), mat2str(activeImagingRows), ...
                isempty(activeImagingRows), mat2str(zeroLevelRows), true, ...
                mat2str(ignoredRows), mat2str(unmappedStimulusRows), ...
                jsonencode(app.lightMappingStruct()));
            if isempty(activeImagingRows) || ~isempty(zeroLevelRows)
                app.Logger.log('WARNING', 'IMAGING_LIGHT_CONFIGURATION_NONBLOCKING', ...
                    ['Cameras=%s | ActiveImagingRows=%s | ZeroLevelRows=%s | ', ...
                     'AcquisitionAllowed=1 | OpticalIlluminationNotGuaranteed=1'], ...
                    mat2str(cameraIndices), mat2str(activeImagingRows), ...
                    mat2str(zeroLevelRows));
            end
        end

        function mapping = lightMappingStruct(app)
            data = app.LightTable.Data;
            mapping = repmat(struct('use', false, 'channel_id', 0, ...
                'device', '', 'channel', '', 'alias', '', 'role', '', ...
                'camera', '', 'level', 0, 'unit', '', ...
                'intensity_percent', NaN, 'state', ''), size(data,1), 1);
            for row = 1:size(data,1)
                mapping(row).use = logical(data{row,1});
                mapping(row).channel_id = double(data{row,2});
                if row <= 2
                    mapping(row).device = 'Coherent OBIS';
                else
                    mapping(row).device = 'Spectra X';
                end
                mapping(row).channel = char(string(data{row,3}));
                mapping(row).alias = char(string(data{row,4}));
                mapping(row).role = char(string(data{row,5}));
                mapping(row).camera = char(string(data{row,6}));
                mapping(row).level = double(data{row,7});
                mapping(row).unit = app.lightLevelUnit(row);
                mapping(row).intensity_percent = double(data{row,7});
                mapping(row).state = char(string(data{row,8}));
            end
        end

        function rows = imagingLightRowsFor(app, cameraIndices)
            cameraIndices = double(cameraIndices(:).');
            data = app.LightTable.Data;
            rows = zeros(1, 0);
            for row = 1:size(data,1)
                if ~logical(data{row,1}) || string(data{row,5}) ~= "Imaging"
                    continue;
                end
                cameraMap = string(data{row,6});
                mapped = cameraMap == "Both" || ...
                    (cameraMap == "Camera 1" && any(cameraIndices == 1)) || ...
                    (cameraMap == "Camera 2" && any(cameraIndices == 2));
                if mapped
                    rows(end+1) = row; %#ok<AGROW>
                end
            end
            rows = unique(rows, 'stable');
        end

        function aliases = lightAliases(app, rows)
            aliases = strings(1, numel(rows));
            for k = 1:numel(rows)
                aliases(k) = string(app.LightTable.Data{rows(k),4});
            end
        end

        function values = imagingLightAnalogVolts(app, rows)
            values = struct('Laser405', 0, 'Laser445', 0);
            for row = double(rows(:).')
                alias = string(app.LightTable.Data{row,4});
                analogIndex = find(app.DaqController.AnalogLightNames == alias, 1);
                if isempty(analogIndex)
                    continue;
                end
                percent = double(app.LightTable.Data{row,7});
                minimum = app.DaqController.AnalogMinimumVolts(analogIndex);
                maximum = app.DaqController.AnalogMaximumVolts(analogIndex);
                values.(char(alias)) = minimum + ...
                    (maximum - minimum) * percent / 100;
            end
        end

        function checkSpectraAddress(app)
            address = app.DaqController.SpectraAddress;
            app.beginAction('CHECK_SPECTRAX_ADDRESS', ...
                "Checking " + address + "...", app.LightStatusLabel);
            command = sprintf('ping -n 1 -w 700 %s', address);
            [status, output] = system(command);
            reachable = status == 0;
            if reachable
                message = "Address reachable; USB serial remains the control interface.";
                app.LightLamp.Color = [0.10 0.75 0.20];
            else
                message = "Address unreachable; USB serial control is independent.";
                if ~app.SpectraController.Connected
                    app.LightLamp.Color = [0.85 0.15 0.12];
                end
            end
            app.Logger.log('INFO', 'SPECTRA_ADDRESS_CHECK', ...
                'Address=%s | Reachable=%d | Output=%s', address, reachable, ...
                regexprep(output, '[\r\n]+', ' '));
            app.finishAction('CHECK_SPECTRAX_ADDRESS', reachable, message, app.LightStatusLabel);
        end

        function openSpectraGUI(app)
            address = app.DaqController.SpectraAddress;
            app.beginAction('OPEN_SPECTRAX_GUI', ...
                "Opening http://" + address + "...", app.LightStatusLabel);
            try
                web("http://" + address, '-browser');
                app.finishAction('OPEN_SPECTRAX_GUI', true, ...
                    'Web GUI open request sent.', app.LightStatusLabel);
            catch ME
                app.handleError('SPECTRA_GUI_OPEN_FAILED', ME, app.LightStatusLabel);
            end
        end

        function lightStimulusSettingEdited(app, settingName, previousValue, newValue)
            if app.LightStimulusController.Armed
                app.disarmLightStimulus('configuration_changed');
            end
            app.Logger.log('INFO', 'USER_LIGHT_STIMULUS_SETTING_EDITED', ...
                'Setting=%s | Previous=%s | New=%s | LightStimulusDisarmed=1', ...
                settingName, string(previousValue), string(newValue));
            app.updateLightStimulusFieldAvailability();
            try
                app.LightStimulusController.configure( ...
                    app.currentLightStimulusSpec(), app.Logger);
                app.LightStimFrameworkStatusLabel.Text = ...
                    'Configuration valid; click Arm Light Stimulus when ready.';
                app.LightStimFrameworkStatusLabel.FontColor = [0.08 0.55 0.18];
                if app.LightStimTimelinePreview
                    app.scheduleExpensiveUiRefresh( ...
                        "light_stimulus_draft_" + string(settingName), ...
                        true, false, false);
                end
                app.persistUserSettings("light_stimulus_" + string(settingName));
            catch ME
                app.LightStimFrameworkStatusLabel.Text = "Invalid: " + string(ME.message);
                app.LightStimFrameworkStatusLabel.FontColor = [0.78 0.18 0.12];
                app.Logger.logException('LIGHT_STIMULUS_CONFIGURATION_INVALID', ME);
            end
        end

        function lightStimulusDigitalParameterEdited(app, settingName, ...
                previousValue, newValue)
            if app.LightStimulusController.Armed
                app.disarmLightStimulus('digital_configuration_changed');
            end
            app.updateDigitalCalculatedDuration();
            app.Logger.log('INFO', 'USER_LIGHT_STIMULUS_DO_PARAMETER_EDITED', ...
                ['Setting=%s | Previous=%s | New=%s | ', ...
                 'TableRegenerationScheduled=1 | DebounceSeconds=%.3g | ', ...
                 'HardwareCommandIssued=0'], ...
                settingName, string(previousValue), string(newValue), ...
                app.UiRefreshDebounceSeconds);
            app.LightStimFrameworkStatusLabel.Text = ...
                'DO timing changed — updating waveform and Timeline...';
            app.LightStimFrameworkStatusLabel.FontColor = [0.80 0.48 0.05];
            app.PendingDoWaveformRegeneration = true;
            app.scheduleExpensiveUiRefresh( ...
                "light_stimulus_DO_" + string(settingName), ...
                true, false, false);
            app.persistUserSettings("light_stimulus_DO_" + string(settingName));
        end

        function lightStimulusDigitalModeChanged(app, previousValue, newValue)
            if app.LightStimulusController.Armed
                app.disarmLightStimulus('digital_mode_changed');
            end
            app.updateDigitalCalculatedDuration();
            app.updateLightStimulusFieldAvailability();
            app.Logger.log('INFO', 'USER_LIGHT_STIMULUS_DO_MODE_CHANGED', ...
                ['Previous=%s | New=%s | TableRegenerationScheduled=%d | ', ...
                 'DebounceSeconds=%.3g | HardwareCommandIssued=0'], ...
                string(previousValue), string(newValue), ...
                string(newValue) ~= "Manual Points", ...
                app.UiRefreshDebounceSeconds);
            if string(newValue) ~= "Manual Points"
                app.PendingDoWaveformRegeneration = true;
            end
            app.scheduleExpensiveUiRefresh( ...
                "light_stimulus_DO_mode_" + string(newValue), ...
                true, false, false);
            app.LightStimFrameworkStatusLabel.Text = ...
                "DO mode: " + string(newValue) + ". Updating Timeline...";
            app.LightStimFrameworkStatusLabel.FontColor = [0.80 0.48 0.05];
            app.persistUserSettings('light_stimulus_DO_mode_changed');
        end

        function lightStimulusAnalogTargetChanged(app, previousValue, newValue)
            try
                app.storeLightStimulusAnalogControls(string(previousValue));
                app.loadLightStimulusAnalogControls(string(newValue));
                app.updateLightStimulusFieldAvailability();
                app.Logger.log('INFO', 'USER_LIGHT_STIMULUS_AO_TARGET_CHANGED', ...
                    'Previous=%s | New=%s | HardwareCommandIssued=0', ...
                    string(previousValue), string(newValue));
                app.LightStimFrameworkStatusLabel.Text = ...
                    "Editing independent AO waveform for " + string(newValue) + ".";
                if app.LightStimTimelinePreview
                    app.LightStimulusController.configure( ...
                        app.currentLightStimulusSpec(), app.Logger);
                    app.scheduleExpensiveUiRefresh( ...
                        "light_stimulus_AO_target_draft", true, false, false);
                end
                app.persistUserSettings('light_stimulus_AO_target_changed');
            catch ME
                app.LightStimAnalogTargetDropDown.Value = char(string(previousValue));
                app.Logger.logException('LIGHT_STIMULUS_AO_TARGET_CHANGE_FAILED', ME);
                app.LightStimFrameworkStatusLabel.Text = "Invalid AO values: " + ...
                    string(ME.message);
                app.LightStimFrameworkStatusLabel.FontColor = [0.78 0.18 0.12];
            end
        end

        function lightStimulusAnalogSettingEdited(app, settingName, previousValue, newValue)
            if app.LightStimulusController.Armed
                app.disarmLightStimulus('analog_configuration_changed');
            end
            target = string(app.LightStimAnalogTargetDropDown.Value);
            app.Logger.log('INFO', 'USER_LIGHT_STIMULUS_AO_SETTING_EDITED', ...
                ['Target=%s | Setting=%s | Previous=%s | New=%s | ', ...
                 'LightStimulusDisarmed=1 | HardwareCommandIssued=0'], ...
                target, settingName, string(previousValue), string(newValue));
            app.updateLightStimulusFieldAvailability();
            try
                app.storeLightStimulusAnalogControls(target);
                app.LightStimulusController.configure( ...
                    app.currentLightStimulusSpec(), app.Logger);
                app.LightStimFrameworkStatusLabel.Text = sprintf( ...
                    'AO %s configuration valid; click Arm when ready.', target);
                app.LightStimFrameworkStatusLabel.FontColor = [0.08 0.55 0.18];
                if app.LightStimTimelinePreview
                    app.scheduleExpensiveUiRefresh( ...
                        "light_stimulus_AO_draft_" + string(settingName), ...
                        true, false, false);
                end
                app.persistUserSettings("light_stimulus_AO_" + ...
                    string(settingName));
            catch ME
                app.LightStimFrameworkStatusLabel.Text = "Invalid AO waveform: " + ...
                    string(ME.message);
                app.LightStimFrameworkStatusLabel.FontColor = [0.78 0.18 0.12];
                app.Logger.logException('LIGHT_STIMULUS_AO_CONFIGURATION_INVALID', ME);
            end
        end

        function spec = currentLightStimulusSpec(app)
            app.storeLightStimulusAnalogControls( ...
                string(app.LightStimAnalogTargetDropDown.Value));
            app.normalizeFollowDoAnalogDrafts();
            switch string(app.LightStimSourceDropDown.Value)
                case "405"
                    names = {'Laser405'};
                case "445"
                    names = {'Laser445'};
                otherwise
                    names = {'Laser405','Laser445'};
            end
            dmdLogicalCount = 0;
            dmdPaddingCount = 0;
            dmdManifestHash = '';
            if ~isempty(fieldnames(app.DmdCompiledManifest)) && ...
                    isfield(app.DmdCompiledManifest, 'binary_frame_count')
                dmdLogicalCount = double( ...
                    app.DmdCompiledManifest.logical_mask_count);
                dmdPaddingCount = double( ...
                    app.DmdCompiledManifest.padding_binary_frame_count);
                if isfield(app.DmdCompiledManifest, 'content_sha256')
                    dmdManifestHash = char(string( ...
                        app.DmdCompiledManifest.content_sha256));
                end
            end
            dmdPoints = double(app.DmdTriggerTable.Data);
            risingRows = app.dmdTriggerRisingRows(dmdPoints);
            risingTimes = zeros(1, 0);
            risingFrames = zeros(1, 0);
            if ~isempty(risingRows)
                risingTimes = dmdPoints(risingRows, 1).';
                risingFrames = dmdPoints(risingRows, 3).';
            end
            spec = struct( ...
                'stimulus_light_names', {names}, ...
                'waveform_type', 'Points', ...
                'digital_table_helper', char(string( ...
                    app.LightStimWaveformDropDown.Value)), ...
                'stimulus_delay_seconds', app.LightStimDelayField.Value, ...
                'stimulus_duration_seconds', ...
                    double(app.LightStimDigitalPointTable.Data(end, 1)), ...
                'pulse_width_seconds', app.LightStimPulseWidthField.Value, ...
                'pulse_period_seconds', app.LightStimPulseWidthField.Value + ...
                    app.LightStimPulsePeriodField.Value, ...
                'digital_point_times_seconds', ...
                    double(app.LightStimDigitalPointTable.Data(:, 1)).', ...
                'digital_point_values', ...
                    double(app.LightStimDigitalPointTable.Data(:, 2)).', ...
                'digital_repeat_count', app.LightStimDigitalRepeatField.Value, ...
                'digital_points_are_expanded', true, ...
                'custom_onsets_seconds', zeros(1, 0), ...
                'custom_durations_seconds', zeros(1, 0), ...
                'analog_waveforms', app.LightStimAnalogDraft, ...
                'dmd_enabled', string(app.LightStimDmdSwitch.Value) == "ON", ...
                'dmd_trigger_mode', char(string( ...
                    app.DmdTriggerModeDropDown.Value)), ...
                'dmd_pattern', upper(strrep(char(string( ...
                    app.LightStimDmdPatternDropDown.Value)), ' ', '_')), ...
                'dmd_loop', string(app.LightStimDmdLoopSwitch.Value) == "Loop", ...
                'dmd_frame_rate_hz', app.LightStimDmdRateField.Value, ...
                'dmd_trigger_count', numel(risingRows), ...
                'dmd_trigger_times_seconds', risingTimes, ...
                'dmd_trigger_frame_indices', risingFrames, ...
                'dmd_trigger_point_times_seconds', dmdPoints(:, 1).', ...
                'dmd_trigger_point_values', dmdPoints(:, 2).', ...
                'dmd_trigger_points_are_expanded', true, ...
                'dmd_trigger_repeat_count', 1, ...
                'dmd_trigger_cycle_seconds', ...
                    app.dmdTriggerCycleSeconds(), ...
                'dmd_start_offset_seconds', ...
                    app.DmdTriggerDelayField.Value, ...
                'dmd_repeat_to_fill_timeline', ...
                    app.DmdRepeatToFillTimelineCheckBox.Value, ...
                'dmd_logical_mask_count', dmdLogicalCount, ...
                'dmd_padding_binary_frame_count', dmdPaddingCount, ...
                'dmd_manifest_sha256', dmdManifestHash, ...
                'dmd_trigger_width_seconds', ...
                    app.LightStimDmdPulseField.Value / 1000);
        end

        function spec = currentLaserMethodSpec(app)
            spec = app.currentLightStimulusSpec();
            names = string(fieldnames(spec));
            dmdNames = names(startsWith(names, "dmd_"));
            if ~isempty(dmdNames)
                spec = rmfield(spec, cellstr(dmdNames));
            end
            spec.schema_version = '1.0.0';
            spec.module = 'light_stim_laser';
        end

        function applyLaserMethodSpec(app, laserSpec)
            combined = app.currentLightStimulusSpec();
            names = string(fieldnames(laserSpec));
            for index = 1:numel(names)
                name = names(index);
                if startsWith(name, "dmd_") || ...
                        any(name == ["schema_version","module"])
                    continue;
                end
                combined.(char(name)) = laserSpec.(char(name));
            end
            app.applyLightStimulusSpec(combined);
            app.LightStimulusController.configure( ...
                app.currentLightStimulusSpec(), app.Logger);
            app.updateLightStimulusFieldAvailability();
        end

        function spec = currentDmdMethodSpec(app)
            combined = app.currentLightStimulusSpec();
            names = string(fieldnames(combined));
            dmdNames = names(startsWith(names, "dmd_"));
            spec = struct('schema_version', '1.0.0', 'module', 'dmd');
            for index = 1:numel(dmdNames)
                name = dmdNames(index);
                spec.(char(name)) = combined.(char(name));
            end
            spec.pattern_folder = char(string(app.DmdPatternFolderField.Value));
            spec.start_position = app.DmdStartPositionField.Value;
            spec.picture_count = app.DmdPictureCountField.Value;
            spec.mask = struct( ...
                'mode', char(string(app.DmdMaskModeDropDown.Value)), ...
                'threshold_percent', app.DmdMaskThresholdField.Value, ...
                'minimum_area_pixels', app.DmdMaskMinAreaField.Value, ...
                'expansion_pixels', app.DmdMaskExpansionField.Value, ...
                'create_each_roi', app.DmdMaskEachRoiCheckBox.Value, ...
                'insert_off_between_rois', ...
                    app.DmdInsertOffBetweenRoisCheckBox.Value, ...
                'create_reverse', app.DmdMaskReverseCheckBox.Value);
            spec.playback = struct( ...
                'bit_depth', char(string(app.DmdBitDepthDropDown.Value)), ...
                'internal_playback_hz', app.DmdInternalRateField.Value, ...
                'legacy_trailing_all_off_padding', ...
                    app.DmdTrailingOffPaddingCheckBox.Value, ...
                'vertical_mirror', app.DmdVerticalMirrorCheckBox.Value, ...
                'data_reverse', app.DmdDataReverseCheckBox.Value, ...
                'row_addressing', app.DmdRowAddressingCheckBox.Value, ...
                'input_edge', char(string(app.DmdInputEdgeDropDown.Value)), ...
                'output_edge', char(string(app.DmdOutputEdgeDropDown.Value)), ...
                'divided_edge', char(string(app.DmdDividedEdgeDropDown.Value)), ...
                'trigger_division', app.DmdTriggerDivisionField.Value, ...
                'picture_count_action', ...
                    char(string(app.DmdPictureCountActionDropDown.Value)));
            % Calibration is intentionally excluded from reusable methods.
            % Its actual file, matrix, and hash belong to the Record-level
            % method/manifest because calibration is experiment-specific.
        end

        function applyDmdMethodSpec(app, dmdSpec)
            combined = app.currentLightStimulusSpec();
            names = string(fieldnames(dmdSpec));
            for index = 1:numel(names)
                name = names(index);
                if startsWith(name, "dmd_")
                    combined.(char(name)) = dmdSpec.(char(name));
                end
            end
            app.applyLightStimulusSpec(combined);
            if isfield(dmdSpec, 'pattern_folder')
                app.DmdPatternFolderField.Value = ...
                    char(string(dmdSpec.pattern_folder));
            end
            if isfield(dmdSpec, 'start_position')
                app.DmdStartPositionField.Value = dmdSpec.start_position;
            end
            if isfield(dmdSpec, 'picture_count')
                app.DmdPictureCountField.Value = dmdSpec.picture_count;
            end
            if isfield(dmdSpec, 'mask')
                mask = dmdSpec.mask;
                app.DmdMaskModeDropDown.Value = char(string( ...
                    app.structFieldOr(mask, 'mode', ...
                    app.DmdMaskModeDropDown.Value)));
                app.DmdMaskThresholdField.Value = app.structFieldOr( ...
                    mask, 'threshold_percent', ...
                    app.DmdMaskThresholdField.Value);
                app.DmdMaskMinAreaField.Value = app.structFieldOr( ...
                    mask, 'minimum_area_pixels', ...
                    app.DmdMaskMinAreaField.Value);
                app.DmdMaskExpansionField.Value = app.structFieldOr( ...
                    mask, 'expansion_pixels', ...
                    app.DmdMaskExpansionField.Value);
                app.DmdMaskEachRoiCheckBox.Value = app.structFieldOr( ...
                    mask, 'create_each_roi', ...
                    app.DmdMaskEachRoiCheckBox.Value);
                app.DmdInsertOffBetweenRoisCheckBox.Value = ...
                    app.structFieldOr(mask, 'insert_off_between_rois', ...
                    app.DmdInsertOffBetweenRoisCheckBox.Value);
                app.DmdMaskReverseCheckBox.Value = app.structFieldOr( ...
                    mask, 'create_reverse', ...
                    app.DmdMaskReverseCheckBox.Value);
            end
            if isfield(dmdSpec, 'playback')
                playback = dmdSpec.playback;
                app.applyControlValueIfPresent(app.DmdBitDepthDropDown, ...
                    playback, 'bit_depth');
                app.applyControlValueIfPresent(app.DmdInternalRateField, ...
                    playback, 'internal_playback_hz');
                app.applyControlValueIfPresent( ...
                    app.DmdTrailingOffPaddingCheckBox, playback, ...
                    'legacy_trailing_all_off_padding');
                app.applyControlValueIfPresent(app.DmdVerticalMirrorCheckBox, ...
                    playback, 'vertical_mirror');
                app.applyControlValueIfPresent(app.DmdDataReverseCheckBox, ...
                    playback, 'data_reverse');
                app.applyControlValueIfPresent(app.DmdRowAddressingCheckBox, ...
                    playback, 'row_addressing');
                app.applyControlValueIfPresent(app.DmdInputEdgeDropDown, ...
                    playback, 'input_edge');
                app.applyControlValueIfPresent(app.DmdOutputEdgeDropDown, ...
                    playback, 'output_edge');
                app.applyControlValueIfPresent(app.DmdDividedEdgeDropDown, ...
                    playback, 'divided_edge');
                app.applyControlValueIfPresent(app.DmdTriggerDivisionField, ...
                    playback, 'trigger_division');
                app.applyControlValueIfPresent( ...
                    app.DmdPictureCountActionDropDown, playback, ...
                    'picture_count_action');
            end
            app.DmdOperationalPatternLoaded = false;
            app.DmdCompiledManifest = struct();
            app.setDmdPatternState('SELECTED', ...
                'DMD method loaded — click Load Pattern before playback.');
            app.LightStimulusController.configure( ...
                app.currentLightStimulusSpec(), app.Logger);
            app.updateLightStimulusFieldAvailability();
        end

        function normalizeFollowDoAnalogDrafts(app)
            doDelay = app.LightStimDelayField.Value;
            digitalMode = string(app.LightStimWaveformDropDown.Value);
            doDuration = double(app.LightStimDigitalPointTable.Data(end, 1));
            if digitalMode == "ON/OFF Cycles"
                doOn = app.LightStimPulseWidthField.Value;
                doOff = app.LightStimPulsePeriodField.Value;
                doCycles = round(app.LightStimDigitalRepeatField.Value);
            else
                % Continuous ON and Manual Points use the final DO table as
                % the authoritative gate.  AO Follow DO only needs a helper
                % window here; the compiler applies the exact DO table mask.
                doOn = doDuration;
                doOff = 0;
                doCycles = 1;
            end
            names = ["Laser405","Laser445"];
            for name = names
                entry = app.LightStimAnalogDraft.(char(name));
                if ~isfield(entry, 'timing_mode') || ...
                        string(entry.timing_mode) ~= "Follow DO"
                    continue;
                end
                entry.delay_seconds = doDelay;
                entry.cycle_on_seconds = doOn;
                entry.cycle_off_seconds = doOff;
                entry.repeat_count = doCycles;
                helper = string(entry.table_helper);
                switch helper
                    case {"Step","Pulse","Line","Constant (Line)", ...
                            "Rectangular cycle"}
                        helper = "Constant";
                    case {"Ramp up","Ramp"}
                        helper = "Linear";
                end
                entry.table_helper = char(helper);
                if helper == "Custom"
                    times = double(entry.point_times_seconds(:));
                    if isempty(times) || abs(times(end) - doDuration) > ...
                            max(1e-9, doDuration * 1e-9)
                        error('ZouLab:FollowDoCustomDurationMismatch', ...
                            ['Custom AO in Follow DO mode must end at the DO duration ', ...
                             '(%.9g s). Edit the final AO table time or use Independent.'], ...
                            doDuration);
                    end
                    points = [times, double(entry.point_values_volts(:))];
                else
                    points = zoulab.StimulusWaveformCompiler.expandAnalogPreset( ...
                        helper, doOn, doOff, doCycles, ...
                        entry.pulse_low_voltage, entry.pulse_high_voltage, ...
                        entry.off_voltage);
                end
                entry.point_times_seconds = points(:, 1).';
                entry.point_values_volts = points(:, 2).';
                entry.waveform_type = 'Points';
                entry.points_are_expanded = true;
                entry.duration_seconds = points(end, 1);
                entry.pulse_width_seconds = doOn;
                entry.pulse_period_seconds = doOn + doOff;
                app.LightStimAnalogDraft.(char(name)) = entry;
            end
        end

        function toggleLightStimulusTimeline(app)
            if app.LightStimTimelinePreview
                app.beginAction('HIDE_LIGHT_STIMULUS_TIMELINE', ...
                    'Removing the draft waveform from the timeline...', ...
                    app.LightStimFrameworkStatusLabel);
                app.LightStimTimelinePreview = false;
                app.LightStimTimelinePreviewButton.Text = 'Show';
                app.refreshDaqTimeline('light_stimulus_draft_hidden');
                app.Logger.log('INFO', 'LIGHT_STIMULUS_DRAFT_TIMELINE_HIDDEN', ...
                    'HardwareArmed=%d | HardwareCommandIssued=0', ...
                    app.LightStimulusController.Armed);
                app.finishAction('HIDE_LIGHT_STIMULUS_TIMELINE', true, ...
                    'Draft preview hidden; hardware state is unchanged.', ...
                    app.LightStimFrameworkStatusLabel);
                return;
            end

            app.beginAction('SHOW_LIGHT_STIMULUS_TIMELINE', ...
                'Validating the configured waveform for the timeline...', ...
                app.LightStimFrameworkStatusLabel);
            try
                app.requireIdentity('show light stimulus timeline');
                app.LightStimulusController.configure( ...
                    app.currentLightStimulusSpec(), app.Logger);
                app.LightStimTimelinePreview = true;
                app.LightStimTimelinePreviewButton.Text = 'Hide';
                app.refreshDaqTimeline('light_stimulus_draft_shown');
                app.Logger.log('SUCCESS', ...
                    'LIGHT_STIMULUS_DRAFT_TIMELINE_SHOWN', ...
                    ['HardwareArmed=0 | HardwareCommandIssued=0 | ', ...
                     'AutoRefreshDebounceSeconds=%.3f'], ...
                    app.UiRefreshDebounceSeconds);
                app.finishAction('SHOW_LIGHT_STIMULUS_TIMELINE', true, ...
                    ['DRAFT PREVIEW shown; hardware is not armed. ', ...
                     'Edits refresh after 250 ms.'], ...
                    app.LightStimFrameworkStatusLabel);
            catch ME
                app.LightStimTimelinePreview = false;
                app.LightStimTimelinePreviewButton.Text = 'Show';
                app.handleError('LIGHT_STIMULUS_DRAFT_TIMELINE_FAILED', ...
                    ME, app.LightStimFrameworkStatusLabel);
            end
        end

        function updateLightStimulusFieldAvailability(app)
            identityReady = app.IdentityConfirmed;
            digitalMode = string(app.LightStimWaveformDropDown.Value);
            app.LightStimPulseWidthField.Editable = app.onOff( ...
                identityReady && digitalMode ~= "Manual Points");
            app.LightStimPulsePeriodField.Editable = app.onOff( ...
                identityReady && digitalMode == "ON/OFF Cycles");
            app.LightStimDigitalRepeatField.Editable = app.onOff( ...
                identityReady && digitalMode == "ON/OFF Cycles");
            app.LightStimDigitalPointTable.Enable = app.onOff(identityReady);
            helper = string(app.LightStimAnalogWaveformDropDown.Value);
            followDo = string(app.LightStimAnalogTimingModeDropDown.Value) == ...
                "Follow DO";
            app.LightStimAnalogHighVoltageField.Editable = app.onOff( ...
                identityReady && helper ~= "Custom");
            app.LightStimAnalogLowVoltageField.Editable = app.onOff(identityReady);
            app.LightStimAnalogOffVoltageField.Editable = app.onOff(identityReady);
            app.LightStimAnalogDelayField.Editable = ...
                app.onOff(identityReady && ~followDo);
            app.LightStimAnalogDurationField.Editable = ...
                app.onOff(identityReady && ~followDo);
            app.LightStimAnalogPulseWidthField.Editable = ...
                app.onOff(identityReady && ~followDo);
            app.LightStimAnalogRepeatField.Editable = ...
                app.onOff(identityReady && ~followDo);
            app.LightStimAnalogPointTable.Enable = app.onOff(identityReady);
            app.LightStimAnalogGenerateButton.Enable = app.onOff( ...
                identityReady && helper ~= "Custom");
            dmd = identityReady && ...
                string(app.LightStimDmdSwitch.Value) == "ON";
            app.LightStimDmdPatternDropDown.Enable = app.onOff(dmd);
            app.LightStimDmdLoopSwitch.Enable = app.onOff(dmd);
            app.LightStimDmdRateField.Editable = app.onOff(dmd);
            app.LightStimDmdPulseField.Editable = app.onOff(dmd);
            if ~isempty(app.DmdTriggerModeDropDown) && ...
                    isvalid(app.DmdTriggerModeDropDown)
                external = string(app.DmdTriggerModeDropDown.Value) == ...
                    "External IN1";
                app.DmdPauseButton.Enable = app.onOff(identityReady && ~external);
                if external
                    app.DmdPlayButton.Text = 'ARM FOR IN1 TRIGGER';
                else
                    app.DmdPlayButton.Text = 'PLAY (Internal)';
                end
            end
        end

        function mode = dmdGeneratedPaddingMode(app, pattern, ~)
            if string(pattern) == "Generated Each ROI"
                if app.DmdTrailingOffPaddingCheckBox.Value
                    mode = "dark";
                else
                    mode = "repeat_sequence";
                end
            else
                mode = "repeat_last";
            end
        end

        function mode = lightDmdPlaybackMode(~, spec)
            if isfield(spec, 'dmd_trigger_mode') && ...
                    string(spec.dmd_trigger_mode) ~= "External IN1"
                mode = "internal_independent";
            elseif logical(spec.dmd_loop)
                mode = "external_loop";
            else
                mode = "external_single";
            end
        end

        function storeLightStimulusAnalogControls(app, target)
            field = "Laser" + string(target);
            entry = app.LightStimAnalogDraft.(char(field));
            entry.waveform_type = 'Points';
            entry.table_helper = char(string( ...
                app.LightStimAnalogWaveformDropDown.Value));
            entry.timing_mode = char(string( ...
                app.LightStimAnalogTimingModeDropDown.Value));
            entry.delay_seconds = app.LightStimAnalogDelayField.Value;
            points = double(app.LightStimAnalogPointTable.Data);
            entry.point_times_seconds = points(:, 1).';
            entry.point_values_volts = points(:, 2).';
            entry.repeat_count = app.LightStimAnalogRepeatField.Value;
            entry.points_are_expanded = true;
            if isempty(points)
                entry.duration_seconds = 0;
            else
                entry.duration_seconds = max(points(:, 1));
            end
            entry.cycle_on_seconds = app.LightStimAnalogDurationField.Value;
            entry.cycle_off_seconds = app.LightStimAnalogPulseWidthField.Value;
            entry.off_voltage = app.LightStimAnalogOffVoltageField.Value;
            entry.pulse_high_voltage = app.LightStimAnalogHighVoltageField.Value;
            entry.pulse_low_voltage = app.LightStimAnalogLowVoltageField.Value;
            entry.pulse_width_seconds = entry.cycle_on_seconds;
            entry.pulse_period_seconds = entry.cycle_on_seconds + ...
                entry.cycle_off_seconds;
            app.LightStimAnalogDraft.(char(field)) = entry;
        end

        function loadLightStimulusAnalogControls(app, target)
            field = "Laser" + string(target);
            entry = app.LightStimAnalogDraft.(char(field));
            helpers = ["Constant","Linear","Triangle","Custom"];
            incomingHelper = "Constant";
            if isfield(entry, 'table_helper')
                incomingHelper = string(entry.table_helper);
            end
            switch incomingHelper
                case {"Step","Pulse","Line","Constant (Line)", ...
                        "Rectangular cycle"}
                    incomingHelper = "Constant";
                case {"Ramp up","Ramp"}
                    incomingHelper = "Linear";
            end
            if any(incomingHelper == helpers)
                app.LightStimAnalogWaveformDropDown.Value = char(incomingHelper);
            else
                app.LightStimAnalogWaveformDropDown.Value = 'Constant';
            end
            timingMode = "Independent";
            if isfield(entry, 'timing_mode') && ...
                    any(string(entry.timing_mode) == ["Follow DO","Independent"])
                timingMode = string(entry.timing_mode);
            end
            app.LightStimAnalogTimingModeDropDown.Value = char(timingMode);
            app.LightStimAnalogDelayField.Value = entry.delay_seconds;
            if isfield(entry, 'point_times_seconds') && ...
                    numel(entry.point_times_seconds) >= 2
                points = [double(entry.point_times_seconds(:)), ...
                    double(entry.point_values_volts(:))];
                repeatCount = double(entry.repeat_count);
                expanded = isfield(entry, 'points_are_expanded') && ...
                    logical(entry.points_are_expanded);
                if ~expanded && repeatCount > 1
                    points = zoulab.StimulusWaveformCompiler.expandPointTemplate( ...
                        points(:, 1), points(:, 2), repeatCount);
                    entry.point_times_seconds = points(:, 1).';
                    entry.point_values_volts = points(:, 2).';
                    entry.points_are_expanded = true;
                    entry.duration_seconds = points(end, 1);
                end
            else
                [points, repeatCount] = ...
                    zoulab.StimulusWaveformCompiler.legacyAnalogToPoints(entry);
                entry.waveform_type = 'Points';
                entry.point_times_seconds = points(:, 1).';
                entry.point_values_volts = points(:, 2).';
                entry.repeat_count = repeatCount;
                points = zoulab.StimulusWaveformCompiler.expandPointTemplate( ...
                    points(:, 1), points(:, 2), repeatCount);
                entry.point_times_seconds = points(:, 1).';
                entry.point_values_volts = points(:, 2).';
                entry.points_are_expanded = true;
                entry.duration_seconds = points(end, 1);
            end
            app.LightStimAnalogDraft.(char(field)) = entry;
            app.LightStimAnalogPointTable.Data = points;
            app.LightStimAnalogRepeatField.Value = repeatCount;
            if isfield(entry, 'cycle_on_seconds')
                app.LightStimAnalogDurationField.Value = entry.cycle_on_seconds;
            else
                app.LightStimAnalogDurationField.Value = ...
                    min(entry.pulse_width_seconds, ...
                    entry.pulse_period_seconds);
            end
            if isfield(entry, 'cycle_off_seconds')
                app.LightStimAnalogPulseWidthField.Value = ...
                    entry.cycle_off_seconds;
            else
                app.LightStimAnalogPulseWidthField.Value = max(0, ...
                    entry.pulse_period_seconds - ...
                    app.LightStimAnalogDurationField.Value);
            end
            app.LightStimAnalogHighVoltageField.Value = entry.pulse_high_voltage;
            app.LightStimAnalogLowVoltageField.Value = entry.pulse_low_voltage;
            if isfield(entry, 'off_voltage')
                app.LightStimAnalogOffVoltageField.Value = entry.off_voltage;
            else
                app.LightStimAnalogOffVoltageField.Value = 0;
            end
            app.LightStimAnalogCalculatedDurationField.Value = points(end, 1);
            if timingMode == "Follow DO"
                app.syncFollowDoAnalogTiming();
            end
        end

        function lightStimulusAnalogTimingModeChanged(app, previousValue, newValue)
            if app.LightStimulusController.Armed
                app.disarmLightStimulus('analog_timing_mode_changed');
            end
            app.Logger.log('INFO', 'USER_LIGHT_STIMULUS_AO_TIMING_MODE_CHANGED', ...
                ['Target=%s | Previous=%s | New=%s | ', ...
                 'HardwareCommandIssued=0'], ...
                app.LightStimAnalogTargetDropDown.Value, previousValue, newValue);
            if string(newValue) == "Follow DO"
                app.syncFollowDoAnalogTiming();
            end
            app.updateLightStimulusFieldAvailability();
            app.storeLightStimulusAnalogControls( ...
                string(app.LightStimAnalogTargetDropDown.Value));
            app.LightStimFrameworkStatusLabel.Text = ...
                'AO timing mode changed — click Generate AO waveform.';
            app.LightStimFrameworkStatusLabel.FontColor = [0.80 0.48 0.05];
            app.persistUserSettings('light_stimulus_AO_timing_mode');
        end

        function syncFollowDoAnalogTiming(app)
            if isempty(app.LightStimAnalogTimingModeDropDown) || ...
                    ~isvalid(app.LightStimAnalogTimingModeDropDown) || ...
                    string(app.LightStimAnalogTimingModeDropDown.Value) ~= "Follow DO"
                return;
            end
            app.LightStimAnalogDelayField.Value = app.LightStimDelayField.Value;
            app.LightStimAnalogDurationField.Value = ...
                app.LightStimPulseWidthField.Value;
            app.LightStimAnalogPulseWidthField.Value = ...
                app.LightStimPulsePeriodField.Value;
            app.LightStimAnalogRepeatField.Value = ...
                app.LightStimDigitalRepeatField.Value;
            app.updateAnalogCalculatedDuration();
        end

        function updateDigitalCalculatedDuration(app)
            mode = string(app.LightStimWaveformDropDown.Value);
            if mode == "Continuous ON"
                value = app.LightStimPulseWidthField.Value;
            elseif mode == "ON/OFF Cycles"
                value = (app.LightStimPulseWidthField.Value + ...
                    app.LightStimPulsePeriodField.Value) * ...
                    app.LightStimDigitalRepeatField.Value;
            else
                data = double(app.LightStimDigitalPointTable.Data);
                value = data(end, 1);
            end
            app.LightStimDurationField.Value = value;
        end

        function updateAnalogCalculatedDuration(app)
            app.LightStimAnalogCalculatedDurationField.Value = ...
                (app.LightStimAnalogDurationField.Value + ...
                app.LightStimAnalogPulseWidthField.Value) * ...
                app.LightStimAnalogRepeatField.Value;
        end

        function generateAnalogPointTable(app)
            helper = string(app.LightStimAnalogWaveformDropDown.Value);
            previous = app.LightStimAnalogPointTable.Data;
            try
                if helper == "Custom"
                    error('ZouLab:AnalogCustomUsesEditableTable', ...
                        'Custom AO is edited directly in the full-sequence table.');
                end
                if string(app.LightStimAnalogTimingModeDropDown.Value) == ...
                        "Follow DO"
                    app.syncFollowDoAnalogTiming();
                end
                onSeconds = app.LightStimAnalogDurationField.Value;
                offSeconds = app.LightStimAnalogPulseWidthField.Value;
                cycles = round(app.LightStimAnalogRepeatField.Value);
                points = zoulab.StimulusWaveformCompiler.expandAnalogPreset( ...
                    helper, onSeconds, offSeconds, cycles, ...
                    app.LightStimAnalogLowVoltageField.Value, ...
                    app.LightStimAnalogHighVoltageField.Value, ...
                    app.LightStimAnalogOffVoltageField.Value);
                app.LightStimAnalogPointTable.Data = points;
                app.LightStimAnalogCalculatedDurationField.Value = points(end, 1);
                app.lightStimulusAnalogPointTableEdited( ...
                    app.LightStimAnalogPointTable, struct( ...
                    'Indices', zeros(0, 2), 'PreviousData', previous, ...
                    'NewData', points));
                app.Logger.log('INFO', ...
                    'USER_LIGHT_STIMULUS_AO_TABLE_GENERATED', ...
                    ['Target=%s | Helper=%s | OnSeconds=%.9g | ', ...
                     'OffSeconds=%.9g | Cycles=%d | TableRows=%d | ', ...
                     'DurationSeconds=%.9g | HardwareCommandIssued=0'], ...
                    app.LightStimAnalogTargetDropDown.Value, helper, ...
                    onSeconds, offSeconds, cycles, size(points, 1), points(end, 1));
            catch ME
                app.LightStimAnalogPointTable.Data = previous;
                app.handleError('LIGHT_STIMULUS_AO_TABLE_GENERATION_FAILED', ...
                    ME, app.LightStimFrameworkStatusLabel);
            end
        end

        function lightStimulusAnalogPointTableEdited(app, ~, event)
            previous = "table";
            current = "table";
            try
                previous = string(event.PreviousData);
                current = string(event.NewData);
            catch
            end
            try
                data = double(app.LightStimAnalogPointTable.Data);
                zoulab.StimulusWaveformCompiler.validatePointWaveform( ...
                    data(:, 1), data(:, 2), 1, ...
                    app.LightStimAnalogTargetDropDown.Value);
                app.LightStimAnalogCalculatedDurationField.Value = data(end, 1);
                app.lightStimulusAnalogSettingEdited( ...
                    'PointTable', previous, current);
            catch ME
                app.Logger.logException( ...
                    'LIGHT_STIMULUS_AO_TABLE_EDIT_REJECTED', ME);
                app.LightStimFrameworkStatusLabel.Text = ...
                    "Invalid AO point table: " + string(ME.message);
                app.LightStimFrameworkStatusLabel.FontColor = [0.78 0.18 0.12];
            end
        end

        function lightStimulusAnalogHelperEdited(app, settingName, previousValue, newValue)
            if app.LightStimulusController.Armed
                app.disarmLightStimulus('analog_configuration_changed');
            end
            app.Logger.log('INFO', 'USER_LIGHT_STIMULUS_AO_HELPER_EDITED', ...
                ['Target=%s | Setting=%s | Previous=%s | New=%s | ', ...
                 'TableRegenerationRequired=1 | HardwareCommandIssued=0'], ...
                app.LightStimAnalogTargetDropDown.Value, settingName, ...
                string(previousValue), string(newValue));
            app.updateAnalogCalculatedDuration();
            app.updateLightStimulusFieldAvailability();
            app.LightStimFrameworkStatusLabel.Text = ...
                'AO parameter changed — click Generate AO waveform.';
            app.LightStimFrameworkStatusLabel.FontColor = [0.80 0.48 0.05];
            app.persistUserSettings("light_stimulus_AO_" + string(settingName));
        end

        function generateDigitalPointTable(app, source)
            if nargin < 2
                source = "user_reset";
            end
            if app.DoWaveformRegenerationRunning
                return;
            end
            mode = string(app.LightStimWaveformDropDown.Value);
            if mode == "Manual Points"
                app.Logger.log('INFO', ...
                    'LIGHT_STIMULUS_DO_TABLE_REGENERATION_SKIPPED', ...
                    'Reason=manual_points_mode | Source=%s', source);
                return;
            end
            app.DoWaveformRegenerationRunning = true;
            regenerationCleanup = onCleanup( ...
                @() app.finishDoWaveformRegeneration()); %#ok<NASGU>
            previous = app.LightStimDigitalPointTable.Data;
            try
                onSeconds = app.LightStimPulseWidthField.Value;
                offSeconds = app.LightStimPulsePeriodField.Value;
                repeatCount = round(app.LightStimDigitalRepeatField.Value);
                if mode == "Continuous ON"
                    points = [0 0; 0 1; onSeconds 1; onSeconds 0];
                    offSeconds = 0;
                    repeatCount = 1;
                    zoulab.StimulusWaveformCompiler.validateDigitalPointWaveform( ...
                        points(:, 1), points(:, 2), 1);
                else
                    points = zoulab.StimulusWaveformCompiler.expandDigitalOnOff( ...
                        onSeconds, offSeconds, repeatCount);
                end
                app.LightStimDigitalPointTable.Data = points;
                app.LightStimDurationField.Value = points(end, 1);
                app.updateRecordLengthSummary();
                app.LightStimDigitalSelectedRows = zeros(1, 0);
                app.syncFollowDoAnalogTiming();
                app.LightStimulusController.configure( ...
                    app.currentLightStimulusSpec(), app.Logger);
                app.LightStimFrameworkStatusLabel.Text = sprintf( ...
                    'DO %s updated: %d rows, %.6g s.', ...
                    mode, size(points, 1), points(end, 1));
                app.LightStimFrameworkStatusLabel.FontColor = [0.08 0.55 0.18];
                app.Logger.log('SUCCESS', ...
                    'LIGHT_STIMULUS_DO_TABLE_AUTO_GENERATED', ...
                    ['Source=%s | Mode=%s | OnSeconds=%.9g | ', ...
                     'OffSeconds=%.9g | Cycles=%d | TableRows=%d | ', ...
                     'DurationSeconds=%.9g | ReplacedManualTableEdits=%d | ', ...
                     'HardwareCommandIssued=0'], source, mode, onSeconds, ...
                    offSeconds, repeatCount, size(points, 1), points(end, 1), ...
                    ~isequaln(previous, points));
            catch ME
                app.LightStimDigitalPointTable.Data = previous;
                app.handleError('LIGHT_STIMULUS_DO_TABLE_GENERATION_FAILED', ...
                    ME, app.LightStimFrameworkStatusLabel);
            end
        end

        function resetDigitalPointTable(app)
            app.Logger.log('INFO', ...
                'USER_LIGHT_STIMULUS_DO_TABLE_RESET_REQUESTED', ...
                'Mode=%s | HardwareCommandIssued=0', ...
                string(app.LightStimWaveformDropDown.Value));
            if string(app.LightStimWaveformDropDown.Value) == "Manual Points"
                previous = app.LightStimDigitalPointTable.Data;
                app.LightStimDigitalPointTable.Data = ...
                    app.clearedWaveformData('DO');
                app.commitWaveformTableChange('DO', 'ResetManual', previous);
            else
                app.generateDigitalPointTable("user_reset");
                app.scheduleExpensiveUiRefresh( ...
                    'light_stimulus_DO_user_reset', true, false, false);
            end
        end

        function finishDoWaveformRegeneration(app)
            app.DoWaveformRegenerationRunning = false;
        end

        function lightStimulusDigitalPointTableEdited(app, ~, event)
            previous = "table";
            current = "table";
            try
                previous = string(event.PreviousData);
                current = string(event.NewData);
            catch
            end
            try
                data = double(app.LightStimDigitalPointTable.Data);
                zoulab.StimulusWaveformCompiler.validateDigitalPointWaveform( ...
                    data(:, 1), data(:, 2), 1);
                app.LightStimDurationField.Value = data(end, 1);
                app.updateRecordLengthSummary();
                app.lightStimulusSettingEdited('DigitalPointTable', ...
                    previous, current);
                app.scheduleExpensiveUiRefresh( ...
                    'light_stimulus_DO_table_manual_edit', ...
                    true, false, false);
            catch ME
                app.Logger.logException( ...
                    'LIGHT_STIMULUS_DO_TABLE_EDIT_REJECTED', ME);
                app.LightStimFrameworkStatusLabel.Text = ...
                    "Invalid DO point table: " + string(ME.message);
                app.LightStimFrameworkStatusLabel.FontColor = [0.78 0.18 0.12];
            end
        end

        function waveformTableSelectionChanged(app, kind, event)
            rows = zeros(1, 0);
            if ~isempty(event.Indices)
                rows = unique(double(event.Indices(:, 1))).';
            end
            switch upper(string(kind))
                case "DO"
                    app.LightStimDigitalSelectedRows = rows;
                case "AO"
                    app.LightStimAnalogSelectedRows = rows;
                otherwise
                    app.DmdTriggerSelectedRows = rows;
            end
            app.Logger.log('INFO', 'USER_WAVEFORM_TABLE_SELECTION_CHANGED', ...
                'Table=%s | SelectedRows=%s | HardwareCommandIssued=0', ...
                upper(string(kind)), mat2str(rows));
        end

        function addWaveformPoint(app, kind)
            [tableHandle, data] = app.waveformTableData(kind);
            if size(data, 1) < 2
                data = app.clearedWaveformData(kind);
            end
            row = size(data, 1) - 1;
            newPoint = (data(row, :) + data(row + 1, :)) / 2;
            data = [data(1:row, :); newPoint; data(row + 1:end, :)];
            tableHandle.Data = data;
            app.commitWaveformTableChange(kind, 'AddPoint', newPoint);
        end

        function insertWaveformPoint(app, kind)
            [tableHandle, data, selected] = app.waveformTableData(kind);
            if size(data, 1) < 2
                app.addWaveformPoint(kind);
                return;
            end
            if isempty(selected)
                app.addWaveformPoint(kind);
                return;
            end
            row = min(max(1, selected(1)), size(data, 1));
            if row >= size(data, 1)
                left = size(data, 1) - 1;
            else
                left = row;
            end
            newPoint = (data(left, :) + data(left + 1, :)) / 2;
            data = [data(1:left, :); newPoint; data(left + 1:end, :)];
            tableHandle.Data = data;
            app.commitWaveformTableChange(kind, 'InsertPoint', newPoint);
        end

        function deleteWaveformPoints(app, kind)
            [tableHandle, data, selected] = app.waveformTableData(kind);
            if isempty(selected)
                app.Logger.log('WARNING', 'USER_WAVEFORM_DELETE_SKIPPED', ...
                    'Table=%s | Reason=no_selected_row', upper(string(kind)));
                app.LightStimFrameworkStatusLabel.Text = ...
                    'Select one or more table rows before Delete selected.';
                return;
            end
            selected = intersect(selected, 2:size(data, 1) - 1);
            if isempty(selected)
                app.Logger.log('WARNING', 'USER_WAVEFORM_DELETE_SKIPPED', ...
                    'Table=%s | Reason=cycle_endpoints_are_protected', ...
                    upper(string(kind)));
                app.LightStimFrameworkStatusLabel.Text = ...
                    'The first and final cycle endpoints are protected; use Clear to reset.';
                return;
            end
            removed = data(selected, :);
            data(selected, :) = [];
            tableHandle.Data = data;
            app.commitWaveformTableChange(kind, 'DeleteSelected', removed);
        end

        function clearWaveformPoints(app, kind)
            [tableHandle, previous] = app.waveformTableData(kind);
            data = app.clearedWaveformData(kind);
            tableHandle.Data = data;
            app.commitWaveformTableChange(kind, 'Clear', previous);
        end

        function [tableHandle, data, selected] = waveformTableData(app, kind)
            switch upper(string(kind))
                case "DO"
                    tableHandle = app.LightStimDigitalPointTable;
                    selected = app.LightStimDigitalSelectedRows;
                otherwise
                    tableHandle = app.LightStimAnalogPointTable;
                    selected = app.LightStimAnalogSelectedRows;
            end
            data = double(tableHandle.Data);
        end

        function data = clearedWaveformData(app, kind)
            switch upper(string(kind))
                case "DO"
                    duration = max(0.0001, app.LightStimDurationField.Value);
                    data = [0 0; duration 0];
                otherwise
                    duration = max(0.0001, ...
                        app.LightStimAnalogCalculatedDurationField.Value);
                    voltage = app.LightStimAnalogOffVoltageField.Value;
                    data = [0 voltage; duration voltage];
            end
        end

        function commitWaveformTableChange(app, kind, action, detail)
            if upper(string(kind)) == "DO"
                app.LightStimDigitalSelectedRows = zeros(1, 0);
                app.lightStimulusDigitalPointTableEdited( ...
                    app.LightStimDigitalPointTable, struct());
                count = size(app.LightStimDigitalPointTable.Data, 1);
            else
                app.LightStimAnalogSelectedRows = zeros(1, 0);
                app.lightStimulusAnalogPointTableEdited( ...
                    app.LightStimAnalogPointTable, struct());
                count = size(app.LightStimAnalogPointTable.Data, 1);
            end
            app.Logger.log('INFO', 'USER_WAVEFORM_TABLE_ACTION', ...
                ['Table=%s | Action=%s | Detail=%s | RowsAfter=%d | ', ...
                 'HardwareCommandIssued=0'], upper(string(kind)), action, ...
                mat2str(double(detail), 6), count);
        end

        function dmdPatternSettingEdited(app, settingName, previousValue, newValue)
            if app.LightStimulusController.Armed
                app.disarmLightStimulus('dmd_pattern_setting_changed');
            end
            app.Logger.log('INFO', 'USER_DMD_PATTERN_SETTING_EDITED', ...
                ['Setting=%s | Previous=%s | New=%s | ', ...
                 'LightStimulusDisarmed=1'], settingName, ...
                string(previousValue), string(newValue));
            app.DmdOperationalPatternLoaded = false;
            app.DmdCompiledManifest = struct();
            app.setDmdPatternState('SELECTED', ...
                "Pattern setting changed (" + string(settingName) + ...
                ") — click Load Pattern.");
            app.DmdStatusLabel.Text = ...
                "Pattern setting changed: " + string(settingName);
            app.DmdStatusLabel.FontColor = [0.80 0.48 0.05];
            app.persistUserSettings("dmd_pattern_" + string(settingName));
        end

        function setDmdPatternState(app, state, message)
            state = upper(string(state));
            app.DmdOperationalPatternLoaded = any(state == ...
                ["LOADED","PLAYING","PAUSED","ARMED"]);
            switch state
                case {"LOADED","PLAYING","ARMED"}
                    color = [0.10 0.75 0.20];
                case {"LOADING","SELECTED","PAUSED"}
                    color = [0.95 0.65 0.10];
                case "ERROR"
                    color = [0.85 0.15 0.12];
                otherwise
                    color = [0.65 0.65 0.65];
            end
            if ~isempty(app.DmdPatternLamp) && isvalid(app.DmdPatternLamp)
                app.DmdPatternLamp.Color = color;
            end
            if ~isempty(app.DmdPatternStateLabel) && ...
                    isvalid(app.DmdPatternStateLabel)
                app.DmdPatternStateLabel.Text = char(string(message));
            end
            app.Logger.log('INFO', 'DMD_PATTERN_UI_STATE_CHANGED', ...
                'State=%s | Loaded=%d | Message=%s', state, ...
                app.DmdOperationalPatternLoaded, string(message));
        end

        function applyLightStimulusSpec(app, spec)
            hadDigitalPoints = isfield(spec, 'digital_point_times_seconds') && ...
                isfield(spec, 'digital_point_values') && ...
                numel(spec.digital_point_times_seconds) >= 2;
            originalSpec = spec;
            spec = zoulab.StimulusWaveformCompiler.withDefaults(spec);
            names = string(spec.stimulus_light_names);
            if numel(names) == 2
                app.LightStimSourceDropDown.Value = '405 + 445';
            elseif any(names == "Laser445")
                app.LightStimSourceDropDown.Value = '445';
            else
                app.LightStimSourceDropDown.Value = '405';
            end
            helper = "ON/OFF Cycles";
            if isfield(spec, 'digital_table_helper')
                requestedHelper = string(spec.digital_table_helper);
                helperItems = string(app.LightStimWaveformDropDown.Items);
                helperIndex = find(strcmpi(helperItems, requestedHelper), 1);
                if ~isempty(helperIndex)
                    helper = helperItems(helperIndex);
                end
            end
            app.LightStimWaveformDropDown.Value = char(helper);
            app.LightStimDelayField.Value = spec.stimulus_delay_seconds;
            app.LightStimPulseWidthField.Value = spec.pulse_width_seconds;
            app.LightStimPulsePeriodField.Value = max(0, ...
                spec.pulse_period_seconds - spec.pulse_width_seconds);
            if hadDigitalPoints
                digitalPoints = [double(spec.digital_point_times_seconds(:)), ...
                    double(spec.digital_point_values(:))];
                digitalRepeats = double(spec.digital_repeat_count);
                expanded = isfield(originalSpec, ...
                    'digital_points_are_expanded') && ...
                    logical(originalSpec.digital_points_are_expanded);
            else
                [digitalPoints, digitalRepeats] = ...
                    zoulab.StimulusWaveformCompiler.legacyDigitalToPoints(spec);
                expanded = false;
            end
            if ~expanded && digitalRepeats > 1
                digitalPoints = ...
                    zoulab.StimulusWaveformCompiler.expandPointTemplate( ...
                    digitalPoints(:, 1), digitalPoints(:, 2), digitalRepeats);
            end
            app.LightStimDigitalPointTable.Data = digitalPoints;
            app.LightStimDigitalRepeatField.Value = digitalRepeats;
            app.LightStimDurationField.Value = digitalPoints(end, 1);
            app.LightStimAnalogDraft = app.normalizedAnalogWaveforms(spec);
            if isempty(app.LightStimAnalogTargetDropDown.Value)
                app.LightStimAnalogTargetDropDown.Value = '405';
            end
            app.loadLightStimulusAnalogControls( ...
                string(app.LightStimAnalogTargetDropDown.Value));
            app.LightStimDmdSwitch.Value = upper(app.onOff(spec.dmd_enabled));
            pattern = strrep(string(spec.dmd_pattern), '_', ' ');
            patternItems = string(app.LightStimDmdPatternDropDown.Items);
            patternIndex = find(strcmpi(patternItems, pattern), 1, 'first');
            if ~isempty(patternIndex)
                % Assign the canonical UI item. MATLAB dropdown Value is
                % case-sensitive even though legacy migration matching is not.
                app.LightStimDmdPatternDropDown.Value = ...
                    char(patternItems(patternIndex));
            end
            if spec.dmd_loop
                app.LightStimDmdLoopSwitch.Value = 'Loop';
            else
                app.LightStimDmdLoopSwitch.Value = 'Single';
            end
            app.LightStimDmdRateField.Value = spec.dmd_frame_rate_hz;
            app.LightStimDmdPulseField.Value = ...
                spec.dmd_trigger_width_seconds * 1000;
            if isfield(spec, 'dmd_trigger_point_times_seconds') && ...
                    ~isempty(spec.dmd_trigger_point_times_seconds)
                pointTimes = double(spec.dmd_trigger_point_times_seconds(:));
                pointValues = double(spec.dmd_trigger_point_values(:));
                frames = zeros(size(pointTimes));
                rising = find(pointValues == 1 & ...
                    [true; pointValues(1:end - 1) == 0]);
                frameValues = (1:numel(rising)).';
                if isfield(spec, 'dmd_trigger_frame_indices') && ...
                        numel(spec.dmd_trigger_frame_indices) == numel(rising)
                    frameValues = double(spec.dmd_trigger_frame_indices(:));
                end
                currentFrame = 0;
                risingCursor = 0;
                for row = 1:numel(pointTimes)
                    if any(rising == row)
                        risingCursor = risingCursor + 1;
                        currentFrame = frameValues(risingCursor);
                    end
                    frames(row) = currentFrame;
                end
                app.DmdTriggerTable.Data = [pointTimes pointValues frames];
            elseif isfield(spec, 'dmd_trigger_times_seconds') && ...
                    ~isempty(spec.dmd_trigger_times_seconds)
                times = double(spec.dmd_trigger_times_seconds(:));
                frames = (1:numel(times)).';
                if isfield(spec, 'dmd_trigger_frame_indices') && ...
                        numel(spec.dmd_trigger_frame_indices) == numel(times)
                    frames = double(spec.dmd_trigger_frame_indices(:));
                end
                legacyRepeat = max(1, round(double( ...
                    spec.dmd_trigger_repeat_count)));
                if legacyRepeat > 1
                    baseTimes = times;
                    baseFrames = frames;
                    times = zeros(numel(baseTimes) * legacyRepeat, 1);
                    frames = zeros(size(times));
                    cursor = 0;
                    for repeatIndex = 0:legacyRepeat - 1
                        rows = cursor + (1:numel(baseTimes));
                        times(rows) = baseTimes + repeatIndex * ...
                            spec.dmd_trigger_cycle_seconds;
                        frames(rows) = baseFrames;
                        cursor = cursor + numel(baseTimes);
                    end
                end
                width = double(spec.dmd_trigger_width_seconds);
                period = 1 / double(spec.dmd_frame_rate_hz);
                points = [0 0 0];
                for index = 1:numel(times)
                    points(end + 1, :) = [times(index) 0 max(0, index - 1)]; %#ok<AGROW>
                    points(end + 1, :) = [times(index) 1 frames(index)]; %#ok<AGROW>
                    points(end + 1, :) = [times(index) + width 1 frames(index)]; %#ok<AGROW>
                    points(end + 1, :) = [times(index) + width 0 frames(index)]; %#ok<AGROW>
                end
                endTime = max(times(end) + period, ...
                    legacyRepeat * spec.dmd_trigger_cycle_seconds);
                points(end + 1, :) = [endTime 0 frames(end)]; %#ok<AGROW>
                app.DmdTriggerTable.Data = points;
            elseif isfield(spec, 'dmd_trigger_times_seconds')
                app.DmdTriggerTable.Data = zeros(0, 3);
            end
            restoredRisingRows = app.dmdTriggerRisingRows( ...
                app.DmdTriggerTable.Data);
            restoredTriggerCount = numel(restoredRisingRows);
            framesPerPattern = max(1, round(double( ...
                app.DmdPictureCountField.Value)));
            app.DmdTotalTriggerField.Value = restoredTriggerCount;
            app.DmdTriggerRepeatField.Value = ...
                restoredTriggerCount / framesPerPattern;
            if isfield(spec, 'dmd_start_offset_seconds')
                app.DmdTriggerDelayField.Value = ...
                    double(spec.dmd_start_offset_seconds);
            else
                % Old methods stored delay inside the point-table times.
                % Keep that table unchanged and add no second offset.
                app.DmdTriggerDelayField.Value = 0;
            end
            if isfield(spec, 'dmd_repeat_to_fill_timeline')
                app.DmdRepeatToFillTimelineCheckBox.Value = logical( ...
                    spec.dmd_repeat_to_fill_timeline);
            end
            app.DmdTriggerPeriodField.Value = 1 / spec.dmd_frame_rate_hz;
            app.updateLightStimulusFieldAvailability();
        end

        function values = normalizedAnalogWaveforms(~, spec)
            values = zoulab.StimulusWaveformCompiler.defaultAnalogWaveforms();
            if ~isfield(spec, 'analog_waveforms') || ...
                    ~isstruct(spec.analog_waveforms)
                return;
            end
            names = ["Laser405", "Laser445"];
            for name = names
                field = char(name);
                if ~isfield(spec.analog_waveforms, field)
                    continue;
                end
                incoming = spec.analog_waveforms.(field);
                entryNames = fieldnames(incoming);
                for entryIndex = 1:numel(entryNames)
                    values.(field).(entryNames{entryIndex}) = ...
                        incoming.(entryNames{entryIndex});
                end
                if ~isfield(incoming, 'points_are_expanded')
                    values.(field).points_are_expanded = false;
                end
                if ~isfield(incoming, 'timing_mode')
                    values.(field).timing_mode = 'Independent';
                end
            end
        end

        function cameraIndex = selectedDmdCalibrationCamera(app)
            value = string(app.DmdCalibrationCameraDropDown.Value);
            if startsWith(value, "Camera 2")
                cameraIndex = 2;
            else
                cameraIndex = 1;
            end
        end

        function root = currentDmdCalibrationRoot(app)
            app.requireIdentity('use DMD calibration storage');
            saveRoot = strtrim(string(app.RootPathField.Value));
            if strlength(saveRoot) == 0
                error('ZouLab:DmdCalibrationSaveRootRequired', ...
                    'Choose Experiment & Save > Save root before DMD calibration.');
            end
            root = fullfile(saveRoot, '_cal', 'dmd');
            app.DmdCalibrationRootField.Value = char(root);
            app.Logger.log('INFO', 'DMD_CALIBRATION_ROOT_RESOLVED', ...
                'Root=%s | Source=ExperimentSaveRoot | SeparateDmdPath=0', root);
        end

        function folder = currentDmdCameraCalibrationFolder(app)
            root = app.currentDmdCalibrationRoot();
            cameraIndex = app.selectedDmdCalibrationCamera();
            serial = string(app.Cameras.Serials(cameraIndex));
            if strlength(serial) == 0
                serial = "unknown";
            end
            safeSerial = regexprep(char(serial), '[^A-Za-z0-9_-]', '_');
            name = sprintf('Cam%d_%s', cameraIndex, safeSerial);
            folder = fullfile(root, name);
            if ~isfolder(folder)
                mkdir(folder);
            end
        end

        function dmdCalibrationCameraChanged(app, previousValue, newValue)
            app.DmdCalibrationData = struct();
            app.DmdCalibrationLamp.Color = [0.85 0.15 0.12];
            app.DmdCalibrationStatusLabel.Text = ...
                'NOT CALIBRATED — load or solve this camera calibration';
            app.DmdCalibrationMatrixField.Value = ...
                'No calibration matrix loaded';
            app.Logger.log('INFO', 'USER_DMD_CALIBRATION_CAMERA_CHANGED', ...
                ['Previous=%s | New=%s | CalibrationCleared=1 | ', ...
                 'Camera1Grid=standard | Camera2Grid=flipped'], ...
                string(previousValue), string(newValue));
            app.updateDmdGridResolvedPath();
            app.persistUserSettings('dmd_calibration_camera_changed');
        end

        function dmdGridModeChanged(app, previousValue, newValue)
            app.Logger.log('INFO', 'USER_DMD_CALIBRATION_GRID_SOURCE_CHANGED', ...
                ['Previous=%s | New=%s | HardwareCommandIssued=0 | ', ...
                 'PlaybackChanged=0'], string(previousValue), string(newValue));
            app.updateDmdGridResolvedPath();
            app.persistUserSettings('dmd_calibration_grid_source_changed');
        end

        function dmdCalibrationSourceChanged(app, previousValue, newValue)
            app.Logger.log('INFO', 'USER_DMD_CALIBRATION_SNAP_SOURCE_CHANGED', ...
                'Previous=%s | New=%s | HardwareCommandIssued=0', ...
                string(previousValue), string(newValue));
            app.persistUserSettings('dmd_calibration_snap_source_changed');
        end

        function folder = selectedDmdGridFolder(app, gridSet)
            mode = string(app.DmdGridModeDropDown.Value);
            if mode == "Auto by camera"
                if app.selectedDmdCalibrationCamera() == 2
                    mode = "Flipped";
                else
                    mode = "Standard";
                end
            end
            if mode == "Flipped"
                folder = string(gridSet.flipped_folder);
            else
                folder = string(gridSet.standard_folder);
            end
        end

        function updateDmdGridResolvedPath(app)
            if isempty(app.DmdGridResolvedPathField) || ...
                    ~isvalid(app.DmdGridResolvedPathField) || ...
                    ~app.IdentityConfirmed
                return;
            end
            try
                root = app.currentDmdCalibrationRoot();
                gridSet = struct('standard_folder', ...
                    char(fullfile(root, 'Standard_Matrix')), ...
                    'flipped_folder', char(fullfile(root, 'Flipped_Matrix')));
                app.DmdGridResolvedPathField.Value = char( ...
                    app.selectedDmdGridFolder(gridSet));
            catch
                app.DmdGridResolvedPathField.Value = '';
            end
        end

        function dmdCalibrationPathEdited(app, pathKind, previousValue, newValue)
            if string(pathKind) == "Root"
                app.DmdGridSet = struct();
                app.DmdCalibrationData = struct();
                app.DmdOperationalPatternLoaded = false;
                app.DmdCalibrationLamp.Color = [0.85 0.15 0.12];
                app.DmdCalibrationStatusLabel.Text = ...
                    'NOT CALIBRATED — root changed';
            end
            app.Logger.log('INFO', 'USER_DMD_CALIBRATION_PATH_EDITED', ...
                'Kind=%s | Previous=%s | New=%s', pathKind, ...
                string(previousValue), string(newValue));
            app.persistUserSettings( ...
                "dmd_calibration_" + lower(string(pathKind)) + "_edited");
        end

        function browseDmdCalibrationRoot(app)
            app.beginAction('BROWSE_DMD_CALIBRATION_ROOT', ...
                'Waiting for DMD calibration folder...', ...
                app.DmdCalibrationStatusLabel);
            startFolder = string(app.DmdCalibrationRootField.Value);
            if strlength(startFolder) == 0 || ~isfolder(startFolder)
                if app.IdentityConfirmed
                    startFolder = app.VisualPresets.ActiveFolder;
                else
                    startFolder = app.AppRoot;
                end
            end
            selected = uigetdir(char(startFolder), ...
                'Choose DMD calibration root');
            if isequal(selected, 0)
                app.finishAction('BROWSE_DMD_CALIBRATION_ROOT', false, ...
                    'DMD calibration-folder selection cancelled.', ...
                    app.DmdCalibrationStatusLabel);
                return;
            end
            previous = app.DmdCalibrationRootField.Value;
            app.DmdCalibrationRootField.Value = selected;
            app.dmdCalibrationPathEdited('Root', previous, selected);
            app.finishAction('BROWSE_DMD_CALIBRATION_ROOT', true, ...
                "Calibration root: " + string(selected), ...
                app.DmdCalibrationStatusLabel);
        end

        function generateDmdCalibrationGrids(app)
            app.beginAction('GENERATE_DMD_CALIBRATION_GRIDS', ...
                'Generating exact iDMD standard and flipped grid sets...', ...
                app.DmdCalibrationStatusLabel);
            try
                app.requireIdentity('generate DMD calibration grids');
                root = app.currentDmdCalibrationRoot();
                requiredBinaryMultiple = 16;
                if app.DmdController.Connected && ...
                        isfield(app.DmdController.DeviceInfo, ...
                        'required_image_multiple') && ...
                        isfinite(app.DmdController.DeviceInfo.required_image_multiple)
                    if app.DmdController.DeviceInfo.width ~= ...
                            zoulab.DmdCalibration.DmdWidth || ...
                            app.DmdController.DeviceInfo.height ~= ...
                            zoulab.DmdCalibration.DmdHeight
                        error('ZouLab:DmdCalibrationResolutionMismatch', ...
                            ['The iDMD grids are 1920x1080, but the connected DMD ', ...
                             'reported %dx%d.'], app.DmdController.DeviceInfo.width, ...
                            app.DmdController.DeviceInfo.height);
                    end
                    requiredBinaryMultiple = ...
                        app.DmdController.DeviceInfo.required_image_multiple;
                end
                if mod(requiredBinaryMultiple, 8) ~= 0
                    error('ZouLab:DmdCalibrationGridBlockInvalid', ...
                        ['The connected DMD requires %d binary frames, which ', ...
                         'cannot be represented by whole 8-bit grid files.'], ...
                        requiredBinaryMultiple);
                end
                eightBitFileCount = requiredBinaryMultiple / 8;
                app.DmdGridSet = zoulab.DmdCalibration.generateGridSet( ...
                    root, eightBitFileCount, app.Logger);
                app.DmdPictureCountField.Value = requiredBinaryMultiple;
                app.updateDmdGridResolvedPath();
                app.DmdCalibrationLamp.Color = [0.95 0.65 0.10];
                app.finishAction('GENERATE_DMD_CALIBRATION_GRIDS', true, ...
                    sprintf(['Both grid sets ready (%d 8-bit files / %d binary ', ...
                    'frames each). ', ...
                    'Project the grid selected by camera mapping.'], ...
                    eightBitFileCount, requiredBinaryMultiple), ...
                    app.DmdCalibrationStatusLabel);
                app.persistUserSettings('dmd_calibration_grids_generated');
            catch ME
                app.DmdCalibrationLamp.Color = [0.85 0.15 0.12];
                app.handleError('DMD_CALIBRATION_GRID_GENERATION_FAILED', ...
                    ME, app.DmdCalibrationStatusLabel);
            end
        end

        function gridSet = requireDmdGridSet(app)
            if isempty(fieldnames(app.DmdGridSet))
                root = app.currentDmdCalibrationRoot();
                parameterFile = fullfile(root, '0_Standard parameters.mat');
                standardFolder = fullfile(root, 'Standard_Matrix');
                flippedFolder = fullfile(root, 'Flipped_Matrix');
                if ~isfile(parameterFile) || ~isfolder(standardFolder) || ...
                        ~isfolder(flippedFolder)
                    error('ZouLab:DmdCalibrationGridsRequired', ...
                        'Generate both DMD calibration grids first.');
                end
                saved = load(parameterFile, 'metadata');
                imageCount = max(1, app.DmdPictureCountField.Value / 8);
                if isfield(saved, 'metadata') && ...
                        isfield(saved.metadata, 'upload_file_count')
                    imageCount = saved.metadata.upload_file_count;
                end
                app.DmdGridSet = struct('root', char(root), ...
                    'standard_folder', char(standardFolder), ...
                    'flipped_folder', char(flippedFolder), ...
                    'parameter_file', char(parameterFile), ...
                    'image_count', imageCount);
            end
            gridSet = app.DmdGridSet;
        end

        function projectDmdCalibrationGrid(app)
            app.beginAction('PROJECT_DMD_CALIBRATION_GRID', ...
                'Loading and projecting the selected calibration grid...', ...
                app.DmdCalibrationStatusLabel);
            try
                app.requireIdentity('project DMD calibration grid');
                if ~app.DmdController.Connected
                    error('ZouLab:DmdNotConnected', ...
                        'Connect DMD before projecting a calibration grid.');
                end
                if app.DmdController.DeviceInfo.width ~= ...
                        zoulab.DmdCalibration.DmdWidth || ...
                        app.DmdController.DeviceInfo.height ~= ...
                        zoulab.DmdCalibration.DmdHeight
                    error('ZouLab:DmdCalibrationResolutionMismatch', ...
                        ['The iDMD grids require a 1920x1080 DMD; connected ', ...
                         'device reported %dx%d.'], ...
                        app.DmdController.DeviceInfo.width, ...
                        app.DmdController.DeviceInfo.height);
                end
                if startsWith(app.DmdController.State, 'PLAYING') || ...
                        startsWith(app.DmdController.State, 'ARMED')
                    app.DmdController.stop(app.Logger);
                end
                gridSet = app.requireDmdGridSet();
                cameraIndex = app.selectedDmdCalibrationCamera();
                folder = app.selectedDmdGridFolder(gridSet);
                app.DmdGridResolvedPathField.Value = char(folder);
                files = dir(fullfile(folder, '*.bmp'));
                uploadFileCount = numel(files);
                if uploadFileCount < 1
                    error('ZouLab:DmdCalibrationGridFilesMissing', ...
                        'No BMP calibration-grid files were found in %s.', folder);
                end
                gridInfo = imfinfo(fullfile(folder, files(1).name));
                if gridInfo.Width ~= zoulab.DmdCalibration.DmdWidth || ...
                        gridInfo.Height ~= zoulab.DmdCalibration.DmdHeight
                    error('ZouLab:DmdCalibrationGridImageSizeInvalid', ...
                        ['Calibration grid BMPs must be %dx%d; %s is %dx%d.'], ...
                        zoulab.DmdCalibration.DmdWidth, ...
                        zoulab.DmdCalibration.DmdHeight, files(1).name, ...
                        gridInfo.Width, gridInfo.Height);
                end
                binaryFrameCount = uploadFileCount * 8;
                app.DmdController.loadPatternFolder(folder, ...
                    uploadFileCount, 1, app.Logger, 1, ...
                    binaryFrameCount, 8);
                countFlag = double(string( ...
                    app.DmdPictureCountActionDropDown.Value) == "Write");
                app.DmdController.setParameters1( ...
                    round(app.DmdInternalRateField.Value), 8, ...
                    binaryFrameCount, countFlag, app.Logger);
                app.sendDmdDeviceParametersToHardware(false);
                app.DmdController.playInternal(true, app.Logger);
                app.DmdOperationalPatternLoaded = false;
                app.DmdCompiledManifest = struct();
                app.DmdLamp.Color = [0.10 0.75 0.20];
                app.DmdPatternSummaryLabel.Text = sprintf( ...
                    'Calibration grid | Files %d | 8-bit | Binary %d | Internal loop', ...
                    uploadFileCount, binaryFrameCount);
                app.finishAction('PROJECT_DMD_CALIBRATION_GRID', true, ...
                    sprintf(['Projecting %s for Camera %d. Source=%s. ', ...
                    'Use Fresh Snap or Latest Preview, then select 3 points.'], ...
                    string(app.DmdGridModeDropDown.Value), cameraIndex, folder), ...
                    app.DmdCalibrationStatusLabel);
            catch ME
                app.handleError('DMD_CALIBRATION_GRID_PROJECTION_FAILED', ...
                    ME, app.DmdCalibrationStatusLabel);
            end
        end

        function saveDmdCalibrationPreview(app)
            cameraIndex = app.selectedDmdCalibrationCamera();
            app.beginAction('SAVE_DMD_CALIBRATION_PREVIEW', ...
                sprintf('Capturing Camera %d source for DMD calibration...', ...
                cameraIndex), app.DmdCalibrationStatusLabel);
            try
                app.requireIdentity('save DMD calibration preview');
                sourceMode = string(app.DmdCalibrationSourceDropDown.Value);
                if sourceMode == "Load TIFF"
                    app.chooseDmdCalibrationTiff();
                    return;
                elseif sourceMode == "Latest Preview"
                    frame = app.LatestFrames{cameraIndex};
                    if isempty(frame)
                        error('ZouLab:DmdCalibrationPreviewUnavailable', ...
                            ['Camera %d has no latest preview frame. Start Preview ', ...
                             'or choose Fresh Snap.'], cameraIndex);
                    end
                else
                    if ~app.confirmAndApplyPendingCameraSettings( ...
                            cameraIndex, 'DMD Calibration Fresh Snap', ...
                            app.DmdCalibrationStatusLabel)
                        app.finishAction('SAVE_DMD_CALIBRATION_PREVIEW', ...
                            false, ['Fresh Snap cancelled; camera settings ', ...
                            'remain Pending.'], ...
                            app.DmdCalibrationStatusLabel);
                        return;
                    end
                    frames = app.captureCameras(cameraIndex, ...
                        'dmd_calibration_snap', true, 'unchanged');
                    frame = frames{cameraIndex};
                end
                if ~isa(frame, 'uint16')
                    error('ZouLab:DmdCalibrationFrameClass', ...
                        'Calibration frame must be raw uint16.');
                end
                folder = app.currentDmdCameraCalibrationFolder();
                stamp = char(datetime('now', 'Format', ...
                    'yyyyMMdd_HHmmss_SSS'));
                filePath = fullfile(folder, sprintf( ...
                    'calibration_cam%d_%s.tif', cameraIndex, stamp));
                imwrite(frame, filePath, 'tif', 'Compression', 'none');
                app.DmdCalibrationTiffField.Value = filePath;
                app.LatestFrames{cameraIndex} = frame;
                if app.TransposeDisplay(cameraIndex)
                    app.ImageHandles{cameraIndex}.CData = frame.';
                else
                    app.ImageHandles{cameraIndex}.CData = frame;
                end
                app.Logger.log('SUCCESS', 'DMD_CALIBRATION_PREVIEW_SAVED', ...
                    ['Camera=%d | Source=%s | File=%s | RawClass=%s | Size=%s | ', ...
                     'RawTransposed=0 | DisplayTranspose=%d | ', ...
                     'ImagingLightStateModified=0'], cameraIndex, sourceMode, ...
                    filePath, class(frame), mat2str(size(frame)), ...
                    app.TransposeDisplay(cameraIndex));
                app.finishAction('SAVE_DMD_CALIBRATION_PREVIEW', true, ...
                    "Fresh camera Snap saved: " + string(filePath), ...
                    app.DmdCalibrationStatusLabel);
            catch ME
                app.handleError('DMD_CALIBRATION_PREVIEW_SAVE_FAILED', ...
                    ME, app.DmdCalibrationStatusLabel);
            end
        end

        function snapAndSolveDmdCalibration(app)
            previousFile = string(app.DmdCalibrationTiffField.Value);
            app.Logger.log('INFO', 'USER_DMD_CALIBRATION_SNAP_SOLVE_CLICKED', ...
                'Source=%s | PreviousFile=%s', ...
                app.DmdCalibrationSourceDropDown.Value, previousFile);
            app.saveDmdCalibrationPreview();
            currentFile = string(app.DmdCalibrationTiffField.Value);
            if isfile(currentFile) && ...
                    (currentFile ~= previousFile || ...
                     string(app.DmdCalibrationSourceDropDown.Value) == "Load TIFF")
                app.solveDmdCalibration();
            else
                app.Logger.log('WARNING', ...
                    'DMD_CALIBRATION_SNAP_SOLVE_NOT_STARTED', ...
                    'Reason=source_capture_or_selection_not_completed');
            end
        end

        function chooseDmdCalibrationTiff(app)
            app.beginAction('CHOOSE_DMD_CALIBRATION_TIFF', ...
                'Waiting for projected-grid TIFF...', ...
                app.DmdCalibrationStatusLabel);
            startFolder = app.currentDmdCameraCalibrationFolder();
            [file, folder] = uigetfile({'*.tif;*.tiff','TIFF image'}, ...
                'Choose projected DMD-grid image', char(startFolder));
            if isequal(file, 0)
                app.finishAction('CHOOSE_DMD_CALIBRATION_TIFF', false, ...
                    'Calibration TIFF selection cancelled.', ...
                    app.DmdCalibrationStatusLabel);
                return;
            end
            previous = app.DmdCalibrationTiffField.Value;
            app.DmdCalibrationTiffField.Value = fullfile(folder, file);
            app.Logger.log('SUCCESS', 'DMD_CALIBRATION_TIFF_SELECTED', ...
                'Previous=%s | New=%s', previous, ...
                app.DmdCalibrationTiffField.Value);
            app.finishAction('CHOOSE_DMD_CALIBRATION_TIFF', true, ...
                "Selected: " + string(file), app.DmdCalibrationStatusLabel);
        end

        function solveDmdCalibration(app)
            cameraIndex = app.selectedDmdCalibrationCamera();
            app.beginAction('SOLVE_DMD_CALIBRATION', ...
                sprintf('Selecting three Camera %d grid intersections...', ...
                cameraIndex), app.DmdCalibrationStatusLabel);
            pointHandles = gobjects(0);
            wasPreview = false;
            try
                app.requireIdentity('solve DMD calibration');
                filePath = string(app.DmdCalibrationTiffField.Value);
                if ~isfile(filePath)
                    error('ZouLab:DmdCalibrationTiffMissing', ...
                        'Save or choose a projected-grid TIFF first.');
                end
                rawImage = imread(filePath, 1);
                if app.TransposeDisplay(cameraIndex)
                    displayImage = rawImage.';
                else
                    displayImage = rawImage;
                end
                wasPreview = app.PreviewActive(cameraIndex);
                if wasPreview
                    app.stopCameraPreview(cameraIndex, ...
                        'dmd_calibration_point_selection');
                end
                axesHandle = app.CameraAxes{cameraIndex};
                app.ImageHandles{cameraIndex}.CData = displayImage;
                axis(axesHandle, 'image');
                axesHandle.Colormap = gray(256);
                title(axesHandle, sprintf( ...
                    'DMD calibration Cam%d: select 3 grid intersections', ...
                    cameraIndex));
                displayPoints = zeros(3, 2);
                selectedNumbers = zeros(3, 1);
                if isempty(app.DmdCalibrationSelectionProvider)
                    for pointIndex = 1:3
                        app.DmdCalibrationStatusLabel.Text = sprintf( ...
                            'Select point %d/3 on Camera %d preview.', ...
                            pointIndex, cameraIndex);
                        drawnow;
                        point = drawpoint(axesHandle, 'Color', 'red', ...
                            'Label', sprintf('%d', pointIndex));
                        wait(point);
                        if ~isvalid(point)
                            error('ZouLab:DmdCalibrationSelectionCancelled', ...
                                'Point selection was cancelled.');
                        end
                        position = double(point.Position);
                        if numel(position) ~= 2 || any(~isfinite(position))
                            error('ZouLab:DmdCalibrationSelectionInvalid', ...
                                ['The selected point did not provide a valid ', ...
                                 '[x y] position.']);
                        end
                        pointHandles(end + 1) = point; %#ok<AGROW>
                        answer = inputdlg(sprintf( ...
                            'Printed grid number for point %d:', pointIndex), ...
                            'DMD Grid Number', [1 36], {'1'});
                        if isempty(answer)
                            error('ZouLab:DmdCalibrationSelectionCancelled', ...
                                'Grid-number entry was cancelled.');
                        end
                        number = str2double(answer{1});
                        if ~isfinite(number) || number ~= round(number)
                            error('ZouLab:DmdCalibrationLabelInvalid', ...
                                'Grid number must be an integer from 1 to 72.');
                        end
                        displayPoints(pointIndex, :) = position;
                        selectedNumbers(pointIndex) = number;
                        point.Label = sprintf('Grid %d', number);
                        app.Logger.log('INFO', ...
                            'USER_DMD_CALIBRATION_POINT_SELECTED', ...
                            ['Camera=%d | Point=%d | DisplayXY=%s | ', ...
                             'GridNumber=%d | DisplayTranspose=%d'], ...
                            cameraIndex, pointIndex, mat2str(position, 9), ...
                            number, app.TransposeDisplay(cameraIndex));
                    end
                else
                    selection = app.DmdCalibrationSelectionProvider( ...
                        cameraIndex, axesHandle, displayImage);
                    if ~isstruct(selection) || ...
                            ~isfield(selection, 'display_points') || ...
                            ~isfield(selection, 'grid_numbers')
                        error('ZouLab:DmdCalibrationTestProviderInvalid', ...
                            ['Diagnostic selection provider must return ', ...
                             'display_points and grid_numbers.']);
                    end
                    displayPoints = double(selection.display_points);
                    selectedNumbers = double(selection.grid_numbers(:));
                    validateattributes(displayPoints, {'numeric'}, ...
                        {'size',[3 2],'finite','real'});
                    validateattributes(selectedNumbers, {'numeric'}, ...
                        {'size',[3 1],'integer','>=',1,'<=',72,'finite'});
                    diagnosticPoints = line('Parent', axesHandle, ...
                        'XData', displayPoints(:,1), ...
                        'YData', displayPoints(:,2), ...
                        'LineStyle', 'none', 'Marker', 'o', ...
                        'Color', 'red', 'Tag', ...
                        'DmdCalibrationDiagnosticPoints');
                    pointHandles(end + 1) = diagnosticPoints;
                    app.Logger.log('INFO', ...
                        'DMD_CALIBRATION_DIAGNOSTIC_INPUT_INJECTED', ...
                        ['Camera=%d | DisplayPoints=%s | GridNumbers=%s | ', ...
                         'UserMouseClicksSimulated=0'], cameraIndex, ...
                        mat2str(displayPoints, 9), ...
                        mat2str(selectedNumbers.'));
                end
                folder = app.currentDmdCameraCalibrationFolder();
                serial = string(app.Cameras.Serials(cameraIndex));
                if cameraIndex == 1
                    bus = 'USB3';
                    orientation = 'standard';
                else
                    bus = 'CXP frame grabber';
                    orientation = 'flipped';
                end
                cameraInfo = struct('camera_index', cameraIndex, ...
                    'serial', char(serial), 'bus', bus, ...
                    'roi', double(app.Cameras.ROIs{cameraIndex}), ...
                    'bin', double(app.Cameras.Bins(cameraIndex)), ...
                    'transpose_display', ...
                        logical(app.TransposeDisplay(cameraIndex)));
                calibration = zoulab.DmdCalibration.solveWithGeometry( ...
                    displayPoints, selectedNumbers, cameraInfo, ...
                    orientation, filePath);
                overlayPath = fullfile(folder, '1_selected_Points.png');
                exportgraphics(axesHandle, overlayPath, 'Resolution', 150);
                matrixPath = fullfile(folder, '1_Matrix parameters.mat');
                zoulab.DmdCalibration.saveCalibration(matrixPath, ...
                    calibration, rawImage, app.Logger);
                app.DmdCalibrationData = calibration;
                app.DmdCalibrationMatrixField.Value = matrixPath;
                app.DmdCalibrationLamp.Color = [0.10 0.75 0.20];
                app.finishAction('SOLVE_DMD_CALIBRATION', true, ...
                    sprintf('CALIBRATED — Camera %d, %s grid, T saved.', ...
                    cameraIndex, calibration.grid_orientation), ...
                    app.DmdCalibrationStatusLabel);
                app.persistUserSettings('dmd_calibration_solved');
            catch ME
                app.DmdCalibrationLamp.Color = [0.85 0.15 0.12];
                app.handleError('DMD_CALIBRATION_SOLVE_FAILED', ...
                    ME, app.DmdCalibrationStatusLabel);
            end
            for index = 1:numel(pointHandles)
                if isvalid(pointHandles(index))
                    delete(pointHandles(index));
                end
            end
            title(app.CameraAxes{cameraIndex}, '');
            if wasPreview && ~app.RunState.Closing
                try
                    app.startCameraPreview(cameraIndex, ...
                        'dmd_calibration_selection_complete');
                catch ME
                    app.Logger.logException( ...
                        'DMD_CALIBRATION_PREVIEW_RESTART_FAILED', ME);
                end
            end
        end

        function loadDmdCalibration(app)
            cameraIndex = app.selectedDmdCalibrationCamera();
            app.beginAction('LOAD_DMD_CALIBRATION', ...
                sprintf('Loading Camera %d calibration matrix...', cameraIndex), ...
                app.DmdCalibrationStatusLabel);
            try
                app.requireIdentity('load DMD calibration');
                startFolder = app.currentDmdCameraCalibrationFolder();
                [file, folder] = uigetfile('*.mat', ...
                    'Choose 1_Matrix parameters.mat', char(startFolder));
                if isequal(file, 0)
                    app.finishAction('LOAD_DMD_CALIBRATION', false, ...
                        'Calibration load cancelled.', ...
                        app.DmdCalibrationStatusLabel);
                    return;
                end
                filePath = fullfile(folder, file);
                calibration = zoulab.DmdCalibration.loadCalibration( ...
                    filePath, cameraIndex);
                cameraInfo = struct('camera_index', cameraIndex, ...
                    'serial', char(app.Cameras.Serials(cameraIndex)), ...
                    'roi', double(app.Cameras.ROIs{cameraIndex}), ...
                    'bin', double(app.Cameras.Bins(cameraIndex)), ...
                    'transpose_display', ...
                        logical(app.TransposeDisplay(cameraIndex)));
                compatibility = zoulab.DmdCalibration.compatibility( ...
                    calibration, cameraInfo);
                if ~compatibility.compatible
                    error('ZouLab:DmdCalibrationIncompatible', '%s', ...
                        compatibility.message);
                end
                app.DmdCalibrationData = calibration;
                app.DmdCalibrationMatrixField.Value = filePath;
                app.DmdCalibrationLamp.Color = [0.10 0.75 0.20];
                app.Logger.log('SUCCESS', 'DMD_CALIBRATION_LOADED', ...
                    ['File=%s | Camera=%d | Schema=%s | T=%s | ', ...
                     'Compatible=%d | Verified=%d | Legacy=%d | Message=%s'], ...
                    filePath, cameraIndex, ...
                    calibration.schema_version, mat2str(calibration.T, 9), ...
                    compatibility.compatible, compatibility.verified, ...
                    compatibility.legacy, compatibility.message);
                app.finishAction('LOAD_DMD_CALIBRATION', true, ...
                    sprintf('CALIBRATED — Camera %d loaded (%s).', ...
                    cameraIndex, compatibility.message), ...
                    app.DmdCalibrationStatusLabel);
                app.persistUserSettings('dmd_calibration_loaded');
            catch ME
                app.DmdCalibrationLamp.Color = [0.85 0.15 0.12];
                app.handleError('DMD_CALIBRATION_LOAD_FAILED', ...
                    ME, app.DmdCalibrationStatusLabel);
            end
        end

        function requireDmdCalibration(app)
            cameraIndex = app.selectedDmdCalibrationCamera();
            zoulab.DmdCalibration.validateCalibration( ...
                app.DmdCalibrationData, cameraIndex);
        end

        function info = currentDmdCameraInfo(app)
            cameraIndex = app.selectedDmdCalibrationCamera();
            if cameraIndex == 1
                bus = 'USB3';
            else
                bus = 'CXP frame grabber';
            end
            info = struct('camera_index', cameraIndex, ...
                'serial', char(app.Cameras.Serials(cameraIndex)), ...
                'bus', bus, 'roi', double(app.Cameras.ROIs{cameraIndex}), ...
                'bin', double(app.Cameras.Bins(cameraIndex)), ...
                'transpose_display', logical(app.TransposeDisplay(cameraIndex)));
        end

        function dmdMaskModeChanged(app, previousValue, newValue)
            thresholdMode = string(newValue) == "Threshold";
            app.DmdMaskThresholdField.Enable = app.onOff(thresholdMode);
            app.DmdMaskMinAreaField.Enable = app.onOff(thresholdMode);
            app.DmdMaskExpansionField.Enable = app.onOff(thresholdMode);
            app.DmdMaskData = struct();
            app.DmdCompiledManifest = struct();
            app.setDmdPatternState('NOT_LOADED', ...
                'Mask mode changed — generate and load a new pattern.');
            app.DmdMaskStatusLabel.Text = ...
                'Mode changed; generate a new DMD mask.';
            app.Logger.log('INFO', 'USER_DMD_MASK_MODE_CHANGED', ...
                'Previous=%s | New=%s | ExistingMaskCleared=1', ...
                string(previousValue), string(newValue));
        end

        function dmdMaskSettingEdited(app, settingName, previousValue, newValue)
            if app.LightStimulusController.Armed
                app.disarmLightStimulus("dmd_mask_setting_changed");
            end
            app.DmdMaskData = struct();
            app.DmdCompiledManifest = struct();
            app.setDmdPatternState('NOT_LOADED', ...
                'Mask setting changed — generate and load a new pattern.');
            app.DmdMaskStatusLabel.Text = ...
                'Mask setting changed; generate and load a new pattern.';
            app.DmdPatternSummaryLabel.Text = 'Pattern invalidated by mask edit.';
            app.DmdInsertOffBetweenRoisCheckBox.Enable = app.onOff( ...
                app.IdentityConfirmed && app.DmdMaskEachRoiCheckBox.Value && ...
                ~app.RunState.AcquisitionRunning);
            app.Logger.log('INFO', 'USER_DMD_MASK_SETTING_CHANGED', ...
                ['Setting=%s | Previous=%s | New=%s | ExistingMaskCleared=1 | ', ...
                 'CompiledManifestCleared=1 | LightStimulusDisarmed=1 | ', ...
                 'HardwarePatternUnchangedUntilNextLoad=1'], ...
                string(settingName), string(previousValue), string(newValue));
        end

        function snapDmdMaskSource(app)
            cameraIndex = app.selectedDmdCalibrationCamera();
            app.beginAction('SNAP_DMD_MASK_SOURCE', sprintf( ...
                'Capturing fresh Camera %d DMD-mask source...', cameraIndex), ...
                app.DmdMaskStatusLabel);
            try
                app.requireDmdCalibration();
                if ~app.confirmAndApplyPendingCameraSettings( ...
                        cameraIndex, 'DMD Mask Source Snap', ...
                        app.DmdMaskStatusLabel)
                    app.finishAction('SNAP_DMD_MASK_SOURCE', false, ...
                        ['DMD mask Snap cancelled; camera settings remain ', ...
                         'Pending.'], app.DmdMaskStatusLabel);
                    return;
                end
                frames = app.captureCameras(cameraIndex, ...
                    'dmd_mask_source_snap', true, 'unchanged');
                frame = frames{cameraIndex};
                folder = app.currentDmdCameraCalibrationFolder();
                stamp = char(datetime('now', 'Format', ...
                    'yyyyMMdd_HHmmss_SSS'));
                pathText = fullfile(folder, sprintf( ...
                    'mask_source_cam%d_%s.tif', cameraIndex, stamp));
                imwrite(frame, pathText, 'tif', 'Compression', 'none');
                app.DmdMaskSourceField.Value = pathText;
                app.DmdMaskData = struct();
                app.DmdCompiledManifest = struct();
                app.setDmdPatternState('NOT_LOADED', ...
                    'New Snap source captured — generate and load a mask.');
                app.LatestFrames{cameraIndex} = frame;
                if app.TransposeDisplay(cameraIndex)
                    app.ImageHandles{cameraIndex}.CData = frame.';
                else
                    app.ImageHandles{cameraIndex}.CData = frame;
                end
                app.Logger.log('SUCCESS', 'DMD_MASK_SOURCE_SNAP_SAVED', ...
                    ['Camera=%d | File=%s | Class=%s | Size=%s | ', ...
                     'RawTransposed=0 | ImagingLightStateModified=0'], ...
                    cameraIndex, pathText, ...
                    class(frame), mat2str(size(frame)));
                app.finishAction('SNAP_DMD_MASK_SOURCE', true, ...
                    "Mask source: " + string(pathText), ...
                    app.DmdMaskStatusLabel);
            catch ME
                app.handleError('DMD_MASK_SOURCE_SNAP_FAILED', ME, ...
                    app.DmdMaskStatusLabel);
            end
        end

        function loadDmdMaskSource(app)
            app.beginAction('LOAD_DMD_MASK_SOURCE', ...
                'Choose a camera-space TIFF for DMD mask generation...', ...
                app.DmdMaskStatusLabel);
            startFolder = app.currentDmdCameraCalibrationFolder();
            [file, folder] = uigetfile({'*.tif;*.tiff','TIFF image'}, ...
                'Load DMD mask source', char(startFolder));
            if isequal(file, 0)
                app.finishAction('LOAD_DMD_MASK_SOURCE', false, ...
                    'Mask-source selection cancelled.', app.DmdMaskStatusLabel);
                return;
            end
            pathText = fullfile(folder, file);
            frame = imread(pathText, 1);
            app.DmdMaskSourceField.Value = pathText;
            app.DmdMaskData = struct();
            app.DmdCompiledManifest = struct();
            app.setDmdPatternState('NOT_LOADED', ...
                'New TIFF source selected — generate and load a mask.');
            cameraIndex = app.selectedDmdCalibrationCamera();
            app.LatestFrames{cameraIndex} = uint16(frame);
            if app.TransposeDisplay(cameraIndex)
                app.ImageHandles{cameraIndex}.CData = frame.';
            else
                app.ImageHandles{cameraIndex}.CData = frame;
            end
            app.Logger.log('SUCCESS', 'DMD_MASK_SOURCE_TIFF_LOADED', ...
                'Camera=%d | File=%s | Size=%s', cameraIndex, ...
                pathText, mat2str(size(frame)));
            app.finishAction('LOAD_DMD_MASK_SOURCE', true, ...
                "Mask source: " + string(pathText), app.DmdMaskStatusLabel);
        end

        function generateDmdMask(app)
            mode = string(app.DmdMaskModeDropDown.Value);
            cameraIndex = app.selectedDmdCalibrationCamera();
            app.beginAction('GENERATE_DMD_MASK', ...
                sprintf('Generating %s mask for Camera %d...', mode, cameraIndex), ...
                app.DmdMaskStatusLabel);
            try
                app.requireDmdCalibration();
                sourcePath = string(app.DmdMaskSourceField.Value);
                if ~isfile(sourcePath)
                    error('ZouLab:DmdMaskSourceRequired', ...
                        'Capture or load a camera-space TIFF first.');
                end
                frame = imread(sourcePath, 1);
                outputFolder = fullfile(fileparts(sourcePath), ...
                    string(erase(filepartsWithName(sourcePath), '.tif')) + ...
                    "_dmd_masks");
                if ~isfolder(outputFolder)
                    mkdir(outputFolder);
                end
                switch mode
                    case "Manual"
                        app.beginDmdManualMask(frame, sourcePath, ...
                            outputFolder, cameraIndex);
                        return;
                    case "Threshold"
                        source = zoulab.DmdMaskGenerator.fromThreshold(frame, ...
                            app.DmdMaskThresholdField.Value, ...
                            app.DmdMaskMinAreaField.Value, ...
                            app.DmdMaskExpansionField.Value);
                    case "Fiji ROI"
                        roiFolder = uigetdir(fileparts(sourcePath), ...
                            'Choose unzipped Fiji ROI folder');
                        if isequal(roiFolder, 0)
                            error('ZouLab:DmdFijiSelectionCancelled', ...
                                'Fiji ROI folder selection was cancelled.');
                        end
                        toolsFolder = fullfile(fileparts(app.AppRoot), 'Tools');
                        oldPath = path;
                        pathCleanup = onCleanup(@() path(oldPath));
                        addpath(toolsFolder);
                        source = zoulab.DmdMaskGenerator.fromFiji( ...
                            roiFolder, size(frame), outputFolder);
                        clear pathCleanup;
                    case "Cellpose"
                        answer = inputdlg({'Diameter','Gamma', ...
                            'Cell threshold','Flow threshold'}, ...
                            'Cellpose DMD mask', [1 32], ...
                            {'15','1','0','0.4'});
                        if isempty(answer)
                            error('ZouLab:DmdCellposeCancelled', ...
                                'Cellpose parameter entry was cancelled.');
                        end
                        source = zoulab.DmdMaskGenerator.fromCellpose(frame, ...
                            str2double(answer{1}), str2double(answer{2}), ...
                            str2double(answer{3}), str2double(answer{4}));
                    otherwise
                        error('ZouLab:DmdMaskModeInvalid', ...
                            'Unknown DMD mask mode %s.', mode);
                end
                app.finalizeDmdMask(source, mode, sourcePath, ...
                    outputFolder, cameraIndex);
            catch ME
                app.handleError('DMD_MASK_GENERATION_FAILED', ME, ...
                    app.DmdMaskStatusLabel);
            end

            function name = filepartsWithName(pathText)
                [~, name] = fileparts(pathText);
            end
        end

        function beginDmdManualMask(app, frame, sourcePath, outputFolder, cameraIndex)
            if app.DmdManualMaskActive
                error('ZouLab:DmdManualMaskAlreadyActive', ...
                    'Finish or cancel the active manual-mask selection first.');
            end
            app.DmdManualMaskActive = true;
            app.DmdManualMaskCameraIndex = cameraIndex;
            app.DmdManualMaskFrame = uint16(frame);
            app.DmdManualMaskSourcePath = string(sourcePath);
            app.DmdManualMaskOutputFolder = string(outputFolder);
            app.DmdManualMaskPolygons = {};
            app.DmdManualMaskCurrentVertices = zeros(0, 2);
            app.DmdManualMaskOverlays = {};
            displayFrame = frame;
            if app.TransposeDisplay(cameraIndex)
                displayFrame = frame.';
            end
            app.ImageHandles{cameraIndex}.CData = displayFrame;
            app.DmdManualMaskPreviousFigureKeyPressFcn = ...
                app.UIFigure.WindowKeyPressFcn;
            app.DmdManualMaskPreviousPointer = string(app.UIFigure.Pointer);
            app.DmdManualMaskPreviousImageButtonDownFcn = ...
                app.ImageHandles{cameraIndex}.ButtonDownFcn;
            app.DmdManualMaskPreviousAxesButtonDownFcn = ...
                app.CameraAxes{cameraIndex}.ButtonDownFcn;
            app.UIFigure.WindowKeyPressFcn = ...
                @(source,event) app.dmdManualMaskKeyPressed(source, event);
            app.UIFigure.Pointer = 'crosshair';
            app.ImageHandles{cameraIndex}.ButtonDownFcn = ...
                @(~,event) app.dmdManualMaskClicked(event);
            app.CameraAxes{cameraIndex}.ButtonDownFcn = ...
                @(~,event) app.dmdManualMaskClicked(event);
            app.DmdMaskGenerateButton.Enable = 'off';
            app.updateDmdManualMaskInstructions();
            app.Logger.log('SUCCESS', 'DMD_MANUAL_MASK_SELECTION_READY', ...
                ['Camera=%d | Source=%s | DisplayFrozenOnSnap=1 | ', ...
                 'NextRoiKey=space | FinishKey=return | UndoKey=r | ', ...
                 'CancelKey=escape | DisplayTranspose=%d'], ...
                cameraIndex, sourcePath, app.TransposeDisplay(cameraIndex));
            try
                focus(app.CameraAxes{cameraIndex});
            catch
            end
        end

        function dmdManualMaskClicked(app, event)
            if ~app.DmdManualMaskActive
                return;
            end
            cameraIndex = app.DmdManualMaskCameraIndex;
            point = app.manualRegistrationEventPoint(cameraIndex, event);
            imageSize = size(app.ImageHandles{cameraIndex}.CData);
            if any(~isfinite(point)) || point(1) < 0.5 || ...
                    point(1) > imageSize(2) + 0.5 || point(2) < 0.5 || ...
                    point(2) > imageSize(1) + 0.5
                app.Logger.log('WARNING', 'DMD_MANUAL_MASK_CLICK_OUTSIDE_IMAGE', ...
                    'Camera=%d | DisplayXY=%s', cameraIndex, mat2str(point));
                app.setStatus('Manual DMD mask: click inside the frozen Snap image.');
                return;
            end
            app.DmdManualMaskCurrentVertices(end + 1, :) = point;
            app.updateDmdManualMaskOverlay();
            app.Logger.log('INFO', 'USER_DMD_MANUAL_MASK_VERTEX_ADDED', ...
                'Camera=%d | ROI=%d | Vertex=%d | DisplayXY=%s', ...
                cameraIndex, numel(app.DmdManualMaskPolygons) + 1, ...
                size(app.DmdManualMaskCurrentVertices, 1), mat2str(point, 6));
            app.updateDmdManualMaskInstructions();
        end

        function dmdManualMaskKeyPressed(app, ~, event)
            if ~app.DmdManualMaskActive
                return;
            end
            key = lower(string(event.Key));
            if ~any(key == ["space","return","enter","r","escape"])
                return;
            end
            app.Logger.log('INFO', 'USER_DMD_MANUAL_MASK_KEY_PRESSED', ...
                'Key=%s | CompletedRois=%d | CurrentVertices=%d', key, ...
                numel(app.DmdManualMaskPolygons), ...
                size(app.DmdManualMaskCurrentVertices, 1));
            switch key
                case "space"
                    app.commitCurrentDmdManualPolygon(false);
                case {"return","enter"}
                    app.commitCurrentDmdManualPolygon(true);
                case "r"
                    if ~isempty(app.DmdManualMaskCurrentVertices)
                        removed = app.DmdManualMaskCurrentVertices(end, :);
                        app.DmdManualMaskCurrentVertices(end, :) = [];
                        app.Logger.log('INFO', ...
                            'USER_DMD_MANUAL_MASK_VERTEX_REMOVED', ...
                            'DisplayXY=%s | RemainingVertices=%d', ...
                            mat2str(removed, 6), ...
                            size(app.DmdManualMaskCurrentVertices, 1));
                    elseif ~isempty(app.DmdManualMaskPolygons)
                        removed = app.DmdManualMaskPolygons{end};
                        app.DmdManualMaskPolygons(end) = [];
                        app.Logger.log('INFO', ...
                            'USER_DMD_MANUAL_MASK_ROI_REMOVED', ...
                            'RemovedVertices=%d | RemainingRois=%d', ...
                            size(removed, 1), numel(app.DmdManualMaskPolygons));
                    else
                        app.Logger.log('INFO', ...
                            'DMD_MANUAL_MASK_UNDO_IGNORED_EMPTY', 'NothingToUndo=1');
                    end
                    app.updateDmdManualMaskOverlay();
                    app.updateDmdManualMaskInstructions();
                case "escape"
                    app.cancelDmdManualMask('escape_key');
            end
        end

        function commitCurrentDmdManualPolygon(app, finishAll)
            vertices = app.DmdManualMaskCurrentVertices;
            if ~isempty(vertices)
                if size(vertices, 1) < 3 || ...
                        abs(polyarea(vertices(:, 1), vertices(:, 2))) < eps
                    message = 'Current ROI needs at least 3 non-collinear points.';
                    app.DmdMaskStatusLabel.Text = message;
                    app.DmdMaskStatusLabel.FontColor = [0.78 0.18 0.12];
                    app.Logger.log('WARNING', ...
                        'DMD_MANUAL_MASK_ROI_NOT_CONFIRMED', ...
                        'Vertices=%d | FinishRequested=%d', ...
                        size(vertices, 1), finishAll);
                    return;
                end
                app.DmdManualMaskPolygons{end + 1} = vertices;
                app.DmdManualMaskCurrentVertices = zeros(0, 2);
                app.Logger.log('SUCCESS', 'USER_DMD_MANUAL_ROI_COMPLETED', ...
                    'Camera=%d | ROI=%d | Vertices=%d | DisplayTranspose=%d', ...
                    app.DmdManualMaskCameraIndex, ...
                    numel(app.DmdManualMaskPolygons), size(vertices, 1), ...
                    app.TransposeDisplay(app.DmdManualMaskCameraIndex));
                app.updateDmdManualMaskOverlay();
            elseif ~finishAll
                app.DmdMaskStatusLabel.Text = ...
                    'Click at least 3 points before Space starts the next ROI.';
                return;
            end
            if finishAll
                if isempty(app.DmdManualMaskPolygons)
                    app.DmdMaskStatusLabel.Text = ...
                        'At least one ROI is required before Enter can finish.';
                    return;
                end
                app.completeDmdManualMask();
            else
                app.updateDmdManualMaskInstructions();
            end
        end

        function updateDmdManualMaskOverlay(app)
            for index = 1:numel(app.DmdManualMaskOverlays)
                if isgraphics(app.DmdManualMaskOverlays{index})
                    delete(app.DmdManualMaskOverlays{index});
                end
            end
            app.DmdManualMaskOverlays = {};
            polygons = app.DmdManualMaskPolygons;
            if ~isempty(app.DmdManualMaskCurrentVertices)
                polygons{end + 1} = app.DmdManualMaskCurrentVertices;
            end
            cameraIndex = app.DmdManualMaskCameraIndex;
            for index = 1:numel(polygons)
                vertices = polygons{index};
                plotted = vertices;
                if size(vertices, 1) >= 3
                    plotted(end + 1, :) = vertices(1, :);
                end
                overlay = line('Parent', app.CameraAxes{cameraIndex}, ...
                    'XData', plotted(:, 1), 'YData', plotted(:, 2), ...
                    'Color', [1 0.25 0.05], 'LineWidth', 2, ...
                    'Marker', 'o', 'MarkerSize', 5, ...
                    'HitTest', 'off', 'PickableParts', 'none', ...
                    'Tag', sprintf('DmdManualMaskRoi%d', index));
                app.DmdManualMaskOverlays{end + 1} = overlay;
            end
        end

        function updateDmdManualMaskInstructions(app)
            if ~app.DmdManualMaskActive
                return;
            end
            roiIndex = numel(app.DmdManualMaskPolygons) + 1;
            pointCount = size(app.DmdManualMaskCurrentVertices, 1);
            message = sprintf([ ...
                'Manual ROI %d: click points on frozen Snap | Space: next ROI | ', ...
                'Enter: finish | R: undo | Esc: cancel (%d points)'], ...
                roiIndex, pointCount);
            app.DmdMaskStatusLabel.Text = message;
            app.DmdMaskStatusLabel.FontColor = [0.80 0.48 0.05];
            app.setStatus(message);
            app.setCameraStatus(app.DmdManualMaskCameraIndex, ...
                'DMD manual mask: Snap frozen; follow the keyboard guide.', 'working');
        end

        function completeDmdManualMask(app)
            cameraIndex = app.DmdManualMaskCameraIndex;
            displayPolygons = app.DmdManualMaskPolygons;
            rawPolygons = displayPolygons;
            if app.TransposeDisplay(cameraIndex)
                for index = 1:numel(rawPolygons)
                    rawPolygons{index} = rawPolygons{index}(:, [2 1]);
                end
            end
            frame = app.DmdManualMaskFrame;
            sourcePath = app.DmdManualMaskSourcePath;
            outputFolder = app.DmdManualMaskOutputFolder;
            try
                source = zoulab.DmdMaskGenerator.fromManualPolygons( ...
                    size(frame), rawPolygons);
                app.cleanupDmdManualMaskInteraction('completed');
                app.finalizeDmdMask(source, "Manual", sourcePath, ...
                    outputFolder, cameraIndex);
            catch ME
                app.cleanupDmdManualMaskInteraction('completion_failed');
                app.handleError('DMD_MASK_GENERATION_FAILED', ME, ...
                    app.DmdMaskStatusLabel);
            end
        end

        function cancelDmdManualMask(app, source)
            if ~app.DmdManualMaskActive
                return;
            end
            app.Logger.log('INFO', 'USER_DMD_MANUAL_MASK_CANCELLED', ...
                'Source=%s | CompletedRois=%d | CurrentVertices=%d', ...
                source, numel(app.DmdManualMaskPolygons), ...
                size(app.DmdManualMaskCurrentVertices, 1));
            app.cleanupDmdManualMaskInteraction("cancelled_" + string(source));
            app.finishAction('GENERATE_DMD_MASK', false, ...
                'Manual DMD mask cancelled; no mask files were changed.', ...
                app.DmdMaskStatusLabel);
        end

        function cleanupDmdManualMaskInteraction(app, reason)
            if ~app.DmdManualMaskActive
                return;
            end
            for index = 1:numel(app.DmdManualMaskOverlays)
                if isgraphics(app.DmdManualMaskOverlays{index})
                    delete(app.DmdManualMaskOverlays{index});
                end
            end
            cameraIndex = app.DmdManualMaskCameraIndex;
            if cameraIndex >= 1 && cameraIndex <= 2
                app.ImageHandles{cameraIndex}.ButtonDownFcn = ...
                    app.DmdManualMaskPreviousImageButtonDownFcn;
                app.CameraAxes{cameraIndex}.ButtonDownFcn = ...
                    app.DmdManualMaskPreviousAxesButtonDownFcn;
            end
            app.UIFigure.WindowKeyPressFcn = ...
                app.DmdManualMaskPreviousFigureKeyPressFcn;
            app.UIFigure.Pointer = char(app.DmdManualMaskPreviousPointer);
            app.DmdMaskGenerateButton.Enable = app.onOff(app.IdentityConfirmed);
            app.DmdManualMaskActive = false;
            app.DmdManualMaskCameraIndex = 0;
            app.DmdManualMaskFrame = [];
            app.DmdManualMaskPolygons = {};
            app.DmdManualMaskCurrentVertices = zeros(0, 2);
            app.DmdManualMaskOverlays = {};
            app.Logger.log('INFO', 'DMD_MANUAL_MASK_INTERACTION_CLEANED', ...
                'Reason=%s | OverlaysCleared=1 | PreviewRenderUnfrozen=1', reason);
        end

        function finalizeDmdMask(app, source, mode, sourcePath, outputFolder, cameraIndex)
            if source.roi_count < 1
                error('ZouLab:DmdMaskNoRois', 'Mask generation found no ROI.');
            end
            mapped = zoulab.DmdMaskGenerator.mapToDmd(source, ...
                app.DmdCalibrationData, app.currentDmdCameraInfo());
            mapped.output_folder = char(outputFolder);
            mapped.source_file = char(sourcePath);
            mapped.save_each_roi = app.DmdMaskEachRoiCheckBox.Value;
            mapped.save_reverse = app.DmdMaskReverseCheckBox.Value;
            maskData = mapped; %#ok<NASGU>
            save(fullfile(outputFolder, 'dmd_masks.mat'), 'maskData', '-v7.3');
            imwrite(mapped.combined_dmd_mask, ...
                fullfile(outputFolder, 'combined_dmd.bmp'), 'bmp');
            eachFolder = fullfile(outputFolder, 'each_roi');
            if app.DmdMaskEachRoiCheckBox.Value
                if ~isfolder(eachFolder)
                    mkdir(eachFolder);
                end
                for index = 1:numel(mapped.each_dmd_mask)
                    imwrite(mapped.each_dmd_mask{index}, fullfile(eachFolder, ...
                        sprintf('roi_%03d.bmp', index)), 'bmp');
                end
            end
            if app.DmdMaskReverseCheckBox.Value
                imwrite(mapped.reverse_dmd_mask, ...
                    fullfile(outputFolder, 'reverse_dmd.bmp'), 'bmp');
            end
            app.DmdMaskData = mapped;
            app.DmdCompiledManifest = struct();
            app.setDmdPatternState('NOT_LOADED', ...
                'Mask changed — click Load Pattern before Play.');
            app.LightStimDmdPatternDropDown.Items = { ...
                'ALL OFF','ALL ON','Generated Combined', ...
                'Generated Reverse','Generated Each ROI','Folder'};
            app.LightStimDmdPatternDropDown.Value = 'Generated Combined';
            app.Logger.log('SUCCESS', 'DMD_MASK_GENERATED', ...
                ['Mode=%s | Camera=%d | Serial=%s | ROI=%s | Bin=%d | ', ...
                 'RoiCount=%d | EachRoiFiles=%d | Output=%s | ', ...
                 'FullSensorCoordinates=1'], mode, cameraIndex, ...
                app.Cameras.Serials(cameraIndex), ...
                mat2str(app.Cameras.ROIs{cameraIndex}), ...
                app.Cameras.Bins(cameraIndex), mapped.roi_count, ...
                app.DmdMaskEachRoiCheckBox.Value * mapped.roi_count, outputFolder);
            app.finishAction('GENERATE_DMD_MASK', true, sprintf( ...
                '%s mask ready: %d ROI(s); overlays cleared.', ...
                mode, mapped.roi_count), app.DmdMaskStatusLabel);
        end

        function pauseDmd(app)
            app.beginAction('PAUSE_DMD', 'Toggling internal DMD playback...', ...
                app.DmdStatusLabel);
            try
                app.requireIdentity('pause DMD');
                if string(app.DmdController.State) == "PAUSED_INTERNAL"
                    loopPlayback = string(app.LightStimDmdLoopSwitch.Value) == "Loop";
                    app.DmdController.playInternal(loopPlayback, app.Logger);
                    app.DmdLamp.Color = [0.10 0.75 0.20];
                    app.setDmdPatternState('PLAYING', ...
                        'Pattern PLAYING (internal).');
                    message = 'DMD internal playback resumed.';
                else
                    app.DmdController.pausePlayback(app.Logger);
                    app.DmdLamp.Color = [0.95 0.65 0.10];
                    app.setDmdPatternState('PAUSED', ...
                        'Pattern PAUSED; click Pause / Resume to continue.');
                    message = 'DMD internal playback paused.';
                end
                app.finishAction('PAUSE_DMD', true, message, app.DmdStatusLabel);
            catch ME
                app.handleError('DMD_PAUSE_UI_FAILED', ME, app.DmdStatusLabel);
            end
        end

        function dmdTriggerModeChanged(app, previousValue, newValue)
            app.Logger.log('INFO', 'USER_DMD_TRIGGER_MODE_CHANGED', ...
                ['Previous=%s | New=%s | HardwareCommandIssued=0 | ', ...
                 'ApplyOnNextPlay=1'], string(previousValue), string(newValue));
            app.updateLightStimulusFieldAvailability();
            app.persistUserSettings('dmd_trigger_mode_changed');
        end

        function dmdTriggerTableEdited(app, source, event)
            data = double(source.Data);
            previous = [];
            try
                previous = event.PreviousData;
            catch
            end
            try
                app.validateDmdTriggerTable(data);
                source.Data = data;
                app.dmdTriggerSequenceEdited('Table', previous, ...
                    mat2str(data, 6));
                app.Logger.log('INFO', ...
                    'DMD_TRIGGER_FRAME_COLUMN_SEMANTICS', ...
                    ['ExpectedFrameEditable=1 | HardwareAddressing=sequential | ', ...
                     'FrameColumnControlsHardwarePage=0 | StateColumnControlsDAQ=1 | ', ...
                     'Purpose=annotation_and_audit']);
            catch ME
                app.Logger.logException('DMD_TRIGGER_TABLE_EDIT_REJECTED', ME);
                app.DmdStatusLabel.Text = "Invalid IN1 table: " + string(ME.message);
                app.DmdStatusLabel.FontColor = [0.78 0.18 0.12];
            end
        end

        function rows = dmdTriggerRisingRows(~, data)
            data = double(data);
            if isempty(data) || size(data, 2) < 2
                rows = zeros(1, 0);
                return;
            end
            states = data(:, 2);
            rows = find(states == 1 & [true; states(1:end - 1) == 0]).';
        end

        function dmdTriggerGeneratorSettingEdited(app, settingName, ...
                previousValue, newValue)
            try
                period = double(app.DmdTriggerPeriodField.Value);
                high = double(app.LightStimDmdPulseField.Value) / 1000;
                if high >= period
                    error('ZouLab:DmdTriggerHighNotBelowPeriod', ...
                        ['Trigger high must be shorter than Trigger period. ', ...
                         'The remaining period is the required LOW reset time.']);
                end
                app.LightStimDmdRateField.Value = 1 / period;
                app.Logger.log('INFO', ...
                    'USER_DMD_TRIGGER_GENERATOR_SETTING_EDITED', ...
                    ['Setting=%s | Previous=%s | New=%s | ', ...
                     'TriggerLowSeconds=%.9g | RegenerateFullTable=1'], ...
                    settingName, string(previousValue), string(newValue), ...
                    period - high);
                if string(settingName) == "FirstTriggerDelay"
                    if app.LightStimulusController.Armed
                        app.disarmLightStimulus('dmd_start_offset_changed');
                    end
                    app.scheduleExpensiveUiRefresh( ...
                        'dmd_start_offset_changed', true, false, false);
                else
                    app.resetDmdTriggerTableForPattern( ...
                        app.DmdPictureCountField.Value);
                end
                app.persistUserSettings("dmd_trigger_generator_" + ...
                    string(settingName));
            catch ME
                switch string(settingName)
                    case "FirstTriggerDelay"
                        app.DmdTriggerDelayField.Value = previousValue;
                    case "TriggerPeriod"
                        app.DmdTriggerPeriodField.Value = previousValue;
                        app.LightStimDmdRateField.Value = 1 / previousValue;
                    case "SequenceCycles"
                        app.DmdTriggerRepeatField.Value = previousValue;
                    case "TriggerHighMilliseconds"
                        app.LightStimDmdPulseField.Value = previousValue;
                    case "AdvancedIn1RateHz"
                        app.LightStimDmdRateField.Value = previousValue;
                        app.DmdTriggerPeriodField.Value = 1 / previousValue;
                end
                app.Logger.logException( ...
                    'DMD_TRIGGER_GENERATOR_EDIT_REJECTED', ME);
                app.DmdStatusLabel.Text = "Invalid IN1 generator setting: " + ...
                    string(ME.message);
                app.DmdStatusLabel.FontColor = [0.78 0.18 0.12];
            end
        end

        function dmdTriggerRateEdited(app, previousValue, newValue)
            previousPeriod = double(app.DmdTriggerPeriodField.Value);
            app.DmdTriggerPeriodField.Value = 1 / double(newValue);
            app.dmdTriggerGeneratorSettingEdited('AdvancedIn1RateHz', ...
                previousValue, newValue);
            if abs(app.LightStimDmdRateField.Value - double(newValue)) > ...
                    max(eps, abs(double(newValue)) * 1e-12)
                app.DmdTriggerPeriodField.Value = previousPeriod;
            end
        end

        function dmdTotalTriggerEdited(app, previousValue, newValue)
            framesPerPattern = max(1, round(double( ...
                app.DmdPictureCountField.Value)));
            triggerCount = max(0, round(double(newValue)));
            previousCycles = app.DmdTriggerRepeatField.Value;
            app.DmdTriggerRepeatField.Value = triggerCount / framesPerPattern;
            try
                app.resetDmdTriggerTableForPattern(framesPerPattern, triggerCount);
                app.Logger.log('INFO', 'USER_DMD_TOTAL_TRIGGER_COUNT_EDITED', ...
                    ['PreviousTriggers=%g | NewTriggers=%d | ', ...
                     'PreviousCycles=%.9g | ActualCycles=%.9g | ', ...
                     'BinaryFramesPerPattern=%d'], previousValue, triggerCount, ...
                    previousCycles, app.DmdTriggerRepeatField.Value, ...
                    framesPerPattern);
            catch ME
                app.DmdTotalTriggerField.Value = previousValue;
                app.DmdTriggerRepeatField.Value = previousCycles;
                app.Logger.logException('DMD_TOTAL_TRIGGER_EDIT_REJECTED', ME);
                app.DmdStatusLabel.Text = "Invalid trigger count: " + ...
                    string(ME.message);
                app.DmdStatusLabel.FontColor = [0.78 0.18 0.12];
            end
        end

        function dmdRepeatToFillEdited(app, previousValue, newValue)
            if app.LightStimulusController.Armed
                app.disarmLightStimulus('dmd_repeat_to_fill_changed');
            end
            app.Logger.log('INFO', 'USER_DMD_REPEAT_TO_FILL_EDITED', ...
                ['Previous=%d | New=%d | DefaultPadAfterTrain=%d | ', ...
                 'HardwareCommandIssued=0'], logical(previousValue), ...
                logical(newValue), ~logical(newValue));
            app.scheduleExpensiveUiRefresh( ...
                'dmd_repeat_to_fill_changed', true, false, false);
            app.persistUserSettings('dmd_repeat_to_fill_changed');
        end

        function addDmdTriggerEdge(app)
            data = double(app.DmdTriggerTable.Data);
            if isempty(data)
                newRow = [0 0 0];
            else
                newRow = [data(end, 1) + app.DmdTriggerPeriodField.Value, ...
                    data(end, 2), data(end, 3)];
            end
            data(end + 1, :) = newRow;
            app.DmdTriggerTable.Data = data;
            app.DmdTriggerSelectedRows = size(data, 1);
            app.dmdTriggerSequenceEdited('AddEdge', '', ...
                mat2str(newRow, 6));
        end

        function insertDmdTriggerEdge(app)
            data = double(app.DmdTriggerTable.Data);
            if isempty(data) || isempty(app.DmdTriggerSelectedRows)
                app.addDmdTriggerEdge();
                return;
            end
            row = min(max(1, app.DmdTriggerSelectedRows(1)), size(data, 1));
            if row < size(data, 1)
                newTime = (data(row, 1) + data(row + 1, 1)) / 2;
                newState = data(row, 2);
                newFrame = data(row, 3);
                data = [data(1:row, :); newTime newState newFrame; ...
                    data(row + 1:end, :)];
            elseif row > 1
                newTime = (data(row - 1, 1) + data(row, 1)) / 2;
                newState = data(row - 1, 2);
                newFrame = data(row - 1, 3);
                data = [data(1:row - 1, :); newTime newState newFrame; ...
                    data(row:end, :)];
            else
                newTime = data(1, 1) + app.DmdTriggerPeriodField.Value;
                newState = data(1, 2);
                newFrame = data(1, 3);
                data(end + 1, :) = [newTime newState newFrame];
            end
            app.DmdTriggerTable.Data = data;
            app.DmdTriggerSelectedRows = zeros(1, 0);
            app.dmdTriggerSequenceEdited('InsertEdge', '', ...
                mat2str([newTime newState newFrame], 6));
        end

        function deleteDmdTriggerEdges(app)
            data = double(app.DmdTriggerTable.Data);
            selected = intersect(app.DmdTriggerSelectedRows, 1:size(data, 1));
            if isempty(selected)
                app.Logger.log('WARNING', 'USER_DMD_TRIGGER_DELETE_SKIPPED', ...
                    'Reason=no_selected_row');
                app.DmdStatusLabel.Text = ...
                    'Select one or more IN1 rows before Delete selected.';
                return;
            end
            removed = data(selected, :);
            data(selected, :) = [];
            app.DmdTriggerTable.Data = data;
            app.DmdTriggerSelectedRows = zeros(1, 0);
            app.dmdTriggerSequenceEdited('DeleteSelected', ...
                mat2str(removed, 6), size(data, 1));
        end

        function clearDmdTriggerTable(app)
            previous = double(app.DmdTriggerTable.Data);
            app.DmdTriggerTable.Data = zeros(0, 3);
            app.DmdTriggerSelectedRows = zeros(1, 0);
            app.dmdTriggerSequenceEdited('Clear', mat2str(previous, 6), 'empty');
        end

        function dmdTriggerSequenceEdited(app, settingName, previousValue, newValue)
            if app.LightStimulusController.Armed
                app.disarmLightStimulus('dmd_trigger_sequence_changed');
            end
            risingCount = numel(app.dmdTriggerRisingRows( ...
                app.DmdTriggerTable.Data));
            framesPerPattern = max(1, round(double( ...
                app.DmdPictureCountField.Value)));
            app.DmdTotalTriggerField.Value = risingCount;
            app.DmdTriggerRepeatField.Value = risingCount / framesPerPattern;
            app.Logger.log('INFO', 'USER_DMD_TRIGGER_SEQUENCE_EDITED', ...
                ['Setting=%s | Previous=%s | New=%s | PointCount=%d | ', ...
                 'RisingEdgeCount=%d | ActualCycles=%.9g | ', ...
                 'BinaryFramesPerPattern=%d | HardwareCommandIssued=0'], ...
                settingName, string(previousValue), string(newValue), ...
                size(app.DmdTriggerTable.Data, 1), ...
                risingCount, app.DmdTriggerRepeatField.Value, framesPerPattern);
            try
                app.validateDmdTriggerTable(double(app.DmdTriggerTable.Data));
                if app.LightStimTimelinePreview
                    app.scheduleExpensiveUiRefresh( ...
                        "dmd_trigger_sequence_" + string(settingName), ...
                        true, false, false);
                end
                if isempty(app.DmdTriggerTable.Data)
                    app.DmdStatusLabel.Text = ...
                        ['IN1 table cleared. Add an edge or Generate default ', ...
                         'before external arming.'];
                    app.DmdStatusLabel.FontColor = [0.75 0.40 0.05];
                else
                    app.DmdStatusLabel.Text = sprintf( ...
                        'IN1 sequence valid: %d points, %d rising edges.', ...
                        size(app.DmdTriggerTable.Data, 1), ...
                        numel(app.dmdTriggerRisingRows( ...
                        app.DmdTriggerTable.Data)));
                    app.DmdStatusLabel.FontColor = [0.08 0.55 0.18];
                end
            catch ME
                app.DmdStatusLabel.Text = "Invalid IN1 sequence: " + string(ME.message);
                app.DmdStatusLabel.FontColor = [0.78 0.18 0.12];
            end
        end

        function seconds = dmdTriggerCycleSeconds(app)
            times = double(app.DmdTriggerTable.Data(:, 1));
            if isempty(times)
                seconds = app.DmdTriggerPeriodField.Value;
            else
                seconds = times(end);
            end
        end

        function validateDmdTriggerTable(~, data)
            if isempty(data)
                return;
            end
            if size(data, 2) ~= 3 || size(data, 1) < 2 || ...
                    any(~isfinite(data(:, 1))) || any(data(:, 1) < 0) || ...
                    abs(data(1, 1)) > 1e-12 || data(end, 1) <= 0 || ...
                    any(diff(data(:, 1)) < 0)
                error('ZouLab:DmdTriggerTableInvalid', ...
                    ['IN1 point table requires three columns, starts at 0 s, ', ...
                     'uses finite nondecreasing times, and ends after 0 s.']);
            end
            states = data(:, 2);
            if any(states ~= 0 & states ~= 1) || states(1) ~= 0 || ...
                    states(end) ~= 0
                error('ZouLab:DmdTriggerStateInvalid', ...
                    ['IN1 state must be 0 or 1, and the full waveform must ', ...
                     'start and finish LOW (0).']);
            end
            frames = data(:, 3);
            if any(~isfinite(frames)) || any(frames < 0) || ...
                    any(fix(frames) ~= frames)
                error('ZouLab:DmdTriggerFrameAnnotationInvalid', ...
                    'Expected-frame annotations must be nonnegative integers.');
            end
            rising = find(states == 1 & [true; states(1:end - 1) == 0]);
            if any(frames(rising) < 1)
                error('ZouLab:DmdTriggerRisingFrameAnnotationInvalid', ...
                    'Every IN1 rising edge requires a positive expected-frame number.');
            end
        end

        function resetDmdTriggerTableForPattern(app, binaryFrameCount, triggerCount)
            framesPerBlock = max(1, round(double(binaryFrameCount)));
            if nargin < 3
                requestedCycles = max(0, double( ...
                    app.DmdTriggerRepeatField.Value));
                triggerCount = max(0, round(framesPerBlock * requestedCycles));
            else
                triggerCount = max(0, round(double(triggerCount)));
            end
            cycles = triggerCount / framesPerBlock;
            period = double(app.DmdTriggerPeriodField.Value);
            high = double(app.LightStimDmdPulseField.Value) / 1000;
            if high >= period
                error('ZouLab:DmdTriggerHighNotBelowPeriod', ...
                    ['Trigger high must be shorter than Trigger period so IN1 ', ...
                     'returns LOW before the next rising edge.']);
            end
            points = zeros(3 * triggerCount + 2, 3);
            points(1, :) = [0 0 0];
            row = 1;
            for triggerIndex = 1:triggerCount
                onset = (triggerIndex - 1) * period;
                frame = mod(triggerIndex - 1, framesPerBlock) + 1;
                points(row + 1, :) = [onset 1 frame];
                points(row + 2, :) = [onset + high 1 frame];
                points(row + 3, :) = [onset + high 0 frame];
                row = row + 3;
            end
            finalFrame = 0;
            if triggerCount > 0
                finalFrame = mod(triggerCount - 1, framesPerBlock) + 1;
            end
            points(end, :) = [max(period, triggerCount * period), ...
                0 finalFrame];
            app.DmdTriggerTable.Data = points;
            app.DmdTriggerSelectedRows = zeros(1, 0);
            app.LightStimDmdRateField.Value = 1 / period;
            app.DmdTotalTriggerField.Value = triggerCount;
            app.DmdTriggerRepeatField.Value = cycles;
            app.Logger.log('INFO', 'DMD_TRIGGER_TABLE_RESET_FOR_PATTERN', ...
                ['BinaryFramesPerBlock=%d | SequenceCycles=%.9g | ', ...
                 'DmdStartOffsetSeconds=%.9g | TriggerPeriodSeconds=%.9g | ', ...
                 'TriggerHighSeconds=%.9g | RisingEdges=%d | Points=%d | ', ...
                 'LowResetBetweenEdges=1'], ...
                framesPerBlock, cycles, app.DmdTriggerDelayField.Value, period, high, ...
                triggerCount, size(points, 1));
            app.dmdTriggerSequenceEdited('GenerateFullSequence', '', ...
                sprintf('%d points', size(points, 1)));
        end

        function previewDmdPattern(app)
            triggerMode = string(app.DmdTriggerModeDropDown.Value);
            app.beginAction('PREVIEW_DMD_PATTERN', ...
                "Preparing loaded DMD pattern: " + triggerMode + "...", ...
                app.DmdStatusLabel);
            try
                app.requireIdentity('preview DMD pattern');
                app.requireDmdCalibration();
                if ~app.DmdOperationalPatternLoaded
                    error('ZouLab:DmdOperationalPatternRequired', ...
                        ['Load the intended ALL OFF, ALL ON, or Folder pattern after ', ...
                         'calibration-grid projection.']);
                end
                loopPlayback = string(app.LightStimDmdLoopSwitch.Value) == "Loop";
                if startsWith(app.DmdController.State, 'PLAYING') || ...
                        startsWith(app.DmdController.State, 'ARMED') || ...
                        string(app.DmdController.State) == "PAUSED_INTERNAL"
                    app.DmdController.stop(app.Logger);
                end
                if triggerMode == "External IN1"
                    app.validateDmdTriggerTable(double(app.DmdTriggerTable.Data));
                    if isempty(app.DmdTriggerTable.Data)
                        error('ZouLab:DmdTriggerTableEmpty', ...
                            ['IN1 table is empty. Add an edge or click Generate ', ...
                             'default before external arming.']);
                    end
                    app.DmdController.armExternal(loopPlayback, app.Logger);
                    app.setDmdPatternState('ARMED', ...
                        'Pattern ARMED — waiting for external IN1 edges.');
                    message = ['DMD armed for External IN1. Each configured edge ', ...
                        'advances one binary frame; no DAQ pulse was sent now.'];
                else
                    app.DmdController.playInternal(loopPlayback, app.Logger);
                    app.setDmdPatternState('PLAYING', ...
                        'Pattern PLAYING (internal).');
                    message = 'Loaded DMD pattern is playing internally; DAQ is not used.';
                end
                app.DmdLamp.Color = [0.10 0.75 0.20];
                app.finishAction('PREVIEW_DMD_PATTERN', true, ...
                    message, ...
                    app.DmdStatusLabel);
            catch ME
                app.setDmdPatternState('ERROR', "Play failed: " + string(ME.message));
                app.handleError('DMD_PATTERN_PREVIEW_FAILED', ME, ...
                    app.DmdStatusLabel);
            end
        end

        function connectDmd(app)
            app.beginAction('CONNECT_DMD', 'Connecting and querying DMD...', ...
                app.DmdStatusLabel);
            app.DmdLamp.Color = [0.95 0.65 0.10];
            try
                app.requireIdentity('connect DMD');
                app.applyDmdAdvancedSettings();
                info = app.DmdController.connect(app.Logger);
                app.sendDmdDeviceParametersToHardware(false);
                if isfinite(info.required_image_multiple)
                    app.DmdPictureCountField.Value = info.required_image_multiple;
                else
                    app.Logger.log('WARNING', 'DMD_IMAGE_MULTIPLE_UNRESOLVED', ...
                        ['KeepingPictureCount=%d | Resolution=%s | Storage=%s | ', ...
                         'Generate/load will remain blocked until a valid multiple is known.'], ...
                        app.DmdPictureCountField.Value, info.resolution, ...
                        info.storage_type);
                end
                app.DmdLamp.Color = [0.10 0.75 0.20];
                app.finishAction('CONNECT_DMD', true, sprintf( ...
                    'DMD READY: %dx%d %s, image multiple %g', ...
                    info.width, info.height, info.storage_type, ...
                    info.required_image_multiple), app.DmdStatusLabel);
            catch ME
                app.DmdLamp.Color = [0.85 0.15 0.12];
                app.handleError('DMD_CONNECT_UI_FAILED', ME, app.DmdStatusLabel);
            end
        end

        function recoverDmdHostPort(app)
            app.beginAction('RECOVER_DMD_UDP_PORT', ...
                'Inspecting the process that owns DMD UDP port 6002...', ...
                app.DmdStatusLabel);
            try
                app.requireIdentity('recover DMD UDP port');
                if app.RunState.AcquisitionRunning
                    error('ZouLab:DmdPortRecoveryDuringAcquisition', ...
                        'DMD port recovery is disabled during acquisition.');
                end
                owner = app.DmdController.hostPortOwner();
                if ~owner.found
                    app.Logger.log('INFO', ...
                        'USER_DMD_UDP_PORT_RECOVERY_NO_OWNER', ...
                        'Port=%d | HardwareCommandIssued=0', ...
                        app.DmdController.HostPort);
                    app.finishAction('RECOVER_DMD_UDP_PORT', true, ...
                        'UDP 6002 is already free; Connect DMD can be retried.', ...
                        app.DmdStatusLabel);
                    return;
                end
                message = sprintf([ ...
                    'UDP port %d is owned by %s (PID %d).\n\n', ...
                    'Stop this process and free the DMD port? ', ...
                    'Unsaved work in that process can be lost.'], ...
                    app.DmdController.HostPort, owner.image_name, owner.pid);
                choice = uiconfirm(app.UIFigure, message, ...
                    'Confirm DMD port recovery', ...
                    'Options', {'Cancel','Stop process'}, ...
                    'DefaultOption', 1, 'CancelOption', 1, ...
                    'Icon', 'warning');
                app.Logger.log('INFO', ...
                    'USER_DMD_UDP_PORT_RECOVERY_CONFIRMATION', ...
                    'Port=%d | PID=%d | Image=%s | Choice=%s', ...
                    app.DmdController.HostPort, owner.pid, ...
                    owner.image_name, choice);
                if ~strcmp(choice, 'Stop process')
                    app.finishAction('RECOVER_DMD_UDP_PORT', false, ...
                        'DMD port recovery cancelled; no process was stopped.', ...
                        app.DmdStatusLabel);
                    return;
                end
                app.DmdController.recoverHostPort(owner.pid, app.Logger);
                app.DmdLamp.Color = [0.65 0.65 0.65];
                app.finishAction('RECOVER_DMD_UDP_PORT', true, ...
                    'UDP 6002 recovered; click Connect DMD to start a fresh service.', ...
                    app.DmdStatusLabel);
            catch ME
                app.DmdLamp.Color = [0.85 0.15 0.12];
                app.handleError('DMD_UDP_PORT_RECOVERY_FAILED', ...
                    ME, app.DmdStatusLabel);
            end
        end

        function runDmdAdminPortKill(app)
            app.beginAction('RUN_DMD_ADMIN_PORT_KILL', ...
                'Inspecting UDP 6002 before requesting administrator access...', ...
                app.DmdStatusLabel);
            try
                app.requireIdentity('run DMD -99 administrator recovery');
                if app.RunState.AcquisitionRunning || ...
                        app.LightStimulusController.Armed || ...
                        app.DmdController.Connected
                    error('ZouLab:DmdAdminRecoveryUnsafeState', ...
                        ['Stop acquisition, disarm Light Stimulus, and disconnect ', ...
                         'the DMD before administrator recovery.']);
                end
                batchPath = string(fullfile(app.AppRoot, 'tools', ...
                    '6002PortKill.bat'));
                if ~isfile(batchPath)
                    error('ZouLab:DmdAdminRecoveryScriptMissing', ...
                        'Project recovery script is missing: %s', batchPath);
                end
                expectedHash = ...
                    "D0E8D73B83272A18F60AA7437BD60A3A64C3BF9783C6ACCC026B7ED4A1DBC3AB";
                actualHash = upper(app.sha256File(batchPath));
                if actualHash ~= expectedHash
                    error('ZouLab:DmdAdminRecoveryScriptChanged', ...
                        ['Project recovery script hash does not match the ', ...
                         'reviewed copy. Expected %s but found %s.'], ...
                        expectedHash, actualHash);
                end
                owner = app.DmdController.hostPortOwner();
                if owner.found
                    ownerText = sprintf('%s (PID %d)', ...
                        owner.image_name, owner.pid);
                else
                    ownerText = 'no current owner detected';
                end
                message = sprintf([ ...
                    'Run the project-owned 6002PortKill.bat as administrator?\n\n', ...
                    'Current UDP 6002 owner: %s\nScript: %s\n\n', ...
                    'The script force-stops the first process matching port 6002. ', ...
                    'Use only for DMD error -99. Windows will show a UAC prompt.'], ...
                    ownerText, batchPath);
                choice = uiconfirm(app.UIFigure, message, ...
                    'Confirm DMD -99 recovery', ...
                    'Options', {'Cancel','Run as administrator'}, ...
                    'DefaultOption', 1, 'CancelOption', 1, 'Icon', 'warning');
                app.Logger.log('INFO', ...
                    'USER_DMD_ADMIN_PORT_KILL_CONFIRMATION', ...
                    ['Choice=%s | PortOwner=%s | Script=%s | ', ...
                    'VerifiedSHA256=%s'], choice, ownerText, batchPath, ...
                    actualHash);
                if ~strcmp(choice, 'Run as administrator')
                    app.finishAction('RUN_DMD_ADMIN_PORT_KILL', false, ...
                        'Cancelled; no process was stopped.', app.DmdStatusLabel);
                    return;
                end
                startInfo = System.Diagnostics.ProcessStartInfo();
                startInfo.FileName = char(batchPath);
                startInfo.Verb = 'runas';
                startInfo.UseShellExecute = true;
                startInfo.WindowStyle = ...
                    System.Diagnostics.ProcessWindowStyle.Normal;
                System.Diagnostics.Process.Start(startInfo);
                app.Logger.log('WARNING', 'DMD_ADMIN_PORT_KILL_LAUNCHED', ...
                    ['Script=%s | UacRequested=1 | AppWaitedForCompletion=0 | ', ...
                     'HardwareCommandIssuedByApp=0'], batchPath);
                app.finishAction('RUN_DMD_ADMIN_PORT_KILL', true, ...
                    ['Administrator recovery launched. Complete its console, ', ...
                     'then click Connect DMD.'], app.DmdStatusLabel);
            catch ME
                app.handleError('DMD_ADMIN_PORT_KILL_FAILED', ...
                    ME, app.DmdStatusLabel);
            end
        end

        function stopDmd(app)
            app.beginAction('STOP_DMD', 'Stopping and resetting DMD...', ...
                app.DmdStatusLabel);
            try
                app.requireIdentity('stop DMD');
                app.DmdController.stop(app.Logger);
                app.DmdLamp.Color = [0.10 0.75 0.20];
                if app.DmdOperationalPatternLoaded
                    app.setDmdPatternState('LOADED', ...
                        'Pattern LOADED and stopped; ready to Play.');
                else
                    app.setDmdPatternState('NOT_LOADED', ...
                        'No operational pattern is loaded.');
                end
                app.finishAction('STOP_DMD', true, ...
                    'DMD stopped and reset to image 0.', app.DmdStatusLabel);
            catch ME
                app.handleError('DMD_STOP_UI_FAILED', ME, app.DmdStatusLabel);
            end
        end

        function browseDmdPatternFolder(app)
            app.beginAction('BROWSE_DMD_PATTERN_FOLDER', ...
                'Waiting for DMD pattern folder...', app.DmdStatusLabel);
            selected = uigetdir(char(app.AppRoot), 'Select DMD BMP pattern folder');
            if isequal(selected, 0)
                app.finishAction('BROWSE_DMD_PATTERN_FOLDER', false, ...
                    'DMD pattern-folder selection cancelled.', app.DmdStatusLabel);
                return;
            end
            previous = app.DmdPatternFolderField.Value;
            app.DmdPatternFolderField.Value = selected;
            app.LightStimDmdPatternDropDown.Value = 'Folder';
            app.setDmdPatternState('SELECTED', ...
                'Folder selected — click Load Pattern to transfer it.');
            app.Logger.log('SUCCESS', 'DMD_PATTERN_FOLDER_SELECTED', ...
                'Previous=%s | New=%s | PatternMode=Folder | Loaded=0', ...
                previous, selected);
            app.finishAction('BROWSE_DMD_PATTERN_FOLDER', true, ...
                "Selected: " + string(selected), app.DmdStatusLabel);
        end

        function loadDmdPattern(app)
            app.beginAction('LOAD_DMD_PATTERN', 'Preparing DMD pattern...', ...
                app.DmdStatusLabel);
            try
                app.requireIdentity('load DMD pattern');
                if ~app.DmdController.Connected
                    error('ZouLab:DmdNotConnected', ...
                        'Connect DMD before compiling and loading a pattern.');
                end
                if startsWith(string(app.DmdController.State), "PLAYING") || ...
                        startsWith(string(app.DmdController.State), "ARMED") || ...
                        string(app.DmdController.State) == "PAUSED_INTERNAL"
                    app.Logger.log('INFO', 'DMD_PATTERN_LOAD_AUTO_STOP', ...
                        'PreviousState=%s | Reason=pattern_reload', ...
                        app.DmdController.State);
                    app.DmdController.stop(app.Logger);
                end
                app.setDmdPatternState('LOADING', ...
                    'Pattern transfer in progress...');
                pattern = string(app.LightStimDmdPatternDropDown.Value);
                if pattern == "Folder"
                    folder = string(app.DmdPatternFolderField.Value);
                    manifestPath = fullfile(folder, 'pattern_manifest.json');
                    if isfile(manifestPath)
                        manifest = jsondecode(fileread(manifestPath));
                        app.DmdController.loadCompiledPattern(manifest, app.Logger);
                        app.DmdCompiledManifest = manifest;
                    else
                        app.DmdController.loadPatternFolder(folder, ...
                            app.DmdPictureCountField.Value, ...
                            app.DmdStartPositionField.Value, app.Logger);
                        manifest = app.DmdController.Pattern;
                        app.DmdCompiledManifest = manifest;
                    end
                elseif startsWith(pattern, "Generated")
                    if isempty(fieldnames(app.DmdMaskData))
                        error('ZouLab:DmdGeneratedMaskRequired', ...
                            'Generate a DMD mask before loading Generated patterns.');
                    end
                    switch pattern
                        case "Generated Combined"
                            masks = app.DmdMaskData.combined_dmd_mask;
                        case "Generated Reverse"
                            if ~app.DmdMaskReverseCheckBox.Value
                                error('ZouLab:DmdReverseMaskDisabled', ...
                                    'Enable Create reverse and regenerate the mask.');
                            end
                            masks = app.DmdMaskData.reverse_dmd_mask;
                        case "Generated Each ROI"
                            if ~app.DmdMaskEachRoiCheckBox.Value || ...
                                    isempty(app.DmdMaskData.each_dmd_mask)
                                error('ZouLab:DmdEachRoiDisabled', ...
                                    'Enable Create Each ROI and regenerate the mask.');
                            end
                            masks = app.DmdMaskData.each_dmd_mask;
                            roiMaskCount = numel(masks);
                            if app.DmdInsertOffBetweenRoisCheckBox.Value
                                sequence = cell(1, roiMaskCount * 2);
                                for roiIndex = 1:roiMaskCount
                                    sequence{2 * roiIndex - 1} = masks{roiIndex};
                                    sequence{2 * roiIndex} = false(size(masks{roiIndex}));
                                end
                                masks = sequence;
                            end
                        otherwise
                            error('ZouLab:DmdGeneratedPatternInvalid', ...
                                'Unknown generated DMD pattern %s.', pattern);
                    end
                    bitDepth = 1;
                    if string(app.DmdBitDepthDropDown.Value) == "8-bit grayscale"
                        bitDepth = 8;
                    end
                    multiple = double( ...
                        app.DmdController.DeviceInfo.required_image_multiple);
                    stamp = char(datetime('now', 'Format', ...
                        'yyyyMMdd_HHmmss_SSS'));
                    safeName = lower(regexprep(char(pattern), ...
                        '[^A-Za-z0-9]+', '_'));
                    folder = fullfile(string(app.DmdMaskData.output_folder), ...
                        "compiled_" + safeName + "_" + stamp);
                    manifest = zoulab.DmdPatternCompiler.compileMasks( ...
                        masks, folder, BitDepth=bitDepth, ...
                        RequiredBinaryMultiple=multiple, Name=pattern, ...
                        Source="generated_mask", ...
                        PaddingMode=app.dmdGeneratedPaddingMode( ...
                            pattern, bitDepth), ...
                        CalibrationFile=string(app.DmdCalibrationMatrixField.Value), ...
                        Logger=app.Logger);
                    if pattern == "Generated Each ROI"
                        manifest.roi_mask_count = roiMaskCount;
                        manifest.inter_roi_off_inserted = logical( ...
                            app.DmdInsertOffBetweenRoisCheckBox.Value);
                        manifest.trailing_off_block_fill = logical( ...
                            app.DmdTrailingOffPaddingCheckBox.Value);
                        zoulab.SessionManager.writeJson(fullfile(folder, ...
                            'pattern_manifest.json'), manifest);
                        app.Logger.log('INFO', 'DMD_EACH_ROI_SEQUENCE_COMPILED', ...
                            ['RoiMasks=%d | InterRoiOffInserted=%d | ', ...
                             'BaseSequenceImages=%d | BlockFillMode=%s | ', ...
                             'TrailingOffBlockFill=%d'], ...
                            roiMaskCount, ...
                            app.DmdInsertOffBetweenRoisCheckBox.Value, ...
                            numel(masks), string(manifest.padding_mode), ...
                            app.DmdTrailingOffPaddingCheckBox.Value);
                    end
                    app.DmdController.loadCompiledPattern(manifest, app.Logger);
                    app.DmdCompiledManifest = manifest;
                    app.DmdPatternFolderField.Value = char(folder);
                else
                    folder = app.DmdController.createBuiltInPattern( ...
                        upper(strrep(pattern, ' ', '_')), ...
                        fullfile(app.currentDmdCalibrationRoot(), 'compiled'), ...
                        app.Logger);
                    app.DmdPatternFolderField.Value = char(folder);
                    manifest = jsondecode(fileread(fullfile(folder, ...
                        'pattern_manifest.json')));
                    app.DmdController.loadCompiledPattern(manifest, app.Logger);
                    app.DmdCompiledManifest = manifest;
                end
                % HC/iDMD apply Param 1 and Param 2 after every transfer.
                % Param 1 depends on the compiled bit depth and exact padded
                % binary-frame count, so it cannot be finalized at connect.
                app.sendDmdDeviceParametersToHardware(true);
                app.DmdOperationalPatternLoaded = true;
                if isfield(app.DmdCompiledManifest, 'binary_frame_count')
                    app.DmdPictureCountField.Value = ...
                        double(app.DmdCompiledManifest.binary_frame_count);
                    app.resetDmdTriggerTableForPattern( ...
                        app.DmdCompiledManifest.binary_frame_count);
                    app.DmdPatternSummaryLabel.Text = sprintf( ...
                        ['Logical %d | %d-bit | Files %d | Binary %d | ', ...
                         'Block fill %s (%d binary frames)'], ...
                        double(app.DmdCompiledManifest.logical_mask_count), ...
                        double(app.DmdCompiledManifest.bit_depth), ...
                        double(app.DmdCompiledManifest.upload_file_count), ...
                        double(app.DmdCompiledManifest.binary_frame_count), ...
                        string(app.DmdCompiledManifest.padding_mode), ...
                        double(app.DmdCompiledManifest.padding_binary_frame_count));
                end
                app.DmdLamp.Color = [0.10 0.75 0.20];
                app.setDmdPatternState('LOADED', ...
                    "Pattern LOADED — ready to Play: " + string(pattern));
                app.finishAction('LOAD_DMD_PATTERN', true, ...
                    "Pattern transfer command accepted: " + folder, ...
                    app.DmdStatusLabel);
            catch ME
                app.setDmdPatternState('ERROR', "Load failed: " + string(ME.message));
                app.handleError('DMD_PATTERN_LOAD_UI_FAILED', ME, app.DmdStatusLabel);
            end
        end

        function armLightStimulus(app)
            app.beginAction('ARM_LIGHT_STIMULUS', ...
                'Validating and arming light stimulus...', ...
                app.LightStimFrameworkStatusLabel);
            try
                app.requireIdentity('arm light stimulus');
                if app.VisualStimulusController.Armed || ...
                        app.LedFlickerController.Armed
                    error('ZouLab:CombinedStimulusNotYetSupported', ...
                        ['Disarm Visual Stimulus and LED Flicker before ', ...
                         'arming Light Stimulus.']);
                end
                spec = app.currentLightStimulusSpec();
                app.LightStimulusController.configure(spec, app.Logger);
                dmdExternal = spec.dmd_enabled && ...
                    string(spec.dmd_trigger_mode) == "External IN1";
                if dmdExternal
                    app.requireDmdCalibration();
                    if ~app.DmdOperationalPatternLoaded
                        error('ZouLab:DmdOperationalPatternRequired', ...
                            ['Load the intended DMD stimulation pattern after ', ...
                             'calibration-grid projection, then Arm again.']);
                    end
                end
                if ~app.SimulationMode
                    app.DaqController.assertReady();
                    if dmdExternal && strlength(app.DaqController.DmdTriggerPort) == 0
                        error('ZouLab:DmdDaqPortRequired', ...
                            ['DMD IN1 DAQ line is unconfigured. Confirm wiring and enter ', ...
                             'the line in Advanced before arming.']);
                    end
                end
                selectedNames = string(spec.stimulus_light_names);
                wavelengths = [405 445];
                for laserIndex = 1:2
                    alias = "Laser" + string(wavelengths(laserIndex));
                    if any(selectedNames == alias)
                        if ~app.SimulationMode
                            app.DaqController.setLights(alias, false, app.Logger);
                            app.DaqController.setLaserAnalogVoltage(alias, 0, app.Logger);
                        else
                            app.Logger.log('INFO', ...
                                'SIMULATION_LIGHT_STIMULUS_OUTPUT_PRIMED_SAFE', ...
                                'Alias=%s | DO=OFF | AO=0V | HardwareCommandIssued=0', ...
                                alias);
                        end
                        app.CoherentControllers{laserIndex}.armMixed(app.Logger);
                        lightData = app.LightTable.Data;
                        lightData{laserIndex,8} = 'OFF';
                        app.LightTable.Data = lightData;
                    end
                end
                app.LightStimulusController.arm(app.DmdController, app.Logger);
                app.Logger.log('INFO', 'DMD_ACQUISITION_MODE_RETAINED', ...
                    ['Enabled=%d | Mode=%s | ExternalIN1Included=%d | ', ...
                     'AutomaticModeChange=0'], spec.dmd_enabled, ...
                    string(spec.dmd_trigger_mode), dmdExternal);
                app.LightStimTimelinePreview = false;
                app.LightStimTimelinePreviewButton.Text = 'Show';
                app.LightStimLamp.Color = [0.10 0.75 0.20];
                app.LightStimStatusLabel.Text = 'Light Stim ARMED';
                app.LightStimArmButton.Enable = 'off';
                app.LightStimDisarmButton.Enable = 'on';
                app.AcquisitionModeDropDown.Value = 'Record';
                resolvedDuration = app.resolvedRecordWindowSeconds();
                app.updateRecordLengthSummary();
                app.Logger.log('INFO', ...
                    'LIGHT_STIMULUS_RECORD_LENGTH_AUTHORITY_RETAINED', ...
                    ['Source=%s | ResolvedCameraWindowSeconds=%.9g | ', ...
                     'RecordDurationFieldOverwritten=0 | DmdExcluded=1'], ...
                    string(app.RecordLengthSourceDropDown.Value), ...
                    resolvedDuration);
                app.updateAcquisitionControlAvailability(false);
                app.updateAcquisitionStorageEstimate( ...
                    'light_stimulus_armed', true);
                app.refreshDaqTimeline('light_stimulus_armed');
                app.finishAction('ARM_LIGHT_STIMULUS', true, ...
                    'Light stimulus armed; Acquisition will include it.', ...
                    app.LightStimFrameworkStatusLabel);
            catch ME
                app.disarmLightStimulus('arm_failed');
                app.handleError('LIGHT_STIMULUS_ARM_FAILED', ME, ...
                    app.LightStimFrameworkStatusLabel);
            end
        end

        function disarmLightStimulus(app, reason)
            wasArmed = app.LightStimulusController.Armed;
            try
                app.LightStimulusController.disarm(app.DmdController, app.Logger);
            catch ME
                app.Logger.logException('LIGHT_STIMULUS_DMD_DISARM_FAILED', ME);
            end
            wavelengths = [405 445];
            for laserIndex = 1:2
                try
                    alias = "Laser" + string(wavelengths(laserIndex));
                    if app.DaqController.Connected && ...
                            ~app.DaqController.FinitePlanRunning
                        app.DaqController.setLights(alias, false, app.Logger);
                        app.DaqController.setLaserAnalogVoltage(alias, 0, app.Logger);
                    end
                    app.CoherentControllers{laserIndex}.disarm(app.Logger);
                    lightData = app.LightTable.Data;
                    lightData{laserIndex,8} = 'OFF';
                    app.LightTable.Data = lightData;
                catch ME
                    app.Logger.logException('LIGHT_STIMULUS_LASER_DISARM_FAILED', ME);
                end
            end
            app.LightStimLamp.Color = [0.65 0.65 0.65];
            app.LightStimStatusLabel.Text = 'Light Stim OFF';
            app.LightStimTimelinePreview = false;
            if ~isempty(app.LightStimTimelinePreviewButton) && ...
                    isvalid(app.LightStimTimelinePreviewButton)
                app.LightStimTimelinePreviewButton.Text = 'Show';
            end
            app.LightStimArmButton.Enable = 'on';
            app.LightStimDisarmButton.Enable = 'off';
            app.LightStimFrameworkStatusLabel.Text = ...
                "Light stimulus OFF (" + string(reason) + ").";
            app.updateAcquisitionControlAvailability(false);
            app.updateAcquisitionStorageEstimate( ...
                "light_stimulus_disarmed_" + string(reason), true);
            app.refreshDaqTimeline("light_stimulus_disarmed_" + string(reason));
            app.Logger.log('INFO', 'LIGHT_STIMULUS_DISARM_COMPLETE', ...
                'Reason=%s | WasArmed=%d', reason, wasArmed);
        end

        function advancedHardwareSettingEdited(app, settingName, previousValue, newValue)
            if app.RunState.AcquisitionRunning || app.LightStimulusController.Armed
                app.Logger.log('WARNING', 'ADVANCED_HARDWARE_EDIT_REJECTED', ...
                    'Setting=%s | Previous=%s | Requested=%s | Reason=locked', ...
                    settingName, string(previousValue), string(newValue));
                return;
            end
            app.Logger.log('INFO', 'USER_ADVANCED_HARDWARE_SETTING_EDITED', ...
                'Setting=%s | Previous=%s | New=%s', settingName, ...
                string(previousValue), string(newValue));
            app.applyDmdAdvancedSettings();
            app.scheduleExpensiveUiRefresh( ...
                "advanced_" + string(settingName), true, false, false);
            app.persistUserSettings("advanced_" + string(settingName));
        end

        function dmdDeviceParameterEdited(app, settingName, previousValue, newValue)
            if app.RunState.AcquisitionRunning || app.LightStimulusController.Armed
                app.restoreDmdDeviceControlValue(settingName, previousValue);
                app.Logger.log('WARNING', 'DMD_DEVICE_PARAMETER_EDIT_REJECTED', ...
                    ['Setting=%s | Previous=%s | Requested=%s | ', ...
                     'Reason=acquisition_or_light_stimulus_armed'], ...
                    settingName, string(previousValue), string(newValue));
                return;
            end
            app.Logger.log('INFO', 'USER_DMD_DEVICE_PARAMETER_EDITED', ...
                ['Setting=%s | Previous=%s | New=%s | ', ...
                 'HardwareCommandIssued=0 | ApplyRequired=%d'], ...
                settingName, string(previousValue), string(newValue), ...
                app.DmdController.Connected);
            if app.DmdController.Connected
                app.DmdLamp.Color = [0.95 0.65 0.10];
                app.DmdStatusLabel.Text = ...
                    'DMD settings changed — click Apply before playback.';
            end
            app.persistUserSettings("dmd_device_" + string(settingName));
        end

        function restoreDmdDeviceControlValue(app, settingName, value)
            switch string(settingName)
                case "InternalPlaybackHz"
                    app.DmdInternalRateField.Value = value;
                case "VerticalMirror"
                    app.DmdVerticalMirrorCheckBox.Value = value;
                case "DataReverse"
                    app.DmdDataReverseCheckBox.Value = value;
                case "RowAddressing"
                    app.DmdRowAddressingCheckBox.Value = value;
                case "InputTriggerEdge"
                    app.DmdInputEdgeDropDown.Value = value;
                case "OutputTriggerEdge"
                    app.DmdOutputEdgeDropDown.Value = value;
                case "DividedTriggerEdge"
                    app.DmdDividedEdgeDropDown.Value = value;
                case "TriggerDivision"
                    app.DmdTriggerDivisionField.Value = value;
                case "PictureCountRegister"
                    app.DmdPictureCountActionDropDown.Value = value;
            end
        end

        function restoreDmdDeviceParameters(app, saved)
            try
                if isfield(saved, 'internal_playback_hz') && ...
                        isscalar(saved.internal_playback_hz) && ...
                        isfinite(saved.internal_playback_hz) && ...
                        saved.internal_playback_hz >= 1
                    app.DmdInternalRateField.Value = ...
                        round(saved.internal_playback_hz);
                end
                logicalFields = { ...
                    'vertical_mirror', 'DmdVerticalMirrorCheckBox'; ...
                    'data_reverse', 'DmdDataReverseCheckBox'; ...
                    'row_addressing', 'DmdRowAddressingCheckBox'};
                for fieldIndex = 1:size(logicalFields, 1)
                    savedName = logicalFields{fieldIndex, 1};
                    controlName = logicalFields{fieldIndex, 2};
                    if isfield(saved, savedName) && isscalar(saved.(savedName))
                        app.(controlName).Value = logical(saved.(savedName));
                    end
                end
                edgeFields = { ...
                    'input_trigger_edge', 'DmdInputEdgeDropDown'; ...
                    'output_trigger_edge', 'DmdOutputEdgeDropDown'; ...
                    'divided_trigger_edge', 'DmdDividedEdgeDropDown'};
                for fieldIndex = 1:size(edgeFields, 1)
                    savedName = edgeFields{fieldIndex, 1};
                    controlName = edgeFields{fieldIndex, 2};
                    if isfield(saved, savedName)
                        item = zoulab.UserSettings.canonicalDropDownItem( ...
                            app.(controlName).Items, saved.(savedName));
                        if strlength(item) > 0
                            app.(controlName).Value = char(item);
                        end
                    end
                end
                if isfield(saved, 'trigger_division') && ...
                        isscalar(saved.trigger_division) && ...
                        isfinite(saved.trigger_division) && ...
                        saved.trigger_division >= 0
                    app.DmdTriggerDivisionField.Value = ...
                        round(saved.trigger_division);
                end
                if isfield(saved, 'picture_count_register')
                    item = zoulab.UserSettings.canonicalDropDownItem( ...
                        app.DmdPictureCountActionDropDown.Items, ...
                        saved.picture_count_register);
                    if strlength(item) > 0
                        app.DmdPictureCountActionDropDown.Value = char(item);
                    end
                end
                app.Logger.log('SUCCESS', 'DMD_DEVICE_PARAMETERS_RESTORED', ...
                    ['InternalHz=%g | VerticalMirror=%d | DataReverse=%d | ', ...
                     'RowAddressing=%d | InputEdge=%s | OutputEdge=%s | ', ...
                     'DividedEdge=%s | Division=%g | CountRegister=%s | ', ...
                     'HardwareCommandIssued=0'], ...
                    app.DmdInternalRateField.Value, ...
                    app.DmdVerticalMirrorCheckBox.Value, ...
                    app.DmdDataReverseCheckBox.Value, ...
                    app.DmdRowAddressingCheckBox.Value, ...
                    app.DmdInputEdgeDropDown.Value, ...
                    app.DmdOutputEdgeDropDown.Value, ...
                    app.DmdDividedEdgeDropDown.Value, ...
                    app.DmdTriggerDivisionField.Value, ...
                    app.DmdPictureCountActionDropDown.Value);
            catch ME
                app.Logger.logException( ...
                    'DMD_DEVICE_PARAMETERS_RESTORE_SKIPPED', ME);
            end
        end

        function applyDmdDeviceParametersClicked(app)
            app.beginAction('APPLY_DMD_DEVICE_PARAMETERS', ...
                'Applying DMD device timing and trigger settings...', ...
                app.DmdStatusLabel);
            try
                app.requireIdentity('apply DMD device settings');
                if ~app.DmdController.Connected
                    error('ZouLab:DmdNotConnected', ...
                        'Connect DMD before applying device settings.');
                end
                includedPattern = app.sendDmdDeviceParametersToHardware( ...
                    ~isempty(fieldnames(app.DmdCompiledManifest)));
                app.DmdLamp.Color = [0.10 0.75 0.20];
                app.finishAction('APPLY_DMD_DEVICE_PARAMETERS', true, ...
                    sprintf(['DMD settings applied; pattern parameters ', ...
                    'included=%d.'], includedPattern), app.DmdStatusLabel);
            catch ME
                app.DmdLamp.Color = [0.85 0.15 0.12];
                app.handleError('DMD_DEVICE_PARAMETERS_APPLY_FAILED', ...
                    ME, app.DmdStatusLabel);
            end
        end

        function includedPattern = sendDmdDeviceParametersToHardware(app, includePattern)
            app.DmdController.setParameters2( ...
                app.DmdVerticalMirrorCheckBox.Value, ...
                app.DmdDataReverseCheckBox.Value, ...
                app.DmdRowAddressingCheckBox.Value, ...
                string(app.DmdInputEdgeDropDown.Value) == "Falling", ...
                string(app.DmdOutputEdgeDropDown.Value) == "Falling", ...
                string(app.DmdDividedEdgeDropDown.Value) == "Falling", ...
                round(app.DmdTriggerDivisionField.Value), app.Logger);
            includedPattern = false;
            if includePattern && ...
                    isfield(app.DmdCompiledManifest, 'binary_frame_count') && ...
                    isfield(app.DmdCompiledManifest, 'bit_depth')
                countFlag = double(string( ...
                    app.DmdPictureCountActionDropDown.Value) == "Write");
                app.DmdController.setParameters1( ...
                    round(app.DmdInternalRateField.Value), ...
                    round(double(app.DmdCompiledManifest.bit_depth)), ...
                    round(double(app.DmdCompiledManifest.binary_frame_count)), ...
                    countFlag, app.Logger);
                includedPattern = true;
            end
        end

        function saveWiringJson(app)
            app.beginAction('SAVE_RIG_WIRING_JSON', ...
                'Validating rig wiring JSON...', app.WiringConfigStatusLabel);
            try
                app.requireIdentity('save rig wiring JSON');
                app.assertWiringConfigEditable();
                app.WiringConfig.saveTextAndReload( ...
                    app.WiringJsonArea.Value, app.Logger);
                app.applyWiringConfigToRuntime(app.WiringConfig.Value);
                app.refreshWiringConfigUi();
                app.refreshDaqTimeline('wiring_json_saved');
                app.finishAction('SAVE_RIG_WIRING_JSON', true, ...
                    'Validated, backed up, saved and applied.', ...
                    app.WiringConfigStatusLabel);
            catch ME
                app.handleError('SAVE_RIG_WIRING_JSON_FAILED', ME, ...
                    app.WiringConfigStatusLabel);
            end
        end

        function wiringJsonEdited(app, textValue)
            lines = string(textValue);
            characterCount = strlength(join(lines, newline));
            app.Logger.log('INFO', 'USER_RIG_WIRING_JSON_EDITOR_CHANGED', ...
                ['Lines=%d | Characters=%d | Saved=0 | ', ...
                 'HardwareCommandsIssued=0'], numel(lines), characterCount);
            app.WiringConfigStatusLabel.Text = ...
                'Unsaved JSON changes. Click Validate & save.';
            app.WiringConfigStatusLabel.FontColor = [0.80 0.48 0.05];
        end

        function reloadWiringJson(app)
            app.beginAction('RELOAD_RIG_WIRING_JSON', ...
                'Reloading and validating rig wiring JSON...', ...
                app.WiringConfigStatusLabel);
            try
                app.requireIdentity('reload rig wiring JSON');
                app.assertWiringConfigEditable();
                value = app.WiringConfig.load(app.Logger);
                app.applyWiringConfigToRuntime(value);
                app.refreshWiringConfigUi();
                app.refreshDaqTimeline('wiring_json_reloaded');
                app.finishAction('RELOAD_RIG_WIRING_JSON', true, ...
                    'Disk JSON reloaded, validated and applied.', ...
                    app.WiringConfigStatusLabel);
            catch ME
                app.handleError('RELOAD_RIG_WIRING_JSON_FAILED', ME, ...
                    app.WiringConfigStatusLabel);
            end
        end

        function assertWiringConfigEditable(app)
            connected = app.DaqController.Connected || app.DmdController.Connected || ...
                app.SpectraController.Connected;
            for laserIndex = 1:numel(app.CoherentControllers)
                connected = connected || app.CoherentControllers{laserIndex}.Connected;
            end
            if app.RunState.AcquisitionRunning || app.LightStimulusController.Armed || connected
                error('ZouLab:WiringConfigLocked', ...
                    ['Stop acquisition, disarm light stimulus, and disconnect DAQ, DMD, ', ...
                     'Spectra X and both OBIS lasers before changing rig wiring.']);
            end
        end

        function applyWiringConfigToRuntime(app, value)
            app.DaqController.applyWiringConfig(value, app.Logger);
            app.applyWiringToNonDaqControllers(value);
            app.Logger.log('SUCCESS', 'RIG_WIRING_RUNTIME_APPLIED', ...
                ['Device=%s | SpectraX=%s | OBIS405=%s | OBIS445=%s | DMD=%s:%d | ', ...
                 'DMD_IN1=%s'], value.daq.device_id, value.serial.spectrax, ...
                value.serial.obis405, ...
                value.serial.obis445, value.dmd_network.target_address, ...
                value.dmd_network.target_port, app.DaqController.DmdTriggerPort);
        end

        function applyWiringToNonDaqControllers(app, value)
            app.SpectraController.ConfiguredPort = string(value.serial.spectrax);
            app.CoherentControllers{1}.Port = string(value.serial.obis405);
            app.CoherentControllers{2}.Port = string(value.serial.obis445);
            app.DmdController.HostAddress = string(value.dmd_network.host_address);
            app.DmdController.HostPort = double(value.dmd_network.host_port);
            app.DmdController.TargetAddress = string(value.dmd_network.target_address);
            app.DmdController.TargetPort = double(value.dmd_network.target_port);
        end

        function refreshWiringConfigUi(app)
            value = app.WiringConfig.Value;
            app.WiringJsonArea.Value = cellstr(splitlines(app.WiringConfig.prettyText()));
            app.DmdDaqPortField.Value = char(app.DaqController.DmdTriggerPort);
            app.DmdHostAddressField.Value = char(value.dmd_network.host_address);
            app.DmdHostPortField.Value = value.dmd_network.host_port;
            app.DmdTargetAddressField.Value = char(value.dmd_network.target_address);
            app.DmdTargetPortField.Value = value.dmd_network.target_port;
            app.WiringConfigStatusLabel.Text = ...
                "Loaded and validated: " + app.WiringConfig.LoadedAt;
            app.WiringConfigStatusLabel.FontColor = [0.08 0.45 0.18];
        end

        function applyDmdAdvancedSettings(app)
            app.DmdController.HostAddress = string(app.DmdHostAddressField.Value);
            app.DmdController.HostPort = app.DmdHostPortField.Value;
            app.DmdController.TargetAddress = string(app.DmdTargetAddressField.Value);
            app.DmdController.TargetPort = app.DmdTargetPortField.Value;
            app.DaqController.DmdTriggerPort = strtrim(string(app.DmdDaqPortField.Value));
        end

        function scheduleExpensiveUiRefresh(app, reason, refreshTimeline, ...
                refreshStorage, writeStorageLog)
            % Debounce means "run once after edits have been quiet for the
            % delay", not polling at the delay interval.
            if nargin < 4
                refreshStorage = false;
            end
            if nargin < 5
                writeStorageLog = false;
            end
            app.PendingTimelineRefresh = app.PendingTimelineRefresh || ...
                logical(refreshTimeline);
            app.PendingStorageRefresh = app.PendingStorageRefresh || ...
                logical(refreshStorage);
            app.PendingStorageRefreshLog = app.PendingStorageRefreshLog || ...
                logical(writeStorageLog);
            app.PendingUiRefreshReason = string(reason);
            app.stopAndDeleteTimer('UiRefreshDebounceTimer');
            if app.RunState.Closing
                return;
            end
            app.UiRefreshDebounceTimer = timer( ...
                'ExecutionMode', 'singleShot', ...
                'StartDelay', app.UiRefreshDebounceSeconds, ...
                'TimerFcn', @(~,~) app.flushExpensiveUiRefresh());
            start(app.UiRefreshDebounceTimer);
        end

        function flushExpensiveUiRefresh(app)
            if app.RunState.Closing
                return;
            end
            refreshTimeline = app.PendingTimelineRefresh;
            regenerateDo = app.PendingDoWaveformRegeneration;
            refreshStorage = app.PendingStorageRefresh;
            writeStorageLog = app.PendingStorageRefreshLog;
            reason = app.PendingUiRefreshReason;
            app.PendingTimelineRefresh = false;
            app.PendingDoWaveformRegeneration = false;
            app.PendingStorageRefresh = false;
            app.PendingStorageRefreshLog = false;
            app.PendingUiRefreshReason = "";
            app.stopAndDeleteTimer('UiRefreshDebounceTimer');
            try
                if regenerateDo
                    app.generateDigitalPointTable("debounced_parameter_edit");
                    app.updateRecordLengthSummary();
                end
                if refreshTimeline
                    app.refreshDaqTimeline(reason);
                end
                if refreshStorage
                    app.updateAcquisitionStorageEstimate(reason, writeStorageLog);
                end
            catch ME
                app.Logger.logException('DEBOUNCED_UI_REFRESH_FAILED', ME);
            end
        end

        function cancelExpensiveUiRefresh(app)
            app.stopAndDeleteTimer('UiRefreshDebounceTimer');
            app.PendingTimelineRefresh = false;
            app.PendingDoWaveformRegeneration = false;
            app.PendingStorageRefresh = false;
            app.PendingStorageRefreshLog = false;
            app.PendingUiRefreshReason = "";
        end

        function refreshDaqTimeline(app, reason)
            if isempty(app.DaqTimelineAxes) || ~isvalid(app.DaqTimelineAxes) || ...
                    isempty(app.AcquisitionModeDropDown) || ...
                    ~isvalid(app.AcquisitionModeDropDown)
                return;
            end
            if app.TimelineRefreshRunning
                return;
            end
            app.cancelExpensiveUiRefresh();
            app.TimelineRefreshRunning = true;
            refreshCleanup = onCleanup(@() app.finishTimelineRefresh()); %#ok<NASGU>
            try
                spec = app.timelineAcquisitionSpec();
                plan = app.LightStimulusController.compileAcquisitionPlan( ...
                    spec, app.timelineChannelNames(), app.Logger, ...
                    app.LightStimTimelinePreview);
                app.LastDaqTimelinePlan = plan;
                app.renderDaqTimeline(plan);
                visualIncluded = app.VisualStimulusController.Armed;
                shown = sum(~ismember(app.timelineDisplayedNames(plan), ...
                    app.DaqTimelineHiddenNames));
                total = numel(app.timelineDisplayedNames(plan));
                if app.LightStimTimelinePreview && ...
                        ~app.LightStimulusController.Armed
                    lightMode = 'DRAFT PREVIEW — hardware not armed';
                elseif app.LightStimulusController.Armed
                    lightMode = 'ARMED';
                else
                    lightMode = 'OFF';
                end
                app.DaqTimelineStatusLabel.Text = sprintf( ...
                    ['Timeline: camera-relative %.3g to %.3g s | ', ...
                     'Camera Record: 0 to %.3g s | exact samples %d | ', ...
                     'shown %d/%d | Light=%s | Visual=%s'], ...
                    plan.time_seconds(1), plan.time_seconds(end), ...
                    plan.camera_end_seconds, numel(plan.time_seconds), shown, total, ...
                    lightMode, ...
                    app.visualTimelineStatus(visualIncluded));
                app.DaqTimelineStatusLabel.FontColor = [0.08 0.45 0.18];
                app.Logger.log('INFO', 'DAQ_TIMELINE_UI_UPDATED', ...
                    ['Reason=%s | DurationSeconds=%.6g | OutputRateHz=%.6g | ', ...
                     'TimelineDisplay=all_exact_samples | Samples=%d | Channels=%s | ', ...
                     'Shown=%d/%d | VisualIncluded=%d | ', ...
                     'VisualControl=software_PTB_not_DAQ | ', ...
                     'VisualEpochOrder=%s'], ...
                    reason, plan.duration_seconds, plan.sample_rate_hz, ...
                    numel(plan.time_seconds), ...
                    strjoin(plan.channel_names, ','), shown, total, visualIncluded, ...
                    app.visualEpochOrderText());
            catch ME
                delete(allchild(app.DaqTimelineAxes));
                app.DaqTimelineMetricsTable.Data = cell(0,6);
                app.DaqTimelineStatusLabel.Text = "Timeline invalid: " + string(ME.message);
                app.DaqTimelineStatusLabel.FontColor = [0.78 0.18 0.12];
                app.Logger.logException('DAQ_TIMELINE_UI_UPDATE_FAILED', ME);
            end
        end

        function finishTimelineRefresh(app)
            app.TimelineRefreshRunning = false;
        end

        function spec = timelineAcquisitionSpec(app)
            mode = string(app.AcquisitionModeDropDown.Value);
            switch mode
                case "Snap"
                    cameraWindow = 0.01;
                case "Time Lapse"
                    cameraWindow = 0.01;
                otherwise
                    cameraWindow = app.resolvedRecordWindowSeconds();
            end
            spec = struct( ...
                'sample_rate_hz', app.DaqSampleRateField.Value, ...
                'cameras', app.activeCameraIndices(), ...
                'camera_window_seconds', cameraWindow, ...
                'camera_trigger_width_seconds', app.DaqController.PulseWidthSeconds, ...
                'imaging_light_start_offset_seconds', app.LightLeadSeconds, ...
                'imaging_light_end_offset_seconds', app.LightTailSeconds, ...
                'camera_pre_stim_seconds', 0, ...
                'imaging_light_names', app.lightAliases( ...
                    app.imagingLightRowsFor(app.activeCameraIndices())), ...
                'imaging_light_analog_volts', app.imagingLightAnalogVolts( ...
                    app.imagingLightRowsFor(app.activeCameraIndices())), ...
                'led_flicker_armed', app.LedFlickerController.Armed, ...
                'led_flicker_delay_seconds', ...
                    app.LedFlickerController.Spec.delay_seconds, ...
                'led_flicker_start_offset_seconds', ...
                    app.LedFlickerController.Spec.delay_seconds, ...
                'led_flicker_hz_per_volt', ...
                    app.LedFlickerController.Spec.hz_per_volt, ...
                'led_flicker_do_points', ...
                    app.LedFlickerController.Spec.do_points, ...
                'led_flicker_ao_points', ...
                    app.LedFlickerController.Spec.ao_points);
        end

        function names = timelineChannelNames(~)
            names = ["camera1","camera2","visual_stamp", ...
                "light_Laser405","light_Laser445", ...
                "light_stim_AO_Laser405","light_stim_AO_Laser445", ...
                "light_LEDcyan", ...
                "light_LEDgreen","light_LEDred","dmd_trigger", ...
                "led_flicker_enable","led_flicker_frequency"];
        end

        function renderDaqTimeline(app, plan)
            delete(allchild(app.DaqTimelineAxes));
            hold(app.DaqTimelineAxes, 'on');
            active = find(any(plan.output ~= 0, 1));
            names = plan.channel_names(active);
            displayNames = strings(size(names));
            for nameIndex = 1:numel(names)
                displayNames(nameIndex) = app.timelineDisplayName(names(nameIndex));
            end
            traces = plan.output(:, active);
            controls = repmat("DAQ output", 1, numel(active));
            controls(startsWith(names, "light_stim_AO_") | ...
                names == "led_flicker_frequency") = "DAQ AO (V)";
            metricRows = plan.metrics(active, :);
            visual = app.timelineVisualTrace(plan);
            if visual.included
                names(end + 1) = visual.name;
                displayNames(end + 1) = visual.display_name;
                traces(:, end + 1) = visual.values;
                controls(end + 1) = "Software/PTB";
                metricRows = [metricRows; visual.metrics]; %#ok<AGROW>
            end

            if isempty(names)
                text(app.DaqTimelineAxes, 0.5, 0.5, ...
                    'No active command or planned visual event', ...
                    'HorizontalAlignment', 'center');
                app.DaqTimelineMetricsTable.Data = cell(0, 6);
                app.DaqTimelineAxes.YLim = [-0.08 1.08];
                app.DaqTimelineAxes.YTick = [0 1];
                app.DaqTimelineAxes.YTickLabel = {'OFF','ON'};
                app.DaqTimelineAxes.XLim = app.timelineXLimits(plan);
                app.renderTimelineEpochRegions(plan);
                hold(app.DaqTimelineAxes, 'off');
                return;
            end

            visible = ~ismember(names, app.DaqTimelineHiddenNames);
            [displayTime, displayTraces] = app.timelineDisplayData( ...
                plan.time_seconds, traces);
            lineHandles = gobjects(1, 0);
            for position = find(visible)
                [color, lineStyle, lineWidth] = app.timelineStyle(names(position));
                lineHandles(end + 1) = stairs(app.DaqTimelineAxes, ...
                    displayTime, displayTraces(:, position), ...
                    'Color', color, 'LineStyle', lineStyle, ...
                    'LineWidth', lineWidth, ...
                    'DisplayName', char(displayNames(position))); %#ok<AGROW>
            end
            if isempty(lineHandles)
                text(app.DaqTimelineAxes, 0.5, 0.5, ...
                    'All timeline signals are hidden; use Show to restore them.', ...
                    'HorizontalAlignment', 'center');
            else
                timelineLegend = legend(app.DaqTimelineAxes, lineHandles, ...
                    'Location', 'northoutside', 'Orientation', 'horizontal');
                timelineLegend.AutoUpdate = 'off';
                timelineLegend.NumColumns = min(4, numel(lineHandles));
            end
            if any(startsWith(names, "light_stim_AO_") | ...
                    names == "led_flicker_frequency")
                maximumValue = max(5, max(traces, [], 'all'));
                app.DaqTimelineAxes.YTick = 0:1:ceil(maximumValue);
                app.DaqTimelineAxes.YTickLabel = ...
                    cellstr(string(app.DaqTimelineAxes.YTick));
                app.DaqTimelineAxes.YLim = [-0.08 maximumValue + 0.08];
                ylabel(app.DaqTimelineAxes, 'TTL logic / AO voltage (V)');
            else
                app.DaqTimelineAxes.YTick = [0 1];
                app.DaqTimelineAxes.YTickLabel = {'OFF','ON'};
                app.DaqTimelineAxes.YLim = [-0.08 1.08];
                ylabel(app.DaqTimelineAxes, 'Digital state');
            end
            app.DaqTimelineAxes.XLim = app.timelineXLimits(plan);
            app.renderTimelineEpochRegions(plan);
            hold(app.DaqTimelineAxes, 'off');
            app.DaqTimelineMetricsTable.Data = [ ...
                num2cell(visible(:)), cellstr(displayNames(:)), ...
                cellstr(controls(:)), num2cell(metricRows.PulseCount), ...
                cellstr(compose('%.4g s', metricRows.MinPulseSeconds)), ...
                cellstr(compose('%.4g s', metricRows.TotalHighSeconds))];
        end

        function renderTimelineEpochRegions(app, plan)
            axesHandle = app.DaqTimelineAxes;
            yLimits = axesHandle.YLim;
            left = plan.camera_start_seconds;
            right = plan.camera_end_seconds;
            recordPatch = patch(axesHandle, ...
                [left right right left], ...
                [yLimits(1) yLimits(1) yLimits(2) yLimits(2)], ...
                [0.50 0.88 0.58], 'FaceAlpha', 0.08, ...
                'EdgeColor', 'none', 'HandleVisibility', 'off', ...
                'HitTest', 'off', 'PickableParts', 'none');
            uistack(recordPatch, 'bottom');
            xline(axesHandle, left, ':', 'HandleVisibility', 'off');
            xline(axesHandle, right, ':', 'HandleVisibility', 'off');
        end

        function [displayTime, displayTraces] = timelineDisplayData( ...
                ~, timeSeconds, traces)
            % Timeline rendering uses every compiled DAQ sample. No display
            % decimation is permitted because even transition-aware sampling
            % can hide user-authored points at high output rates.
            displayTime = timeSeconds;
            displayTraces = traces;
        end

        function limits = timelineXLimits(~, plan)
            left = double(plan.time_seconds(1));
            right = double(plan.time_seconds(end));
            if right <= left
                right = left + 0.01;
            end
            limits = [left right];
        end

        function names = timelineDisplayedNames(app, plan)
            active = find(any(plan.output ~= 0, 1));
            names = plan.channel_names(active);
            if app.VisualStimulusController.Armed
                names(end + 1) = "visual_software";
            end
        end

        function visual = timelineVisualTrace(app, plan)
            visual = struct('included', false, 'name', "visual_software", ...
                'display_name', "Grating ON (PTB)", ...
                'values', zeros(size(plan.time_seconds)), ...
                'metrics', table());
            if ~app.VisualStimulusController.Armed
                return;
            end
            spec = app.VisualStimulusController.Spec;
            startTime = app.CameraPreStimSeconds;
            values = zeros(size(plan.time_seconds));
            if ismember(string(spec.program), ...
                    ["drifting_grating","random_drifting_grating"])
                schedule = zoulab.VisualStimulusController.gratingEpochSchedule( ...
                    spec, startTime);
                for epochIndex = 1:height(schedule)
                    values(plan.time_seconds >= schedule.GratingStartSeconds(epochIndex) & ...
                        plan.time_seconds < schedule.GratingEndSeconds(epochIndex)) = 1;
                end
            else
                endTime = startTime + spec.estimated_duration_seconds;
                values(plan.time_seconds >= startTime & ...
                    plan.time_seconds < endTime) = 1;
            end
            visual.included = true;
            visual.values = values;
            visual.metrics = zoulab.StimulusWaveformCompiler.metrics( ...
                values, visual.name, plan.sample_rate_hz);
        end

        function value = visualEpochOrderText(app)
            value = 'not_applicable';
            if ~app.VisualStimulusController.Armed
                return;
            end
            spec = app.VisualStimulusController.Spec;
            if ismember(string(spec.program), ...
                    ["drifting_grating","random_drifting_grating"])
                value = 'isi_then_grating';
            else
                value = 'continuous_program_blocks';
            end
        end

        function timelineVisibilityChanged(app, source, event)
            row = event.Indices(1);
            if event.Indices(2) ~= 1 || row < 1 || row > size(source.Data, 1)
                return;
            end
            displayName = string(source.Data{row, 2});
            names = app.timelineDisplayedNames(app.LastDaqTimelinePlan);
            if row > numel(names)
                return;
            end
            signalName = names(row);
            visible = logical(event.NewData);
            if visible
                app.DaqTimelineHiddenNames( ...
                    app.DaqTimelineHiddenNames == signalName) = [];
            elseif ~ismember(signalName, app.DaqTimelineHiddenNames)
                app.DaqTimelineHiddenNames(end + 1) = signalName;
            end
            app.Logger.log('INFO', 'USER_TIMELINE_SIGNAL_VISIBILITY_CHANGED', ...
                'Signal=%s | Display=%s | Visible=%d', ...
                signalName, displayName, visible);
            app.renderDaqTimeline(app.LastDaqTimelinePlan);
            app.DaqTimelineStatusLabel.Text = sprintf( ...
                'Display updated: %s %s | Visual remains software/PTB, not DAQ.', ...
                displayName, app.onOffText(visible));
            app.persistUserSettings('timeline_signal_visibility_changed');
        end

        function [color, lineStyle, lineWidth] = timelineStyle(~, name)
            lineWidth = 1.5;
            switch string(name)
                case "camera1"
                    color = [0.00 0.45 0.74]; lineStyle = '-';
                case "camera2"
                    color = [0.85 0.33 0.10]; lineStyle = '--';
                case "visual_stamp"
                    color = [0.30 0.75 0.93]; lineStyle = ':';
                case "visual_software"
                    color = [0.10 0.10 0.10]; lineStyle = '-.'; lineWidth = 2.1;
                case "light_Laser405"
                    color = [0.64 0.08 0.68]; lineStyle = '-';
                case "light_Laser445"
                    color = [0.12 0.28 0.85]; lineStyle = '--';
                case "light_stim_AO_Laser405"
                    color = [0.82 0.20 0.82]; lineStyle = '-'; lineWidth = 2.1;
                case "light_stim_AO_Laser445"
                    color = [0.20 0.45 0.95]; lineStyle = '--'; lineWidth = 2.1;
                case "light_LEDcyan"
                    color = [0.00 0.65 0.70]; lineStyle = '-';
                case "light_LEDgreen"
                    color = [0.00 0.55 0.15]; lineStyle = '--';
                case "light_LEDred"
                    color = [0.85 0.10 0.10]; lineStyle = '-.';
                case "led_flicker_enable"
                    color = [0.95 0.45 0.05]; lineStyle = '-'; lineWidth = 2.1;
                case "led_flicker_frequency"
                    color = [0.75 0.20 0.05]; lineStyle = '--'; lineWidth = 2.1;
                otherwise
                    color = [0.93 0.69 0.13]; lineStyle = ':';
            end
        end

        function value = timelineDisplayName(~, name)
            switch string(name)
                case "camera1"
                    value = "Camera 1 START";
                case "camera2"
                    value = "Camera 2 START";
                case "visual_stamp"
                    value = "Visual stamp (DAQ)";
                case "light_Laser405"
                    value = "Laser 405 TTL";
                case "light_Laser445"
                    value = "Laser 445 TTL";
                case "light_stim_AO_Laser405"
                    value = "Laser 405 AO (V)";
                case "light_stim_AO_Laser445"
                    value = "Laser 445 AO (V)";
                case "light_LEDcyan"
                    value = "LED cyan TTL";
                case "light_LEDgreen"
                    value = "LED green TTL";
                case "light_LEDred"
                    value = "LED red TTL";
                case "dmd_trigger"
                    value = "DMD IN1";
                case "led_flicker_enable"
                    value = "LED Flicker enable";
                case "led_flicker_frequency"
                    value = "LED Flicker AO (V)";
                otherwise
                    value = strrep(string(name), '_', ' ');
            end
        end

        function value = visualTimelineStatus(app, included)
            if app.LedFlickerController.Armed
                value = 'LED Flicker (shared finite DAQ plan; no visual stamp)';
            elseif included
                if strcmp(app.visualEpochOrderText(), 'isi_then_grating')
                    value = 'software/PTB (ISI -> grating; not DAQ)';
                else
                    value = 'planned software/PTB (not DAQ)';
                end
            else
                value = 'not armed';
            end
        end

        function value = onOffText(~, enabled)
            if enabled
                value = 'shown';
            else
                value = 'hidden';
            end
        end

        function acquisitionSettingEdited(app, settingName, previousValue, newValue)
            app.Logger.log('INFO', 'USER_ACQUISITION_SETTING_EDITED', ...
                'Setting=%s | Previous=%s | New=%s', settingName, ...
                string(previousValue), string(newValue));
            app.setStatus(sprintf('%s updated to %s.', settingName, string(newValue)));
            app.updateRecordLengthSummary();
            app.scheduleExpensiveUiRefresh( ...
                "acquisition_setting_" + string(settingName), ...
                true, true, true);
            app.persistUserSettings("acquisition_setting_" + string(settingName));
        end

        function recordLengthSourceChanged(app, previousValue, newValue)
            try
                secondsValue = app.resolvedRecordWindowSeconds();
            catch ME
                app.RecordLengthSourceDropDown.Value = previousValue;
                app.updateRecordLengthSummary();
                app.Logger.logException( ...
                    'RECORD_LENGTH_SOURCE_CHANGE_REJECTED', ME);
                app.setStatus("Record length source rejected: " + ...
                    string(ME.message));
                return;
            end
            app.Logger.log('INFO', 'USER_RECORD_LENGTH_SOURCE_CHANGED', ...
                ['Previous=%s | New=%s | ResolvedCameraWindowSeconds=%.9g | ', ...
                 'DmdExcludedFromAuthority=1'], string(previousValue), ...
                string(newValue), secondsValue);
            app.updateRecordLengthSummary();
            app.updateAcquisitionControlAvailability(app.RunState.AcquisitionRunning);
            app.scheduleExpensiveUiRefresh( ...
                'record_length_source_changed', true, true, true);
            app.persistUserSettings('record_length_source_changed');
        end

        function secondsValue = resolvedRecordWindowSeconds(app)
            source = string(app.RecordLengthSourceDropDown.Value);
            switch source
                case "Custom"
                    secondsValue = double(app.RecordDurationField.Value);
                case "Light Stim DO"
                    points = double(app.LightStimDigitalPointTable.Data);
                    if isempty(points) || size(points, 2) < 2 || ...
                            any(~isfinite(points(:, 1)))
                        error('ZouLab:LightStimDoLengthUnavailable', ...
                            ['Light Stim DO cannot define Record length because ', ...
                             'its point table is empty or invalid.']);
                    end
                    secondsValue = double(app.LightStimDelayField.Value) + ...
                        max(points(:, 1));
                otherwise
                    error('ZouLab:UnknownRecordLengthSource', ...
                        'Unknown Record length source: %s.', source);
            end
            if ~isscalar(secondsValue) || ~isfinite(secondsValue) || ...
                    secondsValue < 0.01
                error('ZouLab:InvalidResolvedRecordLength', ...
                    ['Resolved Record length must be at least 0.01 s. ', ...
                     'Current source %s resolves to %.9g s.'], ...
                    source, secondsValue);
            end
        end

        function updateRecordLengthSummary(app)
            if isempty(app.RecordLengthSummaryLabel) || ...
                    ~isvalid(app.RecordLengthSummaryLabel)
                return;
            end
            try
                secondsValue = app.resolvedRecordWindowSeconds();
                app.RecordLengthSummaryLabel.Text = sprintf( ...
                    '%.6g s (%s)', secondsValue, ...
                    string(app.RecordLengthSourceDropDown.Value));
                app.RecordLengthSummaryLabel.FontColor = [0.08 0.45 0.18];
            catch ME
                app.RecordLengthSummaryLabel.Text = ...
                    "Invalid: " + string(ME.message);
                app.RecordLengthSummaryLabel.FontColor = [0.78 0.18 0.12];
            end
        end

        function acquisitionModeChanged(app, previousValue, newValue, writeLog)
            if nargin < 4
                writeLog = true;
            end
            mode = string(newValue);
            app.updateAcquisitionControlAvailability(app.RunState.AcquisitionRunning);
            if writeLog
                app.Logger.log('INFO', 'USER_ACQUISITION_MODE_CHANGED', ...
                    'Previous=%s | New=%s', string(previousValue), mode);
                app.setStatus("Acquisition mode: " + mode);
                app.persistUserSettings('acquisition_mode_changed');
            end
            app.updateVisualStimulusStatus();
            app.updateRecordLengthSummary();
            if writeLog
                app.scheduleExpensiveUiRefresh( ...
                    'acquisition_mode_changed', true, true, true);
            end
        end

        function updateAcquisitionStorageEstimate(app, reason, writeLog)
            if nargin < 3
                writeLog = true;
            end
            if isempty(app.AcquisitionStorageEstimateLabel) || ...
                    ~isvalid(app.AcquisitionStorageEstimateLabel)
                return;
            end
            try
                estimate = app.currentAcquisitionStorageEstimate();
                requiredText = app.formatStorageBytes( ...
                    estimate.required_peak_bytes);
                if isfinite(estimate.free_disk_bytes)
                    freeText = app.formatStorageBytes(estimate.free_disk_bytes);
                    enough = estimate.free_disk_bytes >= ...
                        estimate.required_peak_bytes;
                    if enough
                        verdict = 'OK';
                        app.AcquisitionStorageEstimateLabel.FontColor = ...
                            [0.08 0.48 0.18];
                    else
                        verdict = 'INSUFFICIENT';
                        app.AcquisitionStorageEstimateLabel.FontColor = ...
                            [0.78 0.12 0.10];
                    end
                    app.AcquisitionStorageEstimateLabel.Text = sprintf( ...
                        'Space: %s needed / %s free — %s', ...
                        requiredText, freeText, verdict);
                else
                    enough = false;
                    app.AcquisitionStorageEstimateLabel.Text = sprintf( ...
                        'Space: %s needed / free unknown', requiredText);
                    app.AcquisitionStorageEstimateLabel.FontColor = ...
                        [0.78 0.45 0.05];
                end
                app.AcquisitionStorageEstimateLabel.Tooltip = sprintf( ...
                    ['Whole acquisition estimate (%s, %d cycle(s)). ', ...
                     'All-BIN/final data: %s. Required disk peak: %s. ', ...
                     'Parallel TIFF peak uses all BIN plus up to %d ', ...
                     'simultaneously active Cycle-Camera TIFF units, then ', ...
                     '10%% margin. Estimated conversion process memory: %s. ', ...
                     'Disk checked at: %s. ', ...
                     'Frame basis: %s.'], ...
                    estimate.mode, estimate.cycles, ...
                    app.formatStorageBytes(estimate.final_data_bytes), ...
                    requiredText, estimate.conversion_worker_count, ...
                    app.formatStorageBytes( ...
                    estimate.estimated_conversion_memory_bytes), ...
                    estimate.disk_probe_path, ...
                    strjoin(string(estimate.frame_count_sources), ', '));
                if writeLog && ~app.ApplyingUserSettings
                    app.Logger.log('INFO', ...
                        'ACQUISITION_STORAGE_ESTIMATE_UPDATED', ...
                        ['Reason=%s | Mode=%s | Cameras=%s | Cycles=%d | ', ...
                         'FramesPerCameraPerCycle=%s | FrameCountSources=%s | ', ...
                         'RawBytesPerCycle=%.0f | FinalDataBytes=%.0f | ', ...
                         'LargestConversionUnitBytes=%.0f | ', ...
                         'ConversionWorkers=%d | ', ...
                         'EstimatedConversionMemoryBytes=%.0f | ', ...
                         'PeakBeforeMarginBytes=%.0f | SafetyMargin=1.1 | ', ...
                         'RequiredPeakBytes=%.0f | FreeDiskBytes=%s | ', ...
                         'EnoughSpace=%d | SaveRoot=%s | DiskProbePath=%s'], ...
                        string(reason), estimate.mode, ...
                        mat2str(estimate.cameras), estimate.cycles, ...
                        mat2str(estimate.frames_per_camera_per_cycle), ...
                        strjoin(string(estimate.frame_count_sources), ','), ...
                        estimate.raw_bytes_per_cycle, ...
                        estimate.final_data_bytes, ...
                        estimate.largest_conversion_unit_bytes, ...
                        estimate.conversion_worker_count, ...
                        estimate.estimated_conversion_memory_bytes, ...
                        estimate.peak_before_margin_bytes, ...
                        estimate.required_peak_bytes, ...
                        app.diagnosticValueText(estimate.free_disk_bytes), ...
                        enough, estimate.save_root, estimate.disk_probe_path);
                end
            catch ME
                app.AcquisitionStorageEstimateLabel.Text = ...
                    'Space: check settings/save root';
                app.AcquisitionStorageEstimateLabel.FontColor = ...
                    [0.78 0.12 0.10];
                app.AcquisitionStorageEstimateLabel.Tooltip = char(string(ME.message));
                if writeLog && ~app.ApplyingUserSettings
                    app.Logger.log('WARNING', ...
                        'ACQUISITION_STORAGE_ESTIMATE_FAILED', ...
                        'Reason=%s | Identifier=%s | Message=%s', ...
                        string(reason), string(ME.identifier), string(ME.message));
                end
            end
        end

        function estimate = currentAcquisitionStorageEstimate(app)
            indices = app.activeCameraIndices();
            rois = cell(1, numel(indices));
            for position = 1:numel(indices)
                rois{position} = zoulab.UserSettings.parseROI( ...
                    app.ROIFields{indices(position)}.Value);
            end
            cycles = max(1, round(app.CycleCountField.Value));
            mode = lower(strrep(char(string( ...
                app.AcquisitionModeDropDown.Value)), ' ', '_'));
            switch mode
                case 'record'
                    recordWindow = app.resolvedRecordWindowSeconds();
                    [frameCounts, sources] = ...
                        app.estimateStorageFrameCounts(indices, recordWindow);
                    convertToTiff = logical(app.RecordTiffCheckBox.Value);
                case 'time_lapse'
                    frameCounts = repmat(max(1, round( ...
                        app.TLPointsField.Value)), 1, numel(indices));
                    sources = repmat("time_lapse_points", 1, numel(indices));
                    convertToTiff = false;
                otherwise
                    frameCounts = ones(1, numel(indices));
                    sources = repmat("single_snap", 1, numel(indices));
                    convertToTiff = false;
            end
            estimate = app.buildStorageEstimate(mode, indices, rois, ...
                frameCounts, sources, cycles, convertToTiff, ...
                string(app.RootPathField.Value), false);
        end

        function [counts, sources] = estimateStorageFrameCounts( ...
                app, indices, durationSeconds)
            counts = zeros(1, numel(indices));
            sources = strings(1, numel(indices));
            for position = 1:numel(indices)
                cameraIndex = indices(position);
                if app.SimulationMode
                    fps = app.SimulationRecordFPS;
                    sources(position) = "simulation_fixed_fps";
                elseif isfinite(app.StreamFPS(cameraIndex)) && ...
                        app.StreamFPS(cameraIndex) > 0
                    fps = app.StreamFPS(cameraIndex);
                    sources(position) = "measured_stream_fps";
                elseif ~app.SettingsDirty(cameraIndex) && ...
                        isfinite(app.expectedStreamFPS(cameraIndex))
                    fps = app.expectedStreamFPS(cameraIndex);
                    sources(position) = "validated_expected_fps";
                else
                    exposureSeconds = max(1e-9, ...
                        app.ExposureFields{cameraIndex}.Value / 1000);
                    fps = min(400, 1 / exposureSeconds);
                    sources(position) = ...
                        "conservative_400_fps_or_exposure_limit";
                end
                counts(position) = max(1, round(durationSeconds * fps));
            end
        end

        function estimate = buildStorageEstimate(app, mode, indices, rois, ...
                frameCounts, sources, cycles, convertToTiff, saveRoot, ...
                createSaveRoot)
            bytesPerFrame = zeros(1, numel(indices));
            for position = 1:numel(indices)
                roi = double(rois{position});
                bytesPerFrame(position) = prod(roi(3:4)) * 2;
            end
            rawPerCycle = sum(bytesPerFrame .* frameCounts);
            finalBytes = rawPerCycle * cycles;
            transientBytes = 0;
            largestUnitBytes = 0;
            conversionWorkerCount = 0;
            estimatedConversionMemoryBytes = 0;
            if strcmp(mode, 'record') && convertToTiff
                % All BIN files exist when conversion begins.  Each worker owns
                % one Cycle-by-Camera TIFF, so partial outputs from up to N
                % active units can overlap the still-retained BIN dataset.
                unitBytes = repmat(bytesPerFrame .* frameCounts, 1, cycles);
                largestUnitBytes = max(unitBytes, [], 'omitnan');
                selection = zoulab.ParallelTiffConverter. ...
                    selectWorkerCount(numel(unitBytes));
                conversionWorkerCount = selection.worker_count;
                sortedUnitBytes = sort(unitBytes, 'descend');
                transientBytes = sum(sortedUnitBytes( ...
                    1:min(conversionWorkerCount, numel(sortedUnitBytes))));
                estimatedConversionMemoryBytes = ...
                    selection.estimated_process_memory_bytes;
            end
            peakBeforeMargin = finalBytes + transientBytes;
            requiredPeak = peakBeforeMargin * 1.1;
            [freeDisk, probePath] = app.queryDiskSpace( ...
                saveRoot, createSaveRoot);
            estimate = struct( ...
                'mode', char(mode), ...
                'cameras', indices, ...
                'cycles', cycles, ...
                'bytes_per_frame', bytesPerFrame, ...
                'frames_per_camera_per_cycle', frameCounts, ...
                'frame_count_sources', {cellstr(sources)}, ...
                'raw_bytes_per_cycle', rawPerCycle, ...
                'final_data_bytes', finalBytes, ...
                'largest_conversion_unit_bytes', largestUnitBytes, ...
                'conversion_worker_count', conversionWorkerCount, ...
                'estimated_conversion_memory_bytes', ...
                    estimatedConversionMemoryBytes, ...
                'transient_conversion_bytes', transientBytes, ...
                'peak_before_margin_bytes', peakBeforeMargin, ...
                'required_peak_bytes', requiredPeak, ...
                'free_disk_bytes', freeDisk, ...
                'save_root', char(saveRoot), ...
                'disk_probe_path', char(probePath), ...
                'safety_margin_multiplier', 1.1, ...
                'convert_record_to_tiff', logical(convertToTiff));
        end

        function [freeDisk, probePath] = queryDiskSpace(~, saveRoot, createSaveRoot)
            saveRoot = string(strtrim(char(saveRoot)));
            if strlength(saveRoot) == 0
                error('ZouLab:EmptySaveRoot', ...
                    'Choose a Save root before acquisition.');
            end
            if createSaveRoot && ~exist(saveRoot, 'dir')
                mkdir(saveRoot);
            end
            probePath = saveRoot;
            while ~exist(probePath, 'dir')
                parentPath = string(fileparts(char(probePath)));
                if strlength(parentPath) == 0 || parentPath == probePath
                    probePath = "";
                    break;
                end
                probePath = parentPath;
            end
            if strlength(probePath) == 0
                freeDisk = NaN;
                return;
            end
            freeDisk = double(java.io.File(char(probePath)).getUsableSpace());
            if freeDisk <= 0
                freeDisk = NaN;
            end
        end

        function textValue = formatStorageBytes(~, bytes)
            if ~isfinite(bytes)
                textValue = 'unknown';
            elseif bytes >= 1024^4
                textValue = sprintf('%.2f TB', bytes / 1024^4);
            elseif bytes >= 1024^3
                textValue = sprintf('%.2f GB', bytes / 1024^3);
            elseif bytes >= 1024^2
                textValue = sprintf('%.1f MB', bytes / 1024^2);
            elseif bytes >= 1024
                textValue = sprintf('%.1f KB', bytes / 1024);
            else
                textValue = sprintf('%.0f B', bytes);
            end
        end

        function visualProgramChanged(app, previousValue, newValue, writeLog)
            if nargin < 4
                writeLog = true;
            end
            if app.VisualStimulusController.Armed
                app.disarmVisualStimulus('configuration_changed');
            end
            switch string(newValue)
                case {"drifting_grating","random_drifting_grating"}
                    app.VisualDurationField.Value = 2;
                    app.VisualFrequencyField.Value = 2;
                    app.VisualISIField.Value = 1;
                    app.VisualRepeatsField.Value = 1;
                    app.VisualSequenceLabel.Text = 'Angles (deg)';
                    app.VisualSequenceField.Value = '[0 45 90 135 180 225 270 315]';
                case "gray_blue_gray"
                    app.VisualDurationField.Value = 1;
                    app.VisualFrequencyField.Value = 1;
                    app.VisualISIField.Value = 0;
                    app.VisualRepeatsField.Value = 1;
                    app.VisualSequenceLabel.Text = 'Block durations (s)';
                    app.VisualSequenceField.Value = '[5 5 5]';
                case "gray_white_gray_black"
                    app.VisualDurationField.Value = 1;
                    app.VisualFrequencyField.Value = 1;
                    app.VisualISIField.Value = 0;
                    app.VisualRepeatsField.Value = 3;
                    app.VisualSequenceLabel.Text = 'Block durations (s)';
                    app.VisualSequenceField.Value = '[3 3 3 3]';
                case "flash"
                    app.VisualDurationField.Value = 1;
                    app.VisualFrequencyField.Value = 1;
                    app.VisualISIField.Value = 0;
                    app.VisualRepeatsField.Value = 1;
                    app.VisualSequenceLabel.Text = 'Block durations (s)';
                    app.VisualSequenceField.Value = '[2 0.05 5.95]';
                case "white_black_flicker"
                    app.VisualDurationField.Value = 30;
                    app.VisualFrequencyField.Value = 5;
                    app.VisualISIField.Value = 0;
                    app.VisualRepeatsField.Value = 1;
                    app.VisualSequenceLabel.Text = 'Unused';
                    app.VisualSequenceField.Value = '[0]';
                case "step_flicker"
                    app.VisualDurationField.Value = 5;
                    app.VisualFrequencyField.Value = 1;
                    app.VisualISIField.Value = 0;
                    app.VisualRepeatsField.Value = 1;
                    app.VisualSequenceLabel.Text = 'Frequencies (Hz)';
                    app.VisualSequenceField.Value = '[0 1 5 10 30]';
                case "contrast_reverse"
                    app.VisualDurationField.Value = 30;
                    app.VisualFrequencyField.Value = 2;
                    app.VisualISIField.Value = 0;
                    app.VisualRepeatsField.Value = 1;
                    app.VisualSequenceLabel.Text = 'Angle (deg)';
                    app.VisualSequenceField.Value = '[0]';
            end
            app.updateVisualConfigurationSummary();
            app.scheduleExpensiveUiRefresh( ...
                'visual_program_changed', true, true, writeLog);
            if writeLog
                app.Logger.log('INFO', 'USER_VISUAL_PROGRAM_CHANGED', ...
                    ['Previous=%s | New=%s | PresetValuesLoaded=1 | ', ...
                     'RequiresExplicitArm=1'], string(previousValue), string(newValue));
                app.persistUserSettings('visual_program_changed');
            end
        end

        function visualSettingEdited(app, settingName, previousValue, newValue)
            if app.VisualStimulusController.Armed
                app.disarmVisualStimulus('configuration_changed');
            end
            app.Logger.log('INFO', 'USER_VISUAL_SETTING_EDITED', ...
                'Setting=%s | Previous=%s | New=%s | VisualStimDisarmed=1', ...
                settingName, string(previousValue), string(newValue));
            app.updateVisualConfigurationSummary();
            if string(settingName) == "ScreenIndex"
                app.updateVisualScreenStatus();
            end
            app.scheduleExpensiveUiRefresh( ...
                "visual_setting_" + string(settingName), true, true, true);
            app.persistUserSettings("visual_setting_" + string(settingName));
        end

        function advancedTimingEdited(app, settingName, previousValue, newValue)
            if app.VisualStimulusController.Armed
                app.disarmVisualStimulus('advanced_timing_changed');
            end
            switch string(settingName)
                case "CameraPreStimSeconds"
                    app.CameraPreStimSeconds = newValue;
                case "CameraPostStimSeconds"
                    app.CameraPostStimSeconds = newValue;
                case "LightLeadSeconds"
                    app.LightLeadSeconds = newValue;
                case "LightTailSeconds"
                    app.LightTailSeconds = newValue;
            end
            app.Logger.log('INFO', 'USER_ADVANCED_TIMING_EDITED', ...
                ['Setting=%s | Previous=%.9g | New=%.9g | ', ...
                 'VisualStimDisarmed=1'], settingName, previousValue, newValue);
            app.updateVisualConfigurationSummary();
            app.scheduleExpensiveUiRefresh( ...
                "advanced_timing_" + string(settingName), true, true, true);
            app.persistUserSettings("advanced_timing_" + string(settingName));
        end

        function advancedVisualDisplayEdited(app, settingName, source, event)
            previousValue = event.PreviousValue;
            newValue = source.Value;
            try
                if app.VisualStimulusController.Armed
                    app.disarmVisualStimulus('advanced_ptb_display_changed');
                end
                config = app.visualConfiguration();
                zoulab.VisualStimulusController.buildSpec(config);
                app.VisualStimulusController.applyStandbyAppearance( ...
                    config, app.Logger);
                app.Logger.log('SUCCESS', 'USER_ADVANCED_PTB_SETTING_EDITED', ...
                    ['Setting=%s | Previous=%s | New=%s | ', ...
                     'VisualStimDisarmed=1 | StandbyUpdated=%d'], ...
                    settingName, string(previousValue), string(newValue), ...
                    app.VisualStimulusController.ScreenReady);
                app.updateVisualConfigurationSummary();
                app.scheduleExpensiveUiRefresh( ...
                    "advanced_ptb_" + string(settingName), true, true, true);
                app.persistUserSettings( ...
                    "advanced_ptb_" + string(settingName));
            catch ME
                source.Value = previousValue;
                app.Logger.logException('ADVANCED_PTB_SETTING_REJECTED', ME);
                app.handleError('ADVANCED_PTB_SETTING_REJECTED', ME, ...
                    app.VisualScreenStatusLabel);
            end
        end

        function config = visualConfiguration(app)
            config = struct( ...
                'program', char(string(app.VisualProgramDropDown.Value)), ...
                'screen_index', app.VisualScreenField.Value, ...
                'duration_seconds', app.VisualDurationField.Value, ...
                'frequency_hz', app.VisualFrequencyField.Value, ...
                'isi_seconds', app.VisualISIField.Value, ...
                'repeats', app.VisualRepeatsField.Value, ...
                'sequence', zoulab.UserSettings.parseNumericVector(app.VisualSequenceField.Value), ...
                'amplitude', app.VisualAmplitudeField.Value, ...
                'spatial_frequency_cpd', ...
                    app.VisualSpatialFrequencyField.Value, ...
                'viewing_distance_cm', app.VisualViewingDistanceField.Value, ...
                'screen_width_cm', app.VisualScreenWidthField.Value, ...
                'idle_color', zoulab.UserSettings.parseRgbValue( ...
                    app.VisualIdleColorField.Value, 'Idle RGB'), ...
                'gray_color', zoulab.UserSettings.parseRgbValue( ...
                    app.VisualBaselineColorField.Value, 'ISI/baseline RGB'), ...
                'white_color', zoulab.UserSettings.parseRgbValue( ...
                    app.VisualWhiteColorField.Value, 'White RGB'), ...
                'black_color', zoulab.UserSettings.parseRgbValue( ...
                    app.VisualBlackColorField.Value, 'Black RGB'), ...
                'blue_color', zoulab.UserSettings.parseRgbValue( ...
                    app.VisualBlueColorField.Value, 'Blue RGB'), ...
                'initial_phase_deg', app.VisualInitialPhaseField.Value, ...
                'flip_deadline_fraction', app.VisualFlipDeadlineField.Value);
        end

        function applyVisualConfiguration(app, config, source, applyStandby)
            if nargin < 4
                applyStandby = true;
            end
            zoulab.VisualStimulusController.buildSpec(config);
            previousApplying = app.ApplyingUserSettings;
            app.ApplyingUserSettings = true;
            cleanup = onCleanup(@() app.restoreApplyingUserSettings( ...
                previousApplying));
            app.VisualProgramDropDown.Value = char(string(config.program));
            app.VisualScreenField.Value = config.screen_index;
            app.VisualDurationField.Value = config.duration_seconds;
            app.VisualFrequencyField.Value = config.frequency_hz;
            app.VisualISIField.Value = config.isi_seconds;
            app.VisualRepeatsField.Value = config.repeats;
            app.VisualSequenceField.Value = mat2str(double(config.sequence(:).'));
            app.VisualAmplitudeField.Value = config.amplitude;
            app.VisualSpatialFrequencyField.Value = config.spatial_frequency_cpd;
            app.VisualViewingDistanceField.Value = config.viewing_distance_cm;
            app.VisualScreenWidthField.Value = config.screen_width_cm;
            displayConfig = zoulab.VisualStimulusController. ...
                normalizeDisplayConfig(config);
            app.VisualIdleColorField.Value = mat2str(displayConfig.idle_color, 6);
            app.VisualBaselineColorField.Value = mat2str( ...
                displayConfig.gray_color, 6);
            app.VisualWhiteColorField.Value = mat2str( ...
                displayConfig.white_color, 6);
            app.VisualBlackColorField.Value = mat2str( ...
                displayConfig.black_color, 6);
            app.VisualBlueColorField.Value = mat2str( ...
                displayConfig.blue_color, 6);
            app.VisualInitialPhaseField.Value = ...
                displayConfig.initial_phase_deg;
            app.VisualFlipDeadlineField.Value = ...
                displayConfig.flip_deadline_fraction;
            if applyStandby
                app.VisualStimulusController.applyStandbyAppearance( ...
                    displayConfig, app.Logger);
            end
            app.updateVisualSequenceLabel();
            app.updateVisualConfigurationSummary();
            app.updateVisualScreenStatus();
            app.Logger.log('SUCCESS', 'VISUAL_CONFIGURATION_APPLIED', ...
                ['Source=%s | StandbyAppearanceApplied=%d | ', ...
                 'HardwareCommandIssued=%d | Config=%s'], ...
                source, applyStandby, applyStandby && ...
                app.VisualStimulusController.ScreenReady, jsonencode(config));
        end

        function updateVisualSequenceLabel(app)
            switch string(app.VisualProgramDropDown.Value)
                case {"drifting_grating","random_drifting_grating"}
                    app.VisualSequenceLabel.Text = 'Angles (deg)';
                case {"gray_blue_gray","gray_white_gray_black","flash"}
                    app.VisualSequenceLabel.Text = 'Block durations (s)';
                case "step_flicker"
                    app.VisualSequenceLabel.Text = 'Frequencies (Hz)';
                case "contrast_reverse"
                    app.VisualSequenceLabel.Text = 'Angle (deg)';
                otherwise
                    app.VisualSequenceLabel.Text = 'Unused';
            end
        end

        function refreshVisualPresetDropDown(app)
            library = app.VisualPresets.listPresets();
            names = string({library.name});
            current = "";
            if ~isempty(app.VisualPresetDropDown) && ...
                    isvalid(app.VisualPresetDropDown)
                current = string(app.VisualPresetDropDown.Value);
            end
            app.VisualPresetDropDown.Items = cellstr(names);
            if any(strcmpi(names, current))
                app.VisualPresetDropDown.Value = char(names(find( ...
                    strcmpi(names, current), 1)));
            elseif ~isempty(names)
                app.VisualPresetDropDown.Value = char(names(1));
            end
        end

        function visualPresetSelected(app, previousValue, newValue)
            app.Logger.log('INFO', 'USER_VISUAL_PRESET_SELECTED', ...
                'Previous=%s | New=%s | Loaded=0', ...
                string(previousValue), string(newValue));
            app.VisualPresetStatusLabel.Text = ...
                "Selected: " + string(newValue) + " | click Load";
            app.VisualPresetStatusLabel.FontColor = [0.75 0.45 0.05];
        end

        function loadVisualPreset(app)
            name = string(app.VisualPresetDropDown.Value);
            app.beginAction('LOAD_VISUAL_PRESET', "Loading " + name + "...", ...
                app.VisualPresetStatusLabel);
            try
                app.requireIdentity('load visual preset');
                if app.VisualStimulusController.Armed
                    app.disarmVisualStimulus('preset_loaded');
                end
                entry = app.VisualPresets.getPreset(name);
                app.applyVisualConfiguration(entry.value, ...
                    "preset:" + string(entry.name));
                app.persistUserSettings('visual_preset_loaded');
                app.finishAction('LOAD_VISUAL_PRESET', true, ...
                    "Loaded: " + string(entry.name), ...
                    app.VisualPresetStatusLabel);
            catch ME
                app.handleError('LOAD_VISUAL_PRESET_FAILED', ME, ...
                    app.VisualPresetStatusLabel);
            end
        end

        function saveVisualPresetAs(app)
            app.beginAction('SAVE_VISUAL_PRESET_AS', ...
                'Waiting for a preset name...', app.VisualPresetStatusLabel);
            try
                app.requireIdentity('save visual preset');
                answer = inputdlg('Preset name:', 'Save Visual Preset As', ...
                    [1 48], {char(app.VisualPresetDropDown.Value)});
                if isempty(answer)
                    app.finishAction('SAVE_VISUAL_PRESET_AS', false, ...
                        'Preset save cancelled.', app.VisualPresetStatusLabel);
                    return;
                end
                entry = app.VisualPresets.savePresetAs(answer{1}, ...
                    app.visualConfiguration());
                app.refreshVisualPresetDropDown();
                app.VisualPresetDropDown.Value = entry.name;
                app.finishAction('SAVE_VISUAL_PRESET_AS', true, ...
                    "Saved: " + string(entry.name), app.VisualPresetStatusLabel);
            catch ME
                app.handleError('SAVE_VISUAL_PRESET_FAILED', ME, ...
                    app.VisualPresetStatusLabel);
            end
        end

        function updateVisualPreset(app)
            name = string(app.VisualPresetDropDown.Value);
            app.beginAction('UPDATE_VISUAL_PRESET', "Updating " + name + "...", ...
                app.VisualPresetStatusLabel);
            try
                app.requireIdentity('update visual preset');
                app.VisualPresets.updatePreset(name, app.visualConfiguration());
                app.finishAction('UPDATE_VISUAL_PRESET', true, ...
                    "Updated: " + name, app.VisualPresetStatusLabel);
            catch ME
                app.handleError('UPDATE_VISUAL_PRESET_FAILED', ME, ...
                    app.VisualPresetStatusLabel);
            end
        end

        function renameVisualPreset(app)
            oldName = string(app.VisualPresetDropDown.Value);
            app.beginAction('RENAME_VISUAL_PRESET', ...
                "Renaming " + oldName + "...", app.VisualPresetStatusLabel);
            try
                app.requireIdentity('rename visual preset');
                answer = inputdlg('New preset name:', 'Rename Visual Preset', ...
                    [1 48], {char(oldName)});
                if isempty(answer)
                    app.finishAction('RENAME_VISUAL_PRESET', false, ...
                        'Preset rename cancelled.', app.VisualPresetStatusLabel);
                    return;
                end
                entry = app.VisualPresets.renamePreset(oldName, answer{1});
                app.refreshVisualPresetDropDown();
                app.VisualPresetDropDown.Value = entry.name;
                app.finishAction('RENAME_VISUAL_PRESET', true, ...
                    "Renamed: " + string(entry.name), app.VisualPresetStatusLabel);
            catch ME
                app.handleError('RENAME_VISUAL_PRESET_FAILED', ME, ...
                    app.VisualPresetStatusLabel);
            end
        end

        function deleteVisualPreset(app)
            name = string(app.VisualPresetDropDown.Value);
            app.beginAction('DELETE_VISUAL_PRESET', ...
                "Delete requested: " + name, app.VisualPresetStatusLabel);
            try
                app.requireIdentity('delete visual preset');
                choice = uiconfirm(app.UIFigure, ...
                    "Delete user preset '" + name + "'?", ...
                    'Confirm Delete', 'Options', {'Delete','Cancel'}, ...
                    'DefaultOption', 2, 'CancelOption', 2);
                if strcmp(choice, 'Cancel')
                    app.finishAction('DELETE_VISUAL_PRESET', false, ...
                        'Preset delete cancelled.', app.VisualPresetStatusLabel);
                    return;
                end
                app.VisualPresets.deletePreset(name);
                app.refreshVisualPresetDropDown();
                app.finishAction('DELETE_VISUAL_PRESET', true, ...
                    "Deleted: " + name, app.VisualPresetStatusLabel);
            catch ME
                app.handleError('DELETE_VISUAL_PRESET_FAILED', ME, ...
                    app.VisualPresetStatusLabel);
            end
        end

        function importLegacyVisualPreset(app)
            app.beginAction('IMPORT_LEGACY_VISUAL_PRESET', ...
                'Opening legacy stimulus file chooser...', ...
                app.VisualPresetStatusLabel);
            try
                app.requireIdentity('import legacy visual stimulus');
                [file, folder] = uigetfile( ...
                    {'*.mat;*.json','MAT/JSON stimulus files'}, ...
                    'Choose method_manifest or stimSpec file');
                if isequal(file, 0)
                    app.finishAction('IMPORT_LEGACY_VISUAL_PRESET', false, ...
                        'Legacy import cancelled.', app.VisualPresetStatusLabel);
                    return;
                end
                filePath = fullfile(folder, file);
                config = zoulab.VisualStimulusController.loadLegacyConfig(filePath);
                app.applyVisualConfiguration(config, "legacy:" + string(filePath));
                app.persistUserSettings('legacy_visual_imported');
                app.finishAction('IMPORT_LEGACY_VISUAL_PRESET', true, ...
                    'Legacy stimulus loaded; use Save As to keep it as a user preset.', ...
                    app.VisualPresetStatusLabel);
            catch ME
                app.handleError('IMPORT_LEGACY_VISUAL_PRESET_FAILED', ME, ...
                    app.VisualPresetStatusLabel);
            end
        end

        function visualPreviewModeChanged(app, previousValue, newValue)
            app.VisualPreviewAngleField.Enable = app.onOff( ...
                string(newValue) == "fixed");
            app.Logger.log('INFO', 'USER_VISUAL_PREVIEW_MODE_CHANGED', ...
                'Previous=%s | New=%s', string(previousValue), string(newValue));
            app.persistUserSettings('visual_preview_mode_changed');
        end

        function setupVisualScreen(app)
            screenIndex = app.VisualScreenField.Value;
            app.beginAction('SETUP_PTB_SCREEN', ...
                sprintf('Setting PTB Screen %d...', screenIndex), ...
                app.VisualScreenStatusLabel);
            try
                app.requireIdentity('set PTB Screen');
                if app.RunState.AcquisitionRunning || app.VisualPreviewRunning || ...
                        app.VisualStimulusController.Armed
                    error('ZouLab:VisualScreenBusy', ...
                        ['Stop playback/acquisition and Disarm Visual Stimulus ', ...
                         'before changing the PTB Screen.']);
                end
                app.VisualScreenSetupButton.Enable = 'off';
                app.VisualStimulusController.setupScreen( ...
                    screenIndex, app.SimulationMode, app.Logger, ...
                    app.visualConfiguration());
                app.updateAcquisitionControlAvailability(false);
                app.updateVisualScreenStatus();
                app.persistUserSettings('ptb_screen_setup');
                app.finishAction('SETUP_PTB_SCREEN', true, ...
                    sprintf('PTB Screen %d READY; Play was not started.', ...
                    screenIndex), app.VisualScreenStatusLabel);
            catch ME
                app.updateVisualScreenStatus();
                if strcmp(ME.identifier, 'ZouLab:OperatorRequired')
                    app.identityBlocked(app.VisualScreenStatusLabel);
                else
                    app.handleError('SETUP_PTB_SCREEN_FAILED', ME, ...
                        app.VisualScreenStatusLabel);
                end
            end
        end

        function closeVisualScreen(app, reason)
            app.beginAction('CLOSE_PTB_SCREEN', ...
                'Closing PTB Screen...', app.VisualScreenStatusLabel);
            try
                if app.RunState.AcquisitionRunning || app.VisualPreviewRunning || ...
                        app.VisualStimulusController.Running
                    error('ZouLab:VisualScreenBusy', ...
                        'Stop visual playback or acquisition before closing the PTB Screen.');
                end
                if app.VisualStimulusController.Armed
                    app.disarmVisualStimulus('ptb_screen_close');
                end
                app.VisualStimulusController.closeScreen(app.Logger);
                app.updateAcquisitionControlAvailability(false);
                app.updateVisualScreenStatus();
                app.finishAction('CLOSE_PTB_SCREEN', true, ...
                    "PTB Screen closed (" + string(reason) + ").", ...
                    app.VisualScreenStatusLabel);
            catch ME
                app.updateVisualScreenStatus();
                app.handleError('CLOSE_PTB_SCREEN_FAILED', ME, ...
                    app.VisualScreenStatusLabel);
            end
        end

        function updateVisualScreenStatus(app)
            if isempty(app.VisualScreenStatusLabel) || ...
                    ~isvalid(app.VisualScreenStatusLabel)
                return;
            end
            ready = app.VisualStimulusController.ScreenReady;
            selected = app.VisualScreenField.Value;
            if ready && app.VisualStimulusController.ScreenIndex == selected
                app.VisualScreenLamp.Color = [0.10 0.75 0.20];
                app.VisualScreenStatusLabel.Text = sprintf( ...
                    'READY: Screen %d | %.3f Hz | idle RGB %s', selected, ...
                    1 / app.VisualStimulusController.Runtime.ifi, ...
                    mat2str(app.VisualStimulusController.DisplayConfig.idle_color, 3));
                app.VisualScreenStatusLabel.FontColor = [0.08 0.55 0.18];
            elseif ready
                app.VisualScreenLamp.Color = [0.95 0.65 0.10];
                app.VisualScreenStatusLabel.Text = sprintf( ...
                    'Screen %d open; selected %d — click Set Screen', ...
                    app.VisualStimulusController.ScreenIndex, selected);
                app.VisualScreenStatusLabel.FontColor = [0.75 0.45 0.05];
            else
                app.VisualScreenLamp.Color = [0.65 0.65 0.65];
                app.VisualScreenStatusLabel.Text = ...
                    'NOT SET — set before Play or Arm';
                app.VisualScreenStatusLabel.FontColor = [0.72 0.18 0.12];
            end
            setupEditable = app.IdentityConfirmed && ~app.RunState.AcquisitionRunning && ...
                ~app.VisualPreviewRunning && ...
                ~app.VisualStimulusController.Armed;
            closeAllowed = app.IdentityConfirmed && ~app.RunState.AcquisitionRunning && ...
                ~app.VisualPreviewRunning && ...
                ~app.VisualStimulusController.Running;
            app.VisualScreenField.Editable = app.onOff(setupEditable);
            app.VisualScreenSetupButton.Enable = app.onOff(setupEditable);
            % Closing an armed screen is valid: closeVisualScreen first
            % disarms the stimulus, then closes PTB.  Do not disable the
            % only path that performs that safe transition.
            app.VisualScreenCloseButton.Enable = ...
                app.onOff(ready && closeAllowed);
        end

        function playVisualPreview(app)
            mode = string(app.VisualPreviewModeDropDown.Value);
            app.beginAction('PLAY_VISUAL_PREVIEW', ...
                "Starting " + mode + " stimulus preview...", ...
                app.VisualSummaryLabel);
            try
                app.requireIdentity('play visual stimulus preview');
                if app.RunState.AcquisitionRunning || ~isempty(app.TimeLapseTimer)
                    error('ZouLab:VisualPreviewAcquisitionBusy', ...
                        'Stop Acquisition or Time Lapse before preview playback.');
                end
                if app.VisualStimulusController.Armed
                    error('ZouLab:VisualPreviewArmed', ...
                        'Disarm the acquisition stimulus before preview playback.');
                end
                if ~app.VisualStimulusController.ScreenReady || ...
                        app.VisualStimulusController.ScreenIndex ~= ...
                        app.VisualScreenField.Value
                    error('ZouLab:VisualScreenNotReady', ...
                        ['Set the selected PTB Screen before Play Preview. ', ...
                         'Play no longer opens or changes the Screen.']);
                end
                app.VisualPreviewRunning = true;
                app.VisualPreviewStopRequested = false;
                app.VisualPlayButton.Enable = 'off';
                app.VisualStopPlaybackButton.Enable = 'on';
                app.AcquisitionStartButton.Enable = 'off';
                app.setCameraCommandsTimingLocked(true);
                app.updateVisualStimulusStatus();
                app.updateVisualScreenStatus();
                app.Logger.log('INFO', ...
                    'VISUAL_PREVIEW_CAMERA_COMMANDS_LOCKED', ...
                    ['ExistingPreviewMask=%s | ExistingPreviewContinues=1 | ', ...
                     'NewCameraCommandsDuringFlipLoop=0'], ...
                    mat2str(app.PreviewActive));
                logs = app.VisualStimulusController.playPreview( ...
                    app.visualConfiguration(), app.SimulationMode, app.Logger, ...
                    mode, app.VisualPreviewAngleField.Value, ...
                    @() app.VisualPreviewStopRequested);
                angleText = "full program";
                if isfinite(logs.preview_chosen_angle)
                    angleText = sprintf('angle %.6g deg', ...
                        logs.preview_chosen_angle);
                end
                app.finishAction('PLAY_VISUAL_PREVIEW', true, ...
                    "Playback completed: " + angleText + ...
                    ". Camera Preview was not stopped; DAQ was not used.", ...
                    app.VisualSummaryLabel);
            catch ME
                if strcmp(ME.identifier, 'ZouLab:AcquisitionStopped') && ...
                        app.VisualPreviewStopRequested
                    app.finishAction('PLAY_VISUAL_PREVIEW', true, ...
                        'Playback stopped by user; camera Preview remains unchanged.', ...
                        app.VisualSummaryLabel);
                elseif strcmp(ME.identifier, 'ZouLab:OperatorRequired')
                    app.identityBlocked(app.VisualSummaryLabel);
                else
                    app.handleError('PLAY_VISUAL_PREVIEW_FAILED', ME, ...
                        app.VisualSummaryLabel);
                end
            end
            app.VisualPreviewRunning = false;
            app.VisualPreviewStopRequested = false;
            app.setCameraCommandsTimingLocked(false);
            app.VisualStopPlaybackButton.Enable = 'off';
            app.updateAcquisitionControlAvailability(false);
            app.updateVisualStimulusStatus();
            app.updateVisualScreenStatus();
        end

        function setCameraCommandsTimingLocked(app, locked)
            for cameraIndex = 1:2
                if locked
                    app.CameraApplyButtons{cameraIndex}.Enable = 'off';
                    app.CameraPreviewStartButtons{cameraIndex}.Enable = 'off';
                    app.CameraPreviewStopButtons{cameraIndex}.Enable = 'off';
                    app.CameraSnapButtons{cameraIndex}.Enable = 'off';
                else
                    app.CameraApplyButtons{cameraIndex}.Enable = ...
                        app.onOff(app.IdentityConfirmed && ...
                        ~app.RunState.AcquisitionRunning);
                    app.CameraSnapButtons{cameraIndex}.Enable = ...
                        app.onOff(app.IdentityConfirmed && ...
                        ~app.RunState.AcquisitionRunning);
                end
            end
            connectButton = findall(app.UIFigure, ...
                'Tag', 'ConnectCamerasButton');
            if ~isempty(connectButton)
                connectButton.Enable = app.onOff(~locked && ...
                    app.IdentityConfirmed && ~app.RunState.AcquisitionRunning);
            end
            if ~locked
                app.updatePreviewButtons();
            end
            app.Logger.log('INFO', 'CAMERA_COMMAND_TIMING_LOCK_CHANGED', ...
                ['Locked=%d | Reason=protect_PTB_flip_loop | ', ...
                 'ExistingPreviewContinues=1'], locked);
        end

        function stopVisualPreview(app)
            app.Logger.log('INFO', 'USER_VISUAL_PREVIEW_STOP_CLICKED', ...
                'Running=%d', app.VisualPreviewRunning);
            if ~app.VisualPreviewRunning
                app.finishAction('STOP_VISUAL_PREVIEW', false, ...
                    'No preview playback is running.', app.VisualSummaryLabel);
                return;
            end
            app.VisualPreviewStopRequested = true;
            app.VisualSummaryLabel.Text = 'Working: stopping stimulus playback...';
            app.VisualSummaryLabel.FontColor = [0.80 0.48 0.05];
        end

        function updateVisualConfigurationSummary(app)
            try
                spec = zoulab.VisualStimulusController.buildSpec( ...
                    app.visualConfiguration());
                cameraWindow = app.CameraPreStimField.Value + ...
                    spec.estimated_duration_seconds + ...
                    app.CameraPostStimField.Value;
                app.VisualSummaryLabel.Text = sprintf( ...
                    '%s | stimulus %.3g s | camera window %.3g s', ...
                    spec.label, spec.estimated_duration_seconds, ...
                    cameraWindow);
                app.VisualSummaryLabel.FontColor = [0.08 0.42 0.18];
                frameText = strings(1, 0);
                for cameraIndex = app.activeCameraIndices()
                    if app.SimulationMode
                        fps = app.SimulationRecordFPS;
                    else
                        fps = app.expectedStreamFPS(cameraIndex);
                    end
                    if isfinite(fps) && fps > 0
                        stimulusFrames = max(1, round( ...
                            spec.estimated_duration_seconds * fps));
                        totalFrames = max(1, round(cameraWindow * fps));
                        frameText(end + 1) = sprintf( ...
                            'Cam%d %.3g FPS: stimulus %d, total %d', ...
                            cameraIndex, fps, stimulusFrames, totalFrames); %#ok<AGROW>
                    else
                        frameText(end + 1) = sprintf( ...
                            'Cam%d FPS unavailable', cameraIndex); %#ok<AGROW>
                    end
                end
                app.AdvancedTimingSummaryLabel.Text = sprintf( ...
                    ['Camera START = 0 s | PTB start offset %.3g s -> %s | ', ...
                     'PTB end padding %.3g s\n', ...
                     'Imaging TTL: start offset %.3g s, end vs Camera END %.3g s | ', ...
                     'Stimulus %.3g s | %s'], ...
                    app.CameraPreStimField.Value, ...
                    app.visualEpochSummary(spec), ...
                    app.CameraPostStimField.Value, app.LightLeadField.Value, ...
                    app.LightTailField.Value, ...
                    spec.estimated_duration_seconds, ...
                    strjoin(frameText, ' | '));
                app.AdvancedTimingSummaryLabel.FontColor = [0.08 0.42 0.18];
            catch ME
                app.VisualSummaryLabel.Text = "Invalid configuration: " + string(ME.message);
                app.VisualSummaryLabel.FontColor = [0.78 0.18 0.12];
                if ~isempty(app.AdvancedTimingSummaryLabel) && ...
                        isvalid(app.AdvancedTimingSummaryLabel)
                    app.AdvancedTimingSummaryLabel.Text = ...
                        "Cannot estimate frames: " + string(ME.message);
                    app.AdvancedTimingSummaryLabel.FontColor = [0.78 0.18 0.12];
                end
            end
        end

        function value = visualEpochSummary(~, spec)
            if ismember(string(spec.program), ...
                    ["drifting_grating","random_drifting_grating"])
                value = sprintf('[ISI %.3g s -> grating %.3g s] x %d', ...
                    spec.isi_seconds, spec.duration_seconds, ...
                    numel(spec.sequence) * spec.repeats);
            else
                value = char(spec.label);
            end
        end

        function armVisualStimulus(app)
            app.beginAction('ARM_VISUAL_STIMULUS', ...
                'Validating and arming visual stimulus...', app.VisualSummaryLabel);
            try
                app.requireIdentity('arm visual stimulus');
                if app.LightStimulusController.Armed || ...
                        app.LedFlickerController.Armed
                    error('ZouLab:CombinedStimulusNotYetSupported', ...
                        ['Disarm Light Stimulus and LED Flicker before ', ...
                         'arming Visual Stimulus.']);
                end
                previousMode = string(app.AcquisitionModeDropDown.Value);
                previousDuration = app.RecordDurationField.Value;
                previousLengthSource = string( ...
                    app.RecordLengthSourceDropDown.Value);
                config = app.visualConfiguration();
                app.VisualStimulusController.arm(config, app.SimulationMode, app.Logger);
                stimulusDuration = app.VisualStimulusController.estimatedDuration();
                app.AcquisitionModeDropDown.Value = 'Record';
                app.RecordLengthSourceDropDown.Value = 'Custom';
                requiredDuration = app.CameraPreStimSeconds + ...
                    stimulusDuration + app.CameraPostStimSeconds;
                if app.LightStimulusController.Armed
                    lightSpec = app.LightStimulusController.Spec;
                    requiredDuration = max(requiredDuration, ...
                        lightSpec.stimulus_delay_seconds + ...
                        lightSpec.stimulus_duration_seconds);
                end
                app.RecordDurationField.Value = requiredDuration;
                app.updateRecordLengthSummary();
                app.updateAcquisitionControlAvailability(false);
                app.updateVisualStimulusStatus();
                app.updateAcquisitionStorageEstimate( ...
                    'visual_stimulus_armed', true);
                app.refreshDaqTimeline('visual_stimulus_armed');
                app.Logger.log('SUCCESS', 'VISUAL_STIM_ACQUISITION_LINKED', ...
                    ['PreviousMode=%s | NewMode=Record | ', ...
                     'PreviousRecordDurationSeconds=%.9g | ', ...
                     'PreviousLengthSource=%s | LengthSource=Custom | ', ...
                     'StimulusDurationSeconds=%.9g | ', ...
                     'ModeAndRecordDurationFrozen=1 | ', ...
                     'TimeLapseSettingsFrozen=1'], ...
                    previousMode, previousDuration, previousLengthSource, ...
                    stimulusDuration);
                app.finishAction('ARM_VISUAL_STIMULUS', true, ...
                    sprintf('Visual stimulus ARMED: %s | Record %.3g s locked', ...
                    app.VisualStimulusController.Spec.label, stimulusDuration), ...
                    app.VisualSummaryLabel);
            catch ME
                app.updateAcquisitionControlAvailability(app.RunState.AcquisitionRunning);
                app.updateVisualStimulusStatus();
                if strcmp(ME.identifier, 'ZouLab:OperatorRequired')
                    app.identityBlocked(app.VisualSummaryLabel);
                else
                    app.handleError('VISUAL_STIM_ARM_UI_FAILED', ME, ...
                        app.VisualSummaryLabel);
                end
            end
        end

        function disarmVisualStimulus(app, reason)
            app.Logger.log('INFO', 'USER_VISUAL_STIM_DISARM_REQUESTED', ...
                'Reason=%s | WasArmed=%d', reason, app.VisualStimulusController.Armed);
            app.VisualStimulusController.disarm(app.Logger);
            app.updateAcquisitionControlAvailability(app.RunState.AcquisitionRunning);
            app.updateVisualStimulusStatus();
            app.updateVisualConfigurationSummary();
            app.updateAcquisitionStorageEstimate( ...
                "visual_stimulus_disarmed_" + string(reason), true);
            app.refreshDaqTimeline("visual_stimulus_disarmed_" + string(reason));
            app.Logger.log('INFO', 'VISUAL_STIM_ACQUISITION_LINK_RELEASED', ...
                ['Mode=%s | RecordDurationSeconds=%.9g | ', ...
                 'ValuesRetained=1 | ControlsUnlocked=%d'], ...
                string(app.AcquisitionModeDropDown.Value), ...
                app.RecordDurationField.Value, ~app.RunState.AcquisitionRunning);
        end

        function updateVisualStimulusStatus(app)
            if app.VisualPreviewRunning
                app.VisualStimLamp.Color = [0.10 0.75 0.20];
                app.VisualStimStatusLabel.Text = ...
                    'Visual Stim PREVIEW (no DAQ sync)';
                return;
            end
            if app.LedFlickerController.Armed
                app.VisualStimLamp.Color = [0.10 0.75 0.20];
                app.VisualStimStatusLabel.Text = 'Visual: LED Flicker ARMED';
                return;
            end
            state = app.VisualStimulusController.State;
            switch state
                case "ARMED"
                    app.VisualStimLamp.Color = [0.95 0.65 0.10];
                    suffix = '';
                    if string(app.AcquisitionModeDropDown.Value) ~= "Record"
                        suffix = ' (Record only)';
                    end
                    app.VisualStimStatusLabel.Text = "Visual Stim ARMED" + suffix;
                case "RUNNING"
                    app.VisualStimLamp.Color = [0.10 0.75 0.20];
                    app.VisualStimStatusLabel.Text = 'Visual Stim RUNNING';
                case "ERROR"
                    app.VisualStimLamp.Color = [0.85 0.15 0.12];
                    app.VisualStimStatusLabel.Text = 'Visual Stim ERROR';
                otherwise
                    app.VisualStimLamp.Color = [0.65 0.65 0.65];
                    app.VisualStimStatusLabel.Text = 'Visual Stim OFF';
            end
        end

        function startAcquisition(app)
            indices = app.activeCameraIndices();
            app.Logger.log('INFO', 'ACQUISITION_SAVE_ROOT_CURRENT', ...
                'Action=Start Acquisition | SaveRoot=%s', ...
                string(app.RootPathField.Value));
            if ~app.confirmAndApplyPendingCameraSettings( ...
                    indices, 'Start Acquisition', app.AcquisitionStatusLabel)
                return;
            end
            app.Acquisition.startAcquisition( ...
                string(app.AcquisitionModeDropDown.Value), app.VisualPreviewRunning);
        end

        function plan = freezeAcquisitionPlan(app)
            modeValue = string(app.AcquisitionModeDropDown.Value);
            switch modeValue
                case "Snap"
                    mode = 'snap';
                case "Record"
                    mode = 'record';
                case "Time Lapse"
                    mode = 'time_lapse';
            end
            resolvedRecordDuration = app.RecordDurationField.Value;
            if modeValue == "Record"
                resolvedRecordDuration = app.resolvedRecordWindowSeconds();
            end
            plan = struct( ...
                'schema_version', '3.0.0', ...
                'frozen_at', char(datetime('now', ...
                    'Format', 'yyyy-MM-dd HH:mm:ss.SSS')), ...
                'operator_id', char(app.Logger.OperatorID), ...
                'operator_name', char(app.Logger.OperatorName), ...
                'mode', mode, ...
                'cameras', app.activeCameraIndices(), ...
                'cycles', round(app.CycleCountField.Value), ...
                'cycle_start_interval_seconds', app.CycleIntervalField.Value, ...
                'cycle_interval_semantics', 'start-to-start; overrun starts next immediately', ...
                'record_duration_seconds', resolvedRecordDuration, ...
                'record_duration_custom_seconds', app.RecordDurationField.Value, ...
                'record_length_source', char(string( ...
                    app.RecordLengthSourceDropDown.Value)), ...
                'convert_record_to_tiff', app.RecordTiffCheckBox.Value, ...
                'record_capture_format', 'headerless_uint16_bin', ...
                'record_tiff_conversion_policy', ...
                    ['after all Record cycles; crop parallel by Cycle; TIFF ', ...
                     'parallel by Cycle-camera; delete each source BIN only ', ...
                     'after its TIFF verifies'], ...
                'daq_sample_rate_hz', app.DaqSampleRateField.Value, ...
                'camera_pre_stim_seconds', app.CameraPreStimField.Value, ...
                'camera_post_stim_seconds', app.CameraPostStimField.Value, ...
                'light_lead_seconds', app.LightLeadField.Value, ...
                'light_tail_seconds', app.LightTailField.Value, ...
                'ptb_start_offset_seconds', app.CameraPreStimField.Value, ...
                'ptb_end_padding_seconds', app.CameraPostStimField.Value, ...
                'imaging_light_start_offset_seconds', ...
                    app.LightLeadField.Value, ...
                'imaging_light_end_offset_seconds', ...
                    app.LightTailField.Value, ...
                'time_lapse_interval_seconds', app.TLIntervalField.Value, ...
                'time_lapse_interval_semantics', ...
                    'wait after previous point acquisition and save complete', ...
                'time_lapse_points', round(app.TLPointsField.Value), ...
                'visual_stimulus_armed', app.VisualStimulusController.Armed, ...
                'visual_stimulus', app.VisualStimulusController.manifest(), ...
                'led_flicker_armed', app.LedFlickerController.Armed, ...
                'led_flicker', app.LedFlickerController.snapshot(), ...
                'light_stimulus_armed', app.LightStimulusController.Armed, ...
                'light_stimulus', app.LightStimulusController.snapshot(), ...
                'dmd_pattern_manifest', app.DmdCompiledManifest, ...
                'rig_wiring_file', char(app.WiringConfig.FilePath), ...
                'rig_wiring', app.WiringConfig.Value, ...
                'tiff_split_bytes', zoulab.TiffStackWriter.MaxBytesPerStack, ...
                'raw_class', 'uint16', ...
                'raw_transposed', false);
            app.Logger.log('INFO', 'ACQUISITION_PLAN_FROZEN', ...
                'Plan=%s', jsonencode(plan));
        end

        function plan = preflightAcquisition(app, plan)
            if any(app.SettingsDirty(plan.cameras))
                error('ZouLab:CameraSettingsPending', ...
                    'Apply pending camera settings before acquisition.');
            end
            if plan.visual_stimulus_armed && ~strcmp(plan.mode, 'record')
                error('ZouLab:VisualStimRecordOnly', ...
                    ['Visual Stimulus is armed but acquisition mode is %s. ', ...
                     'Select Record or disarm Visual Stimulus.'], plan.mode);
            end
            if plan.light_stimulus_armed && ~strcmp(plan.mode, 'record')
                error('ZouLab:LightStimRecordOnly', ...
                    ['Light Stimulus is armed but acquisition mode is %s. ', ...
                     'Select Record or disarm Light Stimulus.'], plan.mode);
            end
            if plan.led_flicker_armed && ~strcmp(plan.mode, 'record')
                error('ZouLab:LedFlickerRecordOnly', ...
                    ['LED Flicker is armed but acquisition mode is %s. ', ...
                     'Select Record or disarm LED Flicker.'], plan.mode);
            end
            if plan.visual_stimulus_armed && plan.light_stimulus_armed
                error('ZouLab:CombinedStimulusNotYetSupported', ...
                    ['Visual and Light Stimulus cannot be armed together in this version. ', ...
                     'The rebuilt-compatible PTB stamp writes and finite DAQ waveform ', ...
                     'share one output task; running both would make timing ambiguous.']);
            end
            if plan.led_flicker_armed && ...
                    (plan.visual_stimulus_armed || plan.light_stimulus_armed)
                error('ZouLab:CombinedStimulusNotYetSupported', ...
                    ['LED Flicker currently owns the finite visual DAQ plan. ', ...
                     'Disarm PTB Visual Stimulus and Light Stimulus first.']);
            end
            app.validateLightMapping(plan.cameras);
            app.ensureAcquisitionCameras(plan.cameras);
            if (numel(plan.cameras) == 2 || plan.visual_stimulus_armed || ...
                    plan.light_stimulus_armed || plan.led_flicker_armed) && ...
                    ~app.SimulationMode
                app.DaqController.assertReady();
            end
            if plan.light_stimulus_armed
                selectedNames = string( ...
                    plan.light_stimulus.spec.stimulus_light_names);
                imagingAliases = app.lightAliases( ...
                    app.imagingLightRowsFor(plan.cameras));
                overlap = intersect(selectedNames, imagingAliases, 'stable');
                if ~isempty(overlap)
                    error('ZouLab:StimulusImagingLightConflict', ...
                        ['%s is assigned as both imaging and stimulus light. ', ...
                         'Assign different roles in Home > Light Sources.'], ...
                        strjoin(overlap, ', '));
                end
                lightSpec = plan.light_stimulus.spec;
                dmdExternal = lightSpec.dmd_enabled && ...
                    string(lightSpec.dmd_trigger_mode) == "External IN1";
                if dmdExternal
                    if isempty(fieldnames(plan.dmd_pattern_manifest))
                        error('ZouLab:DmdFrozenManifestMissing', ...
                            ['DMD stimulation is armed, but no compiled-pattern ', ...
                             'manifest was frozen into this acquisition.']);
                    end
                    zoulab.DmdPatternCompiler.validateManifest( ...
                        plan.dmd_pattern_manifest);
                    manifestCount = double( ...
                        plan.dmd_pattern_manifest.binary_frame_count);
                    triggerCount = double(lightSpec.dmd_trigger_count);
                    if triggerCount < 1 || fix(triggerCount) ~= triggerCount
                        error('ZouLab:DmdFrozenTriggerCountMismatch', ...
                            ['Frozen DAQ trigger count must be a positive ', ...
                             'integer; received %.9g.'], triggerCount);
                    end
                    dmdSequenceBlocks = triggerCount / manifestCount;
                    if dmdSequenceBlocks > 1 && ~logical(lightSpec.dmd_loop)
                        error('ZouLab:DmdExternalSingleMultipleBlocks', ...
                            ['The IN1 table contains %d complete DMD blocks, but ', ...
                             'Playback is Single. Select Loop or generate one block.'], ...
                            dmdSequenceBlocks);
                    end
                    if plan.cycles > 1 && ~logical(lightSpec.dmd_loop)
                        error('ZouLab:DmdExternalSingleMultipleCycles', ...
                            ['External Single can consume the compiled pattern only ', ...
                             'once. For multiple acquisition cycles, select Loop; ', ...
                             'the DAQ emits exactly one complete binary-frame block ', ...
                             'per cycle, returning the DMD to frame 1.']);
                    end
                    app.Logger.log('SUCCESS', ...
                        'DMD_ACQUISITION_PATTERN_PREFLIGHT_PASSED', ...
                        ['Mode=%s | LogicalMasks=%d | BinaryTriggersPerBlock=%d | ', ...
                         'In1PatternCycles=%.9g | CompleteCycles=%d | ', ...
                         'RemainderTriggers=%d | ', ...
                         'PaddingBinaryFrames=%d | Cycles=%d | ManifestHash=%s'], ...
                        app.lightDmdPlaybackMode(lightSpec), ...
                        double(plan.dmd_pattern_manifest.logical_mask_count), ...
                        manifestCount, dmdSequenceBlocks, ...
                        floor(dmdSequenceBlocks), mod(triggerCount, manifestCount), ...
                        double(plan.dmd_pattern_manifest. ...
                            padding_binary_frame_count), plan.cycles, ...
                        string(plan.dmd_pattern_manifest.content_sha256));
                end
            end
            if plan.light_stimulus_armed && ~app.SimulationMode
                selectedNames = string( ...
                    plan.light_stimulus.spec.stimulus_light_names);
                laserNames = ["Laser405", "Laser445"];
                for laserIndex = 1:2
                    if any(selectedNames == laserNames(laserIndex)) && ...
                            ~app.CoherentControllers{laserIndex}.Connected
                        error('ZouLab:LightStimLaserDisconnected', ...
                            '%s must be connected before acquisition.', ...
                            laserNames(laserIndex));
                    end
                end
                if dmdExternal && ...
                        ~app.DmdController.Connected
                    error('ZouLab:LightStimDmdDisconnected', ...
                        'DMD must be connected before light-stimulus acquisition.');
                end
            end
            if strcmp(plan.mode, 'record')
                recordWindow = plan.record_duration_seconds;
                frameCounts = app.recordFrameCounts(plan.cameras, recordWindow);
                sources = repmat("record_frame_target", ...
                    1, numel(plan.cameras));
                plan.storage_estimate = app.preflightAcquisitionStorage( ...
                    plan, frameCounts, sources);
                plan.record_buffer_policy = app.preflightRecordStorage( ...
                    plan.cameras, frameCounts, ...
                    plan.convert_record_to_tiff, recordWindow, ...
                    plan.storage_estimate);
            elseif strcmp(plan.mode, 'time_lapse')
                frameCounts = repmat(plan.time_lapse_points, ...
                    1, numel(plan.cameras));
                sources = repmat("time_lapse_points", ...
                    1, numel(plan.cameras));
                plan.storage_estimate = app.preflightAcquisitionStorage( ...
                    plan, frameCounts, sources);
            else
                frameCounts = ones(1, numel(plan.cameras));
                sources = repmat("single_snap", 1, numel(plan.cameras));
                plan.storage_estimate = app.preflightAcquisitionStorage( ...
                    plan, frameCounts, sources);
            end
            app.Logger.log('SUCCESS', 'ACQUISITION_PREFLIGHT_PASSED', ...
                ['Mode=%s | Cameras=%s | Cycles=%d | CycleStartInterval=%.6g | ', ...
                 'VisualStim=%d | LedFlicker=%d | LightStim=%d | Operator=%s'], ...
                plan.mode, mat2str(plan.cameras), plan.cycles, ...
                plan.cycle_start_interval_seconds, plan.visual_stimulus_armed, ...
                plan.led_flicker_armed, plan.light_stimulus_armed, ...
                plan.operator_id);
        end

        function ensureAcquisitionCameras(app, indices)
            for cameraIndex = indices
                if ~app.Cameras.Connected(cameraIndex)
                    exposure = app.ExposureFields{cameraIndex}.Value / 1000;
                    roi = zoulab.UserSettings.parseROI(app.ROIFields{cameraIndex}.Value);
                    binFactor = app.BinDropDowns{cameraIndex}.Value;
                    app.Cameras.configureCamera(cameraIndex, exposure, roi, ...
                        binFactor, app.Logger);
                end
            end
            if any(~app.Cameras.Connected(indices))
                app.Cameras.connect(indices, app.Logger);
            end
            for cameraIndex = indices
                app.updateCameraModeLabel(cameraIndex, 'actual');
            end
            app.updateHardwareStatus();
        end

        function preparation = prepareRecordTask(app, plan, recordPath)
            indices = plan.cameras;
            cyclePaths = strings(1, plan.cycles);
            outputFolders = cell(plan.cycles, 2);
            for cycleIndex = 1:plan.cycles
                cyclePaths(cycleIndex) = app.Sessions.newCycleFolder(cycleIndex);
                for cameraIndex = indices
                    outputFolders{cycleIndex, cameraIndex} = char( ...
                        app.Sessions.cameraFolder(cyclePaths(cycleIndex), ...
                        cameraIndex));
                end
            end
            cameraWindow = plan.record_duration_seconds;
            counts = app.recordFrameCounts(indices, cameraWindow);
            expectedFrames = zeros(1, 2);
            expectedFPS = nan(1, 2);
            frameSizes = {[], []};
            for position = 1:numel(indices)
                cameraIndex = indices(position);
                settings = app.Cameras.getActualSettings(cameraIndex);
                frameSizes{cameraIndex} = ...
                    [settings.ROI(4) settings.ROI(3)];
                expectedFrames(cameraIndex) = counts(position);
                expectedFPS(cameraIndex) = counts(position) / cameraWindow;
            end
            app.setConversionDetail({ ...
                sprintf('Record preparation: allocated %d Cycle folder(s).', ...
                    plan.cycles), ...
                'Reserving BIN segments before the Cycle clock starts...'});
            app.setAcquisitionState('PREPARING', ...
                'Preparing all Cycle BIN files and persistent writers.');
            recordPartsAllocated = false;
            try
                if isa(app.Cameras, 'zoulab.CameraServiceClient')
                    allocation = zoulab.BufferedBinRecorder.prepareRecordFiles( ...
                        outputFolders, indices, frameSizes, expectedFrames, ...
                        expectedFPS, @(done,total,cycle,camera,segment) ...
                        app.recordPreparationProgress(done, total, cycle, ...
                        camera, segment));
                    recordPartsAllocated = true;
                    taskID = sprintf('M%d_R%d', app.Sessions.MethodID, ...
                        app.Sessions.RecordID);
                    app.Cameras.prepareRemoteRecordTask(struct( ...
                        'record_task_id', taskID, 'cameras', indices), app.Logger);
                else
                    allocation = struct('schema_version', '1.0.0', ...
                        'created_utc', zoulab.BinInfo.utcNow(), ...
                        'state', 'deferred_legacy_camera_backend', ...
                        'cycle_count', plan.cycles, 'camera_indices', indices, ...
                        'total_segments', 0, 'total_bytes', 0, ...
                        'cycles', repmat(struct('index', 0, ...
                        'cameras', struct([])), 1, plan.cycles));
                    for cycleIndex = 1:plan.cycles
                        allocation.cycles(cycleIndex).index = cycleIndex;
                    end
                end
                manifestPath = fullfile(recordPath, ...
                    'record_preallocation_manifest');
                zoulab.SessionManager.writeManifestPair(manifestPath, allocation);
                preparation = struct('schema_version', '1.0.0', ...
                    'cycle_paths', cyclePaths, 'cycles', allocation.cycles, ...
                    'expected_frames', expectedFrames, ...
                    'expected_fps', expectedFPS, ...
                    'frame_sizes', {frameSizes}, ...
                    'allocation', allocation, ...
                    'manifest_base', char(manifestPath));
                app.setConversionDetail({ ...
                    sprintf('Record ready: %d Cycle(s), %d BIN segment(s).', ...
                        plan.cycles, allocation.total_segments), ...
                    sprintf('Reserved %.3f GB; writer task is ready.', ...
                        allocation.total_bytes / 1e9)});
                app.Logger.log('SUCCESS', 'RECORD_LEVEL_PREPARATION_COMPLETE', ...
                    ['Cycles=%d | Cameras=%s | Segments=%d | Bytes=%.0f | ', ...
                     'PartFilesRetainedForWriter=1 | ', ...
                     'CycleClockStartedAfterThisEvent=1 | Manifest=%s'], ...
                    plan.cycles, mat2str(indices), allocation.total_segments, ...
                    allocation.total_bytes, manifestPath + ".json");
            catch ME
                if recordPartsAllocated
                    try
                        zoulab.BufferedBinRecorder.cleanupUnpublishedParts( ...
                            allocation, 1);
                        app.Logger.log('WARNING', ...
                            'RECORD_LEVEL_PREPARATION_ROLLED_BACK', ...
                            ['ReasonIdentifier=%s | Reason=%s | ', ...
                             'AllUnpublishedPartFilesRemoved=1'], ...
                            ME.identifier, ME.message);
                    catch cleanupError
                        app.Logger.logException( ...
                            'RECORD_LEVEL_PREPARATION_ROLLBACK_FAILED', ...
                            cleanupError);
                    end
                end
                rethrow(ME);
            end
        end

        function recordPreparationProgress(app, done, total, cycle, camera, segment)
            app.setConversionDetail({ ...
                sprintf('Record preparation: BIN segment %d/%d', done, total), ...
                sprintf('Cycle %d | Camera %d | segment %d', ...
                    cycle, camera, segment)});
            drawnow limitrate;
        end

        function cleanupRecordPreparation(app, preparation, firstCycleToRemove)
            if ~isfield(preparation, 'allocation')
                return;
            end
            zoulab.BufferedBinRecorder.cleanupUnpublishedParts( ...
                preparation.allocation, firstCycleToRemove);
            app.Logger.log('INFO', 'RECORD_UNUSED_PREALLOCATION_CLEANED', ...
                ['FirstCycleRemoved=%d | CompletedOrCurrentCyclePreserved=1 | ', ...
                 'OnlyUnpublishedPartFilesRemoved=1'], firstCycleToRemove);
        end

        function [files, status] = runRecordCycle(app, plan, cyclePath, ...
                cycleIndex, frozenDaqPlan, cyclePreparation)
            if nargin < 5
                frozenDaqPlan = struct();
            end
            if nargin < 6
                cyclePreparation = struct();
            end
            indices = plan.cameras;
            % Preview is stopped once at the Record-task boundary.  It is
            % intentionally not restarted between cycles.
            previousPreview = false(1, 2);
            for cameraIndex = indices
                if app.PreviewActive(cameraIndex)
                    app.stopCameraPreview(cameraIndex, 'record_prepare');
                end
            end
            lightRows = app.imagingLightRowsFor(indices);
            aliases = app.lightAliases(lightRows);
            useExternalTrigger = ~app.SimulationMode && ...
                (numel(indices) == 2 || app.DaqController.Connected);
            visualEnabled = plan.visual_stimulus_armed;
            ledEnabled = plan.led_flicker_armed;
            lightStimEnabled = plan.light_stimulus_armed;
            finiteStimEnabled = lightStimEnabled || ledEnabled;
            cameraWindow = plan.record_duration_seconds;
            expectedCounts = app.recordFrameCounts(indices, cameraWindow);
            if isa(app.Cameras, 'zoulab.CameraServiceClient')
                [files, status] = app.runPersistentServiceRecordCycle( ...
                    plan, cyclePath, cycleIndex, indices, previousPreview, ...
                    lightRows, aliases, cameraWindow, expectedCounts, ...
                    frozenDaqPlan, cyclePreparation);
                return;
            end
            if visualEnabled && ~finiteStimEnabled && ~app.SimulationMode
                [files, status] = app.runIsolatedVisualRecordCycle( ...
                    plan, cyclePath, cycleIndex, indices, previousPreview, ...
                    lightRows, aliases, cameraWindow, expectedCounts);
                return;
            end
            recorder = app.createBinRecorder(indices, cyclePath, cycleIndex, ...
                expectedCounts, cameraWindow, plan.record_buffer_policy);
            recorderCleanup = onCleanup(@() delete(recorder)); %#ok<NASGU>
            recordPrepared = false;
            files = strings(1, 0);
            status = 'complete';
            visualLogs = struct();
            rawSync = table();
            syncTable = table();
            app.RecordImagingLightsOn = false;
            cleanup = onCleanup(@() app.finishRecordCycle(indices, lightRows, ...
                aliases, previousPreview, useExternalTrigger)); %#ok<NASGU>
            try
                if finiteStimEnabled
                    daqPlan = frozenDaqPlan;
                    if isempty(fieldnames(daqPlan))
                        daqPlan = app.compileFrozenDaqPlan( ...
                            plan, lightRows, aliases);
                    end
                    app.Cameras.prepareFiniteAcquisition(indices, expectedCounts, ...
                        ~app.SimulationMode, app.Logger);
                    recordPrepared = true;
                    if ~app.SimulationMode
                        app.prepareDaqControlledLights(lightRows, aliases);
                        app.DaqController.startFinitePlan(daqPlan, app.Logger);
                    end
                    outputClock = tic;
                    if lightStimEnabled
                        app.LightStimLamp.Color = [0.10 0.75 0.20];
                        app.LightStimStatusLabel.Text = 'Light Stim RUNNING';
                        stimulusName = 'Light Stimulus';
                    else
                        app.LedFlickerLamp.Color = [0.10 0.75 0.20];
                        app.LedFlickerStatusLabel.Text = 'LED Flicker RUNNING';
                        stimulusName = 'LED Flicker';
                    end
                    app.Logger.log('INFO', 'FINITE_DAQ_STIMULUS_CYCLE_STARTED', ...
                        ['Cycle=%d | CameraWindowSeconds=%.6g | ', ...
                         'Stimulus=%s | PlanDurationSeconds=%.6g | ', ...
                         'ExpectedFrameCounts=%s | ', ...
                         'Storage=streamed_bin | Simulation=%d'], ...
                        cycleIndex, cameraWindow, stimulusName, ...
                        daqPlan.duration_seconds, ...
                        mat2str(expectedCounts), app.SimulationMode);
                    timeout = daqPlan.duration_seconds + ...
                        max(10, 0.25 * cameraWindow);
                    completed = app.collectFiniteRecordToBin(recorder, indices, ...
                        expectedCounts, timeout, cycleIndex, plan.cycles);
                    if ~app.SimulationMode
                        remainingPlan = daqPlan.duration_seconds - toc(outputClock);
                        if remainingPlan > 0 && ~app.waitRecordInterval( ...
                                remainingPlan, sprintf( ...
                                'Cycle %d DAQ light tail', cycleIndex), ...
                                recorder, indices)
                            error('ZouLab:AcquisitionStopped', ...
                                'Stop requested during the finite DAQ light plan.');
                        end
                        app.DaqController.finishFinitePlan(app.Logger);
                    end
                    if ~completed
                        status = 'incomplete';
                    end
                else
                    if visualEnabled && ~app.SimulationMode
                        app.DaqController.beginVisualSync(indices, app.Logger);
                    end
                    app.setImagingLights(lightRows, aliases, true);
                    app.RecordImagingLightsOn = true;
                    if ~app.waitInterruptible(max(0, ...
                            -plan.imaging_light_start_offset_seconds), ...
                            sprintf('Cycle %d imaging-light preparation', cycleIndex))
                        error('ZouLab:AcquisitionStopped', ...
                            'Stop requested during the record preparation period.');
                    end
                    if visualEnabled
                        app.Cameras.prepareOpenEndedAcquisition(indices, ...
                            useExternalTrigger, app.Logger);
                    else
                        app.Cameras.prepareFiniteAcquisition(indices, ...
                            expectedCounts, useExternalTrigger, app.Logger);
                    end
                    recordPrepared = true;
                    if useExternalTrigger
                        app.DaqController.pulseCameras(indices, app.Logger);
                    end
                    app.Logger.log('INFO', 'RECORD_CAMERA_WINDOW_BEGIN', ...
                        ['Cycle=%d | Cameras=%s | VisualStim=%d | ', ...
                         'RequestedWindowSeconds=%.6g | ExpectedFrameCounts=%s | ', ...
                         'ExternalTrigger=%d | Storage=streamed_bin'], ...
                        cycleIndex, mat2str(indices), visualEnabled, ...
                        cameraWindow, mat2str(expectedCounts), useExternalTrigger);

                    if visualEnabled
                        if app.SimulationMode
                            app.generateSimulationRecord(recorder, indices, ...
                                expectedCounts);
                        end
                        if ~app.waitRecordInterval(plan.camera_pre_stim_seconds, ...
                                sprintf('Cycle %d pre-stimulus camera window', ...
                                cycleIndex), recorder, indices)
                            error('ZouLab:AcquisitionStopped', ...
                                'Stop requested during the pre-stimulus camera window.');
                        end
                        app.VisualStimLamp.Color = [0.10 0.75 0.20];
                        app.VisualStimStatusLabel.Text = 'Visual Stim RUNNING';
                        app.Logger.log('INFO', ...
                            'VISUAL_STIMULUS_RUN_INDICATOR_ON', ...
                            'Cycle=%d | Program=%s | BinDrainAfterEachFlip=1', ...
                            cycleIndex, plan.visual_stimulus.spec.program);
                        drawnow limitrate;
                        if app.SimulationMode
                            stampFcn = [];
                        else
                            stampFcn = @() app.visualRecordFlipService( ...
                                recorder, indices);
                        end
                        visualLogs = app.VisualStimulusController.run( ...
                            app.Logger, stampFcn, ...
                            @() app.RunState.AcquisitionStopRequested);
                        app.updateVisualStimulusStatus();
                        if ~app.waitRecordInterval(plan.camera_post_stim_seconds, ...
                                sprintf('Cycle %d post-stimulus camera window', ...
                                cycleIndex), recorder, indices)
                            error('ZouLab:AcquisitionStopped', ...
                                'Stop requested during the post-stimulus camera window.');
                        end
                        app.Cameras.stopBufferedAcquisition(indices, app.Logger, ...
                            'visual_stimulus_window_complete');
                        if ~app.SimulationMode
                            [rawSync, syncTable] = ...
                                app.DaqController.finishVisualSync( ...
                                indices, visualLogs.vbl, app.Logger);
                        end
                        app.drainStoppedRecord(recorder, indices);
                    else
                        timeout = cameraWindow + max(10, 0.25 * cameraWindow);
                        completed = app.collectFiniteRecordToBin(recorder, ...
                            indices, expectedCounts, timeout, cycleIndex, ...
                            plan.cycles);
                        if ~completed
                            status = 'incomplete';
                        end
                    end
                    if ~app.waitRecordInterval(max(0, ...
                            plan.imaging_light_end_offset_seconds), ...
                            sprintf('Cycle %d imaging-light tail', cycleIndex), ...
                            recorder, indices)
                        error('ZouLab:AcquisitionStopped', ...
                            'Stop requested during the imaging-light tail period.');
                    end
                    app.setImagingLights(lightRows, aliases, false);
                    app.RecordImagingLightsOn = false;
                end

                app.setAcquisitionState('FLUSHING', sprintf( ...
                    'Cycle %d/%d: closing BIN writers.', cycleIndex, plan.cycles));
                streamManifest = recorder.finish();
                if visualEnabled && app.SimulationMode
                    for cameraIndex = indices
                        position = find([streamManifest.cameras.camera] == ...
                            cameraIndex, 1);
                        count = double(streamManifest.cameras(position). ...
                            written_frames);
                        alignment = struct( ...
                            'schema_version', '1.0.0', ...
                            'status', 'simulation_full_record_window', ...
                            'valid', count > 0, ...
                            'simulation', true, ...
                            'hardware_counter_alignment', false, ...
                            'applied_frame_range', [1 count], ...
                            'valid_frame_count', count, ...
                            'storage_crop_applied', false, ...
                            'reason', ['Simulation creates exactly the ', ...
                            'requested visual camera window; no DAQ counter ', ...
                            'samples exist or are claimed.']);
                        streamManifest.cameras(position).visual_alignment = ...
                            alignment;
                    end
                    streamManifest.visual_alignment = struct( ...
                        'schema_version', '1.1.0', ...
                        'status', 'simulation_full_record_window', ...
                        'simulation', true, ...
                        'hardware_counter_alignment', false, ...
                        'all_cameras_valid', all([streamManifest.cameras. ...
                            written_frames] > 0));
                    app.Logger.log('INFO', ...
                        'SIMULATION_VISUAL_FULL_BIN_RANGE_DECLARED', ...
                        ['Cycle=%d | Cameras=%s | HardwareCounterAlignment=0 | ', ...
                         'PhysicalCropRange=entire_generated_bin'], ...
                        cycleIndex, mat2str(indices));
                end
                [recordFiles, storageStatus, streamManifest] = ...
                    app.finalizeRecordStorage(recorder, streamManifest, ...
                    plan, cyclePath, cycleIndex);
                files = [files recordFiles];
                if storageStatus ~= "complete"
                    status = char(storageStatus);
                elseif app.recordIntegrityHasErrors(streamManifest) && ...
                        strcmp(status, 'complete')
                    status = 'complete_with_integrity_errors';
                end

                if visualEnabled
                    visualPath = fullfile(cyclePath, 'visual_sync.mat');
                    save(visualPath, 'visualLogs', 'rawSync', 'syncTable', '-v7.3');
                    files(end + 1) = string(visualPath);
                    logs = app.buildLegacyVisualLogs( ...
                        visualLogs, rawSync, syncTable, indices); %#ok<NASGU>
                    logsPath = fullfile(cyclePath, 'logs.mat');
                    save(logsPath, 'logs', '-v7.3');
                    files(end + 1) = string(logsPath);
                    visualSummary = struct( ...
                        'program', visualLogs.program, ...
                        'label', visualLogs.label, ...
                        'angle_sequence', app.visualAngleSequence(visualLogs), ...
                        'flip_count', numel(visualLogs.vbl), ...
                        'matched_sync_rows', height(syncTable), ...
                        'elapsed_seconds', visualLogs.elapsed_seconds, ...
                        'mat_file', char(visualPath), ...
                        'camera_storage', 'streamed_bin');
                    zoulab.SessionManager.writeJson(fullfile(cyclePath, ...
                        'visual_stimulus_manifest.json'), visualSummary);
                end
                if ledEnabled
                    ledSummary = struct( ...
                        'schema_version', '1.0.0', ...
                        'simulation', app.SimulationMode, ...
                        'camera_trigger_semantics', ...
                            'single_START_then_free_run', ...
                        'frame_limit_mode', 'finite', ...
                        'physical_bin_crop', false, ...
                        'timing_basis', ...
                            'shared_finite_DAQ_output_matrix', ...
                        'visual_stamp_used', false, ...
                        'planned_event_count', numel(daqPlan. ...
                            led_flicker_event_times_seconds), ...
                        'sync_status', ...
                            'simulation_shared_output_plan_not_executed');
                    ledManifestPath = fullfile(cyclePath, ...
                        'led_flicker_manifest.json');
                    zoulab.SessionManager.writeJson( ...
                        ledManifestPath, ledSummary);
                    files(end + 1) = string(ledManifestPath);
                end
                if app.RunState.AcquisitionStopRequested
                    status = 'stopped';
                elseif any(recorder.RetrievedFrames(indices) == 0)
                    status = 'incomplete';
                end
                app.Logger.log('SUCCESS', 'RECORD_CYCLE_DATA_SAVED', ...
                    ['Cycle=%d | Status=%s | Cameras=%s | RetrievedCounts=%s | ', ...
                     'ExpectedCounts=%s | ConvertToTiff=%d | Files=%s'], ...
                    cycleIndex, status, mat2str(indices), ...
                    mat2str(recorder.RetrievedFrames(indices)), ...
                    mat2str(expectedCounts), plan.convert_record_to_tiff, ...
                    strjoin(files, ','));
            catch ME
                if recordPrepared && ~recorder.Closed
                    try
                        app.Cameras.stopBufferedAcquisition(indices, app.Logger, ...
                            'record_error_preserve_partial');
                        app.drainStoppedRecord(recorder, indices);
                        partialManifest = recorder.finish();
                        [partialFiles, ~, partialManifest] = ...
                            app.finalizeRecordStorage(recorder, partialManifest, ...
                            app.planWithoutTiffConversion(plan), cyclePath, ...
                            cycleIndex);
                        files = [files partialFiles];
                        partial = struct('status', 'incomplete', ...
                            'reason', ME.message, 'files', cellstr(files), ...
                            'retrieved_counts', ...
                            recorder.RetrievedFrames(indices), ...
                            'stream_manifest', partialManifest);
                        zoulab.SessionManager.writeJson(fullfile(cyclePath, ...
                            'partial_record_manifest.json'), partial);
                        app.Logger.log('WARNING', 'PARTIAL_RECORD_PRESERVED', ...
                            'Cycle=%d | Counts=%s | Files=%s | Reason=%s', ...
                            cycleIndex, ...
                            mat2str(recorder.RetrievedFrames(indices)), ...
                            strjoin(files, ','), ME.message);
                    catch preserveError
                        app.Logger.logException('PARTIAL_RECORD_PRESERVE_FAILED', ...
                            preserveError);
                    end
                end
                if strcmp(ME.identifier, 'ZouLab:AcquisitionStopped')
                    status = 'stopped';
                    return;
                end
                rethrow(ME);
            end
        end

        function [files, status] = runPersistentServiceRecordCycle(app, plan, ...
                cyclePath, cycleIndex, indices, previousPreview, lightRows, ...
                aliases, cameraWindow, expectedCounts, frozenDaqPlan, ...
                cyclePreparation)
            files = strings(1, 0);
            status = 'complete';
            remoteResult = struct();
            remoteStarted = false;
            visualLogs = struct();
            rawSync = table();
            syncTable = table();
            visualEnabled = plan.visual_stimulus_armed;
            ledEnabled = plan.led_flicker_armed;
            lightStimEnabled = plan.light_stimulus_armed;
            finiteStimEnabled = lightStimEnabled || ledEnabled;
            useExternalTrigger = visualEnabled || finiteStimEnabled || ...
                numel(indices) == 2 || app.DaqController.Connected;
            cleanup = onCleanup(@() app.finishPersistentServiceRecordCycle( ...
                indices, lightRows, aliases, previousPreview, ...
                useExternalTrigger)); %#ok<NASGU>

            outputFolders = {"", ""};
            expectedFull = zeros(1, 2);
            expectedFpsFull = nan(1, 2);
            for position = 1:numel(indices)
                cameraIndex = indices(position);
                outputFolders{cameraIndex} = char( ...
                    app.Sessions.cameraFolder(cyclePath, cameraIndex));
                expectedFull(cameraIndex) = expectedCounts(position);
                expectedFpsFull(cameraIndex) = ...
                    expectedCounts(position) / cameraWindow;
            end
            app.assertCycleBinNamespaces(cyclePath, cycleIndex, indices, ...
                outputFolders);
            frameLimitMode = 'finite';
            if visualEnabled
                frameLimitMode = 'open_ended';
            end
            triggerMode = 'internal';
            if useExternalTrigger
                triggerMode = 'external';
            end
            recordID = sprintf('M%d_R%d_C%d', app.Sessions.MethodID, ...
                app.Sessions.RecordID, cycleIndex);
            recordTaskID = sprintf('M%d_R%d', app.Sessions.MethodID, ...
                app.Sessions.RecordID);
            remoteConfig = struct( ...
                'schema_version', '1.0.0', 'record_id', recordID, ...
                'record_task_id', recordTaskID, ...
                'cycle_index', cycleIndex, 'cycle_count', plan.cycles, ...
                'cameras', indices, 'output_folders', {outputFolders}, ...
                'expected_frames', expectedFull, ...
                'expected_fps', expectedFpsFull, ...
                'trigger_mode', triggerMode, ...
                'frame_limit_mode', frameLimitMode, ...
                'capture_duration_seconds', cameraWindow, ...
                'capture_stop_guard_seconds', 1, ...
                'watchdog_seconds', cameraWindow + 90);
            if ~isempty(cyclePreparation) && ...
                    isfield(cyclePreparation, 'cameras')
                remoteConfig.preallocation = cyclePreparation;
            end
            app.Logger.log('INFO', 'PERSISTENT_CAMERA_RECORD_PREPARE', ...
                ['Cycle=%d | RecordID=%s | Cameras=%s | CameraWindow=%.6g | ', ...
                 'ExpectedFrames=%s | TriggerMode=%s | FrameLimitMode=%s | ', ...
                 'IndependentCaptureDeadline=%.6g+1s_guard | ', ...
                 'MainOwns=UI,PTB,DAQ,lights | ServiceOwns=videoinput,IAT,BIN_writers | ', ...
                 'CameraObjectsReusedUntilSafeExit=1'], cycleIndex, recordID, ...
                mat2str(indices), cameraWindow, mat2str(expectedCounts), ...
                triggerMode, frameLimitMode, cameraWindow);

            try
                if finiteStimEnabled
                    daqPlan = frozenDaqPlan;
                    if isempty(fieldnames(daqPlan))
                        daqPlan = app.compileFrozenDaqPlan( ...
                            plan, lightRows, aliases);
                    end
                    app.prepareDaqControlledLights(lightRows, aliases);
                    app.Cameras.startRemoteRecord(remoteConfig, app.Logger);
                    remoteStarted = true;
                    app.DaqController.startFinitePlan(daqPlan, app.Logger);
                    app.Cameras.markRemoteRecordStarted(app.Logger);
                    if lightStimEnabled
                        app.LightStimLamp.Color = [0.10 0.75 0.20];
                        app.LightStimStatusLabel.Text = 'Light Stim RUNNING';
                        stimulusName = 'Light Stimulus';
                    else
                        app.LedFlickerLamp.Color = [0.10 0.75 0.20];
                        app.LedFlickerStatusLabel.Text = 'LED Flicker RUNNING';
                        stimulusName = 'LED Flicker';
                    end
                    app.Logger.log('INFO', 'FINITE_DAQ_STIMULUS_CYCLE_STARTED', ...
                        ['Cycle=%d | PlanDurationSeconds=%.6g | ', ...
                         'Stimulus=%s | CameraTrigger=single_START_then_free_run | ', ...
                         'FrameLimit=finite | CameraServiceParallelDrain=1 | ', ...
                         'Storage=streamed_bin'], cycleIndex, ...
                        daqPlan.duration_seconds, stimulusName);
                    if ~app.waitInterruptible(daqPlan.duration_seconds, sprintf( ...
                            'Cycle %d finite DAQ and camera record', cycleIndex))
                        error('ZouLab:AcquisitionStopped', ...
                            'Stop requested during the finite DAQ light plan.');
                    end
                    app.DaqController.finishFinitePlan(app.Logger);
                else
                    if visualEnabled
                        app.Cameras.startRemoteRecord(remoteConfig, app.Logger);
                        remoteStarted = true;
                        app.DaqController.beginVisualSync(indices, app.Logger);
                    end
                    app.setImagingLights(lightRows, aliases, true);
                    app.RecordImagingLightsOn = true;
                    if ~app.waitInterruptible(max(0, ...
                            -plan.imaging_light_start_offset_seconds), sprintf( ...
                            'Cycle %d imaging-light preparation', cycleIndex))
                        error('ZouLab:AcquisitionStopped', ...
                            'Stop requested during record preparation.');
                    end
                    if ~visualEnabled
                        app.Cameras.startRemoteRecord(remoteConfig, app.Logger);
                        remoteStarted = true;
                    end
                    if useExternalTrigger
                        app.DaqController.pulseCameras(indices, app.Logger);
                    end
                    app.Cameras.markRemoteRecordStarted(app.Logger);
                    app.Logger.log('SUCCESS', 'PERSISTENT_CAMERA_WINDOW_STARTED', ...
                        ['Cycle=%d | Cameras=%s | TriggerMode=%s | ', ...
                         'ServiceDrainIndependentOfMainUI=1'], ...
                        cycleIndex, mat2str(indices), triggerMode);

                    if visualEnabled
                        if ~app.waitInterruptible(plan.camera_pre_stim_seconds, ...
                                sprintf('Cycle %d pre-stimulus camera window', ...
                                cycleIndex))
                            error('ZouLab:AcquisitionStopped', ...
                                'Stop requested during pre-stimulus camera window.');
                        end
                        app.VisualStimLamp.Color = [0.10 0.75 0.20];
                        app.VisualStimStatusLabel.Text = 'Visual Stim RUNNING';
                        app.Logger.log('INFO', ...
                            'PERSISTENT_VISUAL_STIMULUS_STARTED', ...
                            ['Cycle=%d | PTBProcess=main | CameraProcess=service | ', ...
                             'TCPDuringFlipLoop=0 | WriterPollingDuringFlipLoop=0 | ', ...
                             'FlipCallback=DAQ_stamp_only'], cycleIndex);
                        visualLogs = app.VisualStimulusController.run( ...
                            app.Logger, @() app.DaqController.stampVisualFrame(), ...
                            @() app.RunState.AcquisitionStopRequested);
                        app.updateVisualStimulusStatus();
                        if ~app.waitInterruptible(plan.camera_post_stim_seconds, ...
                                sprintf('Cycle %d post-stimulus camera window', ...
                                cycleIndex))
                            error('ZouLab:AcquisitionStopped', ...
                                'Stop requested during post-stimulus camera window.');
                        end
                        if ~app.waitInterruptible(max(0, ...
                                plan.imaging_light_end_offset_seconds), sprintf( ...
                                'Cycle %d imaging-light tail', cycleIndex))
                            error('ZouLab:AcquisitionStopped', ...
                                'Stop requested during the imaging-light tail.');
                        end
                        app.setImagingLights(lightRows, aliases, false);
                        app.RecordImagingLightsOn = false;
                        % Stop DAQ input before waiting on writer flushing. This
                        % keeps the PTB/DAQ timeline independent of disk latency.
                        [rawSync, syncTable] = app.DaqController.finishVisualSync( ...
                            indices, visualLogs.vbl, app.Logger);
                    else
                        if ~app.waitInterruptible(cameraWindow, sprintf( ...
                                'Cycle %d persistent camera record', cycleIndex))
                            error('ZouLab:AcquisitionStopped', ...
                                'Stop requested during camera record.');
                        end
                        if ~app.waitInterruptible(max(0, ...
                                plan.imaging_light_end_offset_seconds), sprintf( ...
                                'Cycle %d imaging-light tail', cycleIndex))
                            error('ZouLab:AcquisitionStopped', ...
                                'Stop requested during the imaging-light tail.');
                        end
                        app.setImagingLights(lightRows, aliases, false);
                        app.RecordImagingLightsOn = false;
                    end
                end

            app.setAcquisitionState('FLUSHING', sprintf( ...
                    ['Finalizing Record Cycle %d/%d — draining camera ', ...
                     'memory and closing BIN files.'], ...
                    cycleIndex, plan.cycles));
                remoteResult = app.Cameras.stopRemoteRecord( ...
                    'camera_window_complete', app.Logger, @(elapsed,total) ...
                    app.setRemoteFlushProgress(cycleIndex, elapsed, total));
                remoteStarted = false;
                streamManifest = remoteResult.stream_manifest;

                if visualEnabled
                    streamManifest = zoulab.VisualFrameAlignment.apply( ...
                        streamManifest, syncTable, indices, app.Logger);
                    if streamManifest.visual_alignment.all_cameras_valid
                        streamManifest.visual_physical_crop = struct( ...
                            'schema_version', '1.1.0', ...
                            'status', 'pending_record_complete', ...
                            'requested_utc', zoulab.BinInfo.utcNow(), ...
                            'execution', 'background_record_postprocessing', ...
                            'error_identifier', '', 'error', '');
                        app.Logger.log('INFO', ...
                            'PERSISTENT_VISUAL_BIN_CROP_DEFERRED', ...
                            ['Cycle=%d | Cameras=%s | ', ...
                             'StartBoundary=after_all_record_cycles | ', ...
                             'CycleSchedulerBlocked=0'], cycleIndex, ...
                            mat2str(indices));
                    else
                        streamManifest.visual_physical_crop = struct( ...
                            'schema_version', '1.0.0', ...
                            'status', 'skipped_invalid_daq_alignment', ...
                            'completed_utc', zoulab.BinInfo.utcNow(), ...
                            'error_identifier', ...
                                'ZouLab:VisualCropAlignmentInvalid', ...
                            'error', ['Physical crop was skipped because DAQ ', ...
                                'camera-counter alignment was invalid.']);
                    end
                end

                [recordFiles, storageStatus, streamManifest] = ...
                    app.finalizeRecordStorage([], streamManifest, plan, ...
                    cyclePath, cycleIndex);
                files = [files recordFiles];
                if storageStatus ~= "complete"
                    status = char(storageStatus);
                elseif app.recordIntegrityHasErrors(streamManifest)
                    status = 'complete_with_integrity_errors';
                elseif string(remoteResult.status) ~= "complete"
                    status = char(string(remoteResult.status));
                end

                if visualEnabled
                    visualPath = fullfile(cyclePath, 'visual_sync.mat');
                    save(visualPath, 'visualLogs', 'rawSync', 'syncTable', ...
                        'remoteResult', '-v7.3');
                    files(end + 1) = string(visualPath);
                    logs = app.buildLegacyVisualLogs( ...
                        visualLogs, rawSync, syncTable, indices); %#ok<NASGU>
                    logsPath = fullfile(cyclePath, 'logs.mat');
                    save(logsPath, 'logs', '-v7.3');
                    files(end + 1) = string(logsPath);
                    visualSummary = struct( ...
                        'program', visualLogs.program, ...
                        'label', visualLogs.label, ...
                        'angle_sequence', app.visualAngleSequence(visualLogs), ...
                        'flip_count', numel(visualLogs.vbl), ...
                        'matched_sync_rows', height(syncTable), ...
                        'visual_frame_alignment', ...
                            streamManifest.visual_alignment, ...
                        'visual_bin_physical_crop', ...
                            streamManifest.visual_physical_crop, ...
                        'elapsed_seconds', visualLogs.elapsed_seconds, ...
                        'mat_file', char(visualPath), ...
                        'camera_storage', ...
                            'persistent_service_streamed_bin');
                    visualManifestPath = fullfile(cyclePath, ...
                        'visual_stimulus_manifest.json');
                    zoulab.SessionManager.writeJson(visualManifestPath, ...
                        visualSummary);
                    files(end + 1) = string(visualManifestPath);
                end
                if ledEnabled
                    ledSyncPath = fullfile(cyclePath, 'led_flicker_timing.mat');
                    ledPlan = plan.led_flicker; %#ok<NASGU>
                    ledEventTimesSeconds = ...
                        daqPlan.led_flicker_event_times_seconds; %#ok<NASGU>
                    timingBasis = ...
                        'shared_finite_DAQ_output_matrix'; %#ok<NASGU>
                    save(ledSyncPath, 'ledPlan', 'ledEventTimesSeconds', ...
                        'timingBasis', 'remoteResult', '-v7.3');
                    files(end + 1) = string(ledSyncPath);
                    ledSummary = struct( ...
                        'schema_version', '1.1.0', ...
                        'camera_trigger_semantics', ...
                            'single_START_then_free_run', ...
                        'frame_limit_mode', 'finite', ...
                        'physical_bin_crop', false, ...
                        'timing_basis', ...
                            'shared_finite_DAQ_output_matrix', ...
                        'visual_stamp_used', false, ...
                        'planned_event_count', numel(daqPlan. ...
                            led_flicker_event_times_seconds), ...
                        'timing_mat_file', char(ledSyncPath));
                    ledManifestPath = fullfile(cyclePath, ...
                        'led_flicker_manifest.json');
                    zoulab.SessionManager.writeJson( ...
                        ledManifestPath, ledSummary);
                    files(end + 1) = string(ledManifestPath);
                end
                if app.RunState.AcquisitionStopRequested
                    status = 'stopped';
                elseif any(remoteResult.frames_retrieved == 0)
                    status = 'incomplete';
                end
                app.Logger.log('SUCCESS', ...
                    'PERSISTENT_CAMERA_RECORD_COMPLETE', ...
                    ['Cycle=%d | Status=%s | Acquired=%s | Retrieved=%s | ', ...
                     'Written=%s | CameraObjectsRemainConnected=1 | Files=%s'], ...
                    cycleIndex, status, ...
                    mat2str(remoteResult.frames_acquired), ...
                    mat2str(remoteResult.frames_retrieved), ...
                    mat2str(remoteResult.frames_written), strjoin(files, ','));
            catch ME
                if remoteStarted
                    try
                        remoteResult = app.Cameras.stopRemoteRecord( ...
                            'main_process_error_preserve_partial', app.Logger);
                        remoteStarted = false;
                        partialManifest = remoteResult.stream_manifest;
                        [partialFiles, ~, partialManifest] = ...
                            app.finalizeRecordStorage([], partialManifest, ...
                            app.planWithoutTiffConversion(plan), cyclePath, ...
                            cycleIndex);
                        files = [files partialFiles];
                        partial = struct('status', 'incomplete', ...
                            'reason', ME.message, 'files', cellstr(files), ...
                            'stream_manifest', partialManifest);
                        zoulab.SessionManager.writeJson(fullfile(cyclePath, ...
                            'partial_record_manifest.json'), partial);
                    catch preserveError
                        app.Logger.logException( ...
                            'PERSISTENT_PARTIAL_RECORD_PRESERVE_FAILED', ...
                            preserveError);
                    end
                end
                if strcmp(ME.identifier, 'ZouLab:AcquisitionStopped')
                    status = 'stopped';
                    return;
                end
                rethrow(ME);
            end
        end

        function setRemoteFlushProgress(app, cycleIndex, elapsed, total)
            message = sprintf( ...
                ['Finalizing Record Cycle %d — camera service is draining ', ...
                 'memory and closing BIN files (%.1f/%.0f s).'], ...
                cycleIndex, elapsed, total);
            app.AcquisitionStatusLabel.Text = message;
            app.setConversionDetail({'Record workflow: FLUSHING', message});
            drawnow limitrate;
        end

        function forceAcquisitionOutputsSafe(app, source)
            daqSafe = true;
            if ~isempty(app.DaqController)
                daqSafe = app.DaqController.safeOff();
            end
            spectraAttempted = false;
            spectraSafe = true;
            if ~isempty(app.SpectraController) && app.SpectraController.Connected
                spectraAttempted = true;
                try
                    app.SpectraController.allOff(app.Logger, source);
                catch ME
                    spectraSafe = false;
                    app.Logger.logException( ...
                        'FORCED_SAFE_SPECTRAX_OFF_FAILED', ME);
                end
            end
            coherentConnected = 0;
            coherentDisarmed = 0;
            for laserIndex = 1:numel(app.CoherentControllers)
                controller = app.CoherentControllers{laserIndex};
                if ~isempty(controller) && controller.Connected
                    coherentConnected = coherentConnected + 1;
                    try
                        controller.disarm(app.Logger);
                        coherentDisarmed = coherentDisarmed + 1;
                    catch ME
                        app.Logger.logException( ...
                            'FORCED_SAFE_COHERENT_DISARM_FAILED', ME);
                    end
                end
            end
            app.RecordImagingLightsOn = false;
            allSafe = daqSafe && spectraSafe && ...
                coherentDisarmed == coherentConnected;
            if allSafe
                level = 'SUCCESS';
            else
                level = 'ERROR';
            end
            app.Logger.log(level, 'ACQUISITION_OUTPUTS_FORCED_SAFE', ...
                ['Source=%s | DaqSafeOff=%d | SpectraAllOffAttempted=%d | ', ...
                 'SpectraSafe=%d | CoherentConnected=%d | ', ...
                 'CoherentDisarmed=%d | AllCommandsSucceeded=%d'], ...
                source, daqSafe, spectraAttempted, spectraSafe, ...
                coherentConnected, coherentDisarmed, allSafe);
        end

        function finishPersistentServiceRecordCycle(app, indices, lightRows, ...
                aliases, previousPreview, usedExternalTrigger)
            try
                serviceStatus = app.Cameras.queryStatus();
                if isfield(serviceStatus, 'record') && ...
                        logical(serviceStatus.record.active)
                    app.Cameras.stopRemoteRecord( ...
                        'persistent_cycle_cleanup_preserve_partial', app.Logger);
                end
            catch ME
                app.Logger.logException( ...
                    'PERSISTENT_CAMERA_RECORD_CLEANUP_FAILED', ME);
            end
            app.finishRecordCycle(indices, lightRows, aliases, ...
                previousPreview, usedExternalTrigger);
        end

        function [files, status] = runIsolatedVisualRecordCycle(app, plan, ...
                cyclePath, cycleIndex, indices, previousPreview, lightRows, ...
                aliases, cameraWindow, expectedCounts)
            files = strings(1, 0);
            status = 'complete';
            visualLogs = struct();
            rawSync = table();
            syncTable = table();
            workerResult = struct();
            workerCompleted = false;
            app.RecordImagingLightsOn = false;

            controlFolder = string(fullfile(cyclePath, ...
                '.acquisition_worker'));
            if ~exist(controlFolder, 'dir')
                mkdir(controlFolder);
            end
            outputFolders = {"", ""};
            expectedFull = zeros(1, 2);
            expectedFpsFull = nan(1, 2);
            for position = 1:numel(indices)
                cameraIndex = indices(position);
                outputFolders{cameraIndex} = ...
                    char(app.Sessions.cameraFolder(cyclePath, cameraIndex));
                expectedFull(cameraIndex) = expectedCounts(position);
                expectedFpsFull(cameraIndex) = ...
                    expectedCounts(position) / cameraWindow;
            end
            app.assertCycleBinNamespaces(cyclePath, cycleIndex, indices, ...
                outputFolders);
            workerConfig = struct( ...
                'schema_version', '1.0.0', ...
                'app_root', char(app.AppRoot), ...
                'control_folder', char(controlFolder), ...
                'log_folder', char(fullfile(controlFolder, 'logs')), ...
                'operator_id', char(app.Logger.OperatorID), ...
                'operator_name', char(app.Logger.OperatorName), ...
                'session_id', char(app.Logger.SessionID), ...
                'adaptor', char(app.Cameras.Adaptor), ...
                'cameras', indices, ...
                'video_formats', {cellstr(app.Cameras.VideoFormats)}, ...
                'rois', {app.Cameras.ROIs}, ...
                'exposure_seconds', app.Cameras.ExposureTimes, ...
                'bins', app.Cameras.Bins, ...
                'output_folders', {outputFolders}, ...
                'expected_frames', expectedFull, ...
                'expected_fps', expectedFpsFull, ...
                'trigger_mode', 'external', ...
                'frame_limit_mode', 'open_ended', ...
                'iat_stop_fraction', ...
                    zoulab.BufferedBinRecorder.IatProtectionFraction, ...
                'watchdog_seconds', cameraWindow + 300);

            app.Logger.log('INFO', 'ISOLATED_VISUAL_RECORD_PREPARE', ...
                ['Cycle=%d | Cameras=%s | WindowSeconds=%.6g | ', ...
                 'ExpectedFrames=%s | MainOwns=PTB,DAQ | ', ...
                 'WorkerOwns=videoinput,IAT,BIN_writers | ', ...
                 'FlipCallback=DAQ_stamp_only | UIRefreshDuringPTB=0'], ...
                cycleIndex, mat2str(indices), cameraWindow, ...
                mat2str(expectedCounts));
            app.Cameras.release(app.Logger);
            worker = zoulab.AcquisitionWorkerClient(workerConfig, app.Logger);
            app.ActiveAcquisitionWorker = worker;
            cleanup = onCleanup(@() app.finishIsolatedVisualRecordCycle( ...
                indices, lightRows, aliases, previousPreview)); %#ok<NASGU>
            try
                app.setAcquisitionState('PREPARING', sprintf( ...
                    'Cycle %d: camera storage process is starting.', cycleIndex));
                worker.waitReady(90, @(elapsed,total) ...
                    app.setAcquisitionState('PREPARING', sprintf( ...
                    'Cycle %d: camera worker %.1f/%.0f s', ...
                    cycleIndex, elapsed, total)));

                app.DaqController.beginVisualSync(indices, app.Logger);
                app.setImagingLights(lightRows, aliases, true);
                app.RecordImagingLightsOn = true;
                if ~app.waitInterruptible(max(0, ...
                        -plan.imaging_light_start_offset_seconds), sprintf( ...
                        'Cycle %d imaging-light preparation', cycleIndex))
                    error('ZouLab:AcquisitionStopped', ...
                        'Stop requested during record preparation.');
                end
                app.DaqController.pulseCameras(indices, app.Logger);
                app.Logger.log('SUCCESS', 'ISOLATED_CAMERA_START_SENT', ...
                    ['Cycle=%d | Cameras=%s | Trigger=single_DAQ_START | ', ...
                     'CameraFreeRunAfterStart=1'], cycleIndex, mat2str(indices));

                if ~app.waitInterruptible(plan.camera_pre_stim_seconds, ...
                        sprintf('Cycle %d pre-stimulus camera window', cycleIndex))
                    error('ZouLab:AcquisitionStopped', ...
                        'Stop requested during pre-stimulus camera window.');
                end
                app.VisualStimLamp.Color = [0.10 0.75 0.20];
                app.VisualStimStatusLabel.Text = 'Visual Stim RUNNING';
                app.Logger.log('INFO', 'VISUAL_STIMULUS_RUN_INDICATOR_ON', ...
                    ['Cycle=%d | Program=%s | BinDrainAfterEachFlip=0 | ', ...
                     'WorkerPollingInPTBProcess=0 | StampWritesPerFlip=3_high_1_low'], ...
                    cycleIndex, plan.visual_stimulus.spec.program);
                visualLogs = app.VisualStimulusController.run( ...
                    app.Logger, @() app.DaqController.stampVisualFrame(), []);
                app.updateVisualStimulusStatus();

                if ~app.waitInterruptible(plan.camera_post_stim_seconds, ...
                        sprintf('Cycle %d post-stimulus camera window', cycleIndex))
                    error('ZouLab:AcquisitionStopped', ...
                        'Stop requested during post-stimulus camera window.');
                end
                worker.requestStop('visual_camera_window_complete');
                [rawSync, syncTable] = app.DaqController.finishVisualSync( ...
                    indices, visualLogs.vbl, app.Logger);
                workerResult = worker.waitComplete(300, @(elapsed,total) ...
                    app.setAcquisitionState('FLUSHING', sprintf( ...
                    'Cycle %d: draining IAT and BIN writers %.1f/%.0f s', ...
                    cycleIndex, elapsed, total)));
                workerCompleted = true;
                app.ActiveAcquisitionWorker = [];

                streamManifest = workerResult.stream_manifest;
                streamManifest = zoulab.VisualFrameAlignment.apply( ...
                    streamManifest, syncTable, indices, app.Logger);
                if streamManifest.visual_alignment.all_cameras_valid
                    streamManifest.visual_physical_crop = struct( ...
                        'schema_version', '1.1.0', ...
                        'status', 'pending_record_complete', ...
                        'requested_utc', zoulab.BinInfo.utcNow(), ...
                        'execution', 'background_record_postprocessing', ...
                        'error_identifier', '', 'error', '');
                    app.Logger.log('INFO', ...
                        'VISUAL_BIN_CROP_DEFERRED', ...
                        ['Cycle=%d | Cameras=%s | ', ...
                         'StartBoundary=after_all_record_cycles | ', ...
                         'CycleSchedulerBlocked=0'], cycleIndex, ...
                        mat2str(indices));
                else
                    streamManifest.visual_physical_crop = struct( ...
                        'schema_version', '1.0.0', ...
                        'status', 'skipped_invalid_daq_alignment', ...
                        'completed_utc', zoulab.BinInfo.utcNow(), ...
                        'error_identifier', ...
                            'ZouLab:VisualCropAlignmentInvalid', ...
                        'error', ['Physical crop was skipped because at least ', ...
                            'one DAQ camera counter was invalid.']);
                end
                workerResult.stream_manifest = streamManifest;
                [recordFiles, storageStatus, streamManifest] = ...
                    app.finalizeRecordStorage([], streamManifest, plan, ...
                    cyclePath, cycleIndex);
                files = [files recordFiles];
                if storageStatus ~= "complete"
                    status = char(storageStatus);
                elseif app.recordIntegrityHasErrors(streamManifest)
                    status = 'complete_with_integrity_errors';
                elseif ~streamManifest.visual_alignment.all_cameras_valid
                    status = 'complete_with_alignment_errors';
                elseif string(workerResult.status) ~= "complete"
                    status = char(string(workerResult.status));
                end

                visualPath = fullfile(cyclePath, 'visual_sync.mat');
                save(visualPath, 'visualLogs', 'rawSync', 'syncTable', ...
                    'workerResult', '-v7.3');
                files(end + 1) = string(visualPath);
                logs = app.buildLegacyVisualLogs( ...
                    visualLogs, rawSync, syncTable, indices); %#ok<NASGU>
                logsPath = fullfile(cyclePath, 'logs.mat');
                save(logsPath, 'logs', '-v7.3');
                files(end + 1) = string(logsPath);
                visualSummary = struct( ...
                    'program', visualLogs.program, ...
                    'label', visualLogs.label, ...
                    'angle_sequence', app.visualAngleSequence(visualLogs), ...
                    'flip_count', numel(visualLogs.vbl), ...
                    'matched_sync_rows', height(syncTable), ...
                    'visual_frame_alignment', ...
                        streamManifest.visual_alignment, ...
                    'visual_bin_physical_crop', ...
                        streamManifest.visual_physical_crop, ...
                    'elapsed_seconds', visualLogs.elapsed_seconds, ...
                    'mat_file', char(visualPath), ...
                    'camera_storage', 'isolated_process_streamed_bin');
                visualManifestPath = fullfile(cyclePath, ...
                    'visual_stimulus_manifest.json');
                zoulab.SessionManager.writeJson(visualManifestPath, ...
                    visualSummary);
                files(end + 1) = string(visualManifestPath);
                app.Logger.log('SUCCESS', ...
                    'ISOLATED_VISUAL_RECORD_COMPLETE', ...
                    ['Cycle=%d | Status=%s | Acquired=%s | Retrieved=%s | ', ...
                     'Written=%s | VisualFlips=%d | MatchedSyncRows=%d | ', ...
                     'Files=%s'], cycleIndex, status, ...
                    mat2str(workerResult.frames_acquired), ...
                    mat2str(workerResult.frames_retrieved), ...
                    mat2str(workerResult.frames_written), ...
                    numel(visualLogs.vbl), height(syncTable), ...
                    strjoin(files, ','));
            catch ME
                if ~workerCompleted
                    try
                        worker.requestStop('main_process_error');
                        workerResult = worker.waitComplete(300);
                        app.Logger.log('WARNING', ...
                            'ISOLATED_WORKER_PARTIAL_DATA_PRESERVED', ...
                            'Cycle=%d | Retrieved=%s | Written=%s', ...
                            cycleIndex, ...
                            mat2str(workerResult.frames_retrieved), ...
                            mat2str(workerResult.frames_written));
                    catch workerError
                        app.Logger.logException( ...
                            'ISOLATED_WORKER_ERROR_CLEANUP_FAILED', workerError);
                    end
                end
                app.ActiveAcquisitionWorker = [];
                if strcmp(ME.identifier, 'ZouLab:AcquisitionStopped')
                    status = 'stopped';
                    return;
                end
                rethrow(ME);
            end
        end

        function finishIsolatedVisualRecordCycle(app, indices, lightRows, ...
                aliases, previousPreview)
            if ~isempty(app.ActiveAcquisitionWorker)
                try
                    app.ActiveAcquisitionWorker.requestStop( ...
                        'isolated_cycle_cleanup');
                catch ME
                    app.Logger.logException( ...
                        'ISOLATED_WORKER_STOP_REQUEST_FAILED', ME);
                end
                app.ActiveAcquisitionWorker = [];
            end
            if app.RecordImagingLightsOn
                try
                    app.setImagingLights(lightRows, aliases, false);
                catch ME
                    app.Logger.logException('RECORD_IMAGING_LIGHT_OFF_FAILED', ME);
                    app.DaqController.safeOff();
                end
            end
            app.RecordImagingLightsOn = false;
            try
                app.DaqController.abortVisualSync();
            catch
            end
            try
                app.ensureAcquisitionCameras(indices);
                app.Cameras.restorePreviewConfiguration(indices, app.Logger);
            catch ME
                app.Logger.logException( ...
                    'ISOLATED_CAMERA_RECONNECT_FAILED', ME);
            end
            app.restartPreviewMask(previousPreview, ...
                'isolated_visual_record_cleanup');
            app.updateVisualStimulusStatus();
            app.Logger.log('INFO', ...
                'ISOLATED_VISUAL_RECORD_CLEANUP_COMPLETE', ...
                ['Cameras=%s | ImagingLightsOff=1 | ', ...
                 'PreviewRestartMask=%s'], mat2str(indices), ...
                mat2str(previousPreview));
        end

        function recorder = createBinRecorder(app, indices, cyclePath, ...
                cycleIndex, expectedCounts, cameraWindow, bufferPolicy)
            outputFolders = {"", ""};
            frameSizes = {[], []};
            expectedFull = zeros(1, 2);
            fpsFull = nan(1, 2);
            cameraMetadata = {struct(), struct()};
            for position = 1:numel(indices)
                cameraIndex = indices(position);
                outputFolders{cameraIndex} = ...
                    app.Sessions.cameraFolder(cyclePath, cameraIndex);
                roi = app.Cameras.ROIs{cameraIndex};
                frameSizes{cameraIndex} = [roi(4) roi(3)];
                expectedFull(cameraIndex) = expectedCounts(position);
                fpsFull(cameraIndex) = expectedCounts(position) / cameraWindow;
                settings = app.Cameras.getActualSettings(cameraIndex);
                cameraMetadata{cameraIndex} = struct( ...
                    'logical_name', char(app.Cameras.LogicalNames(cameraIndex)), ...
                    'serial', char(app.Cameras.Serials(cameraIndex)), ...
                    'format', settings.VideoFormat, ...
                    'roi_xywh', settings.ROI, ...
                    'bin', settings.Bin, ...
                    'exposure_seconds', settings.ExposureTime, ...
                    'cycle_index', cycleIndex, ...
                    'cycle_folder', char(cyclePath));
            end
            app.assertCycleBinNamespaces(cyclePath, cycleIndex, indices, ...
                outputFolders);
            recorder = zoulab.BufferedBinRecorder(indices, outputFolders, ...
                frameSizes, expectedFull, fpsFull, app.Logger, bufferPolicy, ...
                cameraMetadata);
            app.WriterBackpressureActive(:) = false;
            app.IatProtectionTriggered = false;
            app.Logger.log('SUCCESS', 'RECORD_STREAM_RECORDER_CREATED', ...
                ['Cycle=%d | Cameras=%s | FrameSizes=%s | ', ...
                 'ExpectedFrames=%s | SegmentSeconds=%g | BlockFrames=%d | ', ...
                 'IatCapacityBytes=%s | IatStopBytes=%s'], ...
                app.RunState.AcquisitionCycleIndex, mat2str(indices), ...
                jsonencode(frameSizes(indices)), mat2str(expectedCounts), ...
                zoulab.BufferedBinRecorder.SegmentSeconds, ...
                zoulab.BufferedBinRecorder.BlockFrames, ...
                app.diagnosticValueText(bufferPolicy.iat_capacity_bytes), ...
                app.diagnosticValueText(bufferPolicy.iat_stop_bytes));
        end

        function assertCycleBinNamespaces(app, cyclePath, cycleIndex, ...
                indices, outputFolders)
            cycleRoot = zoulab.BufferedBinRecorder.normalizedPath(cyclePath);
            childPrefix = cycleRoot + '\';
            normalizedFolders = strings(1, numel(indices));
            for position = 1:numel(indices)
                cameraIndex = indices(position);
                folder = string(outputFolders{cameraIndex});
                normalizedFolders(position) = ...
                    zoulab.BufferedBinRecorder.normalizedPath(folder);
                if ~startsWith(normalizedFolders(position), childPrefix)
                    error('ZouLab:CycleBinFolderOutsideCycle', ...
                        ['Cycle %d Camera %d BIN folder is outside its Cycle ', ...
                         'directory. Cycle=%s | Folder=%s'], cycleIndex, ...
                        cameraIndex, cyclePath, folder);
                end
                existingBins = dir(fullfile(folder, 'Rec_*.bin'));
                existingInfos = dir(fullfile(folder, 'Rec_*.info.json'));
                if ~isempty(existingBins) || ~isempty(existingInfos)
                    error('ZouLab:CycleBinNamespaceAlreadyUsed', ...
                        ['Cycle %d Camera %d folder already contains BIN ', ...
                         'segments or INFO sidecars: %s'], cycleIndex, ...
                        cameraIndex, folder);
                end
                app.Logger.log('INFO', 'CYCLE_BIN_NAMESPACE_RESERVED', ...
                    ['Cycle=%d | Camera=%d | CycleFolder=%s | ', ...
                     'CameraFolder=%s | FirstBin=Rec_001.bin | ', ...
                     'FirstInfo=Rec_001.info.json | ExistingSegments=0 | ', ...
                     'CrossCycleReuse=0'], cycleIndex, cameraIndex, ...
                    cyclePath, folder);
            end
            if numel(unique(normalizedFolders)) ~= numel(normalizedFolders)
                error('ZouLab:CycleBinCameraFolderCollision', ...
                    'Cycle %d camera output folders are not unique.', cycleIndex);
            end
        end

        function completed = collectFiniteRecordToBin(app, recorder, indices, ...
                expectedCounts, timeoutSeconds, cycleIndex, totalCycles)
            target = zeros(1, 2);
            target(indices) = expectedCounts;
            if app.SimulationMode
                app.generateSimulationRecord(recorder, indices, expectedCounts);
                completed = ~app.RunState.AcquisitionStopRequested;
                return;
            end
            waitClock = tic;
            while toc(waitClock) < timeoutSeconds
                app.serviceBinRecorder(recorder, indices, 2, false);
                counts = recorder.RetrievedFrames;
                app.recordAcquisitionProgress(counts, indices, ...
                    expectedCounts, cycleIndex, totalCycles);
                if all(counts(indices) >= target(indices))
                    break;
                end
                if app.RunState.AcquisitionStopRequested
                    break;
                end
                metrics = app.Cameras.bufferedAcquisitionMetrics(indices);
                if all(~[metrics.Running]) && ...
                        all([metrics.FramesAvailable] == 0)
                    break;
                end
                pause(0.001);
                drawnow limitrate;
            end
            app.Cameras.stopBufferedAcquisition(indices, app.Logger, ...
                'finite_record_target_or_timeout');
            app.drainStoppedRecord(recorder, indices);
            completed = all(recorder.RetrievedFrames(indices) >= ...
                target(indices)) && ~app.RunState.AcquisitionStopRequested;
            if completed
                app.Logger.log('SUCCESS', ...
                    'FINITE_BIN_ACQUISITION_COLLECTION_COMPLETE', ...
                    'Cameras=%s | Expected=%s | Retrieved=%s | Elapsed=%.6g', ...
                    mat2str(indices), mat2str(expectedCounts), ...
                    mat2str(recorder.RetrievedFrames(indices)), toc(waitClock));
            else
                app.Logger.log('WARNING', ...
                    'FINITE_BIN_ACQUISITION_COLLECTION_INCOMPLETE', ...
                    ['Cameras=%s | Expected=%s | Retrieved=%s | ', ...
                     'Elapsed=%.6g | StopRequested=%d | PartialBinPreserved=1'], ...
                    mat2str(indices), mat2str(expectedCounts), ...
                    mat2str(recorder.RetrievedFrames(indices)), ...
                    toc(waitClock), app.RunState.AcquisitionStopRequested);
            end
        end

        function generateSimulationRecord(app, recorder, indices, expectedCounts)
            for position = 1:numel(indices)
                cameraIndex = indices(position);
                frameNumber = 1;
                fps = recorder.ExpectedFPS(cameraIndex);
                frameSize = recorder.FrameSizes{cameraIndex};
                while frameNumber <= expectedCounts(position)
                    while ~recorder.canAccept(cameraIndex)
                        recorder.processMessages(0.01);
                    end
                    take = min(zoulab.BufferedBinRecorder.BlockFrames, ...
                        expectedCounts(position) - frameNumber + 1);
                    data = uint16(randi([500 60000], frameSize(1), ...
                        frameSize(2), 1, take));
                    numbers = frameNumber:frameNumber + take - 1;
                    times = (numbers(:) - 1) / fps;
                    metadata = repmat(struct('AbsTime', [], ...
                        'FrameNumber', 0, 'RelativeFrame', 0, ...
                        'TriggerIndex', 1), take, 1);
                    for localIndex = 1:take
                        metadata(localIndex).FrameNumber = numbers(localIndex);
                        metadata(localIndex).RelativeFrame = numbers(localIndex);
                    end
                    recorder.ingest(cameraIndex, data, times, metadata);
                    frameNumber = frameNumber + take;
                end
            end
            recorder.processMessages(0);
            app.Logger.log('SUCCESS', 'BIN_RECORD_SIMULATION_GENERATED', ...
                'Cameras=%s | Counts=%s | FPS=%s | MetadataContinuous=1', ...
                mat2str(indices), mat2str(expectedCounts), ...
                mat2str(recorder.ExpectedFPS(indices)));
        end

        function serviceBinRecorder(app, recorder, indices, ...
                maxBlocksPerCamera, includePartial)
            if app.SimulationMode || recorder.Closed
                recorder.processMessages(0);
                return;
            end
            recorder.processMessages(0);
            metrics = app.Cameras.bufferedAcquisitionMetrics(indices);
            bytesPerFrame = zeros(1, numel(indices));
            for position = 1:numel(indices)
                cameraIndex = indices(position);
                bytesPerFrame(position) = ...
                    prod(recorder.FrameSizes{cameraIndex}) * 2;
            end
            iatPressure = zoulab.BufferedBinRecorder.computeIatPressure( ...
                [metrics.FramesAvailable], bytesPerFrame, ...
                recorder.IatBufferPolicy);
            stopBytes = recorder.IatBufferPolicy.iat_stop_bytes;
            if any([metrics.Running]) && iatPressure.stop_required
                if ~app.IatProtectionTriggered
                    app.IatProtectionTriggered = true;
                    app.Logger.log('ERROR', ...
                        'IAT_BUFFER_80_PERCENT_PROTECTION_TRIGGERED', ...
                        ['Cameras=%s | FramesAvailable=%s | ', ...
                         'IatBytesByCamera=%s | TotalIatBytes=%.0f | ', ...
                         'IatCapacityBytes=%.0f | StopFraction=%.3f | ', ...
                         'StopBytes=%.0f | BothCamerasStopRequested=1'], ...
                        mat2str(indices), ...
                        mat2str([metrics.FramesAvailable]), ...
                        mat2str(iatPressure.bytes_by_stream), ...
                        iatPressure.total_bytes, ...
                        recorder.IatBufferPolicy.iat_capacity_bytes, ...
                        recorder.IatBufferPolicy.iat_stop_fraction, stopBytes);
                end
                app.Cameras.stopBufferedAcquisition(indices, app.Logger, ...
                    'iat_buffer_80_percent_protection');
                error('ZouLab:IatBufferProtectionStop', ...
                    ['IAT buffers reached %.1f%% of the configured memory ', ...
                     'capacity. Both cameras were stopped; buffered frames ', ...
                     'will be preserved to BIN.'], ...
                    100 * recorder.IatBufferPolicy.iat_stop_fraction);
            end
            for position = 1:numel(indices)
                cameraIndex = indices(position);
                available = metrics(position).FramesAvailable;
                blocks = 0;
                while available > 0 && blocks < maxBlocksPerCamera
                    if ~includePartial && available < ...
                            zoulab.BufferedBinRecorder.BlockFrames
                        break;
                    end
                    if ~recorder.canAccept(cameraIndex)
                        if ~app.WriterBackpressureActive(cameraIndex)
                            app.WriterBackpressureActive(cameraIndex) = true;
                            app.Logger.log('WARNING', ...
                                'BIN_WRITER_BACKPRESSURE_ENTERED', ...
                                ['Camera=%d | InFlightBlocks=%d | ', ...
                                 'QueueLimitBlocks=%d | FramesAvailable=%d | ', ...
                                 'GetDataPaused=1 | IatContinuesBuffering=1'], ...
                                cameraIndex, ...
                                recorder.InFlightBlocks(cameraIndex), ...
                                recorder.MaxInFlightBlocksPerCamera, available);
                        end
                        break;
                    end
                    if app.WriterBackpressureActive(cameraIndex)
                        app.WriterBackpressureActive(cameraIndex) = false;
                        app.Logger.log('SUCCESS', ...
                            'BIN_WRITER_BACKPRESSURE_RECOVERED', ...
                            ['Camera=%d | InFlightBlocks=%d | ', ...
                             'FramesAvailable=%d | GetDataResumed=1'], ...
                            cameraIndex, ...
                            recorder.InFlightBlocks(cameraIndex), available);
                    end
                    take = min(available, ...
                        zoulab.BufferedBinRecorder.BlockFrames);
                    block = app.Cameras.takeBufferedFrames(cameraIndex, take);
                    recorder.ingest(cameraIndex, block.Data, block.Times, ...
                        block.Metadata);
                    available = available - take;
                    blocks = blocks + 1;
                end
            end
        end

        function drainStoppedRecord(app, recorder, indices)
            if app.SimulationMode
                recorder.processMessages(0);
                return;
            end
            drainClock = tic;
            while true
                recorder.processMessages(0);
                metrics = app.Cameras.bufferedAcquisitionMetrics(indices);
                if all([metrics.FramesAvailable] == 0)
                    break;
                end
                app.serviceBinRecorder(recorder, indices, 4, true);
                if toc(drainClock) > 180
                    error('ZouLab:BinIatDrainTimeout', ...
                        ['Stopped-camera IAT buffers did not drain within 180 ', ...
                         'seconds.']);
                end
                pause(0.001);
                drawnow limitrate;
            end
            app.Logger.log('SUCCESS', 'STOPPED_IAT_BUFFERS_DRAINED_TO_BIN', ...
                'Cameras=%s | RetrievedFrames=%s | Elapsed=%.6g', ...
                mat2str(indices), ...
                mat2str(recorder.RetrievedFrames(indices)), toc(drainClock));
        end

        function completed = waitRecordInterval(app, durationSeconds, message, ...
                recorder, indices)
            completed = true;
            if durationSeconds <= 0
                recorder.processMessages(0);
                return;
            end
            waitClock = tic;
            while toc(waitClock) < durationSeconds
                if app.RunState.AcquisitionStopRequested
                    completed = false;
                    return;
                end
                app.serviceBinRecorder(recorder, indices, 2, false);
                remaining = durationSeconds - toc(waitClock);
                app.AcquisitionStatusLabel.Text = sprintf( ...
                    'Working: %s (%.1f s remaining)', message, ...
                    max(0, remaining));
                pause(min(0.01, max(0.001, remaining)));
                drawnow limitrate;
            end
        end

        function visualRecordFlipService(app, recorder, indices)
            app.DaqController.stampVisualFrame();
            app.serviceBinRecorder(recorder, indices, 2, false);
        end

        function [files, status, streamManifest] = finalizeRecordStorage( ...
                app, recorder, streamManifest, plan, cyclePath, cycleIndex)
            files = strings(1, 0);
            binFiles = strings(1, 0);
            infoFiles = strings(1, 0);
            for cameraIndex = plan.cameras
                if isempty(recorder)
                    cameraPosition = find( ...
                        [streamManifest.cameras.camera] == cameraIndex, 1);
                    cameraManifest = streamManifest.cameras(cameraPosition);
                    binFiles = [binFiles ...
                        string(cameraManifest.bin_files)]; %#ok<AGROW>
                    infoFiles = [infoFiles ...
                        string(cameraManifest.bin_info_files)]; %#ok<AGROW>
                else
                    binFiles = [binFiles ...
                        recorder.BinFiles{cameraIndex}]; %#ok<AGROW>
                    infoFiles = [infoFiles ...
                        recorder.BinInfoFiles{cameraIndex}]; %#ok<AGROW>
                end
            end
            streamManifest.conversion = struct( ...
                'requested', logical(plan.convert_record_to_tiff), ...
                'status', app.recordConversionInitialStatus( ...
                    plan.convert_record_to_tiff), ...
                'deferred_until_all_record_cycles_complete', true, ...
                'sequential_unit_policy', ...
                    'legacy_field_superseded_by_parallel_unit_policy', ...
                'parallel_unit_policy', ...
                    'crop_by_cycle_tiff_by_cycle_camera', ...
                'delete_source_bin_after_unit_verification', true, ...
                'source_bin_deleted', false, ...
                'bin_info_files', {cellstr(infoFiles)}, ...
                'tiff_files', {{}}, ...
                'units', {struct([])}, ...
                'error', '');
            cropRequested = logical(plan.visual_stimulus_armed);
            streamManifest.postprocessing = struct( ...
                'requested', cropRequested || ...
                    logical(plan.convert_record_to_tiff), ...
                'status', app.recordPostProcessingInitialStatus( ...
                    cropRequested, plan.convert_record_to_tiff), ...
                'deferred_until_all_record_cycles_complete', true, ...
                'physical_bin_crop_requested', cropRequested, ...
                'convert_to_tiff_requested', ...
                    logical(plan.convert_record_to_tiff), ...
                'execution', 'background_batch', ...
                'error', '');
            status = "complete";
            files = [binFiles infoFiles];
            streamManifest.final_data_files = cellstr(files);
            streamManifest.integrity_has_errors = ...
                app.recordIntegrityHasErrors(streamManifest);
            manifestMat = string(fullfile(cyclePath, ...
                'record_stream_manifest.mat'));
            manifestJson = string(fullfile(cyclePath, ...
                'record_stream_manifest.json'));
            zoulab.SessionManager.writeMatManifest(manifestMat, streamManifest);
            zoulab.SessionManager.writeJson(manifestJson, streamManifest);
            files = [files manifestMat manifestJson];
            app.Logger.log('SUCCESS', 'RECORD_STREAM_MANIFEST_SAVED', ...
                ['Cycle=%d | Mat=%s | Json=%s | ConversionStatus=%s | ', ...
                 'IntegrityErrors=%d'], cycleIndex, manifestMat, manifestJson, ...
                streamManifest.conversion.status, ...
                streamManifest.integrity_has_errors);
            if cropRequested || plan.convert_record_to_tiff
                app.Logger.log('INFO', ...
                    'RECORD_POSTPROCESSING_DEFERRED_UNTIL_ALL_CYCLES', ...
                    ['Cycle=%d | PhysicalCrop=%d | ConvertToTiff=%d | ', ...
                     'BinFiles=%s | InfoFiles=%s | ', ...
                     'CycleSchedulerBlocked=0'], cycleIndex, cropRequested, ...
                    plan.convert_record_to_tiff, ...
                    strjoin(binFiles, ','), strjoin(infoFiles, ','));
            end
        end

        function value = recordPostProcessingInitialStatus(~, crop, convert)
            if crop || convert
                value = 'pending_record_complete';
            else
                value = 'not_requested';
            end
        end

        function value = recordConversionInitialStatus(~, requested)
            if requested
                value = 'pending_record_complete';
            else
                value = 'not_requested';
            end
        end

        function result = startRecordConversionBackground(app, plan, recordPath)
            try
                [job, config] = zoulab.ParallelTiffConverter.submit( ...
                    recordPath, plan, app.AppRoot);
                app.ConversionJob = job;
                app.ConversionConfig = config;
                app.ConversionRecordPath = string(recordPath);
                app.RunState.beginConversion();
                app.ConversionLastLoggedFraction = -1;
                app.ConversionLastLogTime = posixtime(datetime('now'));
                cropText = 'OFF';
                if config.crop_visual_bins
                    cropText = 'ON';
                end
                tiffText = 'OFF';
                if config.convert_to_tiff
                    tiffText = 'ON';
                end
                app.AcquisitionStatusLabel.Text = ...
                    'Record post-processing queued.';
                app.setConversionDetail({ ...
                    sprintf('Post-processing: queued | 0/%d units', ...
                        config.total_units), ...
                    sprintf(['BIN crop: %s | TIFF: %s | Workers: %d | ', ...
                        'source BIN retained until verification'], ...
                        cropText, tiffText, ...
                        config.worker_count), ...
                    sprintf('Record: %s', recordPath)});
                app.stopAndDeleteTimer('ConversionTimer');
                app.ConversionTimer = timer( ...
                    'ExecutionMode', 'fixedSpacing', 'Period', 0.5, ...
                    'BusyMode', 'drop', 'Name', 'ZouLabTiffConversion', ...
                    'TimerFcn', @(~,~) app.pollRecordConversion(), ...
                    'ErrorFcn', @(~,event) ...
                        app.recordConversionTimerError(event));
                start(app.ConversionTimer);
                app.Logger.log('SUCCESS', ...
                    'RECORD_BACKGROUND_POSTPROCESSING_JOB_SUBMITTED', ...
                    ['RecordPath=%s | JobID=%s | Units=%d | ', ...
                     'PhysicalBinCrop=%d | ConvertToTiff=%d | Workers=%d | ', ...
                     'WorkerLimit=%d | PhysicalCores=%d | ', ...
                     'AvailableMemoryBytes=%.0f | ', ...
                     'EstimatedBytesPerWorker=%.0f | ReadMode=%s | ', ...
                     'MainUiReleasedAfterSubmission=1 | ', ...
                     'OneExclusiveTiffPerWorker=%d'], ...
                    recordPath, app.parallelJobId(job), ...
                    config.total_units, config.crop_visual_bins, ...
                    config.convert_to_tiff, config.worker_count, ...
                    config.worker_limit, config.physical_core_count, ...
                    config.available_memory_bytes_at_submit, ...
                    config.estimated_bytes_per_worker, config.read_mode, ...
                    config.convert_to_tiff);
                result = struct('status', 'queued', ...
                    'worker_count', config.worker_count, ...
                    'total_units', config.total_units, ...
                    'total_frames', config.total_frames);
            catch ME
                app.RunState.finishConversion();
                app.ConversionJob = [];
                app.ConversionConfig = struct();
                app.ConversionRecordPath = "";
                app.AcquisitionStatusLabel.Text = ...
                    'Record post-processing could not start; BIN retained.';
                app.setConversionDetail({ ...
                    'Post-processing: launch failed; source BIN retained', ...
                    sprintf('Error: %s', ME.message), ...
                    sprintf('Record: %s', recordPath)});
                app.Logger.logException( ...
                    'RECORD_BACKGROUND_POSTPROCESSING_JOB_SUBMIT_FAILED', ME);
                result = struct('schema_version', '2.0.0', ...
                    'kind', 'record_post_capture_processing', ...
                    'status', 'launch_failed_source_bin_retained', ...
                    'started_at', app.localTimestamp(), ...
                    'completed_at', app.localTimestamp(), ...
                    'total_units', 0, 'completed_units', 0, ...
                    'total_frames', 0, 'converted_frames', 0, ...
                    'units', struct([]), 'error', ME.message);
                app.writeRecordConversionManifest(recordPath, result);
            end
        end

        function pollRecordConversion(app)
            if app.RunState.Closing || ~app.RunState.ConversionRunning || ...
                    isempty(fieldnames(app.ConversionConfig))
                return;
            end
            try
                progress = zoulab.ParallelTiffConverter.readProgress( ...
                    app.ConversionConfig);
                etaText = app.durationOrPending(progress.eta_seconds);
                app.AcquisitionStatusLabel.Text = sprintf( ...
                    'Post-processing %.1f%% | ETA %s', ...
                    100 * progress.fraction, etaText);
                app.setConversionDetail({ ...
                    sprintf('Post-processing: %.1f%% | %d/%d units complete', ...
                    100 * progress.fraction, progress.completed_units, ...
                        progress.total_units), ...
                    sprintf('Stage: %s | Cycle: %d | %s', ...
                        progress.stage, progress.current_cycle, ...
                        progress.stage_detail), ...
                    sprintf('Active: %d | errors: %d | elapsed %.1f s | ETA %s', ...
                        progress.active_units, progress.error_units, ...
                        progress.elapsed_seconds, etaText), ...
                    sprintf('Record: %s', app.ConversionRecordPath)});
                nowPosix = posixtime(datetime('now'));
                if progress.fraction >= 1 || ...
                        progress.fraction - ...
                        app.ConversionLastLoggedFraction >= 0.05 || ...
                        nowPosix - app.ConversionLastLogTime >= 30
                    app.Logger.log('INFO', ...
                        'RECORD_BACKGROUND_POSTPROCESSING_PROGRESS', ...
                        ['Percent=%.2f | CompletedUnits=%d/%d | ', ...
                         'ActiveUnits=%d | ErrorUnits=%d | ', ...
                         'ElapsedSeconds=%.1f | ETASeconds=%.1f'], ...
                        100 * progress.fraction, progress.completed_units, ...
                        progress.total_units, progress.active_units, ...
                        progress.error_units, progress.elapsed_seconds, ...
                        progress.eta_seconds);
                    app.ConversionLastLoggedFraction = progress.fraction;
                    app.ConversionLastLogTime = nowPosix;
                end
                jobState = app.parallelJobState(app.ConversionJob);
                if any(jobState == ["finished","failed","unavailable"])
                    app.finishRecordConversionMonitor(jobState);
                end
            catch ME
                app.Logger.logException( ...
                    'RECORD_BACKGROUND_POSTPROCESSING_MONITOR_FAILED', ME);
            end
        end

        function finishRecordConversionMonitor(app, jobState)
            recordPath = app.ConversionRecordPath;
            app.stopAndDeleteTimer('ConversionTimer');
            final = zoulab.ParallelTiffConverter.loadFinal(recordPath);
            if isempty(fieldnames(final)) || string(final.status) == "queued"
                final = struct('status', 'background_job_failed', ...
                    'error', sprintf( ...
                    'Post-processing job ended with state %s before a final manifest was written.', ...
                    jobState));
            end
            app.RunState.finishConversion();
            app.ConversionConfig = struct();
            app.ConversionRecordPath = "";
            try
                if ~isempty(app.ConversionJob)
                    delete(app.ConversionJob);
                end
            catch ME
                app.Logger.logException( ...
                    'RECORD_BACKGROUND_POSTPROCESSING_JOB_DELETE_FAILED', ME);
            end
            app.ConversionJob = [];

            status = string(final.status);
            convertedToTiff = isfield(final, 'tiff_conversion_requested') && ...
                logical(final.tiff_conversion_requested);
            if status == "complete"
                finalState = 'COMPLETED';
                if convertedToTiff
                    finalMessage = sprintf( ...
                        ['Record post-processing complete: BIN crop and ', ...
                         'TIFF conversion %d/%d units.'], ...
                        final.completed_units, final.total_units);
                else
                    finalMessage = sprintf( ...
                        'Record post-processing complete: BIN crop %d/%d units.', ...
                        final.completed_units, final.total_units);
                end
                level = 'SUCCESS';
                eventName = 'RECORD_BACKGROUND_POSTPROCESSING_COMPLETE';
            elseif status == "complete_with_source_bin_retained"
                finalState = 'COMPLETED_WITH_WARNINGS';
                finalMessage = ['TIFF conversion complete, but one or more ', ...
                    'source BIN files could not be deleted.'];
                level = 'WARNING';
                eventName = 'RECORD_BACKGROUND_POSTPROCESSING_CLEANUP_WARNING';
            else
                finalState = 'COMPLETED_WITH_WARNINGS';
                finalMessage = ['Record capture completed, but post-processing ', ...
                    'was incomplete. Original BIN data was retained; review logs.'];
                level = 'ERROR';
                eventName = 'RECORD_BACKGROUND_POSTPROCESSING_INCOMPLETE';
            end
            errorText = '';
            if isfield(final, 'error')
                errorText = char(string(final.error));
            end
            app.Logger.log(level, eventName, ...
                'RecordPath=%s | JobState=%s | Status=%s | Detail=%s', ...
                recordPath, jobState, status, errorText);
            app.setConversionDetail({ ...
                sprintf('Record post-processing: %s', status), ...
                sprintf('Job state: %s | %s', jobState, errorText), ...
                sprintf('Record: %s', recordPath)});
            app.Acquisition.writeAcquisitionManifest(recordPath, finalState, errorText);
            app.setAcquisitionState(finalState, finalMessage);
            app.updateAcquisitionControlAvailability(false);
        end

        function shutdownRecordConversion(app, reason)
            if isempty(app.ConversionJob)
                app.RunState.finishConversion();
                return;
            end
            recordPath = app.ConversionRecordPath;
            state = app.parallelJobState(app.ConversionJob);
            app.Logger.log('INFO', ...
                'RECORD_BACKGROUND_POSTPROCESSING_SHUTDOWN_REQUESTED', ...
                ['Reason=%s | JobState=%s | RecordPath=%s | ', ...
                 'IncompleteUnitBinRetentionExpected=1'], ...
                reason, state, app.ConversionRecordPath);
            if ~any(state == ["finished","failed","unavailable"])
                try
                    cancel(app.ConversionJob);
                catch ME
                    app.Logger.logException( ...
                        'RECORD_BACKGROUND_POSTPROCESSING_CANCEL_FAILED', ME);
                end
                deadline = tic;
                while toc(deadline) < 10
                    state = app.parallelJobState(app.ConversionJob);
                    if any(state == ["finished","failed","unavailable"])
                        break;
                    end
                    pause(0.1);
                end
            end
            try
                delete(app.ConversionJob);
            catch ME
                app.Logger.logException( ...
                    'RECORD_BACKGROUND_POSTPROCESSING_JOB_DELETE_FAILED', ME);
            end
            app.ConversionJob = [];
            app.RunState.finishConversion();
            app.ConversionConfig = struct();
            app.ConversionRecordPath = "";
            app.setConversionDetail({ ...
                sprintf('Record post-processing: stopped during %s', reason), ...
                ['Completed outputs remain; original BIN is retained for any ', ...
                 'incomplete unit.'], ...
                sprintf('Record: %s', recordPath)});
        end

        function setConversionDetail(app, lines)
            if isempty(app.ConversionDetailArea) || ...
                    ~isvalid(app.ConversionDetailArea)
                return;
            end
            values = string(lines(:));
            app.ConversionDetailArea.Value = cellstr(values);
        end

        function recordConversionTimerError(app, event)
            try
                errorValue = event.Data;
                if isa(errorValue, 'MException')
                    app.Logger.logException( ...
                        'RECORD_BACKGROUND_POSTPROCESSING_TIMER_ERROR', errorValue);
                else
                    app.Logger.log('ERROR', ...
                        'RECORD_BACKGROUND_POSTPROCESSING_TIMER_ERROR', ...
                        'TimerEvent=%s', app.diagnosticValueText(errorValue));
                end
            catch
            end
        end

        function value = parallelJobState(~, job)
            value = "unavailable";
            try
                if ~isempty(job) && isvalid(job)
                    value = lower(string(job.State));
                end
            catch
            end
        end

        function value = parallelJobId(~, job)
            value = '--';
            try
                value = char(string(job.ID));
            catch
            end
        end

        function value = durationOrPending(~, seconds)
            if ~isfinite(seconds)
                value = 'estimating...';
            elseif seconds >= 3600
                value = sprintf('%dh %02dm', floor(seconds / 3600), ...
                    floor(mod(seconds, 3600) / 60));
            elseif seconds >= 60
                value = sprintf('%dm %02ds', floor(seconds / 60), ...
                    floor(mod(seconds, 60)));
            else
                value = sprintf('%ds', max(0, ceil(seconds)));
            end
        end

        function result = convertRecordAfterAllCycles(app, plan, recordPath)
            startedAt = char(datetime('now', ...
                'Format', 'yyyy-MM-dd HH:mm:ss.SSS'));
            units = struct('cycle', {}, 'camera', {}, 'status', {}, ...
                'expected_frames', {}, 'written_frames', {}, ...
                'bin_info_files', {}, 'source_bin_files', {}, ...
                'tiff_files', {}, 'source_bin_deleted', {}, ...
                'partial_tiff_files_deleted', {}, ...
                'started_at', {}, 'completed_at', {}, 'error', {});
            streamManifests = cell(1, plan.cycles);
            totalFrames = 0;
            try
                for cycleIndex = 1:plan.cycles
                    cyclePath = string(fullfile(recordPath, ...
                        sprintf('Cycle%d', cycleIndex)));
                    manifestPath = fullfile(cyclePath, ...
                        'record_stream_manifest.mat');
                    loaded = load(manifestPath, 'manifest');
                    streamManifests{cycleIndex} = loaded.manifest;
                    for cameraIndex = plan.cameras
                        cameraPosition = find( ...
                            [loaded.manifest.cameras.camera] == cameraIndex, 1);
                        if isempty(cameraPosition)
                            error('ZouLab:RecordConversionCameraMissing', ...
                                ['Cycle %d stream manifest does not contain ', ...
                                 'Camera %d.'], cycleIndex, cameraIndex);
                        end
                        cameraManifest = ...
                            loaded.manifest.cameras(cameraPosition);
                        expectedFrames = cameraManifest.written_frames;
                        if isfield(cameraManifest, 'visual_alignment')
                            expectedFrames = cameraManifest.visual_alignment. ...
                                valid_frame_count;
                        end
                        totalFrames = totalFrames + expectedFrames;
                        units(end + 1) = struct( ... %#ok<AGROW>
                            'cycle', cycleIndex, ...
                            'camera', cameraIndex, ...
                            'status', 'pending', ...
                            'expected_frames', expectedFrames, ...
                            'written_frames', 0, ...
                            'bin_info_files', ...
                                {cellstr(string( ...
                                cameraManifest.bin_info_files))}, ...
                            'source_bin_files', ...
                                {cellstr(string(cameraManifest.bin_files))}, ...
                            'tiff_files', {{}}, ...
                            'source_bin_deleted', false, ...
                            'partial_tiff_files_deleted', {{}}, ...
                            'started_at', '', 'completed_at', '', ...
                            'error', '');
                    end
                end
            catch ME
                app.Logger.logException( ...
                    'RECORD_POST_CAPTURE_CONVERSION_PREPARE_FAILED', ME);
                result = struct('status', 'partial_error', ...
                    'started_at', startedAt, ...
                    'completed_at', app.localTimestamp(), ...
                    'total_units', numel(units), ...
                    'completed_units', 0, ...
                    'total_frames', totalFrames, ...
                    'converted_frames', 0, ...
                    'units', units, 'error', ME.message);
                app.writeRecordConversionManifest(recordPath, result);
                return;
            end

            app.setAcquisitionState('CONVERTING', sprintf( ...
                'Converting Record BIN to TIFF: 0.0%% (0/%d units)', ...
                numel(units)));
            app.Logger.log('INFO', 'RECORD_POST_CAPTURE_CONVERSION_BEGIN', ...
                ['RecordPath=%s | Cycles=%d | Units=%d | TotalFrames=%d | ', ...
                 'UnitPolicy=cycle_camera | CaptureAllCyclesComplete=1 | ', ...
                 'DeleteSourceBinImmediatelyAfterUnitVerification=1'], ...
                recordPath, plan.cycles, numel(units), totalFrames);
            progressDialog = app.createRecordConversionProgressDialog();
            dialogCleanup = onCleanup(@() ...
                app.closeRecordConversionProgressDialog(progressDialog)); %#ok<NASGU>
            completedFrames = 0;
            stopped = false;
            app.persistRecordConversionState(recordPath, plan, ...
                streamManifests, units, startedAt, 'converting', '', ...
                completedFrames, totalFrames);

            for unitIndex = 1:numel(units)
                if app.recordConversionStopRequested(progressDialog)
                    stopped = true;
                    break;
                end
                cycleIndex = units(unitIndex).cycle;
                cameraIndex = units(unitIndex).camera;
                cameraManifest = streamManifests{cycleIndex}.cameras( ...
                    [streamManifests{cycleIndex}.cameras.camera] == cameraIndex);
                cyclePath = string(fullfile(recordPath, ...
                    sprintf('Cycle%d', cycleIndex)));
                outputPath = string(fullfile( ...
                    app.Sessions.cameraFolder(cyclePath, cameraIndex), ...
                    'Rec.tif'));
                infoFiles = string(units(unitIndex).bin_info_files);
                sourceBinFiles = string(units(unitIndex).source_bin_files);
                frameRange = [];
                if isfield(cameraManifest, 'visual_alignment')
                    frameRange = cameraManifest.visual_alignment. ...
                        applied_frame_range;
                end
                units(unitIndex).status = 'converting';
                units(unitIndex).started_at = app.localTimestamp();
                app.Logger.log('INFO', 'RECORD_TIFF_UNIT_BEGIN', ...
                    ['Unit=%d/%d | Cycle=%d/%d | Camera=%d | ', ...
                     'ExpectedFrames=%d | BinFiles=%s'], unitIndex, ...
                    numel(units), cycleIndex, plan.cycles, cameraIndex, ...
                    units(unitIndex).expected_frames, ...
                    strjoin(sourceBinFiles, ','));
                try
                    [cameraTiffs, written, validatedBinFiles] = ...
                        zoulab.TiffStackWriter.writeFromBinInfo( ...
                        infoFiles, outputPath, app.Logger, ...
                        @(done,total,stack,stackTotal) ...
                        app.recordConversionProgress(progressDialog, ...
                        unitIndex, numel(units), cycleIndex, plan.cycles, ...
                        cameraIndex, completedFrames, done, total, ...
                        totalFrames, stack, stackTotal), ...
                        @() app.recordConversionStopRequested( ...
                        progressDialog), frameRange);
                    if written ~= units(unitIndex).expected_frames
                        error('ZouLab:TiffConversionCountMismatch', ...
                            'Cycle %d Camera %d converted %d of %d frames.', ...
                            cycleIndex, cameraIndex, written, ...
                            units(unitIndex).expected_frames);
                    end
                    zoulab.BinInfo.markConversion(infoFiles, 'complete', ...
                        cameraTiffs, '');
                    deleteFailures = strings(1, 0);
                    for fileIndex = 1:numel(validatedBinFiles)
                        try
                            if isfile(validatedBinFiles(fileIndex))
                                delete(validatedBinFiles(fileIndex));
                            end
                            app.Logger.log('SUCCESS', ...
                                'SOURCE_BIN_DELETED_AFTER_TIFF_UNIT_VERIFICATION', ...
                                ['Unit=%d/%d | Cycle=%d | Camera=%d | ', ...
                                 'File=%s | Recoverable=0'], unitIndex, ...
                                numel(units), cycleIndex, cameraIndex, ...
                                validatedBinFiles(fileIndex));
                        catch deleteError
                            deleteFailures(end + 1) = ... %#ok<AGROW>
                                validatedBinFiles(fileIndex);
                            app.Logger.logException( ...
                                'VERIFIED_SOURCE_BIN_DELETE_FAILED', ...
                                deleteError);
                        end
                    end
                    units(unitIndex).written_frames = written;
                    units(unitIndex).tiff_files = cellstr(cameraTiffs);
                    units(unitIndex).source_bin_files = ...
                        cellstr(validatedBinFiles);
                    units(unitIndex).source_bin_deleted = ...
                        isempty(deleteFailures);
                    units(unitIndex).completed_at = app.localTimestamp();
                    if isempty(deleteFailures)
                        units(unitIndex).status = 'complete';
                    else
                        units(unitIndex).status = ...
                            'complete_with_source_bin_retained';
                        units(unitIndex).error = sprintf( ...
                            'Could not delete verified source BIN: %s', ...
                            strjoin(deleteFailures, ','));
                    end
                    completedFrames = completedFrames + written;
                    app.Logger.log('SUCCESS', 'RECORD_TIFF_UNIT_COMPLETE', ...
                        ['Unit=%d/%d | Cycle=%d | Camera=%d | ', ...
                         'WrittenFrames=%d | SourceBinDeleted=%d | ', ...
                         'TiffFiles=%s'], unitIndex, numel(units), ...
                        cycleIndex, cameraIndex, written, ...
                        units(unitIndex).source_bin_deleted, ...
                        strjoin(cameraTiffs, ','));
                catch ME
                    units(unitIndex).completed_at = app.localTimestamp();
                    units(unitIndex).error = ME.message;
                    if strcmp(ME.identifier, 'ZouLab:TiffConversionStopped')
                        units(unitIndex).status = 'cancelled_source_bin_retained';
                        stopped = true;
                    else
                        units(unitIndex).status = 'error_source_bin_retained';
                    end
                    try
                        partialTiffs = dir(fullfile(fileparts(outputPath), ...
                            'Rec_stack*.tif'));
                        partialPaths = string(arrayfun( ...
                            @(entry) fullfile(entry.folder, entry.name), ...
                            partialTiffs, 'UniformOutput', false));
                        deletedPartials = strings(1, 0);
                        retainedPartials = strings(1, 0);
                        for partialIndex = 1:numel(partialPaths)
                            try
                                delete(partialPaths(partialIndex));
                                deletedPartials(end + 1) = ... %#ok<AGROW>
                                    partialPaths(partialIndex);
                                app.Logger.log('INFO', ...
                                    'INVALID_PARTIAL_TIFF_DELETED', ...
                                    ['Unit=%d/%d | Cycle=%d | Camera=%d | ', ...
                                     'File=%s | SourceBinRetained=1'], ...
                                    unitIndex, numel(units), cycleIndex, ...
                                    cameraIndex, partialPaths(partialIndex));
                            catch partialDeleteError
                                retainedPartials(end + 1) = ... %#ok<AGROW>
                                    partialPaths(partialIndex);
                                app.Logger.logException( ...
                                    'INVALID_PARTIAL_TIFF_DELETE_FAILED', ...
                                    partialDeleteError);
                            end
                        end
                        units(unitIndex).partial_tiff_files_deleted = ...
                            cellstr(deletedPartials);
                        units(unitIndex).tiff_files = ...
                            cellstr(retainedPartials);
                        zoulab.BinInfo.markConversion(infoFiles, ...
                            units(unitIndex).status, ...
                            retainedPartials, ME.message);
                    catch infoError
                        app.Logger.logException( ...
                            'BIN_INFO_CONVERSION_STATUS_UPDATE_FAILED', ...
                            infoError);
                    end
                    app.Logger.logException('RECORD_TIFF_UNIT_FAILED', ME);
                    app.Logger.log('ERROR', ...
                        'RECORD_TIFF_UNIT_SOURCE_BIN_RETAINED', ...
                        ['Unit=%d/%d | Cycle=%d | Camera=%d | ', ...
                         'BinFiles=%s | ContinueOtherUnits=%d'], unitIndex, ...
                        numel(units), cycleIndex, cameraIndex, ...
                        strjoin(sourceBinFiles, ','), ~stopped);
                end
                app.persistRecordConversionState(recordPath, plan, ...
                    streamManifests, units, startedAt, 'converting', '', ...
                    completedFrames, totalFrames);
                if stopped
                    break;
                end
            end

            statuses = string({units.status});
            if stopped
                overallStatus = 'cancelled';
                errorText = ['Conversion was cancelled. Completed units remain ', ...
                    'TIFF; current and pending units retain BIN.'];
            elseif all(statuses == "complete")
                overallStatus = 'complete';
                errorText = '';
            else
                overallStatus = 'partial_error';
                errorText = ['One or more conversion units failed or retained ', ...
                    'source BIN; see unit records.'];
            end
            result = app.persistRecordConversionState(recordPath, plan, ...
                streamManifests, units, startedAt, overallStatus, ...
                errorText, completedFrames, totalFrames);
            app.updateConversionCycleStatuses(units);
            if strcmp(overallStatus, 'complete')
                completionMessage = sprintf( ...
                    'TIFF conversion complete: 100%% | %d/%d units', ...
                    numel(units), numel(units));
                app.AcquisitionStatusLabel.Text = completionMessage;
                if ~isempty(progressDialog)
                    try
                        progressDialog.Value = 1;
                        progressDialog.Message = completionMessage;
                    catch
                    end
                end
                app.Logger.log('SUCCESS', ...
                    'RECORD_POST_CAPTURE_CONVERSION_COMPLETE', ...
                    ['RecordPath=%s | Units=%d | ConvertedFrames=%d | ', ...
                     'AllSourceBinDeleted=1'], recordPath, numel(units), ...
                    completedFrames);
            else
                app.Logger.log('WARNING', ...
                    'RECORD_POST_CAPTURE_CONVERSION_INCOMPLETE', ...
                    'RecordPath=%s | Status=%s | Detail=%s', ...
                    recordPath, overallStatus, errorText);
            end
        end

        function result = markRecordConversionSkipped(app, plan, ...
                recordPath, reason)
            result = struct('schema_version', '2.0.0', ...
                'kind', 'record_post_capture_processing', ...
                'status', 'skipped_capture_incomplete', ...
                'started_at', '', 'completed_at', app.localTimestamp(), ...
                'physical_bin_crop_requested', ...
                    logical(plan.visual_stimulus_armed), ...
                'tiff_conversion_requested', ...
                    logical(plan.convert_record_to_tiff), ...
                'unit_policy', 'cycle_camera', ...
                'source_delete_policy', ...
                    'after_each_unit_tiff_verification', ...
                'total_units', 0, 'completed_units', 0, ...
                'total_frames', 0, 'converted_frames', 0, ...
                'progress_fraction', 0, ...
                'units', struct([]), 'error', char(reason), ...
                'plan_cycles', plan.cycles);
            app.writeRecordConversionManifest(recordPath, result);
            app.Logger.log('WARNING', ...
                'RECORD_POST_CAPTURE_PROCESSING_SKIPPED', ...
                ['RecordPath=%s | Reason=%s | AllExistingSourceBinRetained=1'], ...
                recordPath, reason);
        end

        function result = persistRecordConversionState(app, recordPath, ...
                plan, streamManifests, units, startedAt, overallStatus, ...
                errorText, convertedFrames, totalFrames)
            completedStatuses = ["complete", ...
                "complete_with_source_bin_retained"];
            unitStatuses = string({units.status});
            completedUnits = sum(ismember(unitStatuses, completedStatuses));
            if strcmp(overallStatus, 'converting')
                completedAt = '';
            else
                completedAt = app.localTimestamp();
            end
            result = struct('schema_version', '1.0.0', ...
                'kind', 'record_post_capture_conversion', ...
                'status', char(overallStatus), ...
                'started_at', startedAt, ...
                'completed_at', completedAt, ...
                'capture_all_cycles_completed_before_conversion', true, ...
                'unit_policy', 'cycle_camera', ...
                'source_delete_policy', ...
                    'after_each_unit_tiff_verification', ...
                'total_units', numel(units), ...
                'completed_units', completedUnits, ...
                'total_frames', totalFrames, ...
                'converted_frames', convertedFrames, ...
                'progress_fraction', min(1, convertedFrames / ...
                    max(1, totalFrames)), ...
                'units', units, 'error', char(errorText), ...
                'plan_cycles', plan.cycles);
            app.writeRecordConversionManifest(recordPath, result);
            for cycleIndex = 1:min(plan.cycles, numel(streamManifests))
                if isempty(streamManifests{cycleIndex})
                    continue;
                end
                cycleUnits = units([units.cycle] == cycleIndex);
                cycleManifest = streamManifests{cycleIndex};
                cycleStatuses = string({cycleUnits.status});
                if isempty(cycleUnits)
                    cycleStatus = 'pending_record_complete';
                elseif all(cycleStatuses == "complete")
                    cycleStatus = 'complete';
                elseif all(ismember(cycleStatuses, completedStatuses))
                    cycleStatus = 'complete_with_source_bin_retained';
                elseif any(startsWith(cycleStatuses, "cancelled"))
                    cycleStatus = 'cancelled';
                elseif any(startsWith(cycleStatuses, "error"))
                    cycleStatus = 'partial_error';
                else
                    cycleStatus = 'converting';
                end
                cycleManifest.conversion.status = cycleStatus;
                cycleManifest.conversion.units = cycleUnits;
                cycleManifest.conversion.source_bin_deleted = ...
                    ~isempty(cycleUnits) && ...
                    all([cycleUnits.source_bin_deleted]);
                cycleManifest.conversion.tiff_files = cellstr(string( ...
                    [cycleUnits.tiff_files]));
                errorValues = string({cycleUnits.error});
                cycleManifest.conversion.error = char(strjoin( ...
                    errorValues(strlength(errorValues) > 0), ' | '));
                finalFiles = strings(1, 0);
                for unitIndex = 1:numel(cycleUnits)
                    finalFiles = [finalFiles ... %#ok<AGROW>
                        string(cycleUnits(unitIndex).bin_info_files) ...
                        string(cycleUnits(unitIndex).tiff_files)];
                    sourceFiles = string( ...
                        cycleUnits(unitIndex).source_bin_files);
                    finalFiles = [finalFiles ... %#ok<AGROW>
                        sourceFiles(isfile(sourceFiles))];
                end
                finalFiles = unique(finalFiles(isfile(finalFiles)), 'stable');
                cycleManifest.final_data_files = cellstr(finalFiles);
                cyclePath = string(fullfile(recordPath, ...
                    sprintf('Cycle%d', cycleIndex)));
                streamMat = string(fullfile(cyclePath, ...
                    'record_stream_manifest.mat'));
                streamJson = string(fullfile(cyclePath, ...
                    'record_stream_manifest.json'));
                zoulab.SessionManager.writeMatManifest( ...
                    streamMat, cycleManifest);
                zoulab.SessionManager.writeJson(streamJson, cycleManifest);
                app.refreshCycleFilesAfterConversion(cycleIndex, cyclePath, ...
                    finalFiles, streamMat, streamJson, cycleStatus, result);
            end
        end

        function refreshCycleFilesAfterConversion(app, cycleIndex, cyclePath, ...
                finalFiles, streamMat, streamJson, conversionStatus, ...
                conversionResult)
            resultIndex = find([app.RunState.AcquisitionCycleResults.cycle] == ...
                cycleIndex, 1);
            if isempty(resultIndex)
                return;
            end
            oldFiles = string( ...
                app.RunState.AcquisitionCycleResults(resultIndex).files);
            preserved = oldFiles(isfile(oldFiles));
            updatedFiles = unique([preserved finalFiles streamMat streamJson], ...
                'stable');
            app.RunState.AcquisitionCycleResults(resultIndex).files = ...
                cellstr(updatedFiles);
            cycleJson = string(fullfile(cyclePath, 'cycle_manifest.json'));
            if isfile(cycleJson)
                cycleValue = jsondecode(fileread(cycleJson));
                cycleValue.files = cellstr(updatedFiles);
                cycleValue.conversion = conversionResult;
                cycleValue.conversion.cycle_status = conversionStatus;
                cycleValue.updated_at = app.localTimestamp();
                zoulab.SessionManager.writeJson(cycleJson, cycleValue);
            end
            cycleMat = string(fullfile(cyclePath, 'cycle_manifest.mat'));
            if isfile(cycleMat)
                loaded = load(cycleMat, 'manifest');
                compatible = loaded.manifest;
                compatible.actual.movie_paths = cellstr(updatedFiles);
                compatible.notes.conversion_status = conversionStatus;
                compatible.notes.conversion_manifest = char(fullfile( ...
                    app.Sessions.RecordPath, ...
                    'record_conversion_manifest.mat'));
                compatible.timestamps.updated_at = app.localTimestamp();
                zoulab.SessionManager.writeMatManifest(cycleMat, compatible);
            end
        end

        function updateConversionCycleStatuses(app, units)
            for cycleIndex = unique([units.cycle])
                unitStatuses = string({units([units.cycle] == ...
                    cycleIndex).status});
                if all(unitStatuses == "complete")
                    continue;
                end
                resultIndex = find([app.RunState.AcquisitionCycleResults.cycle] == ...
                    cycleIndex, 1);
                if isempty(resultIndex)
                    continue;
                end
                if any(startsWith(unitStatuses, "cancelled")) || ...
                        any(unitStatuses == "pending")
                    suffix = 'conversion_cancelled';
                elseif any(startsWith(unitStatuses, "error"))
                    suffix = 'conversion_error';
                else
                    suffix = 'conversion_cleanup_warning';
                end
                prior = string( ...
                    app.RunState.AcquisitionCycleResults(resultIndex).status);
                if prior == "complete"
                    app.RunState.AcquisitionCycleResults(resultIndex).status = suffix;
                else
                    app.RunState.AcquisitionCycleResults(resultIndex).status = ...
                        char(prior + "+" + suffix);
                end
            end
        end

        function writeRecordConversionManifest(~, recordPath, value)
            basePaths = string(fullfile(recordPath, [ ...
                "record_postprocessing_manifest", ...
                "record_conversion_manifest"]));
            for basePath = basePaths
                zoulab.SessionManager.writeMatManifest( ...
                    basePath + ".mat", value);
                zoulab.SessionManager.writeJson(basePath + ".json", value);
            end
        end

        function dialog = createRecordConversionProgressDialog(app)
            dialog = [];
            try
                if isvalid(app.UIFigure) && ...
                        strcmpi(app.UIFigure.Visible, 'on')
                    dialog = uiprogressdlg(app.UIFigure, ...
                        'Title', 'Record TIFF conversion', ...
                        'Message', 'Preparing sequential conversion...', ...
                        'Indeterminate', 'off', 'Cancelable', 'on', ...
                        'Value', 0);
                end
            catch ME
                app.Logger.logException( ...
                    'TIFF_CONVERSION_PROGRESS_DIALOG_CREATE_FAILED', ME);
                dialog = [];
            end
        end

        function closeRecordConversionProgressDialog(app, dialog)
            if isempty(dialog)
                return;
            end
            try
                close(dialog);
            catch ME
                app.Logger.logException( ...
                    'TIFF_CONVERSION_PROGRESS_DIALOG_CLOSE_FAILED', ME);
            end
        end

        function value = recordConversionStopRequested(app, dialog)
            value = app.RunState.AcquisitionStopRequested || ...
                app.RunState.ConversionStopRequested;
            if value || isempty(dialog)
                return;
            end
            try
                if dialog.CancelRequested
                    app.RunState.requestConversionStop();
                    value = true;
                    app.Logger.log('INFO', ...
                        'USER_TIFF_CONVERSION_CANCEL_REQUESTED', ...
                        ['Completed units keep TIFF; current and pending ', ...
                         'units retain BIN.']);
                end
            catch
            end
        end

        function recordConversionProgress(app, dialog, unitIndex, unitTotal, ...
                cycleIndex, cycleTotal, cameraIndex, completedBefore, ...
                done, unitFrames, totalFrames, stack, stackTotal)
            globalDone = min(totalFrames, completedBefore + done);
            fraction = min(1, globalDone / max(1, totalFrames));
            app.RecordStatus(cameraIndex) = sprintf('%d/%d', done, unitFrames);
            app.refreshFPSLabel(cameraIndex, false);
            message = sprintf([ ...
                'Converting TIFF: %.1f%% | Unit %d/%d | Cycle %d/%d | ', ...
                'Cam%d %d/%d | Stack %d/%d'], fraction * 100, ...
                unitIndex, unitTotal, cycleIndex, cycleTotal, cameraIndex, ...
                done, unitFrames, stack, stackTotal);
            app.AcquisitionStatusLabel.Text = sprintf( ...
                'TIFF conversion %.1f%% | unit %d/%d', ...
                fraction * 100, unitIndex, unitTotal);
            app.setConversionDetail({ ...
                sprintf('TIFF conversion: %.1f%% | unit %d/%d', ...
                    fraction * 100, unitIndex, unitTotal), ...
                sprintf('Cycle %d/%d | Cam%d %d/%d frames', ...
                    cycleIndex, cycleTotal, cameraIndex, done, unitFrames), ...
                sprintf('TIFF stack %d/%d', stack, stackTotal)});
            if ~isempty(dialog)
                try
                    dialog.Value = fraction;
                    dialog.Message = message;
                catch
                end
            end
            app.Logger.log('INFO', 'RECORD_TIFF_CONVERSION_PROGRESS', ...
                ['Percent=%.3f | Unit=%d/%d | Cycle=%d/%d | Camera=%d | ', ...
                 'UnitFrames=%d/%d | Stack=%d/%d'], fraction * 100, ...
                unitIndex, unitTotal, cycleIndex, cycleTotal, cameraIndex, ...
                done, unitFrames, stack, stackTotal);
            drawnow limitrate;
        end

        function value = localTimestamp(~)
            value = char(datetime('now', ...
                'Format', 'yyyy-MM-dd HH:mm:ss.SSS'));
        end

        function value = recordIntegrityHasErrors(~, streamManifest)
            cameras = streamManifest.cameras;
            value = any([cameras.metadata_error_count] > 0) || ...
                any([cameras.writer_block_order_error_count] > 0);
        end

        function result = planWithoutTiffConversion(~, plan)
            result = plan;
            result.convert_record_to_tiff = false;
        end

        function daqPlan = compileFrozenDaqPlan(app, plan, lightRows, aliases)
            if strcmp(plan.mode, 'record')
                cameraWindow = plan.record_duration_seconds;
            else
                cameraWindow = 0.01;
            end
            spec = struct( ...
                'sample_rate_hz', plan.daq_sample_rate_hz, ...
                'cameras', plan.cameras, ...
                'camera_window_seconds', cameraWindow, ...
                'camera_trigger_width_seconds', ...
                    app.DaqController.PulseWidthSeconds, ...
                'imaging_light_start_offset_seconds', ...
                    plan.imaging_light_start_offset_seconds, ...
                'imaging_light_end_offset_seconds', ...
                    plan.imaging_light_end_offset_seconds, ...
                'camera_pre_stim_seconds', 0, ...
                'imaging_light_names', aliases, ...
                'imaging_light_analog_volts', ...
                    app.imagingLightAnalogVolts(lightRows), ...
                'led_flicker_armed', plan.led_flicker_armed, ...
                'led_flicker_delay_seconds', ...
                    plan.led_flicker.spec.delay_seconds, ...
                'led_flicker_start_offset_seconds', ...
                    plan.led_flicker.spec.delay_seconds, ...
                'led_flicker_hz_per_volt', ...
                    plan.led_flicker.spec.hz_per_volt, ...
                'led_flicker_do_points', ...
                    plan.led_flicker.spec.do_points, ...
                'led_flicker_ao_points', ...
                    plan.led_flicker.spec.ao_points);
            daqPlan = app.LightStimulusController.compileAcquisitionPlan( ...
                spec, app.timelineChannelNames(), app.Logger);
            app.Logger.log('SUCCESS', 'FROZEN_DAQ_PLAN_COMPILED', ...
                ['Mode=%s | CameraWindowSeconds=%.6g | LightRows=%s | ', ...
                 'LightAliases=%s | DurationSeconds=%.6g | Samples=%d'], ...
                plan.mode, cameraWindow, mat2str(lightRows), ...
                strjoin(aliases, ','), daqPlan.duration_seconds, ...
                size(daqPlan.output, 1));
        end

        function prepareDaqControlledLights(app, lightRows, aliases)
            stimulusNames = string( ...
                app.LightStimulusController.Spec.stimulus_light_names);
            app.DaqControlledLightsPrepared = true;
            daqInactiveConfirmed = app.DaqController.safeOff();
            if daqInactiveConfirmed
                app.Logger.log('SUCCESS', ...
                    'DAQ_INACTIVE_BEFORE_LIGHT_TTL_ARM', ...
                    'ConfiguredInactiveVectorWritten=1 | FlashPrevention=1');
            else
                app.Logger.log('ERROR', ...
                    'DAQ_INACTIVE_BEFORE_LIGHT_TTL_ARM_FAILED', ...
                    ['ConfiguredInactiveVectorWritten=0 | ', ...
                     'SpectraTTLChannelArmSkipped=1 | AcquisitionAllowed=1']);
            end
            for position = 1:numel(lightRows)
                row = lightRows(position);
                if row <= 2
                    if ~app.CoherentControllers{row}.Connected
                        error('ZouLab:ImagingObisDisconnected', ...
                            '%s must be connected for DAQ-controlled acquisition.', ...
                            aliases(position));
                    end
                    app.CoherentControllers{row}.armMixed(app.Logger);
                end
            end
            ttlStateVerified = true;
            spectraRows = lightRows(lightRows > 2);
            if ~isempty(spectraRows) && app.SpectraController.Connected && ...
                    daqInactiveConfirmed
                spectraChannels = arrayfun( ...
                    @(row) app.spectraChannelForRow(row), spectraRows);
                try
                    app.SpectraController.armTTLChannels( ...
                        spectraChannels, app.Logger);
                catch ME
                    ttlStateVerified = false;
                    app.Logger.logException( ...
                        'SPECTRAX_TTL_CHANNEL_ARM_FAILED_NONBLOCKING', ME);
                end
            elseif ~isempty(spectraRows) && ~daqInactiveConfirmed
                ttlStateVerified = false;
                app.Logger.log('WARNING', 'SPECTRAX_TTL_MODE_UNVERIFIED', ...
                    ['ImagingRows=%s | ImagingAliases=%s | ', ...
                     'Reason=daq_inactive_state_not_confirmed | ', ...
                     'SpectraChannelArmSkipped=1 | DaqAcquisitionAllowed=1'], ...
                    mat2str(lightRows), strjoin(aliases, ','));
            elseif ~isempty(spectraRows)
                ttlStateVerified = false;
                app.Logger.log('WARNING', 'SPECTRAX_TTL_MODE_UNVERIFIED', ...
                    ['ImagingRows=%s | ImagingAliases=%s | SpectraConnected=0 | ', ...
                     'UsbTtlModeConfirmationSkipped=1 | DaqAcquisitionAllowed=1'], ...
                    mat2str(lightRows), strjoin(aliases, ','));
            end
            app.Logger.log('SUCCESS', 'DAQ_CONTROLLED_LIGHTS_PREPARED', ...
                ['ImagingRows=%s | ImagingAliases=%s | StimulusAliases=%s | ', ...
                 'DAQ=%s | TTLStateVerified=%d'], mat2str(lightRows), ...
                strjoin(aliases, ','), strjoin(stimulusNames, ','), ...
                app.DaqController.DeviceID, ttlStateVerified);
        end

        function restoreDaqControlledLights(app, lightRows, aliases)
            if ~app.DaqControlledLightsPrepared
                return;
            end
            stimulusNames = string( ...
                app.LightStimulusController.Spec.stimulus_light_names);
            if app.SpectraController.Connected && any(lightRows > 2)
                try
                    app.SpectraController.disarmTTLChannels( ...
                        app.Logger, 'finite_plan_complete');
                catch ME
                    app.Logger.logException('SPECTRAX_TTL_RESTORE_FAILED', ME);
                end
            end
            for position = 1:numel(lightRows)
                row = lightRows(position);
                if row <= 2 && ~any(stimulusNames == aliases(position))
                    try
                        app.CoherentControllers{row}.disarm(app.Logger);
                    catch ME
                        app.Logger.logException( ...
                            'IMAGING_OBIS_DIGITAL_DISARM_FAILED', ME);
                    end
                end
            end
            app.DaqControlledLightsPrepared = false;
            app.Logger.log('INFO', 'DAQ_CONTROLLED_LIGHTS_RESTORED', ...
                ['ImagingAliases=%s | StimulusArmedStateRetained=%d | ', ...
                 'DAQOutputsSafeOff=1'], strjoin(aliases, ','), ...
                app.LightStimulusController.Armed);
        end

        function saveDaqPlanArtifacts(app, targetPath, daqPlan, acquisitionPlan)
            output = daqPlan.output; %#ok<NASGU>
            matPath = fullfile(targetPath, 'daq_output.mat');
            pngPath = fullfile(targetPath, 'daq_output.png');
            timelinePath = fullfile(targetPath, 'timeline.png');
            if isfile(matPath) && isfile(pngPath) && isfile(timelinePath)
                app.Logger.log('INFO', 'DAQ_PLAN_ARTIFACTS_REUSED', ...
                    ['Mat=%s | Png=%s | Timeline=%s | ', ...
                     'Reason=record_frozen_plan_artifacts_already_exist | Overwrite=0'], ...
                    matPath, pngPath, timelinePath);
                return;
            end
            if ~isfile(matPath)
                save(matPath, 'output', 'daqPlan', '-v7.3');
            else
                app.Logger.log('INFO', 'DAQ_PLAN_MAT_RETAINED', ...
                    'File=%s | Overwrite=0', matPath);
            end
            if ~isfile(pngPath)
                figureHandle = figure('Visible', 'off', 'Color', 'w', ...
                    'Name', 'DAQ Output');
                cleanup = onCleanup(@() close(figureHandle));
                active = find(any(output ~= 0, 1));
                if isempty(active)
                    axes('Parent', figureHandle);
                    text(0.5, 0.5, 'No active DAQ outputs', ...
                        'HorizontalAlignment', 'center');
                    axis off;
                else
                    layout = tiledlayout(figureHandle, numel(active), 1, ...
                        'TileSpacing', 'compact', 'Padding', 'compact');
                    plotIndex = 1:numel(daqPlan.time_seconds);
                    for position = 1:numel(active)
                        channel = active(position);
                        ax = nexttile(layout);
                        stairs(ax, daqPlan.time_seconds(plotIndex), ...
                            output(plotIndex, channel), 'LineWidth', 1);
                        if startsWith(string(daqPlan.channel_names(channel)), ...
                                "light_stim_AO_")
                            ylim(ax, [-0.1 max(5.1, ...
                                max(output(:, channel)) + 0.1)]);
                        else
                            ylim(ax, [-0.1 1.1]);
                        end
                        ylabel(ax, strrep(daqPlan.channel_names(channel), '_', ' '), ...
                            'Interpreter', 'none');
                        grid(ax, 'on');
                    end
                    xlabel(layout, 'Time relative to Camera START (s)');
                    title(layout, sprintf( ...
                        'Exact commanded output | %.0f Hz | %.4g s', ...
                        daqPlan.sample_rate_hz, daqPlan.duration_seconds));
                end
                exportgraphics(figureHandle, pngPath, 'Resolution', 150);
                clear cleanup;
            end
            if ~isfile(timelinePath)
                app.saveFrozenTimelineArtifact( ...
                    timelinePath, daqPlan, acquisitionPlan);
            end
            app.Logger.log('SUCCESS', 'DAQ_PLAN_ARTIFACTS_SAVED', ...
                ['RecordRoot=%s | Mat=%s | Png=%s | Timeline=%s | ', ...
                 'SavedOncePerRecord=1 | SharedByCycles=%d | ', ...
                 'OutputVariableCompatibleWithRebuilt=1 | PlanMetadataIncluded=1'], ...
                targetPath, matPath, pngPath, timelinePath, ...
                acquisitionPlan.cycles);
        end

        function saveFrozenTimelineArtifact(app, filePath, daqPlan, acquisitionPlan)
            figureHandle = figure('Visible', 'off', 'Color', 'w', ...
                'Name', 'Frozen Acquisition Timeline', ...
                'Position', [100 100 1800 520]);
            cleanup = onCleanup(@() close(figureHandle));
            axesHandle = axes('Parent', figureHandle);
            hold(axesHandle, 'on');
            active = find(any(daqPlan.output ~= 0, 1));
            traces = daqPlan.output(:, active);
            names = daqPlan.channel_names(active);
            visual = app.frozenVisualTimelineTrace(daqPlan, acquisitionPlan);
            if visual.included
                traces(:, end + 1) = visual.values;
                names(end + 1) = "visual_software";
            end
            [displayTime, displayTraces] = app.timelineDisplayData( ...
                daqPlan.time_seconds, traces);
            handles = gobjects(1, 0);
            for position = 1:numel(names)
                [color, lineStyle, lineWidth] = app.timelineStyle(names(position));
                handles(end + 1) = stairs(axesHandle, displayTime, ...
                    displayTraces(:, position), 'Color', color, ...
                    'LineStyle', lineStyle, 'LineWidth', lineWidth, ...
                    'DisplayName', char(app.timelineDisplayName( ...
                    names(position)))); %#ok<AGROW>
            end
            if isempty(handles)
                text(axesHandle, 0.5, 0.5, ...
                    'No active DAQ, AO, DMD, or PTB plan', ...
                    'HorizontalAlignment', 'center');
            else
                legend(axesHandle, handles, 'Location', 'northoutside', ...
                    'Orientation', 'horizontal', 'NumColumns', ...
                    min(5, numel(handles)));
            end
            maximumValue = 1;
            if ~isempty(traces)
                maximumValue = max(1, max(traces, [], 'all'));
            end
            ylim(axesHandle, [-0.08 maximumValue + 0.08]);
            xLimits = [daqPlan.time_seconds(1), daqPlan.time_seconds(end)];
            if xLimits(2) <= xLimits(1)
                xLimits(2) = xLimits(1) + 0.01;
            end
            xlim(axesHandle, xLimits);
            xlabel(axesHandle, 'Time relative to Camera START (s)');
            ylabel(axesHandle, 'TTL logic / AO voltage (V)');
            title(axesHandle, sprintf( ...
                'Frozen Record timeline | %.0f Hz | %d cycle(s) share this plan', ...
                daqPlan.sample_rate_hz, acquisitionPlan.cycles));
            grid(axesHandle, 'on');
            xline(axesHandle, daqPlan.camera_start_seconds, ':', ...
                'HandleVisibility', 'off');
            xline(axesHandle, daqPlan.camera_end_seconds, ':', ...
                'HandleVisibility', 'off');
            exportgraphics(figureHandle, filePath, 'Resolution', 150);
            clear cleanup;
        end

        function visual = frozenVisualTimelineTrace(~, daqPlan, acquisitionPlan)
            visual = struct('included', false, ...
                'values', zeros(size(daqPlan.time_seconds)));
            if ~acquisitionPlan.visual_stimulus_armed || ...
                    ~isfield(acquisitionPlan.visual_stimulus, 'spec')
                return;
            end
            spec = acquisitionPlan.visual_stimulus.spec;
            startTime = acquisitionPlan.camera_pre_stim_seconds;
            values = zeros(size(daqPlan.time_seconds));
            if ismember(string(spec.program), ...
                    ["drifting_grating","random_drifting_grating"])
                schedule = zoulab.VisualStimulusController. ...
                    gratingEpochSchedule(spec, startTime);
                for epochIndex = 1:height(schedule)
                    values(daqPlan.time_seconds >= ...
                        schedule.GratingStartSeconds(epochIndex) & ...
                        daqPlan.time_seconds < ...
                        schedule.GratingEndSeconds(epochIndex)) = 1;
                end
            else
                endTime = startTime + spec.estimated_duration_seconds;
                values(daqPlan.time_seconds >= startTime & ...
                    daqPlan.time_seconds < endTime) = 1;
            end
            visual.included = true;
            visual.values = values;
        end

        function setImagingLights(app, lightRows, aliases, turnOn)
            if app.SimulationMode
                app.Logger.log('INFO', 'SIMULATION_IMAGING_LIGHT_STATE', ...
                    'Rows=%s | Aliases=%s | State=%s', mat2str(lightRows), ...
                    strjoin(aliases, ','), upper(app.onOff(turnOn)));
                return;
            end
            if isempty(lightRows)
                return;
            end
            app.DaqController.assertReady();
            spectraRows = lightRows(lightRows > 2);
            if ~isempty(spectraRows) && app.SpectraController.Connected
                spectraChannels = arrayfun( ...
                    @(row) app.spectraChannelForRow(row), spectraRows);
                app.SpectraController.armTTLChannels( ...
                    spectraChannels, app.Logger);
            elseif ~isempty(spectraRows)
                app.Logger.log('WARNING', ...
                    'SPECTRAX_TTL_MODE_UNVERIFIED_ACQUISITION', ...
                    ['Rows=%s | Aliases=%s | SpectraConnected=0 | ', ...
                     'DAQCommandAllowed=1'], mat2str(spectraRows), ...
                    strjoin(app.lightAliases(spectraRows), ','));
            end
            data = app.LightTable.Data;
            for position = 1:numel(lightRows)
                row = lightRows(position);
                alias = aliases(position);
                if row <= 2
                    if ~app.CoherentControllers{row}.Connected
                        error('ZouLab:ImagingObisDisconnected', ...
                            '%s must be connected for AO + DO control.', alias);
                    end
                    [actualOn, verification] = app.commandCoherentManualState( ...
                        row, turnOn);
                else
                    app.DaqController.setLights(alias, turnOn, app.Logger);
                    actualOn = turnOn;
                    verification = ...
                        'DAQ TTL command; USB serial controls intensity only';
                end
                data{row,8} = app.lightStateText(actualOn);
                app.Logger.log('SUCCESS', 'ACQUISITION_LIGHT_STATE_CONFIRMED', ...
                    ['Row=%d | Alias=%s | RequestedOn=%d | CommandedOn=%d | ', ...
                     'SwitchOwner=DAQ_TTL | Verification=%s'], ...
                    row, alias, turnOn, actualOn, verification);
            end
            app.LightTable.Data = data;
        end

        function textValue = spectraPowerEvidenceText(app, row)
            channel = app.spectraChannelForRow(row);
            if channel < 1 || ...
                    channel > numel(app.SpectraController.PowerEvidenceAvailable) || ...
                    ~app.SpectraController.PowerEvidenceAvailable(channel)
                textValue = 'power query unavailable';
                return;
            end
            powerMilliwatts = app.SpectraController.PowerMilliwatts(channel);
            powerLevel = app.SpectraController.PowerLevels(channel);
            if isfinite(powerMilliwatts)
                textValue = sprintf('measured %.4g mW', powerMilliwatts);
            elseif isfinite(powerLevel)
                textValue = sprintf('power level %.4g', powerLevel);
            else
                textValue = 'power query unavailable';
            end
        end

        function textValue = lightPowerEvidenceText(app, row)
            if row <= 2
                volts = app.lightLevelPercentToVolts( ...
                    row, app.LightTable.Data{row,7});
                textValue = sprintf( ...
                    'commanded AO %.4g V; optical feedback unavailable', volts);
            else
                textValue = app.spectraPowerEvidenceText(row);
            end
        end

        function unit = lightLevelUnit(~, row)
            if row <= 2
                unit = 'AO %';
            else
                unit = '%';
            end
        end

        function channel = spectraChannelForRow(app, row)
            if row <= 2 || row > size(app.LightTable.Data, 1)
                error('ZouLab:SpectraRowInvalid', ...
                    'Light-table row %d is not a visible Spectra X channel.', row);
            end
            channel = double(app.LightTable.Data{row,2}) + 1;
            if channel < 1 || channel > 6
                error('ZouLab:SpectraChannelInvalid', ...
                    'Light-table row %d maps to invalid Spectra channel %d.', ...
                    row, channel);
            end
        end

        function volts = lightLevelPercentToVolts(app, row, percent)
            alias = string(app.LightTable.Data{row,4});
            analogIndex = find(app.DaqController.AnalogLightNames == alias, 1);
            if isempty(analogIndex)
                error('ZouLab:AnalogLightMappingMissing', ...
                    'No AO mapping is configured for %s.', alias);
            end
            percent = double(percent);
            minimum = app.DaqController.AnalogMinimumVolts(analogIndex);
            maximum = app.DaqController.AnalogMaximumVolts(analogIndex);
            volts = minimum + (maximum - minimum) * percent / 100;
        end

        function [actualOn, verification] = commandCoherentManualState(app, row, turnOn)
            alias = string(app.LightTable.Data{row,4});
            controller = app.CoherentControllers{row};
            if ~controller.Connected
                error('ZouLab:ObisNotConnected', ...
                    'Connect %s by USB before changing its state.', alias);
            end
            app.DaqController.assertReady();
            volts = app.lightLevelPercentToVolts( ...
                row, app.LightTable.Data{row,7});
            if turnOn
                app.DaqController.setLights(alias, false, app.Logger);
                app.DaqController.setLaserAnalogVoltage(alias, volts, app.Logger);
                controller.armMixed(app.Logger);
                app.DaqController.setLights(alias, true, app.Logger);
            else
                app.DaqController.setLights(alias, false, app.Logger);
                app.DaqController.setLaserAnalogVoltage(alias, 0, app.Logger);
                controller.setManualState(false, app.Logger);
            end
            actualOn = logical(turnOn);
            verification = sprintf( ...
                'MIXED mode | DO=%s | AO=%.4g V | optical feedback unavailable', ...
                upper(app.onOff(turnOn)), double(turnOn) * volts);
            app.Logger.log('SUCCESS', 'COHERENT_MIXED_OUTPUT_COMMAND_CONFIRMED', ...
                ['Row=%d | Alias=%s | DOState=%s | AOVolts=%.6g | ', ...
                 'OpticalFeedbackAvailable=0'], row, alias, ...
                upper(app.onOff(turnOn)), double(turnOn) * volts);
        end

        function assertLightControlEditable(app)
            if app.RunState.AcquisitionRunning || app.LightStimulusController.Armed
                error('ZouLab:LightControlLocked', ...
                    ['Manual light state and intensity are locked while Acquisition ', ...
                     'is running or Light Stimulus is armed. Disarm/stop first.']);
            end
        end

        function verifyLightPreviewIsolation(app, stateBefore, row, turnOn, source)
            stateAfter = app.PreviewActive;
            if isequal(stateAfter, stateBefore)
                app.Logger.log('SUCCESS', ...
                    'LIGHT_ACTION_PREVIEW_STATE_ISOLATED', ...
                    ['Row=%d | RequestedOn=%d | Source=%s | ', ...
                     'PreviewBefore=%s | PreviewAfter=%s | ', ...
                     'CameraPreviewCommandIssued=0'], ...
                    row, turnOn, source, mat2str(stateBefore), ...
                    mat2str(stateAfter));
            else
                app.Logger.log('ERROR', ...
                    'LIGHT_ACTION_PREVIEW_STATE_CHANGED_UNEXPECTEDLY', ...
                    ['Row=%d | RequestedOn=%d | Source=%s | ', ...
                     'PreviewBefore=%s | PreviewAfter=%s'], ...
                    row, turnOn, source, mat2str(stateBefore), ...
                    mat2str(stateAfter));
            end
        end

        function finishRecordCycle(app, indices, lightRows, aliases, ~, ~)
            if app.DaqController.FinitePlanRunning
                try
                    app.DaqController.finishFinitePlan(app.Logger);
                catch ME
                    app.Logger.logException('RECORD_DAQ_PLAN_FINISH_FAILED', ME);
                    app.DaqController.safeOff();
                end
            end
            app.restoreDaqControlledLights(lightRows, aliases);
            if app.RecordImagingLightsOn
                try
                    app.setImagingLights(lightRows, aliases, false);
                catch ME
                    app.Logger.logException('RECORD_IMAGING_LIGHT_OFF_FAILED', ME);
                    app.DaqController.safeOff();
                end
            end
            app.RecordImagingLightsOn = false;
            try
                app.DaqController.abortVisualSync();
            catch
            end
            app.updateVisualStimulusStatus();
            if app.LightStimulusController.Armed
                app.LightStimLamp.Color = [0.95 0.65 0.10];
                app.LightStimStatusLabel.Text = 'Light Stim ARMED';
            else
                app.LightStimLamp.Color = [0.65 0.65 0.65];
                app.LightStimStatusLabel.Text = 'Light Stim OFF';
            end
            app.Logger.log('INFO', 'RECORD_CYCLE_CLEANUP_COMPLETE', ...
                ['Cameras=%s | ImagingLightsOff=1 | ', ...
                 'CameraConfigurationRetainedForNextCycle=1 | ', ...
                 'PreviewRestartedBetweenCycles=0'], mat2str(indices));
        end

        function recordAcquisitionProgress(app, counts, indices, targets, ...
                cycleIndex, totalCycles)
            values = counts(indices);
            for position = 1:numel(indices)
                cameraIndex = indices(position);
                app.RecordStatus(cameraIndex) = sprintf('%d/%d', ...
                    values(position), targets(position));
                app.refreshFPSLabel(cameraIndex, false);
            end
            cameraParts = strings(1, numel(indices));
            for position = 1:numel(indices)
                cameraParts(position) = sprintf('Camera %d: %d/%d frames', ...
                    indices(position), values(position), targets(position));
            end
            app.AcquisitionStatusLabel.Text = sprintf( ...
                'Recording Cycle %d/%d — %s', cycleIndex, totalCycles, ...
                strjoin(cameraParts, ' | '));
            app.setConversionDetail({ ...
                sprintf('Record workflow: CAPTURING Cycle %d/%d', ...
                    cycleIndex, totalCycles), char(strjoin(cameraParts, ' | '))});
        end

        function recordWriteProgress(app, cameraIndex, done, total, ...
                stack, stackTotal, cycleIndex)
            app.RecordStatus(cameraIndex) = sprintf('%d/%d', done, total);
            app.refreshFPSLabel(cameraIndex, false);
            app.AcquisitionStatusLabel.Text = sprintf( ...
                ['Saving Record Cycle %d — Camera %d: %d/%d frames ', ...
                 '(TIFF stack %d/%d).'], cycleIndex, cameraIndex, done, ...
                total, stack, stackTotal);
            drawnow limitrate;
        end

        function counts = recordFrameCounts(app, indices, durationSeconds)
            counts = zeros(1, numel(indices));
            for position = 1:numel(indices)
                cameraIndex = indices(position);
                if app.SimulationMode
                    fps = app.SimulationRecordFPS;
                    source = 'simulation_fixed_10_fps';
                else
                    fps = app.StreamFPS(cameraIndex);
                    if isfinite(fps) && fps > 0
                        source = 'measured_preview_frames_acquired_counter';
                    else
                        fps = app.expectedStreamFPS(cameraIndex);
                        if isfinite(fps) && fps > 0
                            source = 'validated_fast_512x512_configuration';
                        else
                            [fps, source] = ...
                                app.Cameras.getCameraReportedFPS(cameraIndex);
                        end
                    end
                    if ~isfinite(fps)
                        fps = min(400, 1 / app.Cameras.ExposureTimes(cameraIndex));
                        source = 'fallback_min_400_or_exposure_limit';
                    end
                end
                counts(position) = max(1, round(durationSeconds * fps));
                app.Logger.log('INFO', 'RECORD_FRAME_TARGET_CALCULATED', ...
                    ['Camera=%d | DurationSeconds=%.9g | TargetFPS=%.9g | ', ...
                     'FrameCount=%d | FPSProperty=%s'], cameraIndex, ...
                    durationSeconds, fps, counts(position), source);
            end
        end

        function estimate = preflightAcquisitionStorage(app, plan, ...
                frameCounts, sources)
            rois = cell(1, numel(plan.cameras));
            for position = 1:numel(plan.cameras)
                rois{position} = app.Cameras.ROIs{plan.cameras(position)};
            end
            estimate = app.buildStorageEstimate(plan.mode, plan.cameras, ...
                rois, frameCounts, sources, plan.cycles, ...
                plan.convert_record_to_tiff, ...
                string(app.RootPathField.Value), true);
            app.Logger.log('INFO', 'ACQUISITION_STORAGE_PREFLIGHT', ...
                ['Mode=%s | Cameras=%s | Cycles=%d | BytesPerFrame=%s | ', ...
                 'FramesPerCameraPerCycle=%s | FrameCountSources=%s | ', ...
                 'RawBytesPerCycle=%.0f | FinalDataBytes=%.0f | ', ...
                 'LargestConversionUnitBytes=%.0f | ', ...
                 'ConversionWorkers=%d | EstimatedConversionMemoryBytes=%.0f | ', ...
                 'ConcurrentTiffBytes=%.0f | PeakBeforeMarginBytes=%.0f | ', ...
                 'SafetyMargin=1.1 | RequiredPeakBytes=%.0f | FreeDiskBytes=%s | ', ...
                 'ConvertToTiff=%d | SaveRoot=%s | DiskProbePath=%s'], ...
                estimate.mode, mat2str(estimate.cameras), estimate.cycles, ...
                mat2str(estimate.bytes_per_frame), ...
                mat2str(estimate.frames_per_camera_per_cycle), ...
                strjoin(string(estimate.frame_count_sources), ','), ...
                estimate.raw_bytes_per_cycle, estimate.final_data_bytes, ...
                estimate.largest_conversion_unit_bytes, ...
                estimate.conversion_worker_count, ...
                estimate.estimated_conversion_memory_bytes, ...
                estimate.transient_conversion_bytes, ...
                estimate.peak_before_margin_bytes, ...
                estimate.required_peak_bytes, ...
                app.diagnosticValueText(estimate.free_disk_bytes), ...
                estimate.convert_record_to_tiff, estimate.save_root, ...
                estimate.disk_probe_path);
            if ~isfinite(estimate.free_disk_bytes)
                error('ZouLab:DiskSpaceMeasurementUnavailable', ...
                    ['MATLAB could not measure usable space for Save root %s. ', ...
                     'Choose an accessible local or network folder.'], ...
                    estimate.save_root);
            end
            if estimate.free_disk_bytes < estimate.required_peak_bytes
                error('ZouLab:InsufficientAcquisitionDisk', ...
                    ['The complete %s acquisition needs an estimated peak of ', ...
                     '%s (including the 10%% margin), but only %s is available ', ...
                     'at %s. Reduce duration, cycles, points, ROI, or camera count, ', ...
                     'or choose another Save root.'], ...
                    estimate.mode, ...
                    app.formatStorageBytes(estimate.required_peak_bytes), ...
                    app.formatStorageBytes(estimate.free_disk_bytes), ...
                    estimate.save_root);
            end
            app.Logger.log('SUCCESS', ...
                'ACQUISITION_STORAGE_PREFLIGHT_PASSED', ...
                'RequiredPeakBytes=%.0f | FreeDiskBytes=%.0f | EnoughSpace=1', ...
                estimate.required_peak_bytes, estimate.free_disk_bytes);
        end

        function bufferPolicy = preflightRecordStorage(app, indices, frameCounts, ...
                convertToTiff, recordWindowSeconds, storageEstimate)
            bytes = 0;
            queuePayloadBytes = 0;
            minimumIatBytes = 0;
            for position = 1:numel(indices)
                roi = app.Cameras.ROIs{indices(position)};
                bytesPerFrame = prod(roi(3:4)) * 2;
                bytes = bytes + bytesPerFrame * frameCounts(position);
                queuePayloadBytes = queuePayloadBytes + bytesPerFrame * ...
                    zoulab.BufferedBinRecorder.BlockFrames * ...
                    zoulab.BufferedBinRecorder.MaxInFlightBlocksPerCamera;
                minimumIatBytes = minimumIatBytes + bytesPerFrame * ...
                    zoulab.BufferedBinRecorder.BlockFrames;
            end
            availableMemory = Inf;
            if ~app.SimulationMode
                try
                    [~, systemView] = memory;
                    availableMemory = double(systemView.PhysicalMemory.Available);
                catch ME
                    app.Logger.logException( ...
                        'RECORD_AVAILABLE_MEMORY_QUERY_FAILED', ME);
                    error('ZouLab:RecordMemoryMeasurementUnavailable', ...
                        ['MATLAB could not measure available physical memory, ', ...
                         'so a safe dynamic IAT capacity cannot be configured.']);
                end
            end
            bufferPolicy = ...
                zoulab.BufferedBinRecorder.computeIatBufferPolicy( ...
                availableMemory, queuePayloadBytes);
            requiredMemory = queuePayloadBytes + minimumIatBytes;
            app.Logger.log('INFO', 'RECORD_STORAGE_PREFLIGHT', ...
                ['RawBytes=%g | QueuePayloadBytes=%g | MinimumIatBytes=%g | ', ...
                 'MinimumRequiredMemoryBytes=%g | AvailableMemoryBytes=%s | ', ...
                 'IatCapacityBytes=%s | IatStopBytes=%s | ', ...
                 'IatStopFraction=%.3f | IatCapacityPolicy=', ...
                 'available_memory_minus_full_writer_queue | ', ...
                 'PostCaptureTiffWorkers=%d | ', ...
                 'EstimatedTiffProcessMemoryBytes=%g | ', ...
                 'RequiredPeakDiskBytes=%g | FreeDiskBytes=%g | ', ...
                 'ConvertToTiff=%d | Cycles=%d | ', ...
                 'DiskMarginMultiplier=1.1 | RecordWindowSeconds=%.9g | Root=%s'], ...
                bytes, queuePayloadBytes, minimumIatBytes, requiredMemory, ...
                app.diagnosticValueText(availableMemory), ...
                app.diagnosticValueText(bufferPolicy.iat_capacity_bytes), ...
                app.diagnosticValueText(bufferPolicy.iat_stop_bytes), ...
                bufferPolicy.iat_stop_fraction, ...
                storageEstimate.conversion_worker_count, ...
                storageEstimate.estimated_conversion_memory_bytes, ...
                storageEstimate.required_peak_bytes, ...
                storageEstimate.free_disk_bytes, convertToTiff, ...
                storageEstimate.cycles, recordWindowSeconds, ...
                storageEstimate.save_root);
            if ~app.SimulationMode && isfinite(availableMemory) && ...
                    bufferPolicy.iat_capacity_bytes < minimumIatBytes
                error('ZouLab:InsufficientRecordMemory', ...
                    ['The full writer queue plus one 64-frame IAT block per ', ...
                     'camera requires at least %.2f GB, but %.2f GB is available. ', ...
                     'Reduce ROI/camera count or close other applications.'], ...
                    requiredMemory / 1024^3, availableMemory / 1024^3);
            end
        end

        function completed = waitInterruptible(app, durationSeconds, message)
            completed = true;
            if durationSeconds <= 0
                return;
            end
            waitClock = tic;
            while toc(waitClock) < durationSeconds
                if app.RunState.AcquisitionStopRequested
                    completed = false;
                    return;
                end
                remaining = durationSeconds - toc(waitClock);
                app.AcquisitionStatusLabel.Text = sprintf( ...
                    'Working: %s (%.1f s remaining)', message, max(0, remaining));
                pause(min(0.05, max(0.001, remaining)));
                drawnow limitrate;
            end
        end

        function completed = waitForNextCycle(app, durationSeconds, ...
                cycleIndex, totalCycles)
            completed = true;
            dialog = [];
            if durationSeconds <= 0
                return;
            end
            try
                if isvalid(app.UIFigure) && ...
                        strcmpi(app.UIFigure.Visible, 'on')
                    dialog = uiprogressdlg(app.UIFigure, ...
                        'Title', sprintf('Record Cycle %d/%d completed', ...
                        cycleIndex - 1, totalCycles), ...
                        'Message', sprintf( ...
                        'Next: Record Cycle %d/%d starts in %.1f s', ...
                        cycleIndex, totalCycles, durationSeconds), ...
                        'Indeterminate', 'off', 'Cancelable', 'on', ...
                        'Value', 0);
                end
            catch ME
                app.Logger.logException( ...
                    'CYCLE_COUNTDOWN_DIALOG_CREATE_FAILED', ME);
                dialog = [];
            end
            dialogCleanup = onCleanup(@() ...
                app.closeRecordConversionProgressDialog(dialog));
            app.setAcquisitionState('WAITING', sprintf( ...
                'Waiting between Record cycles — Cycle %d/%d starts in %.1f s.', ...
                cycleIndex, totalCycles, durationSeconds));
            app.Logger.log('INFO', 'CYCLE_COUNTDOWN_STARTED', ...
                ['NextCycle=%d/%d | DurationSeconds=%.6g | ', ...
                 'IntervalSemantics=start_to_start'], ...
                cycleIndex, totalCycles, durationSeconds);
            waitClock = tic;
            lastDisplayedSecond = Inf;
            while toc(waitClock) < durationSeconds
                if app.RunState.AcquisitionStopRequested
                    completed = false;
                    break;
                end
                if ~isempty(dialog)
                    try
                        if dialog.CancelRequested
                            app.RunState.requestCaptureStop();
                            completed = false;
                            app.Logger.log('INFO', ...
                                'USER_CYCLE_COUNTDOWN_CANCEL_REQUESTED', ...
                                'NextCycle=%d/%d', cycleIndex, totalCycles);
                            break;
                        end
                    catch
                    end
                end
                elapsed = toc(waitClock);
                remaining = max(0, durationSeconds - elapsed);
                shownSecond = ceil(remaining * 10) / 10;
                if shownSecond ~= lastDisplayedSecond
                    message = sprintf( ...
                        ['Waiting between Record cycles — Cycle %d/%d ', ...
                         'starts in %.1f s.'], ...
                        cycleIndex, totalCycles, shownSecond);
                    app.AcquisitionStatusLabel.Text = message;
                    app.setConversionDetail({ ...
                        'Record workflow: INTER-CYCLE WAIT', message});
                    if ~isempty(dialog)
                        try
                            dialog.Value = min(1, elapsed / durationSeconds);
                            dialog.Message = sprintf( ...
                                'Next: Record Cycle %d/%d starts in %.1f s', ...
                                cycleIndex, totalCycles, shownSecond);
                        catch
                        end
                    end
                    lastDisplayedSecond = shownSecond;
                end
                pause(min(0.05, max(0.001, remaining)));
                drawnow limitrate;
            end
            clear dialogCleanup
            if completed
                app.Logger.log('SUCCESS', 'CYCLE_COUNTDOWN_COMPLETE', ...
                    'NextCycle=%d/%d | DurationSeconds=%.6g', ...
                    cycleIndex, totalCycles, durationSeconds);
            end
        end

        function logs = buildLegacyVisualLogs(app, visualLogs, rawSync, ...
                syncTable, indices)
            legacySync = table();
            rowCount = height(syncTable);
            if rowCount > 0 && ismember('StimulusFrame', ...
                    syncTable.Properties.VariableNames)
                legacySync.stimvideo_frame = double(syncTable.StimulusFrame);
                legacySync.PTB_VBL_Time = double(syncTable.PTBVBLTime);
                legacySync.DAQ_Timestamp = ...
                    double(syncTable.DAQTimestampSeconds);
            else
                legacySync.stimvideo_frame = zeros(0, 1);
                legacySync.PTB_VBL_Time = zeros(0, 1);
                legacySync.DAQ_Timestamp = zeros(0, 1);
            end
            for cameraIndex = indices
                sourceName = sprintf('Camera%dFrame', cameraIndex);
                targetName = sprintf('Camera%d_Frame', cameraIndex);
                if rowCount > 0 && ismember(sourceName, ...
                        syncTable.Properties.VariableNames)
                    legacySync.(targetName) = double(syncTable.(sourceName));
                else
                    legacySync.(targetName) = zeros(0, 1);
                end
            end
            logs = struct( ...
                'vbl', double(visualLogs.vbl(:).'), ...
                'stimulus', visualLogs.stimulus, ...
                'daq', rawSync, 'sync', legacySync, ...
                'zoulabview', struct( ...
                    'source_file', 'visual_sync.mat', ...
                    'camera_indices', indices, ...
                    'operator_id', char(app.Logger.OperatorID), ...
                    'operator_name', char(app.Logger.OperatorName)));
            app.Logger.log('SUCCESS', 'REBUILT_VISUAL_LOGS_CREATED', ...
                ['SyncRows=%d | Cameras=%s | AngleSequence=%s | ', ...
                 'AAACompatibleVariables=1'], height(legacySync), ...
                mat2str(indices), mat2str(app.visualAngleSequence(visualLogs)));
        end

        function angles = visualAngleSequence(~, visualLogs)
            angles = zeros(1, 0);
            if isstruct(visualLogs) && isfield(visualLogs, 'stimulus') && ...
                    isstruct(visualLogs.stimulus) && ...
                    isfield(visualLogs.stimulus, 'angleSequence')
                angles = double(visualLogs.stimulus.angleSequence(:).');
            end
        end

        function writeCycleManifest(app, cyclePath, plan, cycleIndex, ...
                status, files, errorMessage)
            manifest = struct( ...
                'schema_version', '3.0.0', ...
                'level', 'cycle', ...
                'cycle', cycleIndex, ...
                'status', char(string(status)), ...
                'completed_at', char(datetime('now', ...
                    'Format', 'yyyy-MM-dd HH:mm:ss.SSS')), ...
                'plan', plan, ...
                'files', {cellstr(files)}, ...
                'error', char(string(errorMessage)));
            zoulab.SessionManager.writeJson(fullfile(cyclePath, ...
                'cycle_manifest.json'), manifest);
            recordMode = plan.mode;
            if plan.visual_stimulus_armed
                recordMode = 'visualstim';
            end
            if strcmp(plan.mode, 'record')
                captureSaveType = 'bin';
                if plan.convert_record_to_tiff
                    saveType = 'tiff';
                else
                    saveType = 'bin';
                end
            else
                captureSaveType = 'tiff';
                saveType = 'tiff';
            end
            compatible = struct( ...
                'schema_version', '1.0.0', 'level', 'cycle', ...
                'ids', struct('method_id', app.Sessions.MethodID, ...
                    'record_id', app.Sessions.RecordID, ...
                    'cycle_id', cycleIndex), ...
                'paths', struct('method_path', char(app.Sessions.MethodPath), ...
                    'record_path', char(app.Sessions.RecordPath), ...
                    'cycle_path', char(string(cyclePath))), ...
                'refs', struct( ...
                    'method_manifest', char(fullfile(app.Sessions.MethodPath, ...
                        'method_manifest.mat')), ...
                    'record_manifest', char(fullfile(app.Sessions.RecordPath, ...
                        'record_manifest.mat'))), ...
                'spec', struct('recordmode', recordMode, ...
                    'savetype', saveType, ...
                    'capture_savetype', captureSaveType, ...
                    'labels', {cellstr(app.Sessions.CameraLabels)}), ...
                'actual', struct('movie_paths', {cellstr(files)}, ...
                    'has_logs', isfile(fullfile(cyclePath, 'logs.mat'))), ...
                'artifacts', struct( ...
                    'cycle_manifest_mat', char(fullfile(cyclePath, ...
                        'cycle_manifest.mat')), ...
                    'cycle_manifest_json', char(fullfile(cyclePath, ...
                        'cycle_manifest.json')), ...
                    'logs_mat', char(fullfile(cyclePath, 'logs.mat'))), ...
                'notes', struct('zoulabview_status', char(string(status)), ...
                    'error', char(string(errorMessage))), ...
                'status', struct('state', char(string(status))), ...
                'timestamps', struct('created_at', char(datetime('now', ...
                    'Format', 'yyyy-MM-dd HH:mm:ss'))));
            zoulab.SessionManager.writeMatManifest(fullfile(cyclePath, ...
                'cycle_manifest.mat'), compatible);
        end

        function setAcquisitionState(app, state, message)
            app.RunState.setStatus(state);
            app.AcquisitionStateLabel.Text = char(app.RunState.Status);
            switch app.RunState.Status
                case {"RUNNING","COMPLETED"}
                    app.AcquisitionLamp.Color = [0.10 0.75 0.20];
                case {"WAITING","STOPPING","FLUSHING","CONVERTING", ...
                        "COMPLETED_WITH_WARNINGS"}
                    app.AcquisitionLamp.Color = [0.95 0.65 0.10];
                case "ERROR"
                    app.AcquisitionLamp.Color = [0.85 0.15 0.12];
                otherwise
                    app.AcquisitionLamp.Color = [0.65 0.65 0.65];
            end
            app.AcquisitionStatusLabel.Text = char(string(message));
            app.Logger.log('INFO', 'ACQUISITION_STATE_CHANGED', ...
                'State=%s | Cycle=%d | Message=%s', app.RunState.Status, ...
                app.RunState.AcquisitionCycleIndex, string(message));
            drawnow limitrate;
        end

        function updateAcquisitionControlAvailability(app, locked)
            context = struct( ...
                'identityReady', app.IdentityConfirmed, ...
                'locked', locked, ...
                'mode', string(app.AcquisitionModeDropDown.Value), ...
                'recordLengthSource', string(app.RecordLengthSourceDropDown.Value), ...
                'visualArmed', app.VisualStimulusController.Armed, ...
                'lightArmed', app.LightStimulusController.Armed, ...
                'ledArmed', app.LedFlickerController.Armed, ...
                'visualPreviewRunning', app.VisualPreviewRunning, ...
                'conversionRunning', app.RunState.ConversionRunning, ...
                'visualScreenReady', app.VisualStimulusController.ScreenReady && ...
                    app.VisualStimulusController.ScreenIndex == app.VisualScreenField.Value);
            enabled = zoulab.AcquisitionState.controlAvailability(context);
            names = fieldnames(enabled);
            for index = 1:numel(names)
                control = app.(names{index});
                if ~isempty(control) && isvalid(control)
                    control.Enable = app.onOff(enabled.(names{index}));
                end
            end
        end

        function setAcquisitionControlsLocked(app, locked)
            editable = app.onOff(~locked && app.IdentityConfirmed);
            operatorEditable = app.onOff(~locked);
            app.AcquisitionStartButton.Enable = editable;
            app.AcquisitionStopButton.Enable = app.onOff( ...
                locked && app.IdentityConfirmed);
            app.CycleCountField.Enable = editable;
            app.CycleIntervalField.Enable = editable;
            app.DmdTotalTriggerField.Editable = editable;
            app.DmdRepeatToFillTimelineCheckBox.Enable = editable;
            app.updateAcquisitionControlAvailability(locked);
            app.CameraModeDropDown.Enable = editable;
            app.RootPathField.Editable = editable;
            app.MethodNoteField.Editable = editable;
            app.Camera1LabelField.Editable = editable;
            app.Camera2LabelField.Editable = editable;
            app.OpenUserButton.Enable = operatorEditable;
            app.OperatorUserDropDown.Enable = operatorEditable;
            app.OperatorNameField.Enable = operatorEditable;
            for cameraIndex = 1:2
                app.ExposurePresetDropDowns{cameraIndex}.Enable = editable;
                app.ExposureFields{cameraIndex}.Editable = editable;
                app.ROIPresetDropDowns{cameraIndex}.Enable = editable;
                app.ROIFields{cameraIndex}.Editable = editable;
                app.BinDropDowns{cameraIndex}.Enable = editable;
                if locked
                    app.CameraApplyButtons{cameraIndex}.Enable = 'off';
                    app.CameraPreviewStartButtons{cameraIndex}.Enable = 'off';
                    app.CameraPreviewStopButtons{cameraIndex}.Enable = 'off';
                    app.CameraSnapButtons{cameraIndex}.Enable = 'off';
                else
                    app.CameraApplyButtons{cameraIndex}.Enable = 'on';
                    app.CameraSnapButtons{cameraIndex}.Enable = 'on';
                end
            end
            if ~locked
                app.updatePreviewButtons();
            end
            app.VisualProgramDropDown.Enable = editable;
            app.VisualScreenField.Editable = editable;
            app.VisualDurationField.Editable = editable;
            app.VisualFrequencyField.Editable = editable;
            app.VisualISIField.Editable = editable;
            app.VisualRepeatsField.Editable = editable;
            app.VisualSequenceField.Editable = editable;
            app.VisualAmplitudeField.Editable = editable;
            app.VisualSpatialFrequencyField.Editable = editable;
            app.VisualViewingDistanceField.Editable = editable;
            app.VisualScreenWidthField.Editable = editable;
            app.VisualIdleColorField.Editable = editable;
            app.VisualBaselineColorField.Editable = editable;
            app.VisualWhiteColorField.Editable = editable;
            app.VisualBlackColorField.Editable = editable;
            app.VisualBlueColorField.Editable = editable;
            app.VisualInitialPhaseField.Editable = editable;
            app.VisualFlipDeadlineField.Editable = editable;
            app.CameraPreStimField.Editable = editable;
            app.CameraPostStimField.Editable = editable;
            app.LightLeadField.Editable = editable;
            app.LightTailField.Editable = editable;
            app.VisualPreviewModeDropDown.Enable = editable;
            app.VisualPreviewAngleField.Editable = editable;
            app.LedFlickerDelayField.Editable = editable;
            app.LedFlickerOnField.Editable = editable;
            app.LedFlickerOffField.Editable = editable;
            app.LedFlickerCyclesField.Editable = editable;
            app.LedFlickerFrequencyField.Editable = editable;
            app.LedFlickerDoTable.Enable = editable;
            app.LedFlickerAoTable.Enable = editable;
            modules = ["visual_ptb","visual_led", ...
                "light_stim_laser","dmd"];
            for moduleName = modules
                methodControls = app.moduleMethodControls(moduleName);
                methodControls.dropdown.Enable = editable;
                methodControls.name.Editable = editable;
                buttonTags = [app.moduleMethodTag(moduleName, 'LoadButton'), ...
                    app.moduleMethodTag(moduleName, 'SaveButton')];
                for buttonTag = buttonTags
                    methodButton = findall(app.UIFigure, ...
                        'Tag', char(buttonTag));
                    if ~isempty(methodButton)
                        methodButton.Enable = editable;
                    end
                end
            end
            app.VisualPlayButton.Enable = app.onOff(~locked && ...
                ~app.VisualStimulusController.Armed && ...
                app.VisualStimulusController.ScreenReady && ...
                app.VisualStimulusController.ScreenIndex == ...
                app.VisualScreenField.Value);
            app.VisualStopPlaybackButton.Enable = app.onOff( ...
                app.VisualPreviewRunning);
            app.VisualArmButton.Enable = app.onOff(~locked && ...
                ~app.VisualStimulusController.Armed && ...
                ~app.LightStimulusController.Armed && ...
                app.VisualStimulusController.ScreenReady && ...
                app.VisualStimulusController.ScreenIndex == ...
                app.VisualScreenField.Value);
            app.VisualDisarmButton.Enable = app.onOff(~locked && ...
                app.VisualStimulusController.Armed);
            app.LightStimSourceDropDown.Enable = editable;
            app.LightStimWaveformDropDown.Enable = editable;
            app.LightStimDelayField.Editable = editable;
            app.LightStimDurationField.Editable = 'off';
            app.LightStimPulseWidthField.Editable = editable;
            app.LightStimPulsePeriodField.Editable = editable;
            app.LightStimDigitalRepeatField.Editable = editable;
            app.LightStimDigitalPointTable.Enable = editable;
            app.LightStimAnalogTargetDropDown.Enable = editable;
            app.LightStimAnalogTimingModeDropDown.Enable = editable;
            app.LightStimAnalogWaveformDropDown.Enable = editable;
            app.LightStimAnalogDelayField.Editable = editable;
            app.LightStimAnalogDurationField.Editable = editable;
            app.LightStimAnalogHighVoltageField.Editable = editable;
            app.LightStimAnalogLowVoltageField.Editable = editable;
            app.LightStimAnalogOffVoltageField.Editable = editable;
            app.LightStimAnalogPulseWidthField.Editable = editable;
            app.LightStimAnalogCalculatedDurationField.Editable = 'off';
            app.LightStimAnalogRepeatField.Editable = editable;
            app.LightStimAnalogPointTable.Enable = editable;
            app.LightStimAnalogGenerateButton.Enable = editable;
            app.LightStimDmdSwitch.Enable = editable;
            app.LightStimDmdPatternDropDown.Enable = editable;
            app.LightStimDmdLoopSwitch.Enable = editable;
            app.LightStimDmdRateField.Editable = editable;
            app.LightStimDmdPulseField.Editable = editable;
            app.LightStimTimelinePreviewButton.Enable = app.onOff( ...
                ~locked && app.IdentityConfirmed);
            app.DmdPatternFolderField.Editable = editable;
            app.DmdStartPositionField.Editable = editable;
            app.DmdPictureCountField.Editable = 'off';
            app.DmdTriggerTable.Enable = editable;
            app.DmdTriggerRepeatField.Editable = editable;
            app.DmdCalibrationCameraDropDown.Enable = editable;
            app.DmdGridModeDropDown.Enable = editable;
            app.DmdCalibrationSourceDropDown.Enable = editable;
            app.DmdTriggerModeDropDown.Enable = editable;
            app.DmdCalibrationRootField.Editable = 'off';
            app.DmdCalibrationTiffField.Editable = 'off';
            app.DmdMaskModeDropDown.Enable = editable;
            thresholdMaskEditable = ~locked && app.IdentityConfirmed && ...
                string(app.DmdMaskModeDropDown.Value) == "Threshold";
            app.DmdMaskThresholdField.Enable = ...
                app.onOff(thresholdMaskEditable);
            app.DmdMaskMinAreaField.Enable = ...
                app.onOff(thresholdMaskEditable);
            app.DmdMaskExpansionField.Enable = ...
                app.onOff(thresholdMaskEditable);
            app.DmdMaskEachRoiCheckBox.Enable = editable;
            app.DmdInsertOffBetweenRoisCheckBox.Enable = app.onOff( ...
                ~locked && app.IdentityConfirmed && ...
                app.DmdMaskEachRoiCheckBox.Value);
            app.DmdMaskReverseCheckBox.Enable = editable;
            app.DmdBitDepthDropDown.Enable = editable;
            app.DmdTrailingOffPaddingCheckBox.Enable = editable;
            app.DmdTriggerDelayField.Editable = editable;
            app.DmdTriggerPeriodField.Editable = editable;
            app.WiringJsonArea.Editable = editable;
            lightButtonTags = {'LightStimDigitalAddPointButton', ...
                'LightStimDigitalInsertPointButton', ...
                'LightStimDigitalDeletePointButton', ...
                'LightStimDigitalClearPointButton', ...
                'LightStimDigitalResetPointButton', ...
                'LightStimAnalogAddPointButton', ...
                'LightStimAnalogInsertPointButton', ...
                'LightStimAnalogDeletePointButton', ...
                'LightStimAnalogClearPointButton', ...
                'LightStimAnalogResetPointButton', ...
                'AddDmdTriggerEdgeButton', ...
                'InsertDmdTriggerEdgeButton', ...
                'DeleteDmdTriggerEdgeButton', ...
                'ClearDmdTriggerTableButton', ...
                'GenerateDmdTriggerTableButton', ...
                'ConnectDmdButton','StopDmdButton','RecoverDmdPortButton', ...
                'DmdAdminRecoverButton', ...
                'PauseDmdButton','BrowseDmdPatternButton', ...
                'LoadDmdPatternButton','PreviewDmdPatternButton', ...
                'BrowseDmdCalibrationRootButton', ...
                'GenerateDmdCalibrationGridsButton', ...
                'ProjectDmdCalibrationGridButton', ...
                'StopDmdCalibrationGridButton', ...
                'SaveDmdCalibrationPreviewButton', ...
                'SnapSolveDmdCalibrationButton', ...
                'ChooseDmdCalibrationTiffButton', ...
                'SolveDmdCalibrationButton','LoadDmdCalibrationButton', ...
                'SnapDmdMaskSourceButton','LoadDmdMaskSourceButton', ...
                'GenerateDmdMaskButton', ...
                'ReloadWiringJsonButton', ...
                'SaveWiringJsonButton'};
            for tagIndex = 1:numel(lightButtonTags)
                controls = findall(app.UIFigure, 'Tag', lightButtonTags{tagIndex});
                if ~isempty(controls)
                    controls.Enable = editable;
                end
            end
            if ~locked
                app.updateLightStimulusFieldAvailability();
            end
            app.updateAcquisitionControlAvailability(locked);
            app.updateVisualScreenStatus();
            app.Logger.log('INFO', 'ACQUISITION_CONTROLS_LOCK_CHANGED', ...
                'Locked=%d | ImagingCriticalControlsEditable=%d', ...
                locked, ~locked && app.IdentityConfirmed);
            if ~app.IdentityConfirmed
                app.setIdentityGate(true, ...
                    'acquisition_controls_operator_unconfirmed');
            end
        end

        function takeSnap(app, cameraIndices)
            cameraIndices = unique(double(cameraIndices(:).'));
            app.beginAction('SNAP', sprintf('Capturing camera(s) %s...', ...
                mat2str(cameraIndices)), app.AcquisitionStatusLabel);
            try
                app.requireIdentity('Snap');
                if ~app.confirmAndApplyPendingCameraSettings( ...
                        cameraIndices, 'Snap', app.AcquisitionStatusLabel)
                    app.finishAction('SNAP', false, ...
                        'Snap cancelled; camera settings remain Pending.', ...
                        app.AcquisitionStatusLabel);
                    return;
                end
                [recordPath, baseMetadata] = app.ensureRecord();
                app.Logger.log('INFO', 'SNAP_SAVE_TARGET_RESOLVED', ...
                    'SaveRoot=%s | RecordPath=%s', ...
                    string(app.RootPathField.Value), recordPath);
                frames = app.captureCameras(cameraIndices, 'snap', true, ...
                    'unchanged');
                snapFolder = app.Sessions.newSnapFolder();
                files = app.saveFrameSet(frames, snapFolder, 'Snap', cameraIndices);
                metadata = baseMetadata;
                metadata.kind = 'snap';
                metadata.cameras = cameraIndices;
                metadata.captured_at = char(datetime('now', ...
                    'Format', 'yyyy-MM-dd HH:mm:ss.SSS'));
                metadata.files = cellstr(files);
                metadata.raw_uint16 = true;
                metadata.raw_transposed = false;
                metadata.display_transpose = app.TransposeDisplay;
                metadata.record_path = char(recordPath);
                zoulab.SessionManager.writeJson(fullfile(snapFolder, ...
                    'snap_manifest.json'), metadata);
                app.Logger.log('SUCCESS', 'SNAP_SAVE_SUCCESS', ...
                    'Cameras=%s | Folder=%s | Files=%s', mat2str(cameraIndices), ...
                    snapFolder, strjoin(files, ','));
                app.finishAction('SNAP', true, "Snap saved: " + string(snapFolder), ...
                    app.AcquisitionStatusLabel);
                for cameraIndex = cameraIndices
                    app.setCameraStatus(cameraIndex, 'Snap saved.', 'success');
                end
            catch ME
                if strcmp(ME.identifier, 'ZouLab:OperatorRequired')
                    app.identityBlocked(app.AcquisitionStatusLabel);
                else
                    app.handleError('SNAP_FAILED', ME, app.AcquisitionStatusLabel);
                end
            end
        end

        function startTimeLapse(app)
            indices = app.activeCameraIndices();
            app.beginAction('START_TIMELAPSE', sprintf( ...
                'Starting Time Lapse: cameras %s, %.4g s, %d points...', ...
                mat2str(indices), app.TLIntervalField.Value, app.TLPointsField.Value), ...
                app.AcquisitionStatusLabel);
            try
                app.requireIdentity('Time Lapse');
                if ~app.confirmAndApplyPendingCameraSettings( ...
                        indices, 'Time Lapse', app.AcquisitionStatusLabel)
                    app.finishAction('START_TIMELAPSE', false, ...
                        ['Time Lapse cancelled; camera settings remain ', ...
                         'Pending.'], app.AcquisitionStatusLabel);
                    return;
                end
                app.validateLightMapping(indices);
                if numel(indices) == 2 && ~app.SimulationMode
                    app.DaqController.assertReady();
                end
                app.ensureRecord();
                app.Logger.log('INFO', 'TIMELAPSE_SAVE_TARGET_RESOLVED', ...
                    'SaveRoot=%s | RecordPath=%s', ...
                    string(app.RootPathField.Value), app.Sessions.RecordPath);
                app.TimeLapseFolder = app.Sessions.newTimeLapseFolder();
                for cameraIndex = indices
                    app.Sessions.cameraFolder(app.TimeLapseFolder, cameraIndex);
                end
                app.TimeLapseIndex = 0;
                app.TimeLapseRecords = struct('index', {}, 'timestamp', {}, 'files', {});
                app.stopAndDeleteTimer('TimeLapseTimer');
                app.TimeLapseTimer = timer('ExecutionMode', 'fixedSpacing', ...
                    'Period', app.TLIntervalField.Value, 'StartDelay', 0, ...
                    'BusyMode', 'drop', 'TimerFcn', @(~,~) app.timeLapseTick(), ...
                    'ErrorFcn', @(~,event) app.timeLapseTimerError(event));
                start(app.TimeLapseTimer);
                app.TLStartButton.Enable = 'off';
                app.TLStopButton.Enable = 'on';
                app.Logger.log('SUCCESS', 'TIMELAPSE_STARTED', ...
                    ['Folder=%s | IntervalSemantics=fixedSpacing_after_completion | ', ...
                     'Interval=%.6g | Points=%d | Cameras=%s | DualDAQRequired=%d'], ...
                    app.TimeLapseFolder, app.TLIntervalField.Value, ...
                    app.TLPointsField.Value, mat2str(indices), numel(indices) == 2);
                app.finishAction('START_TIMELAPSE', true, ...
                    sprintf('Time Lapse running: 0/%d', app.TLPointsField.Value), ...
                    app.AcquisitionStatusLabel);
            catch ME
                if strcmp(ME.identifier, 'ZouLab:OperatorRequired')
                    app.identityBlocked(app.AcquisitionStatusLabel);
                else
                    app.handleError('TIMELAPSE_START_FAILED', ME, app.AcquisitionStatusLabel);
                end
            end
        end

        function timeLapseTick(app)
            if app.RunState.Closing
                return;
            end
            try
                app.TimeLapseIndex = app.TimeLapseIndex + 1;
                point = app.TimeLapseIndex;
                indices = app.activeCameraIndices();
                app.AcquisitionStatusLabel.Text = sprintf( ...
                    'Working: acquiring point %d/%d...', point, app.TLPointsField.Value);
                app.Logger.log('INFO', 'TIMELAPSE_POINT_REQUESTED', ...
                    'Point=%d/%d | Cameras=%s', point, app.TLPointsField.Value, ...
                    mat2str(indices));
                frames = app.captureCameras(indices, sprintf('time_lapse_%d', point), true);
                files = app.saveFrameSet(frames, app.TimeLapseFolder, ...
                    sprintf('F%06d', point), indices);
                app.TimeLapseRecords(end+1) = struct( ...
                    'index', point, ...
                    'timestamp', char(datetime('now', 'Format', ...
                        'yyyy-MM-dd HH:mm:ss.SSS')), ...
                    'files', {cellstr(files)});
                app.Logger.log('SUCCESS', 'TIMELAPSE_POINT_SAVED', ...
                    'Point=%d/%d | Files=%s', point, ...
                    app.TLPointsField.Value, strjoin(files, ','));
                app.AcquisitionStatusLabel.Text = sprintf( ...
                    'Success: Time Lapse %d/%d saved.', point, app.TLPointsField.Value);
                if point >= app.TLPointsField.Value
                    app.stopTimeLapse('completed');
                end
            catch ME
                app.Logger.logException('TIMELAPSE_POINT_FAILED', ME);
                app.stopTimeLapse('error');
                app.showError(ME);
            end
        end

        function stopTimeLapse(app, reason)
            app.beginAction('STOP_TIMELAPSE', ...
                sprintf('Stopping Time Lapse (%s)...', reason), app.AcquisitionStatusLabel);
            app.stopAndDeleteTimer('TimeLapseTimer');
            app.TLStartButton.Enable = 'on';
            app.TLStopButton.Enable = 'off';
            if strlength(app.TimeLapseFolder) > 0 && exist(app.TimeLapseFolder, 'dir')
                manifest = struct( ...
                    'schema_version', '2.1.0', ...
                    'kind', 'time_lapse', ...
                    'status', char(string(reason)), ...
                    'operator_id', char(app.Logger.OperatorID), ...
                    'operator_name', char(app.Logger.OperatorName), ...
                    'identity_confirmation', 'manual_name_confirmation', ...
                    'camera_mode', app.CameraModeDropDown.Value, ...
                    'interval_seconds', app.TLIntervalField.Value, ...
                    'interval_semantics', 'fixed spacing after acquisition completion', ...
                    'requested_points', app.TLPointsField.Value, ...
                    'saved_points', app.TimeLapseIndex, ...
                    'raw_uint16', true, ...
                    'raw_transposed', false, ...
                    'display_transpose', app.TransposeDisplay, ...
                    'records', app.TimeLapseRecords);
                zoulab.SessionManager.writeJson(fullfile(app.TimeLapseFolder, ...
                    'timelapse_manifest.json'), manifest);
            end
            app.DaqController.safeOff();
            app.Logger.log('SUCCESS', 'TIMELAPSE_STOPPED', ...
                'Reason=%s | Folder=%s | PointsSaved=%d', ...
                reason, app.TimeLapseFolder, app.TimeLapseIndex);
            app.finishAction('STOP_TIMELAPSE', true, sprintf( ...
                'Time Lapse stopped (%s); %d point(s) saved.', ...
                reason, app.TimeLapseIndex), app.AcquisitionStatusLabel);
        end

        function timeLapseTimerError(app, event)
            try
                app.Logger.logException('TIMELAPSE_TIMER_ERROR', event.Data);
            catch
                app.Logger.log('ERROR', 'TIMELAPSE_TIMER_ERROR', ...
                    'Timer raised an unreported error.');
            end
            app.stopTimeLapse('timer_error');
        end

        function runRegistration(app, registrationMode)
            registrationMode = string(registrationMode);
            if registrationMode == "manual"
                if app.ManualRegistrationActive
                    app.cancelManualRegistration('manual_button');
                else
                    app.beginManualRegistration();
                end
                return;
            end
            artifactFolder = "";
            app.beginAction(upper(registrationMode) + "_REGISTRATION", ...
                sprintf('%s registration: opening imaging lights and acquiring both cameras...', ...
                upper(registrationMode)), app.RegistrationStatusLabel);
            previousPreview = app.PreviewActive;
            try
                if ~app.confirmAndApplyPendingCameraSettings( ...
                        [1 2], upper(registrationMode) + " Registration", ...
                        app.RegistrationStatusLabel)
                    app.finishAction(upper(registrationMode) + ...
                        "_REGISTRATION", false, ...
                        'Registration cancelled; camera settings remain Pending.', ...
                        app.RegistrationStatusLabel);
                    return;
                end
                app.validateRegistrationReady(registrationMode);
                app.validateLightMapping([1 2]);
                frames = app.captureCameras([1 2], registrationMode + "_registration", false);
                [recordPath, ~] = app.ensureRecord();
                app.Logger.log('INFO', 'REGISTRATION_SAVE_TARGET_RESOLVED', ...
                    'Mode=%s | SaveRoot=%s | RecordPath=%s', ...
                    registrationMode, string(app.RootPathField.Value), recordPath);
                artifactFolder = zoulab.RegistrationService.beginArtifacts( ...
                    recordPath, frames{1}, frames{2}, registrationMode, ...
                    app.registrationArtifactContext());
                app.Logger.log('SUCCESS', ...
                    'REGISTRATION_RAW_ARTIFACTS_SAVED', ...
                    'Mode=%s | Folder=%s | RawClass=uint16', ...
                    registrationMode, artifactFolder);
                baseROI = app.Cameras.ROIs{1};
                sensorLimit = 2304 / app.Cameras.Bins(1);
                result = zoulab.RegistrationService.register( ...
                    frames{1}, frames{2}, baseROI, sensorLimit, app.Logger);
                app.Cameras.applyROI(1, result.camera1_roi, app.Logger);
                app.ROIFields{1}.Value = mat2str(result.camera1_roi);
                app.RegistrationResult = result;
                zoulab.RegistrationService.finishArtifacts( ...
                    artifactFolder, frames{1}, frames{2}, result);
                app.Logger.log('SUCCESS', 'REGISTRATION_ARTIFACTS_SAVED', ...
                    'Mode=%s | Folder=%s | Camera1Transposed=1', ...
                    registrationMode, artifactFolder);
                app.restartPreviewMask(previousPreview, 'registration_complete');
                app.finishAction(upper(registrationMode) + "_REGISTRATION", true, ...
                    sprintf('%s registration complete; Cam1 ROI %s', ...
                    upper(registrationMode), mat2str(result.camera1_roi)), ...
                    app.RegistrationStatusLabel);
            catch ME
                if strlength(artifactFolder) > 0
                    try
                        zoulab.RegistrationService.markArtifactsCancelled( ...
                            artifactFolder, "failed: " + string(ME.identifier));
                    catch artifactError
                        app.Logger.logException( ...
                            'REGISTRATION_ARTIFACT_STATUS_UPDATE_FAILED', ...
                            artifactError);
                    end
                end
                app.DaqController.safeOff();
                app.restartPreviewMask(previousPreview, 'registration_failed');
                if strcmp(ME.identifier, 'ZouLab:OperatorRequired')
                    app.identityBlocked(app.RegistrationStatusLabel);
                else
                    app.handleError('REGISTRATION_FAILED', ME, app.RegistrationStatusLabel);
                end
            end
        end

        function loadRegistration(app)
            app.beginAction('LOAD_REGISTRATION', ...
                'Choose a previous camera registration file...', ...
                app.RegistrationStatusLabel);
            previousPreview = app.PreviewActive;
            try
                app.validateRegistrationReady('load');
                saveRoot = strtrim(string(app.RootPathField.Value));
                if strlength(saveRoot) == 0 || ~isfolder(saveRoot)
                    saveRoot = app.AppRoot;
                end
                [file, folder] = uigetfile( ...
                    {'*.mat;*.json','Registration MAT or JSON'}, ...
                    'Load previous registration', char(saveRoot));
                if isequal(file, 0)
                    app.finishAction('LOAD_REGISTRATION', false, ...
                        'Registration load cancelled.', ...
                        app.RegistrationStatusLabel);
                    return;
                end
                filePath = fullfile(folder, file);
                [~, ~, extension] = fileparts(filePath);
                if strcmpi(extension, '.json')
                    result = jsondecode(fileread(filePath));
                else
                    loaded = load(filePath);
                    if isfield(loaded, 'result')
                        result = loaded.result;
                    else
                        error('ZouLab:RegistrationFileInvalid', ...
                            'Registration MAT file does not contain result.');
                    end
                end
                if ~isfield(result, 'camera1_roi') || ...
                        numel(result.camera1_roi) ~= 4
                    error('ZouLab:RegistrationFileInvalid', ...
                        'Registration file has no valid Camera 1 ROI.');
                end
                roi = double(result.camera1_roi(:).');
                sensorLimit = 2304 / app.Cameras.Bins(1);
                if any(roi < 0) || roi(1) + roi(3) > sensorLimit || ...
                        roi(2) + roi(4) > sensorLimit
                    error('ZouLab:RegistrationROIOutOfBounds', ...
                        'Loaded Camera 1 ROI %s is invalid for Bin%d.', ...
                        mat2str(roi), app.Cameras.Bins(1));
                end
                for cameraIndex = find(previousPreview)
                    app.stopCameraPreview(cameraIndex, ...
                        'load_registration_prepare');
                end
                app.Cameras.applyROI(1, roi, app.Logger);
                app.ROIFields{1}.Value = mat2str(roi);
                app.RegistrationResult = result;
                app.restartPreviewMask(previousPreview, ...
                    'load_registration_complete');
                app.Logger.log('SUCCESS', 'REGISTRATION_LOADED', ...
                    'File=%s | Camera1ROI=%s | Mode=%s', ...
                    filePath, mat2str(roi), ...
                    string(app.registrationField(result, 'mode', 'unknown')));
                app.finishAction('LOAD_REGISTRATION', true, ...
                    sprintf('Loaded registration; Cam1 ROI %s', mat2str(roi)), ...
                    app.RegistrationStatusLabel);
            catch ME
                app.restartPreviewMask(previousPreview, ...
                    'load_registration_failed');
                app.handleError('REGISTRATION_LOAD_FAILED', ME, ...
                    app.RegistrationStatusLabel);
            end
        end

        function value = registrationField(~, source, name, fallback)
            if isfield(source, name)
                value = source.(name);
            else
                value = fallback;
            end
        end

        function context = registrationArtifactContext(app)
            cameraSettings = repmat(struct( ...
                'camera', 0, 'exposure_seconds', 0, ...
                'roi', zeros(1, 4), 'bin', 1), 1, 2);
            for cameraIndex = 1:2
                actual = app.Cameras.getActualSettings(cameraIndex);
                cameraSettings(cameraIndex) = struct( ...
                    'camera', cameraIndex, ...
                    'exposure_seconds', actual.ExposureTime, ...
                    'roi', actual.ROI, 'bin', actual.Bin);
            end
            context = struct( ...
                'operator_id', char(app.Logger.OperatorID), ...
                'operator_name', char(app.Logger.OperatorName), ...
                'save_root', char(string(app.RootPathField.Value)), ...
                'camera_settings', cameraSettings, ...
                'display_transpose', app.TransposeDisplay);
        end

        function validateRegistrationReady(app, registrationMode)
            app.requireIdentity(string(registrationMode) + " registration");
            if string(app.CameraModeDropDown.Value) ~= "Dual"
                error('ZouLab:RegistrationDualOnly', ...
                    'Registration is available only in dual-camera mode.');
            end
            if app.Cameras.Bins(1) ~= app.Cameras.Bins(2)
                error('ZouLab:RegistrationBinMismatch', ...
                    'Registration requires the same Bin on both cameras.');
            end
            if ~isequal(app.Cameras.ROIs{1}(3:4), app.Cameras.ROIs{2}(3:4))
                error('ZouLab:RegistrationSizeMismatch', ...
                    'Registration requires equal ROI width and height on both cameras.');
            end
        end

        function beginManualRegistration(app)
            app.beginAction('MANUAL_REGISTRATION', ...
                ['Manual registration: acquiring a fresh dual-camera frame; ', ...
                 'selection will be drawn on the two preview panels.'], ...
                app.RegistrationStatusLabel);
            try
                if ~app.confirmAndApplyPendingCameraSettings( ...
                        [1 2], 'Manual Registration', ...
                        app.RegistrationStatusLabel)
                    app.finishAction('MANUAL_REGISTRATION', false, ...
                        ['Manual registration cancelled; camera settings ', ...
                         'remain Pending.'], app.RegistrationStatusLabel);
                    return;
                end
                app.validateRegistrationReady('manual');
                app.validateLightMapping([1 2]);
                app.ManualRegistrationActive = true;
                app.ManualRegistrationPreviousPreview = app.PreviewActive;
                app.lockManualRegistrationControls();
                app.ManualRegistrationFrames = app.captureCameras( ...
                    [1 2], 'manual_registration', true);
                [recordPath, ~] = app.ensureRecord();
                app.Logger.log('INFO', 'REGISTRATION_SAVE_TARGET_RESOLVED', ...
                    'Mode=manual | SaveRoot=%s | RecordPath=%s', ...
                    string(app.RootPathField.Value), recordPath);
                app.ManualRegistrationArtifactFolder = string( ...
                    zoulab.RegistrationService.beginArtifacts( ...
                    recordPath, app.ManualRegistrationFrames{1}, ...
                    app.ManualRegistrationFrames{2}, 'manual', ...
                    app.registrationArtifactContext()));
                app.Logger.log('SUCCESS', ...
                    'REGISTRATION_RAW_ARTIFACTS_SAVED', ...
                    'Mode=manual | Folder=%s | RawClass=uint16', ...
                    app.ManualRegistrationArtifactFolder);
                app.ManualRegistrationVertices = {zeros(0, 2), zeros(0, 2)};
                app.ManualRegistrationStage = 1;
                for cameraIndex = 1:2
                    frame = app.ManualRegistrationFrames{cameraIndex};
                    app.LatestFrames{cameraIndex} = frame;
                    if app.TransposeDisplay(cameraIndex)
                        app.ImageHandles{cameraIndex}.CData = frame.';
                    else
                        app.ImageHandles{cameraIndex}.CData = frame;
                    end
                end
                app.installManualRegistrationInteraction();
                app.updateManualRegistrationInstructions();
                app.Logger.log('SUCCESS', ...
                    'MANUAL_REGISTRATION_IN_PREVIEW_READY', ...
                    ['Stage=1 | ActiveCamera=1 | DisplayFrozen=1 | ', ...
                     'CameraAcquisitionContinuesWherePreviouslyPreviewing=1 | ', ...
                     'AdvanceKey=space | CancelKey=escape | UndoKey=backspace | ', ...
                     'DisplayTranspose=%s'], ...
                    mat2str(app.TransposeDisplay));
            catch ME
                app.DaqController.safeOff();
                if strlength(app.ManualRegistrationArtifactFolder) > 0
                    try
                        zoulab.RegistrationService.markArtifactsCancelled( ...
                            app.ManualRegistrationArtifactFolder, ...
                            "start_failed: " + string(ME.identifier));
                    catch artifactError
                        app.Logger.logException( ...
                            'MANUAL_REGISTRATION_ARTIFACT_STATUS_UPDATE_FAILED', ...
                            artifactError);
                    end
                end
                app.cleanupManualRegistrationInteraction('start_failed');
                if strcmp(ME.identifier, 'ZouLab:OperatorRequired')
                    app.identityBlocked(app.RegistrationStatusLabel);
                else
                    app.handleError('MANUAL_REGISTRATION_START_FAILED', ME, ...
                        app.RegistrationStatusLabel);
                end
            end
        end

        function installManualRegistrationInteraction(app)
            app.ManualRegistrationPreviousFigureKeyPressFcn = ...
                app.UIFigure.WindowKeyPressFcn;
            app.ManualRegistrationPreviousPointer = string(app.UIFigure.Pointer);
            app.UIFigure.WindowKeyPressFcn = ...
                @(source,event) app.manualRegistrationKeyPressed(source, event);
            app.UIFigure.Pointer = 'crosshair';
            for cameraIndex = 1:2
                app.ManualRegistrationPreviousImageButtonDownFcn{cameraIndex} = ...
                    app.ImageHandles{cameraIndex}.ButtonDownFcn;
                app.ManualRegistrationPreviousAxesButtonDownFcn{cameraIndex} = ...
                    app.CameraAxes{cameraIndex}.ButtonDownFcn;
                app.ImageHandles{cameraIndex}.ButtonDownFcn = ...
                    @(~,event) app.manualRegistrationClicked(cameraIndex, event);
                app.CameraAxes{cameraIndex}.ButtonDownFcn = ...
                    @(~,event) app.manualRegistrationClicked(cameraIndex, event);
            end
            try
                focus(app.CameraAxes{1});
            catch
            end
        end

        function lockManualRegistrationControls(app)
            controls = [{app.CameraModeDropDown, app.AutoRegistrationButton, ...
                app.ManualRegistrationButton, app.LoadRegistrationButton, ...
                app.AcquisitionStartButton, ...
                app.PreviewStartButton, app.PreviewStopButton, app.SnapButton, ...
                app.TLStartButton, app.TLStopButton}, ...
                app.CameraApplyButtons, app.CameraPreviewStartButtons, ...
                app.CameraPreviewStopButtons, app.CameraSnapButtons, ...
                app.ExposurePresetDropDowns, app.ExposureFields, ...
                app.ROIPresetDropDowns, app.ROIFields, app.BinDropDowns, ...
                app.TransposeChecks];
            app.ManualRegistrationLockedControls = {};
            app.ManualRegistrationLockedEnableStates = {};
            for controlIndex = 1:numel(controls)
                control = controls{controlIndex};
                if isempty(control) || ~isvalid(control) || ~isprop(control, 'Enable')
                    continue;
                end
                app.ManualRegistrationLockedControls{end + 1} = control; %#ok<AGROW>
                app.ManualRegistrationLockedEnableStates{end + 1} = ...
                    control.Enable; %#ok<AGROW>
                control.Enable = 'off';
            end
            app.ManualRegistrationButton.Text = 'Manual active (Esc cancels)';
        end

        function manualRegistrationClicked(app, cameraIndex, event)
            if ~app.ManualRegistrationActive
                return;
            end
            app.Logger.log('INFO', 'USER_MANUAL_REGISTRATION_IMAGE_CLICK', ...
                'ClickedCamera=%d | RequiredCamera=%d', ...
                cameraIndex, app.ManualRegistrationStage);
            if cameraIndex ~= app.ManualRegistrationStage
                message = sprintf(['Camera %d is waiting. Click vertices on Camera %d, ', ...
                    'then press Space.'], cameraIndex, app.ManualRegistrationStage);
                app.RegistrationStatusLabel.Text = message;
                app.RegistrationStatusLabel.FontColor = [0.78 0.18 0.12];
                app.setStatus(message);
                app.Logger.log('WARNING', ...
                    'MANUAL_REGISTRATION_CLICK_WRONG_CAMERA', ...
                    'ClickedCamera=%d | RequiredCamera=%d', ...
                    cameraIndex, app.ManualRegistrationStage);
                return;
            end
            point = app.manualRegistrationEventPoint(cameraIndex, event);
            imageSize = size(app.ImageHandles{cameraIndex}.CData);
            if numel(imageSize) < 2 || any(~isfinite(point)) || ...
                    point(1) < 0.5 || point(1) > imageSize(2) + 0.5 || ...
                    point(2) < 0.5 || point(2) > imageSize(1) + 0.5
                app.Logger.log('WARNING', ...
                    'MANUAL_REGISTRATION_CLICK_OUTSIDE_IMAGE', ...
                    'Camera=%d | DisplayXY=%s | DisplaySize=%s', ...
                    cameraIndex, mat2str(point), mat2str(imageSize(1:2)));
                app.setStatus(sprintf( ...
                    'Camera %d: click inside the displayed image.', cameraIndex));
                return;
            end
            vertices = app.ManualRegistrationVertices{cameraIndex};
            vertices(end + 1, :) = point; %#ok<AGROW>
            app.ManualRegistrationVertices{cameraIndex} = vertices;
            app.updateManualRegistrationOverlay(cameraIndex);
            app.Logger.log('INFO', 'MANUAL_REGISTRATION_VERTEX_ADDED', ...
                ['Camera=%d | VertexIndex=%d | DisplayXY=%s | ', ...
                 'DisplayTranspose=%d'], cameraIndex, size(vertices, 1), ...
                mat2str(point, 6), app.TransposeDisplay(cameraIndex));
            app.updateManualRegistrationInstructions();
        end

        function point = manualRegistrationEventPoint(app, cameraIndex, event)
            point = [NaN NaN];
            try
                candidate = double(event.IntersectionPoint);
                if numel(candidate) >= 2
                    point = candidate(1, 1:2);
                    return;
                end
            catch
            end
            try
                candidate = double(app.CameraAxes{cameraIndex}.CurrentPoint);
                point = candidate(1, 1:2);
            catch
            end
        end

        function updateManualRegistrationOverlay(app, cameraIndex)
            oldOverlay = app.ManualRegistrationOverlays{cameraIndex};
            if ~isempty(oldOverlay) && isgraphics(oldOverlay)
                delete(oldOverlay);
            end
            vertices = app.ManualRegistrationVertices{cameraIndex};
            if isempty(vertices)
                app.ManualRegistrationOverlays{cameraIndex} = [];
                return;
            end
            plotVertices = vertices;
            if size(vertices, 1) >= 3
                plotVertices(end + 1, :) = vertices(1, :);
            end
            colors = {[0.95 0.35 0.10], [0.10 0.65 0.95]};
            overlay = line('Parent', app.CameraAxes{cameraIndex}, ...
                'XData', plotVertices(:, 1), 'YData', plotVertices(:, 2), ...
                'Color', colors{cameraIndex}, 'LineWidth', 2, ...
                'Marker', 'o', 'MarkerSize', 6, ...
                'MarkerFaceColor', colors{cameraIndex}, ...
                'HitTest', 'off', 'PickableParts', 'none', ...
                'Tag', sprintf('ManualRegistrationPolygon%d', cameraIndex));
            app.ManualRegistrationOverlays{cameraIndex} = overlay;
        end

        function manualRegistrationKeyPressed(app, ~, event)
            if ~app.ManualRegistrationActive
                return;
            end
            key = "";
            try
                key = lower(string(event.Key));
            catch
            end
            if ~any(key == ["space","escape","backspace"])
                return;
            end
            app.Logger.log('INFO', 'USER_MANUAL_REGISTRATION_KEY_PRESSED', ...
                'Key=%s | Stage=%d | Vertices=%d', key, ...
                app.ManualRegistrationStage, size( ...
                app.ManualRegistrationVertices{app.ManualRegistrationStage}, 1));
            switch key
                case "escape"
                    app.cancelManualRegistration('escape_key');
                case "backspace"
                    cameraIndex = app.ManualRegistrationStage;
                    vertices = app.ManualRegistrationVertices{cameraIndex};
                    if isempty(vertices)
                        app.setStatus(sprintf( ...
                            'Camera %d: no vertex to remove.', cameraIndex));
                        app.Logger.log('INFO', ...
                            'MANUAL_REGISTRATION_UNDO_IGNORED_EMPTY', ...
                            'Camera=%d', cameraIndex);
                        return;
                    end
                    removed = vertices(end, :);
                    vertices(end, :) = [];
                    app.ManualRegistrationVertices{cameraIndex} = vertices;
                    app.updateManualRegistrationOverlay(cameraIndex);
                    app.Logger.log('INFO', ...
                        'MANUAL_REGISTRATION_VERTEX_REMOVED', ...
                        'Camera=%d | DisplayXY=%s | RemainingVertices=%d', ...
                        cameraIndex, mat2str(removed, 6), size(vertices, 1));
                    app.updateManualRegistrationInstructions();
                case "space"
                    cameraIndex = app.ManualRegistrationStage;
                    vertices = app.ManualRegistrationVertices{cameraIndex};
                    if size(vertices, 1) < 3 || ...
                            abs(polyarea(vertices(:, 1), vertices(:, 2))) < eps
                        message = sprintf(['Camera %d needs at least three ', ...
                            'non-collinear vertices before Space.'], cameraIndex);
                        app.RegistrationStatusLabel.Text = message;
                        app.RegistrationStatusLabel.FontColor = [0.78 0.18 0.12];
                        app.setStatus(message);
                        app.Logger.log('WARNING', ...
                            'MANUAL_REGISTRATION_STAGE_NOT_CONFIRMED', ...
                            'Camera=%d | Vertices=%d | PolygonArea=%.6g', ...
                            cameraIndex, size(vertices, 1), ...
                            abs(polyarea(vertices(:, 1), vertices(:, 2))));
                        return;
                    end
                    app.Logger.log('SUCCESS', ...
                        'MANUAL_REGISTRATION_CAMERA_POLYGON_CONFIRMED', ...
                        'Camera=%d | Vertices=%d | PolygonArea=%.6g', ...
                        cameraIndex, size(vertices, 1), ...
                        abs(polyarea(vertices(:, 1), vertices(:, 2))));
                    if cameraIndex == 1
                        app.ManualRegistrationStage = 2;
                        try
                            focus(app.CameraAxes{2});
                        catch
                        end
                        app.updateManualRegistrationInstructions();
                    else
                        app.completeManualRegistration();
                    end
            end
        end

        function updateManualRegistrationInstructions(app)
            if ~app.ManualRegistrationActive || ...
                    ~any(app.ManualRegistrationStage == [1 2])
                return;
            end
            cameraIndex = app.ManualRegistrationStage;
            vertexCount = size( ...
                app.ManualRegistrationVertices{cameraIndex}, 1);
            fullMessage = sprintf(['Camera %d: click polygon vertices on this preview ', ...
                '(%d selected). Space = next/finish; Backspace = undo; Esc = cancel.'], ...
                cameraIndex, vertexCount);
            if cameraIndex == 1
                spaceAction = 'Cam2';
            else
                spaceAction = 'Finish';
            end
            app.RegistrationStatusLabel.Text = sprintf( ...
                'Cam%d: %d points | Space: %s | Backspace: undo | Esc: cancel', ...
                cameraIndex, vertexCount, spaceAction);
            app.RegistrationStatusLabel.FontColor = [0.80 0.48 0.05];
            app.setStatus(fullMessage);
            if cameraIndex == 1
                app.setCameraStatus(1, sprintf( ...
                    'Manual registration: select polygon (%d vertices).', ...
                    vertexCount), 'working');
                app.CameraStatusLabels{2}.Text = ...
                    'Manual registration: waiting for Camera 1 + Space.';
            else
                app.CameraStatusLabels{1}.Text = ...
                    'Manual registration: Camera 1 polygon confirmed.';
                app.setCameraStatus(2, sprintf( ...
                    'Manual registration: select matching polygon (%d vertices).', ...
                    vertexCount), 'working');
            end
            app.setStatus(fullMessage);
        end

        function completeManualRegistration(app)
            frames = app.ManualRegistrationFrames;
            vertices = app.ManualRegistrationVertices;
            displayTranspose = app.TransposeDisplay;
            camera1PreviewStopped = false;
            try
                baseROI = app.Cameras.ROIs{1};
                sensorLimit = 2304 / app.Cameras.Bins(1);
                result = zoulab.RegistrationService. ...
                    manualResultFromDisplayedPolygons( ...
                    vertices{1}, vertices{2}, baseROI, sensorLimit, ...
                    displayTranspose);
                app.Logger.log('SUCCESS', ...
                    'MANUAL_POLYGON_REGISTRATION_COMPUTED', ...
                    ['Camera1DisplayCentroidInput=%s | ', ...
                     'Camera2DisplayCentroidInput=%s | OffsetXY=%s | ', ...
                     'Camera1ROI=%s | DisplayTranspose=%s | ', ...
                     'IntensityWeighted=0'], ...
                    mat2str(vertices{1}), mat2str(vertices{2}), ...
                    mat2str(result.offset_xy), ...
                    mat2str(result.camera1_roi), ...
                    mat2str(displayTranspose));
                camera1PreviewStopped = app.PreviewActive(1);
                if camera1PreviewStopped
                    app.stopCameraPreview(1, ...
                        'manual_registration_apply_roi');
                end
                app.Cameras.applyROI(1, result.camera1_roi, app.Logger);
                app.ROIFields{1}.Value = mat2str(result.camera1_roi);
                app.SettingsDirty(1) = false;
                app.updateCameraModeLabel(1, 'actual');
                app.RegistrationResult = result;
                zoulab.RegistrationService.finishArtifacts( ...
                    app.ManualRegistrationArtifactFolder, ...
                    frames{1}, frames{2}, result);
                app.Logger.log('SUCCESS', 'REGISTRATION_ARTIFACTS_SAVED', ...
                    ['Mode=manual | Folder=%s | Camera1RegistrationTranspose=1 | ', ...
                     'PreviewDisplayTranspose=%s'], ...
                    app.ManualRegistrationArtifactFolder, ...
                    mat2str(displayTranspose));
                app.cleanupManualRegistrationInteraction('completed');
                if camera1PreviewStopped && ~app.PreviewActive(1)
                    try
                        app.startCameraPreview(1, ...
                            'manual_registration_complete');
                    catch previewError
                        app.Logger.logException( ...
                            'PREVIEW_RESTART_AFTER_MANUAL_REGISTRATION_FAILED', ...
                            previewError);
                        app.setCameraStatus(1, ...
                            'Registration applied; preview restart failed. Click Preview.', ...
                            'error');
                    end
                end
                app.setCameraStatus(1, sprintf( ...
                    'Manual registration applied. ROI %s.', ...
                    mat2str(result.camera1_roi)), 'success');
                app.setCameraStatus(2, ...
                    'Manual registration reference polygon accepted.', 'success');
                app.finishAction('MANUAL_REGISTRATION', true, ...
                    sprintf('Manual registration complete; Cam1 ROI %s', ...
                    mat2str(result.camera1_roi)), ...
                    app.RegistrationStatusLabel);
                app.updateAcquisitionStorageEstimate( ...
                    'manual_registration_complete', true);
            catch ME
                if strlength(app.ManualRegistrationArtifactFolder) > 0
                    try
                        zoulab.RegistrationService.markArtifactsCancelled( ...
                            app.ManualRegistrationArtifactFolder, ...
                            "completion_failed: " + string(ME.identifier));
                    catch artifactError
                        app.Logger.logException( ...
                            'MANUAL_REGISTRATION_ARTIFACT_STATUS_UPDATE_FAILED', ...
                            artifactError);
                    end
                end
                app.cleanupManualRegistrationInteraction('completion_failed');
                if camera1PreviewStopped && ~app.PreviewActive(1)
                    app.restartPreviewMask([true false], ...
                        'manual_registration_failed');
                end
                app.handleError('MANUAL_REGISTRATION_FAILED', ME, ...
                    app.RegistrationStatusLabel);
            end
        end

        function cancelManualRegistration(app, source)
            if ~app.ManualRegistrationActive
                return;
            end
            app.Logger.log('INFO', 'USER_MANUAL_REGISTRATION_CANCELLED', ...
                'Source=%s | Stage=%d | Camera1Vertices=%d | Camera2Vertices=%d', ...
                source, app.ManualRegistrationStage, ...
                size(app.ManualRegistrationVertices{1}, 1), ...
                size(app.ManualRegistrationVertices{2}, 1));
            try
                zoulab.RegistrationService.markArtifactsCancelled( ...
                    app.ManualRegistrationArtifactFolder, source);
                app.Logger.log('INFO', ...
                    'MANUAL_REGISTRATION_ARTIFACTS_MARKED_CANCELLED', ...
                    'Folder=%s | Reason=%s', ...
                    app.ManualRegistrationArtifactFolder, source);
            catch artifactError
                app.Logger.logException( ...
                    'MANUAL_REGISTRATION_ARTIFACT_STATUS_UPDATE_FAILED', ...
                    artifactError);
            end
            app.cleanupManualRegistrationInteraction("cancelled_" + string(source));
            message = 'Manual registration cancelled; Camera 1 ROI was not changed.';
            app.Logger.log('INFO', 'USER_ACTION_RESULT', ...
                'Action=MANUAL_REGISTRATION | Success=0 | Cancelled=1 | Message=%s', ...
                message);
            app.RegistrationStatusLabel.Text = message;
            app.RegistrationStatusLabel.FontColor = [0.25 0.25 0.25];
            app.setStatus(message);
            app.setCameraStatus(1, 'Manual registration cancelled; preview restored.', ...
                'working');
            app.setCameraStatus(2, 'Manual registration cancelled; preview restored.', ...
                'working');
        end

        function cleanupManualRegistrationInteraction(app, reason)
            if ~app.ManualRegistrationActive
                return;
            end
            for cameraIndex = 1:2
                overlay = app.ManualRegistrationOverlays{cameraIndex};
                if ~isempty(overlay) && isgraphics(overlay)
                    delete(overlay);
                end
                if ~isempty(app.ImageHandles{cameraIndex}) && ...
                        isvalid(app.ImageHandles{cameraIndex})
                    app.ImageHandles{cameraIndex}.ButtonDownFcn = ...
                        app.ManualRegistrationPreviousImageButtonDownFcn{cameraIndex};
                end
                if ~isempty(app.CameraAxes{cameraIndex}) && ...
                        isvalid(app.CameraAxes{cameraIndex})
                    app.CameraAxes{cameraIndex}.ButtonDownFcn = ...
                        app.ManualRegistrationPreviousAxesButtonDownFcn{cameraIndex};
                end
            end
            if ~isempty(app.UIFigure) && isvalid(app.UIFigure)
                app.UIFigure.WindowKeyPressFcn = ...
                    app.ManualRegistrationPreviousFigureKeyPressFcn;
                app.UIFigure.Pointer = char(app.ManualRegistrationPreviousPointer);
            end
            for controlIndex = 1:numel(app.ManualRegistrationLockedControls)
                control = app.ManualRegistrationLockedControls{controlIndex};
                if ~isempty(control) && isvalid(control)
                    control.Enable = ...
                        app.ManualRegistrationLockedEnableStates{controlIndex};
                end
            end
            if ~isempty(app.ManualRegistrationButton) && ...
                    isvalid(app.ManualRegistrationButton)
                app.ManualRegistrationButton.Text = 'Manual Register';
            end
            app.ManualRegistrationActive = false;
            app.ManualRegistrationStage = 0;
            app.ManualRegistrationVertices = {zeros(0, 2), zeros(0, 2)};
            app.ManualRegistrationFrames = {[], []};
            app.ManualRegistrationOverlays = {[], []};
            app.ManualRegistrationArtifactFolder = "";
            app.ManualRegistrationLockedControls = {};
            app.ManualRegistrationLockedEnableStates = {};
            if ~app.RunState.Closing
                for cameraIndex = 1:2
                    if ~isempty(app.LatestFrames{cameraIndex})
                        if app.TransposeDisplay(cameraIndex)
                            app.ImageHandles{cameraIndex}.CData = ...
                                app.LatestFrames{cameraIndex}.';
                        else
                            app.ImageHandles{cameraIndex}.CData = ...
                                app.LatestFrames{cameraIndex};
                        end
                    end
                end
            end
            app.Logger.log('INFO', 'MANUAL_REGISTRATION_INTERACTION_ENDED', ...
                'Reason=%s | DisplayFreezeReleased=1 | CallbacksRestored=1', ...
                reason);
        end

        function proceed = confirmAndApplyPendingCameraSettings( ...
                app, indices, actionName, statusLabel)
            proceed = true;
            indices = unique(double(indices(:).'));
            pending = indices(app.SettingsDirty(indices));
            if isempty(pending)
                return;
            end
            lines = strings(1, numel(pending));
            for itemIndex = 1:numel(pending)
                cameraIndex = pending(itemIndex);
                requestedExposureMs = app.ExposureFields{cameraIndex}.Value;
                requestedROI = zoulab.UserSettings.parseROI( ...
                    app.ROIFields{cameraIndex}.Value);
                requestedBin = app.BinDropDowns{cameraIndex}.Value;
                actual = app.Cameras.getActualSettings(cameraIndex);
                lines(itemIndex) = sprintf([ ...
                    'Camera %d: Exposure %.6g -> %.6g ms; ROI %s -> %s; ', ...
                    'Bin %d -> %d'], cameraIndex, actual.ExposureTime * 1000, ...
                    requestedExposureMs, mat2str(actual.ROI), ...
                    mat2str(requestedROI), actual.Bin, requestedBin);
            end
            saveRoot = strtrim(string(app.RootPathField.Value));
            message = sprintf([ ...
                '%s has unapplied camera settings.\n\n%s\n\nSave root: %s\n\n', ...
                'Apply these settings and continue?'], actionName, ...
                strjoin(lines, newline), saveRoot);
            app.Logger.log('INFO', ...
                'PENDING_CAMERA_SETTINGS_CONFIRMATION_SHOWN', ...
                'Action=%s | Cameras=%s | SaveRoot=%s | Detail=%s', ...
                actionName, mat2str(pending), saveRoot, strjoin(lines, ' || '));
            try
                if isempty(app.CameraSettingsConfirmationProvider)
                    choice = uiconfirm(app.UIFigure, message, ...
                        'Unapplied Camera Settings', ...
                        'Options', {'Apply & Continue','Cancel'}, ...
                        'DefaultOption', 1, 'CancelOption', 2, ...
                        'Icon', 'warning');
                else
                    choice = app.CameraSettingsConfirmationProvider(message);
                end
                choice = string(choice);
                if ~any(choice == ["Apply & Continue", "Cancel"])
                    error('ZouLab:CameraSettingsConfirmationInvalid', ...
                        'Pending-settings confirmation returned: %s.', choice);
                end
            catch ME
                proceed = false;
                app.handleError('PENDING_CAMERA_SETTINGS_CONFIRMATION_FAILED', ...
                    ME, statusLabel);
                return;
            end
            if choice == "Cancel"
                proceed = false;
                app.Logger.log('INFO', ...
                    'PENDING_CAMERA_SETTINGS_ACTION_CANCELLED', ...
                    ['Action=%s | Cameras=%s | PendingPreserved=1 | ', ...
                     'HardwareStateUnchanged=1'], actionName, mat2str(pending));
                app.setStatus(sprintf( ...
                    'Cancelled: %s; unapplied camera settings were kept.', ...
                    actionName));
                if ~isempty(statusLabel) && isvalid(statusLabel)
                    statusLabel.Text = sprintf( ...
                        '%s cancelled — camera settings remain Pending.', ...
                        actionName);
                    statusLabel.FontColor = [0.25 0.25 0.25];
                end
                return;
            end
            applied = zeros(1, 0);
            for cameraIndex = pending
                requestedExposureMs = app.ExposureFields{cameraIndex}.Value;
                requestedROIText = app.ROIFields{cameraIndex}.Value;
                requestedBin = app.BinDropDowns{cameraIndex}.Value;
                if ~app.applyCameraSettings(cameraIndex)
                    app.ExposureFields{cameraIndex}.Value = ...
                        requestedExposureMs;
                    app.ROIFields{cameraIndex}.Value = requestedROIText;
                    app.BinDropDowns{cameraIndex}.Value = requestedBin;
                    app.SettingsDirty(cameraIndex) = true;
                    app.syncExposurePreset(cameraIndex);
                    app.syncRoiPreset(cameraIndex);
                    app.updateCameraModeLabel(cameraIndex, 'pending');
                    proceed = false;
                    app.Logger.log('ERROR', ...
                        'PENDING_CAMERA_SETTINGS_APPLY_SEQUENCE_FAILED', ...
                        ['Action=%s | FailedCamera=%d | AppliedCameras=%s | ', ...
                         'FailedCameraPendingPreserved=1'], actionName, ...
                        cameraIndex, mat2str(applied));
                    return;
                end
                applied(end + 1) = cameraIndex; %#ok<AGROW>
            end
            app.Logger.log('SUCCESS', ...
                'PENDING_CAMERA_SETTINGS_APPLIED_AND_CONTINUING', ...
                'Action=%s | Cameras=%s | SaveRoot=%s', ...
                actionName, mat2str(applied), saveRoot);
        end

        function frames = captureCameras(app, indices, reason, restartPreview, lightingPolicy)
            if nargin < 5
                lightingPolicy = 'mapped_imaging';
            end
            lightingPolicy = string(lightingPolicy);
            if ~any(lightingPolicy == ["mapped_imaging", "unchanged"])
                error('ZouLab:CaptureLightingPolicyInvalid', ...
                    'Capture lighting policy must be mapped_imaging or unchanged.');
            end
            indices = unique(double(indices(:).'));
            if any(app.SettingsDirty(indices))
                error('ZouLab:CameraSettingsPending', ...
                    'Camera setting edits are pending for camera(s) %s. Click each camera Apply first.', ...
                    mat2str(indices(app.SettingsDirty(indices))));
            end
            if any(~app.Cameras.Connected(indices))
                for cameraIndex = indices
                    if ~app.Cameras.Connected(cameraIndex)
                        exposure = app.ExposureFields{cameraIndex}.Value / 1000;
                        roi = zoulab.UserSettings.parseROI(app.ROIFields{cameraIndex}.Value);
                        binFactor = app.BinDropDowns{cameraIndex}.Value;
                        app.Cameras.configureCamera(cameraIndex, exposure, roi, ...
                            binFactor, app.Logger);
                    end
                end
                app.Cameras.connect(indices, app.Logger);
            end
            previousPreview = app.PreviewActive;
            for cameraIndex = indices
                if app.PreviewActive(cameraIndex)
                    app.stopCameraPreview(cameraIndex, 'capture_prepare');
                end
            end
            controlLights = lightingPolicy == "mapped_imaging";
            if controlLights
                lightRows = app.imagingLightRowsFor(indices);
                aliases = app.lightAliases(lightRows);
            else
                lightRows = zeros(1, 0);
                aliases = strings(1, 0);
            end
            useDaqTrigger = numel(indices) == 2 || app.DaqController.Connected;
            if app.SimulationMode
                useDaqTrigger = false;
            end
            if numel(indices) == 2 && ~app.SimulationMode
                app.DaqController.assertReady();
            end
            cleanup = onCleanup(@() app.finishCapture(indices, lightRows, aliases, ...
                previousPreview & restartPreview, useDaqTrigger, controlLights));

            app.Logger.log('INFO', 'CAPTURE_BEGIN', ...
                ['Reason=%s | Cameras=%s | LightRows=%s | LightAliases=%s | ', ...
                 ['DaqSynchronized=%d | LightingPolicy=%s | ', ...
                  'LightStateModified=%d | LightSettleSeconds=%.1f']], ...
                reason, mat2str(indices), mat2str(lightRows), ...
                strjoin(aliases, ','), useDaqTrigger, lightingPolicy, ...
                controlLights, 0.2 * controlLights);
            if ~app.SimulationMode && controlLights
                app.setImagingLights(lightRows, aliases, true);
                pause(0.2);
            end

            if useDaqTrigger
                app.Cameras.prepareExternalAcquisition(indices, 1, app.Logger);
                app.DaqController.pulseCameras(indices, app.Logger);
                timeout = max(2, max(app.Cameras.ExposureTimes(indices)) * 20);
                frames = app.Cameras.collectTriggeredFrames(indices, timeout, app.Logger);
            else
                frames = app.Cameras.acquireInternalSnapshots(indices, app.Logger);
                if app.SimulationMode
                    app.Logger.log('INFO', 'SIMULATION_CAPTURE_GENERATED', ...
                        'Reason=%s | Cameras=%s | PhysicalSynchronizationNotTested=1', ...
                        reason, mat2str(indices));
                else
                    app.Logger.log('INFO', 'SINGLE_CAMERA_INTERNAL_TRIGGER_USED', ...
                        ['Reason=%s | Camera=%s | DualSequentialFallbackDisabled=1 | ', ...
                         'DAQNotConnected=1'], reason, mat2str(indices));
                end
            end
            for cameraIndex = indices
                if ~isa(frames{cameraIndex}, 'uint16')
                    error('ZouLab:RawClassMismatch', ...
                        'Camera %d returned %s instead of uint16.', ...
                        cameraIndex, class(frames{cameraIndex}));
                end
            end
            app.Logger.log('SUCCESS', 'CAPTURE_SUCCESS', ...
                'Reason=%s | Cameras=%s | Synchronized=%d | RawClass=uint16', ...
                reason, mat2str(indices), useDaqTrigger);
        end

        function finishCapture(app, indices, lightRows, aliases, restartMask, usedDaq, controlLights)
            if controlLights && ~isempty(lightRows)
                try
                    app.setImagingLights(lightRows, aliases, false);
                catch ME
                    app.Logger.logException('IMAGING_LIGHT_AUTO_OFF_FAILED', ME);
                    app.DaqController.safeOff();
                end
            elseif controlLights
                app.DaqController.safeOff();
            end
            if usedDaq
                try
                    app.Cameras.restorePreviewConfiguration(indices, app.Logger);
                catch ME
                    app.Logger.logException('CAMERA_TRIGGER_RESTORE_FAILED', ME);
                end
            end
            app.restartPreviewMask(restartMask, 'capture_cleanup');
            app.Logger.log('INFO', 'CAPTURE_CLEANUP_COMPLETE', ...
                ['Cameras=%s | LightingPolicyControlled=%d | ', ...
                 'ImagingLightsOff=%d | RestartMask=%s'], ...
                mat2str(indices), controlLights, controlLights, ...
                mat2str(restartMask));
        end

        function restartPreviewMask(app, mask, source)
            if app.RunState.Closing
                return;
            end
            for cameraIndex = find(mask)
                if ~app.PreviewActive(cameraIndex)
                    try
                        app.startCameraPreview(cameraIndex, source);
                    catch ME
                        app.Logger.logException('PREVIEW_RESTART_AFTER_CAPTURE_FAILED', ME);
                    end
                end
            end
        end

        function files = saveFrameSet(app, frames, parentFolder, baseName, indices)
            files = strings(1,0);
            for cameraIndex = indices
                camFolder = app.Sessions.cameraFolder(parentFolder, cameraIndex);
                if startsWith(baseName, 'F')
                    fileName = baseName + ".tif";
                else
                    fileName = sprintf('%s_Cam%d.tif', baseName, cameraIndex);
                end
                filePath = string(fullfile(camFolder, fileName));
                app.RecordStatus(cameraIndex) = "0/1";
                app.refreshFPSLabel(cameraIndex, false);
                app.Logger.log('INFO', 'RECORD_FRAME_WRITE_BEGIN', ...
                    ['Camera=%d | ExpectedFrames=1 | WrittenFrames=0 | ', ...
                     'RecordFPS=not_applicable_single_frame | File=%s'], ...
                    cameraIndex, filePath);
                try
                    imwrite(uint16(frames{cameraIndex}), filePath, ...
                        'tif', 'Compression', 'none');
                catch ME
                    app.RecordStatus(cameraIndex) = "ERROR";
                    app.refreshFPSLabel(cameraIndex, false);
                    app.Logger.logException('RECORD_FRAME_WRITE_FAILED', ME);
                    app.Logger.log('ERROR', 'RECORD_FRAME_COUNT', ...
                        ['Camera=%d | ExpectedFrames=1 | WrittenFrames=0 | ', ...
                         'RecordFPS=not_available | File=%s'], cameraIndex, filePath);
                    rethrow(ME);
                end
                files(end+1) = filePath; %#ok<AGROW>
                app.RecordStatus(cameraIndex) = "1/1";
                app.refreshFPSLabel(cameraIndex, false);
                app.Logger.log('SUCCESS', 'UINT16_TIFF_SAVED', ...
                    'Camera=%d | File=%s | Size=%s | Transposed=0', ...
                    cameraIndex, filePath, mat2str(size(frames{cameraIndex})));
                app.Logger.log('SUCCESS', 'RECORD_FRAME_COUNT', ...
                    ['Camera=%d | ExpectedFrames=1 | WrittenFrames=1 | ', ...
                     'DroppedFrames=0 | RecordFPS=not_applicable_single_frame | File=%s'], ...
                    cameraIndex, filePath);
            end
        end

        function [recordPath, metadata] = ensureRecord(app)
            app.Sessions.RootPath = string(app.RootPathField.Value);
            app.Sessions.MethodNote = string(app.MethodNoteField.Value);
            app.Sessions.CameraLabels = [string(app.Camera1LabelField.Value), ...
                string(app.Camera2LabelField.Value)];
            operator = struct('id', char(app.Logger.OperatorID), ...
                'name', char(app.Logger.OperatorName), ...
                'identity_confirmation', 'user_profile_open_or_create', ...
                'id_derivation', 'case-insensitive canonical user name');
            settings = struct( ...
                'camera_mode', app.CameraModeDropDown.Value, ...
                'active_cameras', app.activeCameraIndices(), ...
                'formats', {cellstr(app.Cameras.VideoFormats)}, ...
                'roi', {app.Cameras.ROIs}, ...
                'bin', app.Cameras.Bins, ...
                'exposure_seconds', app.Cameras.ExposureTimes, ...
                'display_transpose', app.TransposeDisplay, ...
                'raw_uint16', true, ...
                'raw_transposed', false, ...
                'preview_render_limit_fps', app.PreviewRenderLimitFPS, ...
                'acquisition_plan', app.RunState.FrozenAcquisitionPlan, ...
                'acquisition_state', char(app.RunState.Status), ...
                'visual_stimulus', app.VisualStimulusController.manifest(), ...
                'light_stimulus', app.LightStimulusController.snapshot(), ...
                'rig_wiring_file', char(app.WiringConfig.FilePath), ...
                'rig_wiring', app.WiringConfig.Value, ...
                'daq_device', char(app.DaqController.DeviceID), ...
                'daq_connected', app.DaqController.Connected, ...
                'dual_snap_timelapse_trigger', ...
                    'NI-DAQ simultaneous TTL; no sequential fallback', ...
                'spectra_address', char(app.DaqController.SpectraAddress), ...
                'spectra_usb_port', char(app.SpectraController.Port), ...
                'light_control', app.lightControlDescription(), ...
                'light_mapping', app.lightMappingStruct());
            methodSpec = app.buildMethodSpec();
            previousMethodID = app.Sessions.MethodID;
            previousMethodPath = app.Sessions.MethodPath;
            [recordPath, metadata] = app.Sessions.ensureRecord( ...
                operator, settings, methodSpec);
            if isfinite(previousMethodID) && ...
                    previousMethodID ~= app.Sessions.MethodID
                app.Logger.log('INFO', 'METHOD_AUTO_ROLLOVER', ...
                    ['PreviousMethodID=%d | PreviousMethodPath=%s | ', ...
                     'NewMethodID=%d | NewMethodPath=%s | ', ...
                     'Reason=acquisition-critical configuration changed'], ...
                    previousMethodID, previousMethodPath, ...
                    app.Sessions.MethodID, app.Sessions.MethodPath);
            end
            app.Logger.setSession(sprintf('M%d-R%d', ...
                app.Sessions.MethodID, app.Sessions.RecordID));
            app.Logger.log('INFO', 'RECORD_PATH_READY', ...
                ['RecordPath=%s | Naming=RecN_note_YYMMDDhhmm | ', ...
                 'MethodModel=record_aggregate_plus_module_snapshots | ', ...
                 'MethodPath=%s'], recordPath, app.Sessions.MethodPath);
        end

        function records = currentModuleMethodRecords(app)
            lightArmed = app.LightStimulusController.Armed;
            dmdEnabled = string(app.LightStimDmdSwitch.Value) == "ON";
            records = struct( ...
                'visual_ptb', app.moduleMethodRecord('visual_ptb', ...
                    app.VisualStimulusController.Armed), ...
                'visual_led', app.moduleMethodRecord('visual_led', ...
                    app.LedFlickerController.Armed), ...
                'light_stim_laser', app.moduleMethodRecord( ...
                    'light_stim_laser', lightArmed), ...
                'dmd', app.moduleMethodRecord('dmd', ...
                    lightArmed && dmdEnabled));
        end

        function record = moduleMethodRecord(app, moduleName, enabled)
            spec = app.currentModuleMethodSpec(moduleName);
            state = app.ModuleMethodState.(char(moduleName));
            currentSignature = app.methodSpecSignature(spec);
            if strlength(string(state.signature)) == 0
                status = "manual";
                name = "Manual";
                source = "manual";
                derivedFrom = "";
            elseif currentSignature == string(state.signature)
                status = "loaded";
                name = string(state.name);
                source = string(state.source);
                derivedFrom = "";
            else
                status = "modified";
                name = "Manual";
                source = "manual_modified";
                derivedFrom = string(state.name);
            end
            record = struct('module', char(string(moduleName)), ...
                'name', char(name), 'status', char(status), ...
                'source', char(source), ...
                'derived_from', char(derivedFrom), ...
                'source_file', char(string(state.file)), ...
                'enabled_for_record', logical(enabled), ...
                'spec', spec);
        end

        function record = currentDmdCalibrationRecord(app)
            filePath = string(app.DmdCalibrationMatrixField.Value);
            loaded = ~isempty(fieldnames(app.DmdCalibrationData));
            hash = "";
            if loaded && isfile(filePath)
                try
                    hash = string(app.sha256File(filePath));
                catch ME
                    app.Logger.logException( ...
                        'DMD_CALIBRATION_RECORD_HASH_FAILED', ME);
                end
            end
            record = struct('loaded', loaded, ...
                'file', char(filePath), 'sha256', char(hash), ...
                'calibration', app.DmdCalibrationData);
        end

        function methodSpec = buildMethodSpec(app)
            indices = app.activeCameraIndices();
            cameraSpec = struct([]);
            fpsValues = nan(1, numel(indices));
            for position = 1:numel(indices)
                cameraIndex = indices(position);
                fpsValues(position) = app.expectedStreamFPS(cameraIndex);
                currentCameraSpec = struct( ...
                    'camera_index', cameraIndex, ...
                    'label', char(string( ...
                        app.Sessions.CameraLabels(cameraIndex))), ...
                    'format', char(string(app.Cameras.VideoFormats(cameraIndex))), ...
                    'roi', app.Cameras.ROIs{cameraIndex}, ...
                    'bin', app.Cameras.Bins(cameraIndex), ...
                    'exposure_seconds', app.Cameras.ExposureTimes(cameraIndex), ...
                    'expected_fps', fpsValues(position), ...
                    'raw_class', 'uint16', 'raw_transposed', false, ...
                    'display_transpose', app.TransposeDisplay(cameraIndex));
                if position == 1
                    cameraSpec = currentCameraSpec;
                else
                    cameraSpec(position) = currentCameraSpec;
                end
            end
            if app.VisualStimulusController.Armed
                recordMode = 'visualstim';
                finiteFPS = fpsValues(isfinite(fpsValues) & fpsValues > 0);
                cameraFPS = NaN;
                if ~isempty(finiteFPS)
                    cameraFPS = finiteFPS(1);
                end
                stimSpec = app.VisualStimulusController.legacyStimSpec(cameraFPS);
                stimRuntime = app.VisualStimulusController.legacyRuntime();
            else
                recordMode = lower(strrep(char(string( ...
                    app.AcquisitionModeDropDown.Value)), ' ', '_'));
                stimSpec = struct('enabled', false, 'mode', recordMode);
                stimRuntime = struct();
            end
            timing = struct( ...
                'stimulus_duration_seconds', ...
                    app.VisualStimulusController.estimatedDuration(), ...
                'camera_pre_stim_seconds', app.CameraPreStimField.Value, ...
                'camera_post_stim_seconds', app.CameraPostStimField.Value, ...
                'light_lead_seconds', app.LightLeadField.Value, ...
                'light_tail_seconds', app.LightTailField.Value, ...
                'ptb_start_offset_seconds', app.CameraPreStimField.Value, ...
                'ptb_end_padding_seconds', app.CameraPostStimField.Value, ...
                'imaging_light_start_offset_seconds', ...
                    app.LightLeadField.Value, ...
                'imaging_light_end_offset_seconds', ...
                    app.LightTailField.Value, ...
                    'camera_window_semantics', ...
                    'Camera START is t=0; independent signed output offsets');
            if string(app.AcquisitionModeDropDown.Value) == "Record"
                captureSaveType = 'bin';
                if app.RecordTiffCheckBox.Value
                    saveType = 'tiff';
                else
                    saveType = 'bin';
                end
            else
                captureSaveType = 'tiff';
                saveType = 'tiff';
            end
            methodSpec = struct( ...
                'recordmode', recordMode, ...
                'savetype', saveType, ...
                'capture_savetype', captureSaveType, ...
                'cycles', round(app.CycleCountField.Value), ...
                'acquisition', struct( ...
                    'mode', char(string(app.AcquisitionModeDropDown.Value)), ...
                    'cycle_start_interval_seconds', ...
                        app.CycleIntervalField.Value, ...
                    'record_duration_seconds', ...
                        app.resolvedRecordWindowSeconds(), ...
                    'record_duration_custom_seconds', ...
                        app.RecordDurationField.Value, ...
                    'record_length_source', char(string( ...
                        app.RecordLengthSourceDropDown.Value)), ...
                    'convert_record_to_tiff', app.RecordTiffCheckBox.Value, ...
                    'time_lapse_interval_seconds', app.TLIntervalField.Value, ...
                    'time_lapse_points', app.TLPointsField.Value), ...
                'labels', {cellstr(app.Sessions.CameraLabels)}, ...
                'hardwareInfo', struct( ...
                    'camera_mode', char(string(app.CameraModeDropDown.Value)), ...
                    'daq_device', char(app.DaqController.DeviceID), ...
                    'spectra_usb_port', char(app.SpectraController.Port)), ...
                'cameraSpec', cameraSpec, 'stimSpec', stimSpec, ...
                'visual', app.visualConfiguration(), ...
                'led_flicker', app.currentLedFlickerSpec(), ...
                'light_stimulus', app.currentLightStimulusSpec(), ...
                'module_methods', app.currentModuleMethodRecords(), ...
                'dmd_calibration', app.currentDmdCalibrationRecord(), ...
                'light_mapping', app.lightMappingStruct(), ...
                'timing', timing, ...
                'actual', struct('stimRuntime', stimRuntime, ...
                    'timing', timing));
        end

        function description = lightControlDescription(app)
            if app.SpectraController.Connected
                description = sprintf('Spectra X USB serial STANDARD mode on %s', ...
                    app.SpectraController.Port);
            elseif app.DaqController.Connected
                description = 'NI-DAQ TTL';
            elseif app.SimulationMode
                description = 'simulation';
            else
                description = 'not connected';
            end
        end

        function refreshLogClicked(app)
            app.beginAction('REFRESH_LOG_VIEW', 'Refreshing log view...', []);
            app.finishAction('REFRESH_LOG_VIEW', true, ...
                'Log view refreshed (latest 200 lines).', []);
            app.flushLogNowIfIdle(false);
            app.refreshLogView();
        end

        function refreshLogView(app)
            if isempty(app.LogArea) || ~isvalid(app.LogArea)
                return;
            end
            try
                lines = app.Logger.recentLines(200);
                app.LogArea.Value = cellstr(lines);
                scroll(app.LogArea, 'bottom');
            catch ME
                app.Logger.log('WARNING', 'LOG_VIEW_REFRESH_FAILED', 'Error=%s', ME.message);
            end
        end

        function openLogFolder(app)
            app.beginAction('OPEN_LOG_FOLDER', 'Opening log folder...', []);
            try
                winopen(fileparts(app.Logger.FilePath));
                app.finishAction('OPEN_LOG_FOLDER', true, ...
                    "Opened: " + string(fileparts(app.Logger.FilePath)), []);
            catch ME
                app.handleError('OPEN_LOG_FOLDER_FAILED', ME, []);
            end
        end

        function responsiveLayout(app)
            if isempty(app.UIFigure) || ~isvalid(app.UIFigure) || ...
                    isempty(app.RootGrid) || ~isvalid(app.RootGrid)
                return;
            end
            width = app.UIFigure.Position(3);
            height = app.UIFigure.Position(4);
            if width < 1200
                bucket = "small";
                rightWidth = min(380, max(320, round(width * 0.34)));
            elseif width < 1500
                bucket = "compact";
                rightWidth = min(520, max(460, round(width * 0.36)));
            elseif width < 1900
                bucket = "standard";
                rightWidth = min(680, max(560, round(width * 0.36)));
            else
                bucket = "wide";
                rightWidth = min(840, max(720, round(width * 0.32)));
            end
            app.RootGrid.ColumnWidth = {'1x','1x',rightWidth};
            homeGrid = findall(app.UIFigure, 'Tag', 'HomeTabGrid');
            lightPanelHeight = 350;
            if ~isempty(homeGrid)
                % Figure height minus the persistent bottom row, tab/panel
                % chrome, fixed Home rows, padding, and inter-row spacing.
                availableHomeHeight = max(0, height - 270 - 70);
                fixedHomeHeight = 126 + 126 + 122 + 92 + 62 + 42;
                lightPanelHeight = max(350, ...
                    floor(availableHomeHeight - fixedHomeHeight));
                homeGrid(1).RowHeight = ...
                    {126,126,122,lightPanelHeight,92,62};
            end
            if rightWidth < 450
                app.LightTable.ColumnWidth = {30,26,52,54,60,62,50,48};
            elseif rightWidth < 500
                app.LightTable.ColumnWidth = {30,26,58,64,64,68,50,48};
            else
                aliasWidth = max(94, rightWidth - 453);
                app.LightTable.ColumnWidth = ...
                    {35,30,72,aliasWidth,82,88,55,56};
            end
            if app.LastLayoutBucket ~= bucket
                app.LastLayoutBucket = bucket;
                app.Logger.log('INFO', 'RESPONSIVE_LAYOUT_APPLIED', ...
                    ['Bucket=%s | FigureSize=[%g %g] | RightColumn=%g | ', ...
                     'HomeLightPanelHeight=%g'], ...
                    bucket, width, height, rightWidth, lightPanelHeight);
            end
        end

        function beginAction(app, actionName, message, statusLabel)
            app.Logger.log('INFO', 'USER_ACTION_REQUESTED', ...
                'Action=%s | Message=%s', actionName, string(message));
            app.setStatus("Working: " + string(message));
            if ~isempty(statusLabel) && isvalid(statusLabel)
                statusLabel.Text = "Working: " + string(message);
                statusLabel.FontColor = [0.80 0.48 0.05];
            end
            drawnow limitrate nocallbacks;
        end

        function finishAction(app, actionName, success, message, statusLabel)
            if success
                level = 'SUCCESS';
                prefix = "Success: ";
                color = [0.08 0.55 0.18];
            else
                level = 'WARNING';
                prefix = "Not completed: ";
                color = [0.78 0.18 0.12];
            end
            app.Logger.log(level, 'USER_ACTION_RESULT', ...
                'Action=%s | Success=%d | Message=%s', ...
                actionName, success, string(message));
            app.setStatus(prefix + string(message));
            if ~isempty(statusLabel) && isvalid(statusLabel)
                statusLabel.Text = prefix + string(message);
                statusLabel.FontColor = color;
            end
        end

        function setCameraStatus(app, cameraIndex, message, state)
            label = app.CameraStatusLabels{cameraIndex};
            label.Text = char(string(message));
            switch string(state)
                case "success"
                    label.FontColor = [0.08 0.55 0.18];
                case "error"
                    label.FontColor = [0.78 0.18 0.12];
                otherwise
                    label.FontColor = [0.80 0.48 0.05];
            end
            app.setStatus(sprintf('Camera %d: %s', cameraIndex, string(message)));
        end

        function identityBlocked(app, statusLabel)
            message = 'Blocked: confirm operator name first.';
            if ~isempty(statusLabel) && isvalid(statusLabel)
                statusLabel.Text = message;
                statusLabel.FontColor = [0.78 0.18 0.12];
            end
            app.setStatus(message);
        end

        function setStatus(app, textValue)
            if isempty(app.MainStatusArea) || ~isvalid(app.MainStatusArea)
                return;
            end
            app.MainStatusArea.Value = {char(string(textValue))};
            drawnow limitrate nocallbacks;
        end

        function handleError(app, eventName, exception, statusLabel)
            app.Logger.logException(eventName, exception);
            app.setStatus("ERROR: " + string(exception.message));
            if nargin >= 4 && ~isempty(statusLabel) && isvalid(statusLabel)
                statusLabel.Text = "Error: " + string(exception.message);
                statusLabel.FontColor = [0.78 0.18 0.12];
            end
            % Persist diagnostic failures immediately when the system is
            % idle. During acquisition, disk activity remains prohibited;
            % the independent one-minute timer will flush after idle resumes.
            app.flushLogNowIfIdle(false);
            app.refreshLogView();
            app.showError(exception);
        end

        function showError(app, exception)
            if ~app.RunState.Closing && ~isempty(app.UIFigure) && isvalid(app.UIFigure)
                if strcmpi(app.UIFigure.Visible, 'on')
                    try
                        uialert(app.UIFigure, exception.message, 'Operation Failed');
                    catch alertError
                        app.Logger.logException('ERROR_DIALOG_DISPLAY_FAILED', ...
                            alertError);
                    end
                else
                    app.Logger.log('INFO', 'ERROR_DIALOG_SKIPPED_HIDDEN_UI', ...
                        'OriginalError=%s', exception.message);
                end
            end
        end

        function value = structFieldOr(~, source, name, fallback)
            if isstruct(source) && isfield(source, name)
                value = source.(name);
            else
                value = fallback;
            end
        end

        function applyControlValueIfPresent(~, control, source, name)
            if ~isstruct(source) || ~isfield(source, name) || ...
                    isempty(control) || ~isvalid(control)
                return;
            end
            value = source.(name);
            if isa(control, 'matlab.ui.control.DropDown')
                value = char(string(value));
            end
            control.Value = value;
        end

        function closeFigureIfValid(~, figureHandle)
            if ~isempty(figureHandle) && isgraphics(figureHandle)
                delete(figureHandle);
            end
        end

        function stopAndDeleteTimer(app, propertyName)
            timerObject = app.(propertyName);
            if isempty(timerObject)
                return;
            end
            try
                if isvalid(timerObject)
                    stop(timerObject);
                    delete(timerObject);
                end
            catch
            end
            app.(propertyName) = [];
        end

        function value = cameraOwnershipText(app)
            if app.SimulationMode
                value = 'main_process_simulator';
            else
                value = 'persistent_child_matlab_until_safe_exit';
            end
        end

        function closeRequested(app, preconfirmed)
            if nargin < 2
                preconfirmed = false;
            end
            if app.RunState.Closing
                return;
            end
            app.Logger.log('INFO', 'USER_CLOSE_APP_CLICKED', ...
                ['PreviewActive=%s | TimeLapseRunning=%d | ', ...
                 'AcquisitionRunning=%d | AcquisitionState=%s | ', ...
                 'Preconfirmed=%d'], ...
                mat2str(app.PreviewActive), ~isempty(app.TimeLapseTimer), ...
                app.RunState.AcquisitionRunning, app.RunState.Status, preconfirmed);
            app.setStatus('Working: close requested.');
            if app.RunState.AcquisitionRunning
                if ~preconfirmed
                    choice = uiconfirm(app.UIFigure, ...
                        ['Acquisition is running. Stop it, preserve acquired data, ', ...
                         'finish cleanup, and then close the app?'], ...
                        'Confirm Close', 'Options', {'Stop and close','Cancel'}, ...
                        'DefaultOption', 2, 'CancelOption', 2);
                    if strcmp(choice, 'Cancel')
                        app.Logger.log('INFO', 'APP_CLOSE_CANCELLED', ...
                            'Acquisition continues running.');
                        app.setStatus('Not completed: app close cancelled.');
                        return;
                    end
                else
                    app.Logger.log('INFO', ...
                        'APP_CLOSE_RUNNING_ACQUISITION_PRECONFIRMED', ...
                        ['Source=SafeExit | Action=stop_preserve_cleanup_close | ', ...
                         'NoSecondDialog=1']);
                end
                app.RunState.closeAfterCapture();
                app.Acquisition.requestAcquisitionStop();
                return;
            end
            if ~isempty(app.TimeLapseTimer)
                if ~preconfirmed
                    choice = uiconfirm(app.UIFigure, ...
                        'Time Lapse is running. Stop it and close the app?', ...
                        'Confirm Close', 'Options', {'Stop and close','Cancel'}, ...
                        'DefaultOption', 2, 'CancelOption', 2);
                    if strcmp(choice, 'Cancel')
                        app.Logger.log('INFO', 'APP_CLOSE_CANCELLED', ...
                            'Time Lapse remains active.');
                        app.setStatus('Not completed: app close cancelled.');
                        return;
                    end
                else
                    app.Logger.log('INFO', ...
                        'APP_CLOSE_TIMELAPSE_PRECONFIRMED', ...
                        'Source=SafeExit | Action=stop_and_close | NoSecondDialog=1');
                end
                app.stopTimeLapse('app_closed');
            end
            delete(app);
        end

        function forceWindowClose(app)
            if app.RunState.Closing || app.RunState.EmergencyClosing
                return;
            end
            app.RunState.forceClose();
            % The window X is deliberately a force-close-only path.  It must
            % not show a dialog, save settings/logs, issue hardware commands,
            % wait for workers, or enter the normal delete cleanup sequence.
            app.stopAndDeleteTimer('TimeLapseTimer');
            app.stopAndDeleteTimer('SimulationTimer');
            app.stopAndDeleteTimer('RemotePreviewTimer');
            app.stopAndDeleteTimer('StatusTimer');
            app.stopAndDeleteTimer('LogFlushTimer');
            app.stopAndDeleteTimer('UiRefreshDebounceTimer');
            app.stopAndDeleteTimer('ConversionTimer');
            try
                app.Logger.discard();
            catch
            end
            figureHandle = app.UIFigure;
            if ~isempty(figureHandle) && isvalid(figureHandle)
                figureHandle.CloseRequestFcn = [];
                figureHandle.Visible = 'off';
                drawnow limitrate nocallbacks;
                delete(figureHandle);
            end
        end

        function safeExitClicked(app)
            app.Logger.log('INFO', 'USER_SAFE_EXIT_CLICKED', ...
                ['AcquisitionRunning=%d | AcquisitionState=%s | ', ...
                 'PreviewActive=%s'], app.RunState.AcquisitionRunning, ...
                app.RunState.Status, mat2str(app.PreviewActive));
            message = sprintf([ ...
                'Safely close ZouLabView?\n\n', ...
                'This will stop active Preview/Acquisition, preserve acquired ', ...
                'data, switch controlled outputs to their safe OFF state, ', ...
                'release cameras, DAQ, light sources and DMD, close the PTB ', ...
                'Screen, and then close this MATLAB session. Any unsaved work ', ...
                'in this same MATLAB session will be lost.']);
            app.Logger.log('INFO', 'USER_SAFE_EXIT_CONFIRMATION_SHOWN', ...
                ['Default=Cancel | AcquisitionRunning=%d | ', ...
                 'TimeLapseRunning=%d | PreviewActive=%s'], ...
                app.RunState.AcquisitionRunning, ~isempty(app.TimeLapseTimer), ...
                mat2str(app.PreviewActive));
            app.setStatus('Confirmation required: choose Safe Exit or Cancel.');
            try
                if isempty(app.SafeExitConfirmationProvider)
                    choice = uiconfirm(app.UIFigure, message, ...
                        'Confirm Safe Exit', ...
                        'Options', {'Safe Exit','Cancel'}, ...
                        'DefaultOption', 2, 'CancelOption', 2, ...
                        'Icon', 'warning');
                else
                    choice = app.SafeExitConfirmationProvider(message);
                end
                choice = string(choice);
                if ~any(choice == ["Safe Exit", "Cancel"])
                    error('ZouLab:SafeExitConfirmationInvalid', ...
                        'Safe Exit confirmation returned an invalid choice: %s.', ...
                        choice);
                end
            catch ME
                app.handleError('SAFE_EXIT_CONFIRMATION_FAILED', ME, []);
                return;
            end
            if choice == "Cancel"
                app.Logger.log('INFO', 'USER_SAFE_EXIT_CANCELLED', ...
                    ['AcquisitionContinues=%d | TimeLapseContinues=%d | ', ...
                     'PreviewContinues=%s | HardwareStateUnchanged=1'], ...
                    app.RunState.AcquisitionRunning, ~isempty(app.TimeLapseTimer), ...
                    mat2str(app.PreviewActive));
                app.setStatus('Not completed: Safe Exit cancelled; hardware state unchanged.');
                return;
            end
            app.Logger.log('SUCCESS', 'USER_SAFE_EXIT_CONFIRMED', ...
                ['AcquisitionRunning=%d | TimeLapseRunning=%d | ', ...
                 'PreviewActive=%s | CleanupRequested=1 | ', ...
                 'TerminateCurrentMatlabSessionAfterCleanup=1'], ...
                app.RunState.AcquisitionRunning, ~isempty(app.TimeLapseTimer), ...
                mat2str(app.PreviewActive));
            app.TerminateHostOnDelete = true;
            app.setStatus('Working: Safe Exit confirmed; cleaning up hardware.');
            app.closeRequested(true);
        end
    end

    methods (Static, Access = private)
        function hash = sha256File(pathText)
            fileID = fopen(pathText, 'rb');
            if fileID < 0
                error('ZouLab:FileHashOpenFailed', ...
                    'Could not open file for SHA-256: %s', pathText);
            end
            cleanup = onCleanup(@() fclose(fileID)); %#ok<NASGU>
            bytes = fread(fileID, Inf, '*uint8');
            digest = java.security.MessageDigest.getInstance('SHA-256');
            digest.update(bytes);
            raw = typecast(digest.digest(), 'uint8');
            hash = string(lower(reshape(dec2hex(raw, 2).', 1, [])));
        end

        function value = onOff(flag)
            if flag
                value = 'on';
            else
                value = 'off';
            end
        end

        function textValue = fpsText(fps)
            if isfinite(fps)
                textValue = sprintf('%6.1f', fps);
            else
                textValue = '    --';
            end
        end

        function fps = parseFrameRate(rawValue)
            fps = NaN;
            if iscell(rawValue) && isscalar(rawValue)
                rawValue = rawValue{1};
            end
            if isnumeric(rawValue) || islogical(rawValue)
                candidate = double(rawValue);
            elseif ischar(rawValue) || (isstring(rawValue) && isscalar(rawValue))
                candidate = sscanf(char(rawValue), '%f', 1);
            else
                return;
            end
            if isscalar(candidate) && isfinite(candidate) && candidate > 0
                fps = candidate;
            end
        end

        function textValue = diagnosticValueText(rawValue)
            if isempty(rawValue)
                textValue = '<empty>';
            elseif ischar(rawValue)
                textValue = rawValue;
            elseif isstring(rawValue)
                textValue = char(strjoin(rawValue(:).', ' '));
            elseif isnumeric(rawValue) || islogical(rawValue)
                textValue = mat2str(rawValue);
            else
                textValue = sprintf('<%s>', class(rawValue));
            end
        end

        function textValue = lightStateText(flag)
            if flag
                textValue = 'ON';
            else
                textValue = 'OFF';
            end
        end
    end
end
