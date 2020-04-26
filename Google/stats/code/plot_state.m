function plotobjs = plot_state(state, varname)
    % Plots OpenTable data for a given city. Should be passed a table
    % with the necessary fields.
    
    plotobjs.fig = figure();
    plotobjs.ax = gca();
    
    % Scatter plot
    plotobjs.scatter = scatter(state.date, state.(varname), 'filled');

    % Add vertical line for federal travel ban
    plotobjs.travel_ban = plot_travel_ban(datetime('2020-03-14'));
    
    % Add vertical line for stay-at-home order
    stay_at_home = state{1,'stay_at_home'};
    plotobjs.shutdown = plot_shutdown(stay_at_home);
    
    % School closure
    school_closure = state{1, 'school_closure'};
    plotobjs.school_closure = plot_school_closure(school_closure);
    
    % Dining room ban
    plotobjs.plot_dine_in_ban = plot_dine_in_ban(state{1, 'dine_in_ban'});
    
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
    
    txt = '\leftarrow Stay-at-home order';
    text(sd_date, -10, txt);
end

function plot_obj = plot_school_closure(sc_date)
    plot_obj = xline(sc_date);
    
    txt = '\leftarrow School closure';
    text(sc_date, -20, txt);
end

function plot_obj = plot_dine_in_ban(date)
    plot_obj = xline(date);
    
    txt = '\leftarrow Dining room closure';
    text(date, -30, txt);
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