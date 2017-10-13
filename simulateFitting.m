function [fitCurves, fitErrs, fitPerfParams, fitTime] ...
    = simulateFitting(noisyCurves, times, AF, PV, snr)
%simulateFitting Runs Monte Carlo simulations of least squares fitting.

%% Setup

% Input validation
validateattributes(noisyCurves, {'numeric'}, ...
    {'2d', 'nonempty', 'nonsparse'});
validateattributes(times, {'numeric'}, ...
    {'column', 'nonempty', 'increasing'});
validateattributes(AF, {'numeric'}, {'column', 'nonempty'});
validateattributes(PV, {'numeric'}, {'column', 'nonempty'});
validateattributes(snr, {'numeric'}, {'scalar'});

% Create outputs
nSims = size(noisyCurves, 2);
fitCurves = NaN(size(noisyCurves));
fitErrs = NaN(nSims, 1);
fitPerfParams = NaN(6, nSims); % af, dv, mtt, k1a, k1p, k2 (in order)
fitTime = NaN(nSims, 1);

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

%% Run the Monte Carlo simulations

dispstat('', 'init');
for sim = 1:nSims
    dispstat(sprintf('%d %%', round(sim / nSims * 100)));
    
    % Normalize and mean-center the noisy curve
    noisyCurve = normc(noisyCurves(:, sim));
    nmcNoisyCurve = noisyCurve - mean(noisyCurve);
    tic; % Start the timer
    % Fit the curve
    [af, dv, mtt, k1a, k1p, k2, err] = fitCurve(nmcNoisyCurve, times, ...
        ca, cp, tauA, tauP);
    t = toc; % Stop the timer
    
    % Store the data
    fitCurves(:, sim) = ...
        normc(disc(times, ca, cp, af, dv, mtt, tauA, tauP));
    fitErrs(sim) = err;
    fitPerfParams(:, sim) = [af, dv, mtt, k1a, k1p, k2]';
    fitTime(sim) = t;
end

%% Save the data

fileName = sprintf('LSFit-SNR-%d.mat', snr);
save(fileName, 'fitCurves', 'fitErrs', 'fitPerfParams', 'fitTime');

end

