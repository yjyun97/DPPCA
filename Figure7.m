%% Citation: some parts of the codes are written by ChatGPT

%% Specifies data
WHICH_DATA = "1000Genomes"; % 1000Genomes, survey

%% Reads in data 
path_data = {"outputs/" + WHICH_DATA + "_Figure7_vanilla.txt",... 
    "outputs/" + WHICH_DATA + "_Figure7_rank.txt"};

%% Formats plot 
% sets size
FONTSIZE = 170;
FIGSIZE = 70;
MARKERSIZE = 22;
LEGEND_SPACE = 25;
fig = figure('Units', 'centimeters', 'Position', ...
    [0 0 FIGSIZE * 2.1 + LEGEND_SPACE FIGSIZE + LEGEND_SPACE], ...
    'PaperUnits', 'centimeters', ...
    'PaperPositionMode', 'manual', ...
    'PaperPosition', [0 0 FIGSIZE * 2.1 + LEGEND_SPACE FIGSIZE + LEGEND_SPACE]);
tcl = tiledlayout(fig, 1, 2, 'TileSpacing', 'compact', 'Padding', 'compact');

%% Specifies plot components 
list_title = {'Standard Normalization', 'Rank Normalization'};
vec_col = [0.1490 0.3294 0.4863;
           0.9373 0.2784 0.4353;
           1.0000 0.8196 0.4000;
           0.5765 0.5059 1.0000;
           0.0235 0.8392 0.6275];
if WHICH_DATA == "1000Genomes"
    vec_names  = {'African', 'Hispanic', 'East Asian', 'European', 'South Asian'};
    vec_names_legend = {'African$\hspace{5pt}$', 'Hispanic$\hspace{5pt}$',...
              'East Asian$\hspace{5pt}$', 'European$\hspace{5pt}$',...
              'South Asian'};
elseif WHICH_DATA == "survey"
    vec_col = [1.0000 0.8196 0.4000;
           0.0235 0.8392 0.6275;
           0.1490 0.3294 0.4863;
           0.9373 0.2784 0.4353];
    vec_names  = {'Independent', 'Other', 'Democrat', 'Republican'};
    vec_names_legend = {'Independent$\hspace{5pt}$', 'Other',... 
        'Democrat$\hspace{5pt}$', 'Republican$\hspace{5pt}$'};
end
if WHICH_DATA == "1000Genomes"
    num_item = 5;
elseif WHICH_DATA == "survey"
    num_item = 4;
end

%% Generates plots 
h = gobjects(2,num_item);
for j = 1:2
    ax = nexttile(tcl); 
    hold(ax,'on')
    d = readtable(path_data{j});
    d.labels = string(d.labels);
    for i = 1:num_item 
        mask = (d.labels == vec_names{i});
        if any(mask)
            p = plot(ax, d.x(mask), d.y(mask), 'o', ...
                'MarkerSize', MARKERSIZE, 'MarkerEdgeColor', 'k', ...
                'MarkerFaceColor', vec_col(i,:), ...
                'LineWidth', 1.2, ...
                'DisplayName', vec_names{i});
        else
            p = plot(ax, NaN, NaN, 'o', ...
                'MarkerSize', MARKERSIZE, 'MarkerEdgeColor', 'k', ...
                'MarkerFaceColor', vec_col(i,:), ...
                'LineWidth', 1.2, ...
                'DisplayName', vec_names{i});
        end
        h(j,i) = p;  
    end
    grid(ax,'on');
    axis(ax,'equal');
    pbaspect(ax, [1 1 1]);
    ax.FontSize = FONTSIZE;
    ax.TickLabelInterpreter = 'latex';
    ax.Box = 'on';
    ax.Layer = 'bottom';
    ax.GridColor = [0.2 0.2 0.2];
    ax.GridAlpha = 0.9;
    % sets titles
    title(ax, list_title{j}, 'FontSize', FONTSIZE, 'Interpreter', 'latex');
    xlabel(ax, 'PC 1', 'FontSize', FONTSIZE, 'Interpreter', 'latex');
    ylabel(ax, 'PC 2', 'FontSize', FONTSIZE, 'Interpreter', 'latex');
end
% creates legend
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
leg.NumColumns = 5;

%% Saves plots
pbaspect([1 1 1]);
fig.Units = 'centimeters';
figPos = fig.Position;
fig.PaperUnits = 'centimeters';
fig.PaperPosition = [0 0 figPos(3) figPos(4)];
fig.PaperSize = [figPos(3) figPos(4)];
print(fig,'plots/' + WHICH_DATA + '_Figure7.pdf', '-dpdf', '-painters');
hold off;