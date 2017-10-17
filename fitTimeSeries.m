function [perfusionVolume] = fitTimeSeries(timeSeries, times, AF, PV)
%fitTimeSeries Fits perfusion parameters to time series data.

%% Setup

% Input validation
validateattributes(timeSeries, {'numeric'}, {'nonempty', 'nonsparse'});

% Create output
l = size(timeSeries, 1);
w = size(timeSeries, 2);
d = size(timeSeries, 3);
t = size(timeSeries, 4);
perfusionVolume = zeros(l, w, d, 3);

% Calculate the contrast concentrations
baseFrame = 1;
[~, startFrame] = firstSignificant(PV);
ca = cbPlasma(AF, PV, baseFrame, startFrame);
cp = cpPlasma(PV, baseFrame, startFrame); 

% Calculate tau (look at Chouhan's paper for a better implementation)
[~, i1] = firstSignificant(ca);
[~, i2] = firstSignificant(cp);
dt = abs(times(2) - times(1));
delayFrames = abs(i1 - i2);
delayTime = delayFrames * dt;
tauA = delayTime;
tauP = delayTime;

%% Fit the perfusion parameters

dispstat('', 'init');
index = 0;
tic; % Start the timer
for i = 1:l
    for j = 1:w
        for k = 1:d
            index = index + 1;
            dispstat(sprintf('%d %%', 100 * (index) / (l * w * d)));
            voxel = squeeze(timeSeries(i, j, k, :));
            if any(voxel)
                [af, dv, mtt, ~, ~, ~, ~] = fitCurve(voxel, times, ca, ...
                    cp, tauA, tauP);
                perfusionVolume(i, j, k, :) = [af, dv, mtt];
            end
       end
    end
end
toc; % Stop the timer

end