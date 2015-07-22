% ampPerfCondByCond.m
%
%      usage: ampPerfCondByCond
%         by: laura
%       date: 07/09/15

%%% This program run a GLM with a separate column for each trial to compute the response amplitudes separately for each trial.
%%% Then sort the trials according to response amplitudes, separately for each condition

function ampPerfCondByCond(obs,whichAnal,attCond,saveOverlay,nBins)

%% set conditions to run
% obs = {'co'}; %'nms' 'mr' 'id' 'rd' 'co'
% whichAnal = 'first'; % 'first' or 'TPJ'
% attCond = 'exo';
% saveOverlay = 0;

roiName = {'r_vTPJ','r_pTPJ','r_Ins'};%

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

%% Load behavioral data and Organize them per bin and per ROI

load([dir '/Anal/AllData_' obs{:} '_' attCond '.mat'])
%1st line: condition (from 1 to 11: VPreLoc1, VPostLoc1, VPreLoc2, VPostLoc2, IPreLoc1, IPostLoc1, IPreLoc2, IPostLoc2, CueOnlyLoc1, CueOnlyLoc2, Blank)
%2nd line: performance (1=correct / -1=incorrect / 0=blink)

valid = find((allData(2,:)==1|allData(2,:)==-1)&(allData(1,:)==1|allData(1,:)==2|allData(1,:)==3|allData(1,:)==4));
valid = valid';
invalid = find((allData(2,:)==1|allData(2,:)==-1)&(allData(1,:)==5|allData(1,:)==6|allData(1,:)==7|allData(1,:)==8));
invalid = invalid';

validpre = find((allData(2,:)==1|allData(2,:)==-1)&(allData(1,:)==1|allData(1,:)==3));
validpre = validpre';
invalidpre = find((allData(2,:)==1|allData(2,:)==-1)&(allData(1,:)==5|allData(1,:)==7));
invalidpre = invalidpre';

validpost = find((allData(2,:)==1|allData(2,:)==-1)&(allData(1,:)==2|allData(1,:)==4));
validpost = validpost';
invalidpost = find((allData(2,:)==1|allData(2,:)==-1)&(allData(1,:)==6|allData(1,:)==8));
invalidpost = invalidpost';

for iRoi = 1:length(localizer)
    betasValid{iRoi} = betas{iRoi}(valid);
    betasInvalid{iRoi} = betas{iRoi}(invalid);
    betasValidpre{iRoi} = betas{iRoi}(validpre);
    betasInvalidpre{iRoi} = betas{iRoi}(invalidpre);
    betasValidpost{iRoi} = betas{iRoi}(validpost);
    betasInvalidpost{iRoi} = betas{iRoi}(invalidpost);
end

%% Sort the trials according to response amplitudes
for iRoi = 1:length(localizer)
    [sortedBetasValid{iRoi},index] = sort(betasValid{iRoi}); %index = index of the sorted trials
    idxValid{iRoi} = index;
    [sortedBetasInvalid{iRoi},index] = sort(betasInvalid{iRoi});
    idxInvalid{iRoi} = index;
    [sortedBetasValidpre{iRoi},index] = sort(betasValidpre{iRoi}); %index = index of the sorted trials
    idxValidpre{iRoi} = index;
    [sortedBetasInvalidpre{iRoi},index] = sort(betasInvalidpre{iRoi});
    idxInvalidpre{iRoi} = index;
    [sortedBetasValidpost{iRoi},index] = sort(betasValidpost{iRoi}); %index = index of the sorted trials
    idxValidpost{iRoi} = index;
    [sortedBetasInvalidpost{iRoi},index] = sort(betasInvalidpost{iRoi});
    idxInvalidpost{iRoi} = index;
end

%% Bin the trials according to response amplitudes
trialsPerBin = round(size(sortedBetasValid{iRoi},1)/nBins);
idxValidBin = {};
for iRoi = 1:length(localizer)
    countBin = 0;
    for iBin = 1:nBins
        if (countBin+trialsPerBin)>size(idxValid{iRoi},1)
            idxValidBin{iRoi,iBin} = idxValid{iRoi}(countBin+1:end);
        else
            idxValidBin{iRoi,iBin} = idxValid{iRoi}(countBin+1:countBin+trialsPerBin);
        end
        countBin = countBin + trialsPerBin;
    end
end

trialsPerBin = round(size(sortedBetasInvalid{iRoi},1)/nBins);
idxInvalidBin = {};
for iRoi = 1:length(localizer)
    countBin = 0;
    for iBin = 1:nBins
        if (countBin+trialsPerBin)>size(idxInvalid{iRoi},1)
            idxInvalidBin{iRoi,iBin} = idxInvalid{iRoi}(countBin+1:end);
        else
            idxInvalidBin{iRoi,iBin} = idxInvalid{iRoi}(countBin+1:countBin+trialsPerBin);
        end
        countBin = countBin + trialsPerBin;
    end
end

trialsPerBin = round(size(sortedBetasValidpre{iRoi},1)/nBins);
idxValidpreBin = {};
for iRoi = 1:length(localizer)
    countBin = 0;
    for iBin = 1:nBins
        if (countBin+trialsPerBin)>size(idxValidpre{iRoi},1)
            idxValidpreBin{iRoi,iBin} = idxValidpre{iRoi}(countBin+1:end);
        else
            idxValidpreBin{iRoi,iBin} = idxValidpre{iRoi}(countBin+1:countBin+trialsPerBin);
        end
        countBin = countBin + trialsPerBin;
    end
end

trialsPerBin = round(size(sortedBetasInvalidpre{iRoi},1)/nBins);
idxInvalidpreBin = {};
for iRoi = 1:length(localizer)
    countBin = 0;
    for iBin = 1:nBins
        if (countBin+trialsPerBin)>size(idxInvalidpre{iRoi},1)
            idxInvalidpreBin{iRoi,iBin} = idxInvalidpre{iRoi}(countBin+1:end);
        else
            idxInvalidpreBin{iRoi,iBin} = idxInvalidpre{iRoi}(countBin+1:countBin+trialsPerBin);
        end
        countBin = countBin + trialsPerBin;
    end
end

trialsPerBin = round(size(sortedBetasValidpost{iRoi},1)/nBins);
idxValidpostBin = {};
for iRoi = 1:length(localizer)
    countBin = 0;
    for iBin = 1:nBins
        if (countBin+trialsPerBin)>size(idxValidpost{iRoi},1)
            idxValidpostBin{iRoi,iBin} = idxValidpost{iRoi}(countBin+1:end);
        else
            idxValidpostBin{iRoi,iBin} = idxValidpost{iRoi}(countBin+1:countBin+trialsPerBin);
        end
        countBin = countBin + trialsPerBin;
    end
end

trialsPerBin = round(size(sortedBetasInvalidpost{iRoi},1)/nBins);
idxInvalidpostBin = {};
for iRoi = 1:length(localizer)
    countBin = 0;
    for iBin = 1:nBins
        if (countBin+trialsPerBin)>size(idxInvalidpost{iRoi},1)
            idxInvalidpostBin{iRoi,iBin} = idxInvalidpost{iRoi}(countBin+1:end);
        else
            idxInvalidpostBin{iRoi,iBin} = idxInvalidpost{iRoi}(countBin+1:countBin+trialsPerBin);
        end
        countBin = countBin + trialsPerBin;
    end
end

%% Organize the data per bin and per ROI

dataValid = {};
dataInvalid = {};
dataValidpre = {};
dataInvalidpre = {};
dataValidpost = {};
dataInvalidpost = {};
for iRoi = 1:length(localizer)
    for iBin = 1:nBins
        dataValid{iRoi,iBin}(1,:) = allData(1,valid(idxValidBin{iRoi,iBin}));
        dataValid{iRoi,iBin}(2,:) = allData(2,valid(idxValidBin{iRoi,iBin}));
        dataInvalid{iRoi,iBin}(1,:) = allData(1,invalid(idxInvalidBin{iRoi,iBin}));
        dataInvalid{iRoi,iBin}(2,:) = allData(2,invalid(idxInvalidBin{iRoi,iBin}));
        dataValidpre{iRoi,iBin}(1,:) = allData(1,validpre(idxValidpreBin{iRoi,iBin}));
        dataValidpre{iRoi,iBin}(2,:) = allData(2,validpre(idxValidpreBin{iRoi,iBin}));
        dataInvalidpre{iRoi,iBin}(1,:) = allData(1,invalidpre(idxInvalidpreBin{iRoi,iBin}));
        dataInvalidpre{iRoi,iBin}(2,:) = allData(2,invalidpre(idxInvalidpreBin{iRoi,iBin}));
        dataValidpost{iRoi,iBin}(1,:) = allData(1,validpost(idxValidpostBin{iRoi,iBin}));
        dataValidpost{iRoi,iBin}(2,:) = allData(2,validpost(idxValidpostBin{iRoi,iBin}));
        dataInvalidpost{iRoi,iBin}(1,:) = allData(1,invalidpost(idxInvalidpostBin{iRoi,iBin}));
        dataInvalidpost{iRoi,iBin}(2,:) = allData(2,invalidpost(idxInvalidpostBin{iRoi,iBin}));
    end
end

%% Compute the performance per bin and per ROI

perfValid = [];
perfInvalid = [];
for iRoi = 1:length(localizer)
    for iBin = 1:nBins
        % All Valid trials
        validCorrect = find(dataValid{iRoi,iBin}(2,:)==1&(dataValid{iRoi,iBin}(1,:)==1|dataValid{iRoi,iBin}(1,:)==2|dataValid{iRoi,iBin}(1,:)==3|dataValid{iRoi,iBin}(1,:)==4));
        totalValid = find((dataValid{iRoi,iBin}(2,:)==1|dataValid{iRoi,iBin}(2,:)==-1)&(dataValid{iRoi,iBin}(1,:)==1|dataValid{iRoi,iBin}(1,:)==2|dataValid{iRoi,iBin}(1,:)==3|dataValid{iRoi,iBin}(1,:)==4));
        perfValid(iRoi,iBin) = size(validCorrect,2)./size(totalValid,2);
        % All Invalid trials
        invalidCorrect = find(dataInvalid{iRoi,iBin}(2,:)==1&(dataInvalid{iRoi,iBin}(1,:)==5|dataInvalid{iRoi,iBin}(1,:)==6|dataInvalid{iRoi,iBin}(1,:)==7|dataInvalid{iRoi,iBin}(1,:)==8));
        totalInvalid = find((dataInvalid{iRoi,iBin}(2,:)==1|dataInvalid{iRoi,iBin}(2,:)==-1)&(dataInvalid{iRoi,iBin}(1,:)==5|dataInvalid{iRoi,iBin}(1,:)==6|dataInvalid{iRoi,iBin}(1,:)==7|dataInvalid{iRoi,iBin}(1,:)==8));
        perfInvalid(iRoi,iBin) = size(invalidCorrect,2)./size(totalInvalid,2);
        
        % Pre Valid trials
        validpreCorrect = find(dataValidpre{iRoi,iBin}(2,:)==1&(dataValidpre{iRoi,iBin}(1,:)==1|dataValidpre{iRoi,iBin}(1,:)==3));
        totalValidpre = find((dataValidpre{iRoi,iBin}(2,:)==1|dataValidpre{iRoi,iBin}(2,:)==-1)&(dataValidpre{iRoi,iBin}(1,:)==1|dataValidpre{iRoi,iBin}(1,:)==3));
        perfValidpre(iRoi,iBin) = size(validpreCorrect,2)./size(totalValidpre,2);
        % Pre Invalid trials
        invalidpreCorrect = find(dataInvalidpre{iRoi,iBin}(2,:)==1&(dataInvalidpre{iRoi,iBin}(1,:)==5|dataInvalidpre{iRoi,iBin}(1,:)==7));
        totalInvalidpre = find((dataInvalidpre{iRoi,iBin}(2,:)==1|dataInvalidpre{iRoi,iBin}(2,:)==-1)&(dataInvalidpre{iRoi,iBin}(1,:)==5|dataInvalidpre{iRoi,iBin}(1,:)==7));
        perfInvalidpre(iRoi,iBin) = size(invalidpreCorrect,2)./size(totalInvalidpre,2);
        
        % Post Valid trials
        validpostCorrect = find(dataValidpost{iRoi,iBin}(2,:)==1&(dataValidpost{iRoi,iBin}(1,:)==2|dataValidpost{iRoi,iBin}(1,:)==4));
        totalValidpost = find((dataValidpost{iRoi,iBin}(2,:)==1|dataValidpost{iRoi,iBin}(2,:)==-1)&(dataValidpost{iRoi,iBin}(1,:)==2|dataValidpost{iRoi,iBin}(1,:)==4));
        perfValidpost(iRoi,iBin) = size(validpostCorrect,2)./size(totalValidpost,2);
        % Post Invalid trials
        invalidpostCorrect = find(dataInvalidpost{iRoi,iBin}(2,:)==1&(dataInvalidpost{iRoi,iBin}(1,:)==6|dataInvalidpost{iRoi,iBin}(1,:)==8));
        totalInvalidpost = find((dataInvalidpost{iRoi,iBin}(2,:)==1|dataInvalidpost{iRoi,iBin}(2,:)==-1)&(dataInvalidpost{iRoi,iBin}(1,:)==6|dataInvalidpost{iRoi,iBin}(1,:)==8));
        perfInvalidpost(iRoi,iBin) = size(invalidpostCorrect,2)./size(totalInvalidpost,2);
        
    end
end

save(['perfCondbyCond_' obs{:} '_' attCond '_' num2str(nBins) 'bins.mat'],'perfValid','perfInvalid','perfValidpre','perfInvalidpre','perfValidpost','perfInvalidpost')

end