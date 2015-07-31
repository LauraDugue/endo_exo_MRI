function randomisation_hpc(attCond)

load([attCond '_data_hpc.mat'])

obs = {'nms' 'mr' 'id' 'rd' 'co'}; %
roiName = {'r_vTPJ','r_pTPJ','r_Ins'};%
locThresh = 0.2;

% Compute randomisation (shuffle the labels in the design matrix)
rep = 1;
for iRep = 1:rep
    for iObs = 1:length(obs)
        % pull data out of ROI and select voxels based on stimulus localizer
        for iRoi = 1:length(localizer{iObs})
            goodVox{iObs}{iRoi} = localizer{iObs}{iRoi}.co > locThresh & localizer{iObs}{iRoi}.ph < pi & ~isnan(rois{iObs}{iRoi}.ehdr(localizer{iObs}{iRoi}.goodSelectedVoxel)');
        end
        
        % average across voxels in each ROI
        parfor iRoi = 1:length(localizer{iObs})
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
        parfor iRoi = 1:length(roiName)
            betasShuffled{iRoi,iObs}(iRep,:) = regress(tSeries{iObs,iRoi}', scmShuffled);
        end
    end
end

save(['/scratch/ld1439/data/randombetas_' attCond '_indTrials.mat'],'betasShuffled')

end