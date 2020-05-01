function data = openData(optimprob)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
    if(ismissing(optimprob.Province))
        folder = join(['../Data/', optimprob.Country, '/']);
        filename = join(['data_', optimprob.Country, '_', optimprob.solver, '.mat']);
    else
        folder = join(['../Data/', optimprob.Country, '_', optimprob.Province, '/']);
        filename = join(['data_', optimprob.Country, '_', optimprob.Province, '_', optimprob.solver, '.mat']);
    end
    

    if(exist(join([folder, filename]), 'file') == 2)
        data = load(join([folder, filename])).data;
    else
        data.allTime = 0;
        data.squareLast = 1e20;
        data.squareSmallest = 1e20;
        data.funcCount = 1;
        optim.saveData(optimprob, data);
        data = optim.openData(optimprob);
    end
end

