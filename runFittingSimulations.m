function runFittingSimulations(snrList, times, artInputFunc, ...
    pvInputFunc, startingPerfParams)
%runFittingSimulations Runs all of the curve fitting simulations.

% Input validation
validateattributes(snrList, {'numeric'}, ...
    {'row', 'nonempty', 'increasing'});
validateattributes(times, {'numeric'}, ...
    {'column', 'nonempty', 'increasing'});
validateattributes(artInputFunc, {'numeric'}, {'column', 'nonempty'});
validateattributes(pvInputFunc, {'numeric'}, {'column', 'nonempty'});
validateattributes(startingPerfParams, {'numeric'}, ...
    {'vector', 'nonempty'});

for i = 1:length(snrList)
    snr = snrList(i);
    noisyCurvesFile = load(sprintf('NoisyCurves-SNR-%d.mat', snr));
    [~, ~, fitPerfParams, fitTime] = ...
        simulateFitting(noisyCurvesFile.noisyCurves, times, ...
            artInputFunc, pvInputFunc, startingPerfParams, snr);
    xlswrite(sprintf('SNR-%d.csv', snr), ...
        [fitPerfParams([1:3, 6:8], :)', fitTime']);
end

end