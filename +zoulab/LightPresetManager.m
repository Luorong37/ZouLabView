classdef LightPresetManager < handle
    %LIGHTPRESETMANAGER Stores per-user light stimulus presets separately.

    properties (SetAccess = private)
        ActiveUserFolder string = ""
    end

    methods
        function setActiveUserFolder(obj, folder)
            obj.ActiveUserFolder = string(folder);
        end

        function entries = list(obj)
            entries = struct('name', {}, 'builtin', {}, 'value', {}, ...
                'updated_at', {});
            if strlength(obj.ActiveUserFolder) == 0
                return;
            end
            filePath = obj.filePath();
            if ~isfile(filePath)
                return;
            end
            loaded = load(filePath, 'userPresets');
            if isfield(loaded, 'userPresets') && isstruct(loaded.userPresets)
                entries = loaded.userPresets;
            end
        end

        function entry = get(obj, name)
            entries = obj.list();
            match = find(strcmpi(string({entries.name}), strtrim(string(name))), 1);
            if isempty(match)
                error('ZouLab:LightPresetNotFound', ...
                    'Light stimulus preset %s was not found.', string(name));
            end
            entry = entries(match);
        end

        function saveAs(obj, name, value)
            obj.requireUser();
            name = strtrim(string(name));
            if strlength(name) == 0
                error('ZouLab:LightPresetNameRequired', 'Enter a preset name.');
            end
            entries = obj.list();
            if any(strcmpi(string({entries.name}), name))
                error('ZouLab:LightPresetAlreadyExists', ...
                    'Light stimulus preset %s already exists.', name);
            end
            userPresets = obj.loadUsers();
            userPresets(end + 1) = struct( ...
                'name', char(name), 'builtin', false, 'value', value, ...
                'updated_at', char(datetime('now', ...
                    'Format', 'yyyy-MM-dd HH:mm:ss.SSS')));
            save(obj.filePath(), 'userPresets', '-v7.3');
        end
    end

    methods (Access = private)
        function userPresets = loadUsers(obj)
            userPresets = struct('name', {}, 'builtin', {}, 'value', {}, ...
                'updated_at', {});
            filePath = obj.filePath();
            if ~isfile(filePath)
                return;
            end
            loaded = load(filePath, 'userPresets');
            if isfield(loaded, 'userPresets') && isstruct(loaded.userPresets)
                userPresets = loaded.userPresets;
            end
        end

        function pathText = filePath(obj)
            pathText = fullfile(obj.ActiveUserFolder, 'light_stimulus_presets.mat');
        end

        function requireUser(obj)
            if strlength(obj.ActiveUserFolder) == 0 || ~isfolder(obj.ActiveUserFolder)
                error('ZouLab:UserRequired', ...
                    'Create or open a user before saving a light stimulus preset.');
            end
        end
    end

end
