% loadROIcoranal.m
%
%      usage: loadROIdnoise(view, <roiname>, <scanList>, <groupNum>, matchScanNum, matchGroupNum)
%         by: eli & laura
%       date: 01/13/15
%    purpose: 
%
function rois = loadROIdnoise(view, roiname, scanList, groupNum, varagin);

rois = {};

% check arguments
if nargin < 1
  help loadROIdnoise
  return
end

% no view specified
if ieNotDefined('view')
  view = newView('Volume');
end

% get the roi directory
roidir = viewGet(view,'roidir');

% get group and scan
if ieNotDefined('groupNum')
  groupNum = viewGet(view,'currentGroup');
end
groupName = viewGet(view,'groupName',groupNum);
if ieNotDefined('scanList')
  %scanList = viewGet(view,'currentScan');
  scanList = 1;
end

% set the current group
view = viewSet(view,'currentGroup',groupNum);

% if there is no roi, ask the user to select
if ieNotDefined('roiname')
  roiname = getPathStrDialog(viewGet(view,'roiDir'),'Choose one or more ROIs','*.mat','on');
end

%make into a cell array
roiname = cellArray(roiname);

% load the analysis
view = loadAnalysis(view, 'mrDispOverlayAnal/dnoiseAnal.mat');

% extract the params
d = viewGet(view, 'd');
ehdr = d.ehdr;
ehdrste = d.ehdrste;

% load the rois in turn
for roinum = 1:length(roiname)
  % see if we have to paste roi directory on
  if isstr(roiname{roinum}) && ~isfile(sprintf('%s.mat',stripext(roiname{roinum})))
    roiname{roinum} = fullfile(roidir,stripext(roiname{roinum}));
  end
  % check for file
  if isstr(roiname{roinum}) && ~isfile(sprintf('%s.mat',stripext(roiname{roinum})))
    disp(sprintf('(loadROIdnoise) Could not find roi %s',roiname{roinum}));
    dir(fullfile(roidir,'*.mat'))
  elseif isnumeric(roiname{roinum}) && ((roiname{roinum} < 1) || (roiname{roinum} > viewGet(view,'numberOfROIs')))
    disp(sprintf('(loadROIdnoise) No ROI number %i (number of ROIs = %i)',roiname{roinum},viewGet(view,'numberOfROIs')));
  else
    % load the roi, if the name is actually a struct
    % then assume it is an roi struct. if it is a number choose
    % from a loaded roi
    if isstr(roiname{roinum})
      roi = load(roiname{roinum});
    elseif isnumeric(roiname{roinum})
      thisroi = viewGet(view,'roi',roiname{roinum});
      roi.(fixBadChars(thisroi.name)) = thisroi;
    else
      roi.(fixBadChars(roiname{roinum}.name)) = roiname{roinum};
    end
    roiFieldnames = fieldnames(roi);
    % get all the rois
    for roinum = 1:length(roiFieldnames)
      disppercent(-inf,sprintf('Loading tSeries from roi: %s, group: %s',roiFieldnames{roinum}, groupName));
      for scanNum = 1:length(scanList)
        % get current scan number
        scanNum = scanList(scanNum);
        rois{end+1} = roi.(roiFieldnames{roinum});
        % set a field in the roi for which scan we are collecting from
        rois{end}.scanNum = scanNum;
        rois{end}.groupNum = groupNum;
        % convert to scan coordinates
        rois{end}.scanCoords = getROICoordinates(view,rois{end},scanNum,groupNum);
        %rois{end}.scanCoords = getROICoordinatesMatching(view, rois{end}, scanNum, matchScanNum, groupNum, matchGroupNum);
        % if there are no scanCoords then set to empty and continue
        if isempty(rois{end}.scanCoords)
          rois{end}.n = 0;
          rois{end}.tSeries = [];
          continue;
        end
        % get x y and s in array form
        x = rois{end}.scanCoords(1,:);
        y = rois{end}.scanCoords(2,:);
        s = rois{end}.scanCoords(3,:);
        % set the n
        rois{end}.n = length(x);
        % load the tseries, voxel-by-voxel
        % for now we always load by block, but if memory is an issue, we can
        % switch this if statement and load voxels indiviudally from file
        
        % load each voxel time series indiviudally
        for voxnum = 1:rois{end}.n
          rois{end}.ehdr(voxnum,:) = squeeze(ehdr(x(voxnum),y(voxnum),s(voxnum),:))';
          rois{end}.ehdrste(voxnum,:) = squeeze(ehdrste(x(voxnum),y(voxnum),s(voxnum),:))';
        end
        disppercent(roinum/length(roiFieldnames));
      end
      disppercent(inf);
    end
  end
end




