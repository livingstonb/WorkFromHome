classdef StateFunctions
    methods (Static)
        function table_out = get_state(data, state)
            table_out = data(strcmp(data.state, state),:);
        end
        
        function table_out = between(data, t1, t2)
            t1 = datetime(t1, 'InputFormat', 'MM/dd/yyyy');
            t2 = datetime(t2, 'InputFormat', 'MM/dd/yyyy');
            trange = timerange(t1, t2);
            table_out = data(trange,:);
        end
        
        function table_out = keep(data, variables)
            table_out = data(:,variables);
        end
        
        function table_out = drop(data, variables)
            table_out = data;
            for j = 1:numel(variables)
                table_out.(variables{j}) = [];
            end
        end
    end
end