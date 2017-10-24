function [af, dv, mtt, k1a, k1p, k2, err] = lsFitCurve(curve, times, ...
    ca, cp, tauA, tauP, startingPerfParams)
%lsFitCurve Calculates the best fit curve using lsqcurvefit.

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
ydata = curve; % alias for readability
lb = [0, 0, 1];
ub = [1, 1, 100];
[x, err] = lsqcurvefit(@discLSWrapper, x0, xdata, ydata, lb, ub, opts);
af = x(1);
dv = x(2);
mtt = x(3);
k1a = af * dv / mtt;
k1p = (1 - af) * dv / mtt;
k2 = 1 / mtt;

end
