function [ iAF, iDV, iMTT, it1, it2 ] = DictionaryMatcher( regimages, D, mask )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

% voxel = squeeze(regimages(60, 100, 25, :));

% Seems like the error is somewhere in the following lines
% corrCoefs = voxel' * normc(D);
% [~, linIdx] = max(corrCoefs);
% disp(linIdx);

% Try calculating corrCoefs for the entire time-series
% This ends up being too big for MATLAB to handle
N = normc(D);
resizedMask = zeros(size(regimages, 1), size(regimages, 2), size(regimages, 3));
resizedMask(1:size(mask, 1), 1:size(mask, 2), 1:size(mask, 3)) = mask;
maskedImages = repmat(resizedMask, [1, 1, 1, size(regimages, 4)]) .* regimages;
flatImages = normr(unrollImages(maskedImages, 4));
maxLinIdx = -1;
maxCorrCoef = -1;
% factorA x factorB = n
factorA = 1323;
factorB = 3087;
for i = 1:factorA
    disp(i);
    start = (i - 1) * factorB + 1;
    stop = i * factorB;
    [corrCoef, linIdx] = max(mean(flatImages * N(:, start:stop)));
    if corrCoef > maxCorrCoef
        maxCorrCoef = corrCoef;
        maxLinIdx = (start - 1) + linIdx;
    end
end
disp(maxCorrCoef);
disp(maxLinIdx);

% The sizes need to be updated if I change them in GenerateDictionary.m
[iAF, iDV, iMTT, it1, it2] = ind2sub([21, 21, 21, 21, 21], linIdx);

end