function [noisyCurves, fitCurves, fitCurveIndexes, fitPerfParams, ...
          fitCorrCoefs, time] = simulateDictionary(dict, curve, ...
          afRange, dvRange, mttRange, nSims, snr)
%simulateDictionary Runs a Monte Carlo simulation of the dictionary match.

%% Setup

% Input validation
validateattributes(dict, {'numeric'}, {'2d', 'nonempty', 'nonsparse'});
validateattributes(curve, {'numeric'}, {'column'});
validateattributes(nSims, {'numeric'}, {'scalar'});
validateattributes(snr, {'numeric'}, {'scalar'});

% Create outputs
noisyCurves = NaN(nSims, size(dict, 1));
fitCurves = NaN(nSims, size(dict, 1));
fitCurveIndexes = NaN(nSims, 1);
fitPerfParams = NaN(nSims, 6); % af, dv, mtt, k1a, k1p, k2 (in order)
fitCorrCoefs = NaN(nSims, 1);
time = NaN(nSims, 1);

% Generate a normalized, mean-centered dictionary
nmcDict = normc(dict - mean(dict));

%% Run the Monte Carlo simulations

dispstat('', 'init');
for sim = 1:nSims
    dispstat(sprintf('%d %%', round(sim / nSims * 100)));
    
    % Add noise, normalize, and mean-center
    noisyCurve = normc(addNoise(curve, snr));
    nmcNoisyCurve = noisyCurve - mean(noisyCurve);
    tic; % Start the timer
    % Match the curve
    corrCoefs = matchCurve(nmcNoisyCurve, nmcDict);
    [af, dv, mtt, k1a, k1p, k2, index, maxCorrCoef] = ... 
        getPerfusionParameters(corrCoefs, afRange, dvRange, mttRange);
    t = toc; % Stop the timer
    
    
    % Store the data
    noisyCurves(sim, :) = noisyCurve';
    fitCurves(sim, :) = normr(dict(:, index)'); % Normalize the fit curve
    fitCurveIndexes(sim) = index;
    fitPerfParams(sim, :) = [af, dv, mtt, k1a, k1p, k2];
    fitCorrCoefs(sim) = maxCorrCoef;
    time(sim) = t;
end

%% Save the data

fileName = sprintf('SNRLevel-%d.mat', snr);
save(fileName, 'noisyCurves', 'fitCurves', 'fitCurveIndexes', ...
    'fitPerfParams', 'fitCorrCoefs', 'time');

end

