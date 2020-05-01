function [optimprob, folder] = openProblem(Country, Province)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

    if(ismissing(Province))
        folder = join(['../Data/', Country, '/']);
        filename = join(['problem_', Country, '.mat']);
    else
        folder = join(['../Data/', Country, '_', Province, '/']);
        filename = join(['problem_', Country, '_', Province, '.mat']);
    end
    
    if(exist(join([folder, filename]), 'file') == 2)
        optimprob = load(join([folder, filename])).optimprob;
    else
        optimprob = optim.prepareData(Country, Province);
    end
end

