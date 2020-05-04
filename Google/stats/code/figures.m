%% Creates figures from Google mobility data
%
% States are ranked by population density which is estimated by dividing
% 2018 Census population estimates by Census land area estimates.

clear
close all
warning('off', 'MATLAB:MKDIR:DirectoryExists');

[~, currdir] = fileparts(pwd);
if strcmp(currdir, 'code')
    cd '../..';
end
addpath('stats/code')
outdir = 'stats/output';
mkdir(outdir)

%% Options
STATES = 'all';

%% Read cleaned dataset
filepath = 'build/output/state_time_series.mat';
load(filepath, 'state_time_series')

%% Filter top and bottom 10 states by population density
data = rmmissing(state_time_series, 'DataVariables', 'stay_at_home');

ranks = unique(data.rank);
n = numel(ranks);

top10 = data(ismember(data.rank, ranks(1:10)),:);
top10.Properties.Description = 'top10';
bottom10 = data(ismember(data.rank, ranks(n-9:n)),:);
bottom10.Properties.Description = 'bottom10';

%% Make plots
varnames = {'retail_and_recreation', 'workplaces'};
varlabels = {'retail and recreation', 'workplaces'};

if isequal(STATES, 'all')
    groups = {top10, bottom10};
    for grp = 1:2
        group = groups{grp};
        figdir = fullfile('stats/output',...
            strcat(group.Properties.Description, 'figs'));
        mkdir(figdir);
        states = reshape(unique(group.state), 1, []);
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
else
    for k = 1:2
        state_series = data(strcmp(data.state, STATES),:);
        plot_options = struct('varname', varnames{k}, 'varlabel', varlabels{k});
        StatePlots(state_series, plot_options);

        filename = strcat(STATES, '_', varnames{k}, '.pdf');
        filepath = fullfile('stats/output', filename);
        saveas(gcf, filepath);
        close
    end
end