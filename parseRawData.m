function [perfParams] = parseRawData(rawData, mask)
%parseRawData Parses the raw data returned from DITC fitting into results.

% Column 1 is mean, column 2 is standard deviation
nPerfParams = size(rawData, 4);
perfParams = NaN(nPerfParams, 2);

% Get the perfusion parameter slices
f = rawData(:, :, 1, 1);
ps = rawData(:, :, 1, 2);
v2 = rawData(:, :, 1, 3);
af = rawData(:, :, 1, 4);
v1 = rawData(:, :, 1, 5);
t1 = rawData(:, :, 1, 6);
e = rawData(:, :, 1, 7);
tauA = rawData(:, :, 1, 8);

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

