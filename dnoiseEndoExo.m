% dnoiseEndoExo.m
%
%      usage: dnoiseEndoExo(v, roiName, varargin)
%         by: eli & laura
%       date: 01/17/15
%    purpose: get ehdr and ehdrste for each roi
%
function [v,ehdr,ehdrste] = dnoiseEndoExo(v, roiName, groupNum, varargin)

% check arguments
if ~any(nargin == [2:10])
  help dnoiseEndoExo
  return
end

% get the input arguemnts
getArgs(varargin, [], 'verbose=0');
if ieNotDefined('scanNum'); scanNum = 1;end
if ieNotDefined('groupNum'); groupNum = 'w-endo';end
if ieNotDefined('locThresh'); locThresh = 0.3; end
if ieNotDefined('locGroup'); locGroup = 'Averages'; end
if ieNotDefined('locScan'); locScan = 1; end

% load the beta weights
rois = loadROIdnoise(v, roiName, scanNum, groupNum);

% load the localizer corAnal Roi-by-Roi
localizer = loadROIcoranalMatching(v, roiName, locScan, locGroup, scanNum, groupNum);
for iRoi = 1:length(rois)
    goodVox{iRoi} = localizer{iRoi}.co > locThresh & localizer{iRoi}.ph < pi & ~isnan(mean(rois{iRoi}.ehdr,2));
end

% average across voxels in each ROI
for iRoi = 1:length(rois)
    ehdr{iRoi} = mean(rois{iRoi}.ehdr(goodVox{iRoi},:));
    ehdrste{iRoi} = mean(rois{iRoi}.ehdrste(goodVox{iRoi},:));
end

end


