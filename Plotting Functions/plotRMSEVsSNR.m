function [handle] = plotRMSEVsSNR(idealCurve, estimatedCurves, snrList, ...
    lineColor)
%plotRMSEVsSNR Plots RMSE vs. SNR.

% Input validation
nSims = size(estimatedCurves, 2);
nTimePoints = size(idealCurve, 1);
nSNRs = length(snrList);
validateattributes(snrList, {'numeric'}, {'vector', 'nonempty'});
validateattributes(idealCurve, {'numeric'}, {'column'});
validateattributes(estimatedCurves, {'numeric'}, ...
    {'size', [nTimePoints, nSims, nSNRs]});

% Setup variables
rmseList = NaN(nSims, nSNRs);

% Calculate RMSEs
for i = 1:nSNRs
    for j = 1:nSims
        rmseList(j, i) = rmse(idealCurve, estimatedCurves(:, j, i));
    end
end
meanRMSE = nanmean(rmseList);
stdRMSE = nanstd(rmseList);

% Plot RMSE vs. SNR
lineWidth = 2;
hold on;
handle = errorbar(snrList, meanRMSE, stdRMSE, 'Color', lineColor, ...
    'LineStyle', 'none');
plot(snrList, meanRMSE, 'Color', lineColor, 'LineWidth', lineWidth);
axis([snrList(1), snrList(end), 0, 1]);
xlabel('SNR', 'FontSize', 22);
ylabel('RMSE', 'FontSize', 22);

end

