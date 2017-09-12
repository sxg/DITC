function DatastoreMapper( data, ~, intermediateOutput )

    i = data(:, 1);
    j = data(:, 2);
    k = data(:, 3);
    matrix = data(:, 4);
    val = data(:, 5);
    
    % Add M data
    mMatrix = matrix(matrix == 0);
    mI = i(matrix == 0);
    mJ = j(matrix == 0);
    mVal = val(matrix == 0);
    
    addmulti(intermediateOutput, mJ, num2cell([mMatrix, mI, mVal], 2));
    
    % Add N data
    nMatrix = matrix(matrix == 1);
    nJ = j(matrix == 1);
    nK = k(matrix == 1);
    nVal = val(matrix == 1);
    
    addmulti(intermediateOutput, nJ, num2cell([nMatrix, nK, nVal], 2));
    
end