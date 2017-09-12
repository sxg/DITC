function [ perfParamIndexImages ] = matchImages( images, dict )
%matchImages Finds the best perfusion curve in the dictionary for each
%voxel in images.
%   

% Ensure matrices can be multiplied
if size(images, 4) ~= size(dict, 1)
    error(['Error. Dimension mismatch between images (%d columns) and ' ...
        'dict (%d rows)'], size(images, 4), size(dict, 1));
end

% Unroll images into a 2D matrix for matrix multiplication
unrolledImages = unroll(images, 4);

% Normalized dot product with mean centering
corrCoefArray = normr(unrolledImages - mean(unrolledImages)) * ...
    normc(dict - mean(dict));

% Column vector of max correlation coefficients by row
[maxCorrCoefByRow, perfParamIdx] = max(corrCoefArray, [], 2);
% Contains the correlation coefficient, k1a, k1p, and k2 in that order for
% each voxel
perfParamIndexArray = zeros(size(perfParamIdx, 1), 4);
% Get perfusion parameter indexes from correlation coefficients
dispstat('init');
for i = 1:size(maxCorrCoefByRow, 1)
    dispstat('Row: %d', i);
    % WARNING: size is hardcoded here and in generateDictionary.m
    perfParamIndexArray(i, 2:4) = ind2sub([100, 100, 100], ...
        perfParamIdx(i));
    perfParamIndexArray(i, 1) = maxCorrCoefByRow(i);
end
dispstat('Done.', 'keepprev');

% Roll the index array back into the image shape
perfParamIndexImages = roll(perfParamIndexArray, size(images, 1), ...
    size(images, 2), size(images, 3), 4);

end

