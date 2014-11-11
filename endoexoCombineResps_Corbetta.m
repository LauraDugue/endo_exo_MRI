% endoexoCombineResps.m
%
%      usage: endoexoCombineResps(analL, analR)
%         by: eli merriam
%       date: 06/25/14
%    purpose: combine estimates from 
%
function retval = endoexoCombineResps_Corbetta(anal1, anal2, attCond, obs, varargin)

% check arguments
if ~any(nargin == [4])
  help endoexoCombineResps_Corbetta
  return
end

% get the input arguemnts
getArgs(varargin, [], 'verbose=0');
if ieNotDefined('analdir'); analdir = ['Anal/' attCond '/Corbetta'];end

aL = load(fullfile(analdir,anal1));

aR = load(fullfile(analdir, anal2));

% concat and  average ipsilateral responses
% for left ROI, 2, 4 and 6 are ipsilateral
% for right ROI, 3, 5 and 7 are ipsilateral
ehdrI = cat(3, aL.dDec.ehdr([2 4 6],:), aR.dDec.ehdr([3 5 7],:));
ehdrI = mean(ehdrI, 3);

ehdrsteI = cat(3, aL.dDec.ehdrste([2 4 6],:), aR.dDec.ehdrste([3 5 7],:));
ehdrsteI = sqrt(sum(ehdrsteI.^2,3))/2;

bas = [aL.dDec.ehdr(1,:); aR.dDec.ehdr(1,:)];
baseline_ehdr = mean(bas,1);
basste = [aL.dDec.ehdrste(1,:); aR.dDec.ehdrste(1,:)];
basste = sqrt(sum(basste.^2,3))/2;
baseline_ehdrste = sqrt(sum(basste.^2))/2;

glmehdrI = cat(3, aL.dGLM.ehdr([2 4 6],:), aR.dGLM.ehdr([3 5 7],:));
glmehdrI = mean(glmehdrI, 3);

glmehdrsteI = cat(3, aL.dGLM.ehdrste([2 4 6],:), aR.dGLM.ehdrste([3 5 7],:));
glmehdrsteI = sqrt(sum(glmehdrsteI.^2,3))/2;

basglm = [aL.dGLM.ehdr(1,:); aR.dGLM.ehdr(1,:)];
basglm = mean(basglm, 3);
basglmste = [aL.dGLM.ehdrste(1,:); aR.dGLM.ehdrste(1,:)];
basglmste = sqrt(sum(basglmste.^2,3))/2;
baseline_glmehdr = mean(basglm,1);
baseline_glmehdrste = sqrt(sum(basglmste.^2))/2;

% do the contralateral hemifield
ehdrC = cat(3, aL.dDec.ehdr([3 5 7],:), aR.dDec.ehdr([2 4 6],:));
ehdrC = mean(ehdrC, 3);

ehdrsteC = cat(3, aL.dDec.ehdrste([3 5 7],:), aR.dDec.ehdrste([2 4 6],:));
ehdrsteC = sqrt(sum(ehdrsteC.^2,3))/2;

glmehdrC = cat(3, aL.dGLM.ehdr([3 5 7],:), aR.dGLM.ehdr([2 4 6],:));
glmehdrC = mean(glmehdrC, 3);

glmehdrsteC = cat(3, aL.dGLM.ehdrste([3 5 7],:), aR.dGLM.ehdrste([2 4 6],:));
glmehdrsteC = sqrt(sum(glmehdrsteC.^2,3))/2;


% plot them

% create a new figure
h = smartfig('tSeriesPlot', 'reuse'); clf;
% title  for the figure based on the ROI
titlestr = fixBadChars(anal1, {'anal_l_',''});
titlestr = fixBadChars(titlestr, {'_restricted.mat', ''});
suptitle(sprintf('ROI: %s', titlestr));

% set the standard colors
myColors{1}=[0 0 0];
myColors{2}=[0.5 0.5 0.5];
myColors{3}=[10 55 191]/255;
myColors{4}=[191 0 0]/255;

% length and number of the responses
nhdr = 3;
hdrlen = 17;

% plot contralateral responses first
subplot(1,2,1); cla
yMax = ceil(10*(max([ehdrC(:);ehdrI(:)]) + max([ehdrsteC(:);ehdrsteI(:)]) ))/10;
yMin = floor(10*(min([ehdrC(:);ehdrI(:)]) - max([ehdrsteC(:);ehdrsteI(:)]) ))/10;

myerrorbar(aL.dDec.time, baseline_ehdr, 'yError', baseline_ehdrste, 'MarkerFaceColor', myColors{1});
hold on;
for i=1:nhdr
  myerrorbar(aL.dDec.time, ehdrC(i,:), 'yError', ehdrsteC(i,:), 'MarkerFaceColor', myColors{i+1});
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

yMax = ceil(10*(max([glmehdrC; glmehdrI]+max([glmehdrsteC; glmehdrsteI]))))/10;
yMin = floor(10*(min([glmehdrC; glmehdrI]-min([glmehdrsteC; glmehdrsteI]))))/10;
yMin = min(0, yMin);

toplot = [baseline_glmehdr;glmehdrC];
toplotste = [baseline_glmehdrste;glmehdrsteC];

subplot(1,2,2); cla
mybar(toplot', 'yError', toplotste', 'dispValues', 0, 'groupLabels', {' '},'yLabelText',...
    'fMRI response (% change image intensity)','yAxisMin', yMin, 'yAxisMax',yMax, 'withinGroupColors',myColors);

axis square;
drawPublishAxis('yTick', [yMin yMax]);

namefig=sprintf(['/Local/Users/purpadmin/Laura/MRI/Data/' obs '/' obs 'Merge/Images_Comb/' attCond '/Corbetta/' anal1 '_' anal2]);
print ('-djpeg', '-r500',namefig);

