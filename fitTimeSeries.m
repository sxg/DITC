function [fitPerfParams] = fitTimeSeries(timeSeries, mask, times, ...
    artInputFunc, pvInputFunc)
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

% Create output
l = size(timeSeries, 1);
w = size(timeSeries, 2);
d = size(timeSeries, 3);
t = size(timeSeries, 4);
fitPerfParams = zeros(l, w, d, 8);
fitCurves = zeros(l, w, d, t);

% Calculate the contrast concentrations
cA = concArtery(artInputFunc, pvInputFunc);
cP = concPV(pvInputFunc); 

% Calculate tauA and tauP
[artStart, ~] = findRise(cA);
[pvStart, ~] = findRise(cP);
dt = abs(times(2) - times(1));

% Get the linear indexes from the mask
indexList = find(mask);
[i, j, k] = ind2sub([l, w, d], indexList);

%% Fit the perfusion parameters

dispstat('', 'init');
tic; % Start the timer
for index = 1:length(indexList)
    dispstat(sprintf('%.2f %%', 100 * (index) / length(indexList)));
    voxel = squeeze(timeSeries(i(index), j(index), k(index), :));
    cL = concLiver(voxel);
    [liverStart, ~] = findRise(voxel);
    artDelayFrames = liverStart - artStart;
    pvDelayFrames = liverStart - pvStart;
    tauA = min(artDelayFrames * dt, 20.10);
    tauP = min(pvDelayFrames * dt, 10.05);
    [af, dv, mtt, k1a, k1p, k2, ~] = fitCurve(cL, times, cA, cP, ...
        tauA, tauP);
    fitPerfParams(i(index), j(index), k(index), :) = ...
        [af, dv, mtt, tauA, tauP, k1a, k1p, k2];
end
time = toc; % Stop the timer

% Store the fitted curves
for index = 1:length(indexList)
    [af, dv, mtt, tauA, tauP] = ...
        fitPerfParams(i(index), j(index), k(index), 1:5);
    fitCurves(i(index), j(index), k(index), :) = ...
        normc(disc(times, ca, cp, af, dv, mtt, tauA, tauP));
end

% Save the data
save('fitPerfuionVolume.mat', ...
    'fitPerfParams', 'fitCurves', 'time');

end