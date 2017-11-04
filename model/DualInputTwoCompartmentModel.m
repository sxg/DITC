function [ CL ] = DualInputTwoCompartmentModel( fitted_params, x )
%DUALINPUTTWOCOMPARTMENTMODEL Summary of this function goes here
%   Detailed explanation goes here
%
% 3/7/2016, Yong Chen
% v2: use v1 instead of t1

F = fitted_params(1)/100;
PS = fitted_params(2)/100;
v2 = fitted_params(3);
AF = fitted_params(4);
v1 = fitted_params(5);
t1 = v1 / F;

tauA = fitted_params(6);
% tauP = fitted_params(7);

Ca = x(:, 1);
Cpv = x(:, 2);
t = x(:, 3);

% v1 = F * t1;
% E = 1 - exp(-PS/F);

CL = zeros(length(t), 1);

%% Satyam's original code. But conv is not correct
% for i = 1:length(t)
%     CL(i) = F * conv(Cin(AF, Ca(i), Cpv(i)), R(t(i), t1, PS, F, v2));
% end

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

%% New method to do it
dt = t(2)-t(1); % here we assume even smampling

% First calculate a list of R from R(0) to R((n-1)*dt)
R_list = zeros(length(t),1);
for iR = 1:length(t)
    R_list(iR) = R(dt*(iR-1), t1, PS, F, v2);
end

% Then calculate a list of Cin from 1 to length(t)
Cin_list = zeros(length(t),1);
iTauA = round(tauA / dt);
% iTauP = round(tauP / dt);
for iCin = 1:length(t)
    if iCin - iTauA < 1
        Cin_list(iCin) =  Cin(AF, Ca(iCin), Cpv(iCin));
    else
        Cin_list(iCin) =  Cin(AF, Ca(iCin - iTauA), Cpv(iCin));
    end
end

% Finally calculate the conv using the two pre-caculated lists 
% Be careful about the index for R
for i = 1:length(t)
    sum1 = 0;
    for idt=1:i
       sum1 = sum1+F* Cin_list(idt)*R_list(i-idt+1)*dt;
    end
    CL(i) = sum1;
end
end

