% indexAnalysis.m
%
%      usage: indexAnalysis
%         by: eli & laura
%       date: 01/17/15


%% set conditions to plot
obs = 'mr';
whichAnal = 'corbetta'; % 'classic' or 'corbetta'
roiName = {'l_v1', 'l_v4', 'l_vo1', 'l_vo2', 'l_v2d', 'l_v3d', 'l_v3a', 'l_v3b', 'l_lo1', 'l_lo2','l_v7','l_ips1','l_ips3','l_ips4',...
    'r_v1', 'r_v4', 'r_vo1', 'r_vo2', 'r_v2d', 'r_v3d', 'r_v3a', 'r_v3b', 'r_lo1', 'r_lo2','r_v7','r_ips1','r_ips2','r_ips3','r_ips4',...
    'r_vTPJ'};%,'l_ips2'
roiToPlot = {'v1','v2','v3a','v3b','v3','v4','v7','ips1','ips3','ips4'};%'v1','v2','v3a','v3b','v3','v4','v7','vo1','vo2','ips1','ips2','ips3','ips4'
CI = 'correct';
contra_ipsi = 1; % 1 for contra and 2 for ipsi

%% set parameters fro mrTool
% open a new view
v = newView;

%% get beta weights by attention condition
% EXOGENOUS condition
v = viewSet(v, 'curGroup', 'exo');
% average across voxels within each ROI
[v,ehdr_exo,ehdrste_exo] = dnoiseEndoExo(v, whichAnal, roiName, 'w-exo');

% ENDOGENOUS condition
v = viewSet(v, 'curGroup', 'endo');
% average across voxels within each ROI
[v,ehdr_endo,ehdrste_endo] = dnoiseEndoExo(v, whichAnal, roiName, 'w-endo');

%% Plot indexes

indexPlot(ehdr_endo, ehdr_exo, obs, roiName, roiToPlot, CI, whichAnal, contra_ipsi)



