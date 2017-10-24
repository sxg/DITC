function [err] = rmse(x, y)
%rmse Calculates the root mean square error for two vectors.

% Input validation
validateattributes(x, {'numeric'}, {'nonempty'});
validateattributes(y, {'numeric'}, {'nonempty'});

err = sqrt(mean((x(:) - y(:)).^2));

end