% endoexoRvL.m
%
%      usage: endoexoRvL2(v, roiName, varargin)
%         by: eli & laura
%       date: 06/17/14
%    purpose: 
%
function v = endoexoRvL2(v, roiName, varargin)

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
goodVox = localizer{1}.co > locThresh & localizer{1}.ph < pi;

% make sure rois is a cell
rois = cellArray(rois);
tSeries = [];
for i=1:length(rois)
  tSeries = cat(1, tSeries, rois{i}.tSeries);
end
% and average across voxels, based on localizer response
tSeries = nanmean(tSeries(goodVox,:));

% get the stimvol
if strcmp(attCond,'exo')
    load('Anal/correctIncorrect_exo');
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
    load('Anal/correctIncorrect_endo');
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

% get stimvols for correct and incorrect trials
correctStimvol{1,11} = [];
incorrectStimvol{1,11} = [];
for iCond = 1:11
    correctStimvol{iCond} = stimvol{iCond}(correctIncorrect{iCond}==1);
    incorrectStimvol{iCond} = stimvol{iCond}(correctIncorrect{iCond}==-1);
end

% make stimulus convolution matrix 
scm = makescm(v, round(24/frameperiod), 1, stimvol);
scmCI = makescm(v, round(24/frameperiod), 1, [correctStimvol incorrectStimvol]);

% compute the betas
nhdr = length(stimNames);
hdrlen = round(24/frameperiod);
dDec = getr2timecourse(tSeries, nhdr, hdrlen, scm, frameperiod);
nhdrCI = length(stimNames)*2;
dDecCI = getr2timecourse(tSeries, nhdrCI, hdrlen, scmCI, frameperiod); 

% define colors for time series plots
myColors{1}=[10 55 191]/255;
myColors{2}=[191 0 0]/255;
myColors{3}=[207 219 255]/255;
myColors{4}=[255 204 204]/255;

%% Betas from GLM analysis
% creates design matrix and d structure for computing GLM
verbose = 1;
params.scanParams{scanNum}.highpassDesign = 1;

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

% first make design matrix for all trials
d.stimvol = stimvol;
for iRun=1:length(stimvol)
    d.stimDurations{iRun} = ones(size(stimvol{iRun}));
end
d = makeDesignMatrix(d,params,verbose, scanNum);

% then make design matrix seperately for correct/incorrect trials
dCI = d;
dCI.stimvol = [correctStimvol incorrectStimvol];
for iRun=1:length(dCI.stimvol)
    dCI.stimDurations{iRun} = ones(size(dCI.stimvol{iRun}));
end
dCI = makeDesignMatrix(dCI,params,verbose, scanNum);

%yMax = ceil(10*(max(dGLM.ehdr(:)+max(dGLM.ehdrste(:)))))/10;
%yMin = min(0, floor(10*(min(dGLM.ehdr(:)-max(dGLM.ehdrste(:)))))/10);

%% Remove the motor response
% which we estimated from the blank trials of the deconvolution analysis
% step 1: get the deconvolved response to the blank trials
dd.tr = frameperiod;
dd.designSupersampling = 1;
dd.dim = [1 1 1 length(tSeries)];
dd.concatInfo = viewGet(v, 'concatInfo');
% this HRF is the response to the blank trial only
dd.hrf = dDec.ehdr(11,:)';
dd.hdrlen = 14;
for iRun=1:dd.concatInfo.n
    dd.concatInfo.hipassfilter{iRun} = [];
end

% step 2: get the stimvols for all trial types
% collapsing across conditions
newstimvol = [];
for iCond=1:length(d.stimvol)
    newstimvol = cat(2, newstimvol, d.stimvol{iCond});
end
newstimvol = sort(newstimvol);
dd.stimvol{1} = newstimvol;
dd.stimDurations{1} = ones(size(dd.stimvol{1}));
% and make the design matrix for onset time of _any_ trial
dd = makeDesignMatrix(dd,[],verbose, scanNum);

% step 3: subtract the blank trial from the time series
temp = 100*(tSeries-1);
residual = temp - (dd.scm)';
residual = (residual/100)+1;

%% compute responses from the residual time series

% do deconvolution on the residual time series
nhdr = length(stimNames);
hdrlen = round(24/frameperiod);
% for all trials
dDec = getr2timecourse(residual, nhdr, hdrlen, scm, frameperiod);
% for correct/incorrect 
dDecCI = getr2timecourse(residual, nhdr, hdrlen, scm, frameperiod);

% do GLM on the residual time series
hdrlen = 1;
dGLM = getr2timecourse(residual, nhdr, hdrlen, d.scm, d.tr);
dGLMCI = getr2timecourse(residual, nhdrCI, hdrlen, dCI.scm, dCI.tr);

%% Plot the MRI response over time -- for both correct and incorrect
smartfig('tSeriesPlot1', 'reuse'); clf;
% title  for the figure based on the ROI
suptitle(sprintf('ROI: %s', fixBadChars(roiName, {'_',' '})));

% plot the responses for target in the LVF
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

% plot the respones for target in the RVF
subplot(1,3,2); cla
for i=5:8
  myerrorbar(dDec.time, dDec.ehdr(i,:), 'yError', dDec.ehdrste(i,:), 'MarkerFaceColor', myColors{i-4});
end
axis square
ylim([yMin yMax]);
xlabel('Time (seconds)');

drawPublishAxis('yTick',[yMin 0 yMax], 'xTick',[0 25], 'titleStr', 'Target in RVF');
%h_legend = mylegend({'Pre Valid', 'Pre Invalid', 'Post Valid', 'Post Invalid'}, myColors);
%set(h_legend, 'box', 'off')

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
axis square;
drawPublishAxis('yTick', [0 yMax/2 yMax],'xTickLabel',{'LVF' 'RVF'});

%% Plot the MRI response over time -- ONLY for correct responses
smartfig('tSeriesPlot2', 'reuse'); clf;
% title  for the figure based on the ROI
suptitle(sprintf('ROI: %s', fixBadChars(roiName, {'_',' '})));

% plot the responses for target in the LVF
subplot(1,3,1); cla
yMax = ceil(10*(max(dDecCI.ehdr(:)+max(dDecCI.ehdrste(:)))))/10;
yMin = floor(10*(min(dDecCI.ehdr(:)-max(dDecCI.ehdrste(:)))))/10;
for i=1:4
  myerrorbar(dDecCI.time, dDecCI.ehdr(i,:), 'yError', dDecCI.ehdrste(i,:), 'MarkerFaceColor', myColors{i});
end
ylabel('fMRI resp (% chg img intensity)');
xlabel('Time (seconds)');
axis square
ylim([yMin yMax]);
drawPublishAxis('yTick',[yMin 0 yMax], 'xTick',[0 25],'titleStr', 'Target in LVF');

% plot the respones for target in the RVF
subplot(1,3,2); cla
for i=5:8
  myerrorbar(dDecCI.time, dDecCI.ehdr(i,:), 'yError', dDecCI.ehdrste(i,:), 'MarkerFaceColor', myColors{i-4});
end
axis square
ylim([yMin yMax]);
xlabel('Time (seconds)');

drawPublishAxis('yTick',[yMin 0 yMax], 'xTick',[0 25], 'titleStr', 'Target in RVF');
%h_legend = mylegend({'Pre Valid', 'Pre Invalid', 'Post Valid', 'Post Invalid'}, myColors);
%set(h_legend, 'box', 'off')

yMax = ceil(10*(max(dGLMCI.ehdr(:)+max(dGLMCI.ehdrste(:)))))/10;
yMin = min(0, floor(10*(min(dGLMCI.ehdr(:)-max(dGLMCI.ehdrste(:)))))/10);

subplot(1,3,3); 
cla
for iBar=1:4
    bar([iBar iBar+6], dGLMCI.ehdr([iBar iBar+4],1), 0.1, 'facecolor', myColors{iBar});
    hold on
    errorbar([iBar iBar+6], dGLMCI.ehdr([iBar iBar+4],1), dGLMCI.ehdrste([iBar iBar+4], 1), 'o', 'color', myColors{iBar});
end
xaxis([0 11]);
axis square;
drawPublishAxis('yTick', [0 yMax/2 yMax],'xTickLabel',{'LVF' 'RVF'});

%%

% % save the PDF of the time courses
% print_pdf(fullfile('Figures', sprintf('%s.pdf', stripext(roiName))));

% print('-djpeg','-r500',['Images_Rois/' attCond '/removed/' roiName '_' attCond '_respRemoved']);

if ~exist('Anal', 'dir')
  mkdir('Anal');
end
temp = fixBadChars(num2str(locThresh), [],{'.',''});
% eval(sprintf(['save Anal/' attCond '/threshold/anal_%s_' attCond '_LocThresh' temp '.mat dGLM dGLM2 dDec dDec2 rois'], stripext(roiName)))

eval(sprintf(['save Anal/' attCond '/anal_%s_' attCond '_CI.mat dGLM dGLMCI dDec dDecCI rois'], stripext(roiName)))

