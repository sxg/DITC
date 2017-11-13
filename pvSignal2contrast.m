function [pvContrast] = pvSignal2contrast(pvSignal, flipAngle, TR, ...
    T10p, relaxivity, startFrame, addFrames)
%cpPlasma Contrast concentration for signal in the portal venous plasma.

pvSignal = abs(pvSignal);

alpha = flipAngle * pi / 180;
T10p = T10p * 1000;
R10p = 1/T10p;
Hct = 0.4;

S0p = mean(pvSignal(startFrame:startFrame+addFrames)) * ...
    (1 - exp(-R10p * TR) * cos(alpha)) / (1 - exp(-R10p * TR)) / ...
    sin(alpha); %GE equation
R1p = log((S0p * sin(alpha) - pvSignal .* cos(alpha)) ./ ...
    (S0p * sin(alpha) - pvSignal)) / TR;
% Concentration in portal vein (mM)
cpArtery = (R1p - R10p) * 1e3 / relaxivity; 
% Concentration in plasma of portal vein (mM)
pvContrast = cpArtery / (1 - Hct); 
% pvContrast = abs(pvContrast);
pvContrast(1:startFrame) = 0;

end

