% indexPlot.m
%
%      usage: indexPlot(ehdr, ehdrste, whichAnal, roiName)
%         by: eli & laura
%       date: 01/17/15
%    purpose: 

function indexPlot(ehdr, ehdrste, whichAnal, roiName)

% check arguments
if ~any(nargin == [4])
    help endoexoIndexPlot
    return
end

% init variables
ehdrEndoC=[]; ehdrEndoI=[]; ehdrExoC=[]; ehdrExoI=[]; endoName=[];exoName=[];
% loop over ROIs, accumulating the beta's from the GLM
for iRoi = 1:length(fEndo)
    % load file from endo analysis
    anal = load(fullfile('Anal/endo/', fEndo(iRoi).name));
    
    if strcmp(CI,'all') && baseRemove == 0 && Corb == 0
        idx = 0;
    elseif strcmp(CI,'all') && baseRemove == 1 && Corb == 0
        idx = 0;
        anal.dGLM = anal.dGLMb;
    elseif strcmp(CI,'correct') && baseRemove == 0 && Corb == 0
        anal.dGLM = anal.dGLMCI;
        idx = 0;
    elseif strcmp(CI,'correct') && baseRemove == 1 && Corb == 0
        anal.dGLM = anal.dGLMCIb;
        idx = 0;
    elseif strcmp(CI,'incorrect') && baseRemove == 0 && Corb == 0
        anal.dGLM = anal.dGLMCI;
        idx = 11;
    elseif strcmp(CI,'incorrect') && baseRemove == 1 && Corb == 0
        anal.dGLM = anal.dGLMCIb;
        idx = 11;
    elseif strcmp(CI,'correct') && Corb == 1
        idx = 0;
    elseif strcmp(CI,'incorrect') && Corb == 1
        idx = 8;
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
    if strcmp(CI,'all') && baseRemove == 0 && Corb == 0
        idx = 0;
    elseif strcmp(CI,'all') && baseRemove == 1 && Corb == 0
        idx = 0;
        anal.dGLM = anal.dGLMb;
    elseif strcmp(CI,'correct') && baseRemove == 0 && Corb == 0
        anal.dGLM = anal.dGLMCI;
        idx = 0;
    elseif strcmp(CI,'correct') && baseRemove == 1 && Corb == 0
        anal.dGLM = anal.dGLMCIb;
        idx = 0;
    elseif strcmp(CI,'incorrect') && baseRemove == 0 && Corb == 0
        anal.dGLM = anal.dGLMCI;
        idx = 11;
    elseif strcmp(CI,'incorrect') && baseRemove == 1 && Corb == 0
        anal.dGLM = anal.dGLMCIb;
        idx = 11;
    elseif strcmp(CI,'correct') && Corb == 1
        idx = 0;
    elseif strcmp(CI,'correct') && Corb == 1
        idx = 8;
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






end