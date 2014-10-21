% endoexoRvL.m
%
%      usage: endoexoRvL(v, roiName, varargin)
%         by: eli & laura
%       date: 06/17/14
%    purpose: 
%
function v = endoexoRvL(v, roiName, varargin)

% check arguments
if ~any(nargin == [2:10])
  help endoexoRvL
  return
end

% get the input arguemnts
getArgs(varargin, [], 'verbose=0');
if ieNotDefined('scanNum'); scanNum = 1;end
if ieNotDefined('groupNum'); groupNum = 'Concatenation';end
if ieNotDefined('locThresh'); locThresh = 0.4; end
if ieNotDefined('locGroup'); locGroup = 'Averages'; end
if ieNotDefined('locScan'); locScan = 1; end

v = viewSet(v, 'curGroup', groupNum);
groupName = viewGet(v, 'groupName');


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

keyboard
% load analyses if needed
if viewGet(v, 'nanalyses')==0
  disp(sprintf('Loading both analyses'))
  v = loadAnalysis(v, 'erAnal/erAnal_exo.mat');
  v = loadAnalysis(v, 'glmAnalStats/GLM_exo.mat');
end
if viewGet(v, 'nanalyses')==1
  disp(sprintf('Only %s is loaded, please load both analyses', viewGet(v, 'analysistype',1)))
  return;
end
if viewGet(v, 'nanalyses')==2
  disp(sprintf('Both %s and %s are loaded', viewGet(v, 'analysistype',1), viewGet(v, 'analysistype',2)))
end
  

%% Run the event related analysis
% get the 'd' structure, loading analysis of needed
% ATTN do some error checking that the first analysis is erAnal
dDec = viewGet(v, 'd', scanNum, 1);

% compute the betas
nhdr = size(dDec.ehdr,4);
hdrlen = size(dDec.ehdr, 5);
dDec = getr2timecourse(tSeries, nhdr, hdrlen, dDec.scm, dDec.tr); 

myColors{1}=[10 55 191]/255;
myColors{2}=[191 0 0]/255;
myColors{3}=[207 219 255]/255;
myColors{4}=[255 204 204]/255;

%% Plot the MRI response over time

% create a new figure
smartfig('tSeriesPlot', 'reuse'); clf;
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
drawPublishAxis('yTick',[yMin 0 yMax], 'xTick',[0 25], 'titleStr', 'Target in RVF');
h_legend = mylegend({'Pre Valid', 'Pre Invalid', 'Post Valid', 'Post Invalid'}, myColors);
set(h_legend, 'box', 'off')

%% Betas from GLM analysis
% get the 'd' structure, loading analysis of needed
% ATTN do some error checking to make sure that the second analysis is GLM anal
dGLM = viewGet(v, 'd', scanNum, 2);

% compute the betas
nhdr = size(dGLM.ehdr,4);
hdrlen = size(dGLM.ehdr, 5);
dGLM = getr2timecourse(tSeries, nhdr, hdrlen, dGLM.scm, dGLM.tr); 
yMax = ceil(10*(max(dGLM.ehdr(:)+max(dGLM.ehdrste(:)))))/10;
yMin = min(0, floor(10*(min(dGLM.ehdr(:)-max(dGLM.ehdrste(:)))))/10);

subplot(1,3,3); 
cla
for iBar=1:4
    bar([iBar iBar+6],      dGLM.ehdr([iBar iBar+3],1), 0.1, 'facecolor', myColors{iBar});
    hold on
    errorbar([iBar iBar+6], dGLM.ehdr([iBar iBar+3],1), dGLM.ehdrste([iBar iBar+3],1), 'o', 'color', myColors{iBar});
end
xaxis([0 11]);
axis square;
drawPublishAxis('yTick', [0 yMax/2 yMax], 'whichAxis', 'vertical');

% mybar(reshape(dGLM.ehdr(1:8,1),4,2)', 'yError', reshape(dGLM.ehdrste(1:8,1),4,2)', 'dispValues', 0, 'groupLabels', {'Target in LVF', 'Target in RVF'},...
% 'yLabelText', 'fMRI response (% change image intensity)','yAxisMin', yMin, 'yAxisMax',yMax, 'withinGroupColors',myColors)
% , 'dispValues', 0, 'groupLabels', {'Target in LVF', 'Target in RVF'},...
% 'yLabelText', 'fMRI response (% change image intensity)','yAxisMin', yMin, 'yAxisMax',yMax, 'withinGroupColors',myColors)


% save the PDF of the time courses
print_pdf(fullfile('Figures', sprintf('%s.pdf', stripext(roiName))));

if ~exist('Anal', 'dir')
  mkdir('Anal');
end
eval(sprintf('save Anal/anal_%s.mat dGLM dDec rois', stripext(roiName)))
