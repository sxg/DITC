function [fitPerfParams] = fitTimeSeries(timeSeries, mask, times, ...
    artSignal, pvSignal, saveFileSuffix)
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
artContrast = artSignal2contrast(artSignal, pvSignal);
pvContrast = pvSignal2contrast(pvSignal); 

% Get the linear indexes from the mask
indexList = find(mask);
[i, j, k] = ind2sub([l, w, d], indexList);

%% Fit the perfusion parameters

dispstat('', 'init');
t = tic; % Start the timer
for index = 1:length(indexList)
    dispstat(sprintf('%.2f%%', 100 * (index) / length(indexList)));
    voxel = squeeze(timeSeries(i(index), j(index), k(index), :));
    contrast = signal2contrast(voxel);
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