function [str, val, time, depth] = correlating(signals, field_to_save, norm)
% Calculate cross correlation function
%
% [str, val, time, depth] = correlating(signals, field_to_save, norm)

tic
disp([num2str(toc) ': Starting...']);

n = length( signals(:, 1) );
assert( n == 2, 'Number of signals must be two.')

sig1 = signals{1, 1};   field1 = signals{1, 2};     chnl1 = signals{1, 3};
sig2 = signals{2, 1};   field2 = signals{2, 2};     chnl2 = signals{2, 3};

% Signal 1
assert( isstruct(sig1), 'Input structure is not defined.');   % check str
assert( isfield(sig1, field1), 'Field <%s> missing.', field2 );   % check field

    vector1 = vertcat(sig1.(field1).chnl);
    if chnl1 == -1
        ind1 = 1:length(vector1);
    else
        [ind1, ~] = find(vector1 == chnl1);
    end

    assert( ~isempty(ind1), 'No channel in the the first signal.' );   % check chnl
    N = length(ind1);


% Signal 2
assert( isstruct(sig2), 'Input structure is not defined.');   % check str
assert( isfield(sig2, field2), 'Field <%s> missing.', field2 );   % check field

    vector2 = vertcat(sig2.(field2).chnl);
    [ind2, ~] = find(vector2 == chnl2);

assert( ~isempty(ind2), 'No channel in the the second signal.' );   % check chnl
assert( isscalar(ind2), 'Channel error in the second signal.' );   % check chnl

if isfield(sig1, field_to_save)
    warning(['Field ' field_to_save ' removed.']);
        sig1 = rmfield(sig1, field_to_save);
end

%%
str = sig1;
val = [];   depth = [];     time = []; 

 p_ref = sig2.(field2)(ind2).p;                 % signal
    L_ref = length(p_ref);                      % signal length
    fs_ref = sig2.(field2)(ind2).t(2);          % sampling frequency
    dt_ref = 1 / fs_ref;                        % time step
    Tsignal_ref = length(p_ref) * dt_ref;       % signal time

%%
for i = 1:length(ind1)

    p = sig1.(field2)(ind1(i)).p;

    assert(length(p) >= L_ref, 'The second signal should be longer than the first.');

    p = p - mean(p);
    p_ref = p_ref - mean(p_ref);

    if norm == 0
        [r, lags] = xcorr(p, p_ref);
        % Cross-correlation measures the similarity between a vector x and 
        % shifted (lagged) copies of a vector y as a function of the lag. 
        % If x and y have different lengths, the function appends zeros to 
        % the end of the shorter vector so it has the same length as the other.
    elseif norm == 1
        [r, lags] = xcorr(p, p_ref, 'coeff');
    end
    
    p_out = [];
        p_out = r(round(length(r) / 2):end);    % take the second half
    % maxP = max(p_out);
    % p_out = p_out ./ maxP;
        
    % saving in the structure
        str.(field_to_save)(i).p = p_out;
        str.(field_to_save)(i).chnl = sig1.(field1)(i).chnl;
        str.(field_to_save)(i).z = sig1.(field1)(i).z;
        str.(field_to_save)(i).d = sig1.(field1)(i).d;
        str.(field_to_save)(i).t = sig1.(field1)(i).t;

        % saving in the variables
            val = [val; p_out];
            depth = [depth; sig1.(field1)(i).z];

        clear r lags p
        disp(['Signal ' num2str(i) '/' num2str(N) ' is done.']);
end

% time axis
time = (0:length(p_out)-1) * dt_ref + sig1.(field1)(1).t(1);

disp([num2str(toc) ': Correlating done.']);
end