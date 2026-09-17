function targetFile = build_mlapp()
%BUILD_MLAPP Generate HamamatsuImagingApp.mlapp from the reviewed source.
%
% The .m source remains canonical and reviewable.  This builder uses the
% MATLAB internal App Designer serializer, so regenerate the MLAPP with the
% release targeted by the current compatibility branch after source changes.

appRoot = fileparts(mfilename('fullpath'));
sourceFolder = fullfile(appRoot, 'source');
sourceFile = fullfile(sourceFolder, 'HamamatsuImagingApp.m');
targetFile = fullfile(appRoot, 'HamamatsuImagingApp.mlapp');
addpath(appRoot);
addpath(sourceFolder, '-begin');

previousFolder = pwd;
folderCleanup = onCleanup(@() cd(previousFolder)); %#ok<NASGU>
% The appRoot also contains the previously generated .mlapp.  Running from
% sourceFolder guarantees that the reviewed .m source, not the stale MLAPP,
% is instantiated during regeneration.
cd(sourceFolder);

app = HamamatsuImagingApp('SimulationMode', true, 'Visible', 'off');
appCleanup = onCleanup(@() deleteIfValid(app));
fig = app.getUIFigure();
drawnow;

% The build instance is a static serialization source. Its runtime timers
% must not fire while App Designer reloads the class during serialization.
buildTimers = [timerfindall('Name', 'ZouLabPreviewHealth'); ...
    timerfindall('Name', 'ZouLabIdleLogFlush')];
for timerIndex = 1:numel(buildTimers)
    try
        stop(buildTimers(timerIndex));
    catch
    end
end

screenshotFile = fullfile(appRoot, 'ui_preview.png');
exportapp(fig, screenshotFile);

serializer = appdesigner.internal.serialization.MLAPPSerializer(targetFile, fig);
serializer.OverwriteTargetFile = true;
serializer.ClassName = 'HamamatsuImagingApp';
serializer.MatlabCodeText = fileread(sourceFile);
% App Designer requires an editable-section entry in its code model.  The
% implementation remains programmatic and source-controlled in source/*.m,
% but including this entry prevents the generated MLAPP from containing only
% ClassName metadata in appModel.mat.
serializer.EditableSectionCode = {''};
serializer.RunConfigurations = {''};
serializer.ScreenshotPath = screenshotFile;
serializer.save();

fprintf('MLAPP_BUILD_SUCCESS | Target=%s | Source=%s\n', targetFile, sourceFile);
end

function deleteIfValid(app)
try
    if ~isempty(app) && isvalid(app)
        delete(app);
    end
catch
end
end
