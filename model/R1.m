function [ y ] = R1( t, t1 )
%R1 Summary of this function goes here
%   Detailed explanation goes here

y = heaviside(t) - heaviside(t - t1);

end

