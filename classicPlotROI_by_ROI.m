% classicPlotROI_by_ROI.m
%
%      usage: classicPlotROI_by_ROI(v, roiName, varargin)
%         by: eli & laura
%       date: 01/17/15
%    purpose: 

function classicPlotROI_by_ROI(ehdr, ehdrste, roiName)

% define colors for time series plots
myColors{1}=[10 55 191]/255;
myColors{2}=[191 0 0]/255;
myColors{3}=[207 219 255]/255;
myColors{4}=[255 204 204]/255;
myColors{5}=[128 128 128]/255;
myColors{6}=[128 128 128]/255;
myColors{7}=[0 0 0]/255;

% set boudaries
yMax = ceil(10*(max(ehdr([1:8 12:19],:)+max(ehdrste([1:8 12:19],:)))))/10;
yMin = min(0, floor(10*(min(ehdr([1:8 12:19],:))-max(ehdrste([1:8 12:19],:))))/10);

%% Plot the MRI response over time
% create a new figure
smartfig('tSeriesPlot'); clf;
% title  for the figure based on the ROI
suptitle(sprintf('Classic analysis (%s)', fixBadChars(roiName, {'_',' '})));

subplot(1,3,1); 
cla
for iBar=1:4
    bar([iBar iBar+6], ehdr([iBar iBar+4],1), 0.1, 'facecolor', myColors{iBar});
    hold on
    errorbar([iBar iBar+6], ehdr([iBar iBar+4],1), ehdrste([iBar iBar+4], 1), 'o', 'color', myColors{iBar});
end
xaxis([0 11]);
yaxis([yMin yMax]);
axis square;
ylabel('fMRI resp (% chg img intensity)');
drawPublishAxis('xTickLabel',{'LVF' 'RVF'},'titleStr', 'Correct trials') 

subplot(1,3,2); 
cla
for iBar=1:4
    bar([iBar iBar+6], ehdr([iBar+11 iBar+4+11],1), 0.1, 'facecolor', myColors{iBar});
    hold on
    errorbar([iBar iBar+6], ehdr([iBar+11 iBar+4+11],1), ehdrste([iBar+11 iBar+11+4], 1), 'o', 'color', myColors{iBar});
end
xaxis([0 11]);
yaxis([yMin yMax]);
axis square;
ylabel('fMRI resp (% chg img intensity)');
drawPublishAxis('xTickLabel',{'LVF' 'RVF'},'titleStr', 'Incorrect trials') 

subplot(1,3,3); 
cla
for iBar=9:11
    bar([iBar-8 iBar-8+5], ehdr([iBar iBar+3],1), 0.15, 'facecolor', myColors{5});
    hold on
    errorbar([iBar-8 iBar-8+5], ehdr([iBar iBar+3],1), ehdrste([iBar iBar+3], 1), 'o', 'color', myColors{5});
end
xaxis([0 9]);
yaxis([yMin yMax])
axis square;
ylabel('fMRI resp (% chg img intensity)');
drawPublishAxis('xTickLabel',{'Correct','Incorrect'},'titleStr', 'Cue-only LEFT/RIGHT and Blank trials')


end
