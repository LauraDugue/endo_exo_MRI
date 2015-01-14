

% v = newView;
v = viewSet(v, 'curGroup', 'exo');
nScans = viewGet(v, 'nscans');
% for iScan = 1:nScans
%     [v params] = concatTSeries(v, [], 'justGetParams=1', 'defaultParams=1', sprintf('scanList=%i',iScan));
%     params.percentSignal = 0;
%     params.filterType = 'none';
%     params.warpInterpMethod = 'linear';
%     params.warpBaseScan = 1;
%     params.newGroupName = sprintf('w-%s', params.groupName');
%     concatTSeries(v, params);
% end


%% -------------------------------------------------
runLength = [];
v = viewSet(v, 'curGroup', 'w-exo');
for iScan = 1:nScans
    runLength = cat(1, runLength, viewGet(v, 'nFrames', iScan));
end

nCond = 23; % 11 correct, 11 incorrect, blinks
%nCond = 11; % 11 correct, 11 incorrect, blinks

% load the stim vols
% stimvol = load('Anal/endostimvol.mat');
% load('Anal/correctIncorrect_endo_blinks.mat');
stimvol = load('Anal/exostimvol.mat');
load('Anal/correctIncorrect_exo_blinks.mat');

designAllRuns = zeros(sum(runLength), nCond);

% first loop over conditions
for iCond = 1:length(correctIncorrect)
    % correct trials
    whichVols = stimvol.stimvol{iCond}(correctIncorrect{iCond}==1);
    designAllRuns(whichVols,iCond) = 1;
    % incorrect trials
    whichVols = stimvol.stimvol{iCond}(correctIncorrect{iCond}==-1);
    designAllRuns(whichVols,iCond+length(correctIncorrect)) = 1;    
    % blinks
    whichVols = stimvol.stimvol{iCond}(correctIncorrect{iCond}==0);
    designAllRuns(whichVols,end) = 1;    
end

% for iCond = 1:length(correctIncorrect)
%     correct trials
%     whichVols = stimvol.stimvol{iCond};
%     designAllRuns(whichVols,iCond) = 1;
% end


% now split by run
runStartTimes = 1;
runEndTimes = [];
for iScan = 1:nScans-1
    runStartTimes = cat(1, runStartTimes, sum(runLength(1:iScan))+1);
    runEndTimes = cat(1, runEndTimes, sum(runLength(1:iScan)));
end
runEndTimes(end+1) = sum(runLength);

for iScan = 1:nScans
    design{iScan} = designAllRuns(runStartTimes(iScan):runEndTimes(iScan),:);
end

%% load the data
% whichSlice = [2 27];
whichSlice = [];
disppercent(-inf, 'Loading data');
for iScan = 1:nScans
    data{iScan} = loadTSeries(v, iScan, whichSlice, [], [], [], 'single');
    disppercent(iScan/nScans);
end
disppercent(inf);

%% run GLM dnoise
results = GLMdnoisedata(design, data, 1, 1.75, [], [], [], []);
   
save('glmoutput_exo_nms.mat', 'results','-v7.3')

% parse the output
scanNum = viewGet(v, 'curscan');
groupNum = viewGet(v, 'curgroup');

d.ehdr = results.modelmd{2};
d.ehdrste = results.modelse{2};
d.stimvol = design;
[v dnoiseAnal] = mrDispOverlay(results.R2, scanNum, groupNum, v, 'saveName=dnoiseAnal', 'overlayNames', {'r2'}, 'analName', 'glmdnoise', 'd', d);

mrSetPref('overwritePolicy', 'Merge');
saveAnalysis(v, 'dnoiseAnal');

    

    

    
    
    