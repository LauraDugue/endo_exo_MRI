% corbettaPlotROI_by_ROI.m
%
%      usage: corbettaPlotROI_by_ROI(v, roiName, varargin)
%         by: eli & laura
%       date: 01/17/15
%    purpose: 

function corbettaPlotROI_by_ROI(ehdr, ehdrste, roiName)

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
suptitle(sprintf('%s', fixBadChars(roiName, {'_',' '})));

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
drawPublishAxis('xTickLabel',{'LVF' 'RVF'},'titleStr', 'Correct trials') 

subplot(1,3,2); 
cla
for iBar=1:4
    bar([iBar iBar+6], ehdr([iBar+10 iBar+4+10],1), 0.1, 'facecolor', myColors{iBar});
    hold on
    errorbar([iBar iBar+6], ehdr([iBar+10 iBar+4+10],1), ehdrste([iBar+10 iBar+10+4], 1), 'o', 'color', myColors{iBar});
end
xaxis([0 10]);
yaxis([yMin yMax]);
axis square;
drawPublishAxis('xTickLabel',{'LVF' 'RVF'},'titleStr', 'Incorrect trials') 

subplot(1,3,3); 
cla
for iBar=17:19
    bar(iBar-16, dGLM.ehdr(iBar),  0.4, 'facecolor', myColors{iBar-16})
    hold on
    errorbar(iBar-16 , dGLM.ehdr(iBar), dGLM.ehdrste(iBar), 'o', 'color', myColors{iBar-16});
end
yaxis([yMin yMax])
axis square;
box off 
drawPublishAxis('yTick', [yMin 0 yMax],'xTick', [1:3], 'xTickLabel', {'CueL' 'CueR' 'Blinks'});

end