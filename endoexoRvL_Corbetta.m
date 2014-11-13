% endoexoRvL_Corbetta.m
function v = endoexoRvL_Corbetta(v, roiName, attCond, varargin)

% check arguments
if ~any(nargin == [2:10])
  help endoexoRvL
  return
end

% get the input arguemnts
getArgs(varargin, [], 'verbose=0');
if ieNotDefined('scanNum'); scanNum = 2;end
if ieNotDefined('groupNum'); groupNum = 'Concatenation';end
if ieNotDefined('locThresh'); locThresh = 0.2; end
if ieNotDefined('locGroup'); locGroup = 'Averages'; end
if ieNotDefined('locScan'); locScan = 1; end

v = viewSet(v, 'curGroup', groupNum);
v = viewSet(v, 'curScan', scanNum);
groupName = viewGet(v, 'groupName');
frameperiod = viewGet(v, 'frameperiod');

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
    if exist('Anal/exostimvol_Corb.mat', 'file')
        load('Anal/exostimvol_Corb.mat');
    else
        [stimvol, stimNames, var] = getStimvol(v, ...
            {{'CueCond=10'},...
            {'CueCond=9','cueLoc=1'}, ...
            {'CueCond=9','cueLoc=2'}, ...
            {'CueCond=[1 2 3 4]','cueLoc=1'},...
            {'CueCond=[1 2 3 4]','cueLoc=2'},...
            {'CueCond=[5 6 7 8]','cueLoc=1'},...
            {'CueCond=[5 6 7 8]','cueLoc=2'}});
        save Anal/exostimvol_Corb.mat stimvol stimNames var
    end
elseif strcmp(attCond,'endo')
    if exist('Anal/endostimvol_Corb.mat', 'file')
        load('Anal/endostimvol_Corb.mat');
    else
        [stimvol, stimNames, var] = getStimvol(v, ...
            {{'CueCond=10'},...
            {'CueCond=9','cueLoc=1'}, ...
            {'CueCond=9','cueLoc=2'}, ...
            {'CueCond=[1 2 3 4 5 6]','cueLoc=1'},...
            {'CueCond=[1 2 3 4 5 6]','cueLoc=2'},...
            {'CueCond=[7 8]','cueLoc=1'},...
            {'CueCond=[7 8]','cueLoc=2'}});
        save Anal/endostimvol_Corb.mat stimvol stimNames var
    end
end
keyboard
% make stimulus convolution analysis
scm = makescm(v, round(24/frameperiod), 1, stimvol);

% compute the betas
nhdr = length(stimNames);
hdrlen = round(24/frameperiod);
dDec = getr2timecourse(tSeries, nhdr, hdrlen, scm, frameperiod); 

myColors{1}=[0 0 0];
myColors{2}=[0.5 0.5 0.5];
myColors{3}=[10 55 191]/255;
myColors{4}=[191 0 0]/255;

%% Plot the MRI response over time

% create a new figure
smartfig('tSeriesPlot', 'reuse'); clf;
% title  for the figure based on the ROI
suptitle(sprintf([attCond ': %s'], fixBadChars(roiName, {'_',' '})));

% plot the responses for target in the LVF
subplot(1,3,1); cla
yMax = ceil(10*(max(dDec.ehdr(:)+max(dDec.ehdrste(:)))))/10;
yMin = floor(10*(min(dDec.ehdr(:)-max(dDec.ehdrste(:)))))/10;
count=0;
for i=[1 2 4 6]
    count = count + 1;
    myerrorbar(dDec.time, dDec.ehdr(i,:), 'yError', dDec.ehdrste(i,:), 'MarkerFaceColor', myColors{count});
end
ylabel('fMRI resp (% chg img intensity)');
xlabel('Time (seconds)');
axis square
ylim([yMin yMax]);
drawPublishAxis('yTick',[yMin 0 yMax], 'xTick',[0 25],'titleStr', 'Cue in LVF');

% plot the respones for target in the RVF
subplot(1,3,2); cla
count=0;
for i=[1 3 5 7]
    count = count + 1;
    myerrorbar(dDec.time, dDec.ehdr(i,:), 'yError', dDec.ehdrste(i,:), 'MarkerFaceColor', myColors{count});
end
axis square
ylim([yMin yMax]);
xlabel('Time (seconds)');

drawPublishAxis('yTick',[yMin 0 yMax], 'xTick',[0 25], 'titleStr', 'Cue in RVF');
%h_legend = mylegend({'Pre Valid', 'Pre Invalid', 'Post Valid', 'Post Invalid'}, myColors);
%set(h_legend, 'box', 'off')

%% Betas from GLM analysis

%create model HRF
[params, d.hrf] = hrfDoubleGamma([], frameperiod, [], 'defaultParams=1');
d.tr = frameperiod;
d.dim = [1 1 1 length(tSeries)];
d.stimvol = stimvol;
d.concatInfo = viewGet(v, 'concatInfo');
d.designSupersampling = 1;
for iRun=1:length(stimvol)
    d.stimDurations{iRun} = ones(size(stimvol{iRun}));
end
verbose = 1;
d = makeDesignMatrix(d,[],verbose, scanNum);
% compute estimates and statistics
%[d, out] = getGlmStatistics(d, params, verbose, precision, actualData);%, computeTtests,computeBootstrap);

% compute the betas
hdrlen = 1;
dGLM = getr2timecourse(tSeries, nhdr, hdrlen, d.scm, d.tr); 
yMax = ceil(10*(max(dGLM.ehdr(:)+max(dGLM.ehdrste(:)))))/10;
yMin = min(0, floor(10*(min(dGLM.ehdr(:)-max(dGLM.ehdrste(:)))))/10);

subplot(1,3,3); 
cla
bar(1, dGLM.ehdr(1,1), 0.5, 'facecolor', myColors{1});
hold on
errorbar(1, dGLM.ehdr(1,1), dGLM.ehdrste(1,1), 'o', 'color', myColors{1});

count = 0;
for iBar = [2 4 6]
    count = count + 1;
    bar(count+2, dGLM.ehdr(iBar,1), 0.5, 'facecolor', myColors{count+1});
    hold on
    errorbar(count+2, dGLM.ehdr(iBar,1), dGLM.ehdrste(iBar,1), 'o', 'color', myColors{count+1});
end
count = 0;
for iBar = [3 5 7]
    count = count + 1;
    bar(count+7, dGLM.ehdr(iBar,1), 0.5, 'facecolor', myColors{count+1});
    hold on
    errorbar(count+7, dGLM.ehdr(iBar,1), dGLM.ehdrste(iBar,1), 'o', 'color', myColors{count+1});
end
xaxis([0 11]);
axis square;
drawPublishAxis('yTick', [0 yMax/2 yMax], 'xTick', [1 4 9], 'xTickLabel', {'Blank' 'Left' 'Right'});

% mybar(reshape(dGLM.ehdr(1:8,1),4,2)', 'yError', reshape(dGLM.ehdrste(1:8,1),4,2)', 'dispValues', 0, 'groupLabels', {'Target in LVF', 'Target in RVF'},...
% 'yLabelText', 'fMRI response (% change image intensity)','yAxisMin', yMin, 'yAxisMax',yMax, 'withinGroupColors',myColors)
% , 'dispValues', 0, 'groupLabels', {'Target in LVF', 'Target in RVF'},...
% 'yLabelText', 'fMRI response (% change image intensity)','yAxisMin', yMin, 'yAxisMax',yMax, 'withinGroupColors',myColors)


%save the PDF of the time courses
%print_pdf(fullfile('Figures', sprintf('%s.pdf', stripext(roiName))));

% print('-djpeg','-r500',[roiName '_' attCond]);

if ~exist('Anal', 'dir')
  mkdir('Anal');
end
eval(sprintf(['save Anal/' attCond '/Corbetta/anal_%s_' attCond '_Corb.mat dGLM dDec rois'], stripext(roiName)))

