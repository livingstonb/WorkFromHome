function plotobjs = plot_city(city)
    data = city.data;
    year_on_year = data.change;
    
    plotobjs.fig = figure();
    plotobjs.ax = gca();
    
    plotobjs.scatter = scatter(data.date, year_on_year, 'filled');
    plotobjs.travel_ban = plot_travel_ban(city.travel_ban);
    plotobjs.shutdown = plot_shutdown(city.shutdown);
    title(city.name)
    format_figure(plotobjs)
   
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