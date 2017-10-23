function [cpPlasma] = cpPlasma(PV, baseFrame, startFrame)
%cpPlasma Contrast concentration in the portal venous plasma.

alpha = 15 * pi / 180;
TR = 5.12;
T10p = 1.584 * 1000;
R10p = 1/T10p;
relaxivity = 6.3;
Hct = 0.4;

S0p = mean(PV(baseFrame:startFrame)) * (1 - exp(-R10p * TR) ...
    * cos(alpha)) / (1 - exp(-R10p * TR)) / sin(alpha); %GE equation
R1p = log((S0p * sin(alpha) - PV .* cos(alpha)) ./ (S0p * sin(alpha) ...
    - PV)) / TR;
% Concentration in portal vein (mM)
cpArtery = (R1p - R10p) * 1e3 / relaxivity; 
% Concentration in plasma of portal vein (mM)
cpPlasma = cpArtery / (1 - Hct); 
% cpPlasma(1:baseFrame) = 0;

end

