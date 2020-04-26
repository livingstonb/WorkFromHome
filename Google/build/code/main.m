%% Creates figures and statistics from Google mobility data.
%
% States are ranked by population density which is estimated by dividing
% 2018 Census population estimates by Census land area estimates.
%
% Dates on shelter-in-place executive orders were taken from:
%   Sarah Mervosh, Denise Lu and Vanessa Swales. See Which States
%       and Cities Have Told Residents to Stay at Home. New York Times.
%       Accessed 4/23/20 at [https://www.nytimes.com/interactive/2020/
%       us/coronavirus-stay-at-home-order.html].

clear
close all

cd '/media/hdd/GitHub/WorkFromHome/Google'
addpath('build/code')
outdir = 'build/output';
mkdir(outdir)

%% ---------------------- READ AND CLEAN DATA -----------------------------

% Read raw Google data
filepath = 'build/input/cleaned_mobility_report.csv';
data = readtable(filepath);

% Drop Washington D.C.
data(strcmp(data.('state'), 'District of Columbia'),:) = [];

% Relabel variables
newvarnames = cellfun(@(x) strrep(x, '_percent_change_from_baseline', ''),...
    data.Properties.VariableNames, 'UniformOutput', false);
data.Properties.VariableNames = newvarnames;

% Convert to datetime
data = convertvars(data, 'date', 'datetime');

% Read population data
state_variables = readtable('build/input/state_data.xlsx');
state_variables.('state') = cellfun(@(x) strrep(x, '.', ''),...
    state_variables.('state'), 'UniformOutput', false);
state_variables = state_variables(~strcmp(state_variables.('state'), 'District of Columbia'),:);
state_variables.Properties.VariableNames{'pop2018'} = 'population';
state_variables = rmmissing(state_variables, 'DataVariables', 'density');
state_variables.('land') = [];

values = unique(state_variables.('density'));
pop_ranks = table(values, (numel(values):-1:1)', 'VariableNames',...
    {'density', 'rank'});
state_variables = join(state_variables, pop_ranks, 'Keys', 'density');

% Merge with population data
data = join(data, state_variables, 'Keys', 'state');

%% Generate variables
new_city_vars = state_variables(:,{'state','rank','shelter_in_place'});
vars_to_keep = {'state','retail_and_recreation','workplaces'};

% Average from Feb-15 to Feb-28
trange = timerange(datetime('2020-02-15'), datetime('2020-02-29'));
subseries = table2timetable(data, 'RowTimes', 'date');
subseries = subseries(trange, vars_to_keep);
subseries = varfun(@mean, subseries, 'GroupingVariables', 'state');

varnames = {'state', 'mean_retail_rec_feb15_feb28', 'mean_workplaces_feb15_feb28'};
mean_differences_feb = table(subseries.('state'), subseries.('mean_retail_and_recreation'),...
    subseries.('mean_workplaces'), 'VariableNames', varnames);

% Travel ban
varnames = {'state', 'retail_rec_at_travel_ban', 'workplaces_at_travel_ban'};
at_travel_ban = values_at_date(data, datetime('2020-03-14'), vars_to_keep, varnames);
new_city_vars = join(new_city_vars, at_travel_ban, 'Keys', 'state');

% Shelter-in-place order
varnames = {'state', 'retail_rec_at_shelter_in_place', 'workplaces_at_shelter_in_place'};
at_shelter_in_place = values_at_date(data, data.('shelter_in_place'), vars_to_keep, varnames);
new_city_vars = outerjoin(new_city_vars, at_shelter_in_place, 'Keys', 'state', 'Type', 'left');
new_city_vars.('state_at_shelter_in_place') = [];

% Filter top and bottom ten by population density
new_city_vars = rmmissing(new_city_vars, 'DataVariables', 'shelter_in_place');
new_city_vars = sortrows(new_city_vars, 'rank');
new_city_vars = new_city_vars([1:10 end-9:end],:);

new_city_vars.('group') = double(new_city_vars.('rank') < 25);
new_city_vars.Properties.VariableNames{'state_new_city_vars'} = 'state';

% Merge with mean differences
stats = join(new_city_vars, mean_differences_feb, 'Keys', 'state');
filepath = fullfile(outdir, 'mobility_stats.xlsx');
writetable(stats, filepath);

%% Merge
vars_to_keep = {'retail_rec_at_travel_ban', 'workplaces_at_travel_ban',...
    'retail_rec_at_shelter_in_place', 'workplaces_at_shelter_in_place',...
    'group'};
data = outerjoin(data, new_city_vars, 'Keys', 'state', 'Type', 'left',...
    'RightVariables', vars_to_keep);

%% Plots

% Top 10
group = data(data.('group') == 1,:);
figdir = fullfile(outdir, 'top10');
plot_group(group, figdir);

% Bottom 10
group = data(data.('group') == 0,:);
figdir = fullfile(outdir, 'bottom10');
plot_group(group, figdir);


%% Functions
function series = values_at_date(data, date, vars_to_keep, varnames)
    series = data(data.('date') == date,vars_to_keep);
    series.Properties.VariableNames = varnames;
end

function plot_group(group, figdir)
    mkdir(figdir);
    states = reshape(unique(group.('state')), 1, []);
    for state = states
        for variable = {'retail_and_recreation', 'workplaces'}
            state_series = group(strcmp(group.('state'), state{1}),:);
            plot_state(state_series, variable{1});

            filename = strcat(state{1}, '_', variable{1}, '.pdf');
            filepath = fullfile(figdir, filename);
            saveas(gcf, filepath);
            close
        end
    end
end

