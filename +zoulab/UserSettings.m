classdef UserSettings
    %USERSETTINGS UI-independent settings persistence, migration and parsing.
    % Widget assignments stay in the App; hardware/method validation remains
    % with the existing controllers and repositories. No new defaults here.
    methods (Static)
        function item = canonicalDropDownItem(items, requested)
            items = string(items);
            index = find(strcmpi(items, string(requested)), 1, 'first');
            if isempty(index)
                item = "";
            else
                item = items(index);
            end
        end

        function roi = parseROI(textValue)
            roi = sscanf(regexprep(char(string(textValue)), '[\[\],;]', ' '), '%f').';
            validateattributes(roi, {'numeric'}, ...
                {'vector','numel',4,'integer','nonnegative'});
            roi = double(roi);
        end

        function values = parseNumericVector(textValue)
            values = sscanf(regexprep(char(string(textValue)), ...
                '[\[\],;]', ' '), '%f').';
            if isempty(values) || any(~isfinite(values))
                error('ZouLab:NumericVectorInvalid', ...
                    'Enter one or more finite numbers, for example [0 45 90].');
            end
            values = double(values);
        end

        function value = parseRgbValue(textValue, label)
            value = zoulab.UserSettings.parseNumericVector(textValue);
            if numel(value) ~= 3 || any(value < 0) || any(value > 1)
                error('ZouLab:RgbValueInvalid', ...
                    '%s must contain exactly three values from 0 to 1.', label);
            end
            value = double(value(:).');
        end

        function values = parseNumericVectorAllowEmpty(textValue)
            raw = strtrim(regexprep(char(string(textValue)), ...
                '[\[\],;]', ' '));
            if isempty(raw)
                values = zeros(1, 0);
                return;
            end
            values = sscanf(raw, '%f').';
            if any(~isfinite(values))
                error('ZouLab:NumericVectorInvalid', ...
                    'Enter finite numbers, or leave the field empty.');
            end
            values = double(values);
        end

        function validateROIForBin(roi, binFactor)
            limit = 2304 / binFactor;
            if any(roi(3:4) < 1) || roi(1) + roi(3) > limit || ...
                    roi(2) + roi(4) > limit
                error('ZouLab:ROIOutOfBounds', ...
                    'ROI %s is outside the %dx%d Bin%d image.', ...
                    mat2str(roi), limit, limit, binFactor);
            end
        end

        function [currentLight, selectedRow, migration] = ...
                migrateSavedLightTable(currentLight, savedLight, savedSettings)
            selectedRow = 1;
            legacyLaserMilliwatts = true;
            if isfield(savedSettings, 'level_semantics') && ...
                    contains(string(savedSettings.level_semantics), ...
                    'AO_percent', 'IgnoreCase', true)
                legacyLaserMilliwatts = false;
            end
            copiedIDs = zeros(1, 0);
            if iscell(savedLight) && size(savedLight, 2) >= 8
                savedIDs = cellfun(@double, savedLight(:,2));
                for row = 1:size(currentLight, 1)
                    currentID = double(currentLight{row,2});
                    sourceRow = find(savedIDs == currentID, 1);
                    if isempty(sourceRow)
                        continue;
                    end
                    currentLight{row,1} = logical(savedLight{sourceRow,1});
                    currentLight{row,4} = savedLight{sourceRow,4};
                    currentLight{row,5} = savedLight{sourceRow,5};
                    currentLight{row,6} = savedLight{sourceRow,6};
                    level = double(savedLight{sourceRow,7});
                    if legacyLaserMilliwatts && row <= 2
                        ratedMilliwatts = [50 75];
                        level = 100 * level / ratedMilliwatts(row);
                    end
                    currentLight{row,7} = min(max(level, 0), 100);
                    currentLight{row,8} = 'OFF';
                    copiedIDs(end + 1) = currentID; %#ok<AGROW>
                end
                if isfield(savedSettings, 'selected_row')
                    oldRow = min(max(1, double(savedSettings.selected_row)), ...
                        size(savedLight, 1));
                    oldID = double(savedLight{oldRow,2});
                    matched = find(cellfun(@double, currentLight(:,2)) == oldID, 1);
                    if ~isempty(matched)
                        selectedRow = matched;
                    end
                end
            end
            migration = sprintf( ...
                ['VisibleIDs=%s | HiddenUnmappedSpectraIDs=[0 1 5] | ', ...
                 'CopiedIDs=%s | LegacyLaserMilliwattsConverted=%d | ', ...
                 'StateForcedOff=1 | SelectedRow=%d'], ...
                mat2str(cellfun(@double, currentLight(:,2)).'), ...
                mat2str(copiedIDs), legacyLaserMilliwatts, selectedRow);
        end

        function [value, legacyLead] = restoreTiming(timing)
            % Preserve the existing signed-offset precedence and legacy defaults.
            value.pre = zoulab.UserSettings.fieldOr(timing, ...
                'ptb_start_offset_seconds', zoulab.UserSettings.fieldOr( ...
                timing, 'camera_pre_stim_seconds', 0));
            value.post = zoulab.UserSettings.fieldOr(timing, ...
                'ptb_end_padding_seconds', zoulab.UserSettings.fieldOr( ...
                timing, 'camera_post_stim_seconds', 0));
            legacyLead = ~isfield(timing, 'imaging_light_start_offset_seconds');
            if legacyLead
                value.lead = -zoulab.UserSettings.fieldOr(timing, 'light_lead_seconds', 1);
            else
                value.lead = timing.imaging_light_start_offset_seconds;
            end
            value.tail = zoulab.UserSettings.fieldOr(timing, ...
                'imaging_light_end_offset_seconds', zoulab.UserSettings.fieldOr( ...
                timing, 'light_tail_seconds', 1));
        end

        function saveAppSettings(folder, profile, settings)
            settings.schema_version = '1.0.0';
            settings.saved_at = char(datetime('now', ...
                'Format', 'yyyy-MM-dd HH:mm:ss.SSS'));
            settings.user = profile;
            save(fullfile(folder, 'app_settings.mat'), ...
                'settings', '-v7.3');
        end

        function settings = loadAppSettings(folder)
            settings = struct();
            filePath = fullfile(folder, 'app_settings.mat');
            if ~isfile(filePath)
                return;
            end
            loaded = load(filePath, 'settings');
            if isfield(loaded, 'settings') && isstruct(loaded.settings)
                settings = loaded.settings;
            end
        end

    end

    methods (Static, Access = private)
        function value = fieldOr( source, name, fallback)
            if isstruct(source) && isfield(source, name)
                value = source.(name);
            else
                value = fallback;
            end
        end

    end
end
