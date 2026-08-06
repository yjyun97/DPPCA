%% Citation: some parts of the codes are written by ChatGPT

%% Specifies data
WHICH_DATA = "survey"; % 1000Genomes, survey

%% Reads in data 
path_data = {"outputs/" + WHICH_DATA + "_Figure1_nonPriv.txt", ...
    "outputs/" + WHICH_DATA + "_Figure1_0.01.txt", ...
    "outputs/" + WHICH_DATA + "_Figure1_0.2.txt", ...
    "outputs/" + WHICH_DATA + "_Figure1_1.2.txt"};

%% Formats plot 
% sets size
FONTSIZE = 105;
FIGSIZE = 36;
MARKERSIZE = 22;
LEGEND_SPACE = 8;
fig = figure('Units', 'centimeters', 'Position',...
    [0 0 FIGSIZE * 4.8 FIGSIZE + LEGEND_SPACE],...
    'PaperUnits', 'centimeters', 'PaperPositionMode', 'manual',...
    'PaperPosition', [0 0 FIGSIZE * 4.8 FIGSIZE + LEGEND_SPACE]);
if WHICH_DATA == "survey"
    fig = figure('Units', 'centimeters', 'Position',...
    [0 0 FIGSIZE * 5 FIGSIZE + LEGEND_SPACE],...
    'PaperUnits', 'centimeters', 'PaperPositionMode', 'manual',...
    'PaperPosition', [0 0 FIGSIZE * 4.8 FIGSIZE + LEGEND_SPACE]);
end
tcl = tiledlayout(fig, 1, 4, 'TileSpacing', 'none', 'Padding', 'compact');
% sets limits for the x and y axes
x_all = [];
y_all = [];
for j = 1:4
    d = readtable(path_data{j});
    x_all = [x_all; d.x];
    y_all = [y_all; d.y];
end
xrange = max(x_all) - min(x_all);
yrange = max(y_all) - min(y_all);
pad_ratio = 0.05; % 5% margin on each side
xlim_all = [min(x_all) - pad_ratio * xrange, max(x_all) + pad_ratio * xrange];
ylim_all = [min(y_all) - pad_ratio * yrange, max(y_all) + pad_ratio * yrange];

%% Specifies plot components 
% sets colors and legend items 
vec_col = [0.1490 0.3294 0.4863;
           0.9373 0.2784 0.4353;
           1.0000 0.8196 0.4000;
           0.5765 0.5059 1.0000;
           0.0235 0.8392 0.6275];
if WHICH_DATA == "1000Genomes"
    vec_names = {'African', 'Hispanic', 'East Asian', 'European', 'South Asian'};
    vec_names_legend = {'African$\hspace{5pt}$', 'Hispanic$\hspace{5pt}$',...
              'East Asian$\hspace{5pt}$', 'European$\hspace{5pt}$',...
              'South Asian'};
    % sets titles 
    list_title = {'Non-private', ...
        '$\beta = 0.01$ (0.16-DP)', ...
        '$\beta = 0.2$ (3.19-DP)', ...
        '$\beta = 1.2$ (19.17-DP)'};
elseif WHICH_DATA == "survey"
    vec_col = [1.0000 0.8196 0.4000;
           0.0235 0.8392 0.6275;
           0.1490 0.3294 0.4863;
           0.9373 0.2784 0.4353];
    vec_names = {'Independent', 'Other', 'Democrat', 'Republican'};
    vec_names_legend = {'Independent$\hspace{5pt}$', 'Other',... 
        'Democrat$\hspace{5pt}$', 'Republican$\hspace{5pt}$'};
    % sets titles 
    list_title = {'Non-private', ...
        '$\beta = 0.01$ (0.07-DP)', ...
        '$\beta = 0.2$ (1.48-DP)', ...
        '$\beta = 1.2$ (8.88-DP)'};
end

%% Generates plots 
if WHICH_DATA == "1000Genomes"
    num_item = 5;
elseif WHICH_DATA == "survey"
    num_item = 4;
end
h = gobjects(4,num_item);
for j = 1:4
    ax = nexttile(tcl);
    hold(ax,'on');
    d = readtable(path_data{j});
    d.labels = string(d.labels);
    for i = 1:num_item
        mask = (d.labels == vec_names{i});
        if any(mask)
            p = plot(ax, d.x(mask), d.y(mask), 'o', ...
                'MarkerSize', MARKERSIZE, ...
                'MarkerEdgeColor', 'k', ...
                'MarkerFaceColor', vec_col(i,:), ...
                'LineWidth', 1.2, ...
                'DisplayName', vec_names{i});
        else
            p = plot(ax, NaN, NaN, 'o', ...
                'MarkerSize', MARKERSIZE, ...
                'MarkerEdgeColor', 'k', ...
                'MarkerFaceColor', vec_col(i,:), ...
                'LineWidth', 1.2, ...
                'DisplayName', vec_names{i});
        end
        h(j,i) = p;
    end
    % specifies grid settings 
    grid(ax,'on');
    ax.Layer = 'bottom';
    ax.GridColor = [0.2 0.2 0.2];
    ax.GridAlpha = 0.9;
    ax.XMinorGrid = 'off';
    ax.YMinorGrid = 'off';
    axis(ax,'equal');
    pbaspect(ax,[1 1 1]);
    ax.FontSize = FONTSIZE;
    ax.TickLabelInterpreter = 'latex';
    ax.Box = 'on';
    % sets axis limits 
    xlim(ax, xlim_all);
    ylim(ax, ylim_all);
    % sets titles
    title(ax, list_title{j}, 'FontSize', FONTSIZE, 'Interpreter','latex');
    xlabel(ax, 'PC 1', 'FontSize', FONTSIZE, 'Interpreter','latex');
    ylabel(ax, 'PC 2', 'FontSize', FONTSIZE, 'Interpreter','latex');
end
% creates legend 
if WHICH_DATA == "survey"
    legend_order = [3 4 1 2];
    leg = legend(h(1, legend_order), vec_names_legend(legend_order), ...
    'Interpreter', 'latex', ...
    'Orientation','horizontal');
else 
    leg = legend(h(1,:), vec_names_legend, 'Interpreter', 'latex', ...
        'Orientation','horizontal');
end
leg.FontSize = FONTSIZE;
leg.Layout.Tile = 'south';
leg.Box = 'off';
leg.NumColumns = num_item;

%% Saves plots
fig.Units = 'centimeters';
figPos = fig.Position;  
fig.PaperUnits   = 'centimeters';
fig.PaperPosition= [0 0 figPos(3) figPos(4)];
fig.PaperSize    = [figPos(3) figPos(4)];
print(fig,'plots/' + WHICH_DATA + '_Figure1.pdf','-dpdf','-painters');
hold off;