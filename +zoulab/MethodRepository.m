classdef MethodRepository < handle
    %METHODREPOSITORY Stores APP-native semantic acquisition methods.
    % Repository methods never own the DAQ sample rate.  The active APP
    % compiles their time/voltage/state tables at its configured rate.

    properties (SetAccess = private)
        RootFolder string
    end

    methods
        function obj = MethodRepository(rootFolder)
            obj.RootFolder = string(rootFolder);
            if ~isfolder(obj.RootFolder)
                mkdir(obj.RootFolder);
            end
        end

        function entries = list(obj)
            entries = struct('name', {}, 'folder', {}, 'updated_at', {});
            listing = dir(obj.RootFolder);
            for index = 1:numel(listing)
                if ~listing(index).isdir || any(strcmp(listing(index).name, {'.','..'}))
                    continue;
                end
                folder = fullfile(listing(index).folder, listing(index).name);
                if ~isfile(fullfile(folder, 'method.json'))
                    continue;
                end
                entries(end + 1) = struct( ... %#ok<AGROW>
                    'name', listing(index).name, ...
                    'folder', folder, ...
                    'updated_at', datestr(listing(index).datenum, ...
                        'yyyy-mm-dd HH:MM:SS'));
            end
        end

        function [value, folder] = load(obj, name)
            folder = obj.resolve(name);
            value = jsondecode(fileread(fullfile(folder, 'method.json')));
            if ~isfield(value, 'spec') || ~isstruct(value.spec)
                error('ZouLab:MethodRepositoryInvalid', ...
                    'Repository method %s has no valid spec.', string(name));
            end
            obj.assertNoDaqRate(value.spec, "spec");
        end

        function folder = saveAs(obj, name, spec)
            name = string(zoulab.MethodRepository.cleanName(name));
            folder = string(fullfile(obj.RootFolder, name));
            if isfolder(folder)
                error('ZouLab:MethodRepositoryAlreadyExists', ...
                    'Repository method already exists: %s', name);
            end
            obj.assertNoDaqRate(spec, "spec");
            mkdir(folder);
            value = struct('schema_version', '1.0.0', ...
                'name', char(name), 'origin', 'repository', ...
                'created_at', char(datetime('now', ...
                    'Format', 'yyyy-MM-dd HH:mm:ss.SSS')), ...
                'spec', spec);
            zoulab.SessionManager.writeJson(fullfile(folder, 'method.json'), value);
        end

        function folder = resolve(obj, name)
            requested = strtrim(string(name));
            entries = obj.list();
            names = string({entries.name});
            match = find(strcmpi(names, requested), 1);
            if isempty(match)
                error('ZouLab:MethodRepositoryNotFound', ...
                    'Repository method was not found: %s', requested);
            end
            folder = string(entries(match).folder);
        end
    end

    methods (Access = private)
        function assertNoDaqRate(obj, value, pathText) %#ok<INUSL>
            if ~isstruct(value)
                return;
            end
            names = fieldnames(value);
            for index = 1:numel(names)
                name = string(names{index});
                childPath = pathText + "." + name;
                if any(strcmpi(name, ["sample_rate_hz", "daq_sample_rate", ...
                        "daq_sample_rate_hz"]))
                    error('ZouLab:MethodRepositoryOwnsDaqRate', ...
                        ['APP repository methods must not contain a DAQ ', ...
                         'sample rate (%s).'], childPath);
                end
                child = value.(names{index});
                if isstruct(child)
                    for childIndex = 1:numel(child)
                        obj.assertNoDaqRate(child(childIndex), childPath);
                    end
                end
            end
        end
    end

    methods (Static, Access = private)
        function value = cleanName(name)
            value = regexprep(char(strtrim(string(name))), ...
                '[^A-Za-z0-9_-]+', '_');
            value = regexprep(value, '^_+|_+$', '');
            if isempty(value)
                error('ZouLab:MethodRepositoryNameRequired', ...
                    'Enter a method name.');
            end
            if numel(value) > 64
                value = value(1:64);
            end
        end
    end
end
