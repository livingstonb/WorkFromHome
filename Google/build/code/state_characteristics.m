
clear
warning('off', 'MATLAB:MKDIR:DirectoryExists');
warning('off', 'MATLAB:table:ModifiedAndSavedVarnames');

[~, currdir] = fileparts(pwd);
if strcmp(currdir, 'code')
    cd '../..';
end
addpath('build/code')

%% School closure
filepath = 'build/input/school_closures.csv';
school_closures = readtable(filepath);

school_closures = school_closures(:,{'State', 'StateClosureStartDate'});
school_closures.Properties.VariableNames = {'state', 'school_closure'};

%% Stay at home order
filepath = 'build/temp/stay_at_home.csv';
stay_at_home = readtable(filepath);

% Use the following day if effective time is after 8 am
hours = hour(datetime(stay_at_home.date, 'InputFormat', 'MM d h a'));
stay_at_home.date = datetime(stay_at_home.date,...
    'InputFormat', 'MM d h a', 'Format', 'MM/dd/yyyy');
stay_at_home.date(hours > 8) = stay_at_home.date(hours > 8) + days(1);
stay_at_home.Properties.VariableNames{'date'} = 'stay_at_home';

%% Population
population = readtable('build/input/state_data.xlsx');
population.('state') = cellfun(@(x) strrep(x, '.', ''),...
    population.('state'), 'UniformOutput', false);
population = population(~strcmp(population.('state'), 'District of Columbia'),:);
population.Properties.VariableNames{'pop2018'} = 'population';
population = rmmissing(population, 'DataVariables', 'density');
population.('land') = [];
population.('shelter_in_place') = [];
population.('dine_in_ban') = [];

values = unique(population.('density'));
pop_ranks = table(values, (numel(values):-1:1)', 'VariableNames',...
    {'density', 'rank'});
population = join(population, pop_ranks, 'Keys', 'density');
population.Properties.VariableNames{'density'} = 'persons_per_sqmi';

%% Dining room bans
filepath = 'build/input/dine_in_bans.csv';
dine_in_bans = readtable(filepath);
dine_in_bans.dine_in_ban = datetime(dine_in_bans.dine_in_ban,...
    'Format', 'MM/dd/yyyy');

%% Coronavirus state tracking data
state_tracking = readtable('build/temp/coronavirus_state_tracking.csv');
state_tracking.Var1 = [];

datevars = {'stay_at_home', 'business_closure', 'state_of_emergency'};

for j = 1:numel(datevars)
    state_tracking.(datevars{j}) = datetime(state_tracking.(datevars{j}),...
        'InputFormat', 'MM d yyyy', 'Format', 'MM/dd/yyyy');
    state_tracking.Properties.VariableNames{datevars{j}} = strcat(datevars{j}, '_CST');
end

%% Merge
states_data = outerjoin(school_closures, stay_at_home,...
    'Keys', 'state', 'MergeKeys', true);
states_data = outerjoin(states_data, population,...
    'Keys', 'state', 'MergeKeys', true);
states_data = outerjoin(states_data, dine_in_bans,...
    'Keys', 'state', 'MergeKeys', true);
states_data = outerjoin(states_data, state_tracking,...
    'Keys', 'state', 'MergeKeys', true);

%% Drop non-states
states_data = rmmissing(states_data, 'DataVariables', 'rank');

%% Save
outpath = 'build/output/state_level_data.mat';
save(outpath, 'states_data');