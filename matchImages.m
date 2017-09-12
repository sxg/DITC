function [ corrCoefs ] = matchImages( images, dict )
%matchImages Finds the best perfusion curve in the dictionary for each
%voxel in images.
%   

if size(images, 4) ~= size(dict, 1)
    error(['Error. Dimension mismatch between images (%d columns) and ' ...
        'dict (%d rows)'], size(images, 4), size(dict, 1));
end

unrolledImages = unroll(images, size(images, 4));

% Normalized dot product with mean centering
corrCoefs = normr(unrolledImages - mean(unrolledImages)) * normc(dict - mean(dict));


end

