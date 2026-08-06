%% Citation: some parts of the codes are written by ChatGPT

%% Reads in data 
path_data = "outputs/Figure2.txt";
d = readtable(path_data);

%% Formats plot 
FONTSIZE = 70;    
FIGSIZE = 36;              
LINEWIDTH = 10;   
LEGEND_SPACE = 17;

%% Generates plots 
figure('Units', 'centimeters', 'Position', ...
    [0 0 FIGSIZE + LEGEND_SPACE FIGSIZE], ...
    'PaperUnits', 'centimeters', ...
    'PaperPositionMode', 'manual', ...
    'PaperPosition', [0 0 FIGSIZE + LEGEND_SPACE FIGSIZE]);
plot(d.alpha, d.perfect, 'k', 'LineWidth', LINEWIDTH);
hold on;
plot(d.alpha, d.dp1, 'Color', [0.9373 0.2784 0.4353], ...
    'LineWidth', LINEWIDTH);
plot(d.alpha, d.gdp1, 'Color', [0.1490 0.3294 0.4863], ...
    'LineWidth', LINEWIDTH);
plot(d.alpha, d.gdp3, 'Color', [0.1490 0.3294 0.4863], ...
    'LineWidth', LINEWIDTH, 'LineStyle', ':'); 
% Legend
legend({'Perfect Privacy', '1-DP', '1-GDP', '3-GDP'}, ...
    'Interpreter', 'latex', 'Location', 'eastoutside');
legendHandle = legend;
legendHandle.FontSize = FONTSIZE; 
legendHandle.Box = 'off';
grid on; 
axis tight;
axis padded;
ax = gca;
ax.FontSize = FONTSIZE;          
ax.TickLabelInterpreter = 'latex';    
ax.Box = 'on';
% forces tick labels to stay horizontal
ax.XTickLabelRotation = 0;
ax.YTickLabelRotation = 0;
% specifies grid settings 
ax.Layer = 'bottom';          
ax.GridColor = [0.2 0.2 0.2]; % dark gray
ax.GridAlpha = 0.9;           
ax.XMinorGrid = 'off';
ax.YMinorGrid = 'off';
% specifies ticks 
ax.XTick = linspace(0, 1, 6);   
ax.YTick = linspace(0, 1, 6);
% Sets titles 
title('Tradeoff Functions', 'FontSize', FONTSIZE, 'Interpreter', 'latex');
xlabel('Significance Level ($\alpha$)', ...
    'FontSize', FONTSIZE, 'Interpreter', 'latex');
ylabel('Type II Error', 'FontSize', FONTSIZE, 'Interpreter', 'latex');
xlim([0,1]);
ylim([0,1]);

%% Saves plots
pbaspect([1 1 1]);
set(gcf, 'Units', 'centimeters', 'Position', ...
    [0, 0, FIGSIZE + LEGEND_SPACE, FIGSIZE]);
fg = gcf;
fg.PaperSize = [fg.PaperPosition(3) fg.PaperPosition(4)];
print(fg, 'plots/Figure2.pdf', '-dpdf');
hold off;
