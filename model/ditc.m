function [ contConc ] = ditc( fitParams, x )
%ditc Dual-input two-compartmetn model for liver perfusion quantification.
%
% 3/7/2016, Yong Chen
% v2: use v1 instead of t1

f = fitParams(1) / 100;
ps = fitParams(2) / 100;
v2 = fitParams(3);
af = fitParams(4);
v1 = fitParams(5);
t1 = v1 / f;
tauA = fitParams(6) * 1000;
% tauP = fitted_params(7); Sourbron 2012 says tauP is negligible

% v1 = F * t1;
% E = 1 - exp(-PS/F);

artContrast = x(:, 1);
pvContrast = x(:, 2);
times = x(:, 3);

contConc = zeros(length(times), 1);

%%
% The efficiency of the code below is really low. Could improve a lot!
% dt = t(2)-t(1); % here we assume even smampling
% for i = 1:length(t)
%     sum1 = 0;
%     for idt=1:i
%        sum1 = sum1+F* Cin(AF, Ca(idt), Cpv(idt))*R(t(i)-t(idt), t1, PS, F, v2)*dt;
%     end
%     CL(i) = sum1;
% end

dt = times(2) - times(1);

% First calculate a list of R from R(0) to R((n-1)*dt)
rList = zeros(length(times),1);
for iR = 1:length(times)
    rList(iR) = r(dt * (iR - 1), t1, ps, f, v2);
end

% Then calculate a list of Cin from 1 to length(t)
cInList = zeros(length(times), 1);
iTauA = round(tauA / dt);
% iTauP = round(tauP / dt);
for iCIn = 1:length(times)
    if iCIn - iTauA < 1
        cInList(iCIn) =  cIn(af, artContrast(iCIn), pvContrast(iCIn));
    else
        cInList(iCIn) = ...
            cIn(af, artContrast(iCIn - iTauA), pvContrast(iCIn));
    end
end

% Finally calculate the conv using the two pre-caculated lists 
% Be careful about the index for R
for i = 1:length(times)
    sum1 = 0;
    for idt = 1:i
       sum1 = sum1 + f * cInList(idt) * rList(i - idt + 1) * dt;
    end
    contConc(i) = sum1;
end

end

