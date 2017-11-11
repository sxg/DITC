function [fitPerfParams] = fitTimeSeries(timeSeries, mask, times, ...
    artSignal, pvSignal, flipAngle, TR, T10b, T10p, T10l, relaxivity, ...
    scaleFactor, startFrame, addFrames, saveFileSuffix)
%fitTimeSeries Gets perfusion parameters by least squares curve fitting.

%% Setup

% Input validation
validateattributes(timeSeries, {'numeric'}, {'nonempty', 'nonsparse'});
validateattributes(mask, {'numeric'}, {'nonempty', 'binary'});
validateattributes(times, {'numeric'}, ...
    {'nonempty', 'column', 'increasing'});
validateattributes(artSignal, {'numeric'}, ...
    {'nonempty', 'column'});
validateattributes(pvSignal, {'numeric'}, ...
    {'nonempty', 'column'});

% Create output
l = size(timeSeries, 1);
w = size(timeSeries, 2);
d = size(timeSeries, 3);
t = size(timeSeries, 4);
fitPerfParamsList = zeros(l * w * d, 9);
fitPerfParams = zeros(l, w, d, 9);
fitCurvesList = zeros(l * w * d, t);
fitCurves = zeros(l, w, d, t);

% Calculate the contrast concentrations
artContrast = artSignal2contrast(artSignal, pvSignal, flipAngle, TR, ...
    T10b, relaxivity, startFrame, addFrames);
pvContrast = pvSignal2contrast(pvSignal, flipAngle, TR, T10p, ...
    relaxivity, startFrame, addFrames); 

% Get the linear indexes from the mask
voxelIndexes = find(mask);
[i, j, k] = ind2sub([l, w, d], voxelIndexes);
timeSeries = reshape(timeSeries, [], t);
voxelList = timeSeries(voxelIndexes, :);
nVoxels = size(voxelList, 1);

%% Fit the perfusion parameters

t = tic; % Start the timer
parfor_progress(nVoxels);
parfor index = 1:nVoxels
    voxel = voxelList(index, :);
    contrast = signal2contrast(voxel, flipAngle, TR, T10l, relaxivity, ...
         scaleFactor, startFrame, addFrames);
    [f, ps, v2, af, v1, t1, e, tauA, tauP, ~] = lsFitCurve(contrast', times, ...
        artContrast, pvContrast);
    fitPerfParamsList(index, :) = [f, ps, v2, af, v1, t1, e, tauA, tauP];
%     fitCurvesList(index, :) = normc(ditc([f, ps, v2, af, v1, tauA], ...
%         [artContrast, pvContrast, times]));
    parfor_progress;
end
parfor_progress(0);
time = toc(t); % Stop the timer

for index = 1:nVoxels
    fitPerfParams(i(index), j(index), k(index), :) = ...
        fitPerfParamsList(index, :);
%     fitCurves(i(index), j(index), k(index), :) = ...
%         fitCurvesList(voxelIndexes(index), :);
end

%% Save the data
save(sprintf('fitPerfusionVolume-%s.mat', saveFileSuffix), ...
    'fitPerfParams', 'time');

end