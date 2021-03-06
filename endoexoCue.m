% endoexoIndexPlot_CI.m
%
%      usage: endoexoIndexPlot_CI()
%         by: eli merriam
%       date: 07/28/14
%    purpose:
%
function retval = endoexoCue

% check arguments
if ~any(nargin == [0])
    help endoexoIndexPlot
    return
end

% get listing of all files in analysis directory
fEndo = dir(fullfile('Anal/endo/anal*_Corb.mat'));
fExo = dir(fullfile('Anal/exo/anal*_Corb.mat'));

% init variables
ehdrEndoC=[]; ehdrEndoI=[]; ehdrExoC=[]; ehdrExoI=[]; endoName=[];exoName=[];
% loop over ROIs, accumulating the beta's from the GLM
for iRoi = 1:length(fEndo)
    % load file from endo analysis
    anal = load(fullfile('Anal/endo/', fEndo(iRoi).name));
    
    % first four resps are 'contralateral' for right hemi ROIs
    if strfind(fEndo(iRoi).name, '_r_')
        ehdrEndoC(:,iRoi) = anal.dGLM.ehdr(17);
        ehdrEndoI(:,iRoi) = anal.dGLM.ehdr(18);
        ehdrEndoAll(:,iRoi) = anal.dGLM.ehdr(17:18);
    elseif strfind(fEndo(iRoi).name, '_l_')
        ehdrEndoC(:,iRoi) = anal.dGLM.ehdr(18);
        ehdrEndoI(:,iRoi) = anal.dGLM.ehdr(17);
        ehdrEndoAll(:,iRoi) = anal.dGLM.ehdr(17:18);
    else
        disp(sprintf('UHOH: Does not match left or right hemisphere'));
        return;
    end
    temp = anal.rois{1}.name;
    temp = fixBadChars(temp, [],{'r_',''});
    temp = fixBadChars(temp, [],{'l_',''});
    temp = fixBadChars(temp, [], {'v3d','v3'});
    temp = fixBadChars(temp, [], {'v2d','v2'});
    endoName{iRoi} = temp;
    
    % load file from exo analysis
    anal = load(fullfile('Anal/exo/', fExo(iRoi).name));
    
    % first four resps are 'contralateral' for right hemi ROIs
    if strfind(fExo(iRoi).name, '_r_')
        ehdrExoC(:,iRoi) = anal.dGLM.ehdr(17);
        ehdrExoI(:,iRoi) = anal.dGLM.ehdr(18);
        ehdrExoAll(:,iRoi) = anal.dGLM.ehdr(17:18);
    elseif strfind(fExo(iRoi).name, '_l_')
        ehdrExoC(:,iRoi) = anal.dGLM.ehdr(18);
        ehdrExoI(:,iRoi) = anal.dGLM.ehdr(17);
        ehdrExoAll(:,iRoi) = anal.dGLM.ehdr(17:18);
    else
        disp(sprintf('UHOH: Does not match left or right hemisphere'));
        return;
    end
    temp = anal.rois{1}.name;
    temp = fixBadChars(temp, [],{'r_',''});
    temp = fixBadChars(temp, [],{'l_',''});
    temp = fixBadChars(temp, [], {'v3d','v3'});
    temp = fixBadChars(temp, [], {'v2d','v2'});
    exoName{iRoi} = temp;
    
end
roiNames = {'v1','v2','v3a','v3b','v3','v4','v7','vo1','vo2','ips1','ips2','ips3','ips4','vTPJ'};%
% roiNames = {'v1','v2','v3a','v3b','v3','v4','vo1','vo2','lo1','lo2'};%
% roiNames = {'v7','ips1','ips2','ips3','ips4'};%

% average over right and left hemipshere betas
aveExoC=[];aveExoI=[];aveExoAll=[];aveEndoC=[];aveEndoI=[];aveEndoAll=[];
for iRoi=1:length(roiNames)
    % find indices matching roiNames for exo 
    roiInd = strcmp(exoName, roiNames{iRoi});
    aveExoC(:,iRoi) = mean(ehdrExoC(:,roiInd)');
    aveExoI(:,iRoi) = mean(ehdrExoI(:,roiInd)');
    aveExoAll(:,iRoi) = mean(ehdrExoAll(:,roiInd)');
    % find indices matching roiNames for endo
    roiInd = strcmp(endoName, roiNames{iRoi});
    aveEndoC(:,iRoi) = mean(ehdrEndoC(:,roiInd)');
    aveEndoI(:,iRoi) = mean(ehdrEndoI(:,roiInd)');
    aveEndoAll(:,iRoi) = mean(ehdrEndoAll(:,roiInd)');
end

%% Contralateral
all = [aveExoC;aveEndoC];

smartfig('All'); clf; hold on;

bar(all');
legend('Exo','Endo')
ylim([-.2 1])
set(gca, 'XTick', 1:14, 'XTickLabel',roiNames, 'tickdir', 'out')
axis square
ylabel('fMRI resp (% chg img intensity)','FontSize', 14);
title('Cue effect - CONTRALATERAL','FontSize', 18)

%% Ipsilateral
all = [aveExoI;aveEndoI];

smartfig('All'); clf; hold on;

bar(all');
legend('Exo','Endo')
ylim([-.2 1])
set(gca, 'XTick', 1:14, 'XTickLabel',roiNames, 'tickdir', 'out')
axis square
ylabel('fMRI resp (% chg img intensity)','FontSize', 14);
title('Cue effect - IPSILATERAL','FontSize', 18)

%% All trials
Exo = [aveExoI;aveExoC];
Endo = [aveEndoI;aveEndoC];
all = [mean(Exo);mean(Endo)];

smartfig('All'); clf; hold on;

bar(all');
legend('Exo','Endo')
ylim([-.2 1])
set(gca, 'XTick', 1:14, 'XTickLabel',roiNames, 'tickdir', 'out')
axis square
ylabel('fMRI resp (% chg img intensity)','FontSize', 14);
title('Cue effect - ALL','FontSize', 18)

%% EXO
% smartfig('Exo'); clf; hold on;
% 
% bar(aveExoAll');
% legend('Right','Left')
% ylim([-.2 1])
% set(gca, 'XTick', 1:14, 'XTickLabel',roiNames, 'tickdir', 'out')
% axis square
% 
% title('Exogenous attention','FontSize', 16)

%% ENDO
% smartfig('Endo'); clf; hold on;
% 
% bar(aveEndoAll');
% legend('Right','Left')
% ylim([-.2 1])
% set(gca, 'XTick', 1:14, 'XTickLabel',roiNames, 'tickdir', 'out')
% axis square
% 
% title('Endogenous attention','FontSize', 16)

