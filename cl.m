function [cl] = cl(liver, baseFrame, startFrame)
%cl Contrast concentration in the liver tissue.

alpha = 15 * pi / 180;
TR = 5.12;
relaxivity = 6.3;

% CL calculation
S0L = mean(Liver(baseFrame:startFrame)) * (1 - exp(-R10L * TR) ...
    * cos(alpha)) / (1 - exp(-R10L * TR)) / sin(alpha); %GE equation
R1L = abs(log((S0L * sin(alpha) - liver .* cos(alpha)) ./ (S0L ...
    * sin(alpha) - Liver)) / TR);
cl = (R1L - R10L) * 1e3 / relaxivity; % Concentration in liver
% CL = CL * 0.2627; %0.2627 = 0.22/mean(CL(end-5:end)); normalize the liver SI

end

