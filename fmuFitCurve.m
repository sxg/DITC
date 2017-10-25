function [af, dv, mtt, k1a, k1p, k2] = fmuFitCurve(curve, times, ...
    ca, cp, tauA, tauP, startingPerfParams)
%fmuFitCurve Calculates the best fit curve using fminunc.

% Input validation
validateattributes(curve, {'numeric'}, {'column'});
validateattributes(times, {'numeric'}, ...
    {'column', 'nonempty', 'increasing'});
validateattributes(ca, {'numeric'}, {'column', 'nonempty'});
validateattributes(cp, {'numeric'}, {'column', 'nonempty'});
validateattributes(tauA, {'numeric'}, {'scalar'});
validateattributes(tauP, {'numeric'}, {'scalar'});
validateattributes(startingPerfParams, {'numeric'}, ...
    {'vector', 'nonempty'});

opts = optimset('Tolx', 1e-16, 'Tolfun', 1e-10, 'Display', 'off', ...
                'DiffMinChange', 0.001);
x0 = startingPerfParams; % af, dv, mtt
nData = size(times, 1);
xdata = [times, ca, cp, repmat(tauA, nData, 1), repmat(tauP, nData, 1)];
% ydata = curve; % alias for readability
f = @(fittedParameters) ...
    rmse(discLSWrapper(fittedParameters, xdata), curve);
x = fminunc(f, x0, opts);
af = x(1);
dv = x(2);
mtt = x(3);
k1a = af * dv / mtt;
k1p = (1 - af) * dv / mtt;
k2 = 1 / mtt;

end

