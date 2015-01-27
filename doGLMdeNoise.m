% doGLMdeNoise.m
%
%      usage: doGLMdeNoise(v, varargin)
%         by: eli & laura
%       date: 01/17/15
%    purpose: 
%
function v = doGLMdeNoise(v,obs,attCond,whichAnal,scanNum)

% set parameters
groupNum = 'Concatenation';

% get the input arguemnts
v = viewSet(v, 'curGroup', groupNum);
v = viewSet(v, 'curScan', scanNum);
groupName = viewGet(v, 'groupName');
frameperiod = viewGet(v, 'frameperiod');

% get the stimvol
if strcmp(whichAnal,'classic')
    nCond = 23; % 11 correct, 11 incorrect, blinks
    if strcmp(attCond,'exo')
        load('Anal/correctIncorrect_exo_blinks');
        if exist('Anal/exostimvol.mat', 'file')
            load('Anal/exostimvol.mat');
        else
            [stimvol, stimNames, var] = getStimvol(v, ...
                {{'CueCond=[1 2 3 4]','PrePost=1','targLoc=1'},...
                {'CueCond=[5 6 7 8]','PrePost=1','targLoc=1'}, ...
                {'CueCond=[1 2 3 4]','PrePost=2','targLoc=1'}, ...
                {'CueCond=[5 6 7 8]','PrePost=2','targLoc=1'}, ...
                {'CueCond=[1 2 3 4]','PrePost=1','targLoc=2'}, ...
                {'CueCond=[5 6 7 8]','PrePost=1','targLoc=2'}, ...
                {'CueCond=[1 2 3 4]','PrePost=2','targLoc=2'}, ...
                {'CueCond=[5 6 7 8]','PrePost=2','targLoc=2'}, ...
                {'CueCond=9','cueLoc=1'}, ...
                {'CueCond=9','cueLoc=2'}, ...
                {'CueCond=10'}});
            save Anal/exostimvol.mat stimvol stimNames var
        end
    elseif strcmp(attCond,'endo')
        load('Anal/correctIncorrect_endo_blinks');
        if exist('Anal/endostimvol.mat', 'file')
            load('Anal/endostimvol.mat');
        else
            [stimvol, stimNames, var] = getStimvol(v, ...
                {{'CueCond=[1 2 3 4 5 6]','PrePost=1','targLoc=1'},...
                {'CueCond=[7 8]','PrePost=1','targLoc=1'}, ...
                {'CueCond=[1 2 3 4 5 6]','PrePost=2','targLoc=1'}, ...
                {'CueCond=[7 8]','PrePost=2','targLoc=1'}, ...
                {'CueCond=[1 2 3 4 5 6]','PrePost=1','targLoc=2'}, ...
                {'CueCond=[7 8]','PrePost=1','targLoc=2'}, ...
                {'CueCond=[1 2 3 4 5 6]','PrePost=2','targLoc=2'}, ...
                {'CueCond=[7 8]','PrePost=2','targLoc=2'}, ...
                {'CueCond=9','cueLoc=1'}, ...
                {'CueCond=9','cueLoc=2'}, ...
                {'CueCond=10'}});
            save Anal/endostimvol.mat stimvol stimNames var
        end
    end
elseif strcmp(whichAnal,'corbetta')
    nCond = 12;
    if strcmp(attCond,'exo')
        load(['Anal/CIValidInvalid_' obs '_exo']);
        if exist('Anal/exostimvolCorb.mat', 'file')
            load('Anal/exostimvolCorb.mat');
        else
            [stimvol, stimNames, var] = getStimvol(v, ...
                {{'cueLoc=1','PrePost=1'},...% Cue-Left-Pre
                {'cueLoc=1','PrePost=2'},...%  Cue-Left-Post
                {'cueLoc=2','PrePost=1'},...%  Cue-Right-Pre
                {'cueLoc=2','PrePost=2'},...%  Cue-Right-Post
                {'CueCond=9','cueLoc=1'},...%  CueOnly-Left
                {'CueCond=9','cueLoc=2'},...%  CueOnly-Right
                {'CueCond=10'},...%            Blank
                {'CueCond=[1:4]'},...%         RespCue-Valid
                {'CueCond=[5:8]'}...%          RespCue-Invalid
                });
            save Anal/exostimvolCorb.mat stimvol stimNames var
        end
    elseif strcmp(attCond,'endo')
        load(['Anal/CIValidInvalid_' obs '_endo']);
        if exist('Anal/endostimvolCorb.mat', 'file')
            load('Anal/endostimvolCorb.mat');
        else
            [stimvol, stimNames, var] = getStimvol(v, ...
                {{'cueLoc=1','PrePost=1'},...% Cue-Left-Pre
                {'cueLoc=1','PrePost=2'},...%  Cue-Left-Post
                {'cueLoc=2','PrePost=1'},...%  Cue-Right-Pre
                {'cueLoc=2','PrePost=2'},...%  Cue-Right-Post
                {'CueCond=9','cueLoc=1'},...%  CueOnly-Left
                {'CueCond=9','cueLoc=2'},...%  CueOnly-Right
                {'CueCond=10'},...%            Blank
                {'CueCond=[1:6]'},...%         RespCue-Valid
                {'CueCond=[7 8]'}...%          RespCue-Invalid
                });
            save Anal/endostimvolCorb.mat stimvol stimNames var
        end
    end
end

runLength = [];
v = viewSet(v, 'curGroup', ['w-' attCond]);
nScans = viewGet(v, 'nscans');

for iScan = 1:nScans
    runLength = cat(1, runLength, viewGet(v, 'nFrames', iScan));
end

designAllRuns = zeros(sum(runLength), nCond);

if strcmp(whichAnal,'classic')
    % first loop over conditions
    for iCond = 1:length(correctIncorrect)
        % correct trials
        whichVols = stimvol{iCond}(correctIncorrect{iCond}==1);
        designAllRuns(whichVols,iCond) = 1;
        % incorrect trials
        whichVols = stimvol{iCond}(correctIncorrect{iCond}==-1);
        designAllRuns(whichVols,iCond+length(correctIncorrect)) = 1;
        % blinks
        whichVols = stimvol{iCond}(correctIncorrect{iCond}==0);
        designAllRuns(whichVols,end) = 1;
    end
end

if strcmp(whichAnal,'corbetta')
    % get stimvols for correct and incorrect trials
    correctStimvol{1,2} = [];
    incorrectStimvol{1,2} = [];
    blinkStimvol = [];
    for iCond = 1:2
        % correct trials
        correctStimvol{iCond} = stimvol{iCond+7}(CIValidInvalid{iCond}==1);
        % incorrect trials
        incorrectStimvol{iCond} = stimvol{iCond+7}(CIValidInvalid{iCond}==-1);
        % blinks
        blinkStimvol = cat(2, blinkStimvol, stimvol{iCond+7}(CIValidInvalid{iCond}==0));
    end
    % correct/incorrect stimvols
    newstimvol = [stimvol{1:7} correctStimvol incorrectStimvol blinkStimvol];%
    for iCond = 1:length(newstimvol)
        designAllRuns(newstimvol{iCond},iCond) = 1;
    end
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

%% load the data
whichSlice = [];
disppercent(-inf, 'Loading data');
for iScan = 1:nScans
    data{iScan} = loadTSeries(v, iScan, whichSlice, [], [], [], 'single');
    disppercent(iScan/nScans);
end
disppercent(inf);

%% run GLM dnoise
keyboard
results = GLMdenoisedata(design, data, 1, 1.75, [], [], [], []); 
% results = GLMdenoisedata(design, data, 1, 1.75, 'fir', [], [], []); 
save(['glmoutput_' attCond '_' whichAnal '_' obs '.mat'], 'results','-v7.3')

% parse the output
scanNum = viewGet(v, 'curscan');
groupNum = viewGet(v, 'curgroup');

d.ehdr = results.modelmd{2};
d.ehdrste = results.modelse{2};
d.stimvol = design;
[v,dnoiseAnal] = mrDispOverlay(results.R2, scanNum, groupNum, v, ['saveName=dnoiseAnal_' whichAnal], 'overlayNames', {'r2'}, 'analName', 'glmdnoise', 'd', d);

% mrSetPref('overwritePolicy', 'Merge');
% saveAnalysis(v, ['dnoiseAnal_' whichAnal]);

end