function [ y ] = cIn( af, artContrast, pvContrast )

y = af * artContrast + (1 - af) * pvContrast;

end

