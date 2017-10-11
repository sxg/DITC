function [croi] = discLSWrapper(fittedParams, unfittedParams)
%mdiscLSWrapper - Wrapper for lsqcurvefit to use the disc function. 

% Pull out the fitted parameters
af = fittedParams(1);
dv = fittedParams(2);
mtt = fittedParams(3);

% Pull out the unfitted parameters
times = unfittedParams(:, 1);
ca = unfittedParams(:, 2);
cp = unfittedParams(:, 3);
tauA = unfittedParams(:, 4);
tauA = tauA(1);
tauP = unfittedParams(:, 5);
tauP = tauP(1);

croi = disc(times, ca, cp, af, dv, mtt, tauA, tauP);
   
end