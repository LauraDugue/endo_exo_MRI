% runDnoiseAnalysis.m
%
%      usage: runDnoiseAnalysis(v, roiName, varargin)
%         by: eli & laura
%       date: 01/17/15

%% set conditions to run
obs = 'nms';
cond = 'exo'; % 'exo' or 'endo'
createGroup = 0; % 0 to not create and 1 to create
whichAnal = 'classic'; % 'classic' or 'corbetta'
doGLM = 0; % 0 to not run and 1 to run
roiName = {'l_v1', 'l_v4', 'l_vo1', 'l_vo2', 'l_v2d', 'l_v3d', 'l_v3a', 'l_v3b', 'l_lo1', 'l_lo2','l_v7','l_ips1','l_ips2','l_ips3','l_ips4',...
    'r_v1', 'r_v4', 'r_vo1', 'r_vo2', 'r_v2d', 'r_v3d', 'r_v3a', 'r_v3b', 'r_lo1', 'r_lo2','r_v7','r_ips1','r_ips2','r_ips3','r_ips4',...
    'r_vTPJ'};

%% set parameters fro mrTool
% open a new view
v = newView;
% get attention condition
v = viewSet(v, 'curGroup', cond);

%% create an additional group for denoising purposes
if createGroup
    v = prepDenoiseGroup(v);
end

%% run GLM denoise
if doGLM
    v = doGLMdeNoise(v,obs,cond,whichAnal);
end

%% average across voxels within each ROI
[v,ehdr,ehdrste] = dnoiseEndoExo(v, roiName, ['w-' cond]);

%% Plot Roi-by-Roi classic analysis
plotROI = 'r_v1';
m_ehdr = ehdr{strcmp(roiName,plotROI)};
m_ehdr = m_ehdr';
ste_ehdr = ehdrste{strcmp(roiName,plotROI)};
ste_ehdr = ste_ehdr';

classicPlotROI_by_ROI(m_ehdr, ste_ehdr, plotROI)

%% Plot Roi-by-Roi corbetta analysis
plotROI = 'r_v1';
m_ehdr = ehdr{strcmp(roiName,plotROI)};
m_ehdr = m_ehdr';
ste_ehdr = ehdrste{strcmp(roiName,plotROI)};
ste_ehdr = ste_ehdr';

corbettaPlotROI_by_ROI(m_ehdr, ste_ehdr, plotROI)

%% Plot indexes





