function [f, ps, v2, af, v1, t1, e, tauA, tauP, err] = lsFitCurve(curve, times, ...
    artContrast, pvContrast)
%lsFitCurve Calculates the best fit curve using lsqcurvefit.

% Input validation
validateattributes(curve, {'numeric'}, {'column'});
validateattributes(times, {'numeric'}, ...
    {'column', 'nonempty', 'increasing'});
validateattributes(artContrast, {'numeric'}, {'column', 'nonempty'});
validateattributes(pvContrast, {'numeric'}, {'column', 'nonempty'});

opts = optimset('Tolx', 1e-16, 'Tolfun', 1e-10, 'Display', 'off', ...
                'DiffMinChange', 0.001);
xdata = [artContrast, pvContrast, times];
ydata = curve; % alias for readability
x0 = [1.3, 0.5, 0.2, 0.5, 0.2, 0.015, 0.007]; %f, ps, v2, af, v1, tauA
lb = [0.167, 0.01, 0.01, 0.01, 0.004, 0, 0];
ub = [2.5, 1, 0.4, 1, 0.4, 0.023, 0.020];
[x, err] = lsqcurvefit(@ditc, x0, xdata, ydata, lb, ub, opts);
f = x(1) * 60;
ps = x(2) * 60;
v2 = x(3) * 100;
af = x(4) * 100;
v1 = x(5) * 100;
tauA = x(6) * 1000;
tauP = x(7) * 1000;
t1 = v1 / f * 100;
e = (1 - exp(-ps / f)) * 100;

end

