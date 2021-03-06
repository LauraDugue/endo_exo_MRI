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
if strcmp(whichAnal,'visualCortex')
    nCond = 23; % 11 correct, 11 incorrect, blinks
    if strcmp(attCond,'exo')
        load(['Anal/CIValidInvalid_' obs '_exo']);
        if exist('Anal/exostimvolVisual.mat', 'file')
            load('Anal/exostimvolVisual.mat');
        else
            [stimvol, stimNames, var] = getStimvol(v, ...
                {{'CueCond=[1:8]','cueLoc=1','PrePost=1'},...% Cue-Left-Pre
                {'CueCond=[1:8]','cueLoc=1','PrePost=2'},...%  Cue-Left-Post
                {'CueCond=[1:8]','cueLoc=2','PrePost=1'},...%  Cue-Right-Pre
                {'CueCond=[1:8]','cueLoc=2','PrePost=2'},...%  Cue-Right-Post
                {'CueCond=9','cueLoc=1'},...%  CueOnly-Left
                {'CueCond=9','cueLoc=2'},...%  CueOnly-Right
                {'CueCond=10'},...%            Blank
                %{'CueCond=[1:4]'},...%         RespCue-Valid
                %{'CueCond=[5:8]'}...%          RespCue-Invalid
                });
            save Anal/exostimvolVisual.mat stimvol stimNames var
        end
    elseif strcmp(attCond,'endo')
        load(['Anal/CIValidInvalid_' obs '_endo']);
        if exist('Anal/endostimvolVisual.mat', 'file')
            load('Anal/endostimvolVisual.mat');
        else
            [stimvol, stimNames, var] = getStimvol(v, ...
                {{'CueCond=[1:8]','cueLoc=1','PrePost=1'},...% Cue-Left-Pre
                {'CueCond=[1:8]','cueLoc=1','PrePost=2'},...%  Cue-Left-Post
                {'CueCond=[1:8]','cueLoc=2','PrePost=1'},...%  Cue-Right-Pre
                {'CueCond=[1:8]','cueLoc=2','PrePost=2'},...%  Cue-Right-Post
                {'CueCond=9','cueLoc=1'},...%  CueOnly-Left
                {'CueCond=9','cueLoc=2'},...%  CueOnly-Right
                {'CueCond=10'},...%            Blank
                %{'CueCond=[1:4]'},...%         RespCue-Valid
                %{'CueCond=[5:8]'}...%          RespCue-Invalid
                });
            save Anal/endostimvolVisual.mat stimvol stimNames var
        end
    end
elseif strcmp(whichAnal,'TPJ')
    if strcmp(attCond,'exo')
        load(['Anal/CIValidInvalid_' obs '_exo']);
        if exist('Anal/exostimvolTPJ.mat', 'file')
            load('Anal/exostimvolTPJ.mat');
        else
            [stimvol, stimNames, var] = getStimvol(v, ...
                {...%{'CueCond=[1:8]','cueLoc=1','PrePost=1'},...% Cue-Left-Pre
                %{'CueCond=[1:8]','cueLoc=1','PrePost=2'},...%  Cue-Left-Post
                %{'CueCond=[1:8]','cueLoc=2','PrePost=1'},...%  Cue-Right-Pre
                %{'CueCond=[1:8]','cueLoc=2','PrePost=2'},...%  Cue-Right-Post
                {'CueCond=9','cueLoc=1'},...%  CueOnly-Left
                {'CueCond=9','cueLoc=2'},...%  CueOnly-Right
                {'CueCond=10'},...%            Blank
                {'CueCond=[1:4]'},...%         RespCue-Valid
                {'CueCond=[5:8]'}...%          RespCue-Invalid
                });
            save Anal/exostimvolTPJ.mat stimvol stimNames var
        end
    elseif strcmp(attCond,'endo')
        load(['Anal/CIValidInvalid_' obs '_endo']);
        if exist('Anal/endostimvolTPJ.mat', 'file')
            load('Anal/endostimvolTPJ.mat');
        else
            [stimvol, stimNames, var] = getStimvol(v, ...
                {...%{'CueCond=[1:8]','cueLoc=1','PrePost=1'},...% Cue-Left-Pre
                %{'CueCond=[1:8]','cueLoc=1','PrePost=2'},...%  Cue-Left-Post
                %{'CueCond=[1:8]','cueLoc=2','PrePost=1'},...%  Cue-Right-Pre
                %{'CueCond=[1:8]','cueLoc=2','PrePost=2'},...%  Cue-Right-Post
                {'CueCond=9','cueLoc=1'},...%  CueOnly-Left
                {'CueCond=9','cueLoc=2'},...%  CueOnly-Right
                {'CueCond=10'},...%            Blank
                {'CueCond=[1:6]'},...%         RespCue-Valid
                {'CueCond=[7 8]'}...%          RespCue-Invalid
                });
            save Anal/endostimvolTPJ.mat stimvol stimNames var
        end
    end
elseif strcmp(whichAnal,'first')
    if strcmp(attCond,'exo')
        load(['Anal/correctIncorrect_' obs '_exo']);
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
        load(['Anal/correctIncorrect_' obs '_endo']);
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
end

runLength = [];
v = viewSet(v, 'curGroup', ['w-' attCond]);
nScans = viewGet(v, 'nscans');

for iScan = 1:nScans
    runLength = cat(1, runLength, viewGet(v, 'nFrames', iScan));
end

if strcmp(whichAnal,'visualCortex')
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % get stimvols for correct and incorrect trials
    Blink{1,length(stimvol)} = [];
    noBlink{1,length(stimvol)} = [];
    
    for iCond = 1:4 %1:length(stimvol)
        Blink{iCond} = stimvol{iCond}(CIValidInvalid{iCond}==0);
        % the noBlink stimvols are what we will use in the design matrix
        noBlink{iCond} = stimvol{iCond}(CIValidInvalid{iCond}~=0);
    end
    
    % fill in the trials for which we do not care about blinks
    for iCond=5:7
        noBlink{iCond}=stimvol{iCond};
    end
    
    blinkStimvol = sort([Blink{1}';Blink{2}';Blink{3}';Blink{4}'])';
    
    % correct/incorrect stimvols
    newstimvol = [noBlink blinkStimvol];%
    designAllRuns = zeros(sum(runLength), length(newstimvol));
    
    for iCond = 1:length(newstimvol)
        designAllRuns(newstimvol{iCond},iCond) = 1;
    end
end
if strcmp(whichAnal,'TPJ')
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % get stimvols for correct and incorrect trials
    Blink{1,length(stimvol)} = [];
    noBlink{1,length(stimvol)} = [];
    for iCond = 4:5 %1:length(stimvol)
        Blink{iCond} = stimvol{iCond}(CIValidInvalid{iCond+4}==0);
        % the noBlink stimvols are what we will use in the design matrix
        noBlink{iCond} = stimvol{iCond}(CIValidInvalid{iCond+4}~=0);
    end
    
    % fill in the trials for which we do not care about blinks
    for iCond=1:3
        noBlink{iCond}=stimvol{iCond};
    end
    
    correctStimvol{1,2} = [];
    incorrectStimvol{1,2} = [];
    for iCond = 8:9
        % correct trials
        correctStimvol{iCond-7} = stimvol{iCond-4}(CIValidInvalid{iCond}==1);
        % incorrect trials
        incorrectStimvol{iCond-7} = stimvol{iCond-4}(CIValidInvalid{iCond}==-1);
    end
    
    blinkStimvol = sort([Blink{4}';Blink{5}'])';
    
    % correct/incorrect stimvols
    newstimvol = [noBlink{1:3} correctStimvol incorrectStimvol blinkStimvol];%
    designAllRuns = zeros(sum(runLength), length(newstimvol));
    
    for iCond = 1:length(newstimvol)
        designAllRuns(newstimvol{iCond},iCond) = 1;
    end
end
if strcmp(whichAnal,'first')
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % get stimvols for correct and incorrect trials
    Blink{1,length(stimvol)} = [];
    noBlink{1,length(stimvol)} = [];
    
    for iCond = 1:8
        Blink{iCond} = stimvol{iCond}(correctIncorrect{iCond}==0);
        % the noBlink stimvols are what we will use in the design matrix
        noBlink{iCond} = stimvol{iCond}(correctIncorrect{iCond}~=0);
    end
    
    % fill in the trials for which we do not care about blinks
    for iCond=9:11
        noBlink{iCond}=stimvol{iCond};
    end
    
    blinkStimvol = sort([Blink{1}';Blink{2}';Blink{3}';Blink{4}';Blink{5}';Blink{6}';Blink{7}';Blink{8}'])';
    
    % correct/incorrect stimvols
    newstimvol = [noBlink blinkStimvol];%
    designAllRuns = zeros(sum(runLength), length(newstimvol));
    
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
whichScans = 1:nScans;

rois = loadROITSeries(v, 'r_vTPJ', whichScans);
for i=1:nScans; nVox(i) = rois{i}.n; end

whichScans = whichScans(nVox>=(max(nVox)/4*3));
disp(whichScans)

disppercent(-inf, 'Loading data');
idxScan = 0;
for iScan = whichScans
    idxScan = idxScan +1;
    data{idxScan} = loadTSeries(v, iScan, whichSlice, [], [], [], 'single');
    disppercent(iScan/nScans);
    d{idxScan} = design{iScan};
end
disppercent(inf);

design = d;

%% run GLM dnoise
[results,denoiseddata] = GLMdenoisedata(design, data, 1, 1.75,[], [], [], []);
save(['glmoutput_' attCond '_' whichAnal '_CI_' obs '_results.mat'], 'results','-v7.3')
save(['glmoutput_' attCond '_' whichAnal '_CI_' obs '_denoiseddata.mat'], 'denoiseddata','-v7.3')

% parse the output
scanNum = viewGet(v, 'curscan');
groupNum = viewGet(v, 'curgroup');

d.ehdr = results.modelmd{2};
d.ehdrste = results.modelse{2};
d.stimvol = design;
[v,dnoiseAnal] = mrDispOverlay(results.R2, scanNum, groupNum, v, ['saveName=dnoiseAnal_' whichAnal], 'overlayNames', {'r2'}, 'analName', 'glmdnoiseboot', 'd', d);

% mrSetPref('overwritePolicy', 'Merge');
% saveAnalysis(v, ['dnoiseAnal_' whichAnal]);

end