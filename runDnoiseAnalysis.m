% runDnoiseAnalysis.m
%
%      usage: runDnoiseAnalysis
%         by: eli & laura
%       date: 01/17/15

%% set conditions to run
obs = 'rd';
cond = 'exo'; % 'exo' or 'endo'
createGroup = 0; % 0 to not create and 1 to create
whichAnal = 'TPJ'; % 'first' or 'visualCortex' or 'TPJ'
doGLM = 1; % 0 to not run and 1 to run
roiName = {'r_vTPJ', 'r_pTPJ', 'r_Ins'};
    %{'r_v1', 'r_v3a','r_v4','r_v7','r_vTPJ'};
    %{'l_v1', 'l_v4', 'l_vo1', 'l_vo2', 'l_v2d', 'l_v3d', 'l_v3a', 'l_v3b', 'l_lo1', 'l_lo2','l_v7','l_ips1','l_ips2','l_ips3','l_ips4',...
    %'r_v1', 'r_v4', 'r_vo1', 'r_vo2', 'r_v2d', 'r_v3d', 'r_v3a', 'r_v3b', 'r_lo1', 'r_lo2','r_v7','r_ips1','r_ips2','r_ips3','r_ips4',...
    %'r_vTPJ'};
plotData = 0; % 0 to not plot the results and 1 to plot the results

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
    if strcmp(cond,'exo')
        scanNum = 1;% scanNum=1 for exo and scanNum=2 for endo
    elseif strcmp(cond,'endo')
        scanNum = 2;% scanNum=1 for exo and scanNum=2 for endo
    end
    v = doGLMdeNoise(v,obs,cond,whichAnal,scanNum);
end

%% average across voxels within each ROI
if plotData == 1 
    [v,ehdr,ehdrste] = dnoiseEndoExo(v, whichAnal, roiName, ['w-' cond]);
end

%% Plot Roi-by-Roi classic analysis = prediction on the visual cortex
if strcmp(whichAnal,'visualCortex') && plotData == 1 
    plotROI = 'r_vTPJ';
    m_ehdr = ehdr{strcmp(roiName,plotROI)};
    m_ehdr = m_ehdr';
    ste_ehdr = ehdrste{strcmp(roiName,plotROI)};
    ste_ehdr = ste_ehdr';
    
    visualPlotROI_by_ROI(m_ehdr, ste_ehdr, plotROI, cond, obs)
end

%% Plot Roi-by-Roi corbetta analysis = prediction on TPJ
if strcmp(whichAnal,'TPJ') && plotData == 1 
    plotROI = 'r_pTPJ';
    m_ehdr = ehdr{strcmp(roiName,plotROI)};
    m_ehdr = m_ehdr';
    ste_ehdr = ehdrste{strcmp(roiName,plotROI)};
    ste_ehdr = ste_ehdr';
    
    TPJPlotROI_by_ROI(m_ehdr, ste_ehdr, plotROI, cond, obs)
end

%% Plot Roi-by-Roi first analysis for TPJ
if strcmp(whichAnal,'first') && plotData == 1 
    plotROI = 'r_vTPJ';
    m_ehdr = ehdr{strcmp(roiName,plotROI)};
    m_ehdr = m_ehdr';
    ste_ehdr = ehdrste{strcmp(roiName,plotROI)};
    ste_ehdr = ste_ehdr';
    
%     firstPlotROI_by_ROI(m_ehdr, ste_ehdr, plotROI, cond, obs)
firstVisualPlotROI_by_ROI(m_ehdr, ste_ehdr, plotROI, cond, obs)
end
%% Plot Roi-by-Roi first analysis for Visual areas
% if strcmp(whichAnal,'first') && plotData == 1 
%     plotROI = 'r_v1';
%     m_ehdr = ehdr{strcmp(roiName,plotROI)};
%     m_ehdr = m_ehdr';
%     ste_ehdr = ehdrste{strcmp(roiName,plotROI)};
%     ste_ehdr = ste_ehdr';
%     
%     firstVisualPlotROI_by_ROI(m_ehdr, ste_ehdr, plotROI, cond, obs)
% end