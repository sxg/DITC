function [handle] = plotPerfParamVsSNR(perfParams, snrList, titleName, ...
    yAxisLabel, yAxisLimits, trueValue)
%plotPerfParamVsSNR Plots RMSE vs. SNR.

% Input validation
nSims = size(perfParams, 1);
nSNRs = length(snrList);
validateattributes(snrList, {'numeric'}, {'vector', 'nonempty'});
validateattributes(perfParams, {'numeric'}, {'size', [nSims, nSNRs]});
validateattributes(titleName, {'char'}, {'scalartext'});
validateattributes(yAxisLabel, {'char'}, {'scalartext'});
validateattributes(yAxisLimits, {'numeric'}, {'row', 'increasing'});

% Setup variables
meanPerfParam = NaN(1, nSNRs);
stdPerfParam = NaN(1, nSNRs);

% Calculate perfusion parameters stats
meanPerfParam = nanmean(perfParams);
stdPerfParam = nanstd(perfParams);

% Plot RMSE vs. SNR
hold on;
handle = errorbar(snrList, meanPerfParam, stdPerfParam, 'r', ...
    'LineStyle', 'none');
plot(snrList, meanPerfParam);
axis([snrList(1), snrList(end), yAxisLimits]);
xlabel('SNR', 'FontSize', 18);
ylabel(yAxisLabel, 'FontSize', 18);
line([0, 100], [trueValue, trueValue], 'Color', 'green');
title(titleName, 'FontSize', 24);

end

