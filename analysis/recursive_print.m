function recursive_print(data, level)
if isstruct(data)
    fields = fieldnames(data);
    for i = 1:size(fields,1)
        
        for j = 1:level
            fprintf('| - ')
        end
        
        
        fprintf('%s\n', fields{i});
        for j = 1:numel(data.(fields{i}))
            recursive_print(data.(fields{i})(j), level + 1)
        end
    end
elseif isnumeric(data)
    
    for j = 1:level
        fprintf('| - ')
    end
    
    fprintf('%.3f\n', data);
end

end