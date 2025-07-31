function [str, val, time, depth] = resampling(in, field1, field2, prm)
% Resample all signals in field 'field1' in structure 'in'.
%
% syntax1: [str, val, time, depth] = resampling(in, field1, field2, prm) 
% % - resample initial signals in the field of structure. Output
% sampling frequency equals fs_new = fs * fs_increase / fs_decrease. 
% The results can be saved in structure (str) and/or in matrix (val, depth and time axis)
%
% syntax2: [str, ~, ~, ~] = resampling(in, field1, field2, prm) 
%
% syntax3: [~, val, time, depth] = resampling(in, field1, field2, prm) 

%--------------------------------------------------------------------------
timer_resmapling = tic;

fs_up = prm.fs_up;
fs_down = prm.fs_down;
%--------------------------------------------------------------------------

fprintf( '\tresampling: start --> ' );

%%
assert( isstruct(in), 'Input structure is not defined.');   % check str
assert( isfield(in, field1), 'Field <%s> missing.', field1 );   % check field

if isfield(in, field2)
    warning(['Field ' field2 ' removed.']);
        in = rmfield(in, field2);
end

%%
N = length(in.(field1));          % number of the channels in the initial field
fs = in.(field1)(1).t(2);         % sampling frequency, Hz
new_fs = fs * fs_up / fs_down;

val = [];   depth = [];     str = in;

for i = 1:N

    p = in.(field1)(i).p;
    p_out = resample(p, fs_up, fs_down);
    
    % saving in the structure
        str.(field2)(i).p = p_out;
        str.(field2)(i).chnl = in.(field1)(i).chnl;
        str.(field2)(i).z = in.(field1)(i).z;
        str.(field2)(i).d = in.(field1)(i).d;
        str.(field2)(i).t = [in.(field1)(i).t(1), new_fs];

    % saving in the matrix
        val = [val, p_out];
        depth = [depth, in.(field1)(i).z];

    clear p p_out
    fprintf( '%d..', i );
end

new_dt = 1 / new_fs;
new_L = length( str.(field2)(1).p );

time = ( (0:new_L-1) * new_dt + in.(field1)(1).t(1) )';

fprintf( ' resampling done (%.1f).\n', toc(timer_resmapling) );
end