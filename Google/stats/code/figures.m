clear
close all

cd '/media/hdd/GitHub/WorkFromHome/Google'
addpath('stats/code')
outdir = 'stats/output';
mkdir(outdir)

%% Options
ALL_PLOTS = false;

%% Read cleaned dataset
filepath = 'build/output/state_restrictions.mat';
load(filepath, 'state_restrictions')

%% Filter top and bottom 10 states by population density
data = rmmissing(state_restrictions, 'DataVariables', 'stay_at_home');

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
    plot_state(state_series, 'workplaces');
end

%% Functions

function plot_group(group, figdir)
    mkdir(figdir);
    states = reshape(unique(group.state), 1, []);
    variables = {'retail_and_recreation', 'workplaces'};

    for j = 1:10
        for k = 1:2
            state_series = group(strcmp(group.state, states{j}),:);
            plot_state(state_series, variables{k});

            filename = strcat(states{j}, '_', variables{k}, '.pdf');
            filepath = fullfile(figdir, filename);
            saveas(gcf, filepath);
            close
        end
    end
end
