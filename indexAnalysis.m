% indexAnalysis.m
%
%      usage: indexAnalysis(v, roiName, varargin)
%         by: eli & laura
%       date: 01/17/15


%% set conditions to plot
obs = 'mr';
whichAnal = 'corbetta'; % 'classic' or 'corbetta'
roiName = {'l_v1', 'l_v4', 'l_vo1', 'l_vo2', 'l_v2d', 'l_v3d', 'l_v3a', 'l_v3b', 'l_lo1', 'l_lo2','l_v7','l_ips1','l_ips2','l_ips3','l_ips4',...
    'r_v1', 'r_v4', 'r_vo1', 'r_vo2', 'r_v2d', 'r_v3d', 'r_v3a', 'r_v3b', 'r_lo1', 'r_lo2','r_v7','r_ips1','r_ips2','r_ips3','r_ips4',...
    'r_vTPJ'};

%% Plot indexes

indexPlot(m_ehdr, ste_ehdr, whichAnal, roiName)