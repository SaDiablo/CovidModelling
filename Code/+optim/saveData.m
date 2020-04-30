function saveData(optimprob, data)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
    if(ismissing(optimprob.Province))
        folder = join(['../Data/', optimprob.Country, '/']);
        filename = join(['data_', optimprob.Country, '_',optimprob.solver]);
    else
        folder = join(['../Data/', optimprob.Country, '_', optimprob.Province, '/']);
        filename = join(['data_', optimprob.Country, '_', optimprob.Province, '_', optimprob.solver]);
    end
    
%   if it exist change name to problem.bak and then save
    if(exist(join([folder, filename, '.mat']), 'file') == 2)
        movefile (join([folder, filename, '.mat']), join([folder, filename, '.bak']))
    end
    
    save(join([folder, filename]), 'data')
    

end

