function [ maxCorrCoef, af, dv, mtt ] = getPerfusionParameters( ... 
    corrCoefs, afRange, dvRange, mttRange )
%getPerfusionParameters Gets the perfusion parameter values.
%   Gets the perfusion parameter values from the dictionary characteristics.

% Get the max correlation coefficient and its associated index(es)
% Note: correlation coefficients are read to 4 decimal places to determine
% if they're identical.
maxCorrCoef = max(corrCoefs);
indexes = find(corrCoefs == round(maxCorrCoef, 4));


% Get the perfusion parameters
[iAF, iDV, iMTT] = ind2sub([length(afRange), length(dvRange), ...
    length(mttRange)], indexes);
af = afRange(iAF);
dv = dvRange(iDV);
mtt = mttRange(iMTT);

end

