function [ y ] = R2( t, PS, F, v2 )
%R2 Summary of this function goes here
%   Detailed explanation goes here

% R2_integral = @(tau) exp(-PS/v2 * tau) .* sqrt(PS.^2 ./ (v2 * F * tau)) .* besseli(1, 2 * sqrt(PS.^2 * tau / (v2 * F)));
% y = heaviside(t) * (1 - exp(-PS/F) * (1 + integral(R2_integral, 0.1, t)));
% starting the integration at zero causes a divide by zero error

coder.extrinsic('besseli');
vals = zeros(100, 1);
for i = 1:100
    tau = t / 100 * i;
    b = 0.0;
%     b = besseli(1, 2 * sqrt(PS.^2 * tau / (v2 * F)));
%     vals(i,1) = exp(-PS/v2 * tau) .* sqrt(PS.^2 ./ (v2 * F * tau)) .* b; 
    b = besseli(1, 2 * sqrt(abs(PS.^2 * tau / (v2 * F))));
    vals(i,1) = exp(-PS/v2 * tau) .* sqrt(abs(PS.^2 ./ (v2 * F * tau))) .* b; 
end
int_val = trapz(vals);

y = heaviside(t) * (1 - exp(-PS/F) * (1 + double(int_val)));

% r2_int = @(tau) exp(-PS/v2 * tau) .* sqrt(PS.^2 ./ (v2 * F * tau)) .* besseli(1, 2 * sqrt(PS.^2 * tau / (v2 * F)));
% y = integral(r2_int, 0.1, t);

end

