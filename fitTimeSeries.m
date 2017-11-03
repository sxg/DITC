function [fitPerfParams] = fitTimeSeries(timeSeries, mask, times, ...
    artSignal, pvSignal, startingPerfParams, tauA, tauP, saveFileSuffix)
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
validateattributes(startingPerfParams, {'numeric'}, ...
    {'vector', 'nonempty'});

% Create output
l = size(timeSeries, 1);
w = size(timeSeries, 2);
d = size(timeSeries, 3);
t = size(timeSeries, 4);
fitPerfParams = zeros(l, w, d, 8);
fitCurves = zeros(l, w, d, t);

% Calculate the contrast concentrations
artContrast = artSignal2contrast(artSignal, pvSignal);
pvContrast = pvSignal2contrast(pvSignal); 

% Calculate tauA and tauP
% tauA = calcTauA(artContrast, pvContrast, times);
% tauP = tauA;

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
    [af, dv, mtt, k1a, k1p, k2, ~] = lsFitCurve(contrast, times, ...
        artContrast, pvContrast, tauA, tauP, startingPerfParams);
    fitPerfParams(i(index), j(index), k(index), :) = ...
        [af, dv, mtt, tauA, tauP, k1a, k1p, k2];
    fitCurves(i(index), j(index), k(index), :) = ...
        normc(disc(times, artContrast, pvContrast, af, dv, mtt, tauA, tauP));
end
time = toc(t); % Stop the timer

%% Save the data
save(sprintf('fitPerfuionVolume-%s.mat', saveFileSuffix), ...
    'fitPerfParams', 'fitCurves', 'time');

end