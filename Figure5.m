%% Citation: some parts of the codes are written by ChatGPT

%% Specifies data
WHICH_DATA = "survey"; % 1000Genomes, survey

%% Formats plot 
% sets size 
TILESIZE = 50;
LEGEND_SPACE = 8;
FONTSIZE = 100;
LINEWIDTH = 10;
MARKERSIZE = 22; 
GRIDCOLOR = [0.2 0.2 0.2];

fig = figure('Units','centimeters', ...
    'Position',[0 0 TILESIZE + LEGEND_SPACE TILESIZE], ...
    'PaperUnits','centimeters','PaperPositionMode','manual', ...
    'Renderer','painters');

tcl = tiledlayout(fig,1,1,'TileSpacing','compact','Padding','compact');

%% Specifies plot components 
priv_files_fun = @(k) ("outputs/" + WHICH_DATA + "_Figure4_privacy_" + ...
    string(k) + ".txt");
colors_k = [0.1490 0.3294 0.4863;
            0.9373 0.2784 0.4353;
            1.0000 0.8196 0.4000];
vec_k = [1 2 3];

%% Generates plot 
ax1 = nexttile(tcl,1); hold(ax1,'on');
h_k = gobjects(numel(vec_k),1);

for idx = 1:numel(vec_k)
    k = vec_k(idx);
    d = readtable(priv_files_fun(k));
    h_k(idx) = plot(ax1, d.beta, d.sig, '-', ...
        'Color', colors_k(idx,:), 'LineWidth', LINEWIDTH, ...
        'DisplayName', "$k=$" + string(k) + "\hspace{5pt}");
end

grid(ax1,'on'); ax1.Layer='bottom';
ax1.GridColor = GRIDCOLOR; ax1.GridAlpha = 0.9;
ax1.XMinorGrid='off'; ax1.YMinorGrid='off';
pbaspect(ax1,[1 1 1]);
axis(ax1,'padded');
ax1.FontSize = FONTSIZE;
ax1.TickLabelInterpreter='latex';
ax1.Box='on';

if WHICH_DATA == "1000Genomes"
    ax1.YTick = linspace(0,1.8,7);
    ylim(ax1,[0 1.8]);
elseif WHICH_DATA == "survey"
    ax1.YTick = linspace(0,1,6);
    ylim(ax1,[0 1]);
end

xlabel(ax1,'$\beta$','FontSize',FONTSIZE,'Interpreter','latex');
ylabel(ax1,'$\sigma_\beta$','FontSize',FONTSIZE,'Interpreter','latex');

% Creates legend 
leg = legend(h_k, 'Interpreter','latex','Orientation','vertical');
leg.FontSize = FONTSIZE;
leg.Layout.Tile = 'east';
leg.Box = 'off';
leg.NumColumns = 1;

%% Saves plot
fig.Units = 'centimeters';
figPos = fig.Position;
fig.PaperUnits = 'centimeters';
fig.PaperPosition = [0 0 figPos(3) figPos(4)];
fig.PaperSize = [figPos(3) figPos(4)];
print(fig,'plots/' + WHICH_DATA + '_Figure5.pdf','-dpdf','-painters');