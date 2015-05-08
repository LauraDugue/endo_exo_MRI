% firstVisualPlotROI_by_ROI.m
%
%      usage: firstVisualPlotROI_by_ROI(ehdr, ehdrste, roiName)
%         by: eli & laura
%       date: 01/17/15
%    purpose: 

function firstVisualPlotROI_by_ROI(ehdr, ehdrste, roiName, cond, obs)
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

% print('-djpeg','-r500',[obs '_' cond '_ValidInvalid_' roiName]);

%% Separating left and right visual field

%%% LEFT
% create a new figure
smartfig('Valid-Invalid (left Hemi)'); clf;
% title  for the figure based on the ROI
suptitle(sprintf(['(left Hemi) ' cond ' (%s)'], fixBadChars(roiName, {'_',' '})));

subplot(1,2,1)
cla
bar([ehdr(1) ehdr(2)], 'facecolor', 'k');
hold on
errorbar([ehdr(1) ehdr(2)], [ehdrste(1) ehdrste(2)], 'ko');

xaxis([0 3]);
yaxis([yMin yMax]);
axis square;box off;
set(gca,'xTickLabel',{'Valid' 'Invalid'},'FontSize',14);
ylabel('fMRI resp (% chg img intensity)');
title('Pre-cueing')

subplot(1,2,2)
cla
bar([ehdr(3) ehdr(4)], 'facecolor', 'k');
hold on
errorbar([ehdr(3) ehdr(4)], [ehdrste(3) ehdrste(4)], 'ko');

xaxis([0 3]);
yaxis([yMin yMax]);
axis square;box off;
set(gca,'xTickLabel',{'Valid' 'Invalid'},'FontSize',14);
ylabel('fMRI resp (% chg img intensity)');
title('Post-cueing')

print('-djpeg','-r500',['/Local/Users/purpadmin/Desktop/Laura/' obs '_' cond '_ValidInvalid_' roiName '_LeftHemi']);

%%% RIGHT
% create a new figure
smartfig('Valid-Invalid (right Hemi)'); clf;
% title  for the figure based on the ROI
suptitle(sprintf(['(right Hemi) ' cond ' (%s)'], fixBadChars(roiName, {'_',' '})));

subplot(1,2,1)
cla
bar([ehdr(5) ehdr(6)], 'facecolor', 'k');
hold on
errorbar([ehdr(5) ehdr(6)], [ehdrste(5) ehdrste(6)], 'ko');

xaxis([0 3]);
yaxis([yMin yMax]);
axis square;box off;
set(gca,'xTickLabel',{'Valid' 'Invalid'},'FontSize',14);
ylabel('fMRI resp (% chg img intensity)');
title('Pre-cueing')

subplot(1,2,2)
cla
bar([ehdr(7) ehdr(8)], 'facecolor', 'k');
hold on
errorbar([ehdr(7) ehdr(8)], [ehdrste(7) ehdrste(8)], 'ko');

xaxis([0 3]);
yaxis([yMin yMax]);
axis square;box off;
set(gca,'xTickLabel',{'Valid' 'Invalid'},'FontSize',14);
ylabel('fMRI resp (% chg img intensity)');
title('Post-cueing')

print('-djpeg','-r500',['/Local/Users/purpadmin/Desktop/Laura/' obs '_' cond '_ValidInvalid_' roiName '_RightHemi']);
end