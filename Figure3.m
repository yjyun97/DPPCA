%% Citation: some parts of the codes are written by ChatGPT

%% Specifies data
WHICH_DATA = "1000Genomes"; % 1000Genomes, survey

%% Formats plot 
% sets size 
FONTSIZE = 85;
FIGSIZE = 36;     
MARKERSIZE = 20;
LINEWIDTH = 8;
LEGEND_SPACE = 15; 
fig = figure('Units', 'centimeters', 'Position',...
    [0 0 FIGSIZE * 2.4 FIGSIZE + LEGEND_SPACE],...  
    'PaperUnits', 'centimeters', 'PaperPositionMode', 'manual',...
    'Renderer', 'painters');  
tcl = tiledlayout(fig,1,2,'TileSpacing','loose','Padding','loose');

%% Specifies plot components 
vec_k = 1:3;
vec_cutoff = readtable("outputs/" + WHICH_DATA + "_Figure3_thresholds.txt");
colors = [0.1490 0.3294 0.4863;
    0.9373 0.2784 0.4353;
    1.0000 0.8196 0.4000];

%% Generates plot 
function make_error_plot(ax, which_error, vec_k, colors,...
    FONTSIZE, MARKERSIZE, LINEWIDTH, vec_cutoff, WHICH_DATA)
    hold(ax,'on')
    for cur_col = 1:3
        k = vec_k(cur_col);
        path_data_e = "outputs/" + WHICH_DATA + "_Figure3_empirical_" +...
            which_error +...
            "_k" + string(k) + ".txt";
        path_data_t = "outputs/" + WHICH_DATA + "_Figure3_theoretical_" +...
            which_error + "_k" + string(k) + ".txt";
        d_e = readtable(path_data_e);
        d_t = readtable(path_data_t);
        plot(ax, d_t.beta, d_t.error, '-',...
            'Color', colors(cur_col,:), 'LineWidth', LINEWIDTH);
        plot(ax, d_e.beta, d_e.error, 'o',...
            'MarkerSize', MARKERSIZE, 'MarkerEdgeColor', 'k',...
            'MarkerFaceColor', colors(cur_col,:));
    end
    for c = 1:numel(vec_cutoff.Hvec)
        xline(ax, vec_cutoff.Hvec(c), ':', ...
            'Color', [0 0 0], ...   
            'LineWidth', 8, ...     
            'HandleVisibility','off');
    end
    grid(ax,'on'); 
    pbaspect(ax,[1 1 1]); 
    axis(ax,'padded');
    ax.FontSize = FONTSIZE; 
    ax.TickLabelInterpreter = 'latex'; 
    ax.Box = 'on';
    ax.Layer = 'bottom';
    ax.GridColor = [0.2 0.2 0.2];
    ax.GridAlpha = 0.9;
    xlabel(ax, '$\beta$', 'FontSize', FONTSIZE, 'Interpreter', 'latex');
    if which_error == "op"
        ylabel(ax,'Operator Norm Error', 'FontSize', FONTSIZE, ...
            'Interpreter', 'latex');
    else
        ylabel(ax, 'Frobenius Norm Error', 'FontSize', FONTSIZE, ...
            'Interpreter','latex');
    end
end

%% Make the two subplots
ax1 = nexttile(tcl);
make_error_plot(ax1, "op", vec_k, colors, FONTSIZE, MARKERSIZE, LINEWIDTH, ...
    vec_cutoff, WHICH_DATA);
ax2 = nexttile(tcl);
make_error_plot(ax2, "Fro", vec_k, colors, FONTSIZE, MARKERSIZE, LINEWIDTH, ...
    vec_cutoff, WHICH_DATA);
hColor = gobjects(1,3);
for cur_col = 1:3
    hColor(cur_col) = plot(ax1, nan, nan, '-',...
        'Color', colors(cur_col,:), 'LineWidth', LINEWIDTH,...
        'DisplayName', sprintf('$k=%d$', vec_k(cur_col)));
end
hSolid  = plot(ax1, nan, nan, '-', 'Color', 'k', 'LineWidth', LINEWIDTH,...
               'DisplayName', 'Theoretical$\hspace{5pt}$');
hMarker = plot(ax1, nan, nan, 'o', 'Color', 'k', 'MarkerFaceColor', 'k',...
               'MarkerSize', MARKERSIZE, 'DisplayName', 'Empirical');
leg = legend([hColor hSolid hMarker], ...
    'Interpreter', 'latex', 'Orientation', 'horizontal');
leg.FontSize = FONTSIZE;
leg.Box = 'off';
leg.Layout.Tile = 'south'; 
leg.NumColumns = 3;
leg.ItemTokenSize = [100, 40];

%% Saves plots
pbaspect(ax1,[1 1 1]); 
pbaspect(ax2,[1 1 1]);
fig.Units='centimeters'; 
figPos=fig.Position;  
fig.PaperUnits='centimeters';
fig.PaperPosition=[0 0 figPos(3) figPos(4)];
fig.PaperSize=[figPos(3) figPos(4)];
print(fig,"plots/" + WHICH_DATA + "_Figure3.pdf",'-dpdf','-painters');