

% v = newView;
v = viewSet(v, 'curGroup', 'endo');
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
v = viewSet(v, 'curGroup', 'w-endo');
for iScan = 1:nScans
    runLength = cat(1, runLength, viewGet(v, 'nFrames', iScan));
end

nCond = 23; % 11 correct, 11 incorrect, blinks

% load the stim vols
stimvol = load('Anal/endostimvol.mat');
load('Anal/correctIncorrect_endo_blinks.mat');

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

%%

% load the data
whichSlice = 2:27;
disppercent(-inf, 'Loading data');
for iScan = 1:nScans
    data{iScan} = loadTSeries(v, iScan, whichSlice, [], [], [], 'single');
    disppercent(iScan/nScans);
end
disppercent(inf);

% run GLM denoise
[results, denoisedata] = GLMdenoisedata(design, data, 1, 1.75, [], [], [], []);
   




    



    

    
    
    