function [ corrCoefs ] = matchCurve( curve, dict )
%matchCurve Finds the best curve in a dictionary fitting a given curve.

% Input validation
validateattributes(curve, {'numeric'}, {'row'});
validateattributes(dict, {'numeric'}, {'2d', 'nonempty', 'nonsparse'});

% Normalized dot product with mean centering
corrCoefs = normr(curve - mean(curve)) * normc(dict - mean(dict));

end

