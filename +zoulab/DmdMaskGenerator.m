classdef DmdMaskGenerator
    %DMDMASKGENERATOR Camera-space ROI extraction and camera-to-DMD mapping.

    methods (Static)
        function result = fromManualPolygons(imageSize, polygons)
            validateattributes(imageSize, {'numeric'}, ...
                {'vector','numel',2,'integer','positive'});
            if ~iscell(polygons) || isempty(polygons)
                error('ZouLab:DmdManualMaskEmpty', ...
                    'At least one manual polygon is required.');
            end
            labels = zeros(imageSize(1), imageSize(2), 'uint32');
            for index = 1:numel(polygons)
                vertices = double(polygons{index});
                validateattributes(vertices, {'numeric'}, ...
                    {'2d','ncols',2,'finite','real'});
                if size(vertices, 1) < 3
                    error('ZouLab:DmdManualPolygonTooSmall', ...
                        'Each manual DMD polygon requires at least three vertices.');
                end
                mask = poly2mask(vertices(:, 1), vertices(:, 2), ...
                    imageSize(1), imageSize(2));
                labels(mask) = uint32(index);
            end
            result = zoulab.DmdMaskGenerator.fromLabelMask(labels, 'manual');
        end

        function result = fromThreshold(frame, percentileValue, minArea, expansion)
            validateattributes(frame, {'numeric'}, {'2d','nonempty','real','finite'});
            validateattributes(percentileValue, {'numeric'}, ...
                {'scalar','>=',0,'<=',100,'finite'});
            validateattributes(minArea, {'numeric'}, ...
                {'scalar','integer','nonnegative','finite'});
            validateattributes(expansion, {'numeric'}, ...
                {'scalar','integer','nonnegative','finite'});
            threshold = prctile(double(frame(:)), percentileValue);
            mask = double(frame) > threshold;
            if ~any(mask, 'all')
                mask = double(frame) >= threshold;
            end
            if minArea > 0
                mask = bwareaopen(mask, minArea);
            end
            if expansion > 0
                mask = imdilate(mask, strel('disk', expansion, 0));
            end
            labels = bwlabel(mask, 8);
            result = zoulab.DmdMaskGenerator.fromLabelMask(labels, 'threshold');
            result.threshold_percentile = percentileValue;
            result.threshold_value = threshold;
            result.minimum_area_pixels = minArea;
            result.expansion_pixels = expansion;
        end

        function result = fromFiji(folder, imageSize, outputFolder)
            if exist('import_fiji_rois_to_bwmask', 'file') ~= 2
                error('ZouLab:FijiRoiImporterMissing', ...
                    ['import_fiji_rois_to_bwmask.m is not on the MATLAB path. ', ...
                     'Add the project Tools folder before importing Fiji ROIs.']);
            end
            imported = import_fiji_rois_to_bwmask(char(folder), ...
                char(outputFolder), double(imageSize));
            if isfield(imported, 'bwmask')
                labels = imported.bwmask;
            else
                error('ZouLab:FijiRoiImportInvalid', ...
                    'Fiji ROI importer returned no bwmask.');
            end
            result = zoulab.DmdMaskGenerator.fromLabelMask(labels, 'fiji');
            result.imported = imported;
        end

        function result = fromCellpose(frame, diameter, gammaValue, ...
                cellThreshold, flowThreshold)
            if exist('cellpose', 'file') ~= 2
                error('ZouLab:CellposeUnavailable', ...
                    'MATLAB Cellpose support is not installed or not on the path.');
            end
            adjusted = imadjust(frame, [], [], gammaValue);
            model = cellpose(ExecutionEnvironment="gpu");
            labels = segmentCells2D(model, adjusted, ...
                ImageCellDiameter=diameter, CellThreshold=cellThreshold, ...
                FlowErrorThreshold=flowThreshold);
            result = zoulab.DmdMaskGenerator.fromLabelMask(labels, 'cellpose');
            result.cellpose_parameters = struct('diameter', diameter, ...
                'gamma', gammaValue, 'cell_threshold', cellThreshold, ...
                'flow_threshold', flowThreshold);
        end

        function result = fromLabelMask(labels, mode)
            labels = double(labels);
            uniqueLabels = unique(labels(:));
            uniqueLabels = uniqueLabels(uniqueLabels > 0 & isfinite(uniqueLabels));
            each = cell(1, numel(uniqueLabels));
            combined = false(size(labels));
            for index = 1:numel(uniqueLabels)
                each{index} = labels == uniqueLabels(index);
                combined = combined | each{index};
            end
            result = struct('schema_version', '1.0.0', ...
                'created_utc', zoulab.BinInfo.utcNow(), ...
                'mode', char(string(mode)), 'labels', labels, ...
                'each_camera_mask', {each}, 'combined_camera_mask', combined, ...
                'roi_count', numel(each));
        end

        function output = mapToDmd(maskResult, calibration, cameraInfo)
            zoulab.DmdCalibration.validateCalibration(calibration, ...
                cameraInfo.camera_index);
            cameraMasks = maskResult.each_camera_mask;
            dmdMasks = cell(1, numel(cameraMasks));
            combined = false(zoulab.DmdCalibration.DmdHeight, ...
                zoulab.DmdCalibration.DmdWidth);
            for index = 1:numel(cameraMasks)
                boundaries = bwboundaries(cameraMasks{index}, 'noholes');
                current = false(size(combined));
                for boundaryIndex = 1:numel(boundaries)
                    boundary = boundaries{boundaryIndex};
                    localXY = [boundary(:, 2), boundary(:, 1)];
                    dmdRC = zoulab.DmdMaskGenerator.mapPoints( ...
                        localXY, calibration, cameraInfo);
                    current = current | poly2mask(dmdRC(:, 2), dmdRC(:, 1), ...
                        size(current, 1), size(current, 2));
                end
                dmdMasks{index} = current;
                combined = combined | current;
            end
            imageSize = size(maskResult.combined_camera_mask);
            corners = [1 1; imageSize(2) 1; imageSize(2) imageSize(1); ...
                1 imageSize(1)];
            dmdCorners = zoulab.DmdMaskGenerator.mapPoints( ...
                corners, calibration, cameraInfo);
            fieldOfView = poly2mask(dmdCorners(:, 2), dmdCorners(:, 1), ...
                size(combined, 1), size(combined, 2));
            reverse = fieldOfView & ~combined;
            output = maskResult;
            output.each_dmd_mask = dmdMasks;
            output.combined_dmd_mask = combined;
            output.reverse_dmd_mask = reverse;
            output.dmd_field_of_view = fieldOfView;
            output.calibration_schema = calibration.schema_version;
            output.camera_serial = char(string(cameraInfo.serial));
            output.camera_roi = double(cameraInfo.roi(:).');
            output.camera_bin = double(cameraInfo.bin);
        end

        function dmdRC = mapPoints(localRawXY, calibration, cameraInfo)
            if isfield(calibration, 'coordinate_space') && ...
                    string(calibration.coordinate_space) == ...
                    "full_sensor_pixel_center_unbinned"
                inputXY = zoulab.DmdCalibration.displayToSensorPoints( ...
                    localRawXY, cameraInfo.roi, cameraInfo.bin, false);
            else
                inputXY = double(localRawXY);
            end
            homogeneous = [inputXY, ones(size(inputXY, 1), 1)];
            mapped = (double(calibration.T) * homogeneous.').';
            scale = mapped(:, 3);
            if any(abs(scale) < eps)
                error('ZouLab:DmdMaskTransformInvalid', ...
                    'DMD calibration mapped mask points to infinity.');
            end
            dmdRC = mapped(:, 1:2) ./ scale;
        end
    end
end
