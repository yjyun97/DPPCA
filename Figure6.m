%% Citation: some parts of the codes are written by ChatGPT

%% Specifies data
WHICH_DATA = "1000Genomes"; % 1000Genomes, survey

%% Formats plot
% sets size
FONTSIZE = 80;
FIGSIZE = 36;
MARKERSIZE = 20;
LINEWIDTH = 8;
LEGEND_SPACE = 12;
fig = figure('Units', 'centimeters', 'Position',...
    [0 0 FIGSIZE * 3.4 FIGSIZE + LEGEND_SPACE],...
    'PaperUnits', 'centimeters', 'PaperPositionMode', 'manual');
tcl = tiledlayout(fig, 1, 3, 'TileSpacing', 'loose', 'Padding', 'loose');

%% Specifies plot components
vec_k = [1 2 3];
if WHICH_DATA == "1000Genomes"
    beta_map = containers.Map( ...
        {1, 2, 3}, ...
        { [0.5, 1, 2, 4, 8], [1, 2, 4, 8], [2, 4, 8] } );
elseif WHICH_DATA == "survey"
    beta_map = containers.Map( ...
        {1, 2, 3}, ...
        { [0.5, 1, 2, 4, 8], [0.5, 1, 2, 4, 8], [0.5, 1, 2, 4, 8] } );
end
palette = [0.5765 0.5059 1.0000;
           0.1490 0.3294 0.4863;
           0.0235 0.8392 0.6275;
           1.0000 0.8196 0.4000;
           0.9373 0.2784 0.4353];
all_beta = [0.5, 1, 2, 4, 8];
colors = palette;
function col = beta_color(b, all_beta, colors)
    idx = find(all_beta == b, 1);
    col = colors(idx,:);
end

%% Generates plots
function make_privacy_plot(ax, k, beta_map, all_beta, colors, ...
    FONTSIZE, MARKERSIZE, LINEWIDTH, WHICH_DATA)

    hold(ax,'on')
    betas = beta_map(k);

    for s = numel(betas):-1:1
        b = betas(s);
        col = beta_color(b, all_beta, colors);

        % File paths (beta)
        path_data_e = "outputs/" + WHICH_DATA + "_Figure6_empirical_k" +...
            string(k) + ...
            "_beta" + string(b) + ".txt";
        path_data_t = "outputs/" + WHICH_DATA + "_Figure6_theoretical_k" +...
            string(k) + ...
            "_beta" + string(b) + ".txt";

        d_e = readtable(path_data_e);
        d_t = readtable(path_data_t);

        % theoretical
        plot(ax, d_t.alpha, d_t.tf, '-', 'Color', col, ...
            'LineWidth', LINEWIDTH);
        % empirical
        plot(ax, d_e.alpha, d_e.tf, 'o', 'MarkerSize', MARKERSIZE, ...
            'MarkerEdgeColor', 'k', 'MarkerFaceColor', col);
        % prior work
        plot(ax, d_t.alpha, d_t.tf_prior, '--', 'Color', col, ...
            'LineWidth', LINEWIDTH);
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
    ax.XMinorGrid = 'off';
    ax.YMinorGrid = 'off';
    ax.XTick = 0:0.2:1;
    ax.YTick = 0:0.2:1;
    ax.XTickLabelRotation = 0;
    xlabel(ax,'Significance Level ($\alpha$)', ...
        'FontSize', FONTSIZE, 'Interpreter','latex');
    ylabel(ax,'Type II Error', ...
        'FontSize', FONTSIZE, 'Interpreter','latex');
    title(ax, sprintf('$k=%d$', k), ...
        'FontSize', FONTSIZE, 'Interpreter','latex');
    xlim(ax,[0 1]);
    ylim(ax,[0 1]);
end

ax = gobjects(1,3);
for i = 1:3
    ax(i) = nexttile(tcl);
    make_privacy_plot(ax(i), vec_k(i), beta_map, all_beta, colors, ...
        FONTSIZE, MARKERSIZE, LINEWIDTH, WHICH_DATA);
end

% Generates legend
hColor = gobjects(1, numel(all_beta));
for s = 1:numel(all_beta)
    hColor(s) = plot(ax(1), nan, nan, '-', 'Color', colors(s,:), ...
        'LineWidth', LINEWIDTH, 'DisplayName', ...
        sprintf('$\\beta=%g\\hspace{22pt}$', all_beta(s)));
end

hTheoretical = plot(ax(1), nan, nan, '-', 'Color', 'k', ...
    'LineWidth', LINEWIDTH, 'DisplayName','Theoretical$\hspace{5pt}$');
hEmpirical = plot(ax(1), nan, nan, 'o', 'Color', 'k', 'MarkerFaceColor', 'k', ...
    'MarkerSize', MARKERSIZE, 'DisplayName', 'Empirical$\hspace{5pt}$');
hPrior = plot(ax(1), nan, nan, '--', 'Color', 'k', 'LineWidth', LINEWIDTH, ...
    'DisplayName', 'Prior Work');

leg = legend([hColor hTheoretical hEmpirical hPrior], ...
    'Interpreter', 'latex', 'Orientation', 'horizontal');
leg.FontSize = FONTSIZE;
leg.Box = 'off';
leg.Layout.Tile = 'south';
leg.NumColumns = max(numel(all_beta), 3);
leg.ItemTokenSize = [100,40];

%% Saves plots
fig.Units = 'centimeters';
figPos = fig.Position;
fig.PaperUnits = 'centimeters';
fig.PaperPosition = [0 0 figPos(3) figPos(4)];
fig.PaperSize = [figPos(3) figPos(4)];
print(fig,"plots/" + WHICH_DATA + "_Figure6.pdf",'-dpdf','-painters');