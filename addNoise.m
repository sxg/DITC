function [noisyCurves] = addNoise(curve, numCurves, snr)
%addNoise Adds random noise to a vector.

% Input validation
validateattributes(curve, {'numeric'}, {'column', 'nonempty'});
validateattributes(numCurves, {'numeric'}, {'scalar'});
validateattributes(snr, {'numeric'}, {'scalar'});

% Create the output
noisyCurves = NaN(size(curve, 1), numCurves);

% Generate noisy curves
for i = 1:numCurves
    noisyCurves(:, i) = awgn(curve, snr);
    % Alternative approach specified by Katie
    % noisyCurves = curve + randn(size(curve)) * snr;
end

% Save the noisy curves
save(sprintf('Corrected-NoisyCurves-SNR-%d.mat', snr), 'noisyCurves');

end

