function [matchCurves, matchCurveIndexes, matchPerfParams, ...
    matchMaxCorrCoefs, matchTime] = simulateDictionary(noisyCurves, ...
    dict, afRange, dvRange, mttRange, snr)
%simulateDictionary Runs Monte Carlo simulations of dictionary matching.

%% Setup

% Input validation
validateattributes(noisyCurves, {'numeric'}, ...
    {'2d', 'nonempty', 'nonsparse'});
validateattributes(dict, {'numeric'}, {'2d', 'nonempty', 'nonsparse'});
validateattributes(afRange, {'numeric'}, ...
    {'row', 'nonempty', 'increasing'});
validateattributes(dvRange, {'numeric'}, ...
    {'row', 'nonempty', 'increasing'});
validateattributes(mttRange, {'numeric'}, ...
    {'row', 'nonempty', 'increasing'});
validateattributes(snr, {'numeric'}, {'scalar'});

% Create outputs
nSims = size(noisyCurves, 2);
matchCurves = NaN(size(noisyCurves));
matchCurveIndexes = NaN(nSims, 1);
matchPerfParams = NaN(6, nSims); % af, dv, mtt, k1a, k1p, k2 (in order)
matchMaxCorrCoefs = NaN(nSims, 1);
matchTime = NaN(nSims, 1);

% Generate a normalized, mean-centered dictionary
nmcDict = normc(dict - mean(dict));

%% Run the Monte Carlo simulations

dispstat('', 'init');
for sim = 1:nSims
    dispstat(sprintf('%d %%', round(sim / nSims * 100)));
    
    % Normalize and mean-center the noisy curve
    noisyCurve = normc(noisyCurves(:, sim));
    nmcNoisyCurve = noisyCurve - mean(noisyCurve);
    tic; % Start the timer
    % Match the curve
    [af, dv, mtt, k1a, k1p, k2, index, maxCorrCoef] = ...
        matchCurve(nmcNoisyCurve, nmcDict, afRange, dvRange, mttRange);
    t = toc; % Stop the timer
    
    % Store the data
    matchCurves(:, sim) = normc(dict(:, index));
    matchCurveIndexes(sim) = index;
    matchPerfParams(:, sim) = [af, dv, mtt, k1a, k1p, k2]';
    matchMaxCorrCoefs(sim) = maxCorrCoef;
    matchTime(sim) = t;
end

%% Save the data

fileName = sprintf('DictMatch-SNR-%d.mat', snr);
save(fileName, 'matchCurves', 'matchCurveIndexes', 'matchPerfParams', ...
    'matchMaxCorrCoefs', 'matchTime');

end

