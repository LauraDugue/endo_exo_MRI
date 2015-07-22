% statsBoot.m
%
%      usage: statsBoot
%         by: eli & laura
%       date: 07/02/15

%%% co: Sig for TPJ contrast and first contrast, for vTPJ only

%% set conditions to run
obs = {'co'}; %'nms' 'mr' 'id' 'rd' 'co'
whichAnal = 'first'; % 'first' or 'TPJ'
roiName = {'r_vTPJ','r_pTPJ','r_Ins'};%'r_pTPJ','r_Ins'
attCond = 'exo';
saveOverlay = 0;

%% Set directory
dir = ['/Volumes/DRIVE1/DATA/laura/MRI/' obs{:} '/' obs{:} 'Merge'];
cd(dir)

%% set parameters for mrTool
% open a new view
v = newView;
% get attention condition
v = viewSet(v, 'curGroup', ['w-' attCond]);

%% load the data

% Load the output of the GLMdenoise
load(['glmoutput_' attCond '_' whichAnal '_CI_' obs{:} '_results.mat'])

%% make the unshuffled design matrix
scm = [];

for iRun = 1:length(results.inputs.design)
    % make the design matrix
    thisDesign = convn(results.models{1}(:,1), results.inputs.design{iRun});
    thisDesign = thisDesign(1:length(results.inputs.design{iRun}),:);
    scm = cat(1, scm, thisDesign);
end

%% save Bootstraped data as a mrTool overlay
if saveOverlay
    % Load the output of the GLMdenoise
    if strcmp(obs{:},'co') || strcmp(obs{:},'rd')
        load(['glmoutput_' attCond '_' whichAnal '_CI_' obs{:} '_denoiseddata.mat'])
    else
        load(['glmoutput_' attCond '_' whichAnal '_CI_' obs{:} '_denoiseddata.mat'])
    end
    
    % Set parameters
    scanNum = viewGet(v, 'curscan');
    groupNum = viewGet(v, 'curgroup');
    
    % Save the data into the d structure
    d.ehdr = results.modelmd{2};
    d.ehdrste = results.modelse{2};
    d.stimvol = results.inputs.design;
    d.boot = denoiseddata;
    
    % Save the structure as an overlay
    [v,dnoiseAnal] = mrDispOverlay(results.R2, scanNum, groupNum, v, ['saveName=dnoiseAnal_' whichAnal '_statsBoot'], 'overlayNames', {'r2'}, 'analName', 'glmdnoise', 'd', d);
end

%% pull data out of ROI and select voxels based on stimulus localizer

% get the input arguemnts
if strcmp(attCond,'endo')
    scanNum = 2;groupNum = 'w-endo';
elseif strcmp(attCond,'exo')
    scanNum = 1;groupNum = 'w-exo';
end
locThresh = 0.2;
locGroup = 'Averages';
locScan = 1;

% load the beta weights
rois = loadROIdnoisestatsBOOT(v, whichAnal, roiName, scanNum, groupNum);

% load the localizer corAnal Roi-by-Roi
localizer = loadROIcoranalMatching(v, roiName, locScan, locGroup, scanNum, groupNum);
for iRoi = 1:length(localizer)
    goodVox{iRoi} = localizer{iRoi}.co > locThresh & localizer{iRoi}.ph < pi & ~isnan(rois{iRoi}.ehdr(localizer{iRoi}.goodSelectedVoxel)');
end

% average across voxels in each ROI
for iRoi = 1:length(localizer)
    tempB = [];
    for iRun = 1:size(rois{iRoi}.boot,2)
        temp = squeeze(mean(rois{iRoi}.boot{iRun}(goodVox{iRoi},:)));
        temp = percentTSeries(temp')';
        tempB = cat(2, tempB, temp);
    end
    tSeries{iRoi} = tempB;
end

%% Compute the actual contrast (compute the betas using standard GLM)
for iRoi = 1:length(localizer)
    betas{iRoi} = regress(tSeries{iRoi}', scm);
end

%% Compute randomisation (shuffle the labels in the design matrix)
rep = 1000;
for iRep = 1:rep
    %% make the shuffled design matrix
    scm = [];
    for iRun = 1:length(results.inputs.design)
        % make the concatenated design matrix
        thisDesign = convn(results.models{1}(:,1), results.inputs.design{iRun});
        thisDesign = thisDesign(1:length(results.inputs.design{iRun}),:);
        scm = cat(1, scm, thisDesign);
    end
    
    % shuffle the design matrix
    idx = size(scm,2);
    idxShuffled = randsample(1:idx,idx);
    scmShuffled = scm(:,idxShuffled);
    
    %% Compute the surrogate contrasts
    for iRoi = 1:length(localizer)
        betasShuffled{iRoi}(:,iRep) = regress(tSeries{iRoi}', scmShuffled);
    end
end

%% ask whether the actual contrast is larger than 95th percentile of shuffled distribution
if strcmp(whichAnal,'TPJ')
    contrast = [0 0 0 -1 1 -1 1 0]';
    contrastCorrect = [0 0 0 -1 1 0 0 0]';
    contrastIncorrect = [0 0 0 0 0 -1 1 0]';
elseif strcmp(whichAnal,'first')
    contrast = [-1 1 -1 1 -1 1 -1 1 0 0 0 0]'; % PRE AND POST
    contrastPre = [-1 1 0 0 -1 1 0 0 0 0 0 0]'; % PRE
    contrastPost = [0 0 -1 1 0 0 -1 1 0 0 0 0]'; % POST
end
for iRoi = 1:length(localizer)
    for iBoot=1:rep
        if strcmp(whichAnal,'TPJ')
            my_contrast_distribution_cont{iRoi}(iBoot) = betasShuffled{iRoi}(:,iBoot)' * contrast;
            my_contrast_distribution_contCor{iRoi}(iBoot) = betasShuffled{iRoi}(:,iBoot)' * contrastCorrect;
            my_contrast_distribution_contIncor{iRoi}(iBoot) = betasShuffled{iRoi}(:,iBoot)' * contrastIncorrect;
        elseif strcmp(whichAnal,'first')
            my_contrast_distribution_cont{iRoi}(iBoot) = betasShuffled{iRoi}(:,iBoot)' * contrast;
            my_contrast_distribution_contPre{iRoi}(iBoot) = betasShuffled{iRoi}(:,iBoot)' * contrastPre;
            my_contrast_distribution_contPost{iRoi}(iBoot) = betasShuffled{iRoi}(:,iBoot)' * contrastPost;
        end
    end
    if strcmp(whichAnal,'TPJ')
        actualContrast{iRoi} = betas{iRoi}' * contrast;
        actualContrastCor{iRoi} = betas{iRoi}' * contrastCorrect;
        actualContrastIncor{iRoi} = betas{iRoi}' * contrastIncorrect;
        statsPerRoi{iRoi,1} = prctile(my_contrast_distribution_cont{iRoi}, 95) < actualContrast{iRoi};
        statsPerRoi{iRoi,2} = prctile(my_contrast_distribution_contCor{iRoi}, 95) < actualContrastCor{iRoi};
        statsPerRoi{iRoi,3} = prctile(my_contrast_distribution_contIncor{iRoi}, 95) < actualContrastIncor{iRoi};
    elseif strcmp(whichAnal,'first')
        actualContrast{iRoi} = betas{iRoi}' * contrast;
        actualContrastPre{iRoi} = betas{iRoi}' * contrastPre;
        actualContrastPost{iRoi} = betas{iRoi}' * contrastPost;
        statsPerRoi{iRoi,1} = prctile(my_contrast_distribution_cont{iRoi}, 95) < actualContrast{iRoi};
        statsPerRoi{iRoi,2} = prctile(my_contrast_distribution_contPre{iRoi}, 95) < actualContrastPre{iRoi};
        statsPerRoi{iRoi,3} = prctile(my_contrast_distribution_contPost{iRoi}, 95) < actualContrastPost{iRoi};
    end
end



 