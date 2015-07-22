% ampPerf.m
%
%      usage: ampPerf
%         by: laura
%       date: 07/09/15

%%% This program run a GLM with a separate column for each trial to compute the response amplitudes separately for each trial.
%%% Then sort the trials according to response amplitudes.

function ampPerf(obs,whichAnal,attCond,saveOverlay,nBins)

%% set conditions to run
% obs = {'co'}; %'nms' 'mr' 'id' 'rd' 'co'
% whichAnal = 'first'; % 'first' or 'TPJ'
% attCond = 'exo';
% saveOverlay = 0;

roiName = {'r_vTPJ','r_pTPJ','r_Ins'};%'r_pTPJ','r_Ins'

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
if strcmp(obs{:},'co') || strcmp(obs{:},'rd')
    load(['glmoutput_' attCond '_' whichAnal '_CI_' obs{:} '_results.mat'])
else
    load(['glmoutput_' attCond '_' whichAnal '_CI_' obs{:} '_results.mat'])
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

%% make the design matrix: 1 column per trial

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
    betas{iRoi} = regress(tSeries{iRoi}', scm);
end
keyboard
%% Sort the trials according to response amplitudes
idx = {};
for iRoi = 1:length(localizer)
    [sortedBetas{iRoi},index] = sort(betas{iRoi}); %index = index of the sorted trials
    idx{iRoi} = index;
end

%% Bin the trials according to response amplitudes: 33/33/33%
trialsPerBin = round(size(sortedBetas{iRoi},1)/nBins);
idxBin = {};
for iRoi = 1:length(localizer)
    countBin = 0;
    for iBin = 1:nBins
        if (countBin+trialsPerBin)>size(idx{iRoi},1)
            idxBin{iRoi,iBin} = idx{iRoi}(countBin+1:end);
        else
            idxBin{iRoi,iBin} = idx{iRoi}(countBin+1:countBin+trialsPerBin);
        end
        countBin = countBin + trialsPerBin;
    end
end

%% Load behavioral data and Organize them per bin and per ROI

load([dir '/Anal/AllData_' obs{:} '_' attCond '.mat'])
%1st line: condition (from 1 to 11: VPreLoc1, VPostLoc1, VPreLoc2, VPostLoc2, IPreLoc1, IPostLoc1, IPreLoc2, IPostLoc2, CueOnlyLoc1, CueOnlyLoc2, Blank)
%2nd line: performance (1=correct / -1=incorrect / 0=blink)

data = {};
for iRoi = 1:length(localizer)
    for iBin = 1:nBins
        data{iRoi,iBin}(1,:) = allData(1,idxBin{iRoi,iBin});
        data{iRoi,iBin}(2,:) = allData(2,idxBin{iRoi,iBin});
    end
end

%% Compute the performance per bin and per ROI

perfValid = [];
perfInvalid = [];
for iRoi = 1:length(localizer)
    for iBin = 1:nBins
        % All Valid trials
        validCorrect = find(data{iRoi,iBin}(2,:)==1&(data{iRoi,iBin}(1,:)==1|data{iRoi,iBin}(1,:)==2|data{iRoi,iBin}(1,:)==3|data{iRoi,iBin}(1,:)==4));
        totalValid = find((data{iRoi,iBin}(2,:)==1|data{iRoi,iBin}(2,:)==-1)&(data{iRoi,iBin}(1,:)==1|data{iRoi,iBin}(1,:)==2|data{iRoi,iBin}(1,:)==3|data{iRoi,iBin}(1,:)==4));
        perfValid(iRoi,iBin) = size(validCorrect,2)./size(totalValid,2);
        % All Invalid trials
        invalidCorrect = find(data{iRoi,iBin}(2,:)==1&(data{iRoi,iBin}(1,:)==5|data{iRoi,iBin}(1,:)==6|data{iRoi,iBin}(1,:)==7|data{iRoi,iBin}(1,:)==8));
        totalInvalid = find((data{iRoi,iBin}(2,:)==1|data{iRoi,iBin}(2,:)==-1)&(data{iRoi,iBin}(1,:)==5|data{iRoi,iBin}(1,:)==6|data{iRoi,iBin}(1,:)==7|data{iRoi,iBin}(1,:)==8));
        perfInvalid(iRoi,iBin) = size(invalidCorrect,2)./size(totalInvalid,2);
    end
end

save(['perf_' obs{:} '_' attCond '_' num2str(nBins) 'bins.mat'],'perfValid','perfInvalid')

end