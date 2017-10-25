function [fitPerfParams] = fitTimeSeries(timeSeries, mask, times, ...
    artInputFunc, pvInputFunc, startingPerfParams)
%fitTimeSeries Gets perfusion parameters by least squares curve fitting.

%% Setup

% Input validation
validateattributes(timeSeries, {'numeric'}, {'nonempty', 'nonsparse'});
validateattributes(mask, {'numeric'}, {'nonempty', 'binary'});
validateattributes(times, {'numeric'}, ...
    {'nonempty', 'column', 'increasing'});
validateattributes(artInputFunc, {'numeric'}, ...
    {'nonempty', 'column'});
validateattributes(pvInputFunc, {'numeric'}, ...
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
[~, startFrame] = firstSignificant(pvInputFunc);
concAorta = cbPlasma(artInputFunc, pvInputFunc, startFrame);
concPV = cpPlasma(pvInputFunc, startFrame); 

% Calculate tauA and tauP
tauA = calcTauA(concAorta, concPV, times);
tauP = tauA;
tauA = 0;
tauP = 0;

% Get the linear indexes from the mask
indexList = find(mask);
[i, j, k] = ind2sub([l, w, d], indexList);

%% Fit the perfusion parameters

dispstat('', 'init');
t = tic; % Start the timer
for index = 1:length(indexList)
    dispstat(sprintf('%.2f%%', 100 * (index) / length(indexList)));
    voxel = squeeze(timeSeries(i(index), j(index), k(index), :));
    [~, startFrame] = firstSignificant(voxel);
    concLiver = cl(voxel, startFrame);
    [af, dv, mtt, k1a, k1p, k2, ~] = lsFitCurve(concLiver, times, ...
        concAorta, concPV, tauA, tauP, startingPerfParams);
    fitPerfParams(i(index), j(index), k(index), :) = ...
        [af, dv, mtt, tauA, tauP, k1a, k1p, k2];
    fitCurves(i(index), j(index), k(index), :) = ...
        normc(disc(times, concAorta, concPV, af, dv, mtt, tauA, tauP));
end
time = toc(t); % Stop the timer

%% Save the data
save('fitPerfuionVolume.mat', ...
    'fitPerfParams', 'fitCurves', 'time');

end