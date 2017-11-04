function [contrast] = signal2contrast(signal, flipAngle, TR, T10l, ...
    relaxivity, scaleFactor, startFrame, addFrames)
%cl Contrast concentration for a given signal intensity.

alpha = flipAngle * pi / 180;
T10l = T10l * 1000;
R10l = 1/T10l;

S0l = mean(signal(startFrame:startFrame+addFrames)) ...
    * (1 - exp(-R10l * TR) * cos(alpha)) / (1 - exp(-R10l * TR)) ...
    / sin(alpha);
R1l = abs(log((S0l * sin(alpha) - signal .* cos(alpha)) ...
    ./ (S0l * sin(alpha) - signal)) / TR);
contrast = (R1l - R10l) * 1e3 / relaxivity;
contrast = contrast * scaleFactor;

end
