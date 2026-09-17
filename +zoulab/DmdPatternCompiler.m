classdef DmdPatternCompiler
    %DMDPATTERNCOMPILER Compile logical masks into F4320 transfer folders.
    % The F4320 playback address/count unit is a binary bit-plane.  The
    % vendor 8-bit BMP transfer path expands every file into eight binary
    % frames, so logical files and playback frames must never be conflated.

    properties (Constant)
        SchemaVersion = "1.0.0"
        DmdWidth = 1920
        DmdHeight = 1080
        TransferBinaryBmp = 1
        TransferEightBitBmp = 2
    end

    methods (Static)
        function manifest = compileMasks(masks, outputFolder, options)
            arguments
                masks
                outputFolder {mustBeTextScalar}
                options.BitDepth (1,1) double {mustBeMember(options.BitDepth,[1 8])} = 1
                options.RequiredBinaryMultiple (1,1) double {mustBeInteger,mustBePositive} = 16
                options.Name {mustBeTextScalar} = "pattern"
                options.Source {mustBeTextScalar} = "generated"
                options.CalibrationFile {mustBeTextScalar} = ""
                options.Polarity {mustBeTextScalar} = "bit1_unknown_optical_state"
                options.PaddingMode {mustBeTextScalar} = "dark"
                options.Logger = []
            end

            logicalMasks = zoulab.DmdPatternCompiler.normalizeMasks(masks);
            paddingMode = lower(string(options.PaddingMode));
            if ~any(paddingMode == ["dark", "repeat_last", "repeat_sequence"])
                error('ZouLab:DmdPatternPaddingModeInvalid', ...
                    ['DMD padding mode must be dark, repeat_last, or ', ...
                     'repeat_sequence.']);
            end
            logicalCount = size(logicalMasks, 3);
            bitDepth = double(options.BitDepth);
            multiple = double(options.RequiredBinaryMultiple);
            binaryCountBeforePadding = logicalCount * bitDepth;
            if paddingMode == "repeat_sequence"
                fileCount = lcm(logicalCount, multiple);
                binaryCount = fileCount * bitDepth;
                paddingFiles = fileCount - logicalCount;
            else
                binaryCount = ceil(binaryCountBeforePadding / multiple) * multiple;
                if bitDepth == 1
                    fileCount = binaryCount;
                else
                    fileCount = binaryCount / 8;
                end
                paddingFiles = fileCount - logicalCount;
            end
            if bitDepth == 1
                transferType = zoulab.DmdPatternCompiler.TransferBinaryBmp;
            else
                transferType = zoulab.DmdPatternCompiler.TransferEightBitBmp;
            end

            outputFolder = string(outputFolder);
            if isfolder(outputFolder) && ~isempty(dir(fullfile(outputFolder, '*.bmp')))
                error('ZouLab:DmdPatternFolderNotEmpty', ...
                    'Compiled-pattern folder already contains BMP files: %s', ...
                    outputFolder);
            end
            if ~isfolder(outputFolder)
                mkdir(outputFolder);
            end

            fileNames = strings(fileCount, 1);
            isPadding = false(fileCount, 1);
            for fileIndex = 1:fileCount
                fileNames(fileIndex) = sprintf('%04d.bmp', fileIndex);
                pathText = fullfile(outputFolder, fileNames(fileIndex));
                if fileIndex <= logicalCount
                    imageData = logicalMasks(:, :, fileIndex);
                else
                    if paddingMode == "repeat_last"
                        imageData = logicalMasks(:, :, logicalCount);
                    elseif paddingMode == "repeat_sequence"
                        sourceIndex = mod(fileIndex - 1, logicalCount) + 1;
                        imageData = logicalMasks(:, :, sourceIndex);
                    else
                        imageData = false(size(logicalMasks, 1), ...
                            size(logicalMasks, 2));
                    end
                    isPadding(fileIndex) = true;
                end
                if bitDepth == 1
                    imwrite(logical(imageData), pathText, 'bmp');
                else
                    imwrite(uint8(imageData) .* uint8(255), pathText, 'bmp');
                end
            end

            manifest = struct( ...
                'schema_version', char(zoulab.DmdPatternCompiler.SchemaVersion), ...
                'created_utc', zoulab.BinInfo.utcNow(), ...
                'name', char(string(options.Name)), ...
                'source', char(string(options.Source)), ...
                'folder', char(outputFolder), ...
                'width', size(logicalMasks, 2), ...
                'height', size(logicalMasks, 1), ...
                'bit_depth', bitDepth, ...
                'transfer_type', transferType, ...
                'logical_mask_count', logicalCount, ...
                'upload_file_count', fileCount, ...
                'binary_frame_count_before_padding', binaryCountBeforePadding, ...
                'binary_frame_count', binaryCount, ...
                'required_binary_multiple', multiple, ...
                'padding_file_count', paddingFiles, ...
                'padding_binary_frame_count', binaryCount - binaryCountBeforePadding, ...
                'padding_mode', char(paddingMode), ...
                'padding_file_indices', find(isPadding).', ...
                'file_names', {cellstr(fileNames)}, ...
                'start_binary_position', 1, ...
                'calibration_file', char(string(options.CalibrationFile)), ...
                'polarity', char(string(options.Polarity)), ...
                'content_sha256', zoulab.DmdPatternCompiler.folderDigest( ...
                    outputFolder, fileNames));
            zoulab.SessionManager.writeJson(fullfile(outputFolder, ...
                'pattern_manifest.json'), manifest);
            if ~isempty(options.Logger)
                options.Logger.log('SUCCESS', 'DMD_PATTERN_COMPILED', ...
                    ['Name=%s | Folder=%s | BitDepth=%d | LogicalMasks=%d | ', ...
                     'UploadFiles=%d | BinaryFrames=%d | RequiredMultiple=%d | ', ...
                     ['PaddingFiles=%d | PaddingBinaryFrames=%d | PaddingMode=%s | ', ...
                      'TransferType=%d']], ...
                    string(options.Name), outputFolder, bitDepth, logicalCount, ...
                    fileCount, binaryCount, multiple, paddingFiles, ...
                    binaryCount - binaryCountBeforePadding, paddingMode, transferType);
            end
        end

        function manifest = compileBuiltIn(name, outputFolder, bitDepth, ...
                requiredBinaryMultiple, logger)
            name = upper(string(name));
            if name == "ALL_ON"
                mask = true(zoulab.DmdPatternCompiler.DmdHeight, ...
                    zoulab.DmdPatternCompiler.DmdWidth);
            elseif name == "ALL_OFF"
                mask = false(zoulab.DmdPatternCompiler.DmdHeight, ...
                    zoulab.DmdPatternCompiler.DmdWidth);
            else
                error('ZouLab:DmdBuiltInPatternInvalid', ...
                    'Built-in DMD pattern must be ALL_ON or ALL_OFF.');
            end
            manifest = zoulab.DmdPatternCompiler.compileMasks(mask, ...
                outputFolder, BitDepth=bitDepth, ...
                RequiredBinaryMultiple=requiredBinaryMultiple, ...
                Name=name, Source="built_in", PaddingMode="repeat_last", ...
                Logger=logger);
        end

        function validateManifest(manifest)
            required = {'folder','bit_depth','transfer_type', ...
                'upload_file_count','binary_frame_count', ...
                'required_binary_multiple','start_binary_position'};
            for index = 1:numel(required)
                if ~isfield(manifest, required{index})
                    error('ZouLab:DmdPatternManifestMissingField', ...
                        'DMD pattern manifest is missing %s.', required{index});
                end
            end
            if ~isfolder(string(manifest.folder))
                error('ZouLab:DmdPatternFolderMissing', ...
                    'Compiled DMD pattern folder does not exist: %s', ...
                    string(manifest.folder));
            end
            if ~any(double(manifest.bit_depth) == [1 8])
                error('ZouLab:DmdPatternBitDepthInvalid', ...
                    'DMD pattern bit depth must be 1 or 8.');
            end
            expectedTransfer = 1;
            if double(manifest.bit_depth) == 8
                expectedTransfer = 2;
            end
            if double(manifest.transfer_type) ~= expectedTransfer
                error('ZouLab:DmdPatternTransferMismatch', ...
                    'DMD transfer type does not match the manifest bit depth.');
            end
            binaryCount = double(manifest.binary_frame_count);
            multiple = double(manifest.required_binary_multiple);
            if mod(binaryCount, multiple) ~= 0
                error('ZouLab:DmdPatternBinaryMultipleInvalid', ...
                    'DMD binary frame count %d is not a multiple of %d.', ...
                    binaryCount, multiple);
            end
            files = dir(fullfile(string(manifest.folder), '*.bmp'));
            if numel(files) < double(manifest.upload_file_count)
                error('ZouLab:DmdPatternFilesMissing', ...
                    'DMD pattern has %d BMP files; manifest requires %d.', ...
                    numel(files), double(manifest.upload_file_count));
            end
        end
    end

    methods (Static, Access = private)
        function masks = normalizeMasks(value)
            if iscell(value)
                if isempty(value)
                    error('ZouLab:DmdPatternEmpty', ...
                        'At least one DMD mask is required.');
                end
                first = logical(value{1});
                masks = false(size(first, 1), size(first, 2), numel(value));
                for index = 1:numel(value)
                    current = logical(value{index});
                    if ~isequal(size(current), size(first))
                        error('ZouLab:DmdPatternSizeMismatch', ...
                            'Every DMD mask must have the same size.');
                    end
                    masks(:, :, index) = current;
                end
            elseif isnumeric(value) || islogical(value)
                masks = logical(value);
                if ismatrix(masks)
                    masks = reshape(masks, size(masks, 1), size(masks, 2), 1);
                end
            else
                error('ZouLab:DmdPatternTypeInvalid', ...
                    'DMD masks must be a numeric/logical array or cell array.');
            end
            if isempty(masks) || ndims(masks) > 3
                error('ZouLab:DmdPatternDimensionsInvalid', ...
                    'DMD masks must form a non-empty height-by-width-by-count array.');
            end
            if size(masks, 1) ~= zoulab.DmdPatternCompiler.DmdHeight || ...
                    size(masks, 2) ~= zoulab.DmdPatternCompiler.DmdWidth
                error('ZouLab:DmdPatternResolutionInvalid', ...
                    'DMD masks must be %dx%d; received %dx%d.', ...
                    zoulab.DmdPatternCompiler.DmdWidth, ...
                    zoulab.DmdPatternCompiler.DmdHeight, ...
                    size(masks, 2), size(masks, 1));
            end
        end

        function digest = folderDigest(folder, fileNames)
            engine = java.security.MessageDigest.getInstance('SHA-256');
            for index = 1:numel(fileNames)
                bytes = uint8(filereadBytes(fullfile(folder, fileNames(index))));
                engine.update(bytes);
            end
            digest = lower(reshape(dec2hex(typecast(engine.digest(), ...
                'uint8'), 2).', 1, []));

            function value = filereadBytes(pathText)
                fid = fopen(pathText, 'rb');
                if fid < 0
                    error('ZouLab:DmdPatternReadFailed', ...
                        'Cannot read compiled DMD pattern: %s', pathText);
                end
                cleanup = onCleanup(@() fclose(fid));
                value = fread(fid, Inf, '*uint8');
            end
        end
    end
end
