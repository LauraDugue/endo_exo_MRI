% firstPlotROI_by_ROI.m
%
%      usage: firstPlotROI_by_ROI(ehdr, ehdrste, roiName)
%         by: eli & laura
%       date: 01/17/15
%    purpose: 

function firstPlotROI_by_ROI(ehdr, ehdrste, roiName, cond, obs)
% INFO

% VALID: 1, 3, 5 and 7
% INVALID: 2, 4, 6 and 8

% Valid-Pre-Left
% Invalid-Pre-Left
% Valid-Post-Left
% Invalid-Post-Left
% Valid-Pre-Right
% Invalid-Pre-Right
% Valid-Post-Right
% Invalid-Post-Right
% CueOnly-Left
% CueOnly-Right
% Blank
% Blink

%% Valid vs. Invalid
% set boudaries
yMax = ceil(10*(max(ehdr(1:8)+max(ehdrste(1:8)))))/10;
yMin = min(0, floor(10*(min(ehdr(1:8))-max(ehdrste(1:8))))/10);

% create a new figure
smartfig('Valid-Invalid'); clf;
% title  for the figure based on the ROI
suptitle(sprintf([cond ' (%s)'], fixBadChars(roiName, {'_',' '})));

subplot(1,2,1)
cla
bar([mean(ehdr([1 5])) mean(ehdr([2 6]))], 'facecolor', 'k');
hold on
errorbar([mean(ehdr([1 5])) mean(ehdr([2 6]))], [sqrt(ehdrste(1).^2 + ehdrste(5).^2)...
    sqrt(ehdrste(2).^2 + ehdrste(6).^2)], 'ko');

xaxis([0 3]);
yaxis([yMin yMax]);
axis square;box off;
set(gca,'xTickLabel',{'Valid' 'Invalid'},'FontSize',14);
ylabel('fMRI resp (% chg img intensity)');
title('Pre-cueing')

subplot(1,2,2)
cla
bar([mean(ehdr([3 7])) mean(ehdr([4 8]))], 'facecolor', 'k');
hold on
errorbar([mean(ehdr([3 7])) mean(ehdr([4 8]))], [sqrt(ehdrste(3).^2 + ehdrste(7).^2)...
    sqrt(ehdrste(4).^2 + ehdrste(8).^2)], 'ko');

xaxis([0 3]);
yaxis([yMin yMax]);
axis square;box off;
set(gca,'xTickLabel',{'Valid' 'Invalid'},'FontSize',14);
ylabel('fMRI resp (% chg img intensity)');
title('Post-cueing')

print('-djpeg','-r500',[obs '_' cond '_ValidInvalid_' roiName]);
end