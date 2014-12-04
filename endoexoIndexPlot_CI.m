% endoexoIndexPlot_CI.m
%
%      usage: endoexoIndexPlot_CI()
%         by: eli merriam
%       date: 07/28/14
%    purpose:
%
function retval = endoexoIndexPlot_CI(CI)

% check arguments
if ~any(nargin == [1])
    help endoexoIndexPlot
    return
end

% get listing of all files in analysis directory
fEndo = dir(fullfile('Anal/endo/anal*_CI.mat'));
fExo = dir(fullfile('Anal/exo/anal*_CI.mat'));

% init variables
ehdrEndoC=[]; ehdrEndoI=[]; ehdrExoC=[]; ehdrExoI=[]; endoName=[];exoName=[];
% loop over ROIs, accumulating the beta's from the GLM
for iRoi = 1:length(fEndo)
    % load file from endo analysis
    anal = load(fullfile('Anal/endo/', fEndo(iRoi).name));
    if strcmp(CI,'all')
        idx = 0;
    elseif strcmp(CI,'correct')
        anal.dGLM = anal.dGLMCI;
        idx = 0;
    elseif strcmp(CI,'incorrect')
        anal.dGLM = anal.dGLMCI;
        idx = 11;
    end
    % first four resps are 'contralateral' for right hemi ROIs
    if strfind(fEndo(iRoi).name, '_r_')
        ehdrEndoC(:,iRoi) = anal.dGLM.ehdr((1+idx):(4+idx));
        ehdrEndoI(:,iRoi) = anal.dGLM.ehdr((5+idx):(8+idx));
    elseif strfind(fEndo(iRoi).name, '_l_')
        ehdrEndoC(:,iRoi) = anal.dGLM.ehdr((5+idx):(8+idx));
        ehdrEndoI(:,iRoi) = anal.dGLM.ehdr((1+idx):(4+idx));
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
    if strcmp(CI,'all')
        idx = 0;
    elseif strcmp(CI,'correct')
        anal.dGLM = anal.dGLMCI;
        idx = 0;
    elseif strcmp(CI,'incorrect')
        anal.dGLM = anal.dGLMCI;
        idx = 11;
    end
    % first four resps are 'contralateral' for right hemi ROIs
    if strfind(fExo(iRoi).name, '_r_')
        ehdrExoC(:,iRoi) = anal.dGLM.ehdr((1+idx):(4+idx));
        ehdrExoI(:,iRoi) = anal.dGLM.ehdr((5+idx):(8+idx));
    elseif strfind(fExo(iRoi).name, '_l_')
        ehdrExoC(:,iRoi) = anal.dGLM.ehdr((5+idx):(8+idx));
        ehdrExoI(:,iRoi) = anal.dGLM.ehdr((1+idx):(4+idx));
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

roiNames = {'lo1','lo2','mt','v1','v2','v3a','v3b','v3','v4','v7','vo1','vo2','ips1','ips2','ips3','ips4'};

% average over right and left hemipshere betas
aveExoC=[];aveExoI=[];aveEndoC=[];aveEndoI=[];
for iRoi=1:length(roiNames)
    % find indices matching roiNames for exo 
    roiInd = strcmp(exoName, roiNames{iRoi});
    aveExoC(:,iRoi) = mean(ehdrExoC(:,roiInd)');
    aveExoI(:,iRoi) = mean(ehdrExoI(:,roiInd)');
    % find indices matching roiNames for endo
    roiInd = strcmp(endoName, roiNames{iRoi});
    aveEndoC(:,iRoi) = mean(ehdrEndoC(:,roiInd)');
    aveEndoI(:,iRoi) = mean(ehdrEndoI(:,roiInd)');
end

% create valid-invalid and pre-post index plots
endoVI = ( mean(aveEndoC([1 3],:)) - mean(aveEndoC([2 4],:)) ) ./ ( mean(aveEndoC([1 3],:)) + mean(aveEndoC([2 4],:)) );
endoPP = ( mean(aveEndoC([1 2],:)) - mean(aveEndoC([3 4],:)) ) ./ ( mean(aveEndoC([1 2],:)) + mean(aveEndoC([3 4],:)) );
exoVI = ( mean(aveExoC([1 3],:)) - mean(aveExoC([2 4],:)) ) ./ ( mean(aveExoC([1 3],:)) + mean(aveExoC([2 4],:)) );
exoPP = ( mean(aveExoC([1 2],:)) - mean(aveExoC([3 4],:)) ) ./ ( mean(aveExoC([1 2],:)) + mean(aveExoC([3 4],:)) );

smartfig('indindplot'); clf; hold on;
for iRoi = 1:length(roiNames);
    line([endoVI(iRoi) exoVI(iRoi)], [endoPP(iRoi) exoPP(iRoi)], 'color', [.5 .5 .5]);
    h1 = text(endoVI(iRoi), endoPP(iRoi), upper(roiNames{iRoi}),'FontSize',14,'FontWeight','bold','FontAngle',...
        'italic','color',[0 0 1],'HorizontalAlignment','Center');
    h2 = text(exoVI(iRoi), exoPP(iRoi), upper(roiNames{iRoi}),'FontSize',14,'FontWeight','bold','FontAngle',...
        'italic','color',[1 0 0],'HorizontalAlignment','Center');
end

scale_axis = 2;
axis([-scale_axis scale_axis -scale_axis scale_axis]);
hline(0);
vline(0);
ylabel('<------ post-cue     pre-cue ------>','FontSize', 14, 'FontAngle', 'Italic');
xlabel('<------ invalid     valid ------>', 'FontSize', 14, 'FontAngle', 'Italic');
set(gca, 'YTick', [-scale_axis 0 scale_axis], 'XTick', [-scale_axis 0 scale_axis], 'tickdir', 'out')
axis square

if strcmp(CI,'all')
    title('All trials','FontSize', 16)
elseif strcmp(CI,'correct')
    title('Correct trials only','FontSize', 16)
elseif strcmp(CI,'incorrect')
    title('Incorrect trials only','FontSize', 16)
end


