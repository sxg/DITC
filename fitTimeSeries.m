function [perfusionVolume] = fitTimeSeries(timeSeries, mask, times, ...
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
perfusionVolume = zeros(l, w, d, 6);

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
tauList = NaN(length(indexList), 2);

%% Fit the perfusion parameters

dispstat('', 'init');
tic; % Start the timer
for index = 1:length(indexList)
    dispstat(sprintf('%d %%', 100 * (index) / length(indexList)));
    voxel = squeeze(timeSeries(i(index), j(index), k(index), :));
    cL = concLiver(voxel);
    [liverStart, ~] = findRise(voxel);
    artDelayFrames = liverStart - artStart;
    pvDelayFrames = liverStart - pvStart;
    tauA = artDelayFrames * dt;
    tauP = pvDelayFrames * dt;
    tauList(index, :) = [tauA, tauP];
    [af, dv, mtt, k1a, k1p, k2, err] = fitCurve(cL, times, cA, cP, ...
        tauA, tauP);
    perfusionVolume(i(index), j(index), k(index), :) = ...
        [af, dv, mtt, k1a, k1p, k2];
end
time = toc; % Stop the timer

% Save the data
save('fitPerfuionVolume.mat', 'perfusionVolume', 'tauList', 'time', 'err');

end