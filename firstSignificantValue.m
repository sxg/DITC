function [y, i] = firstSignificantValue(x)
%firstSignificantValue First significant non-zero value in a vector.

% Input Validation
validateattributes(x, {'numeric'}, {'vector'});

% Get the slopes of x in descending order
% xPrime = diff(x);
% [~, indexes] = sort(xPrime, 'descend');
[y, i] = max(diff(x));

end

