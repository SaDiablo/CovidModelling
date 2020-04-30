function saveProblem(optimprob)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
    if(ismissing(optimprob.Province))
        folder = join(['../Data/', optimprob.Country, '/']);
        filename = join(['problem_', optimprob.Country]);
    else
        folder = join(['../Data/', optimprob.Country, '_', optimprob.Province, '/']);
        filename = join(['problem_', optimprob.Country, '_', optimprob.Province]);
    end
    
%   if it exist change name to problem.bak and then save
    if(exist(join([folder, filename, '.mat']), 'file') == 2)
        movefile (join([folder, filename, '.mat']), join([folder, filename, '.bak']))
    end
    
    try
        save(join([folder, filename]), 'optimprob')
    catch
        mkdir(folder); 
        optim.saveProblem(optimprob);
    end
end

