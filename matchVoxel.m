function [ corrCoefs ] = matchVoxel( voxel, dict )
%matchVoxel Finds the best perfusion curve in the dictionary for a voxel.
%   

% Make sure voxel is a row vector
localVoxel = voxel;
if ~isvector(localVoxel)
    error('Error. Input voxel must be a vector.');
elseif ~isrow(localVoxel)
    localVoxel = voxel';
end

% Normalized dot product with mean centering
corrCoefs = normr(localVoxel - mean(localVoxel)) * normc(dict - mean(dict));

end

