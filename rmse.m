function [err] = rmse(x, y)
%rmse Calculates the root mean square error for two vectors.

% Input validation
validateattributes(x, {'numeric'}, {'vector', 'nonempty'});
validateattributes(y, {'numeric'}, {'vector', 'nonempty'});

err = sqrt(mean((x - y).^2));

end