function sgnl = signalAnalysis( signals, prm )
% The function load signals, calculate its parameters in time and frequency domains
%
% signals - {'label1', 'field1', number1; 'label2', 'field2', number2; ...}
%--------------------------------------------------------------------------
timer_signalAnalysis = tic;

timeAxis    = prm.timeAxis;     % absolute seconds (1); relative seconds (2); hh:mm:ss (3)
f_sel       = prm.f_sel;        % frequency range for SEL calculation, Hz
window      = prm.window;       % time frame + weight window, points
overlap     = prm.overlap;      % time frame overlap, from 0 to 1
type        = prm.type;         % PSD (1) or spectrogram (2)
method      = prm.method;       % pspectrum / spectrogram
%--------------------------------------------------------------------------
 
% OUTPUT parameters:
sgnl = [];
    sgnl.par        = [];   % initial signal parameters
    sgnl.chnl       = [];   % signal channel
    sgnl.z          = [];   % horizont of the hydrophone, m
    sgnl.d          = [];   % distance form sled, m
% time domain
    sgnl.fs         = [];   % sampling frequency, Hz
    sgnl.p          = [];   % acoustic pressure or voltz, Pa or V
    sgnl.L          = [];   % signal length
    sgnl.L          = [];   % signal lengthsgnl.dt = [];
    sgnl.t          = [];   % time axis, sec or hh:mm:ss (in depend on timeAxis)
    sgnl.DT         = [];   % date and time of the timeframe
    sgnl.T          = [];   % signal duration, sec
    sgnl.SELt       = [];   % Sound Exposure Level in time domain, dB
    sgnl.SPLpeak    = [];   % Sound Pressure Level peak, dB
% frequency domain
    sgnl.f1         = [];   % frequency axis, Hz
    sgnl.psd1       = [];   % full PSD (full window), dB
    sgnl.SELf       = [];   % Sound Exposure Level in frequency domain, dB
    sgnl.ff         = [];   % new frequency range to calculate SEL, Hz
    sgnl.SELff      = [];   % Sound Exposure Level in frequency range, dB
    sgnl.f2         = [];   % frequency axis, Hz
    sgnl.psd2       = [];   % smoothed PSD (window + overlap), dB
% spectrogram
    sgnl.specF      = [];   % frequency axis for spectrogram, Hz
    sgnl.specT      = [];   % time axis for spectrogram, sec or hh:mm:ss
    sgnl.specS      = [];   % periodograms for spectrogram, dB
    sgnl.specDT     = [];   % datetime format for spectrogram

fprintf( '\tsignalAnalysis: start --> ' );

 %%
    lim_fullwindow = 1 * 10^6;
    N = length(signals(:, 1));    % number of the signals

for i = 1:N
    %% checking and loading
    str = signals{i, 1};  field = signals{i, 2};  chnl = signals{i, 3};

    assert( isstruct(str), 'Input structure is not defined: for signal %d.', i);    % check str
    assert(isfield(str, field), 'No field %s in signal %d.', field, i);             % check field

    vector = vertcat(str.(field).chnl);
    [ind, ~] = find(vector == chnl);

    assert(~isempty(ind), 'No channel %d in signal %d.', chnl, i);                  % check chnl

    sgnl(i).par = str.par;
        sgnl(i).chnl = str.(field)(ind).chnl;
        sgnl(i).z = str.(field)(ind).z;
        sgnl(i).d = str.(field)(ind).d;

    %% TIME DOMAIN
    sgnl(i).fs = str.(field)(ind).t(2);
        p = str.(field)(ind).p;
    sgnl(i).L = length(p);
        pAverage = sum(p) / sgnl(i).L;
    sgnl(i).p = p - pAverage;
    sgnl(i).dt = 1 / sgnl(i).fs;
    sgnl(i).t = ( (0:sgnl(i).L - 1) * sgnl(i).dt ); % absolute sec
    switch timeAxis
        case 1
            sgnl(i).DT = str.par.DT + seconds(str.(field)(ind).t(1));
        case 2
            sgnl(i).t = sgnl(i).t + in.(field)(ind).t(1);   % relatice sec
            sgnl(i).DT = str.par.DT;
        case 3  % hh:mm:ss
            sgnl(i).t = str.par.DT + seconds(sgnl(i).t + str.(field)(ind).t(1));  % hh:mm:ss
            sgnl(i).DT = str.par.DT + seconds(str.(field)(ind).t(1));
        otherwise
            error('The time format is not defined.')
    end
    
    sgnl(i).T = sgnl(i).L / sgnl(i).fs;

    % SEL calc
    E = sum( (sgnl(i).p * 10^6) .^ 2 ) * sgnl(i).dt;
    sgnl(i).SELt = 10 * log10(E);
    
    % SPLpeak calc
    sgnl(i).SPLpeak = 20 * log10( max( abs( sgnl(i).p * 10^6 ) ) );
    
    %% PSD

if type == 1

    % using Welch method
    % --- full window ---
        nfft1 = 2 ^ nextpow2(sgnl(i).L);	% determine number FFT
    if nfft1 <= lim_fullwindow
        [pxx1, f1] = pwelch(sgnl(i).p .* 10^6, rectwin(sgnl(i).L), 0, nfft1, sgnl(i).fs);
        sgnl(i).f1 = f1;   sgnl(i).psd1 = smooth( f1, 10 * log10(pxx1), 20, 'lowess');   % frequency axis + psd full time

        sgnl(i).SELf = 10 * log10( sum(pxx1) * sgnl(i).L / nfft1);     % full SEL

        [idx1, ~] = find(f1 >= f_sel(1), 1, 'first' );
        [idx2, ~] = find(f1 <= f_sel(2), 1, 'last' );

        sgnl(i).ff = [f1(idx1), f1(idx2)];
        sgnl(i).SELff = 10 * log10( sum(pxx1(idx1:idx2)) * sgnl(i).L / nfft1);     % SEL in frequensy range
    else
        warning('PSD-full window not calculated. Window limit exceeded.');
        sgnl(i).SELf = nan;
        sgnl(i).ff = [nan, nan];
        sgnl(i).SELff = nan;
    end
    
    % --- using Welch's overlapped timeframe ---
        nfft2 = 2 ^ nextpow2( length(window) );
    if nfft2 > lim_fullwindow
        warning('PSD-timeframe not calculated. Window limit exceeded.');
    elseif nfft2 >= nfft1
        pxx2 = pxx1;    f2 = f1;
    else
        [pxx2, f2] = pwelch(sgnl(i).p .* 10^6, window, round( length(window) * overlap), nfft2, sgnl(i).fs);
        sgnl(i).psd2 = 10 * log10( pxx2 );
        sgnl(i).f2 = f2;
    end
    
end
    %% SPECTROGRAM

if type == 2

    switch method
        case 'spectrogram'

        nfft2 = 2 ^ nextpow2( length(window) );
        [S, F, T] = spectrogram(sgnl(i).p .* 10^6, window, round( length(window) * 0.5), nfft2, sgnl(i).fs);
        sgnl(i).specS = 10*log10(abs(S).^2);
        sgnl(i).specF = F;
        switch timeAxis
            case 1  % absolute time
                sgnl(i).specT = T;
            case 2  % relative time
                sgnl(i).specT = T + in.(field)(num).t(1);
            case 3  % hh:mm:ss
                sgnl(i).specT = in.par.DT + seconds(T + str.(field)(ind).t(1));
            otherwise
                error('The time format is not defined.')
        end

        case 'pspectrum'

        TimeResolution = length(window) * sgnl(i).dt;

        [S, F, T] = pspectrum(sgnl(i).p*10^6, sgnl(i).fs,'spectrogram','TimeResolution', TimeResolution, 'OverlapPercent', overlap * 100,'Leakage',0.85);
        % sgnl(i).specS = 10*log10(abs(S).^2);
        % % maxS = max(S);
        % maxValue = max(S, [], 'all');
        sgnl(i).specS = S;
        sgnl(i).specF = F;

        % using stft
        % [S, F, T] = stft(sgnl(i).p .* 10^6, sgnl(i).fd, 'Window', window, 'OverlapLength', overlap*100, 'FFTLength', nfft2);        
        % sgnl(i).specS = 10*log10(abs(S).^2);
        % sgnl(i).specF = F;
        % sgnl(i).specT = T;
        % sgnl(i).specDT = DT + seconds(T);

    end

        switch timeAxis
            case 1  % absolute time
                sgnl(i).specT = T;
            case 2  % relative time
                sgnl(i).specT = T + in.(field)(num).t(1);
            case 3  % hh:mm:ss
                sgnl(i).specT = in.par.DT + seconds(T + str.(field)(ind).t(1));
            otherwise
                error('The time format is not defined.')
        end

end


    fprintf( 'signal %d (%.1f)..', i, toc(timer_signalAnalysis) );

end

fprintf( 'get data (%.1f).\n', toc(timer_signalAnalysis) );
end