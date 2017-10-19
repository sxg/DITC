function [cA] = concArtery(artInputFunc, pvInputFunc)
%concArtery Contrast concentration in the arterial plasma.

alpha = 15 * pi / 180;
TR = 5.12;
T10b = 1.664 * 1000;
R10b = 1/T10b;
relaxivity = 6.3;
Hct = 0.4;

[artStart, ~] = findRise(artInputFunc);

S0b = mean(pvInputFunc(1:artStart)) * (1 - exp(-R10b * TR) ...
    * cos(alpha)) / (1 - exp(-R10b * TR)) / sin(alpha);
R1b = log((S0b * sin(alpha) - artInputFunc .* cos(alpha)) ./ (S0b * sin(alpha) ...
    - artInputFunc)) / TR;
cbArtery = (R1b - R10b) * 1e3 / relaxivity; % Concentration in blood (mM)
cA = cbArtery / (1 - Hct); % Concentration in plasma of artery (mM)

end

