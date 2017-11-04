function [ y ] = R( t, t1, PS, F, v2 )
%R Summary of this function goes here
%   Detailed explanation goes here

y = R1(t, t1) + R2(t - t1, PS, F, v2);

end

