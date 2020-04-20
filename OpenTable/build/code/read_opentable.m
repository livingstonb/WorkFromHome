

clear
close all
addpath('build/code')

filepath = 'build/input/state_of_industry.csv';
data = readcell(filepath);
data = reshape_long(data);
data = data(strcmp(data.('type'), 'city'),:);

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
    
    filename = strcat(strrep(top10cities(j).name, ' ', '_'), '.png');
    top10cities(j).fig_path = fullfile(outdir, filename);
end

% data = data(ismember(data.name, {top10cities.name}),:);
% data.type = [];

for j = 1:numel(top10cities)
    plotobjs = plot_city(top10cities(j));
    saveas(gcf, top10cities(j).fig_path);
    close all
end