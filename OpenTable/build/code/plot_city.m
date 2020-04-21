function plotobjs = plot_city(city)
    % Plots OpenTable data for a given city. Should be passed a table
    % with the necessary fields.
    
    plotobjs.fig = figure();
    plotobjs.ax = gca();
    
    % Scatter plot
    plotobjs.scatter = scatter(city.date, city.change, 'filled');
    
    % Add vertical line for first death
    plotobjs.first_death = plot_firstdeath(city.first_death(1));
    
    % Add vertical line for federal travel ban
    plotobjs.travel_ban = plot_travel_ban(city.travel_ban(1));
    
    % Add vertical line for city-wide dine-in ban
    plotobjs.shutdown = plot_shutdown(city.city_ban(1));
    
    % Other formatting
    title(city.city(1))
    format_figure(plotobjs)
end

function firstdeath_obj = plot_firstdeath(first_death)
    firstdeath_obj = xline(first_death);
    
    txt = '\leftarrow First death';
    text(first_death, -80, txt);
end

function ban_obj = plot_travel_ban(ban_date)
    ban_obj = xline(ban_date);
    
    txt = '\leftarrow Federal travel ban';
    text(ban_date, 0, txt)
end

function shutdown_obj = plot_shutdown(sd_date)
    shutdown_obj = xline(sd_date);
    
    txt = '\leftarrow City-wide dine-in ban';
    text(sd_date, -10, txt);
end

function format_figure(plotobjs)
    plotobjs.ax.XLabel.String = 'Date';
    plotobjs.ax.YLabel.String = '% change in reservations, year-on-year';
	box(plotobjs.ax, 'on')
end