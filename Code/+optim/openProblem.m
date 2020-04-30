function [optimprob, filename] = openProblem(Country, Province)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

    if(ismissing(Province))
        filename = join(['../Data/', Country, '/problem_', Country, '.mat']);
    else
        filename = join(['../Data/', Country, '_', Province, '/problem_', Country, '_', Province, '.mat']);
    end
    
    if(exist(filename, 'file') == 2)
        optimprob = load(filename).optimprob;
    else
        optimprob = optim.prepareData(Country, Province);
    end
    
    if(ismissing(Province))
        filename = join(['../Data/', Country, '/']);
    else
        filename = join(['../Data/', Country, '_', Province, '/']);
    end
end

