classdef SessionManager < handle
    %SESSIONMANAGER Creates short, analysis-compatible acquisition paths.

    properties
        RootPath string = ""
        MethodNote string = "default"
        CameraLabels string = ["cyan", "red"]
    end

    properties (SetAccess = private)
        MethodID double = NaN
        MethodPath string = ""
        RecordID double = NaN
        RecordPath string = ""
        MethodSignature string = ""
    end

    methods
        function obj = SessionManager(rootPath)
            if nargin > 0
                obj.RootPath = string(rootPath);
            end
        end

        function validate(obj)
            if strlength(strtrim(obj.RootPath)) == 0
                error('ZouLab:RootRequired', 'Please choose an experiment root folder.');
            end
            if ~exist(obj.RootPath, 'dir')
                mkdir(obj.RootPath);
            end
        end

        function [recordPath, manifest] = ensureRecord(obj, operator, settings, methodSpec)
            if nargin < 4 || isempty(methodSpec)
                methodSpec = settings;
            end
            obj.validate();
            signatureSpec = methodSpec;
            if isstruct(signatureSpec) && isfield(signatureSpec, 'actual')
                signatureSpec = rmfield(signatureSpec, 'actual');
            end
            signature = string(jsonencode(signatureSpec));
            if strlength(obj.RecordPath) > 0
                currentRoot = string(fileparts(obj.RecordPath));
                if ~strcmpi(currentRoot, obj.RootPath) || ...
                        (strlength(obj.MethodSignature) > 0 && ...
                        obj.MethodSignature ~= signature)
                    obj.resetMethod();
                end
            end
            if strlength(obj.RecordPath) == 0
                obj.RecordID = obj.nextIndex(obj.RootPath, '^Rec(\d+)_');
                % MethodID is retained as a compatibility identifier for
                % existing manifests and log session IDs.  New storage has
                % no outer MethodsN directory, so it follows the Record ID.
                obj.MethodID = obj.RecordID;
                note = obj.cleanToken(obj.MethodNote, 'default');
                stamp = char(datetime('now', 'Format', 'yyMMddHHmm'));
                obj.RecordPath = string(fullfile(obj.RootPath, ...
                    sprintf('Rec%d_%s_%s', obj.RecordID, note, stamp)));
                mkdir(obj.RecordPath);
                obj.MethodSignature = signature;
                obj.MethodPath = obj.createMethodSnapshot(methodSpec);
            end
            recordPath = obj.RecordPath;
            manifest = struct( ...
                'schema_version', '2.0.0', ...
                'created_at', char(datetime('now', 'Format', 'yyyy-MM-dd HH:mm:ss.SSS')), ...
                'operator', operator, ...
                'method_id', obj.MethodID, ...
                'record_id', obj.RecordID, ...
                'method_path', char(obj.MethodPath), ...
                'record_path', char(obj.RecordPath), ...
                'settings', settings);
            obj.writeJson(fullfile(obj.RecordPath, 'record_manifest.json'), manifest);
            compatibleManifest = obj.compatibleRecordManifest(methodSpec);
            obj.writeMatManifest(fullfile(obj.RecordPath, ...
                'record_manifest.mat'), compatibleManifest);
        end

        function pathText = newSnapFolder(obj)
            snapRoot = fullfile(obj.RecordPath, 'Snaps');
            if ~exist(snapRoot, 'dir')
                mkdir(snapRoot);
            end
            pathText = string(fullfile(snapRoot, ...
                ['Snap_' char(datetime('now', 'Format', 'yyyyMMdd_HHmmss_SSS'))]));
            mkdir(pathText);
        end

        function pathText = newTimeLapseFolder(obj)
            pathText = string(fullfile(obj.RecordPath, ...
                ['TL_' char(datetime('now', 'Format', 'yyyyMMdd_HHmmss'))]));
            mkdir(pathText);
        end

        function pathText = newCycleFolder(obj, cycleIndex)
            validateattributes(cycleIndex, {'numeric'}, ...
                {'scalar','integer','positive','finite'});
            if strlength(obj.RecordPath) == 0 || ~exist(obj.RecordPath, 'dir')
                error('ZouLab:RecordRequired', ...
                    'Create the record before allocating a Cycle folder.');
            end
            pathText = string(fullfile(obj.RecordPath, sprintf('Cycle%d', cycleIndex)));
            if exist(pathText, 'dir')
                error('ZouLab:CycleFolderExists', ...
                    'Cycle folder already exists: %s', pathText);
            end
            mkdir(pathText);
        end

        function pathText = newCycleTimeLapseFolder(~, cyclePath)
            pathText = string(fullfile(cyclePath, 'TimeLapse'));
            if ~exist(pathText, 'dir')
                mkdir(pathText);
            end
        end

        function camPath = cameraFolder(obj, parentPath, cameraIndex)
            label = obj.cleanToken(obj.CameraLabels(cameraIndex), sprintf('cam%d', cameraIndex));
            camPath = string(fullfile(parentPath, sprintf('Cam%d_%s', cameraIndex, label)));
            if ~exist(camPath, 'dir')
                mkdir(camPath);
            end
        end

        function resetRecord(obj)
            obj.RecordID = NaN;
            obj.RecordPath = "";
            obj.MethodPath = "";
            obj.MethodSignature = "";
        end

        function resetMethod(obj)
            obj.resetRecord();
            obj.MethodID = NaN;
        end
    end

    methods (Static)
        function writeJson(filePath, value)
            textValue = jsonencode(value, PrettyPrint=true);
            fid = fopen(filePath, 'w', 'n', 'UTF-8');
            if fid < 0
                error('ZouLab:ManifestOpenFailed', 'Cannot write manifest: %s', filePath);
            end
            cleanup = onCleanup(@() fclose(fid));
            fprintf(fid, '%s', textValue);
        end

        function writeMatManifest(filePath, value)
            manifest = value; %#ok<NASGU>
            save(filePath, 'manifest', '-v7.3');
        end

        function writeManifestPair(basePath, value)
            zoulab.SessionManager.writeMatManifest(basePath + ".mat", value);
            zoulab.SessionManager.writeJson(basePath + ".json", value);
        end
    end

    methods (Access = private)
        function methodPath = createMethodSnapshot(obj, methodSpec)
            methodPath = string(fullfile(obj.RecordPath, 'methods'));
            if ~isfolder(methodPath)
                mkdir(methodPath);
            end
            methodManifest = obj.compatibleMethodManifest(methodSpec);
            methodManifest.notes.method_origin = ...
                'record_aggregate_plus_module_snapshots';
            methodManifest.paths.method_path = char(methodPath);
            methodManifest.artifacts.method_manifest_mat = char(fullfile( ...
                methodPath, 'method_manifest.mat'));
            methodManifest.artifacts.method_manifest_json = char(fullfile( ...
                methodPath, 'method_manifest.json'));
            obj.writeManifestPair(fullfile(methodPath, 'method_manifest'), ...
                methodManifest);
            methodValue = struct('schema_version', '2.0.0', ...
                'kind', 'record_method_aggregate', ...
                'created_at', char(datetime('now', ...
                    'Format', 'yyyy-MM-dd HH:mm:ss.SSS')), ...
                'spec', methodSpec);
            obj.writeJson(fullfile(methodPath, 'record_method.json'), ...
                methodValue);
            modulesPath = string(fullfile(methodPath, 'modules'));
            if ~isfolder(modulesPath)
                mkdir(modulesPath);
            end
            if isstruct(methodSpec) && isfield(methodSpec, 'module_methods')
                modules = methodSpec.module_methods;
                names = fieldnames(modules);
                for index = 1:numel(names)
                    obj.writeJson(fullfile(modulesPath, ...
                        names{index} + ".json"), modules.(names{index}));
                end
            end
        end

        function value = nextIndex(~, parent, expression)
            listing = dir(parent);
            values = [];
            for k = 1:numel(listing)
                if ~listing(k).isdir
                    continue;
                end
                token = regexp(listing(k).name, expression, 'tokens', 'once');
                if ~isempty(token)
                    values(end + 1) = str2double(token{1}); %#ok<AGROW>
                end
            end
            if isempty(values)
                value = 1;
            else
                value = max(values) + 1;
            end
        end

        function result = cleanToken(~, value, fallback)
            result = regexprep(char(string(value)), '[^A-Za-z0-9_-]+', '_');
            result = regexprep(result, '^_+|_+$', '');
            if isempty(result)
                result = fallback;
            end
            if numel(result) > 32
                result = result(1:32);
            end
        end

        function manifest = compatibleMethodManifest(obj, methodSpec)
            recordMode = obj.fieldOr(methodSpec, 'recordmode', 'record');
            stimSpec = obj.fieldOr(methodSpec, 'stimSpec', ...
                struct('enabled', false, 'mode', recordMode));
            cameraSpec = obj.fieldOr(methodSpec, 'cameraSpec', struct());
            hardwareInfo = obj.fieldOr(methodSpec, 'hardwareInfo', struct());
            labels = obj.fieldOr(methodSpec, 'labels', cellstr(obj.CameraLabels));
            actual = obj.fieldOr(methodSpec, 'actual', struct());
            saveType = obj.fieldOr(methodSpec, 'savetype', 'tiff');
            captureSaveType = obj.fieldOr(methodSpec, 'capture_savetype', ...
                saveType);
            manifest = struct( ...
                'schema_version', '1.0.0', 'level', 'method', ...
                'ids', struct('method_id', obj.MethodID), ...
                'paths', struct('method_path', char(obj.MethodPath)), ...
                'refs', struct('root_path', char(obj.RootPath)), ...
                'spec', struct('hardwareInfo', hardwareInfo, ...
                    'cameraSpec', cameraSpec, 'stimSpec', stimSpec, ...
                    'recordmode', recordMode, 'savetype', saveType, ...
                    'capture_savetype', captureSaveType, ...
                    'labels', {labels}), ...
                'actual', actual, ...
                'artifacts', struct( ...
                    'method_manifest_mat', char(fullfile(obj.MethodPath, ...
                        'method_manifest.mat')), ...
                    'method_manifest_json', char(fullfile(obj.MethodPath, ...
                        'method_manifest.json'))), ...
                'notes', struct('method_note', char(obj.MethodNote), ...
                    'created_by', 'Zoulabview'), ...
                'status', struct('state', 'frozen'), ...
                'timestamps', struct('created_at', char(datetime('now', ...
                    'Format', 'yyyy-MM-dd HH:mm:ss'))));
        end

        function manifest = compatibleRecordManifest(obj, methodSpec)
            recordMode = obj.fieldOr(methodSpec, 'recordmode', 'record');
            cycles = obj.fieldOr(methodSpec, 'cycles', 1);
            labels = obj.fieldOr(methodSpec, 'labels', cellstr(obj.CameraLabels));
            saveType = obj.fieldOr(methodSpec, 'savetype', 'tiff');
            captureSaveType = obj.fieldOr(methodSpec, 'capture_savetype', ...
                saveType);
            manifest = struct( ...
                'schema_version', '1.0.0', 'level', 'record', ...
                'ids', struct('method_id', obj.MethodID, ...
                    'record_id', obj.RecordID), ...
                'paths', struct('method_path', char(obj.MethodPath), ...
                    'record_path', char(obj.RecordPath)), ...
                'refs', struct('method_manifest', char(fullfile( ...
                    obj.MethodPath, 'method_manifest.mat'))), ...
                'spec', struct('recordmode', recordMode, ...
                    'cycles', cycles, 'savetype', saveType, ...
                    'capture_savetype', captureSaveType, ...
                    'labels', {labels}), ...
                'actual', struct('cycle_paths', {{}}, ...
                    'camera_paths', {{}}), ...
                'artifacts', struct('record_manifest_mat', char(fullfile( ...
                    obj.RecordPath, 'record_manifest.mat')), ...
                    'record_manifest_json', char(fullfile( ...
                    obj.RecordPath, 'record_manifest.json'))), ...
                'notes', struct('record_timestamp', char(datetime('now', ...
                    'Format', 'yyyy-MM-dd HH:mm:ss'))), ...
                'status', struct('state', 'prepared'), ...
                'timestamps', struct('created_at', char(datetime('now', ...
                    'Format', 'yyyy-MM-dd HH:mm:ss'))));
        end

        function value = fieldOr(~, source, name, fallback)
            value = fallback;
            if isstruct(source) && isfield(source, name) && ...
                    ~isempty(source.(name))
                value = source.(name);
            end
        end
    end
end
