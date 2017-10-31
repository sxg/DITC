function [matchPerfParams] = matchTimeSeries(timeSeries, mask, ...
    dict, afRange, dvRange, mttRange, times, artSignal, pvSignal, tauA, ...
    tauP)
%matchTimeSeries Gets perfusion parameters by dictionary matching.

%% Setup

elapsedTime = tic; % Start the timer

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

% Calculate the contrast concentrations
artContrast = artSignal2contrast(artSignal, pvSignal);
pvContrast = pvSignal2contrast(pvSignal); 

% Unroll voxels
voxelIndexes = find(mask);
[i, j, k] = ind2sub([l, w, d], voxelIndexes);
timeSeries = reshape(timeSeries, [], t);
voxelList = timeSeries(voxelIndexes, :);
nVoxels = size(voxelList, 1);
nEntries = size(dict, 2);
for idx = 1:nVoxels
    voxelList(idx, :) = signal2contrast(voxelList(idx, :));
end

%% Match the perfusion parameters

% Normalize and mean center the data
nmcVoxelList = normr(voxelList - mean(voxelList, 2));
nmcDict = normc(dict - mean(dict));

% Chunk the voxels
factors = divisors(nVoxels);
chunkSize = 1;
for chunkSize = factors(end:-1:1)
    % This part is partially hard-coded
    % 4 = bytes per single (assuming data is of single type)
    % 16e9 is the amount of RAM on my MBP in bytes
    if chunkSize * nEntries * 4 < 16e9
        break;
    end
end
nChunks = nVoxels / chunkSize;

% Setup outputs
chunkMMTime = NaN(nChunks, 1);
perfParamCalcTime = NaN(nChunks, 1);
dictIndex = NaN(size(voxelList, 1), 1);
matchPerfParams = single(zeros(l, w, d, 6));
matchCurves = single(zeros(l, w, d, t));

dispstat('', 'init');
for chunk = 1:chunkSize:(nChunks * chunkSize)
    dispstat(sprintf('%.2f%%', 100 * chunk / (nChunks * chunkSize)));
    
    % Calculate the correlation coefficients
    chunkRange = chunk:(chunk + chunkSize - 1);
    t = tic;
    corrCoefs = nmcVoxelList(chunkRange, :) * nmcDict;
    chunkMMTime((chunk - 1) / chunkSize + 1) = toc(t);
    
    % Get the perfusion parameters
    u = tic;
    [~, dictIndex(chunkRange)] = max(corrCoefs, [], 2);
    [iAF, iDV, iMTT] = ind2sub([length(afRange), length(dvRange), ...
        length(mttRange)], dictIndex(chunkRange));
    af = afRange(iAF);
    dv = dvRange(iDV);
    mtt = mttRange(iMTT);
    
    % Scale the DV value
    vecLenMatchCurve = sqrt(sum(dict(:, dictIndex(chunkRange)).^2));
    vecLenCurve = sqrt(sum(voxelList(chunkRange, :)'.^2));
    dvScaleFactor = vecLenCurve ./ vecLenMatchCurve;
    dv = dv .* dvScaleFactor;
    dv(dv > 1) = 1; % Clamp DV's value between 0 and 1 (known range)
    dv(dv < 0) = 0;
    
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
        matchCurves(i(chunkIdx), j(chunkIdx), k(chunkIdx), :) = ...
            normc(disc(times, artContrast, pvContrast, af(idx), dv(idx), ...
            mtt(idx), tauA, tauP));
    end
    perfParamCalcTime((chunk - 1) / chunkSize + 1) = toc(u);
end

time = toc(elapsedTime); % Stop the timer

%% Save the data
save('matchPerfuionVolume.mat', 'matchPerfParams', ...
    'matchCurves', 'time', 'chunkMMTime', 'perfParamCalcTime');

end