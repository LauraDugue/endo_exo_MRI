% endoexoCombineResps.m
%
%      usage: endoexoCombineResps(analL, analR)
%         by: eli merriam
%       date: 06/25/14
%    purpose: combine estimates from 
%
function retval = endoexoCombineResps_Laura(anal1, anal2, attCond, obs, basRemov, varargin)

% check arguments
if ~any(nargin == [5])
  help endoexoCombineResps
  return
end

% get the input arguemnts
getArgs(varargin, [], 'verbose=0');
if ieNotDefined('analdir'); analdir = ['Anal/' attCond];end

aL = load(fullfile(analdir,anal1));

aR = load(fullfile(analdir, anal2));

if basRemov
    aL.dDec = aL.dDec2;
    aL.dGLM = aL.dGLM2;
end

% concat and  average ipsilateral responses
% for left ROI, the first four response are ipsilateral
% for right ROI, the second set of four respones are ipsilateral
ehdrI = cat(3, aL.dDec.ehdr(1:4,:), aR.dDec.ehdr(5:8,:));
ehdrI = mean(ehdrI, 3);

ehdrsteI = cat(3, aL.dDec.ehdrste(1:4,:), aR.dDec.ehdrste(5:8,:));
ehdrsteI = sqrt(sum(ehdrsteI.^2,3))/2;

glmehdrI = cat(3, aL.dGLM.ehdr(1:4,:), aR.dGLM.ehdr(5:8,:));
glmehdrI = mean(glmehdrI, 3);

glmehdrsteI = cat(3, aL.dGLM.ehdrste(1:4,:), aR.dGLM.ehdrste(5:8,:));
glmehdrsteI = sqrt(sum(glmehdrsteI.^2,3))/2;

baseline_ehdr = mean(ehdrI,1);
baseline_ehdrste = sqrt(sum(ehdrsteI.^2))/2;

baseline_glmehdr = mean(glmehdrI,1);
baseline_glmehdrste = sqrt(sum(glmehdrsteI.^2))/2;

% do the contralateral hemifield
ehdrC = cat(3, aL.dDec.ehdr(5:8,:), aR.dDec.ehdr(1:4,:));
ehdrC = mean(ehdrC, 3);
ehdrC = cat(1, ehdrC, baseline_ehdr);

ehdrsteC = cat(3, aL.dDec.ehdrste(5:8,:), aR.dDec.ehdrste(1:4,:));
ehdrsteC = sqrt(sum(ehdrsteC.^2,3))/2;
ehdrsteC = cat(1, ehdrsteC, baseline_ehdrste);

glmehdrC = cat(3, aL.dGLM.ehdr(5:8,:), aR.dGLM.ehdr(1:4,:));
glmehdrC = mean(glmehdrC, 3);
glmehdrC = cat(1, glmehdrC, baseline_glmehdr);

glmehdrsteC = cat(3, aL.dGLM.ehdrste(5:8,:), aR.dGLM.ehdrste(1:4,:));
glmehdrsteC = sqrt(sum(glmehdrsteC.^2,3))/2;
glmehdrsteC = cat(1, glmehdrsteC, baseline_glmehdrste);

% plot them

% create a new figure
h = smartfig('tSeriesPlot', 'reuse'); clf;
% title  for the figure based on the ROI
titlestr = fixBadChars(anal1, {'anal_l_',''});
titlestr = fixBadChars(titlestr, {'_restricted.mat', ''});
suptitle(sprintf('ROI: %s', titlestr));

% set the standard colors
myColors{1}=[10 55 191]/255;
myColors{2}=[191 0 0]/255;
myColors{3}=[207 219 255]/255;
myColors{4}=[255 204 204]/255;
myColors{5}=[0 0 0];

% length and number of the responses
nhdr = 5;
hdrlen = 17;

% plot contralateral responses first
subplot(1,2,1); cla
yMax = ceil(10*(max([ehdrC(:);ehdrI(:)]) + max([ehdrsteC(:);ehdrsteI(:)]) ))/10;
yMin = floor(10*(min([ehdrC(:);ehdrI(:)]) - max([ehdrsteC(:);ehdrsteI(:)]) ))/10;

for i=1:nhdr
  myerrorbar(aL.dDec.time, ehdrC(i,:), 'yError', ehdrsteC(i,:), 'MarkerFaceColor', myColors{i});
end
ylabel('fMRI resp (% chg img intensity)');
xlabel('Time (seconds)');
axis square
ylim([yMin yMax]);
drawPublishAxis('yTick',[yMin 0 yMax], 'xTick',[0 25]);

% h_legend = mylegend({'Pre Valid', 'Pre Invalid', 'Post Valid', 'Post Invalid'}, myColors);
% set(h_legend, 'box', 'off')

%% Betas from GLM analysis
% get the 'd' structure, loading analysis of needed

% yMax = ceil(10*(max([glmehdrC; glmehdrI]+max([glmehdrsteC; glmehdrsteI]))))/10;
% yMin = floor(10*(min([glmehdrC; glmehdrI]-min([glmehdrsteC; glmehdrsteI]))))/10;
% yMin = min(0, yMin);

subplot(1,2,2); cla

groupLabs = {'Pre Valid', 'Pre Invalid', 'Post Valid', 'Post Invalid', 'Distractor'};
mybar(glmehdrC, 'yError', glmehdrsteC, 'dispValues', 0,'yLabelText',...
    'fMRI response (% change image intensity)','yAxisMin', yMin, 'yAxisMax',yMax, 'groupColors',myColors);

axis square;
hline(0)
drawPublishAxis('yTick', [yMin yMax]);

if basRemov
    namefig=sprintf(['/Volumes/purpadmin/Laura/MRI/Data/' obs '/' obs 'Merge/Images_Comb/' attCond '/removed/' anal1 '_' anal2 '_restricted']);
else
    namefig=sprintf(['/Volumes/purpadmin/Laura/MRI/Data/' obs '/' obs 'Merge/Images_Comb/' attCond '/original/' anal1 '_' anal2 '_original']);
end
print ('-djpeg', '-r500',namefig);

%% Cue only and Blank trials analysis

% % create a new figure
% h = smartfig('tSeriesPlot', 'reuse'); clf;
% % title  for the figure based on the ROI
% titlestr = fixBadChars(anal1, {'anal_l_',''});
% titlestr = fixBadChars(titlestr, {'_restricted.mat', ''});
% titlestr = fixBadChars(titlestr, {['_' attCond '.mat'], attCond});
% suptitle(sprintf('Cue only and Blank trials (ROI: %s)', titlestr));
% 
% % plot the responses for target in the LVF
% subplot(1,2,1); cla
% yMax = ceil(10*(max(aL.dDec.ehdr(:)+max(aL.dDec.ehdrste(:)))))/10;
% yMin = floor(10*(min(aL.dDec.ehdr(:)-max(aL.dDec.ehdrste(:)))))/10;
% myerrorbar(aL.dDec.time, aL.dDec.ehdr(9,:), 'yError', aL.dDec.ehdrste(9,:), 'MarkerFaceColor', myColors{3});
% hold on
% myerrorbar(aL.dDec.time, aL.dDec.ehdr(10,:), 'yError', aL.dDec.ehdrste(10,:), 'MarkerFaceColor', myColors{1});
% myerrorbar(aL.dDec.time, aL.dDec.ehdr(11,:), 'yError', aL.dDec.ehdrste(11,:), 'MarkerFaceColor', [0 0 0]);
% 
% ylabel('fMRI resp (% chg img intensity)');
% xlabel('Time (seconds)');
% axis square
% ylim([yMin yMax]);
% drawPublishAxis('yTick',[yMin 0 yMax], 'xTick',[0 25],'titleStr', 'Left ROI');
% 
% % plot the respones for target in the RVF
% subplot(1,2,2); cla
% yMax = ceil(10*(max(aR.dDec.ehdr(:)+max(aR.dDec.ehdrste(:)))))/10;
% yMin = floor(10*(min(aR.dDec.ehdr(:)-max(aR.dDec.ehdrste(:)))))/10;
% myerrorbar(aR.dDec.time, aR.dDec.ehdr(9,:), 'yError', aR.dDec.ehdrste(9,:), 'MarkerFaceColor', myColors{1});
% hold on
% myerrorbar(aR.dDec.time, aR.dDec.ehdr(10,:), 'yError', aR.dDec.ehdrste(10,:), 'MarkerFaceColor', myColors{3});
% myerrorbar(aR.dDec.time, aR.dDec.ehdr(11,:), 'yError', aR.dDec.ehdrste(11,:), 'MarkerFaceColor', [0 0 0]);
% 
% ylabel('fMRI resp (% chg img intensity)');
% xlabel('Time (seconds)');
% axis square
% ylim([yMin yMax]);
% drawPublishAxis('yTick',[yMin 0 yMax], 'xTick',[0 25],'titleStr', 'Right ROI');
% 
% namefig=sprintf(['/Local/Users/purpadmin/Laura/MRI/Data/' obs '/' obs 'Merge/Images_Comb/' attCond '/CueOnly_Blank_' anal1 '_' anal2]);
% print ('-djpeg', '-r500',namefig);

