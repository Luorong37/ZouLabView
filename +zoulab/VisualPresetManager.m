classdef VisualPresetManager < handle
    %VISUALPRESETMANAGER Owns case-insensitive user profiles and presets.

    properties (SetAccess = private)
        RootPath string = ""
        ActiveProfile struct = struct()
        ActiveFolder string = ""
    end

    methods
        function obj = VisualPresetManager(rootPath)
            obj.RootPath = string(rootPath);
            if ~exist(obj.RootPath, 'dir')
                mkdir(obj.RootPath);
            end
        end

        function profile = createUser(obj, name)
            [displayName, canonicalName] = obj.validateUserName(name);
            existing = obj.findUser(canonicalName);
            if ~isempty(fieldnames(existing))
                error('ZouLab:UserAlreadyExists', ...
                    'User %s already exists. Select it and click Open User.', ...
                    existing.display_name);
            end
            folderName = obj.userFolderName(displayName, canonicalName);
            folder = string(fullfile(obj.RootPath, folderName));
            if ~exist(folder, 'dir')
                mkdir(folder);
            end
            profile = struct( ...
                'schema_version', '1.0.0', ...
                'display_name', char(displayName), ...
                'canonical_name', char(canonicalName), ...
                'created_at', char(datetime('now', ...
                    'Format', 'yyyy-MM-dd HH:mm:ss.SSS')), ...
                'folder', char(folder));
            zoulab.SessionManager.writeJson(fullfile(folder, ...
                'profile.json'), profile);
            obj.ActiveProfile = profile;
            obj.ActiveFolder = folder;
        end

        function profile = openUser(obj, name)
            [~, canonicalName] = obj.validateUserName(name);
            profile = obj.findUser(canonicalName);
            if isempty(fieldnames(profile))
                error('ZouLab:UserNotFound', ...
                    'User %s does not exist. Enter the name and click New User.', ...
                    string(name));
            end
            obj.ActiveProfile = profile;
            obj.ActiveFolder = string(profile.folder);
        end

        function users = listUsers(obj)
            template = struct('schema_version', {}, 'display_name', {}, ...
                'canonical_name', {}, 'created_at', {}, 'folder', {});
            users = template;
            listing = dir(obj.RootPath);
            for index = 1:numel(listing)
                if ~listing(index).isdir || startsWith(listing(index).name, '.')
                    continue;
                end
                profilePath = fullfile(listing(index).folder, ...
                    listing(index).name, 'profile.json');
                if ~isfile(profilePath)
                    continue;
                end
                try
                    profile = jsondecode(fileread(profilePath));
                    if ~isfield(profile, 'display_name') || ...
                            ~isfield(profile, 'canonical_name')
                        continue;
                    end
                    profile.folder = char(string(fileparts(profilePath)));
                    users(end + 1) = profile; %#ok<AGROW>
                catch
                    % A damaged profile is ignored here and remains on disk
                    % for a developer to inspect.
                end
            end
            if ~isempty(users)
                [~, order] = sort(lower(string({users.display_name})));
                users = users(order);
            end
        end

        function saveAppSettings(obj, settings)
            obj.requireActiveUser();
            zoulab.UserSettings.saveAppSettings(obj.ActiveFolder, obj.ActiveProfile, settings);
        end

        function settings = loadAppSettings(obj)
            obj.requireActiveUser();
            settings = zoulab.UserSettings.loadAppSettings(obj.ActiveFolder);
        end

        function library = listPresets(obj)
            library = obj.builtinPresets();
            if strlength(obj.ActiveFolder) > 0
                library = [library, obj.loadUserLibrary()];
            end
        end

        function entry = getPreset(obj, name)
            library = obj.listPresets();
            match = find(strcmpi(string({library.name}), strtrim(string(name))), 1);
            if isempty(match)
                error('ZouLab:VisualPresetNotFound', ...
                    'Visual preset %s was not found.', string(name));
            end
            entry = library(match);
        end

        function entry = savePresetAs(obj, name, value)
            obj.requireActiveUser();
            name = obj.validatePresetName(name);
            library = obj.loadUserLibrary();
            allPresets = obj.listPresets();
            if any(strcmpi(string({allPresets.name}), name))
                error('ZouLab:VisualPresetAlreadyExists', ...
                    'Preset %s already exists. Use Update or choose another name.', name);
            end
            entry = obj.newPresetEntry(name, value);
            library(end + 1) = entry;
            obj.saveUserLibrary(library);
        end

        function entry = updatePreset(obj, name, value)
            obj.requireActiveUser();
            name = obj.validatePresetName(name);
            library = obj.loadUserLibrary();
            match = find(strcmpi(string({library.name}), name), 1);
            if isempty(match)
                builtin = obj.builtinPresets();
                if any(strcmpi(string({builtin.name}), name))
                    error('ZouLab:VisualPresetReadOnly', ...
                        'Built-in preset %s is read-only. Use Save As.', name);
                end
                error('ZouLab:VisualPresetNotFound', ...
                    'User preset %s was not found.', name);
            end
            library(match).value = value;
            library(match).updated_at = char(datetime('now', ...
                'Format', 'yyyy-MM-dd HH:mm:ss.SSS'));
            entry = library(match);
            obj.saveUserLibrary(library);
        end

        function entry = renamePreset(obj, oldName, newName)
            obj.requireActiveUser();
            oldName = obj.validatePresetName(oldName);
            newName = obj.validatePresetName(newName);
            library = obj.loadUserLibrary();
            match = find(strcmpi(string({library.name}), oldName), 1);
            if isempty(match)
                error('ZouLab:VisualPresetReadOnly', ...
                    'Only user presets can be renamed.');
            end
            allPresets = obj.listPresets();
            duplicate = strcmpi(string({allPresets.name}), newName) & ...
                ~strcmpi(string({allPresets.name}), oldName);
            if any(duplicate)
                error('ZouLab:VisualPresetAlreadyExists', ...
                    'Preset %s already exists.', newName);
            end
            library(match).name = char(newName);
            library(match).updated_at = char(datetime('now', ...
                'Format', 'yyyy-MM-dd HH:mm:ss.SSS'));
            entry = library(match);
            obj.saveUserLibrary(library);
        end

        function deletePreset(obj, name)
            obj.requireActiveUser();
            name = obj.validatePresetName(name);
            library = obj.loadUserLibrary();
            match = find(strcmpi(string({library.name}), name), 1);
            if isempty(match)
                error('ZouLab:VisualPresetReadOnly', ...
                    'Only user presets can be deleted.');
            end
            library(match) = [];
            obj.saveUserLibrary(library);
        end
    end

    methods (Access = private)
        function profile = findUser(obj, canonicalName)
            profile = struct();
            users = obj.listUsers();
            if isempty(users)
                return;
            end
            match = find(strcmpi(string({users.canonical_name}), ...
                string(canonicalName)), 1);
            if ~isempty(match)
                profile = users(match);
            end
        end

        function requireActiveUser(obj)
            if strlength(obj.ActiveFolder) == 0 || ...
                    isempty(fieldnames(obj.ActiveProfile))
                error('ZouLab:UserRequired', ...
                    'Create or open a user before using personalized settings.');
            end
        end

        function library = loadUserLibrary(obj)
            obj.requireActiveUser();
            library = obj.emptyLibrary();
            filePath = fullfile(obj.ActiveFolder, 'visual_presets.mat');
            if ~isfile(filePath)
                return;
            end
            loaded = load(filePath, 'library');
            if isfield(loaded, 'library') && isstruct(loaded.library)
                library = loaded.library;
            end
        end

        function saveUserLibrary(obj, library)
            save(fullfile(obj.ActiveFolder, 'visual_presets.mat'), ...
                'library', '-v7.3');
        end
    end

    methods (Static)
        function library = builtinPresets()
            four = zoulab.VisualPresetManager.defaultGratingConfig( ...
                [0 90 180 270]);
            eight = zoulab.VisualPresetManager.defaultGratingConfig( ...
                [0 45 90 135 180 225 270 315]);
            stamp = 'built-in';
            library = [struct('name', 'Random grating — 4 directions', ...
                'kind', 'visual_stimulus', 'mode', 'random_drifting_grating', ...
                'scope', 'builtin', 'builtin', true, 'value', four, ...
                'updated_at', stamp), ...
                struct('name', 'Random grating — 8 directions', ...
                'kind', 'visual_stimulus', 'mode', 'random_drifting_grating', ...
                'scope', 'builtin', 'builtin', true, 'value', eight, ...
                'updated_at', stamp)];
        end
    end

    methods (Static, Access = private)
        function [displayName, canonicalName] = validateUserName(name)
            displayName = strtrim(string(name));
            if strlength(displayName) == 0
                error('ZouLab:UserNameRequired', 'Enter a user name.');
            end
            if strlength(displayName) > 80
                error('ZouLab:UserNameTooLong', ...
                    'User name must contain 80 characters or fewer.');
            end
            canonicalName = lower(displayName);
        end

        function folderName = userFolderName(displayName, canonicalName)
            readable = regexprep(char(displayName), ...
                '[<>:"/\\|?*\x00-\x1F]', '_');
            readable = regexprep(readable, '[\. ]+$', '');
            readable = strtrim(readable);
            if isempty(readable)
                readable = 'user';
            end
            if numel(readable) > 32
                readable = readable(1:32);
            end
            bytes = unicode2native(char(canonicalName), 'UTF-8');
            digest = java.security.MessageDigest.getInstance('SHA-256');
            digest.update(bytes);
            raw = typecast(int8(digest.digest()), 'uint8');
            hash = lower(reshape(dec2hex(raw, 2).', 1, []));
            folderName = sprintf('%s__%s', readable, hash(1:16));
        end

        function name = validatePresetName(name)
            name = strtrim(string(name));
            if strlength(name) == 0
                error('ZouLab:VisualPresetNameRequired', ...
                    'Enter a preset name.');
            end
            if strlength(name) > 80
                error('ZouLab:VisualPresetNameTooLong', ...
                    'Preset name must contain 80 characters or fewer.');
            end
        end

        function entry = newPresetEntry(name, value)
            entry = struct('name', char(name), ...
                'kind', 'visual_stimulus', ...
                'mode', char(string(value.program)), ...
                'scope', 'user', 'builtin', false, ...
                'value', value, ...
                'updated_at', char(datetime('now', ...
                    'Format', 'yyyy-MM-dd HH:mm:ss.SSS')));
        end

        function library = emptyLibrary()
            library = struct('name', {}, 'kind', {}, 'mode', {}, ...
                'scope', {}, 'builtin', {}, 'value', {}, 'updated_at', {});
        end

        function config = defaultGratingConfig(angles)
            config = struct('program', 'random_drifting_grating', ...
                'screen_index', 1, 'duration_seconds', 2, ...
                'frequency_hz', 2, 'isi_seconds', 1, 'repeats', 1, ...
                'sequence', double(angles), 'amplitude', 0.5, ...
                'spatial_frequency_cpd', 0.04, ...
                'viewing_distance_cm', 9, 'screen_width_cm', 11);
        end
    end
end
