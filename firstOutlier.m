function [y] = firstOutlier(x)
%firstOutlier First outlier in an array.

% Input Validation
validateattributes(x, {'numeric'}, {'vector'});

% Find the first outlier
outlierBools = isoutlier(x);
indexes = find(outlierBools);
y = indexes(1);

end

