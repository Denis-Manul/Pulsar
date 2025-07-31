function viewSpec(signals, prm)
% Plotting spectrograms (maximum 3 signals).
%
% viewSpec(signals, prm)
%--------------------------------------------------------------------------
timer_viewSpec = tic;

window      = prm.window;       % weight window
overlap     = prm.overlap;      % overlap
method      = prm.method;       % 'spectrogram' / 'pspectrum'
timeAxis    = prm.timeAxis;     % absolute seconds (1), relative seconds (2) or in hh:mm:ss format (3)
freqAxis    = prm.freqAxis;     % frequency range on graphs
CAxis       = prm.CAxis;        % scale range
%--------------------------------------------------------------------------
    fontSize = 12;              % fontsize for graph
    color = {'k', 'b', 'g'};    % colores of the curves

fprintf( '\tviewSpec: start --> ' );
%% Loading and Analysis
N = length( signals(:, 1) );
assert( N <= 3 & N >= 1, 'The number of signals less than 1 or more than 3.')

prm.f_sel = [10, 20];
prm.type = 2;
sgnl = signalAnalysis( signals, prm );    % loading

fprintf( 'signal(s) loaded (%.1f) --> ', toc(timer_viewSpec) );

if length( unique( [sgnl.L] ) ) ~= 1
    warning('The signals have different lengths.')
end

%% Preparing for graphs

% graphs positions
% N - number of signals
%
% spec_size:    row x col
% spec_graph:   Spectrogram Subplot
% spec_txt:     Text Subplot

switch N
    case 1
    sub.spec_size = [3, 9];  sub.spec_graph = [10:16, 19:25];  sub.spec_txt = [8:9];
    case 2
    sub.spec_size = [2, 9];  sub.spec_graph = [1:7; 10:16];  sub.spec_txt = [8:9; 17:18];
    case 3
    sub.spec_size = [3, 9];  sub.spec_graph = [1:7; 10:16; 19:25];  sub.spec_txt = [8:9; 17:18; 26:27];
end

%% GRAPH
if N == 1
figure('Name','Spectrogram', 'Color', [1 1 1], 'Units', 'normalized', 'OuterPosition', [0.1 0.2 0.6 0.7]);

%                   ===========================
%                   === Single. TIME DOMAIN ===
%                   ===========================

    subplot(sub.spec_size(1), sub.spec_size(2), [1:7]); 
    box off
    hold all
    grid on

        plot(sgnl.t, sgnl.p, 'Color', color{1});

        title(sprintf('Time Domain & Spectrogram, dB, %s', signals{1, 4}), 'FontWeight', 'normal', 'FontSize', fontSize, 'FontName', 'Arial');
        ylabel('Amplitude');

        xlim([sgnl.t(1), sgnl.t(end)]);
        ax = gca;
        ax.XAxis.FontSize = fontSize;
        ax.YAxis.FontSize = fontSize;

%                       ================================
%                       === Single. FREQUENCY DOMAIN ===
%                       ================================

    subplot(sub.spec_size(1), sub.spec_size(2), sub.spec_graph);
    box off
    hold all
    grid on

        surf(sgnl.specT, sgnl.specF, sgnl.specS, 'EdgeColor', 'none');

        xlabel('Time, sec');
        ylabel('Frequency, Hz');
            
        xlim([sgnl.t(1), sgnl.t(end)]);
        view(2);
        ylim(freqAxis);
        set(gca, 'CLim', CAxis);

        c = colorbar;
        c.Location = 'eastoutside';
        c.FontName = 'Arial';
        c.FontSize = 10;
        colormap parula;
        
        ax = gca;
        ax.Position = ax.Position + [0 0 0 0];
        ax.XAxis.FontSize = fontSize;
        ax.YAxis.FontSize = fontSize;

%                       =================================
%                       === part 2. Single. BILLBOARD ===
%                       =================================

    subplot(sub.spec_size(1), sub.spec_size(2), sub.spec_txt); 
    box off
    hold all
    grid on
    axis off;

    text(0.1, 0.6, ...
        sprintf(['[Signal]  %s\n' ...
                 ' [Timeframe] %s\n' ...
                 ' [Points]  %d\n' ...
                 ' [Sampling Freq]  %.1f Hz\n' ...
                 ' [FFT pts]  %d\n' ...
                 ' [FFT timeframe]  %.2f sec\n' ...
                 ' [Overlap]  %.2f\n' ...
                 ' [Slices] %d'], ...
        signals{4}, datestr(sgnl(1).DT), sgnl.L, sgnl.fs, ...
        2 ^ nextpow2( length(window)), length(window) * sgnl.dt, overlap, length(sgnl.specT)), ...
        'FontName', 'Arial', 'Fontsize', 10)

%% Graph. FEW SPECTROGRAMs
else

figure('Name','Spectrogram', 'Color', [1 1 1], 'Units', 'normalized', 'OuterPosition', [0.1 0.2 0.6 0.7]);

%                   =====================================
%                   === part 2. FEW. FREQUENCY DOMAIN ===
%                   =====================================
    for i = 1:N

    subplot(sub.spec_size(1), sub.spec_size(2), sub.spec_graph(i, :));
    box('off');
    hold('all');
    grid on

        surf(sgnl(i).specT, sgnl(i).specF, sgnl(i).specS, 'EdgeColor', 'none');
            
        if i == 1;      title(sprintf('Spectrogram, dB, %s', signals{i, 4}), 'FontWeight', 'normal', 'FontSize', fontSize, 'FontName', 'Arial');
        else title(sprintf('%s', signals{i, 4}), 'FontWeight', 'normal', 'FontSize', fontSize, 'FontName', 'Arial'); end
        ylabel('Frequency, Hz');
        if i == N;  xlabel('Time, sec'); end
          
        c = colorbar;
        c.FontName = 'Arial';
        c.FontSize = 10;
        colormap parula;
    
        xlim([sgnl(i).t(1), sgnl(i).t(end)]);
        ylim(freqAxis);
        set(gca, 'CLim', CAxis);

        ax = gca;
        ax.XAxis.FontSize = fontSize;
        ax.YAxis.FontSize = fontSize;
        view(2);

%                       ======================
%                       === Few. BILLBOARD ===
%                       ======================
    subplot(sub.spec_size(1), sub.spec_size(2), sub.spec_txt(i, :));
    box off
    hold all
    grid on
    axis off;

    text(0, 1, ...
        sprintf(['[Signal]  %s\n' ...
                 ' [Timeframe] %s\n' ...
                 ' [Points]  %d\n' ...
                 ' [Sampling Freq]  %.1f Hz\n' ...
                 ' [FFT pts]  %d\n' ...
                 ' [FFT timeframe]  %.2f sec\n' ...
                 ' [Overlap]  %.2f\n' ...
                 ' [Slices] %d'], ...
        signals{i, 4}, datestr(sgnl(i).DT), sgnl(i).L,...
        sgnl(i).fs, 2 ^ nextpow2( length(window) ), length(window) * sgnl(i).dt, overlap, length(sgnl.specT)), ...
        'FontName', 'Arial', 'FontSize', 10, 'VerticalAlignment', 'top')

    end
end

fprintf( 'the graph is built (%.1f).\n', toc(timer_viewSpec) );

end