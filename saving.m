function saving(in)
% Save structure in the '!signals' folder.

timer_saving = tic;
fprintf( '\tsaving: start --> ' );

assert( isstruct(in), 'Input structure is not defined.');

name = inputname(1);
%%
if exist(['!signals\' name '.mat'], 'file') == 2
    choice = questdlg(['The signal "' name '" already exists. Replace?'], ...
        'Conflict', 'Yes, delete old signal','No', 'No');
    switch choice
        case 'Yes, delete old signal'   
            delete( ['!signals\' name '.mat']);

        case 'No'
            error('The signal %s already exists.', in)
    end
end
%--------------------------------------------------------------------------
fprintf( 'saving... --> ' );
    eval([name ' = in;']);
    save( ['!signals' '\' name '.mat'], name );

fprintf( 'the structure saved (%.1f).\n', toc(timer_saving) );

end