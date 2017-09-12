function [ B ] = unroll( A, dim )
%unrollImages Unrolls a multidimensional matrix into a 2D matrix.
%   For a multidimensional matrix, this function returns a 2D matrix with
%   the number of columns equal to the size of dimension dim in the given
%   matrix.

B = reshape(A, [], size(A, dim));

end

