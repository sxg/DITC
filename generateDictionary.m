function [ D ] = generateDictionary( times, AF, PV, alpha, TR, baseFrame, frames )
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
% S0L = mean(Liver(baseFrame:baseFrame+frames)) * (1 - exp(-R10L * TR) * cos(alpha)) / (1 - exp(-R10L * TR)) / sin(alpha); %GE equation
% R1L = abs(log((S0L * sin(alpha) - Liver .* cos(alpha)) ./ (S0L * sin(alpha) - Liver)) / TR);
% CL = (R1L - R10L) * 1e3 / relaxivity; % Concentration in liver
% % CL = CL * 0.2627; %0.2627 = 0.22/mean(CL(end-5:end)); normalize the liver SI

% Tau calculation
delayFrames = abs(find(Cb_plasma ~= 0, 1) - find(CL ~= 0, 1));
timePerFrame = times(2) - times(1);
delayTime = delayFrames * timePerFrame;
tauA = delayTime;
tauP = delayTime;

% Ranges for perfusion parameters
AF_range = linspace(0, 1, 101);
DV_range = linspace(0, 1, 21);
MTT_range = linspace(1, 100, 100);
% t1_range = linspace(0, 0.02, 21); % t1 redefined as tauA
% t2_range = linspace(0, 0.02, 21); % t2 redefined as tauP

%times = times(startpoint:end);
%Cb_plasma = Cb_plasma(startpoint:end);
%Cp_plasma = Cp_plasma(startpoint:end);

dispstat('', 'init');
D = zeros(length(times), length(AF_range) * length(DV_range) * length(MTT_range));
for i_AF = 1:length(AF_range)
    for i_DV = 1:length(DV_range)
        for i_MTT = 1:length(MTT_range)
            dispstat(sprintf('%d %d %d', i_AF, i_DV, i_MTT));
            idx = sub2ind([length(AF_range), length(DV_range), length(MTT_range)], i_AF, i_DV, i_MTT);
            D(:, idx) = DISC(times, Cb_plasma, Cp_plasma, AF_range(i_AF), DV_range(i_DV), MTT_range(i_MTT), tauA, tauP);
        end
    end
end
dispstat('Done.', 'keepprev');

% Explicitly populate the dictionary with the perfusion parameters fitted
% by the least squares method
% D(:, 1) = DISC(times, Cb_plasma, Cp_plasma, 0.4145, 0.1711, 4.7196, 0.0034, 0.0028);

% Data from the unnormalized dictionary appears to be more accurate
% D = normc(D);

% Convert the 6 dimensional, non-normalized dictionary to 2 dimensions
% D = D_spread(:, :);

end

