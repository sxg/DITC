function [concLiver] = cl(liverInputFunc)
%cl Contrast concentration in the liver tissue.

alpha = 15 * pi / 180;
TR = 5.12;
T10l = 800;
relaxivity = 6.3;
Mo = 0.0029;

% Signal --> concentration
% e1l = exp(-TR / T10l);
% M0l = mean(liverInputFunc(2:2+liverStart)) * (1 - cos(alpha) * e1l) ./ (sin(alpha) * (1 - e1l));
% E1l = (liverInputFunc - M0l * sin(alpha)) ./ (liverInputFunc .* cos(alpha) - M0l .* sin(alpha));
% T1l = -TR ./ log(E1l);
% concLiver = (1 ./ (relaxivity / 1000)) .* ((1 ./ T1l) - (1 ./ T10l));

% Signal --> concentration
E1 = (liverInputFunc - Mo * sin(alpha)) ./ ...
    (liverInputFunc .* cos(alpha) - Mo .* sin(alpha));
T1l = -TR ./ log(E1);
concLiver = (1 / (relaxivity / 1000)) .* ((1 ./ T1l) - ( 1/ T10l));

% Original code
% S0l = mean(liverInputFunc(2:2+liverStart)) ...
%     * (1 - exp(-R10l * TR) * cos(alpha)) / (1 - exp(-R10l * TR)) ...
%     / sin(alpha);
% R1l = abs(log((S0l * sin(alpha) - liverInputFunc .* cos(alpha)) ...
%     ./ (S0l * sin(alpha) - liverInputFunc)) / TR);
% concLiver = (R1l - R10l) * 1e3 / relaxivity;

% Concentration --> signal
% M0l = mean(liverInputFunc(2:2+liverStart));
% T1l = 1 ./ (1 ./ T10l + relaxivity * liverInputFunc / 1000);
% e1l = exp(-TR ./ T1l);
% signal = M0l .* sin(alpha) .* (1 - e1l) ./ (1 - cos(alpha) .* e1l);

end
