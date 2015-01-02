% endoexoRvL.m
%
%      usage: endoexoRvL2(v, roiName, varargin)
%         by: eli & laura
%       date: 06/17/14
%    purpose: 
%
function v = endoexoRvLCorb(v, roiName, varargin)

% check arguments
if ~any(nargin == [2:10])
  help endoexoRvL
  return
end

% get the input arguemnts
getArgs(varargin, [], 'verbose=0');
if ieNotDefined('scanNum'); scanNum = 3;end
if ieNotDefined('groupNum'); groupNum = 'Concatenation';end
if ieNotDefined('locThresh'); locThresh = 0; end
if ieNotDefined('locGroup'); locGroup = 'Averages'; end
if ieNotDefined('locScan'); locScan = 1; end

v = viewSet(v, 'curGroup', groupNum);
v = viewSet(v, 'curScan', scanNum);
groupName = viewGet(v, 'groupName');
frameperiod = viewGet(v, 'frameperiod');

% get attCond
if strfind(viewGet(v, 'description'), 'exo')
    attCond = 'exo';
    disp(sprintf('Attention condition: %s', attCond));
elseif strfind(viewGet(v, 'description'), 'endo')
    attCond = 'endo';
    disp(sprintf('Attention condition: %s', attCond));
else
    disp(sprintf('UHOH: Attention unknown!!!'));
    return;
end

%% Load the fMRI time series within the ROI
rois = loadROITSeries(v, roiName, scanNum, groupNum, 'keepNAN',true);

% load the localizer corAnal
localizer = loadROIcoranalMatching(v, roiName, locScan, locGroup, scanNum, groupNum);
goodVox = localizer{1}.co > locThresh & localizer{1}.ph < pi & ~isnan(mean(rois.tSeries,2));

% make sure rois is a cell
rois = cellArray(rois);
tSeries = [];
for i=1:length(rois)
  tSeries = cat(1, tSeries, rois{i}.tSeries);
end

% and average across voxels, based on localizer response
tSeries = mean(tSeries(goodVox,:));

% get the stimvol
if strcmp(attCond,'exo')
    load('Anal/correctIncorrect_exo_blinks');
    if exist('Anal/exostimvolCorb.mat', 'file')
        load('Anal/exostimvolCorb.mat');
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
            {'CueCond=[1:10]'}, ...
            {'CueCond=1:9','cueLoc=1'}, ...
            {'CueCond=1:9','cueLoc=2'}, ...
            {'CueCond=1:8'}});
        save Anal/exostimvolCorb.mat stimvol stimNames var
    end
elseif strcmp(attCond,'endo')
    load('Anal/correctIncorrect_endo_blinks');
    if exist('Anal/endostimvolCorb.mat', 'file')
        load('Anal/endostimvolCorb.mat');
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
            {'CueCond=[1:10]'}, ...
            {'CueCond=1:9','cueLoc=1'}, ...
            {'CueCond=1:9','cueLoc=2'}, ...
            {'CueCond=1:8'}});
        save Anal/endostimvolCorb.mat stimvol stimNames var
    end
end

% get stimvols for correct and incorrect trials
correctStimvol{1,8} = [];
incorrectStimvol{1,8} = [];
blinkStimvol = [];
for iCond = 1:8
    correctStimvol{iCond} = stimvol{iCond}(correctIncorrect{iCond}==1);
    incorrectStimvol{iCond} = stimvol{iCond}(correctIncorrect{iCond}==-1);
    blinkStimvol = cat(2, blinkStimvol, stimvol{iCond}(correctIncorrect{iCond}==0));
end

% correct/incorrect stimvols
stimvol = [correctStimvol incorrectStimvol stimvol{9:end} blinkStimvol];

% make stimulus convolution matrix 
scm = makescm(v, round(24/frameperiod), 1, stimvol);

%scm = makescm(d, round(24/frameperiod), 0, stimvol);


% compute the betas
hdrlen = round(24/frameperiod);
nhdr = length(stimvol);
dDec = getr2timecourse(tSeries, nhdr, hdrlen, scm, frameperiod); 

% define colors for time series plots
myColors{1}=[10 55 191]/255;
myColors{2}=[191 0 0]/255;
myColors{3}=[207 219 255]/255;
myColors{4}=[255 204 204]/255;
myColors{5}=[128 128 128]/255;
myColors{6}=[128 128 128]/255;
myColors{7}=[0 0 0]/255;

%% Betas from GLM analysis
% creates design matrix and d structure for computing GLM
verbose = 1;
params.scanParams{scanNum}.highpassDesign = 0;

% create model HRF
params.x = 6;
params.y = 16;
params.z = 6;
params.stimDur = 0.01;
params.incDeriv = 0;
d.hrf = hrfDiffGamma(1.75, params);
d.tr = frameperiod;
d.dim = [1 1 1 length(tSeries)];
d.concatInfo = viewGet(v, 'concatInfo');
d.designSupersampling = 1;

% then make design matrix seperately for correct/incorrect trials
d.stimvol = stimvol;
for iCond=1:length(d.stimvol)
    d.stimDurations{iCond} = ones(size(d.stimvol{iCond}));
end
d = makeDesignMatrix(d,params,verbose, scanNum);

hdrlen = 1;
keyboard
dGLM = getr2timecourse(tSeries, nhdr, hdrlen, d.scm, d.tr);

%% Plot the MRI response over time for CORRECT trials

% create a new figure
smartfig('tSeriesPlot1', 'reuse'); clf;
% title  for the figure based on the ROI
suptitle(sprintf('Correct trials (%s), nVox=%i', fixBadChars(roiName, {'_',' '}), sum(goodVox)));

% plot the responses for target in the LVF, CORRECT TRIALS
subplot(1,3,1); cla
yMax = ceil(10*(max(dDec.ehdr(:)+max(dDec.ehdrste(:)))))/10;
yMin = floor(10*(min(dDec.ehdr(:)-max(dDec.ehdrste(:)))))/10;
for i=1:4
  myerrorbar(dDec.time, dDec.ehdr(i,:), 'yError', dDec.ehdrste(i,:), 'MarkerFaceColor', myColors{i});
end
ylabel('fMRI resp (% chg img intensity)');
xlabel('Time (seconds)');
axis square
ylim([yMin yMax]);
drawPublishAxis('yTick',[yMin 0 yMax], 'xTick',[0 25],'titleStr', 'Target in LVF');

% plot the respones for target in the RVF, CORRECT TRIALS
subplot(1,3,2); cla
for i=5:8
  myerrorbar(dDec.time, dDec.ehdr(i,:), 'yError', dDec.ehdrste(i,:), 'MarkerFaceColor', myColors{i-4});
end
axis square
ylim([yMin yMax]);
xlabel('Time (seconds)');
drawPublishAxis('yTick',[yMin 0 yMax], 'xTick',[0 25], 'titleStr', 'Target in RVF');

% - GLM - %
yMax = ceil(10*(max(dGLM.ehdr(:)+max(dGLM.ehdrste(:)))))/10;
yMin = min(0, floor(10*(min(dGLM.ehdr(:)-max(dGLM.ehdrste(:)))))/10);

subplot(1,3,3); 
cla
for iBar=1:4
    bar([iBar iBar+6], dGLM.ehdr([iBar iBar+4],1), 0.1, 'facecolor', myColors{iBar});
    hold on
    errorbar([iBar iBar+6], dGLM.ehdr([iBar iBar+4],1), dGLM.ehdrste([iBar iBar+4], 1), 'o', 'color', myColors{iBar});
end
xaxis([0 11]);
yaxis([yMin yMax]);
axis square;
box off 
drawPublishAxis('yTick', [yMin 0 yMax],'xTickLabel',{'LVF' 'RVF'});

%% Plot the MRI response over time for INCORRECT trials

% create a new figure
smartfig('tSeriesPlot2', 'reuse'); clf;
% title  for the figure based on the ROI
suptitle(sprintf('Incorrect trials (%s), nVox=%i', fixBadChars(roiName, {'_',' '}), sum(goodVox)));

% plot the responses for target in the LVF, INCORRECT TRIALS
subplot(1,3,1); cla
yMax = ceil(10*(max(dDec.ehdr(:)+max(dDec.ehdrste(:)))))/10;
yMin = floor(10*(min(dDec.ehdr(:)-max(dDec.ehdrste(:)))))/10;
for i=9:12
  myerrorbar(dDec.time, dDec.ehdr(i,:), 'yError', dDec.ehdrste(i,:), 'MarkerFaceColor', myColors{i-8});
end
ylabel('fMRI resp (% chg img intensity)');
xlabel('Time (seconds)');
axis square
ylim([yMin yMax]);
drawPublishAxis('yTick',[yMin 0 yMax], 'xTick',[0 25],'titleStr', 'Target in LVF');


% plot the respones for target in the RVF, INCORRECT TRIALS
subplot(1,3,2); cla
for i=13:16
  myerrorbar(dDec.time, dDec.ehdr(i,:), 'yError', dDec.ehdrste(i,:), 'MarkerFaceColor', myColors{i-12});
end
axis square
ylim([yMin yMax]);
xlabel('Time (seconds)');
drawPublishAxis('yTick',[yMin 0 yMax], 'xTick',[0 25], 'titleStr', 'Target in RVF');

% - GLM - %
yMax = ceil(10*(max(dGLM.ehdr(:)+max(dGLM.ehdrste(:)))))/10;
yMin = min(0, floor(10*(min(dGLM.ehdr(:)-max(dGLM.ehdrste(:)))))/10);

subplot(1,3,3); 
cla
for iBar=9:12
    bar([iBar-8 iBar+6-8], dGLM.ehdr([iBar iBar+4],1), 0.1, 'facecolor', myColors{iBar-8});
    hold on
    errorbar([iBar-8 iBar+6-8], dGLM.ehdr([iBar iBar+4],1), dGLM.ehdrste([iBar iBar+4], 1), 'o', 'color', myColors{iBar-8});
end
xaxis([0 11]);
yaxis([yMin yMax]);
axis square;
box off 
drawPublishAxis('yTick', [yMin 0 yMax],'xTickLabel',{'LVF' 'RVF'});

%% Plot the MRI response over time for REMAINING trials

myColors{1}=[0 0 0]/255;
myColors{2}=[0 255 0]/255;
myColors{3}=[0 128 0]/255;
myColors{4}=[255 0 0]/255;
myColors{5}=[128 128 128]/255;

% create a new figure
smartfig('tSeriesPlot3', 'reuse'); clf;
% title  for the figure based on the ROI
suptitle(sprintf('Remaining trials (%s), nVox=%i', fixBadChars(roiName, {'_',' '}), sum(goodVox)));

subplot(1,2,1); cla
for i=17:21
  myerrorbar(dDec.time, dDec.ehdr(i,:), 'yError', dDec.ehdrste(i,:), 'MarkerFaceColor', myColors{i-16});
end
axis square
ylim([yMin yMax]);
xlabel('Time (seconds)');
drawPublishAxis('yTick',[yMin 0 yMax], 'xTick',[0 25], 'titleStr', 'Target in RVF');

% - GLM - %
%%
subplot(1,2,2); 
yMax = ceil(10*(max(dGLM.ehdr(17:21)+max(dGLM.ehdrste(17:21)))))/10;
yMin = min(0, floor(10*(min(dGLM.ehdr(17:21)-max(dGLM.ehdrste(17:21)))))/10);
cla
for iBar=1:5
    bar(iBar, dGLM.ehdr(iBar+16),  0.4, 'facecolor', myColors{iBar})
    hold on
    errorbar(iBar , dGLM.ehdr(iBar+16), dGLM.ehdrste(iBar+16), 'o', 'color', myColors{iBar});
end
ylim([yMin yMax])
axis square;
box off 
drawPublishAxis('yTick', [yMin 0 yMax],'xTick', [1:5], 'xTickLabel', {'Response' 'CueL' 'CueR' 'Stimulus' 'Blinks'});

%%

% % save the PDF of the time courses
% print_pdf(fullfile('Figures', sprintf('%s.pdf', stripext(roiName))));

% print('-djpeg','-r500',['Images_Rois/' attCond '/removed/' roiName '_' attCond '_respRemoved']);

if ~exist('Anal', 'dir')
  mkdir('Anal');
end
temp = fixBadChars(num2str(locThresh), [],{'.',''});

eval(sprintf(['save Anal/' attCond '/anal_%s_' attCond '_Corb.mat dGLM dDec rois'], stripext(roiName)))

