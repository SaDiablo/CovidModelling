function [out] = cvopt(x)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
%   x = [alpha, beta, delta, gamma, kappa0, kappa1, lambda0, lambda1]
%   IntegratorInitial = [d0, e0, i0, p0, r0, s0, q0]
%   population = Country population

functionTimer = tic;
%% Handle loading input data
global Country_global;
global Province_global;
global allTime;
global squareLast;
global squareSmallest;
global funcCount;

% load problem filename
[optimprob, filename] = optim.openProblem(Country_global, Province_global);
% set image location
filename_image = join([filename, optimprob.solver, '/', num2str(funcCount)]);

% display(x)
% x(2) = 300; %beta does nothing at all and breaks searching in patternsearch and fminsearch
% if(strcmpi(optimprob.solver, 'lsqnonlin'))
%     
% else
%     
% end

%%
% try
    opt = simset('srcWorkspace', 'current', 'FixedStep', '1');
    output.sim = sim('covid', optimprob.t, opt); %simulate
% catch
%     if(strcmpi(optimprob.solver, 'lsqnonlin'))
%         out = [optimprob.arrayInfectedQ*1e200;
%             optimprob.arrayRecovered*1e200;
%             optimprob.arrayDeaths*1e200]; % for lsqnonlin
%     else
%         out = 1e200; % for rest
%     end
% end
%% Output values from simulation
simInfectedQ = output.sim.data.Q.data';
simRecovered = output.sim.data.R.data';
simDeaths = output.sim.data.D.data';

%%
infectedSubstracted = simInfectedQ(1, 1:size(optimprob.arrayInfectedQ, 2)) - optimprob.arrayInfectedQ;
recoveredSubstracted = simRecovered(1, 1:size(optimprob.arrayRecovered, 2)) - optimprob.arrayRecovered;
deathsSubstracted = simDeaths(1, 1:size(optimprob.arrayDeaths, 2)) - optimprob.arrayDeaths;

%% Calculate function values
% recoveredRatio = data.arrayInfectedQ(1,end)/data.arrayRecovered(1,end);
% deathRatio = data.arrayInfectedQ(1,end)/data.arrayDeaths(1,end);
% j = [infectedSubstracted; recoveredSubstracted*recoveredRatio; deathsSubstracted*deathRatio];

%% or Calculate normalized function value
j = [(10/optimprob.arrayInfectedQ(1,end))*infectedSubstracted;...
    (10/optimprob.arrayRecovered(1,end))*recoveredSubstracted;...
    (10/optimprob.arrayDeaths(1,end))*deathsSubstracted];

%% Calculate least squares (for display purposes)
j2=j.^2;
j3=sum(sum(j2));
if(strcmpi(optimprob.solver, 'lsqnonlin'))
    out = j; % for lsqnonlin
else
    out = j3; % for rest
end
%% single plot per data every significant change
if (squareSmallest - j3 > 1e-4)
    %saving part
        fig = gcf;
        fig.Visible = 'off';
        fig.Renderer = 'painters';
        fig.PaperUnits = 'inches';
        fig.PaperPosition = [0 0 9.1066 5.1225];
    %
    subplot(1,3,1)
        plot(optimprob.t, simDeaths, 'r', optimprob.t0, optimprob.arrayDeaths,'r:');   
         legend('simDeaths', 'Deaths','Location', 'northwest')
%          title(join([optimprob.Country, ' - ', optimprob.solver, ' - ',  'funcCount: ', num2str(funcCount)]))
        xlabel('Day')
        ylabel('Number of people')
        grid on
        grid minor
    subplot(1,3,2)
        plot(optimprob.t, simRecovered,'g', optimprob.t0, optimprob.arrayRecovered,'g:');  
         legend('simRecovered', 'Recovered', 'Location', 'northwest')
         title(join([optimprob.Country, ' - ', optimprob.solver, ' - f(x): ', num2str(j3), ' - funcCount: ', num2str(funcCount)]))
        xlabel('Day')
        ylabel('Number of people')
        grid on
        grid minor
    subplot(1,3,3)
        plot(optimprob.t, simInfectedQ,'b', optimprob.t0, optimprob.arrayInfectedQ,'b:');
        legend('simInfectedQ', 'InfectedQ', 'Location','northwest')
%         title(join([optimprob.Country, ' - ', optimprob.solver, ' - ',  'funcCount: ', num2str(funcCount)]))
        xlabel('Day')
        ylabel('Number of people')
        grid on
        grid minor
        drawnow
        % saving part
            saveas(gcf, filename_image, 'png');
            clf (fig);
        %
end

%% or all on the same plot every funcCount
% if rem(funcCount, ((size(x,2)*2)+1)) == 0
%     plot(input.t, simDeaths, 'r', input.t0, data.arrayDeaths,'r:',...
%          input.t, simRecovered,'g', input.t0, data.arrayRecovered,'g:',...
%          input.t, simInfectedQ,'b', input.t0, data.arrayInfectedQ,'b:');
%     legend('simDeaths', 'Deaths',...
%         'simRecovered', 'Recovered',...
%         'simInfectedQ', 'InfectedQ',...
%         'Location','best')
%     
%     title(join([data.Country, ' - OptimModel - ',  'funcCount: ', num2str(funcCount)]))
%     xlabel('Day')
%     ylabel('Number of people')
%     grid on
%     grid minor
%     drawnow
% end



%% display current data
% if rem(funcCount, 5) == 0
%     display(join(['InfectedDiff: ', num2str(j(1,end))]) )
%     display(join(['RecoveredDiff: ', num2str(j(2,end))]) )
%     display(join(['DeathsDiff: ', num2str(j(3,end))]) )
%     display(join(['square: ', num2str(j3)]) )
%     display(join(['squareDiff: ', num2str(squareLast - j3)]) )
%     display(join(['iterTtime: ', num2str(funcTime)]))
%     display(join(['fullOptTime: ', num2str(allTime)]))
%     display(x(:))
%     display(funcCount)
% end  

%% save curent

% if rem(funcCount, ((size(x,2)*2)+1)) == 0
%     clear alpha beta delta gamma kappa0 kappa1 lambda0 lambda1
%     clear d0 e0 i0 j2 opt out p0 q0 r0 s0
%     clear D E I Kappa Lambda P Q R S
%     save(join([input.algorithmName, '-outputs']),...
%         'allTime','output','j','data','input',...
%         'simInfectedQ','simRecovered','simDeaths')
% end
%% check funcCount time
funcTime = toc(functionTimer);
allTime = allTime + funcTime;

%% save
squareLast(1, funcCount) = j3;
if(squareSmallest - j3 > 1e-4)
    squareSmallest = j3;
  
    data.x = x;
    data.allTime = allTime;
    data.squareLast = squareLast;
    data.squareSmallest = squareSmallest;
    data.funcCount = funcCount;
    
    optim.saveData(optimprob, data);
end

%% i++
funcCount = funcCount + 1;
end