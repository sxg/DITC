function runMatchingSimulations(snrList, dict, afRange, dvRange, ...
    mttRange)
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

for i = 1:length(snrList)
    snr = snrList(i);
    noisyCurvesFile = load(sprintf('NoisyCurves-SNR-%d.mat', snr));
    [~, ~, matchPerfParams, matchTime] = ...
        simulateMatching(noisyCurvesFile.noisyCurves, dict, afRange, ...
        dvRange, mttRange, snr);
    xlswrite(sprintf('DictMatch-SNR-%d.csv', snr), ...
        [matchPerfParams', matchTime]);
end

end