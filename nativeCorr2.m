dispstat('','init');

cc = zeros(4084101, 1);

for i = 1:4084101
    dispstat(sprintf('Iteration: %d', i));
    cc(i) = corr2(voxel, D(:, i));
end

dispstat('Done.', 'keepprev');