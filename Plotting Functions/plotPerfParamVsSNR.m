function [handle] = plotPerfParamVsSNR(perfParams, snrList, lineColor, ...
    yAxisLabel, yAxisLimits, trueValue)
%plotPerfParamVsSNR Plots RMSE vs. SNR.

% Input validation
nSims = size(perfParams, 1);
nSNRs = length(snrList);
validateattributes(snrList, {'numeric'}, {'vector', 'nonempty'});
validateattributes(perfParams, {'numeric'}, {'size', [nSims, nSNRs]});
validateattributes(yAxisLabel, {'char'}, {'scalartext'});
validateattributes(yAxisLimits, {'numeric'}, {'row', 'increasing'});

% Calculate perfusion parameters stats
meanPerfParam = nanmean(perfParams);
stdPerfParam = nanstd(perfParams);

% Plot RMSE vs. SNR
lineWidth = 2;
red = [0.866666666666667,0.321568627450980,0.321568627450980];
hold on;
handle = errorbar(snrList, meanPerfParam, stdPerfParam, ...
    'Color', lineColor, 'LineStyle', 'none');
plot(snrList, meanPerfParam, 'Color', lineColor, 'LineWidth', lineWidth);
axis([snrList(1), snrList(end), yAxisLimits]);
xlabel('SNR', 'FontSize', 22);
ylabel(yAxisLabel, 'FontSize', 22);
line([0, 100], [trueValue, trueValue], ...
    'Color', red, 'LineWidth', 1);

end

