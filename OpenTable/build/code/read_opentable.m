% Creates figures and statistics from OpenTable reservation data.

clear
close all

cd '/media/hdd/GitHub/WorkFromHome/OpenTable'
addpath('build/code')
outdir = 'build/output';
mkdir(outdir)

%% ---------------------- OPTIONS -----------------------------------------

COMPUTATIONS = true;
PLOTS = true;

%% ---------------------- READ AND CLEAN DATA -----------------------------

% Read raw OpenTable data
filepath = 'build/input/state_of_industry.csv';
ot_data = readcell(filepath);

% Reshape into long time series
ot_data = reshape_long(ot_data);

% Isolate city-level data
ot_data = ot_data(strcmp(ot_data.('type'), 'city'),:);

% Read population ranks
filepath = 'build/input/city_data.csv';
city_data = readtable(filepath);
convertdate = @(x) datetime(x, 'InputFormat', 'MM/dd');
city_data = convertvars(city_data, 'city_ban', convertdate);
city_data = sortrows(city_data, 3);
us_cities = table2cell(city_data(:,2));

% Isolate US cities
ot_data = ot_data(ismember(ot_data.('name'), us_cities),:);
ot_data = change_label(ot_data, 'name', 'city');

% Add variables
ncities = numel(us_cities);
city_data.('travel_ban') = repmat(convertdate('3/14'), ncities, 1);
city_data.('first_death') = repmat(convertdate('2/29'), ncities, 1);

% Merge OT and city
merged_series = join(ot_data, city_data, 'Keys', 'city');
merged_series = sortrows(merged_series, 'rank');

% Top/bottom 10 cities
ranks = unique(merged_series.('rank'));
ranks_top10 = ranks(1:10)';
ranks_bottom10 = ranks(end-9:end)';

%% ---------------------- COMPUTATIONS ------------------------------------

if COMPUTATIONS
    stats = compute_statistics(merged_series, city_data);
    filename = 'opentable_statistics.xlsx';
    filepath = fullfile(outdir, filename);
    writetable(stats, filepath);
end

%% ---------------------- PLOTS -------------------------------------------

if PLOTS
    % Create plots
    top10dir = fullfile(outdir, 'top10');
    bottom10dir = fullfile(outdir, 'bottom10');

    mkdir(top10dir);
    for j = [ranks_top10 ranks_bottom10]
        city = merged_series(merged_series.('rank')==j,:);
        plot_city(city);

        cityname = strrep(city.city(1), ' ', '_');
        filename = strcat(cityname{1}, '.pdf');
        
        if ismember(j, ranks_top10)
            saveas(gcf, fullfile(top10dir, filename));
        elseif ismember(j, ranks_bottom10)
            saveas(gcf, fullfile(bottom10dir, filename));
        end
        close all
    end
end

%% ---------------------- FUNCTIONS ---------------------------------------

function stats = compute_statistics(merged_series, city_data)
    % Compute averages between Feb 18 and Feb 28
    label = 'mean_before_feb29';
    stats = compute_mean_change(...
        merged_series, '2020-02-18', '2020-02-28', label);

    % Value before travel ban
    restricted_series = merged_series(datetime('2020-03-13'),{'city','change'});
    label = 'day_before_travel_ban';
    before_travel_ban = clean_timetable(restricted_series, label);
    stats = join(stats, before_travel_ban, 'Keys', 'city');

    % Value before city ban
    day_before_city_ban = merged_series.('city_ban') - caldays(1);
    restricted_series = merged_series(merged_series.('date') == day_before_city_ban,{'city','change'});
    label = 'day_before_city_ban';
    change_before_city_ban = clean_timetable(restricted_series, label);
    stats = join(stats, change_before_city_ban, 'Keys', 'city');

    % Merge with population rank
    stats = join(stats, city_data, 'Keys', 'city', 'RightVariables', 'rank');
    stats = change_label(stats, 'rank', 'population_rank');
    stats = sortrows(stats, 'population_rank');
    stats.('population_rank') = (1:size(city_data, 1))';

    allcities = struct();
    allcities.city = 'All';
    allcities.mean_before_feb29 = mean(stats.('mean_before_feb29'));
    allcities.day_before_travel_ban = mean(stats.('day_before_travel_ban'));
    allcities.day_before_city_ban = mean(stats.('day_before_city_ban'));
    allcities.population_rank = NaN;
    
    invars = {'mean_before_
    allcities = varfun(@mean, stats, 'InputVariables', {'change'}, 'OutputFormat', 'table')
    stats = [stats; struct2table(allcities)];

    % Related statistics
    stats.('drop_travel_ban') = stats.('day_before_travel_ban') - stats.('mean_before_feb29');
    stats.('drop_city_ban') = stats.('day_before_city_ban') - stats.('mean_before_feb29');
end

function table_out = change_label(table_in, old_label, new_label)
    table_out = table_in;
    table_out.(new_label) = table_out.(old_label);
    table_out.(old_label) = [];
end

function results = compute_mean_change(data, date1, date2, label)
    % Computes average YoY change between two dates

    trange = timerange(date1, date2);
    restricted = data(trange,{'city', 'change'});
    restricted = restricted(:,{'city', 'change'});

    results = varfun(@mean, restricted, 'InputVariables', 'change',...
        'GroupingVariables', 'city');
    results = timetable2table(results(:,{'city', 'mean_change'}));
    results = change_label(results, 'mean_change', label);
    results.('date') = [];
end

function data_out = clean_timetable(restricted_series, label)
    data_out = timetable2table(restricted_series);
    data_out = change_label(data_out, 'change', label);
    data_out.('date') = [];
end
