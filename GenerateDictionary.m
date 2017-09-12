function [ D ] = generateDictionary( times, AF, PV, Liver, alpha, TR, baseFrame, frames )
%generateDictionary Generates a dictionary of perfusion parameters
%   generateDictionary generates a 2D matrix of all possible perfusion
%   curves made by all combinations of perfusion parameters. Inputs are
%   specific to each data set.

% Constants
%   T10 values are in milliseconds
alpha = alpha * pi / 180;
T10b = 1.664 * 1000;
T10p = 1.584 * 1000;
T10L = 0.8 * 1000;
R10b = 1/T10b; 
R10p = 1/T10p;
R10L = 1/T10L;
Hct = 0.4;
relaxivity = 6.3;

%startpoint = 2;% can get rid of some points at the beginning where there is no contrast

% Ca calculation
% Yong's code
S0b = mean(PV(baseFrame:baseFrame+frames)) * (1 - exp(-R10b * TR) * cos(alpha)) / (1 - exp(-R10b * TR)) / sin(alpha);
R1b = log((S0b * sin(alpha) - AF .* cos(alpha)) ./ (S0b * sin(alpha) - AF)) / TR;
Cb_artery = (R1b - R10b) * 1e3 / relaxivity; % Concentration in blood (mM)
Cb_plasma = Cb_artery / (1 - Hct); % Concentration in plasma of artery (mM)
Cb_plasma(1:baseFrame) = 0;

% Cpv calculation
S0p = mean(PV(baseFrame:baseFrame+frames)) * (1 - exp(-R10p * TR) * cos(alpha)) / (1 - exp(-R10p * TR)) / sin(alpha); %GE equation
R1p = log((S0p * sin(alpha) - PV .* cos(alpha)) ./ (S0p * sin(alpha) - PV)) / TR;
Cp_artery = (R1p - R10p) * 1e3 / relaxivity; % Concentration in portal vein (mM)
Cp_plasma = Cp_artery / (1 - Hct); % Concentration in plasma of portal vein (mM)
Cp_plasma(1:baseFrame) = 0;

% CL calculation
S0L = mean(Liver(baseFrame:baseFrame+frames)) * (1 - exp(-R10L * TR) * cos(alpha)) / (1 - exp(-R10L * TR)) / sin(alpha); %GE equation
R1L = abs(log((S0L * sin(alpha) - Liver .* cos(alpha)) ./ (S0L * sin(alpha) - Liver)) / TR);
CL = (R1L - R10L) * 1e3 / relaxivity; % Concentration in liver
% CL = CL * 0.2627; %0.2627 = 0.22/mean(CL(end-5:end)); normalize the liver SI

% Tau calculation
delayFrames = abs(find(Cb_plasma ~= 0, 1) - find(CL ~= 0, 1));
timePerFrame = times(2) - times(1);
delayTime = delayFrames * timePerFrame;
tauA = delayTime;
tauP = delayTime;

% Ranges for perfusion parameters
% t = linspace(0, length(times), length(times) + 1);
k1aRange = linspace(0.01, 1, 100);
k1pRange = linspace(0.01, 1, 100);
k2Range = linspace(0.01, 1, 100);

dispstat('', 'init');
D = zeros(length(times), length(k1aRange) * length(k1pRange) * length(k2Range));
for ik1a = 1:length(k1aRange)
    for ik1p = 1:length(k1pRange)
        for ik2 = 1:length(k2Range)
            dispstat(sprintf('%d %d %d', ik1a, ik1p, ik2));
            idx = sub2ind([length(k1aRange), length(k1pRange), length(k2Range)], ik1a, ik1p, ik2);
            D(:, idx) = DISC(times, Cb_plasma, Cp_plasma, k1aRange(ik1a), k1pRange(ik1p), k2Range(ik2), tauA, tauP);
        end
    end
end
dispstat('Done.', 'keepprev');

end

