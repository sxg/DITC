function [ af, dv, mtt, k1a, k1p, k2, index, maxCorrCoef ] = ...
    matchCurve( curve, dict, nmcDict, afRange, dvRange, mttRange )
%matchCurve Finds the best curve in a dictionary matching a given curve.

%% Input validation
validateattributes(curve, {'numeric'}, {'column'});
validateattributes(dict, {'numeric'}, {'2d', 'nonempty', 'nonsparse'});
validateattributes(nmcDict, {'numeric'}, {'2d', 'nonempty', 'nonsparse'});
validateattributes(afRange, {'numeric'}, ...
    {'row', 'nonempty', 'increasing'});
validateattributes(dvRange, {'numeric'}, ...
    {'row', 'nonempty', 'increasing'});
validateattributes(mttRange, {'numeric'}, ...
    {'row', 'nonempty', 'increasing'});

%% Normalized dot product with mean centering
% corrCoefs = normr(curve - mean(curve)) * normc(dict - mean(dict));
corrCoefs = normc(curve - mean(curve))' * nmcDict;

%% Get the perfusion parameters
% Get the max correlation coefficient and its associated index
[maxCorrCoef, index] = max(corrCoefs);
[iAF, iDV, iMTT] = ind2sub([length(afRange), length(dvRange), ...
    length(mttRange)], index);
af = afRange(iAF);
dv = dvRange(iDV);
mtt = mttRange(iMTT);

% Scale the DV value
vecLenMatchCurve = sqrt(sum(dict(:, index).^2));
vecLenCurve = sqrt(sum(curve.^2));
dvScaleFactor = vecLenCurve / vecLenMatchCurve;
dv = dv * dvScaleFactor;
dv(dv > 1) = 1; % Clamp DV's value between 0 and 1 (known range)
dv(dv < 0 | isnan(dv)) = 0;

% Formula's taken from Yong's 2015 perfusion paper
k1a = af * dv / mtt;
k1p = (1 - af) * dv / mtt;
k2 = 1 / mtt;

end

