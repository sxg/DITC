function [ corrCoefs ] = matchCurve( curve, dict )
%matchCurve Finds the best curve in a dictionary fitting a given curve.

% Input validation
validateattributes(curve, {'numeric'}, {'vector'});
validateattributes(dict, {'numeric'}, {'2d', 'nonempty', 'nonsparse'});
if ~isrow(curve)
    curve = curve';
end

% Normalized dot product with mean centering
% corrCoefs = normr(curve - mean(curve)) * normc(dict - mean(dict));
corrCoefs = curve * dict;

end

