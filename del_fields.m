function str = del_fields(in, fields)
% Remove specified fields in the 'in' structure.
%
% str = del_fields(in, fields) - return the structure in without specified
% fields, except <par>.

timer_del_fields = tic;
fprintf( '\tdel_fields: start --> ' );

%%
assert( isstruct(in), 'Input structure is not defined.');

%% check par
    if ismember('par', fields)
        warning('Field <par> will not be deleted.');
        fields = setdiff(fields, 'par');
    end
    
    % leave only existings fields
    existingFields = fieldnames(in);
    nonExistingFields = setdiff(fields, existingFields);
    
    if ~isempty(nonExistingFields)
        warning('The fields do not exist in the structure: %s.', ...
               strjoin(nonExistingFields, ', '));
    end
    
    validFieldsToRemove = intersect(fields, existingFields);
    
    % removing
    if ~isempty(validFieldsToRemove)
        str = rmfield(in, validFieldsToRemove);
    end

fprintf( 'fields deleted (%.1f).\n', toc(timer_del_fields) );

end