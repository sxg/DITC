function [fitCurves, fitErrs, fitPerfParams, fitTime] ...
    = simulateFitting(noisyContrastCurves, times, artSignal, pvSignal, ...
    startingPerfParams, method, snr, saveFilePrefix)
%simulateFitting Runs Monte Carlo simulations of least squares fitting.

%% Setup

% Input validation
validateattributes(noisyContrastCurves, {'numeric'}, ...
    {'2d', 'nonempty', 'nonsparse'});
validateattributes(times, {'numeric'}, ...
    {'column', 'nonempty', 'increasing'});
validateattributes(artSignal, {'numeric'}, {'column', 'nonempty'});
validateattributes(pvSignal, {'numeric'}, {'column', 'nonempty'});
validateattributes(snr, {'numeric'}, {'scalar'});
validateattributes(startingPerfParams, {'numeric'}, ...
    {'vector', 'nonempty'});
validateattributes(method, {'char'}, {'scalartext'});
validateattributes(saveFilePrefix, {'char'}, {'scalartext'});

% Create outputs
nSims = size(noisyContrastCurves, 2);
fitCurves = NaN(size(noisyContrastCurves));
fitErrs = NaN(1, nSims);
fitPerfParams = NaN(8, nSims); % af, dv, mtt, k1a, k1p, k2 (in order)
fitTime = NaN(1, nSims);

% Calculate the contrast concentrations
artContrast = artSignal2contrast(artSignal, pvSignal);
pvContrast = pvSignal2contrast(pvSignal); 

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
    noisyCurve = noisyContrastCurves(:, sim);
    tic; % Start the timer
    % Fit the curve
    if strcmp(method, 'fminunc')
        [af, dv, mtt, k1a, k1p, k2] = fmuFitCurve(noisyCurve, times, ...
            artContrast, pvContrast, tauA, tauP, startingPerfParams);
    elseif strcmp(method, 'lsqcurvefit')
        [af, dv, mtt, k1a, k1p, k2, err] = lsFitCurve(noisyCurve, ...
            times, artContrast, pvContrast, tauA, tauP, ...
            startingPerfParams);
    end
    t = toc; % Stop the timer
    
    % Store the data
    fitCurves(:, sim) = ...
        disc(times, artContrast, pvContrast, af, dv, mtt, tauA, ...
        tauP);
    if strcmp(method, 'lsqcurvefit')
        fitErrs(sim) = err;
    end
    fitPerfParams(:, sim) = [af, dv, mtt, tauA, tauP, k1a, k1p, k2]';
    fitTime(sim) = t;
end

%% Save the data

fileName = sprintf('%s-SNR-%d.mat', saveFilePrefix, snr);
save(fileName, 'fitCurves', 'fitErrs', 'fitPerfParams', 'fitTime');

end

