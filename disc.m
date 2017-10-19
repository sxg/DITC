function [ Croi ] = disc( times, Ca, Cp, af, dv, mtt, tauA, tauP )
%disc Summary of this function goes here

% Yong's math
k1a = af * dv / mtt;
k1p = (1 - af) * dv / mtt;
k2 = 1 / mtt;

% Equations from Yong's paper
% AF = k1a / (k1a + k1p);
% DV = (k1a + k1p) / k2;
% MTT = 1 / k2;

dt = times(2) - times(1);
iTauA = tauA / dt;
iTauP = tauP / dt;
Croi = zeros(length(times), 1);

for idx = 1:length(times)
    sum = 0;
    for idt = 1:idx
        sumA = 0;
        sumP = 0;
        if (round(idt - iTauA)) > 0 && (round(idt - iTauA)) <= size(Ca, 1)
            sumA = k1a * Ca(round(idt - iTauA));
        end
        if (round(idt - iTauP)) > 0 && (round(idt - iTauP)) <= size(Cp, 1)
            sumP = k1p * Cp(round(idt - iTauP));
        end
        sum = sum + (sumA + sumP) * (exp(-k2 * (idx - idt) * dt) * dt);
    end
    Croi(idx) = sum;
end

% Yong's code
% dt = times(2) - times(1);
% C = zeros(length(times), 1);

% Yong's code
% for idx = 1:length(times)
%     sum = 0;
%     for idt = 1:idx
%         sum1 = 0;
%         if round(idt - t1 * 1000) > 0 % consider first part
%             sum1 = sum1 + k1a * Ca(round(idt - t1 * 1000));
%         end
%         %if round(idt - t2) > 0
%         if round(idt - t2 * 1000) > 0
%             sum1 = sum1 + k1p * Cp(round(idt - t2*1000));
%         end
%         sum = sum + sum1 * exp(-k2 * (idx - idt) * dt) * dt;
%     end
%     C(idx) = sum;
% end

end