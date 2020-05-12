clear
warning('off', 'MATLAB:MKDIR:DirectoryExists');

[~, currdir] = fileparts(pwd);
if strcmp(currdir, 'code')
    cd '../..';
end
addpath('build/code')


%% Read Google mobility data
filepath = 'build/temp/cleaned_mobility_report.csv';
data = readtable(filepath);

% Drop Washington D.C.
data(strcmp(data.('state'), 'District of Columbia'),:) = [];

% Relabel variables
newvarnames = cellfun(@(x) strrep(x, '_percent_change_from_baseline', ''),...
    data.Properties.VariableNames, 'UniformOutput', false);
data.Properties.VariableNames = newvarnames;

% Convert to datetime
data.date = datetime(data.date, 'Format', 'MM/dd/yyyy');

%% COVID deaths
filepath = 'build/input/covid_deaths.csv';
deaths = readtable(filepath);
deaths.date = datetime(deaths.date, 'Format', 'MM/dd/yyyy');
deaths.fips = [];
deaths.Properties.VariableNames{'deaths'} = 'cum_deaths';
deaths.Properties.VariableNames{'cases'} = 'cum_cases';

%% Perform merge
filepath = 'build/output/state_level_data.mat';
states_data = load(filepath);
states_data = states_data.states_data;

data = outerjoin(data, states_data, 'Keys', 'state', 'MergeKeys', true,...
    'Type', 'left');
data = outerjoin(data, deaths, 'Keys', {'state', 'date'},...
    'MergeKeys', true, 'Type', 'left');
data = table2timetable(data, 'RowTimes', 'date');

%% Save
% MATLAB timetable
state_time_series = data;
outpath = 'build/output/state_time_series.mat';
save(outpath, 'state_time_series')

% csv
outpath = 'build/output/state_time_series.csv';
writetimetable(state_time_series, outpath, 'WriteVariableNames', true);