function [ D ] = generateDictionary( times, AF, PV, afRange, dvRange, mttRange )
%generateDictionary Generates a dictionary of perfusion parameters
%   generateDictionary generates a 2D matrix of all possible perfusion
%   curves made by all combinations of perfusion parameters. Inputs are
%   specific to each data set.

baseFrame = 1;
[~, startFrame] = firstSignificant(PV);

%% Ca calculation
% Yong's code
% S0b = mean(PV(baseFrame:startFrame)) * (1 - exp(-R10b * TR) * cos(alpha)) / (1 - exp(-R10b * TR)) / sin(alpha);
% R1b = log((S0b * sin(alpha) - AF .* cos(alpha)) ./ (S0b * sin(alpha) - AF)) / TR;
% Cb_artery = (R1b - R10b) * 1e3 / relaxivity; % Concentration in blood (mM)
% Cb_plasma = Cb_artery / (1 - Hct); % Concentration in plasma of artery (mM)
% Cb_plasma(1:baseFrame) = 0;
Cb_plasma = cbPlasma(AF, PV, baseFrame, startFrame);

%% Cpv calculation
% S0p = mean(PV(baseFrame:startFrame)) * (1 - exp(-R10p * TR) * cos(alpha)) / (1 - exp(-R10p * TR)) / sin(alpha); %GE equation
% R1p = log((S0p * sin(alpha) - PV .* cos(alpha)) ./ (S0p * sin(alpha) - PV)) / TR;
% Cp_artery = (R1p - R10p) * 1e3 / relaxivity; % Concentration in portal vein (mM)
% Cp_plasma = Cp_artery / (1 - Hct); % Concentration in plasma of portal vein (mM)
% Cp_plasma(1:baseFrame) = 0;
Cp_plasma = cpPlasma(AF, PV, baseFrame, startFrame);

%% CL calculation
% S0L = mean(Liver(baseFrame:baseFrame+frames)) * (1 - exp(-R10L * TR) * cos(alpha)) / (1 - exp(-R10L * TR)) / sin(alpha); %GE equation
% R1L = abs(log((S0L * sin(alpha) - Liver .* cos(alpha)) ./ (S0L * sin(alpha) - Liver)) / TR);
% CL = (R1L - R10L) * 1e3 / relaxivity; % Concentration in liver
% % CL = CL * 0.2627; %0.2627 = 0.22/mean(CL(end-5:end)); normalize the liver SI

%% Tau calculation
% Find the first outlier, and consider it the first non-zero value
[~, i1] = firstSignificant(Cb_plasma);
[~, i2] = firstSignificant(Cp_plasma);
delayFrames = abs(i1 - i2);
timePerFrame = times(2) - times(1);
delayTime = delayFrames * timePerFrame;
tauA = delayTime;
tauP = delayTime;

%% Generate the dictionary

dispstat('', 'init');
D = zeros(length(times), length(afRange) * length(dvRange) * length(mttRange));
for iAF = 1:length(afRange)
    for iDV = 1:length(dvRange)
        for iMTT = 1:length(mttRange)
            dispstat(sprintf('%d %d %d', iAF, iDV, iMTT));
            idx = sub2ind([length(afRange), length(dvRange), length(mttRange)], iAF, iDV, iMTT);
            D(:, idx) = disc(times, Cb_plasma, Cp_plasma, afRange(iAF), dvRange(iDV), mttRange(iMTT), tauA, tauP);
        end
    end
end
dispstat('Done.', 'keepprev');

end

