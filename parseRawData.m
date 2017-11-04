function [perfParams] = parseRawData(rawData, slice, mask)
%parseRawData Parses the raw data returned from DITC fitting into results.

% Column 1 is mean, column 2 is standard deviation
nPerfParams = size(rawData, 4);
perfParams = NaN(nPerfParams, 2);

% Get the perfusion parameter slices
f = rawData(:, :, slice, 1);
ps = rawData(:, :, slice, 2);
v2 = rawData(:, :, slice, 3);
af = rawData(:, :, slice, 4);
v1 = rawData(:, :, slice, 5);
t1 = rawData(:, :, slice, 6);
e = rawData(:, :, slice, 7);
tauA = rawData(:, :, slice, 8);

% Get the ROI
f = f(find(mask));
ps = ps(find(mask));
v2 = v2(find(mask));
af = af(find(mask));
v1 = v1(find(mask));
t1 = t1(find(mask));
e = e(find(mask));
tauA = tauA(find(mask));

% Get the mean and standard deviation
perfParams(1, :) = [mean(f), std(f)];
perfParams(2, :) = [mean(ps), std(ps)];
perfParams(3, :) = [mean(v2), std(v2)];
perfParams(4, :) = [mean(af), std(af)];
perfParams(5, :) = [mean(v1), std(v1)];
perfParams(6, :) = [mean(t1), std(t1)];
perfParams(7, :) = [mean(e), std(e)];
perfParams(8, :) = [mean(tauA), std(tauA)];

end

