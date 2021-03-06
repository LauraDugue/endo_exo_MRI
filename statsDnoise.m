% statsDnoise.m
%
%      usage: statsDnoise
%         by: laura
%       date: 06/23/15

%% set conditions to run
obs = {'co'}; %'nms' 'mr' 'id' 'rd' 'co'
whichAnal = 'first'; % 'first' or 'TPJ'
roiName = {'r_vTPJ','r_pTPJ','r_Ins'};%'r_vTPJ' or 'r_pTPJ' or 'r_Ins'
attCond = 'endo';
saveOverlay = 0;

%% Set directory
if strcmp(obs{:},'co') || strcmp(obs{:},'rd')
    dir = ['/Volumes/DRIVE1/DATA/laura/MRI/' obs{:} '/' obs{:} 'Merge'];
else
    dir = ['/Local/Users/purpadmin/Laura/MRI/Data/' obs{:} '/' obs{:} 'Merge'];
end
cd(dir)

%% set parameters for mrTool
% open a new view
v = newView;
% get attention condition
v = viewSet(v, 'curGroup', ['w-' attCond]);

%% Save Bootstraped data as a mrTool overlay
if saveOverlay
    % Load the output of the GLMdenoise
    if strcmp(obs{:},'co') || strcmp(obs{:},'rd')
        load(['glmoutput_' attCond '_' whichAnal '_CI_' obs{:} '_results.mat'])
    else
        load(['glmoutput_' attCond '_' whichAnal '_CI_' obs{:} '.mat'])
    end
    
    % Set parameters
    scanNum = viewGet(v, 'curscan');
    groupNum = viewGet(v, 'curgroup');
    
    % Save the data into the d structure
    d.ehdr = results.modelmd{2};
    d.ehdrste = results.modelse{2};
    d.stimvol = results.inputs.design;
    d.boot = results.models{2};
    
    % Save the structure as an overlay
    [v,dnoiseAnal] = mrDispOverlay(results.R2, scanNum, groupNum, v, ['saveName=dnoiseAnal_' whichAnal '_boot'], 'overlayNames', {'r2'}, 'analName', 'glmdnoise', 'd', d);
end
%% Average across voxels within each ROI

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
rois = loadROIdnoiseBOOT(v, whichAnal, roiName, scanNum, groupNum);

% load the localizer corAnal Roi-by-Roi
localizer = loadROIcoranalMatching(v, roiName, locScan, locGroup, scanNum, groupNum);
for iRoi = 1:length(localizer)
    goodVox{iRoi} = localizer{iRoi}.co > locThresh & localizer{iRoi}.ph < pi & ~isnan(rois{iRoi}.ehdr(localizer{iRoi}.goodSelectedVoxel)');
end

% average across voxels in each ROI
for iRoi = 1:length(localizer)
    ehdr{iRoi} = mean(rois{iRoi}.ehdr(goodVox{iRoi},:));
    ehdrste{iRoi} = mean(rois{iRoi}.ehdrste(goodVox{iRoi},:));
    boot{iRoi} = squeeze(mean(rois{iRoi}.boot(goodVox{iRoi},:,:)));
end

%% Statistics on the bootstrap values coming from the GLMdenoise procedure
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
    my_contrast_distribution = boot{iRoi} * contrast;
    statsBoot(iRoi) = mean(my_contrast_distribution > 0);
end

disp(statsBoot)



