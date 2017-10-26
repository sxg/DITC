function [ dict ] = generateDictionary( times, artInputFunc, ...
    pvInputFunc, afRange, dvRange, mttRange )
%generateDictionary Generates a dictionary of perfusion parameters
%   generateDictionary generates a 2D matrix of all possible perfusion
%   curves made by all combinations of perfusion parameters. Inputs are
%   specific to each data set.

t = tic; % Start the timer

% Calculate contrast concentrations
concAorta = cbPlasma(artInputFunc, pvInputFunc);
concPV = cpPlasma(pvInputFunc);

% Calculate tau (look at Chouhan's paper for a better implementation)
tauA = calcTauA(concAorta, concPV, times);
tauP = tauA;
tauA = 0;
tauP = 0;

% Generate the dictionary
dispstat('', 'init');
dict = zeros(length(times), length(afRange) * length(dvRange) ...
    * length(mttRange));
for iAF = 1:length(afRange)
    for iDV = 1:length(dvRange)
        for iMTT = 1:length(mttRange)
            dispstat(sprintf('%.2f%%', ...
                100 * (sub2ind([length(mttRange), length(dvRange), ...
                length(afRange)], iMTT, iDV, iAF)) ...
                / (length(afRange) * length(dvRange) * length(mttRange))));
            idx = sub2ind([length(afRange), length(dvRange), ...
                length(mttRange)], iAF, iDV, iMTT);
            dict(:, idx) = disc(times, concAorta, concPV, afRange(iAF), ...
                dvRange(iDV), mttRange(iMTT), tauA, tauP);
        end
    end
end

time = toc(t);

end

