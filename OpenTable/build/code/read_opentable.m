% Reads and creates figures for OpenTable reservation data

clear
close all
addpath('build/code')

% Read raw OpenTable data
filepath = 'build/input/state_of_industry.csv';
data = readcell(filepath);

% Reshape into long time series
data = reshape_long(data);

% Isolate city-level data
data = data(strcmp(data.('type'), 'city'),:);

% Read population ranks
filepath = 'build/input/city_pop_ranks.csv';
popranks = readtable(filepath);
popranks = sortrows(popranks, 2);
us_cities = table2cell(popranks(:,1));


% Isolate US cities
data = data(ismember(data.('name'), us_cities),:);

% Structure with city-specific variables
convertdate = @(x) datetime(x, 'InputFormat', 'MM/dd');
top10cities(1) = struct(...
    'name', 'New York', 'shutdown', '3/17');
top10cities(2) = struct(...
    'name', 'Los Angeles', 'shutdown', '3/17');
top10cities(3) = struct(...
    'name', 'Chicago', 'shutdown', '3/17');
top10cities(4) = struct(...
    'name', 'Houston', 'shutdown', '3/17');
top10cities(5) = struct(...
    'name', 'Phoenix', 'shutdown', '3/18');
top10cities(6) = struct(...
    'name', 'Philadelphia', 'shutdown', '3/17');
top10cities(7) = struct(...
    'name', 'San Antonio', 'shutdown', '3/19');
top10cities(8) = struct(...
    'name', 'San Diego', 'shutdown', '3/17');
top10cities(9) = struct(...
    'name', 'Dallas', 'shutdown', '3/17');
top10cities(10) = struct(...
    'name', 'Austin', 'shutdown', '3/17');

outdir = 'build/output';
for j = 1:numel(top10cities)
    top10cities(j).shutdown = convertdate(top10cities(j).shutdown);
    top10cities(j).data = data(strcmp(data.('name'), top10cities(j).name),:);
    top10cities(j).travel_ban = convertdate('3/14');
    top10cities(j).first_death = convertdate('2/29');
    
    filename = strcat(strrep(top10cities(j).name, ' ', '_'), '.pdf');
    top10cities(j).fig_path = fullfile(outdir, filename);
end

% Compute averages between Feb 18 and Feb 28, and values before bans
stats = table();
trange = timerange('2020-02-18', '2020-02-28');
for j = 1:numel(us_cities)
    city = us_cities{j};
    citydata = data(strcmp(data.('name'), city),:);

    cityname = {city};
    citystats = struct();
    citystats.City = {city};
    citystats.Mean_YoY_Change_Feb18_to_Feb28 = mean(citydata(trange,:).('change'));
    citystats.Population_Rank = table2array(popranks(j,2));
    
    citytable = struct2table(citystats);
    stats = [stats; citytable];
end

% Add US-wide average
tmp = mean(stats.('Mean_YoY_Change_Feb18_to_Feb28'));
citystats = struct();
citystats.City = {'All US cities available'};
citystats.Mean_YoY_Change_Feb18_to_Feb28 = tmp;
citystats.Population_Rank = NaN;
citytable = struct2table(citystats);
stats = [stats; citytable];

% Create plots
for j = 1:numel(top10cities)
    plotobjs = plot_city(top10cities(j));
    saveas(gcf, top10cities(j).fig_path);
    close all
end