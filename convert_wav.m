function str = convert_wav(file, field, prm)
% Convert wav-file to Pulsar format.
%
% str = convert_wav(file, field, prm) - load wav-file and convert
% data to the structure in given field.

%--------------------------------------------------------------------------
timer_convert_wav = tic;

point       = prm.point;        % receiver point
DT          = prm.DT;           % date and time start
%--------------------------------------------------------------------------

fprintf( '\tconvert_wav: start --> ' );

%%
str = struct();
str.par = struct('file', '', 'pointName', '', 'fs', [], 'DT', []);
str.(field) = struct('p', [], 'chnl', [], 'z', [], 'd', [], 't', []);

str.par.file = file;            % file name from which data is taken           
str.par.pointName = point;                % receiver name (point on the map)
str.par.DT = DT;

%% load file and extract data
try
    [signal, fs] = audioread(file);
catch Me
    error(['The problem with reading file <' file '>.']);
end

str.par.fs = fs;

num_channel = size(signal, 2);  % number of channels

for i = 1:num_channel

    str.(field)(i).p = signal(:, i);
    str.(field)(i).chnl = i - 1;
    str.(field)(i).z = nan;
    str.(field)(i).d = nan;
    str.(field)(i).t = [0, fs];

end

fprintf( 'data converted (%.1f).\n', toc(timer_convert_wav) );
end