% statsBootFixedeffect.m
%
%      usage: statsBootFixedeffect
%         by: eli & laura
%       date: 07/02/15

%%% Compute a distribution of randomised differences averaged across observers

%% STEP 1: Compute the actual betas for all 5 observers and save it

% set conditions to run
obs = {'nms' 'mr' 'id' 'rd' 'co'}; %
whichAnal = 'first'; % 'first' or 'TPJ'
roiName = {'r_vTPJ','r_pTPJ','r_Ins'};%
attCond = 'endo';
saveOverlay = 1;

for iObs = 1:length(obs)
    
    %% Set directory
    dir = ['/Volumes/DRIVE1/DATA/laura/MRI/' obs{iObs} '/' obs{iObs} 'Merge'];
    cd(dir)
    
    %% set parameters for mrTool
    % open a new view
    v = newView;
    % get attention condition
    v = viewSet(v, 'curGroup', ['w-' attCond]);
    
    %% load the output of the GLMdenoise
    load(['glmoutput_' attCond '_' whichAnal '_CI_' obs{iObs} '_results.mat'])
    
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
        load(['glmoutput_' attCond '_' whichAnal '_CI_' obs{iObs} '_denoiseddata.mat'])
        
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
        betas{iRoi,iObs} = regress(tSeries{iRoi}', scm);
    end
    
    mrQuit
end
save(['/Volumes/DRIVE1/DATA/laura/MRI/Group/betas_' attCond '.mat'],'betas')

%% STEP 2: Compute the randomized betas for all 5 observers and save it

% set conditions to run
obs = {'nms' 'mr' 'id' 'rd' 'co'}; %
whichAnal = 'first'; % 'first' or 'TPJ'
roiName = {'r_vTPJ','r_pTPJ','r_Ins'};%
attCond = 'endo';

% Load the output of the GLMdenoise once for each observer
for iObs = 1:length(obs)
    load(['/Volumes/DRIVE1/DATA/laura/MRI/' obs{iObs} '/' obs{iObs} 'Merge/glmoutput_' attCond '_' whichAnal '_CI_' obs{iObs} '_results.mat'])
    dataGLM{iObs} = results;
end

% Pull data out of ROI and select voxels based on stimulus localizer once for each observer
for iObs = 1:length(obs)
    % Set directory
    dir = ['/Volumes/DRIVE1/DATA/laura/MRI/' obs{iObs} '/' obs{iObs} 'Merge'];
    cd(dir)
    
    % set parameters for mrTool
    % open a new view
    v = newView;
    % get attention condition
    v = viewSet(v, 'curGroup', ['w-' attCond]);
    
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
    rois{iObs} = loadROIdnoisestatsBOOT(v, whichAnal, roiName, scanNum, groupNum);
    
    % load the localizer corAnal Roi-by-Roi
    localizer{iObs} = loadROIcoranalMatching(v, roiName, locScan, locGroup, scanNum, groupNum);
    
    mrQuit()
end

% Compute randomisation (shuffle the labels in the design matrix)
rep = 1000;
for iRep = 1:rep
    disp(['Running repetition number: ' num2str(iRep)])
    for iObs = 1:length(obs)
        % make the shuffled design matrix
        scm = [];
        for iRun = 1:length(dataGLM{iObs}.inputs.design)
            % make the unshuffled design matrix
            thisDesign = convn(dataGLM{iObs}.models{1}(:,1), dataGLM{iObs}.inputs.design{iRun});
            thisDesign = thisDesign(1:length(dataGLM{iObs}.inputs.design{iRun}),:);
            scm = cat(1, scm, thisDesign);
        end
        
        % shuffle the design matrix
        idx = size(scm,2);
        idxShuffled = randsample(1:idx,idx);
        scmShuffled = scm(:,idxShuffled);
        
        % pull data out of ROI and select voxels based on stimulus localizer
        for iRoi = 1:length(localizer{iObs})
            goodVox{iObs}{iRoi} = localizer{iObs}{iRoi}.co > locThresh & localizer{iObs}{iRoi}.ph < pi & ~isnan(rois{iObs}{iRoi}.ehdr(localizer{iObs}{iRoi}.goodSelectedVoxel)');
        end
        
        % average across voxels in each ROI
        for iRoi = 1:length(localizer{iObs})
            tempB = [];
            for iRun = 1:size(rois{iObs}{iRoi}.boot,2)
                temp = squeeze(mean(rois{iObs}{iRoi}.boot{iRun}(goodVox{iObs}{iRoi},:)));
                temp = percentTSeries(temp')';
                tempB = cat(2, tempB, temp);
            end
            tSeries{iObs,iRoi} = tempB;
        end
        
        % Compute the surrogate contrasts
        for iRoi = 1:length(roiName)
            betasShuffled{iRoi,iObs} = regress(tSeries{iObs,iRoi}', scmShuffled);
        end
    end
    for iRoi = 1:length(roiName)
        betasShuf{iRoi} = [betasShuffled{iRoi,1},betasShuffled{iRoi,2},betasShuffled{iRoi,3},betasShuffled{iRoi,4},betasShuffled{iRoi,5}];
        betasShuf{iRoi} = mean(betasShuf{iRoi},2);
        randombetas{iRoi}(iRep,:) = betasShuf{iRoi}';
    end
end

save(['/Volumes/DRIVE1/DATA/laura/MRI/Group/randombetas_' attCond '.mat'],'randombetas')

%% ask whether the actual contrast is larger than 95th percentile of shuffled distribution
% set conditions to run
obs = {'nms' 'mr' 'id' 'rd' 'co'}; %
whichAnal = 'first'; % 'first' or 'TPJ'
roiName = {'r_vTPJ','r_pTPJ','r_Ins'};%
attCond = 'endo';
rep = 100000;

% Load the data
cd /Volumes/DRIVE1/DATA/laura/MRI/Group
load(['randombetas_' attCond '.mat'])
load(['betas_' attCond '.mat'])

% Average the betas accross observers
for iRoi = 1:length(roiName)
    temp{iRoi} = [betas{iRoi,1},betas{iRoi,2},betas{iRoi,3},betas{iRoi,4},betas{iRoi,5}];
    actualbetas{iRoi} = mean(temp{iRoi},2);
    actualbetas{iRoi} = actualbetas{iRoi}';
end

if strcmp(whichAnal,'TPJ')
    contrast = [0 0 0 -1 1 -1 1 0]';
    contrastCorrect = [0 0 0 -1 1 0 0 0]';
    contrastIncorrect = [0 0 0 0 0 -1 1 0]';
elseif strcmp(whichAnal,'first')
    contrast = [-1 1 -1 1 -1 1 -1 1 0 0 0 0]'; % PRE AND POST
    contrastPre = [-1 1 0 0 -1 1 0 0 0 0 0 0]'; % PRE
    contrastPost = [0 0 -1 1 0 0 -1 1 0 0 0 0]'; % POST
end
for iRoi = 1:3
    for iBoot=1:rep
        if strcmp(whichAnal,'TPJ')
            my_contrast_distribution_cont{iRoi}(iBoot) = randombetas{iRoi}(iBoot,:) * contrast;
            my_contrast_distribution_contCor{iRoi}(iBoot) = randombetas{iRoi}(iBoot,:) * contrastCorrect;
            my_contrast_distribution_contIncor{iRoi}(iBoot) = randombetas{iRoi}(iBoot,:) * contrastIncorrect;
        elseif strcmp(whichAnal,'first')
            my_contrast_distribution_cont{iRoi}(iBoot) = randombetas{iRoi}(iBoot,:) * contrast;
            my_contrast_distribution_contPre{iRoi}(iBoot) = randombetas{iRoi}(iBoot,:) * contrastPre;
            my_contrast_distribution_contPost{iRoi}(iBoot) = randombetas{iRoi}(iBoot,:) * contrastPost;
        end
    end
    if strcmp(whichAnal,'TPJ')
        actualContrast{iRoi} = actualbetas{iRoi} * contrast;
        actualContrastCor{iRoi} = actualbetas{iRoi} * contrastCorrect;
        actualContrastIncor{iRoi} = actualbetas{iRoi} * contrastIncorrect;
        statsPerRoi{iRoi,1} = prctile(my_contrast_distribution_cont{iRoi}, 97.5) < actualContrast{iRoi};
        statsPerRoi{iRoi,2} = prctile(my_contrast_distribution_contCor{iRoi}, 97.5) < actualContrastCor{iRoi};
        statsPerRoi{iRoi,3} = prctile(my_contrast_distribution_contIncor{iRoi}, 97.5) < actualContrastIncor{iRoi};
    elseif strcmp(whichAnal,'first')
        actualContrast{iRoi} = actualbetas{iRoi} * contrast;
        actualContrastPre{iRoi} = actualbetas{iRoi} * contrastPre;
        actualContrastPost{iRoi} = actualbetas{iRoi} * contrastPost;
        statsPerRoi{iRoi,1} = prctile(my_contrast_distribution_cont{iRoi}, 98) < actualContrast{iRoi};
        statsPerRoi{iRoi,2} = prctile(my_contrast_distribution_contPre{iRoi}, 98) < actualContrastPre{iRoi};
        statsPerRoi{iRoi,3} = prctile(my_contrast_distribution_contPost{iRoi}, 98) < actualContrastPost{iRoi};
    end
end



