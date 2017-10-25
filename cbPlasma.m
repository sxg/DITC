function [cbPlasma] = cbPlasma(AF, PV)
%cbPlasma Contrast concentration in the arterial plasma.

alpha = 15 * pi / 180;
TR = 5.12;
T10b = 1.664 * 1000;
R10b = 1/T10b;
relaxivity = 6.3;
Hct = 0.4;

startFrame = 10;

S0b = mean(PV(2:2+startFrame)) * (1 - exp(-R10b * TR) ...
    * cos(alpha)) / (1 - exp(-R10b * TR)) / sin(alpha);
R1b = log((S0b * sin(alpha) - AF .* cos(alpha)) ./ (S0b * sin(alpha) ...
    - AF)) / TR;
cbArtery = (R1b - R10b) * 1e3 / relaxivity; % Concentration in blood (mM)
cbPlasma = cbArtery / (1 - Hct); % Concentration in plasma of artery (mM)
% cbPlasma(1:baseFrame) = 0;

end

