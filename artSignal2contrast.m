function [artContrast] = artSignal2contrast(artSignal, ...
    m0, flipAngle, TR, T10b, relaxivity, startFrame)
%cbPlasma Contrast concentration for signal in the arterial plasma.

artSignal = abs(artSignal);

alpha = flipAngle * pi / 180;
T10b = T10b * 1000;
R10b = 1/T10b;
Hct = 0.4;

S0b = m0 * (1 - exp(-R10b * TR) * cos(alpha)) / (1 - exp(-R10b * TR)) / ...
    sin(alpha);
R1b = log((S0b * sin(alpha) - artSignal .* cos(alpha)) ./ ...
    (S0b * sin(alpha) - artSignal)) / TR;
cbArtery = (R1b - R10b) * 1e3 / relaxivity; % Concentration in blood (mM)
artContrast = cbArtery / (1 - Hct); % Concentration in plasma (mM)
% artContrast = abs(artContrast);
artContrast(1:startFrame) = 0;

end

