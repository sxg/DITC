function [fitCurves, fitErrs, fitPerfParams, fitTime] ...
    = simulateFitting(noisyCurves, times, artInputFunc, pvInputFunc, snr)
%simulateFitting Runs Monte Carlo simulations of least squares fitting.

%% Setup

% Input validation
validateattributes(noisyCurves, {'numeric'}, ...
    {'2d', 'nonempty', 'nonsparse'});
validateattributes(times, {'numeric'}, ...
    {'column', 'nonempty', 'increasing'});
validateattributes(artInputFunc, {'numeric'}, {'column', 'nonempty'});
validateattributes(pvInputFunc, {'numeric'}, {'column', 'nonempty'});
validateattributes(snr, {'numeric'}, {'scalar'});

% Create outputs
nSims = size(noisyCurves, 2);
fitCurves = NaN(size(noisyCurves));
fitErrs = NaN(1, nSims);
fitPerfParams = NaN(8, nSims); % af, dv, mtt, k1a, k1p, k2 (in order)
fitTime = NaN(1, nSims);

% Calculate the contrast concentrations
baseFrame = 1;
[~, startFrame] = firstSignificant(pvInputFunc);
concAorta = cbPlasma(artInputFunc, pvInputFunc, baseFrame, startFrame);
concPV = cpPlasma(pvInputFunc, baseFrame, startFrame); 

% Calculate tau (look at Chouhan's paper for a better implementation)
[~, i1] = firstSignificant(concAorta);
[~, i2] = firstSignificant(concPV);
dt = abs(times(2) - times(1));
delayFrames = abs(i1 - i2);
delayTime = delayFrames * dt;
tauA = delayTime;
tauP = delayTime;

%% Run the Monte Carlo simulations

dispstat('', 'init');
for sim = 1:nSims
    dispstat(sprintf('%d %%', round(sim / nSims * 100)));
    
    % Get the noisy curve
    noisyCurve = noisyCurves(:, sim);
    tic; % Start the timer
    % Fit the curve
    [af, dv, mtt, k1a, k1p, k2, err] = fitCurve(noisyCurve, times, ...
        concAorta, concPV, tauA, tauP);
    t = toc; % Stop the timer
    
    % Store the data
    fitCurves(:, sim) = ...
        normc(disc(times, concAorta, concPV, af, dv, mtt, tauA, tauP));
    fitErrs(sim) = err;
    fitPerfParams(:, sim) = [af, dv, mtt, tauA, tauP, k1a, k1p, k2]';
    fitTime(sim) = t;
end

%% Save the data

fileName = sprintf('LSFit-SNR-%d.mat', snr);
save(fileName, 'fitCurves', 'fitErrs', 'fitPerfParams', 'fitTime');

end

