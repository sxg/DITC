function [y] = addNoise(x, numCurves, snr)
%addNoise Adds random noise to a vector.

% Input validation
validateattributes(x, {'numeric'}, {'column', 'nonempty'});
validateattributes(numCurves, {'numeric'}, {'scalar'});
validateattributes(snr, {'numeric'}, {'scalar'});

% Create the output
y = NaN(size(x, 1), numCurves);

% Generate noisy curves
for i = 1:numCurves
    y(:, i) = awgn(x, snr);
    % Alternative approach specified by Katie
    % y = x + randn(size(x)) * snr;
end

end

