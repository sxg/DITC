function [noisySignals] = addNoise(signal, numSignals, snr)
%addNoise Adds random noise to a signal.

% Input validation
validateattributes(signal, {'numeric'}, {'column', 'nonempty'});
validateattributes(numSignals, {'numeric'}, {'scalar'});
validateattributes(snr, {'numeric'}, {'scalar'});

% Create the outputs
noisySignals = NaN(size(signal, 1), numSignals);
noisyContrastCurves = NaN(size(signal, 1), numSignals);

% Generate noisy signals
for i = 1:numSignals
    noisySignals(:, i) = awgn(signal, snr, 'measured');
    noisyContrastCurves(:, i) = abs(signal2contrast(noisySignals(:, i)));
    % Alternative approach specified by Katie
    % noisySignals = signal + randn(size(signal)) * snr;
end

% Save the noisy signals
save(sprintf('NoisyData-SNR-%d.mat', snr), 'noisySignals', ...
    'noisyContrastCurves', 'signal');

end

