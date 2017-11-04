function [ y ] = r2( t, ps, f, v2 )

coder.extrinsic('besseli');
vals = zeros(100, 1);
for i = 1:100
    tau = t / 100 * i;
    b = besseli(1, 2 * sqrt(abs(ps.^2 * tau / (v2 * f))));
    vals(i,1) = exp(-ps/v2 * tau) .* sqrt(abs(ps.^2 ./ (v2 * f * tau))) .* b; 
end
%int_val = trapz(vals);
integralVal = sum(vals) * t /100; % Yong Chen 3/16/2016
y = heaviside(t) * (1 - exp(-ps/f) * (1 + double(integralVal)));

end

