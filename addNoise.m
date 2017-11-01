function [noisyContrastCurves] = addNoise(contrast, nSims, snr)
%addNoise Adds random noise to a contrast curve.

% Input validation
validateattributes(contrast, {'numeric'}, {'column', 'nonempty'});
validateattributes(nSims, {'numeric'}, {'scalar'});
validateattributes(snr, {'numeric'}, {'scalar'});

% Create the outputs
noisyContrastCurves = NaN(size(contrast, 1), nSims);

% Generate noisy signals
for i = 1:nSims
    noisyContrastCurves(:, i) = awgn(contrast, snr, 'measured');
    % Alternative approach specified by Katie
    % noisySignals = signal + randn(size(signal)) * snr;
end

% Save the noisy signals
save(sprintf('NoisyContrast-SNR-%d.mat', snr), 'noisyContrastCurves', 'contrast');

end

