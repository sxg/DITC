function runMatchingSimulations(snrList, dict, afRange, dvRange, ...
    mttRange, saveFilePrefix)
%runMatchingSimulations Runs all of the dictionary matching simulations.

% Input validation
validateattributes(snrList, {'numeric'}, ...
    {'row', 'nonempty', 'increasing'});
validateattributes(dict, {'numeric'}, ...
    {'2d', 'nonempty', 'nonsparse'});
validateattributes(afRange, {'numeric'}, ...
    {'row', 'nonempty', 'increasing'});
validateattributes(dvRange, {'numeric'}, ...
    {'row', 'nonempty', 'increasing'});
validateattributes(mttRange, {'numeric'}, ...
    {'row', 'nonempty', 'increasing'});
validateattributes(saveFilePrefix, {'char'}, {'scalartext'});

for i = 1:length(snrList)
    snr = snrList(i);
    noisyDataFile = load(sprintf('NoisyContrast-SNR-%d.mat', snr));
    [~, ~, matchPerfParams, ~, matchTime] = ...
        simulateMatching(noisyDataFile.noisyContrastCurves, dict, ...
        afRange, dvRange, mttRange, snr, saveFilePrefix);
    xlswrite(sprintf('%s-DictMatch-SNR-%d.csv', saveFilePrefix, snr), ...
        [matchPerfParams', matchTime]);
end

end