function [noisyCurves, fitCurves, fitCurveIndexes, fitPerfParams, ...
    fitCorrCoefs] = simulate(dict, curve, nSims, snr)
%simulate Runs a Monte Carlo simulation of the dictionary fitting.

%% Setup

% Input validation
validateattributes(dict, {'numeric'}, {'2d', 'nonempty', 'nonsparse'});
validateattributes(curve, {'numeric'}, {'vector'});
validateattributes(nSims, {'numeric'}, {'scalar'});
validateattributes(snr, {'numeric'}, {'scalar'});

% Create outputs
noisyCurves = NaN(nSims, size(dict, 1));
fitCurves = NaN(nSims, size(dict, 1));
fitCurveIndexes = NaN(nSims, 1);
fitPerfParams = NaN(nSims, 6); % af, dv, mtt, k1a, k1p, k2 (in order)
fitCorrCoefs = NaN(nSims, 1);

% Setup ranges
afRange = linspace(0, 1, 101);
dvRange = [0.1886];
mttRange = linspace(1, 100, 100);

%% Run the Monte Carlo simulations

dispstat('', 'init');
for sim = 1:nSims
    dispstat(sprintf('%d \%', round(sim / nSims * 100)));
    
    % Add noise and match the curve
    noisyCurve = addNoise(curve, snr);
    corrCoefs = matchCurve(noisyCurve, dict);
    [af, dv, mtt, index, maxCorrCoef] = getPerfusionParameters( ...
        corrCoefs, afRange, dvRange, mttRange);
    
    % Store the data
    noisyCurves(sim, :) = noisyCurves';
    fitCurves(sim, :) = dict(:, index)';
    fitCurveIndexes(sim) = index;
    fitPerfParams(sim, 1:3) = [af, dv, mtt];
    fitCorrCoefs(sim) = maxCorrCoef;
end

%% Save the data

fileName = sprintf('SNRLevel-%d.mat', snr);
save(fileName, noisyCurves, fitCurves, fitCurveIndexes, fitPerfParams, ...
    fitCorrCoefs);

end

