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
perfusionVolume = zeros(l, w, d, 3);

% Calculate the contrast concentrations
baseFrame = 1;
[~, startFrame] = firstSignificant(pvInputFunc);
ca = cbPlasma(artInputFunc, pvInputFunc, baseFrame, startFrame);
cp = cpPlasma(pvInputFunc, baseFrame, startFrame); 

% Calculate tau (look at Chouhan's paper for a better implementation)
[~, i1] = firstSignificant(ca);
[~, i2] = firstSignificant(cp);
dt = abs(times(2) - times(1));
delayFrames = abs(i1 - i2);
delayTime = delayFrames * dt;
tauA = delayTime;
tauP = delayTime;

% Get the linear indexes from the mask
indexList = find(mask);
[i, j, k] = ind2sub([l, w, d], indexList);

%% Fit the perfusion parameters

dispstat('', 'init');
tic; % Start the timer
for index = 1:length(indexList)
    dispstat(sprintf('%d %%', 100 * (index) / length(indexList)));
    voxel = squeeze(timeSeries(i(index), j(index), k(index), :));
    [af, dv, mtt, ~, ~, ~, ~] = fitCurve(voxel, times, ca, cp, tauA, tauP);
    perfusionVolume(i(index), j(index), k(index), :) = [af, dv, mtt];
end
toc; % Stop the timer

end