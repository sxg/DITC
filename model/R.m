function [ y ] = r( t, t1, ps, f, v2 )

y = r1(t, t1) + r2(t - t1, ps, f, v2);

end

