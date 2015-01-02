% endoexoCombineResps_TPJ.m
%
%      usage: endoexoCombineResps_TPJ(analL, analR)
%         by: eli merriam + laura dugue
%       date: 06/25/14
%    purpose: combine estimates from 
%
function retval = endoexoCombineResps_TPJ(anal1, attCond, obs, CI, baseRemove, varargin)

% check arguments
if ~any(nargin == [5])
  help endoexoCombineResps
  return
end

% get the input arguemnts
getArgs(varargin, [], 'verbose=0');
if ieNotDefined('analdir'); analdir = ['Anal/' attCond];end

a = load(fullfile(analdir,anal1));

if strcmp(CI,'all') && baseRemove == 0
    idx = 0;
elseif strcmp(CI,'all') && baseRemove == 1
    idx = 0;
    a.dDec = a.dDecb;
    a.dGLM = a.dGLMb;
elseif strcmp(CI,'correct') && baseRemove == 0
    a.dDec = a.dDecCI;
    a.dGLM = a.dGLMCI;
    idx = 0;
elseif strcmp(CI,'correct') && baseRemove == 1
    a.dDec = a.dDecCIb;
    a.dGLM = a.dGLMCIb;
    idx = 0;
elseif strcmp(CI,'incorrect') && baseRemove == 0
    a.dDec = a.dDecCI;
    a.dGLM = a.dGLMCI;
    idx = 11;
elseif strcmp(CI,'incorrect') && baseRemove == 1
    a.dDec = a.dDecCIb;
    a.dGLM = a.dGLMCIb;
    idx = 11;
end

% concat and  average ipsilateral responses
ehdrI = cat(3, a.dDec.ehdr(1+idx:4+idx,:), a.dDec.ehdr(5+idx:8+idx,:));
ehdrI = mean(ehdrI, 3);

ehdrsteI = cat(3, a.dDec.ehdrste(1+idx:4+idx,:), a.dDec.ehdrste(5+idx:8+idx,:));
ehdrsteI = sqrt(sum(ehdrsteI.^2,3))/2;

glmehdrI = cat(3, a.dGLM.ehdr(1+idx:4+idx,:), a.dGLM.ehdr(5+idx:8+idx,:));
glmehdrI = mean(glmehdrI, 3);

glmehdrsteI = cat(3, a.dGLM.ehdrste(1+idx:4+idx,:), a.dGLM.ehdrste(5+idx:8+idx,:));
glmehdrsteI = sqrt(sum(glmehdrsteI.^2,3))/2;

% plot them

% create a new figure
h = smartfig('tSeriesPlot'); clf;

if strcmp(CI,'all') && baseRemove == 0
    suptitle(sprintf(['vTPJ: ' attCond ' (all trials)']));
elseif strcmp(CI,'all') && baseRemove == 1
    suptitle(sprintf(['vTPJ: ' attCond ' (all trials - baseline removed)']));
elseif strcmp(CI,'correct') && baseRemove == 0
    suptitle(sprintf(['vTPJ: ' attCond ' (correct trials)']));
elseif strcmp(CI,'correct') && baseRemove == 1
    suptitle(sprintf(['vTPJ: ' attCond ' (correct trials - baseline removed)']));
elseif strcmp(CI,'incorrect') && baseRemove == 0
    suptitle(sprintf(['vTPJ: ' attCond ' (incorrect trials)']));
elseif strcmp(CI,'incorrect') && baseRemove == 1
    suptitle(sprintf(['vTPJ: ' attCond ' (incorrect trials - baseline removed)']));
end

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

if strcmp(CI,'all') && baseRemove == 0
    namefig=sprintf(['/Local/Users/purpadmin/Laura/MRI/Data/' obs '/' obs 'Merge/' obs '_vTPJ_' attCond '_all']);
elseif strcmp(CI,'all') && baseRemove == 1
    namefig=sprintf(['/Local/Users/purpadmin/Laura/MRI/Data/' obs '/' obs 'Merge/' obs '_vTPJ_' attCond '_all_baseRemoved']);
elseif strcmp(CI,'correct') && baseRemove == 0
    namefig=sprintf(['/Local/Users/purpadmin/Laura/MRI/Data/' obs '/' obs 'Merge/' obs '_vTPJ_' attCond '_correct']);
elseif strcmp(CI,'correct') && baseRemove == 1
    namefig=sprintf(['/Local/Users/purpadmin/Laura/MRI/Data/' obs '/' obs 'Merge/' obs '_vTPJ_' attCond '_correct_baseRemoved']);
elseif strcmp(CI,'incorrect') && baseRemove == 0
    namefig=sprintf(['/Local/Users/purpadmin/Laura/MRI/Data/' obs '/' obs 'Merge/' obs '_vTPJ_' attCond '_incorrect']);
elseif strcmp(CI,'incorrect') && baseRemove == 1
    namefig=sprintf(['/Local/Users/purpadmin/Laura/MRI/Data/' obs '/' obs 'Merge/' obs '_vTPJ_' attCond '_incorrect_baseRemoved']);
end

print ('-djpeg', '-r500',namefig);

