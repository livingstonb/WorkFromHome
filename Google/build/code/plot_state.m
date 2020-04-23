function plotobjs = plot_state(state, varname)
    % Plots OpenTable data for a given city. Should be passed a table
    % with the necessary fields.
    
    plotobjs.fig = figure();
    plotobjs.ax = gca();
    
    % Scatter plot
    plotobjs.scatter = scatter(state.date, state.(varname), 'filled');

    % Add vertical line for federal travel ban
    plotobjs.travel_ban = plot_travel_ban(datetime('2020-03-14'));
    
    % Add vertical line for city-wide dine-in ban
    shelter_in_place = state{1,'shelter_in_place'};
    plotobjs.shutdown = plot_shutdown(shelter_in_place);
    
    % Other formatting
    title(state.state(1))
    format_figure(plotobjs, varname)
end

function ban_obj = plot_travel_ban(ban_date)
    ban_obj = xline(ban_date);
    
    txt = '\leftarrow Federal travel ban';
    text(ban_date, 0, txt)
end

function shutdown_obj = plot_shutdown(sd_date)
    shutdown_obj = xline(sd_date);
    
    txt = '\leftarrow Shelter-in-place';
    text(sd_date, -10, txt);
end

function format_figure(plotobjs, varname)
    plotobjs.ax.XLabel.String = 'Date';
    
    if strcmp(varname, 'retail_and_recreation')
        suffix = ', retail and recreation';
    else
        suffix = ', workplaces';
    end
    plotobjs.ax.YLabel.String = strcat('% difference from baseline', suffix);
	box(plotobjs.ax, 'on')
end