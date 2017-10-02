function [ af, dv, mtt, i, maxCorrCoef ] = getPerfusionParameters( ... 
    corrCoefs, afRange, dvRange, mttRange )
%getPerfusionParameters Gets the perfusion parameter values.
%   Gets the perfusion parameter values from the dictionary characteristics.

% Get the max correlation coefficient and its associated index
[maxCorrCoef, i] = max(corrCoefs);


% Get the perfusion parameters
[iAF, iDV, iMTT] = ind2sub([length(afRange), length(dvRange), ...
    length(mttRange)], i);
af = afRange(iAF);
dv = dvRange(iDV);
mtt = mttRange(iMTT);

end

