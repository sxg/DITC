function [matchPerfParams, time] = matchTimeSeries(timeSeries, mask, ...
    dict, afRange, dvRange, mttRange, times)
%matchTimeSeries Gets perfusion parameters by dictionary matching.

%% Setup

% Input validation
validateattributes(timeSeries, {'numeric'}, {'nonempty', 'nonsparse'});
validateattributes(mask, {'numeric'}, {'nonempty', 'binary'});
validateattributes(dict, {'numeric'}, {'nonempty', 'nonsparse'});
validateattributes(afRange, {'numeric'}, ...
    {'row', 'nonempty', 'increasing'});

validateattributes(dvRange, {'numeric'}, ...
    {'row', 'nonempty', 'increasing'});
validateattributes(mttRange, {'numeric'}, ...
    {'row', 'nonempty', 'increasing'});
validateattributes(times, {'numeric'}, ...
    {'nonempty', 'column', 'increasing'});

% Get dimensions
l = size(timeSeries, 1);
w = size(timeSeries, 2);
d = size(timeSeries, 3);
t = size(timeSeries, 4);

% Unroll voxels
voxelIndexes = find(mask);
[i, j, k] = ind2sub([l, w, d], voxelIndexes);
timeSeries = reshape(timeSeries, [], t);
voxelList = timeSeries(voxelIndexes, :);
nVoxels = size(voxelList, 1);
nEntries = size(dict, 2);

%% Match the perfusion parameters
tic; % Start the timer

% Normalize and mean center the data
nmcVoxelList = normr(voxelList - mean(voxelList, 2));
nmcDict = normc(dict - mean(dict));

% Chunk the voxels
factors = divisors(nVoxels);
chunkSize = 1;
for chunkSize = factors(end:-1:1)
    if chunkSize * nEntries * 4 / 1e9 < 16
        break;
    end
end

dispstat('', 'init');
for chunk = 1:chunkSize:size(nmcVoxelList, 1)
    dispstat(sprintf('%.2f%%', ...
        100 * chunk / size(nmcVoxelList, 2)));
    corrCoefs = nmcVoxelList(chunk:chunk+chunkSize-1, :) ...
        * nmcDict;
    save(sprintf('corrCoefs-chunk-%d.mat', chunk), 'corrCoefs');
end

% Get the perfusion parameters
dictIndex = NaN(size(voxelList, 1), 1);
matchPerfParams = single(NaN(l, w, d, 6));

tic;
dispstat('', 'init');
for chunk = 1:chunkSize:size(nmcVoxelList, 1)
    dispstat(sprintf('%.2f%%', 100 * chunk / size(nmcVoxelList, 1)));
    chunkFile = load(sprintf('corrCoefs-chunk-%d.mat', chunk));
    chunkRange = chunk:(chunk + chunkSize - 1);
    [~, dictIndex(chunkRange)] = ...
        max(chunkFile.corrCoefs, [], 2);
    [iAF, iDV, iMTT] = ind2sub([length(afRange), length(dvRange), ...
        length(mttRange)], dictIndex(chunkRange));
    af = afRange(iAF);
    dv = dvRange(iDV);
    mtt = mttRange(iMTT);
    
    % Scale the DV value
    vecLenMatchCurve = ...
        sqrt(sum(dict(:, dictIndex(chunkRange)).^2));
    vecLenCurve = sqrt(sum(voxelList(chunkRange, :)'.^2));
    dvScaleFactor = vecLenMatchCurve ./ vecLenCurve;
    dv = dv ./ dvScaleFactor;
    
    % Formula's taken from Yong's 2015 perfusion paper
    k1a = af .* dv ./ mtt;
    k1p = (1 - af) .* dv ./ mtt;
    k2 = 1 ./ mtt;

    % Store perfusion maps
    perfParams = [af', dv', mtt', k1a', k1p', k2'];
    for idx = 1:chunkSize
        chunkIdx = chunkRange(idx);
        matchPerfParams(i(chunkIdx), j(chunkIdx), k(chunkIdx), :) = ...
            perfParams(idx, :);
    end
end
toc

time = toc; % Stop the timer

end