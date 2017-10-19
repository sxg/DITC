function [startIdx, stopIdx] = findRise(x)
%findRise Finds start and stop of the first rise in value of a vector.

% Input Validation
validateattributes(x, {'numeric'}, {'vector', 'nonempty'});

% Smooth the curve to reduce effects of noise
smoothX = smooth(smooth(x, 'rlowess'), 'rlowess');
% Get the peaks and nadirs in a sorted matrix
[peaks, peakIdxList] = findpeaks(smoothX);
[~, nadirIdxList] = findpeaks(-smoothX);
nadirs = smoothX(nadirIdxList);
optima = [peaks, peakIdxList; nadirs, nadirIdxList];
optima = sortrows(optima, 2);
% Find the max difference between adjacent optima
adjacentOptimaDiffs = diff(optima(:, 1));
[~, maxDiffIdx] = max(adjacentOptimaDiffs);

% Start of the rise is the beginning of the max difference
% End of the rise is the index after start
startIdx = optima(maxDiffIdx, 2);
if maxDiffIdx ~= size(optima, 1)
    stopIdx = optima((maxDiffIdx + 1), 2);
else
    stopIdx = startIdx;
end

end

