function [ images ] = rollImages( unrolledImages, sz )
%rollImages Rolls a 2D matrix into multidimensional images.
%   Converts a 2D matrix into a multidimensional image with size sz.

images = reshape(unrolledImages,sz);

end

