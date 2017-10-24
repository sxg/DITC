function [handle] = plotRMSEVsSNR(allNoisyCurves, allCurves, snrList, ...
    titleName)
%plotRMSEVsSNR Plots RMSE vs. SNR.

% Input validation
nSims = size(allNoisyCurves, 2);
nTimePoints = size(allNoisyCurves, 1);
nSNRs = length(snrList);
validateattributes(snrList, {'numeric'}, {'vector', 'nonempty'});
validateattributes(allNoisyCurves, {'numeric'}, ...
    {'size', [nTimePoints, nSims, nSNRs]});
validateattributes(allCurves, {'numeric'}, ...
    {'size', [nTimePoints, nSims, nSNRs]});
validateattributes(titleName, {'char'}, {'scalartext'});

% Setup variables
rmseList = NaN(nSims, nSNRs);
meanRMSE = NaN(1, nSNRs);
stdRMSE = NaN(1, nSNRs);

% Calculate RMSEs
for i = 1:nSNRs
    noisyCurves = allNoisyCurves(:, :, i);
    curves = allCurves(:, :, i);
    for j = 1:nSims
        rmseList(j, i) = rmse(noisyCurves(:, j), curves(:, j));
    end
end
meanRMSE = nanmean(rmseList);
stdRMSE = nanstd(rmseList);

% Plot RMSE vs. SNR
hold on;
handle = errorbar(snrList, meanRMSE, stdRMSE, 'r', 'LineStyle', 'none');
plot(snrList, meanRMSE);
axis([snrList(1), snrList(end), 0 1]);
xlabel('SNR', 'FontSize', 18);
ylabel('RMSE', 'FontSize', 18);
title(titleName, 'FontSize', 24);

end

