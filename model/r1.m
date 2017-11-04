function [ y ] = r1( t, t1 )

y = heaviside(t) - heaviside(t - t1);

end

