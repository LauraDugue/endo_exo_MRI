function randomisation_hpc(attCond,repNumber)

load([attCond '_data_hpc.mat'])

obs = {'nms' 'mr' 'id' 'rd' 'co'}; %
roiName = {'r_vTPJ','r_pTPJ','r_Ins'};%
locThresh = 0.2;

% Compute randomisation (shuffle the labels in the design matrix)
rep = 1000;
for iRep = 1:rep
    tic; disp(['Running repetition number ' num2str(iRep)])
    for iObs = 1:length(obs)
        % pull data out of ROI and select voxels based on stimulus localizer
        for iRoi = 1:length(localizer{iObs})
            goodVox{iObs}{iRoi} = localizer{iObs}{iRoi}.co > locThresh & localizer{iObs}{iRoi}.ph < pi & ~isnan(rois{iObs}{iRoi}.ehdr(localizer{iObs}{iRoi}.goodSelectedVoxel)');
        end
        
        % average across voxels in each ROI
        for iRoi = 1:length(localizer{iObs})
            tempB = [];
            for iRun = 1:size(rois{iObs}{iRoi}.boot,2)
                temp = squeeze(mean(rois{iObs}{iRoi}.boot{iRun}(goodVox{iObs}{iRoi},:)));
                temp = percentTSeries(temp')';
                tempB = cat(2, tempB, temp);
            end
            tSeries{iObs,iRoi} = tempB;
        end
        
        % make the shuffled design matrix: 1 column per trial
        idxAll = [];
        for iRun = 1:length(dataGLM{iObs}.inputs.design)
            idx = [];
            for iVol = 1:length(dataGLM{iObs}.inputs.design{iRun})
                if find(dataGLM{iObs}.inputs.design{iRun}(iVol,:)==1) > 0
                    idx(iVol) = 1;
                elseif isempty(find(dataGLM{iObs}.inputs.design{iRun}(iVol,:)==1))
                    idx(iVol) = 0;
                end
            end
            idxAll = [idxAll idx];
        end
        
        scm = zeros(size(idxAll,2),size(find(idxAll==1),2));
        countTrial = 1;
        for iVol = 1:size(idxAll,2)
            if idxAll(iVol) == 1
                scm(iVol,countTrial) = 1;
                countTrial = countTrial + 1;
            end
        end
        
        scm2 = [];
        runStart = 1;
        for iRun=1:length(dataGLM{iObs}.inputs.design)
            runEnd = runStart + size(dataGLM{iObs}.inputs.design{iRun},1)-1;
            thisDesign = convn(dataGLM{iObs}.models{1}(:,1), scm(runStart:runEnd,:));
            thisDesign = thisDesign(1:length(dataGLM{iObs}.inputs.design{iRun}),:);
            scm2 = cat(1, scm2, thisDesign);
            runStart = runEnd + 1;
        end 
        
        % shuffle the design matrix
        idx = size(scm,2);
        idxShuffled = randsample(1:idx,idx);
        scmShuffled = scm(:,idxShuffled);
        
        % Compute the surrogate contrasts
        for iRoi = 1:length(roiName)
            betasShuffled{iRoi,iObs}(iRep,:) = regress(tSeries{iObs,iRoi}', scmShuffled);
        end
    end
    toc;
end

save(['/scratch/ld1439/data/randombetas_' attCond '_indTrials_' num2str(repNumber) '.mat'],'betasShuffled')

end

function ptSeries = percentTSeries(tSeries, varargin)
%
%        $Id$
%
% ptSeries = percentTSeries(tSeries, [param1], [value1], [param2], [value2])
%
% 1) Optional temporal normalization.
% 2) Optional spatial normalization.
% 3) Optional temporal detrending.
% 4) Optional subtract mean (note that this may have already happened
% depending on the choice of temporal detrending).
%
% Valid params are: 
% 'detrend'
% 'highpassPeriod'
% 'spatialNormalization'
% 'spatialNorm'
% 'subtractMean',
% 'temporalNormalization'
%
% Values for detrend:  
%   'None' no trend removal
%   'Highpass' highpass trend removal (using 'highpassPeriod')
%   'Linear' linear trend removal
%   'Quadratic' quadratic removal
% Default: 'Highpass'
%
% 'highpassPeriod' controls the highpass filtering. For a periodic or
% block alternation experiment, highpassPeriod should be equal to the number
% of frames in the block period.
% Default: nFrames/6 (number of frames in tSeries divided by 6)
%
% Values for spatialNormalization (e.g., to to compensate coil sensitivity): 
%   'None' do nothing
%   'Divide by mean' divide by the mean, independently at each voxel
%   'Arbitrary' (using 'spatialNorm')
% Default: 'Divide by mean'
%
% 'spatialNorm' must be an array that has the same number of elements as the
% number of voxels in the tSeries. 
% Default: mean(tSeries)
%
% Values for subtractMean:  
%   'No' 
%   'Yes'
% Default: 'Yes'
%
% Values for temporalNormalization that divides each temporal frame by its
% mean:
%   'No' 
%   'Yes'
% Default: 'No'
% 
% djh, 1/22/98
% djh, 7/7/2004 Updated to mrLoadRet 4.0

% Get  nVoxels
[nFrames, nVoxels] = size(tSeries); 

% Parse varargin to get parameters and values
for index = 1:2:length(varargin)
    field = varargin{index};
    val = varargin{index+1};
    switch field
        case 'detrend'
            detrend = val;
        case 'spatialNormalization'
            spatialNormalization = val;
        case 'subtractMean'
            subtractMean = val;
        case 'temporalNormalization'
            temporalNormalization = val;
        case 'highpassPeriod'
            if ~isnumeric(val) | (size(val) ~= 1)
                mrErrorDlg(['Invalid highpassPeriod option: ',val]);
            else
                highpassPeriod = val;
            end
        case 'spatialNorm'
            if ~isnumeric(val) | (prod(size(val)) ~= nVoxels)
                mrErrorDlg(['Invalid normalizationVol option.']);
            else
                % reshape into a row vector
                spatialNorm = val(:)';
            end
        otherwise
            warning('percentTSeries: invalid parameter')
    end
end

detrend = 'Highpass';
subtractMean = 'Yes';
spatialNormalization = 'Divide by mean';
temporalNormalization = 'No';

% if ieNotDefined('detrend')
%     detrend = 'Highpass';
% end
% if ieNotDefined('subtractMean') 
%     subtractMean = 'Yes';
% end
% if ieNotDefined('spatialNormalization')
%     spatialNormalization = 'Divide by mean';
% end
% if ieNotDefined('temporalNormalization')
%     temporalNormalization = 'No';
% end

% If detrend = 'Highpass' then highpassPeriod must be set to something.
% Use nFrames/6 as the default.
% if strcmp(detrend,'Highpass')
%     if ieNotDefined('highpassPeriod')
%         highpassPeriod = round(nFrames/6);
%     end
% end
highpassPeriod = round(nFrames/6);


% If spatialNormalization = 'Aribrary' then spatialNorm must be set to
% something. Use mean of tSeries as the default.
if strcmp(spatialNormalization,'Arbitrary')
    if ieNotDefined('spatialNorm')
        spatialNorm = mean(tSeries);
    end
end

% Temporal normalization divides each frame by its mean.
% Added by ARW
%
switch temporalNormalization
    case 'No'
        % do nothing
    case 'Yes'
        disp('Temporal normalization to first frame');
        % Mean of each frame
        meanFrames = mean(tSeries,2);
        disp(sprintf('Mean tseries value of the first frame %.05f\n',meanFrames(1)));
        tSeries = (tSeries ./ repmat(meanFrames,1,nVoxels)) * meanFrames(1);
    otherwise
        mrErrorDlg(['Invalid termporalNormalization option: ',temporalNormalization]);
end

% Divide by either the mean or whatever you passed in as spatialNormalization
%
switch spatialNormalization
    case 'None'
        ptSeries = tSeries;
    case 'Divide by mean'
        dc = mean(tSeries);
        if any(dc<0)
          mrWarnDlg('(percentTSeries) Dividing some time-series by a negative value during spatial normalization. Is that really what you want ?')
        end
        ptSeries = tSeries./(ones(nFrames,1)*dc);
    case 'Arbitrary'
        ptSeries = tSeries./(ones(nFrames,1)*spatialNorm);
    otherwise
        mrErrorDlg(['Invalid spatialNormalization option: ',spatialNormalization]);
end

% Remove trend
%
switch detrend
    case 'None'
        % Do nothing
    case 'Highpass'
        % Do high-pass baseline removal
        ptSeries = removeBaseline(ptSeries, highpassPeriod);
    case 'Linear'
        % remove a linear function
        model = [(1:nFrames);ones(1,nFrames)]';
        wgts = model \ ptSeries;
        fit = model*wgts;
        ptSeries = ptSeries - fit;
    case 'Quadratic'
        % remove a quadratic function
        model = [(1:nFrames).*(1:nFrames);(1:nFrames);ones(1,nFrames)]';
        wgts = model \ ptSeries;
        fit = model*wgts;
        ptSeries = ptSeries - fit;
    otherwise
        mrErrorDlg(['Invalid detrend option: ',detrend]);
end

% Subtract the mean
% Used to just subtract 1 under the assumption that we had already divided by
% the mean, but now with the spatialGrad option the mean may not be exactly 1.
%
switch subtractMean 
    case 'No'
        % Do nothing
    case 'Yes'
        ptSeries = ptSeries - ones(nFrames,1)*mean(ptSeries);
        if ~strcmp(spatialNormalization,'None')
			% Multiply by 100 to get percent
			ptSeries = 100*ptSeries;
		end
otherwise
    mrErrorDlg(['Invalid subtractMean option: ',subtractMean]);
end

return%

%%%%%%%%%%%%%%
% Test/debug %
%%%%%%%%%%%%%%

nFrames = 100;
nVoxels = 10;
baseline = 100+linspace(-10,10,nFrames)';
tSeries = 10 * (randn(nFrames,nVoxels) + repmat(baseline,1,nVoxels));
figure(1)
plot(tSeries)

ptSeries = percentTSeries(tSeries,'detrend','None',...
    'spatialNormalization','None','subtractMean','No',...
    'temporalNormalization','No');
plot(ptSeries)

ptSeries = percentTSeries(tSeries,'detrend','Linear',...
    'spatialNormalization','None','subtractMean','No',...
    'temporalNormalization','No');
plot(ptSeries)

ptSeries = percentTSeries(tSeries,'detrend','Quadratic',...
    'spatialNormalization','None','subtractMean','No',...
    'temporalNormalization','No');
plot(ptSeries)

% Stupid combination
ptSeries = percentTSeries(tSeries,'detrend','None',...
    'spatialNormalization','None','subtractMean','Yes',...
    'temporalNormalization','No');
plot(ptSeries)

ptSeries = percentTSeries(tSeries,'detrend','None',...
    'spatialNormalization','Divide by mean','subtractMean','No',...
    'temporalNormalization','No');
plot(ptSeries)

ptSeries = percentTSeries(tSeries,'detrend','None',...
    'spatialNormalization','Divide by mean','subtractMean','Yes',...
    'temporalNormalization','No');
plot(ptSeries)

ptSeries = percentTSeries(tSeries,'detrend','Linear',...
    'spatialNormalization','Divide by mean','subtractMean','Yes',...
    'temporalNormalization','No');
plot(ptSeries)

ptSeries = percentTSeries(tSeries,'detrend','None',...
    'spatialNormalization','None','subtractMean','No',...
    'temporalNormalization','Yes');
plot(ptSeries)

ptSeries = percentTSeries(tSeries,'detrend','None',...
    'spatialNormalization','Arbitrary','spatialNorm',10*[1:nVoxels],...
    'subtractMean','No',...
    'temporalNormalization','No');
plot(ptSeries)

ptSeries = percentTSeries(tSeries,'detrend','Linear',...
    'spatialNormalization','Arbitrary','spatialNorm',mean(tSeries),...
    'subtractMean','Yes',...
    'temporalNormalization','No');
plot(ptSeries)

ptSeries = percentTSeries(tSeries,'detrend','None',...
    'spatialNormalization','Arbitrary','subtractMean','No',...
    'temporalNormalization','No');
plot(ptSeries)

ptSeries = percentTSeries(tSeries,...
    'detrend','Highpass','highpassPeriod',round(nFrames/10),...
    'spatialNormalization','None','subtractMean','No',...
    'temporalNormalization','No');
plot(ptSeries)

ptSeries = percentTSeries(tSeries,...
    'detrend','Highpass',...
    'spatialNormalization','None','subtractMean','No',...
    'temporalNormalization','No');
plot(ptSeries)

% Default
ptSeries = percentTSeries(tSeries,...
    'detrend','Highpass','highpassPeriod',round(nFrames/6),...
    'spatialNormalization','Divide by mean','subtractMean','Yes',...
    'temporalNormalization','No');
plot(ptSeries)
end

function tSeries = removeBaseline(tSeries, period)
% function tSeries = removeBaseline(tSeries, period);
%
% Use multiple boxcar smoothing operations to remove low-frequency baseline
% drift from the input time series (tSeries) using the input period in
% FRAMES (not seconds!). The input is assumed to be  two-dimensional, with
% time as the low-order dimension.
%
% DBR  5/00

% djh & dbr, 2/2001. 
% Fixed numIterations=2, no longer a variable input argument.

% Create boxcar kernel:
kernel = ones([period 1]) / period;
numIterations = 2;

% Initialize the baseline array to the time with 1-period
% padding at beginning and end:
ntPoints = size(tSeries,1);
nSeries = size(tSeries,2);
mValues = mean(tSeries);
nBLine = ntPoints + 2*period;
bLine = zeros(nBLine,nSeries);
firstTrialMean = mean(tSeries(1:period,:));

for frame = 1:period
    bLine(frame,:) = firstTrialMean; 
end
bLine(period+1:period+ntPoints,:) = tSeries;
lastTrialMean = mean(tSeries(ntPoints-period+1:ntPoints,:));
for frame = period+ntPoints+1:nBLine
    bLine(frame,:) = lastTrialMean; 
end

% Define indices for post-smoothing array "trim":
addPts = numIterations * (period - 1);
start = floor(addPts/2) + 1;
stop = nBLine + floor(addPts/2);

% Smoothing loop -- convolve with boxcar, then "trim" array:
for i=1:numIterations
    bLine = conv2(bLine, kernel); 
end
bLine = bLine(start:stop, :);

% Remove baseline from time series:
tSeries = tSeries - bLine(period+1:period+ntPoints,:);
end