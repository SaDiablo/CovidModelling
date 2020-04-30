clear all; 
% clc;
Country = 'Germany';
Province = missing;

%% load data from github
% 
optimprob = optim.openProblem(Country, Province);

display(join(['Country: ', optimprob.Country]))
display(join(['Population: ', num2str(optimprob.population)]))
display(join(['Day Started: ', num2str(optimprob.dayStarted)]))

%% algorithms
optim.algorithm('lsqnonlin', optimprob.Country, optimprob.Province, 1); % lsqnonlin
% optim.algorithm('patternsearch', optimprob.Country, optimprob.Province, 1); % patternsearch(s)
% optim.algorithm('fminunc', optimprob.Country, optimprob.Province, 0); % fminunc(s)
% optim.algorithm('fminsearch', optimprob.Country, optimprob.Province, 0); % fminsearch(s)
% optim.algorithm('fmincon', optimprob.Country, optimprob.Province, 0); % fmincon(s)
% optim.algorithm('ga', optimprob.Country, optimprob.Province, 0); % ga(s)
% optim.algorithm('pso_algorithm', optimprob.Country, optimprob.Province, 0); % pso(s)

%% Display difference between starting point and best found
% load('outputBest','x')
% disp('difference from start')
% display(join(['alpha: ', num2str(x(1)-x0(1))]))
% display(join(['beta: ', num2str(x(2)-x0(2))]))
% display(join(['delta: ', num2str(x(3)-x0(3))]))
% display(join(['gamma: ', num2str(x(4)-x0(4))]))
% display(join(['kappa0: ', num2str(x(5)-x0(5))]))
% display(join(['kappa1: ', num2str(x(6)-x0(6))]))
% display(join(['lambda0: ', num2str(x(7)-x0(7))]))
% display(join(['lambda1: ', num2str(x(8)-x0(8))]))
