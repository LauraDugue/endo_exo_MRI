% corbettaPlotROI_by_ROI.m
%
%      usage: corbettaPlotROI_by_ROI(ehdr, ehdrste, roiName)
%         by: eli & laura
%       date: 01/17/15
%    purpose: 

function TPJPlotROI_by_ROI(ehdr, ehdrste, roiName, cond, obs)
% INFO

% CueOnly-Left
% CueOnly-Right
% Blank
% RespCue-Valid-correct
% RespCue-Invalid-correct
% RespCue-Valid-incorrect
% RespCue-Invalid-incorrect
% Blink

% define colors for time series plots
myColors{1}=[10 55 191]/255;
myColors{2}=[191 0 0]/255;
myColors{3}=[207 219 255]/255;
myColors{4}=[255 204 204]/255;
myColors{5}=[128 128 128]/255;
myColors{6}=[128 128 128]/255;
myColors{7}=[0 0 0]/255;

% set boudaries
yMax = ceil(10*(max(ehdr(:)+max(ehdrste(:)))))/10;
yMin = min(0, floor(10*(min(ehdr(:))-max(ehdrste(:))))/10);

%% Valid vs. Invalid
% set boudaries
yMax = ceil(10*(max(ehdr(4:5)+max(ehdrste(4:5)))))/10;
yMin = min(0, floor(10*(min(ehdr(4:5))-max(ehdrste(4:5))))/10);

% create a new figure
smartfig('Valid-Invalid'); clf;
% title  for the figure based on the ROI
suptitle(sprintf('Valid vs. Invalid - correct trials (%s)', fixBadChars(roiName, {'_',' '})));

cla
bar(ehdr(4:5), 'facecolor', 'k');
hold on
errorbar(ehdr(4:5), ehdrste(4:5), 'ko');

xaxis([0 3]);
yaxis([yMin yMax]);
axis square;box off;
set(gca,'xTickLabel',{'Valid' 'Invalid'},'FontSize',14);
ylabel('fMRI resp (% chg img intensity)');

print('-djpeg','-r500',[obs '_' cond '_ValidInvalid_' roiName]);

%% Remaining trials
% set boudaries
yMax = ceil(10*(max(ehdr([1:3 8])+max(ehdrste([1:3 8])))))/10;
yMin = min(0, floor(10*(min(ehdr([1:3 8]))-max(ehdrste([1:3 8]))))/10);
% create a new figure
toPlot = ehdr([1:3 8]);
toPlotste = ehdrste([1:3 8]);

smartfig('RemainingTrials'); clf;
% title  for the figure based on the ROI
suptitle(sprintf('Valid vs. Invalid - Extra trial-types (%s)', fixBadChars(roiName, {'_',' '})));
cla
for iBar=1:4
    bar(iBar, toPlot(iBar),.8, 'facecolor', 'k')
    hold on
    errorbar(iBar, toPlot(iBar), toPlotste(iBar), 'ko');
end
xaxis([0 5]);
yaxis([yMin yMax])
axis square;box off;
set(gca,'xTick',1:4,'xTickLabel',{'C-OnlyL' 'C-OnlyR' 'Blank' 'Blink'},'FontSize',14)
ylabel('fMRI resp (% chg img intensity)');

print('-djpeg','-r500',[obs '_' cond '_ValidInvalidExtra_' roiName]);

end