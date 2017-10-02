function [ af, dv, mtt, indexes, maxCorrCoef ] = getPerfusionParameters( ... 
    corrCoefs, afRange, dvRange, mttRange )
%getPerfusionParameters Gets the perfusion parameter values.
%   Gets the perfusion parameter values from the dictionary characteristics.

% Get the max correlation coefficient and its associated index(es)
maxCorrCoef = max(corrCoefs);
indexes = find(corrCoefs == maxCorrCoef);


% Get the perfusion parameters
[iAF, iDV, iMTT] = ind2sub([length(afRange), length(dvRange), ...
    length(mttRange)], indexes);
af = afRange(iAF);
dv = dvRange(iDV);
mtt = mttRange(iMTT);

end

