
clear
close all

cd '/media/hdd/GitHub/WorkFromHome/Google'
addpath('stats/code')
outdir = 'stats/output';
mkdir(outdir)

%% Read cleaned dataset
filepath = 'build/output/state_time_series.mat';
load(filepath, 'state_time_series')

vars_to_keep = {'state', 'retail_and_recreation', 'workplaces'};

%% Means between Feb 15 and Feb 28
trange = timerange(datetime('2020-02-15'), datetime('2020-02-29'));

subseries = state_time_series(trange,vars_to_keep);
means_baseline = varfun(@mean, subseries, 'GroupingVariables', 'state');
means_baseline = clean_timetable(means_baseline, {'GroupCount'});
means_baseline.Properties.VariableNames =...
    {'state', 'retail_and_rec_feb', 'workplaces_feb'};

%% At travel ban
at_travel_ban = state_time_series(datetime('2020-03-14'),vars_to_keep);
at_travel_ban = clean_timetable(at_travel_ban);
at_travel_ban.Properties.VariableNames =...
    {'state', 'retail_and_rec_travel_ban', 'workplaces_travel_ban'};

%% Other times
variables = {'stay_at_home', 'school_closure', 'dine_in_ban'};

other_subseries = {};
for j = 1:numel(variables)
    mask = day(state_time_series.date, 'dayofyear')...
    	 == day(state_time_series.(variables{j}), 'dayofyear');
    other_subseries{j} = state_time_series(mask,vars_to_keep);
    other_subseries{j} = clean_timetable(other_subseries{j});
    
    varnames = vars_to_keep;
    varnames{2} = strcat(varnames{2}, '_', variables{j});
    varnames{3} = strcat(varnames{3}, '_', variables{j});
    other_subseries{j}.Properties.VariableNames = varnames;
end

%% Merge
data = outerjoin(means_baseline, at_travel_ban,...
    'Keys', 'state', 'MergeKeys', true);

for j = 1:numel(other_subseries)
    data = outerjoin(data, other_subseries{j},...
        'Keys', 'state', 'MergeKeys', true);
end

%% Functions
function table_out = clean_timetable(table_in, extra_vars_to_delete)
    table_out = timetable2table(table_in);
    table_out.date = [];
    
    if nargin == 2
        for j = 1:numel(extra_vars_to_delete)
            table_out.(extra_vars_to_delete{j}) = [];
        end
    end
end