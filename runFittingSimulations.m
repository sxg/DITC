function runFittingSimulations(snrList, times, artSignal, pvSignal, ...
    startingPerfParams, method, saveFilePrefix)
%runFittingSimulations Runs all of the curve fitting simulations.

% Input validation
validateattributes(snrList, {'numeric'}, ...
    {'row', 'nonempty', 'increasing'});
validateattributes(times, {'numeric'}, ...
    {'column', 'nonempty', 'increasing'});
validateattributes(artSignal, {'numeric'}, {'column', 'nonempty'});
validateattributes(pvSignal, {'numeric'}, {'column', 'nonempty'});
validateattributes(startingPerfParams, {'numeric'}, ...
    {'vector', 'nonempty'});
validateattributes(method, {'char'}, {'scalartext'});
validateattributes(saveFilePrefix, {'char'}, {'scalartext'});

for i = 1:length(snrList)
    snr = snrList(i);
    noisyDataFile = load(sprintf('NoisyData-SNR-%d.mat', snr));
    [~, ~, fitPerfParams, fitTime] = ...
        simulateFitting(noisyDataFile.noisyContrastCurves, times, ...
            artSignal, pvSignal, startingPerfParams, method, snr, ...
            saveFilePrefix);
    xlswrite(sprintf('%s-Fitting-SNR-%d.csv', saveFilePrefix, snr), ...
        [fitPerfParams([1:3, 6:8], :)', fitTime']);
end

end