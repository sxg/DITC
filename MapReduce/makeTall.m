% 5 columns: i, j, k, M vs. N, value
data = zeros(167532 * 100 + 4084101 * 100, 5);

% Iterating through I (represented by 0)
for i = 1:167532
    disp(i);
    for j = 1:100
        idx = sub2ind([167532, 100], i, j);
        data(idx, :) = [i, j, -inf, 0, unrolledImages(i, j)];
    end
end

% Iterating through N (represented by 1)
for j = 1:100
    for k = 1:4084101
        disp(k);
        idx = sub2ind([100, 4084101], j, k);
        data(idx, :) = [-inf, j, k, 1, N(j, k)];
    end
end