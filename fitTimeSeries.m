function [fitPerfParams] = fitTimeSeries(timeSeries, mask, times, ...
    artSignal, pvSignal, flipAngle, TR, T10b, T10p, T10l, relaxivity, ...
    scaleFactor, startFrame, endFrame, saveFileSuffix)
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
fitPerfParams = zeros(l, w, d, 7);
fitCurves = zeros(l, w, d, t);

% Calculate the contrast concentrations
artContrast = artSignal2contrast(artSignal, pvSignal, flipAngle, TR, ...
    T10b, relaxivity, startFrame, endFrame);
pvContrast = pvSignal2contrast(pvSignal, flipAngle, TR, T10p, ...
    relaxivity, startFrame, endFrame); 

% Get the linear indexes from the mask
indexList = find(mask);
[i, j, k] = ind2sub([l, w, d], indexList);

%% Fit the perfusion parameters

dispstat('', 'init');
t = tic; % Start the timer
for index = 1:length(indexList)
    progress = index / length(indexList);
    elapsedTime = toc(t) / 60;
    estimatedTime = elapsedTime / progress;
    dispstat(sprintf( ...
        ['Progress: %.2f%%\n' ...
        'Elapsed Time: %.2f min\n' ...
        'Estimated Time: %.2f min'], ...
        100 * progress, elapsedTime, estimatedTime));
    voxel = squeeze(timeSeries(i(index), j(index), k(index), :));
    contrast = signal2contrast(voxel, flipAngle, TR, T10l, relaxivity, ...
         scaleFactor, startFrame, endFrame);
    [f, ps, v2, af, v1, t1, tauA, ~] = lsFitCurve(contrast, times, ...
        artContrast, pvContrast);
    fitPerfParams(i(index), j(index), k(index), :) = ...
        [f, ps, v2, af, v1, t1, tauA];
    fitCurves(i(index), j(index), k(index), :) = ...
        normc(ditc([f, ps, v2, af, v1, tauA], ...
        [artContrast, pvContrast, times]));
end
time = toc(t); % Stop the timer

%% Save the data
save(sprintf('fitPerfusionVolume-%s.mat', saveFileSuffix), ...
    'fitPerfParams', 'fitCurves', 'time');

end