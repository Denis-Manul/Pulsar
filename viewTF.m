function viewTF(signals, prm)
% Plotting signal graphs in time and frequency domains (maximum 3 signals).
%
% viewTF(signals, prm)
%--------------------------------------------------------------------------
timer_viewTF = tic;

window      = prm.window;       % weight window
overlap     = prm.overlap;      % overlap
f_sel       = prm.f_sel;        % frequency range for SEL
equalAxisX  = prm.equalAxisX;   % the same amplitude axis for all graphs (1) or different (0)
timeAxis    = prm.timeAxis;     % absolute seconds (1), relative seconds (2) or in hh:mm:ss format (3)
freqAxis    = prm.freqAxis;     % frequency range on graphs
dS          = prm.dS;           % difference between the minimum and maximum of the spectrum
%--------------------------------------------------------------------------
    fontSize = 12;              % fontsize for graph
    color = {'r', 'b', 'g'};    % colores of the curves
    linewidth = [0.5, 0.5, 0.5];% line thickness for PSD
    linestyle = {'-', '-', '-',};% line style for PSD

fprintf( '\tviewTF: start --> ' );
%% Loading and Analysis
N = length( signals(:, 1) );
assert( N <= 3 & N >= 1, 'The number of signals less than 1 or more than 3.')

prm.type = 1;
prm.method = '';
sgnl = signalAnalysis( signals, prm );    % loading

fprintf( 'signal(s) loaded (%.1f) --> ', toc(timer_viewTF) );

if length( unique( [sgnl.L] ) ) ~= 1
    warning('The signals have different lengths.')
end

%% Preparing for graphs

% determining the maximum amplitude for graphs
mx1 = 0;    % maximum in time domain
mx2 = 0;    % maximum in frequency domain

for i = 1:N
    mx1 = max(mx1, max( abs(sgnl(i).p)) );
    mx2 = max(mx2, max( abs(sgnl(i).psd2)) );
end

ampT = 1.05 * mx1;    % time axis limits
ampF = 1.05 * mx2;    % frequency axis limits
clear mx1 mx2 i
% -------------------------------------------------------------------------
% graphs positions
% N - number of signals
%
%           PART 1:
%
% size - row x col
% T - Time Domain Subplot
% F - Frequency Domain Subplot
% txt - Text Subplot
% txt_pos - Text Position in text()

switch N
    case 1
sub.size = [1, 5];   % subplot
    sub.T = [1, 2];  sub.F = [3, 4]; sub.txt = [5]; sub.txt_pos = [0.6];
    case 2
sub.size = [2, 5];
    sub.T = [1, 2; 6, 7];  sub.F = [3, 4, 8, 9]; sub.txt = [5, 10]; sub.txt_pos = [0.8, 0.25];
    case 3
sub.size = [3, 5];
    sub.T = [1, 2; 6, 7; 11, 12];  sub.F = [3, 4, 8, 9, 13, 14]; sub.txt = [5, 10, 15]; sub.txt_pos = [0.9, 0.5, 0.1];
end

%% GRAPH
figure('Name','Signal(s) in Time and Frequency Domains', 'Color', [1 1 1],  'Units', 'normalized', 'OuterPosition', [0.01 0.2 0.9 0.7]);

%                           ===========================
%                           === part 1. TIME DOMAIN ===
%                           ===========================

set(0, 'DefaultAxesLabelFontSizeMultiplier', 1);
set(0, 'DefaultAxesTitleFontSizeMultiplier', 1);

for i = 1:N
    
    subplot(sub.size(1), sub.size(2), sub.T(i, :));
    box off
    hold all
    grid on
        
    plot(sgnl(i).t, sgnl(i).p, 'Color', color{i});

    if i == 1; title(sprintf('Time Domain, %s', signals{i, 4}), 'FontWeight', 'normal', 'FontSize', fontSize, 'FontName', 'Arial');
    else title(sprintf('%s', signals{i, 4}), 'FontWeight', 'normal', 'FontSize', fontSize, 'FontName', 'Arial');    end
    if i == N;      xlabel('t, sec');    end
    ylabel('Amplitude')
        
    xlim([sgnl(i).t(1) sgnl(i).t(end)]);
    if equalAxisX == 1;     ylim([-ampT ampT]);     end
    ax = gca;
    ax.XAxis.FontSize = fontSize;
    ax.YAxis.FontSize = fontSize;

end

%                           ================================
%                           === part 1. FREQUENCY DOMAIN ===
%                           ================================

subplot(sub.size(1), sub.size(2), sub.F, ...
    'XTick', [10 20 30 40 50 60 70 80 90 100 200 300 400 500 1000 2000 3000 4000 5000, 10000, 20000, 40000],...
    'XTickLabel',{'10','','30','','50','','','','','100','','','','0.5k','1k', '2k', '3k', '', '5k', '10k', '20k', '40k'}, 'XScale', 'log');
hold('all');
grid on

    for i = 1:N
        if N == 1
            semilogx1 = semilogx(sgnl.f1, sgnl.psd1, 'Color', [0.8, 0.8, 0.8], 'LineWidth', 1, 'LineStyle', '-');
        end
            semilogx( sgnl(i).f2, sgnl(i).psd2, 'Color', color{i}, 'LineWidth', linewidth(i), 'LineStyle', linestyle{i});
    end

    title('Frequency Domain', 'FontWeight', 'normal', 'FontSize', fontSize, 'FontName', 'Arial');
    xlabel('f, Hz');
    ylabel('PSD(f), dB re 1 mkPa^{2} / Hz')
    
    ylim([ampF - dS ampF]);
    xlim(freqAxis);
    ax = gca;   % not rotation of marks on the axis
    ax.XTickLabelRotation = 0;
    ax.XAxis.FontSize = fontSize;
    ax.YAxis.FontSize = fontSize;

%                           =========================
%                           === part 1. BILLBOARD ===
%                           =========================

subplot(sub.size(1), sub.size(2), sub.txt, 'ZColor', [1 1 1], 'YColor', [1 1 1], 'XColor', [1 1 1]);

if N == 1   % detailed information for single signal

    text(0, sub.txt_pos(i), ...
        sprintf(['\n[Signal] %s\n' ...
                   '[Field] %s\n' ...
                   '[Channel] %d\n\n' ... 
                   '[Point name]  %s\n' ...
                   '[Timeframe] %s\n' ...
                   '[Horizont (VLA)] %.2f m\n' ...
                   '[Distance (HLA)] %.2f m\n\n' ...
                   '[Sampling Freq]  %.1f Hz\n' ...
                   '[Duration]  %.3f sec (%.2f min)\n' ...
                   '[Points]  %d\n'...
                   '[SPLpeak]  %.1f dB re 1 mkPa\n' ...
                   '[SEL_T]  %.1f dB re 1 mkPa^{2} sec\n' ...
                   '[SEL_F]  %.1f dB re 1 mkPa^{2} s\n' ...
                   '[SEL(f)]  %.1f dB in %.1f - %.1f Hz\n\n' ...
                   '[Timeframe for PSD]  %.2f sec (total %.3f sec)\n' ...
                   '[Overlap for PSD]  %.2f'], ...
        signals{4}, signals{2}, signals{3}, sgnl.par.pointName,  ...
        datestr(sgnl(1).DT), sgnl.z, sgnl.d, sgnl.fs, sgnl.T, sgnl.T/60, sgnl.L, sgnl.SPLpeak, ...
        sgnl.SELt, sgnl.SELf, sgnl.SELff, sgnl.ff(1), sgnl.ff(2), ...
        length(window) * sgnl.dt, sgnl.T, overlap), ...
        'Color', color{1}, 'FontName', 'Arial', 'FontSize', 10)

else

    for i = 1:N     % brief information for several signals

        text(0, sub.txt_pos(i), ...
            sprintf(['\n[Signal] %s\n' ...
                     '  [Timeframe] %s\n' ...
                     '  [Sampling Freq]  %.1f Hz\n' ...
                     '  [Duration]  %.3f sec (%.2f min)\n' ...
                     '  [Points]  %d\n' ...
                     '  [SPLpeak]  %.1f dB re 1 mkPa\n' ...
                     '  [SEL_T]  %.1f dB re 1 mkPa^{2} sec\n' ...
                     '  [SEL(f)]  %.1f dB in %.1f - %.1f Hz\n'], ...
        signals{i, 4}, datestr(sgnl(i).DT), sgnl(i).fs, sgnl(i).T, ...
        sgnl(i).T/60, sgnl(i).L, sgnl(i).SPLpeak, ...
        sgnl(i).SELt, sgnl(i).SELff, sgnl(i).ff(1), sgnl(i).ff(2)), ...
        'Color', color{i}, 'FontName', 'Arial', 'FontSize', 10)

    end
end

fprintf( 'the graph is built (%.1f).\n', toc(timer_viewTF) );
end