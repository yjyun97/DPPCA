%% Citation: some parts of the codes are written by ChatGPT

%% Specifies data
WHICH_DATA = "1000Genomes"; % 1000Genomes, survey

%% Formats plot 
TILESIZE = 36;
LEGEND_SPACE = 8;
FONTSIZE = 105;
LINEWIDTH = 10;
MARKERSIZE = 22;
GRIDCOLOR = [0.2 0.2 0.2];

fig = figure('Units','centimeters', ...
    'Position',[0 0 TILESIZE * 3.1 TILESIZE * 2 + LEGEND_SPACE], ...
    'PaperUnits','centimeters','PaperPositionMode','manual', ...
    'Renderer','painters');

tcl = tiledlayout(fig,2,3,'TileSpacing','compact','Padding','compact');

%% Specifies plot components
vec_col = [0.1490 0.3294 0.4863;
           0.9373 0.2784 0.4353;
           1.0000 0.8196 0.4000;
           0.5765 0.5059 1.0000;
           0.0235 0.8392 0.6275];

if WHICH_DATA == "1000Genomes"

    vec_names  = {'African', 'Hispanic', 'East Asian', 'European', 'South Asian'};

    vec_names_legend = {'African$\hspace{5pt}$', ...
        'Hispanic$\hspace{5pt}$', ...
        'East Asian$\hspace{5pt}$', ...
        'European$\hspace{5pt}$', ...
        'South Asian'};

    % Corresponding to beta = [0, 0.5, 1, 2, 4, 8]
    priv_vals = [NaN, NaN, 0.46, 0.68, 1, 1.46];

elseif WHICH_DATA == "survey"

    vec_col = [1.0000 0.8196 0.4000;
               0.0235 0.8392 0.6275;
               0.1490 0.3294 0.4863;
               0.9373 0.2784 0.4353];

    vec_names  = {'Independent', 'Other', 'Democrat', 'Republican'};

    vec_names_legend = {'Independent$\hspace{5pt}$', ...
        'Other', ...
        'Democrat$\hspace{5pt}$', ...
        'Republican$\hspace{5pt}$'};

    % Corresponding to beta = [0, 0.5, 1, 2, 4, 8]
    priv_vals = [NaN, 0.23, 0.41, 0.65, 0.97, 1.41];

end

beta_vals = [0, 0.5, 1, 2, 4, 8];

%% Generates plots
proj_files = arrayfun(@(b) "outputs/" + WHICH_DATA + "_Figure4_projections_" ...
    + string(b) + ".txt", ...
    beta_vals, 'UniformOutput', false);

%% Creates titles
proj_titles = cell(1,numel(beta_vals));

for j = 1:numel(beta_vals)

    % beta = 0
    if beta_vals(j) == 0

        proj_titles{j} = 'Non-private';

    % beta = 0.5 for 1000Genomes
    elseif beta_vals(j) == 0.5 && WHICH_DATA == "1000Genomes"

        proj_titles{j} = '$\beta = 0.5$';

    % All other cases
    else

        proj_titles{j} = sprintf('$\\beta = %g$ (%g-AGDP)', ...
            beta_vals(j), priv_vals(j));

    end
end

%% Determines common axis limits
% For 1000Genomes, beta = 0.5 is intentionally empty.
% For survey, beta = 0.5 contains data.

x_all = [];
y_all = [];

for j = 1:numel(proj_files)

    % Skip beta = 0.5 only for 1000Genomes
    if WHICH_DATA == "1000Genomes" && beta_vals(j) == 0.5
        continue
    end

    dtmp = readtable(proj_files{j});

    x_all = [x_all; dtmp.x];
    y_all = [y_all; dtmp.y];

end

xr = max(x_all) - min(x_all);
yr = max(y_all) - min(y_all);

pad = 0.05;

xlim_all = [min(x_all)-pad*xr, max(x_all)+pad*xr];
ylim_all = [min(y_all)-pad*yr, max(y_all)+pad*yr];

h_pop = gobjects(1,numel(vec_names));

%% Generates plots
for j = 1:numel(proj_files)

    ax = nexttile(tcl,j);
    hold(ax,'on');

    % Leave beta = 0.5 empty only for 1000Genomes
    if ~(WHICH_DATA == "1000Genomes" && beta_vals(j) == 0.5)

        d = readtable(proj_files{j});
        d.labels = string(d.labels);

        for i = 1:numel(vec_names)

            mask = (d.labels == vec_names{i});

            if any(mask)

                p = plot(ax, d.x(mask), d.y(mask), 'o', ...
                    'MarkerSize', MARKERSIZE, ...
                    'MarkerEdgeColor','k', ...
                    'MarkerFaceColor', vec_col(i,:), ...
                    'LineWidth', 1.2, ...
                    'DisplayName', vec_names{i});

            else

                p = plot(ax, NaN, NaN, 'o', ...
                    'MarkerSize', MARKERSIZE, ...
                    'MarkerEdgeColor','k', ...
                    'MarkerFaceColor', vec_col(i,:), ...
                    'DisplayName', vec_names{i});

            end

            % Capture legend handles from first panel
            if j == 1
                h_pop(i) = p;
            end

        end
    end

    %% Formatting
    grid(ax,'on');

    ax.Layer = 'bottom';
    ax.GridColor = GRIDCOLOR;
    ax.GridAlpha = 0.9;

    axis(ax,'equal');
    pbaspect(ax,[1 1 1]);

    ax.FontSize = FONTSIZE;
    ax.TickLabelInterpreter = 'latex';
    ax.Box = 'on';

    xlim(ax, xlim_all);
    ylim(ax, ylim_all);

    title(ax, proj_titles{j}, ...
        'FontSize', FONTSIZE, ...
        'Interpreter','latex');

    xlabel(ax,'PC 1', ...
        'FontSize',FONTSIZE, ...
        'Interpreter','latex');

    ylabel(ax,'PC 2', ...
        'FontSize',FONTSIZE, ...
        'Interpreter','latex');

end

%% Creates legend
if WHICH_DATA == "survey"

    legend_order = [3 4 1 2];

    leg = legend(h_pop(legend_order), ...
        vec_names_legend(legend_order), ...
        'Interpreter', 'latex', ...
        'Orientation','horizontal');

else

    leg = legend(h_pop, ...
        vec_names_legend, ...
        'Interpreter', 'latex', ...
        'Orientation','horizontal');

end

leg.FontSize = FONTSIZE;
leg.Layout.Tile = 'south';
leg.Box = 'off';
leg.NumColumns = numel(h_pop);

tcl.TileSpacing = 'compact';
tcl.Padding = 'compact';

%% Saves plots
fig.Units = 'centimeters';
figPos = fig.Position;

fig.PaperUnits = 'centimeters';
fig.PaperPosition = [0 0 figPos(3) figPos(4)];
fig.PaperSize = [figPos(3) figPos(4)];

print(fig, ...
    'plots/' + WHICH_DATA + '_Figure4.pdf', ...
    '-dpdf','-painters');