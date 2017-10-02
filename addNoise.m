function [y] = addNoise(x, snr)
%addNoise Adds random noise to a vector.

y = awgn(x, snr);
% Alternative approach specified by Katie
% y = x + randn(size(x)) * snr;

end

