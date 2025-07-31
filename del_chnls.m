function str = del_chnls(in, chnls)
% Remove specified channels in each fields of the 'in' structure.
%
% str = del_chnls(in, chnls) - returns the structure without the specified
% channels in each fields (except 'par').

timer_del_chnls = tic;
fprintf( '\tdel_chnls: start --> ' );

%%
assert( isstruct(in), 'Input structure is not defined.');

% define fields
existingFields = fieldnames(in);
fields = setdiff(existingFields, 'par');    % except 'par'

%% define channels index
    vector = vertcat(in.(fields{1}).chnl);
    [ind, ~] = find(vector == chnls);

    % delete
    for i = 1:length(fields)
        in.(fields{i})(ind) = [];
    end

    str = in;

fprintf( 'channels deleted (%.1f).\n', toc(timer_del_chnls) );

end