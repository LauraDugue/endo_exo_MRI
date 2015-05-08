% visualPlotROI_by_ROI.m
%
%      usage: visualPlotROI_by_ROI(ehdr, ehdrste, roiName)
%         by: eli & laura
%       date: 01/17/15
%    purpose: 

function visualPlotROI_by_ROI(ehdr, ehdrste, roiName, cond, obs)
% INFO
% Cue-Left-Pre
% Cue-Left-Post
% Cue-Right-Pre
% Cue-Right-Post
% CueOnly-Left
% CueOnly-Right
% Blank
% Blink

% define colors for time series plots
myColors{1}=[10 55 191]/255;
myColors{2}=[191 0 0]/255;
myColors{3}=[207 219 255]/255;
myColors{4}=[255 204 204]/255;
myColors{5}=[128 128 128]/255;
myColors{6}=[128 128 128]/255;

% set boudaries
yMax = ceil(10*(max(ehdr(:)+max(ehdrste(:)))))/10;
yMin = min(0, floor(10*(min(ehdr(:))-max(ehdrste(:))))/10);

%% Plot the MRI response over time
% create a new figure
smartfig('visualCortex'); clf;
% title  for the figure based on the ROI
suptitle(sprintf('Pre vs. Post (%s)', fixBadChars(roiName, {'_',' '})));
cla

bar(ehdr(1:4), 'facecolor', 'k');
hold on
errorbar(ehdr(1:4), ehdrste(1:4), 'ko');

xaxis([0 5]);
yaxis([yMin yMax]);
axis square;box off;
set(gca,'xTickLabel',{'L-Pre' 'L-Post' 'R-Pre' 'R-Post'},'FontSize',14);
ylabel('fMRI resp (% chg img intensity)');

print('-djpeg','-r500',[obs '_' cond '_PrePost_' roiName]);

%% Remaining trials
% Data to plot
toplot = ehdr(5:8);
toplotste = ehdrste(5:8);
% create a new figure
smartfig('RemainingTrials'); clf;
% title  for the figure based on the ROI
suptitle(sprintf('Pre vs. Post - Extra trial-types (%s)', fixBadChars(roiName, {'_',' '})));
cla
bar(toplot, 'facecolor', 'k');
hold on
errorbar(toplot, toplotste, 'ko');

xaxis([0 5]);
yaxis([yMin yMax]);
axis square;box off;
set(gca,'xTick',1:4,'xTickLabel',{'C-OnlyL' 'C-OnlyR' 'Blank' 'Blink'},'FontSize',14)
ylabel('fMRI resp (% chg img intensity)');

print('-djpeg','-r500',[obs '_' cond '_PrePostExtra_' roiName]);
end
