function [optimprob] = prepareData(inputCountry, inputProvince)
%preparedData get coviddata from github
%   inputs:
%   inputCountry - ISO Country string
%   inputProvince - ISO Province string
%   output:
%   structure with all needed arrays
%   
%   
%%

%% Import COVID numbers

[tableConfirmed,tableDeaths,tableRecovered,time] = optim.getDataCOVID();

%% Import ISO data

urlwrite("https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/UID_ISO_FIPS_LookUp_Table.csv","ISO_Table.csv");
opts = delimitedTextImportOptions("NumVariables", 12, "VariableNamesLine", 1);
opts.VariableTypes = ["int32", "string", "string", "int32", "int32", "string", "string", "string", "double", "double", "string", "int32"];
opts.ExtraColumnsRule = "ignore";
opts.EmptyLineRule = "read";
tableISO = readtable("ISO_Table.csv", opts);
tableISO([1],:) = [];

%% Go through all data
Population = zeros(size(tableConfirmed,1),1);
for i = 1:size(tableConfirmed,1)
    if(ismissing(tableConfirmed(i,1)))
        tmp = tableConfirmed(i,2);
        Country = tmp{:,:};
        tempVar = tableISO(tableISO.Country_Region == Country, :);
        if (size(tempVar,1) > 1)
            tempVar = tempVar((ismissing(tempVar.Province_State)), :);
        end
    else
        tmp2 = tableConfirmed(i,1);
        Region = tmp2{:,:};
        tempVar = tableISO(tableISO.Province_State == Region, :);
        if (size(tempVar,1) > 1)
            tmp = tableConfirmed(i,2);
            Country = tmp{:,:};
            tempVar = tempVar(tempVar.Country_Region == Country, :);
        end
    end
        %this doesn't work:
        %%%Population(i) = tempVar.Population;
        %this does:
        pop = tempVar.Population;
        Population(i) = pop;
end
% adding population as 5th column
tableConfirmed = addvars(tableConfirmed,Population,'After','Long');
%tableDeaths = addvars(tableDeaths,Population,'After','Long');
%tableRecovered = addvars(tableRecovered,Population,'After','Long');


%% table to array 
if(exist('inputCountry', 'var') == 1)
    Country = inputCountry;
else
    Country = 'Poland';
end

if(exist('inputProvince', 'var') == 1)
    Province = inputProvince;
else
    Province = missing; % space == {<missing>}
end

% table Confirmed
if(ismissing(Province))
    tempVar = tableConfirmed(tableConfirmed.CountryRegion == Country, :);
    if (size(tempVar,1) > 1)
        tempVar = tempVar((ismissing(tempVar.Province_State)), :);
    end
else
    tempVar = tableConfirmed(tableConfirmed.Province_State == Province, :);
    if (size(tempVar,1) > 1)
        tmp = tableConfirmed(i,2);
        Country = tmp{:,:};
        tempVar = tempVar(tempVar.Country_Region == Country, :);
    end
end
arrayVar = table2array(tempVar(1, 6:end));
arrayConfirmed = arrayVar(arrayVar ~= 0);
dayStarted = size(arrayVar, 2) - size(arrayConfirmed, 2);
population = tempVar.Population;


% table Deaths
if(ismissing(Province))
    tempVar = tableDeaths(tableDeaths.CountryRegion == Country, :);
    if (size(tempVar,1) > 1)
        tempVar = tempVar((ismissing(tempVar.Province_State)), :);
    end
else
    tempVar = tableDeaths(tableDeaths.Province_State == Province, :);
    if (size(tempVar,1) > 1)
        tmp = tableDeaths(i,2);
        Country = tmp{:,:};
        tempVar = tempVar(tempVar.Country_Region == Country, :);
    end
end

arrayVar = table2array(tempVar(1, 6:end));
arrayDeaths = arrayVar(dayStarted:end);

% table Recovered
if(ismissing(Province))
    tempVar = tableRecovered(tableRecovered.CountryRegion == Country, :);
    if (size(tempVar,1) > 1)
        tempVar = tempVar((ismissing(tempVar.Province_State)), :);
    end
else
    tempVar = tableRecovered(tableRecovered.Province_State == Province, :);
    if (size(tempVar,1) > 1)
        tmp = tableRecovered(i,2);
        Country = tmp{:,:};
        tempVar = tempVar(tempVar.Country_Region == Country, :);
    end
end
arrayVar = table2array(tempVar(1, 6:end));
arrayRecovered = arrayVar(dayStarted:end);

arrayInfectedQ = arrayConfirmed - arrayRecovered - arrayDeaths;
% clear ans arrayVar i opts pop tmp tmp2 Region tempVar 
% clear Population tableConfirmed tableDeaths tableISO tableRecovered time
delete('COVID.csv')
delete('ISO_Table.csv')

%% data into problem and saving it into .mat
optimprob.Country = Country;
optimprob.Province = Province;
optimprob.dayStarted = dayStarted;
optimprob.population = population;
if(isnan(arrayConfirmed(1,end)))
    optimprob.arrayConfirmed = arrayConfirmed(1, 1:end-1);
else
    optimprob.arrayConfirmed = arrayConfirmed;
end

if(isnan(arrayDeaths(1,end)))
    optimprob.arrayDeaths = arrayDeaths(1, 1:end-1);
else
    optimprob.arrayDeaths = arrayDeaths;
end

if(isnan(arrayRecovered(1,end)))
    optimprob.arrayRecovered = arrayRecovered(1, 1:end-1);
else
    optimprob.arrayRecovered = arrayRecovered;
end
% Currently infected people
if(isnan(arrayInfectedQ(1,end)))
    optimprob.arrayInfectedQ = arrayInfectedQ(1, 1:end-1);
else
    optimprob.arrayInfectedQ = arrayInfectedQ;
end
optimprob.lb = [0, 0, 0, 0, 0, 0, 0, 0];
optimprob.ub = [Inf, Inf, Inf, Inf, Inf, Inf, Inf, Inf];
optimprob.A = [];
optimprob.b = [];
optimprob.Aeq = [];
optimprob.beq = [];
optimprob.x0 = [0.08, 0.9, 1e-3, 1e-3, 1e-3, 1e-3, 0.03, 1e-3];
optimprob.xOld = [0.08, 0.9, 1e-3, 1e-3, 1e-3, 1e-3, 0.03, 1e-3];
optimprob.d0 = 0; % Dead
optimprob.e0 = 0; % Confirmed (?)
optimprob.p0 = 0; % Not susceptible
optimprob.r0 = 0; % Recovered

optimprob.s0 = population; % Susceptible (all population)

optimprob.i0 = 1; % Infected (without quarantine)
optimprob.q0 = 0; % Infected (with quarantine)

optimprob.integratorInitial = [optimprob.d0, optimprob.e0, optimprob.i0,...
    optimprob.p0, optimprob.r0, optimprob.s0, optimprob.q0]; 
optimprob.t0 = 1:size(optimprob.arrayConfirmed, 2); % data time 
optimprob.t = 1:size(optimprob.arrayConfirmed, 2)*1; % simulation time

% Fix of Reference to non-existent field
% 
algorithmName = 'lsqnonlin';optimprob.(algorithmName).allTime = 0;optimprob.(algorithmName).squareLast = 1e20;optimprob.(algorithmName).squareSmallest = 1e20;optimprob.(algorithmName).funcCount = 1;optimprob.x0=optimprob.xOld;
algorithmName = 'patternsearch';optimprob.(algorithmName).allTime = 0;optimprob.(algorithmName).squareLast = 1e20;optimprob.(algorithmName).squareSmallest = 1e20;optimprob.(algorithmName).funcCount = 1;optimprob.x0=optimprob.xOld;
algorithmName = 'fminunc';optimprob.(algorithmName).allTime = 0;optimprob.(algorithmName).squareLast = 1e20;optimprob.(algorithmName).squareSmallest = 1e20;optimprob.(algorithmName).funcCount = 1;optimprob.x0=optimprob.xOld;
algorithmName = 'fminsearch';optimprob.(algorithmName).allTime = 0;optimprob.(algorithmName).squareLast = 1e20;optimprob.(algorithmName).squareSmallest = 1e20;optimprob.(algorithmName).funcCount = 1;optimprob.x0=optimprob.xOld;
algorithmName = 'fmincon';optimprob.(algorithmName).allTime = 0;optimprob.(algorithmName).squareLast = 1e20;optimprob.(algorithmName).squareSmallest = 1e20;optimprob.(algorithmName).funcCount = 1;optimprob.x0=optimprob.xOld;
algorithmName = 'pso';optimprob.(algorithmName).allTime = 0;optimprob.(algorithmName).squareLast = 1e20;optimprob.(algorithmName).squareSmallest = 1e20;optimprob.(algorithmName).funcCount = 1;optimprob.x0=optimprob.xOld;
algorithmName = 'ga';optimprob.(algorithmName).allTime = 0;optimprob.(algorithmName).squareLast = 1e20;optimprob.(algorithmName).squareSmallest = 1e20;optimprob.(algorithmName).funcCount = 1;optimprob.x0=optimprob.xOld;
optim.saveProblem(optimprob)

end