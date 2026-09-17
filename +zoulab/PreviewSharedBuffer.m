classdef PreviewSharedBuffer < handle
    %PREVIEWSHAREDBUFFER Latest-frame uint16 mailbox for two MATLAB processes.
    % The writer alternates between two memory-mapped slots. A reader only
    % accepts a slot when its begin/end sequence markers match before and
    % after copying the payload, so a partially written preview is skipped.

    properties (Constant)
        SchemaVersion uint32 = 1
        GlobalHeaderBytes double = 128
        SlotHeaderBytes double = 64
        SlotCount double = 2
        Magic uint8 = uint8('ZLPREV01')
    end

    properties (SetAccess = private)
        FilePath string = ""
        Height double = 0
        Width double = 0
        Writable logical = false
        LastSequence uint64 = uint64(0)
    end

    properties (Access = private)
        GlobalMap = []
        SlotHeaderMaps cell = {[], []}
        FrameMaps cell = {[], []}
        PayloadBytes double = 0
        NextSlot double = 1
    end

    methods (Static)
        function obj = createWriter(filePath, height, width)
            validateattributes(height, {'numeric'}, ...
                {'scalar','integer','positive','finite'});
            validateattributes(width, {'numeric'}, ...
                {'scalar','integer','positive','finite'});
            filePath = string(filePath);
            folder = string(fileparts(filePath));
            if strlength(folder) > 0 && ~exist(folder, 'dir')
                mkdir(folder);
            end
            payloadBytes = double(height) * double(width) * 2;
            totalBytes = zoulab.PreviewSharedBuffer.GlobalHeaderBytes + ...
                zoulab.PreviewSharedBuffer.SlotCount * ...
                (zoulab.PreviewSharedBuffer.SlotHeaderBytes + payloadBytes);
            zoulab.PreviewSharedBuffer.allocateFile(filePath, totalBytes);
            obj = zoulab.PreviewSharedBuffer(filePath, height, width, true);
            obj.writeGlobalBytes(1, obj.Magic);
            obj.writeGlobalScalar(9, obj.SchemaVersion, 'uint32');
            obj.writeGlobalScalar(13, uint32(height), 'uint32');
            obj.writeGlobalScalar(17, uint32(width), 'uint32');
            obj.writeGlobalScalar(21, uint32(16), 'uint32');
            obj.writeGlobalScalar(25, uint64(payloadBytes), 'uint64');
        end

        function obj = openReader(filePath)
            filePath = string(filePath);
            if ~isfile(filePath)
                error('ZouLab:PreviewSharedBufferMissing', ...
                    'Preview shared buffer does not exist: %s', filePath);
            end
            probe = memmapfile(filePath, 'Offset', 0, ...
                'Format', {'uint8', ...
                    [zoulab.PreviewSharedBuffer.GlobalHeaderBytes 1], 'bytes'}, ...
                'Repeat', 1, 'Writable', false);
            bytes = uint8(probe.Data.bytes(:));
            if numel(bytes) < zoulab.PreviewSharedBuffer.GlobalHeaderBytes || ...
                    ~isequal(bytes(1:8).', zoulab.PreviewSharedBuffer.Magic)
                error('ZouLab:PreviewSharedBufferHeaderInvalid', ...
                    'Preview shared buffer has an invalid header: %s', filePath);
            end
            version = zoulab.PreviewSharedBuffer.decodeScalar( ...
                bytes(9:12), 'uint32');
            if version ~= zoulab.PreviewSharedBuffer.SchemaVersion
                error('ZouLab:PreviewSharedBufferVersionUnsupported', ...
                    'Preview buffer schema %d is not supported.', version);
            end
            height = double(zoulab.PreviewSharedBuffer.decodeScalar( ...
                bytes(13:16), 'uint32'));
            width = double(zoulab.PreviewSharedBuffer.decodeScalar( ...
                bytes(17:20), 'uint32'));
            obj = zoulab.PreviewSharedBuffer(filePath, height, width, false);
        end
    end

    methods
        function publish(obj, frame, framesAcquired, framesAvailable, ...
                capturedDatenum)
            if ~obj.Writable
                error('ZouLab:PreviewSharedBufferReadOnly', ...
                    'A read-only PreviewSharedBuffer cannot publish frames.');
            end
            if nargin < 3 || isempty(framesAcquired)
                framesAcquired = 0;
            end
            if nargin < 4 || isempty(framesAvailable)
                framesAvailable = 0;
            end
            if nargin < 5 || isempty(capturedDatenum)
                capturedDatenum = convertTo(datetime('now'), 'datenum');
            end
            if ~isa(frame, 'uint16') || ...
                    ~isequal(size(frame), [obj.Height obj.Width])
                error('ZouLab:PreviewSharedBufferFrameInvalid', ...
                    'Preview frame must be uint16 with size [%d %d].', ...
                    obj.Height, obj.Width);
            end
            sequence = obj.LastSequence + uint64(1);
            slot = obj.NextSlot;
            obj.writeSlotScalar(slot, 1, uint64(0), 'uint64');
            obj.writeSlotScalar(slot, 9, uint64(0), 'uint64');
            % Assign the fixed-shape uint16 field directly.  The previous
            % flat uint8 mapping created one double index for every payload
            % byte on every frame and eventually exhausted MATLAB memory.
            obj.FrameMaps{slot}.Data.frame = frame;
            obj.writeSlotScalar(slot, 17, double(capturedDatenum), 'double');
            obj.writeSlotScalar(slot, 25, ...
                uint64(max(0, framesAcquired)), 'uint64');
            obj.writeSlotScalar(slot, 33, ...
                uint64(max(0, framesAvailable)), 'uint64');
            obj.writeSlotScalar(slot, 41, min(frame, [], 'all'), 'uint16');
            obj.writeSlotScalar(slot, 43, max(frame, [], 'all'), 'uint16');
            obj.writeSlotScalar(slot, 1, sequence, 'uint64');
            obj.writeSlotScalar(slot, 9, sequence, 'uint64');
            obj.LastSequence = sequence;
            obj.NextSlot = 3 - slot;
        end

        function [frame, metadata, updated] = readLatest(obj)
            frame = zeros(obj.Height, obj.Width, 'uint16');
            metadata = struct('sequence', uint64(0), ...
                'captured_datenum', NaN, 'frames_acquired', NaN, ...
                'frames_available', NaN, 'raw_min', NaN, 'raw_max', NaN);
            updated = false;
            sequences = zeros(1, obj.SlotCount, 'uint64');
            for slot = 1:obj.SlotCount
                sequences(slot) = obj.readSlotScalar(slot, 9, 'uint64');
            end
            [sequence, slot] = max(sequences);
            if sequence == 0 || sequence <= obj.LastSequence
                return;
            end
            endBefore = obj.readSlotScalar(slot, 9, 'uint64');
            beginValue = obj.readSlotScalar(slot, 1, 'uint64');
            if endBefore == 0 || beginValue ~= endBefore
                return;
            end
            capturedDatenum = obj.readSlotScalar(slot, 17, 'double');
            framesAcquired = obj.readSlotScalar(slot, 25, 'uint64');
            framesAvailable = obj.readSlotScalar(slot, 33, 'uint64');
            rawMin = obj.readSlotScalar(slot, 41, 'uint16');
            rawMax = obj.readSlotScalar(slot, 43, 'uint16');
            frameCandidate = uint16(obj.FrameMaps{slot}.Data.frame);
            endAfter = obj.readSlotScalar(slot, 9, 'uint64');
            beginAfter = obj.readSlotScalar(slot, 1, 'uint64');
            if endAfter ~= endBefore || beginAfter ~= endBefore
                return;
            end
            frame = frameCandidate;
            metadata = struct('sequence', endAfter, ...
                'captured_datenum', double(capturedDatenum), ...
                'frames_acquired', double(framesAcquired), ...
                'frames_available', double(framesAvailable), ...
                'raw_min', double(rawMin), 'raw_max', double(rawMax));
            obj.LastSequence = endAfter;
            updated = true;
        end

        function close(obj)
            obj.FrameMaps = {[], []};
            obj.SlotHeaderMaps = {[], []};
            obj.GlobalMap = [];
        end

        function delete(obj)
            obj.close();
        end
    end

    methods (Access = private)
        function obj = PreviewSharedBuffer(filePath, height, width, writable)
            obj.FilePath = string(filePath);
            obj.Height = double(height);
            obj.Width = double(width);
            obj.PayloadBytes = obj.Height * obj.Width * 2;
            obj.Writable = logical(writable);
            obj.GlobalMap = memmapfile(obj.FilePath, 'Offset', 0, ...
                'Format', {'uint8', [obj.GlobalHeaderBytes 1], 'bytes'}, ...
                'Repeat', 1, 'Writable', obj.Writable);
            for slot = 1:obj.SlotCount
                base = obj.slotOffset(slot);
                obj.SlotHeaderMaps{slot} = memmapfile(obj.FilePath, ...
                    'Offset', base, ...
                    'Format', {'uint8', [obj.SlotHeaderBytes 1], 'bytes'}, ...
                    'Repeat', 1, 'Writable', obj.Writable);
                obj.FrameMaps{slot} = memmapfile(obj.FilePath, ...
                    'Offset', base + obj.SlotHeaderBytes, ...
                    'Format', {'uint16', [obj.Height obj.Width], 'frame'}, ...
                    'Repeat', 1, 'Writable', obj.Writable);
            end
        end

        function offset = slotOffset(obj, slot)
            offset = obj.GlobalHeaderBytes + (slot - 1) * ...
                (obj.SlotHeaderBytes + obj.PayloadBytes);
        end

        function writeGlobalScalar(obj, oneBasedOffset, value, className)
            obj.writeGlobalBytes(oneBasedOffset, ...
                typecast(cast(value, className), 'uint8'));
        end

        function writeSlotScalar(obj, slot, oneBasedOffset, value, className)
            obj.writeSlotBytes(slot, oneBasedOffset, ...
                typecast(cast(value, className), 'uint8'));
        end

        function value = readSlotScalar(obj, slot, oneBasedOffset, className)
            count = zoulab.PreviewSharedBuffer.classBytes(className);
            value = zoulab.PreviewSharedBuffer.decodeScalar( ...
                obj.readSlotBytes(slot, oneBasedOffset, count), className);
        end

        function writeGlobalBytes(obj, oneBasedOffset, values)
            values = uint8(values(:));
            last = oneBasedOffset + numel(values) - 1;
            obj.GlobalMap.Data.bytes(oneBasedOffset:last) = values;
        end

        function writeSlotBytes(obj, slot, oneBasedOffset, values)
            values = uint8(values(:));
            last = oneBasedOffset + numel(values) - 1;
            obj.SlotHeaderMaps{slot}.Data.bytes(oneBasedOffset:last) = values;
        end

        function values = readSlotBytes(obj, slot, oneBasedOffset, count)
            last = oneBasedOffset + count - 1;
            values = uint8(obj.SlotHeaderMaps{slot}.Data.bytes( ...
                oneBasedOffset:last));
            values = values(:);
        end
    end

    methods (Static, Access = private)
        function allocateFile(filePath, byteCount)
            try
                fileObject = javaObject('java.io.RandomAccessFile', ...
                    char(filePath), 'rw');
                cleanup = onCleanup(@() fileObject.close()); %#ok<NASGU>
                fileObject.setLength(int64(byteCount));
            catch ME
                error('ZouLab:PreviewSharedBufferCreateFailed', ...
                    'Cannot allocate %.0f bytes for %s: %s', ...
                    byteCount, filePath, ME.message);
            end
        end

        function count = classBytes(className)
            switch string(className)
                case {"uint16","int16"}
                    count = 2;
                case {"uint32","int32","single"}
                    count = 4;
                case {"uint64","int64","double"}
                    count = 8;
                otherwise
                    error('ZouLab:PreviewSharedBufferClassUnsupported', ...
                        'Unsupported scalar class: %s', className);
            end
        end

        function value = decodeScalar(bytes, className)
            value = typecast(uint8(bytes(:)), char(className));
            value = value(1);
        end
    end
end
