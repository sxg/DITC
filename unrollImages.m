function [ unrolledImages ] = unrollImages( images, dim )
%unrollImages Unrolls an image into a 2D matrix.
%   For a multidimensional image, this function returns a 2D matrix with
%   the number of columns equal to the size of dimension dim in the given
%   images matrix.

unrolledImages = reshape(images, [], size(images, dim));

end

