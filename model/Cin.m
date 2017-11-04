function [ y ] = Cin( AF, Ca, Cpv )
%CIN Summary of this function goes here
%   Detailed explanation goes here

y = AF * Ca + (1 - AF) * Cpv;

end

