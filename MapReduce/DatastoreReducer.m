function DatastoreReducer( ~, intermValIter, finalOutput )
    
    mVals = zeros(0, 5);
    nVals = zeros(0, 5);
    
    % Get all values for the key, and split them into mVals and nVals
    while hasnext(intermValIter)
        val = getnext(intermValIter);
        
        % Value is from I (0) or N (1)
        if val(1) == 0
            mVals = [mVals; val];
        else
            nVals = [nVals; val];
        end
    end
    
    for idxM = 1:dim(mVals, 1)
       for idxN = 1:dim(nVals, 1)
           i = mVals(idxM, 2);
           m = mVals(idxM, 3);
           k = nVals(idxN, 2);
           n = nVals(idxN, 3);
           
           linIdx = sub2ind([167532, 4084101], i, k);
           add(finalOutput, linIdx, m * n);
       end
    end
    
end