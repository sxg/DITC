function [ B ] = roll( A, sz )
%rollImages Rolls a 2D matrix into a multidimensional matrix.
%   Converts a 2D matrix into a multidimensional matrix with size sz.

B = reshape(A,sz);

end

