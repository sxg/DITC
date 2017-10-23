function [tauP] = calcTauP(concAorta, concPV, times)
%calcTauP Calculates tauP.

[~, i1] = firstSignificant(concAorta);
[~, i2] = firstSignificant(concPV);
dt = abs(times(2) - times(1));
delayFrames = abs(i1 - i2);
delayTime = delayFrames * dt;
tauP = delayTime;

end