function [contrast] = signal2contrast(signal)
%cl Contrast concentration for a given signal intensity.

alpha = 15 * pi / 180;
TR = 5.12;
T10l = 800;
R10l = 1/T10l;
relaxivity = 6.3;

% liverStart = 10;
% 
% S0l = mean(signal(2:2+liverStart)) ...
%     * (1 - exp(-R10l * TR) * cos(alpha)) / (1 - exp(-R10l * TR)) ...
%     / sin(alpha);
% R1l = abs(log((S0l * sin(alpha) - signal .* cos(alpha)) ...
%     ./ (S0l * sin(alpha) - signal)) / TR);
% contrast = (R1l - R10l) * 1e3 / relaxivity;

M0 = 0.0029;
E1 = (signal - M0 * sin(alpha)) ./ (signal .* cos(alpha) - M0 .* sin(alpha));
T1l = -TR./ log(E1); 
contrast = (1/(relaxivity/1000)) .* ((1./T1l) - (1/T10l));

end
