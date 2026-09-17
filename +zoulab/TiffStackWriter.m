classdef TiffStackWriter
    %TIFFSTACKWRITER Write uint16 movies using the laboratory stack split.

    properties (Constant)
        MaxBytesPerStack = 3.6 * 1024^3
    end

    methods (Static)
        function [files, writtenFrames] = write(movie, requestedPath, logger, progressFcn)
            if nargin < 4
                progressFcn = [];
            end
            if ~isa(movie, 'uint16')
                error('ZouLab:RecordClassMismatch', ...
                    'Continuous recording must be uint16, not %s.', class(movie));
            end
            dimensions = size(movie);
            if numel(dimensions) == 4 && dimensions(3) == 1
                movie = reshape(movie, dimensions(1), dimensions(2), dimensions(4));
            elseif numel(dimensions) > 3
                error('ZouLab:RecordShapeUnsupported', ...
                    'Expected HxWxN uint16 data; received %s.', mat2str(dimensions));
            end
            if ismatrix(movie)
                movie = reshape(movie, size(movie, 1), size(movie, 2), 1);
            end

            height = size(movie, 1);
            width = size(movie, 2);
            frameCount = size(movie, 3);
            bytesPerFrame = height * width * 2;
            framesPerStack = max(1, floor(zoulab.TiffStackWriter.MaxBytesPerStack / ...
                bytesPerFrame));
            stackCount = ceil(frameCount / framesPerStack);
            [folder, baseName] = fileparts(char(requestedPath));
            if ~exist(folder, 'dir')
                mkdir(folder);
            end
            files = strings(1, stackCount);
            writtenFrames = 0;
            logger.log('INFO', 'TIFF_STACK_WRITE_BEGIN', ...
                ['BasePath=%s | Size=[%d %d %d] | Class=uint16 | Compression=none | ', ...
                 'MaxBytesPerStack=%g | FramesPerStack=%d | StackCount=%d'], ...
                requestedPath, height, width, frameCount, ...
                zoulab.TiffStackWriter.MaxBytesPerStack, framesPerStack, stackCount);

            for stackIndex = 1:stackCount
                firstFrame = (stackIndex - 1) * framesPerStack + 1;
                lastFrame = min(stackIndex * framesPerStack, frameCount);
                stackPath = string(fullfile(folder, sprintf('%s_stack%02d.tif', ...
                    baseName, stackIndex)));
                files(stackIndex) = stackPath;
                tiffObject = [];
                try
                    tiffObject = Tiff(char(stackPath), 'w');
                    for frameIndex = firstFrame:lastFrame
                        tags = struct( ...
                            'ImageLength', height, ...
                            'ImageWidth', width, ...
                            'Photometric', Tiff.Photometric.MinIsBlack, ...
                            'BitsPerSample', 16, ...
                            'SamplesPerPixel', 1, ...
                            'RowsPerStrip', 32, ...
                            'PlanarConfiguration', Tiff.PlanarConfiguration.Chunky, ...
                            'Compression', Tiff.Compression.None, ...
                            'Software', 'ZouLabview MATLAB');
                        tiffObject.setTag(tags);
                        tiffObject.write(movie(:, :, frameIndex));
                        writtenFrames = writtenFrames + 1;
                        if frameIndex < lastFrame
                            tiffObject.writeDirectory();
                        end
                        if ~isempty(progressFcn) && ...
                                (mod(writtenFrames, 50) == 0 || writtenFrames == frameCount)
                            progressFcn(writtenFrames, frameCount, stackIndex, stackCount);
                        end
                    end
                    tiffObject.close();
                    tiffObject = [];
                    logger.log('SUCCESS', 'TIFF_STACK_FILE_COMPLETE', ...
                        'File=%s | Stack=%d/%d | Frames=%d', stackPath, ...
                        stackIndex, stackCount, lastFrame - firstFrame + 1);
                catch ME
                    if ~isempty(tiffObject)
                        try
                            tiffObject.close();
                        catch
                        end
                    end
                    logger.logException('TIFF_STACK_WRITE_FAILED', ME);
                    logger.log('ERROR', 'TIFF_STACK_PARTIAL_OUTPUT', ...
                        'File=%s | WrittenFrames=%d/%d | PartialFilePreserved=1', ...
                        stackPath, writtenFrames, frameCount);
                    rethrow(ME);
                end
            end
            logger.log('SUCCESS', 'TIFF_STACK_WRITE_COMPLETE', ...
                'Files=%s | WrittenFrames=%d | ExpectedFrames=%d', ...
                strjoin(files, ','), writtenFrames, frameCount);
        end

        function [files, writtenFrames] = writeFromBin(binFiles, ...
                requestedPath, frameSize, expectedFrames, logger, ...
                progressFcn, stopRequestedFcn, frameRange, readOptions)
            if nargin < 6
                progressFcn = [];
            end
            if nargin < 7
                stopRequestedFcn = [];
            end
            if nargin < 8
                frameRange = [];
            end
            if nargin < 9 || isempty(readOptions)
                readOptions = struct('mode', 'fread', ...
                    'buffer_bytes', 64 * 1024^2);
            end
            binFiles = string(binFiles(:).');
            frameSize = double(frameSize(:).');
            if isempty(binFiles) || numel(frameSize) ~= 2 || ...
                    any(frameSize < 1) || any(~isfinite(frameSize))
                error('ZouLab:BinConversionInputInvalid', ...
                    'BIN conversion requires files and a finite [height width].');
            end
            bytesPerFrame = prod(frameSize) * 2;
            readMode = lower(string(readOptions.mode));
            if ~any(readMode == ["fread","memmap"])
                error('ZouLab:TiffReadModeInvalid', ...
                    'TIFF BIN read mode must be fread or memmap, not %s.', ...
                    readMode);
            end
            [~, ~, hostEndian] = computer;
            if readMode == "memmap" && hostEndian ~= 'L'
                error('ZouLab:TiffMemmapEndianUnsupported', ...
                    ['The BIN format is little-endian; memmap conversion is ', ...
                     'only enabled on little-endian hosts.']);
            end
            bufferBytes = double(readOptions.buffer_bytes);
            validateattributes(bufferBytes, {'numeric'}, ...
                {'scalar','finite','positive'});
            chunkFrames = max(1, floor(bufferBytes / bytesPerFrame));
            progressIntervalFrames = 50;
            if isfield(readOptions, 'progress_interval_frames')
                progressIntervalFrames = double( ...
                    readOptions.progress_interval_frames);
                validateattributes(progressIntervalFrames, {'numeric'}, ...
                    {'scalar','finite','integer','positive'});
            end
            framesPerFile = zeros(1, numel(binFiles));
            for fileIndex = 1:numel(binFiles)
                info = dir(binFiles(fileIndex));
                if isempty(info)
                    error('ZouLab:BinConversionFileMissing', ...
                        'BIN file is missing: %s', binFiles(fileIndex));
                end
                if mod(double(info.bytes), bytesPerFrame) ~= 0
                    error('ZouLab:BinConversionSizeMismatch', ...
                        ['BIN size %.0f is not divisible by the %d-byte frame ', ...
                         'size: %s'], double(info.bytes), bytesPerFrame, ...
                        binFiles(fileIndex));
                end
                framesPerFile(fileIndex) = double(info.bytes) / bytesPerFrame;
            end
            sourceFrameCount = sum(framesPerFile);
            if isfinite(expectedFrames) && sourceFrameCount ~= expectedFrames
                error('ZouLab:BinConversionFrameCountMismatch', ...
                    'BIN contains %d frames but %d were expected.', ...
                    sourceFrameCount, expectedFrames);
            end
            if isempty(frameRange)
                frameRange = [1 sourceFrameCount];
            end
            frameRange = double(frameRange(:).');
            if numel(frameRange) ~= 2 || any(~isfinite(frameRange)) || ...
                    any(mod(frameRange, 1) ~= 0) || frameRange(1) < 1 || ...
                    frameRange(2) < frameRange(1) || ...
                    frameRange(2) > sourceFrameCount
                error('ZouLab:BinConversionFrameRangeInvalid', ...
                    ['Selected global frame range must be integer [first last] ', ...
                     'inside 1..%d; received %s.'], sourceFrameCount, ...
                    mat2str(frameRange));
            end
            frameCount = frameRange(2) - frameRange(1) + 1;
            height = frameSize(1);
            width = frameSize(2);
            framesPerStack = max(1, floor( ...
                zoulab.TiffStackWriter.MaxBytesPerStack / bytesPerFrame));
            stackCount = ceil(frameCount / framesPerStack);
            [folder, baseName] = fileparts(char(requestedPath));
            if ~exist(folder, 'dir')
                mkdir(folder);
            end
            files = strings(1, stackCount);
            writtenFrames = 0;
            currentStack = 0;
            framesInStack = 0;
            tiffObject = [];
            logger.log('INFO', 'BIN_TO_TIFF_CONVERSION_BEGIN', ...
                ['BinFiles=%s | OutputBase=%s | FrameSize=%s | ', ...
                 'SourceFrames=%d | SelectedRange=%s | OutputFrames=%d | ', ...
                 'Compression=none | ReadMode=%s | BufferBytes=%.0f | ', ...
                 'ChunkFrames=%d | ', ...
                 'SourceDeleteOwnedByCallerAfterUnitVerification=1'], ...
                strjoin(binFiles, ','), requestedPath, mat2str(frameSize), ...
                sourceFrameCount, mat2str(frameRange), frameCount, ...
                readMode, bufferBytes, chunkFrames);
            try
                globalFileStart = 1;
                for fileIndex = 1:numel(binFiles)
                    globalFileEnd = globalFileStart + ...
                        framesPerFile(fileIndex) - 1;
                    overlapStart = max(frameRange(1), globalFileStart);
                    overlapEnd = min(frameRange(2), globalFileEnd);
                    if overlapEnd < overlapStart
                        globalFileStart = globalFileEnd + 1;
                        continue;
                    end
                    firstLocalFrame = overlapStart - globalFileStart + 1;
                    fid = -1;
                    mapped = [];
                    fileCleanup = [];
                    if readMode == "memmap"
                        mapped = memmapfile(char(binFiles(fileIndex)), ...
                            'Format', 'uint16', 'Writable', false);
                    else
                        fid = fopen(binFiles(fileIndex), 'r', 'ieee-le');
                        if fid < 0
                            error('ZouLab:BinConversionOpenFailed', ...
                                'Cannot open BIN file: %s', ...
                                binFiles(fileIndex));
                        end
                        fileCleanup = onCleanup(@() fclose(fid));
                        seekStatus = fseek(fid, ...
                            (firstLocalFrame - 1) * bytesPerFrame, 'bof');
                        if seekStatus ~= 0
                            error('ZouLab:BinConversionSeekFailed', ...
                                'Cannot seek to local frame %d in %s.', ...
                                firstLocalFrame, binFiles(fileIndex));
                        end
                    end
                    remaining = overlapEnd - overlapStart + 1;
                    localFramesRead = 0;
                    while remaining > 0
                        if ~isempty(stopRequestedFcn) && stopRequestedFcn()
                            error('ZouLab:TiffConversionStopped', ...
                                'TIFF conversion was stopped; source BIN is retained.');
                        end
                        take = min(chunkFrames, remaining);
                        if readMode == "memmap"
                            firstValue = (firstLocalFrame + ...
                                localFramesRead - 1) * height * width + 1;
                            lastValue = firstValue + ...
                                height * width * take - 1;
                            values = mapped.Data(firstValue:lastValue);
                            readCount = numel(values);
                        else
                            [values, readCount] = fread(fid, ...
                                [height * width take], '*uint16', 0, ...
                                'ieee-le');
                        end
                        if readCount ~= height * width * take
                            error('ZouLab:BinConversionShortRead', ...
                                ['Read %d of %d uint16 values from %s at ', ...
                                 'source frame %d.'], readCount, ...
                                height * width * take, binFiles(fileIndex), ...
                                firstLocalFrame + localFramesRead);
                        end
                        frames = reshape(values, height, width, take);
                        for localFrame = 1:take
                            if isempty(tiffObject) || framesInStack == framesPerStack
                                if ~isempty(tiffObject)
                                    tiffObject.close();
                                    tiffObject = [];
                                    logger.log('SUCCESS', ...
                                        'TIFF_STACK_FILE_COMPLETE', ...
                                        'File=%s | Stack=%d/%d | Frames=%d', ...
                                        files(currentStack), currentStack, ...
                                        stackCount, framesInStack);
                                end
                                currentStack = currentStack + 1;
                                framesInStack = 0;
                                stackPath = string(fullfile(folder, sprintf( ...
                                    '%s_stack%02d.tif', baseName, currentStack)));
                                files(currentStack) = stackPath;
                                tiffObject = Tiff(char(stackPath), 'w');
                            elseif framesInStack > 0
                                tiffObject.writeDirectory();
                            end
                            tiffObject.setTag(zoulab.TiffStackWriter.tags( ...
                                height, width));
                            tiffObject.write(frames(:, :, localFrame));
                            framesInStack = framesInStack + 1;
                            writtenFrames = writtenFrames + 1;
                            if ~isempty(progressFcn) && ...
                                (mod(writtenFrames, progressIntervalFrames) == 0 || ...
                                    writtenFrames == frameCount)
                                progressFcn(writtenFrames, frameCount, ...
                                    currentStack, stackCount);
                            end
                        end
                        remaining = remaining - take;
                        localFramesRead = localFramesRead + take;
                    end
                    if ~isempty(fileCleanup)
                        clear fileCleanup
                    end
                    mapped = [];
                    globalFileStart = globalFileEnd + 1;
                end
                if ~isempty(tiffObject)
                    tiffObject.close();
                    tiffObject = [];
                    logger.log('SUCCESS', 'TIFF_STACK_FILE_COMPLETE', ...
                        'File=%s | Stack=%d/%d | Frames=%d', ...
                        files(currentStack), currentStack, stackCount, ...
                        framesInStack);
                end
            catch ME
                if ~isempty(tiffObject)
                    try
                        tiffObject.close();
                    catch
                    end
                end
                logger.logException('BIN_TO_TIFF_CONVERSION_FAILED', ME);
                logger.log('ERROR', 'TIFF_STACK_PARTIAL_OUTPUT', ...
                    ['Files=%s | WrittenFrames=%d/%d | ', ...
                     'SourceBinRetained=1'], strjoin(files(files ~= ""), ','), ...
                    writtenFrames, frameCount);
                rethrow(ME);
            end
            if writtenFrames ~= frameCount || numel(files) ~= stackCount || ...
                    any(~isfile(files))
                error('ZouLab:BinConversionVerificationFailed', ...
                    ['TIFF conversion verification failed: written=%d, ', ...
                     'expected=%d, files=%d/%d. Source BIN is retained.'], ...
                    writtenFrames, frameCount, sum(isfile(files)), ...
                    stackCount);
            end
            logger.log('SUCCESS', 'BIN_TO_TIFF_CONVERSION_COMPLETE', ...
                'Files=%s | WrittenFrames=%d | ExpectedFrames=%d', ...
                strjoin(files, ','), writtenFrames, frameCount);
        end

        function [files, writtenFrames, binFiles] = writeFromBinInfo( ...
                infoFiles, requestedPath, logger, progressFcn, ...
                stopRequestedFcn, frameRange, readOptions)
            if nargin < 4
                progressFcn = [];
            end
            if nargin < 5
                stopRequestedFcn = [];
            end
            if nargin < 6
                frameRange = [];
            end
            if nargin < 7
                readOptions = [];
            end
            [~, binFiles, frameSize, frameCount] = ...
                zoulab.BinInfo.loadAndValidate(infoFiles);
            logger.log('INFO', 'BIN_INFO_VALIDATED_FOR_TIFF', ...
                ['InfoFiles=%s | BinFiles=%s | FrameSize=%s | ', ...
                 'Frames=%d | DataType=uint16 | ByteOrder=ieee-le'], ...
                strjoin(string(infoFiles), ','), strjoin(binFiles, ','), ...
                mat2str(frameSize), frameCount);
            [files, writtenFrames] = zoulab.TiffStackWriter.writeFromBin( ...
                binFiles, requestedPath, frameSize, frameCount, logger, ...
                progressFcn, stopRequestedFcn, frameRange, readOptions);
        end

        function value = tags(height, width)
            value = struct( ...
                'ImageLength', height, ...
                'ImageWidth', width, ...
                'Photometric', Tiff.Photometric.MinIsBlack, ...
                'BitsPerSample', 16, ...
                'SamplesPerPixel', 1, ...
                'RowsPerStrip', 32, ...
                'PlanarConfiguration', Tiff.PlanarConfiguration.Chunky, ...
                'Compression', Tiff.Compression.None, ...
                'Software', 'ZouLabview MATLAB');
        end
    end
end
