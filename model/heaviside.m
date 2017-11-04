function [ y ] = heaviside( x )
    if x < 0
        y = 0;
    elseif x == 0
        y = 1/2;
    else
        y = 1;
    end
end

