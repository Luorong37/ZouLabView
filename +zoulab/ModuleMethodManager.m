classdef ModuleMethodManager < handle
    %MODULEMETHODMANAGER Stores per-user, module-scoped APP methods.
    % Each module has an independent namespace so identical method names do
    % not collide across PTB, LED, laser-waveform, and DMD workflows.

    properties (SetAccess = private)
        ActiveUserFolder string = ""
    end

    methods
        function setActiveUserFolder(obj, folder)
            folder = string(folder);
            if strlength(folder) > 0 && ~isfolder(folder)
                error('ZouLab:ModuleMethodUserFolderMissing', ...
                    'User folder does not exist: %s', folder);
            end
            obj.ActiveUserFolder = folder;
        end

        function entries = list(obj, moduleName)
            moduleName = obj.validateModule(moduleName);
            entries = struct('name', {}, 'folder', {}, 'file', {}, ...
                'updated_at', {});
            if strlength(obj.ActiveUserFolder) == 0
                return;
            end
            folder = obj.moduleFolder(moduleName, false);
            if ~isfolder(folder)
                return;
            end
            listing = dir(fullfile(folder, '*.json'));
            for index = 1:numel(listing)
                filePath = fullfile(listing(index).folder, listing(index).name);
                try
                    value = jsondecode(fileread(filePath));
                    if ~isfield(value, 'name') || ~isfield(value, 'spec')
                        continue;
                    end
                    entries(end + 1) = struct( ... %#ok<AGROW>
                        'name', char(string(value.name)), ...
                        'folder', listing(index).folder, ...
                        'file', filePath, ...
                        'updated_at', char(string(obj.fieldOr(value, ...
                            'updated_at', ''))));
                catch
                    % Leave damaged files untouched for Developer & Logs.
                end
            end
            if ~isempty(entries)
                [~, order] = sort(lower(string({entries.name})));
                entries = entries(order);
            end
        end

        function entry = load(obj, moduleName, name)
            moduleName = obj.validateModule(moduleName);
            entries = obj.list(moduleName);
            match = find(strcmpi(string({entries.name}), ...
                strtrim(string(name))), 1);
            if isempty(match)
                error('ZouLab:ModuleMethodNotFound', ...
                    '%s method %s was not found.', moduleName, string(name));
            end
            value = jsondecode(fileread(entries(match).file));
            if ~isfield(value, 'module') || ...
                    ~strcmpi(string(value.module), moduleName) || ...
                    ~isfield(value, 'spec') || ~isstruct(value.spec)
                error('ZouLab:ModuleMethodInvalid', ...
                    'Method file is not a valid %s method: %s', ...
                    moduleName, entries(match).file);
            end
            entry = value;
            entry.file = entries(match).file;
        end

        function entry = saveAs(obj, moduleName, name, spec)
            obj.requireUser();
            moduleName = obj.validateModule(moduleName);
            displayName = obj.validateName(name);
            entries = obj.list(moduleName);
            if any(strcmpi(string({entries.name}), displayName))
                error('ZouLab:ModuleMethodAlreadyExists', ...
                    '%s method %s already exists. Choose another name.', ...
                    moduleName, displayName);
            end
            folder = obj.moduleFolder(moduleName, true);
            nowText = char(datetime('now', ...
                'Format', 'yyyy-MM-dd HH:mm:ss.SSS'));
            uuid = char(java.util.UUID.randomUUID());
            fileName = "method_" + ...
                string(datetime('now', 'Format', 'yyyyMMdd_HHmmss_SSS')) + ...
                "_" + string(uuid(1:8)) + ".json";
            filePath = fullfile(folder, fileName);
            entry = struct('schema_version', '1.0.0', ...
                'module', char(moduleName), 'name', char(displayName), ...
                'created_at', nowText, 'updated_at', nowText, ...
                'spec', spec);
            zoulab.SessionManager.writeJson(filePath, entry);
            entry.file = char(filePath);
        end
    end

    methods (Access = private)
        function requireUser(obj)
            if strlength(obj.ActiveUserFolder) == 0 || ...
                    ~isfolder(obj.ActiveUserFolder)
                error('ZouLab:UserRequired', ...
                    'Start a user session before using module methods.');
            end
        end

        function folder = moduleFolder(obj, moduleName, createFolder)
            folder = string(fullfile(obj.ActiveUserFolder, 'methods', ...
                moduleName));
            if createFolder && ~isfolder(folder)
                mkdir(folder);
            end
        end

        function moduleName = validateModule(~, moduleName)
            moduleName = lower(strtrim(string(moduleName)));
            allowed = ["visual_ptb","visual_led", ...
                "light_stim_laser","dmd"];
            if ~isscalar(moduleName) || ~any(moduleName == allowed)
                error('ZouLab:ModuleMethodNameInvalid', ...
                    'Unsupported method module: %s', moduleName);
            end
        end

        function name = validateName(~, name)
            name = strtrim(string(name));
            if ~isscalar(name) || strlength(name) == 0
                error('ZouLab:ModuleMethodNameRequired', ...
                    'Enter a method name.');
            end
            if strlength(name) > 64
                error('ZouLab:ModuleMethodNameTooLong', ...
                    'Method names must contain at most 64 characters.');
            end
        end

        function value = fieldOr(~, source, name, fallback)
            if isfield(source, name)
                value = source.(name);
            else
                value = fallback;
            end
        end
    end
end
