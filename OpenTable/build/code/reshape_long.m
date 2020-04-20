function table_out = reshape_long(arr_in)
    dates = arr_in(1,3:end);
    types = arr_in(2:end,1);
    names = arr_in(2:end,2);
    values = arr_in(2:end,3:end);
    T = numel(dates);
    
    table_out = table();
    for j = 1:numel(names)
        s.name = repmat(names(j), T, 1);
        s.type = repmat(types(j), T, 1);
        s.date = dates(:);
        s.decline = reshape(values(j, :), T, 1);
        
        new_section = struct2table(s);
        table_out = [table_out; new_section];
    end
end