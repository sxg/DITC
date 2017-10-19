function [cL] = concLiver(liverInputFunc)
%concLiver Contrast concentration in the liver tissue.

alpha = 15 * pi / 180;
TR = 5.12;
T10l = 747;
R10l = 1/T10l;
relaxivity = 6.3;

[liverStart, ~] = findRise(liverInputFunc);

S0l = mean(liverInputFunc(1:liverStart)) ...
    * (1 - exp(-R10l * TR) * cos(alpha)) / (1 - exp(-R10l * TR)) ...
    / sin(alpha);
R1l = abs(log((S0l * sin(alpha) - liverInputFunc .* cos(alpha)) ...
    ./ (S0l * sin(alpha) - liverInputFunc)) / TR);
cL = (R1l - R10l) * 1e3 / relaxivity;

end