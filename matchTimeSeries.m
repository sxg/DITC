function [matchPerfParams] = matchTimeSeries(timeSeries, mask, dict, ...
    afRange, dvRange, mttRange, times, artInputFunc, pvInputFunc)
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
validateattributes(artInputFunc, {'numeric'}, ...
    {'nonempty', 'column'});
validateattributes(pvInputFunc, {'numeric'}, ...
    {'nonempty', 'column'});

% Get dimensions
l = size(timeSeries, 1);
w = size(timeSeries, 2);
d = size(timeSeries, 3);
t = size(timeSeries, 4);

% Unroll voxels
voxelListIndexes = find(mask);
% [i, j, k] = ind2sub([l, w, d], voxelListIndexes);
timeSeries = reshape(timeSeries, [], t);
% voxelList = squeeze(timeSeries(i, j, k, :));
voxelList = timeSeries(voxelListIndexes, :);
voxelList = reshape(voxelList, [], t);

%% Fit the perfusion parameters
tic; % Start the timer

% Normalize and mean center the data
nmcVoxelList = normr(voxelList - mean(voxelList, 2));
nmcDict = normc(dict - mean(dict));

% Chunk the voxels
% chunks = 10;
% chunkSize = floor(size(nmcVoxelList, 1) / chunks);
corrCoefs = NaN(size(nmcVoxelList, 1), t);
nmcDict = sparse(nmcDict);
nmcVoxelList = sparse(nmcVoxelList);
corrCoefs = nmcVoxelList * nmcDict;

% for k1 = 1:420:size(nmcDict, 2)
%     
% end

% Find the correlation coefficients
% dispstat('', 'init');
% for index = 1:chunks
%     dispstat(sprintf('%d %%', 100 * index / chunks));
%     start = chunkSize * (index - 1) + 1; 
%     stop = size(nmcVoxelList, 1);
%     if index ~= chunks
%         stop = chunkSize * index;
%     end
%     corrCoefs(start:stop, :) = nmcVoxelList(start:stop, :) * nmcDict;
% end

% Get the perfusion parameters
[~, dictIndex] = max(corrCoefs, 2);
[iAF, iDV, iMTT] = ind2sub([length(afRange), length(dvRange), ...
    length(mttRange)], dictIndex);
af = afRange(iAF);
dv = dvRange(iDV);
mtt = mttRange(iMTT);

% Scale the DV value
vecLenMatchCurve = sqrt(sum(dict(:, dictIndex).^2));
vecLenCurve = sqrt(sum(voxelList.^2));
dvScaleFactor = vecLenMatchCurve ./ vecLenCurve;
dv = dv ./ dvScaleFactor';

% Formula's taken from Yong's 2015 perfusion paper
k1a = af * dv / mtt;
k1p = (1 - af) * dv / mtt;
k2 = 1 / mtt;

perfParams = [af, dv, mtt, k1a, k1p, k2];
matchPerfParams = reshape(perfParams, l, w, d, 6);

toc; % Stop the timer

end