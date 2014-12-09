% endoexoCombineResps_TPJ.m
%
%      usage: endoexoCombineResps_TPJ(analL, analR)
%         by: eli merriam + laura dugue
%       date: 06/25/14
%    purpose: combine estimates from 
%
function retval = endoexoCombineResps_TPJ(anal1, attCond, obs, Correct, varargin)

% check arguments
if ~any(nargin == [4])
  help endoexoCombineResps
  return
end

% get the input arguemnts
getArgs(varargin, [], 'verbose=0');
if ieNotDefined('analdir'); analdir = ['Anal/' attCond];end

a = load(fullfile(analdir,anal1));

if Correct
    a.dDec = a.dDecCI;
    a.dGLM = a.dGLMCI;
end

% concat and  average ipsilateral responses
% for left ROI, the first four response are ipsilateral
% for right ROI, the second set of four respones are ipsilateral
ehdrI = cat(3, a.dDec.ehdr(1:4,:), a.dDec.ehdr(5:8,:));
ehdrI = mean(ehdrI, 3);

ehdrsteI = cat(3, a.dDec.ehdrste(1:4,:), a.dDec.ehdrste(5:8,:));
ehdrsteI = sqrt(sum(ehdrsteI.^2,3))/2;

glmehdrI = cat(3, a.dGLM.ehdr(1:4,:), a.dGLM.ehdr(5:8,:));
glmehdrI = mean(glmehdrI, 3);

glmehdrsteI = cat(3, a.dGLM.ehdrste(1:4,:), a.dGLM.ehdrste(5:8,:));
glmehdrsteI = sqrt(sum(glmehdrsteI.^2,3))/2;

% plot them

% create a new figure
h = smartfig('tSeriesPlot'); clf;
suptitle(sprintf(['vTPJ: ' attCond]));

% set the standard colors
myColors{1}=[10 55 191]/255;
myColors{2}=[191 0 0]/255;
myColors{3}=[207 219 255]/255;
myColors{4}=[255 204 204]/255;

% length and number of the responses
nhdr = 4;
hdrlen = 17;

% plot contralateral responses first
subplot(1,2,1); cla
yMaxhrf = ceil(10*(max(ehdrI(:)) + max(ehdrsteI(:)) ))/10;
yMinhrf = floor(10*(min(ehdrI(:)) - max(ehdrsteI(:)) ))/10;

yMaxglm = ceil(10*(max(glmehdrI+max(glmehdrsteI))))/10;
yMinglm = floor(10*(min(glmehdrI-min(glmehdrsteI))))/10;

yMax = max([yMaxglm yMaxhrf]);
yMin = min([yMinglm yMinhrf]);

for i=1:nhdr
  myerrorbar(a.dDec.time, ehdrI(i,:), 'yError', ehdrsteI(i,:), 'MarkerFaceColor', myColors{i});
end
ylabel('fMRI resp (% chg img intensity)');
xlabel('Time (seconds)');
axis square
ylim([yMin yMax]);
drawPublishAxis('yTick',[yMin 0 yMax], 'xTick',[0 25]);

%% Betas from GLM analysis
% get the 'd' structure, loading analysis of needed

subplot(1,2,2); cla

groupLabs = {'Pre Valid', 'Pre Invalid', 'Post Valid', 'Post Invalid'};
mybar(glmehdrI, 'yError', glmehdrsteI, 'dispValues', 0,'yLabelText',...
    'fMRI response (% change image intensity)','yAxisMin', yMin, 'yAxisMax',yMax, 'groupColors',myColors);

axis square;
hline(0);
drawPublishAxis('yTick', [yMin yMax]);

namefig=sprintf(['/Local/Users/purpadmin/Laura/MRI/Data/' obs '/' obs 'Merge/vTPJ_' attCond]);
print ('-djpeg', '-r500',namefig);
