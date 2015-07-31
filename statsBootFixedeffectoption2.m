% statsBootFixedeffectoption2.m
%
%      usage: statsBootFixedeffectoption2
%         by: eli & laura
%       date: 07/02/15

%%% This program run a GLM with a separate column for each trial to compute the response amplitudes separately for each trial.
%%% Then compute a distribution of randomised differences averaged across observers

%% STEP 1: Compute the actual betas for all 5 observers and save it

% set conditions to run
obs = {'nms' 'mr' 'id' 'rd' 'co'}; %
whichAnal = 'first'; % 'first' or 'TPJ'
roiName = {'r_vTPJ','r_pTPJ','r_Ins'};%
attCond = 'exo';
saveOverlay = 0;

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
    
    %% make the unshuffled design matrix: 1 column per trial
    idxAll = [];
    for iRun = 1:length(results.inputs.design)
        idx = [];
        for iVol = 1:length(results.inputs.design{iRun})
            if find(results.inputs.design{iRun}(iVol,:)==1) > 0
                idx(iVol) = 1;
            elseif isempty(find(results.inputs.design{iRun}(iVol,:)==1))
                idx(iVol) = 0;
            end
        end
        idxAll = [idxAll idx];
    end
    
    scm = zeros(size(idxAll,2),size(find(idxAll==1),2));
    countTrial = 1;
    for iVol = 1:size(idxAll,2)
        if idxAll(iVol) == 1
            scm(iVol,countTrial) = 1;
            countTrial = countTrial + 1;
        end
    end
    thisDesign = convn(results.models{1}(:,1), scm);
    scm = thisDesign(1:size(scm,1),:);
    
    %% Compute the actual contrast (compute the betas using standard GLM)
    for iRoi = 1:length(localizer)
        betas{iRoi,iObs} = regress(tSeries{iRoi}', scm);
    end
    
    mrQuit
end
save(['/Volumes/DRIVE1/DATA/laura/MRI/Group/betas_' attCond '_indTrials.mat'],'betas')

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
save('/Volumes/DRIVE1/DATA/laura/MRI/Group/endo_data_hpc.mat','dataGLM','rois','localizer', '-v7.3')

%%
% Compute randomisation (shuffle the labels in the design matrix)
rep = 10;
for iRep = 1:rep
    disp(['Running repetition number: ' num2str(iRep)])
    for iObs = 1:length(obs)
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
        
        % make the shuffled design matrix: 1 column per trial
        idxAll = [];
        for iRun = 1:length(dataGLM{iObs}.inputs.design)
            idx = [];
            for iVol = 1:length(dataGLM{iObs}.inputs.design{iRun})
                if find(dataGLM{iObs}.inputs.design{iRun}(iVol,:)==1) > 0
                    idx(iVol) = 1;
                elseif isempty(find(dataGLM{iObs}.inputs.design{iRun}(iVol,:)==1))
                    idx(iVol) = 0;
                end
            end
            idxAll = [idxAll idx];
        end
        
        scm = zeros(size(idxAll,2),size(find(idxAll==1),2));
        countTrial = 1;
        for iVol = 1:size(idxAll,2)
            if idxAll(iVol) == 1
                scm(iVol,countTrial) = 1;
                countTrial = countTrial + 1;
            end
        end
        
        scm2 = [];
        runStart = 1;
        for iRun=1:length(dataGLM{iObs}.inputs.design)
            runEnd = runStart + size(dataGLM{iObs}.inputs.design{iRun},1)-1;
            thisDesign = convn(dataGLM{iObs}.models{1}(:,1), scm(runStart:runEnd,:));
            thisDesign = thisDesign(1:length(dataGLM{iObs}.inputs.design{iRun}),:);
            scm2 = cat(1, scm2, thisDesign);
            runStart = runEnd + 1;
        end            
        
        % shuffle the design matrix
        idx = size(scm,2);
        idxShuffled = randsample(1:idx,idx);
        scmShuffled = scm(:,idxShuffled);
        
        % Compute the surrogate contrasts
        for iRoi = 1:length(roiName)
            betasShuffled{iRoi,iObs}(iRep,:) = regress(tSeries{iObs,iRoi}', scmShuffled);
        end
    end
end

save(['/Volumes/DRIVE1/DATA/laura/MRI/Group/randombetas_' attCond '_indTrials.mat'],'betasShuffled')



