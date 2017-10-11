function [lsCurves, fitErrs, fitPerfParams, time] ...
    = simulateFitting(noisyCurves, times, AF, PV, snr)
%simulateFitting Runs a Monte Carlo simulation of the least squares fit.

%% Setup

% Input validation
validateattributes(noisyCurves, {'numeric'}, {'2d'});
validateattributes(times, {'numeric'}, {'column'});
validateattributes(AF, {'numeric'}, {'column'});
validateattributes(PV, {'numeric'}, {'column'});
validateattributes(snr, {'numeric'}, {'scalar'});

% Create outputs
nSims = size(noisyCurves, 1);
lsCurves = NaN(size(noisyCurves));
fitErrs = NaN(nSims, 1);
fitPerfParams = NaN(nSims, 6); % af, dv, mtt, k1a, k1p, k2 (in order)
time = NaN(nSims, 1);

% Calculate the contrast concentrations
baseFrame = 1;
[~, startFrame] = firstSignificant(PV);
ca = cbPlasma(AF, PV, baseFrame, startFrame);
cp = cpPlasma(PV, baseFrame, startFrame); 

% Calculate tau
[~, i1] = firstSignificant(ca);
[~, i2] = firstSignificant(cp);
dt = times(2) - times(1);
delayFrames = abs(i1 - i2);
delayTime = delayFrames * dt;
tauA = delayTime;
tauP = delayTime;

%% Run the Monte Carlo simulations

dispstat('', 'init');
for sim = 1:nSims
    dispstat(sprintf('%d %%', round(sim / nSims * 100)));
    
    % Get noisy curve
    noisyCurve = noisyCurves(sim, :);
    tic; % Start the timer
    % Fit the curve
    [af, dv, mtt, k1a, k1p, k2, err] = fitCurve(noisyCurve, times, ca, ...
        cp, tauA, tauP);
    t = toc; % Stop the timer
    
    % Store the data
    lsCurves(sim, :) = normc(disc(times, ca, cp, af, dv, mtt, tauA, tauP));
    fitErrs(sim) = err;
    fitPerfParams(sim, :) = [af, dv, mtt, k1a, k1p, k2];
    time(sim) = t;
end

%% Save the data

fileName = sprintf('LS-SNRLevel-%d.mat', snr);
save(fileName, 'noisyCurves', 'lsCurves', 'fitErrs', 'fitPerfParams', 'time');

end

