classdef StatePlots < handle
    properties
        data;
        varname;
        varlabel;
        fig;
        ax;
        scatter;
        xlines = struct();
    end
    
    methods
        function obj = StatePlots(data, options)
            obj.data = data;

            obj.varname = options.varname;
            obj.varlabel = options.varlabel;

            obj.fig = figure();
            obj.ax = gca();
            
            obj.plot_scatter();
            obj.plot_vertical_lines();
            obj.format();
        end
        
        function plot_scatter(obj)
            % Scatter plot of the chosen variable
            obj.scatter = scatter(obj.data.date,...
                obj.data.(obj.varname), 'filled');
        end
        
        function plot_vertical_lines(obj)
            obj.make_xline('business_closure_CST',...
                'Business closure', 0);
            obj.make_xline('stay_at_home',...
                'Stay-at-home', -10);
            obj.make_xline('school_closure',...
                'School closure', -20);
            obj.make_xline('dine_in_ban',...
                'Dining room ban', -30);
        end
        
        function make_xline(obj, variable, label, pos, date)
            if nargin < 5
                date = obj.data.(variable)(1);
            end

            if ~ismissing(date)
                obj.xlines.(variable) = xline(date, '--');

                txt = strcat('\leftarrow ', label);
                text(date, pos, txt)
            end
        end
        
        function format(obj)
            title(obj.data.state(1));
            
            obj.ax.XLabel.String = 'Date';
            obj.ax.YLabel.String = strcat(...
                '% difference from baseline,', obj.varlabel);
            box(obj.ax, 'on')
        end
    end
end