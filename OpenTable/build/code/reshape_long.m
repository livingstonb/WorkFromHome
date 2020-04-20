function table_out = reshape_long(arr_in)
    % Reshapes a cell array from OpenTable data into
    % a long time series dataset, returned as a timetable.

    % Columns
    dates = arr_in(1,3:end);
    types = arr_in(2:end,1);
    names = arr_in(2:end,2);
    values = cell2mat(arr_in(2:end,3:end));
    T = numel(dates);
    
    table_out = table();
    for j = 1:numel(names)
        s.name = repmat(names(j), T, 1);
        s.type = repmat(types(j), T, 1);
        s.date = dates(:);
        s.change = reshape(values(j, :), T, 1);
        
        new_section = struct2table(s);
        table_out = [table_out; new_section];
    end
    
    % Convert to timetable
    table_out.date = datetime(table_out.date, 'InputFormat', 'MM/dd');
    table_out = table2timetable(table_out, 'RowTimes', 'date');
end