% Reads and creates figures for OpenTable reservation data

clear
close all
addpath('build/code')

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
ot_data.('city') = ot_data.('name');
ot_data.('name') = [];

% Add variables
ncities = numel(us_cities);
city_data.('travel_ban') = repmat(convertdate('3/14'), ncities, 1);
city_data.('first_death') = repmat(convertdate('2/29'), ncities, 1);

% Merge OT and city
data = join(ot_data, city_data, 'Keys', 'city');
data = sortrows(data, 'rank');

% Top 10 cities
ranks = unique(data.('rank'));
ranks_top10 = ranks(1:10)';
ranks_bottom10 = ranks(end-9:end)';

% Compute averages between Feb 18 and Feb 28
trange = timerange('2020-02-18', '2020-02-28');

restricted = data(trange,{'city', 'change'});
restricted = restricted(:,{'city', 'change'});

stats = varfun(@mean, restricted, 'InputVariables', 'change',...
    'GroupingVariables', 'city');
stats = timetable2table(stats(:,{'city', 'mean_change'}));
stats.('mean_before_feb29') = stats.('mean_change');
stats.('mean_change') = [];
stats.('date') = [];

% Value before travel ban
before_travel_ban = data(datetime('2020-03-13'),{'city','change'});
before_travel_ban = timetable2table(before_travel_ban);
before_travel_ban.('date') = [];
before_travel_ban.('day_before_travel_ban') = before_travel_ban.('change');
before_travel_ban.('change') = [];

stats = join(stats, before_travel_ban, 'Keys', 'city');

% Value before city ban
day_before_city_ban = data.('city_ban') - caldays(1);

restricted = data(data.('date') == day_before_city_ban,:);
change_before_city_ban = restricted(:, {'city', 'change'});
change_before_city_ban.('day_before_city_ban') = change_before_city_ban.('change');
change_before_city_ban.('change') = [];

stats = join(stats, change_before_city_ban, 'Keys', 'city');

allcities = struct();
allcities.city = 'All';
allcities.mean_before_feb29 = mean(stats.('mean_before_feb29'));
allcities.day_before_travel_ban = mean(stats.('day_before_travel_ban'));
allcities.day_before_city_ban = mean(stats.('day_before_city_ban'));
stats = [stats; struct2table(allcities)];

% Create plots
outdir = 'build/output';
for j = ranks_top10
    city = data(data.('rank')==j,:);
    plot_city(city);
    
    cityname = strrep(city.city(1), ' ', '_');
    filename = strcat(cityname{1}, '.pdf');
    saveas(gcf, fullfile(outdir, filename));
    close all
end