function [fitCurves, fitErrs, fitPerfParams, fitTime] ...
    = simulateFitting(noisyCurves, times, artInputFunc, pvInputFunc, ...
    startingPerfParams, snr, saveFilePrefix)
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
validateattributes(startingPerfParams, {'numeric'}, ...
    {'vector', 'nonempty'});
validateattributes(saveFilePrefix, {'char'}, {'scalartext'});

% Create outputs
nSims = size(noisyCurves, 2);
fitCurves = NaN(size(noisyCurves));
fitErrs = NaN(1, nSims);
fitPerfParams = NaN(8, nSims); % af, dv, mtt, k1a, k1p, k2 (in order)
fitTime = NaN(1, nSims);

% Calculate the contrast concentrations
concAorta = cbPlasma(artInputFunc, pvInputFunc);
concPV = cpPlasma(pvInputFunc); 

% Calculate tau (look at Chouhan's paper for a better implementation)
% tauA = calcTauA(concAorta, concPV, times);
% tauP = tauA;
tauA = 0;
tauP = 0;

%% Run the Monte Carlo simulations

dispstat('', 'init');
for sim = 1:nSims
    dispstat(sprintf('%d %%', round(sim / nSims * 100)));
    
    % Get the noisy curve
    noisyCurve = noisyCurves(:, sim);
    tic; % Start the timer
    % Fit the curve
    [af, dv, mtt, k1a, k1p, k2, err] = lsFitCurve(noisyCurve, times, ...
        concAorta, concPV, tauA, tauP, startingPerfParams);
    t = toc; % Stop the timer
    
    % Store the data
    fitCurves(:, sim) = ...
        normc(disc(times, concAorta, concPV, af, dv, mtt, tauA, tauP));
    fitErrs(sim) = err;
    fitPerfParams(:, sim) = [af, dv, mtt, tauA, tauP, k1a, k1p, k2]';
    fitTime(sim) = t;
end

%% Save the data

fileName = sprintf('%s-SNR-%d.mat', saveFilePrefix, snr);
save(fileName, 'fitCurves', 'fitErrs', 'fitPerfParams', 'fitTime');

end

