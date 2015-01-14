% dnoiseEndoExo.m
%
%      usage: dnoiseEndoExo(v, roiName, varargin)
%         by: eli & laura
%       date: 01/17/15
%    purpose: 
%
function v = dnoiseEndoExo(v, roiName, groupNum)

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

% load the localizer corAnal
localizer = loadROIcoranalMatching(v, roiName, locScan, locGroup, scanNum, groupNum);
goodVox = localizer{1}.co > locThresh & localizer{1}.ph < pi & ~isnan(mean(rois{1}.ehdr,2));

% average across voxels in each ROI
for iRoi = 1:length(rois)
    ehdr{iRoi} = mean(rois{iRoi}.ehdr(goodVox,:));
end





