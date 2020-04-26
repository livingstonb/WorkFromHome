%% Creates figures from Google mobility data
%
% States are ranked by population density which is estimated by dividing
% 2018 Census population estimates by Census land area estimates.

clear
close all

cd '/media/hdd/GitHub/WorkFromHome/Google'
addpath('stats/code')
outdir = 'stats/output';
mkdir(outdir)

%% Options
ALL_PLOTS = true;

%% Read cleaned dataset
filepath = 'build/output/state_time_series.mat';
load(filepath, 'state_time_series')

%% Filter top and bottom 10 states by population density
data = rmmissing(state_time_series, 'DataVariables', 'stay_at_home');

ranks = unique(data.rank);
n = numel(ranks);

top10 = data(ismember(data.rank, ranks(1:10)),:);
bottom10 = data(ismember(data.rank, ranks(n-9:n)),:);

%% Make plots
if ALL_PLOTS
    top10dir = 'stats/output/top10figs';
    plot_group(top10, top10dir);

    bottom10dir = 'stats/output/bottom10figs';
    plot_group(bottom10, bottom10dir);
else
    state_series = data(strcmp(data.state, 'New York'),:);
    plot_options = struct('varname', 'workplaces', 'varlabel', 'workplaces');
    state_plot = StatePlots(state_series, plot_options);
end

%% Functions

function plot_group(group, figdir)
    mkdir(figdir);
    states = reshape(unique(group.state), 1, []);
    varnames = {'retail_and_recreation', 'workplaces'};
    varlabels = {'retail and recreation', 'workplaces'};

    for j = 1:10
        for k = 1:2
            state_series = group(strcmp(group.state, states{j}),:);
            plot_options = struct('varname', varnames{k},...
                'varlabel', varlabels{k});
            StatePlots(state_series, plot_options);

            filename = strcat(states{j}, '_', varnames{k}, '.pdf');
            filepath = fullfile(figdir, filename);
            saveas(gcf, filepath);
            close
        end
    end
end
