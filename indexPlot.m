% indexPlot.m
%
%      usage: indexPlot(ehdr_endo, ehdr_exo, ehdrste_endo, ehdrste_exo, roiName)
%         by: eli & laura
%       date: 01/17/15
%    purpose:

function indexPlot(ehdr_endo, ehdr_exo, obs, roiName, roiToPlot, CI, whichAnal, contra_ipsi)

% check arguments
if ~any(nargin == [8])
    help endoexoIndexPlot
    return
end

if strcmp(CI,'correct')
    idx = 0;
elseif strcmp(CI,'incorrect')
    idx = 8;
end

% init variables
ehdrEndoC=[]; ehdrEndoI=[]; ehdrExoC=[]; ehdrExoI=[]; endoName=[];exoName=[];
% loop over ROIs, accumulating the beta's from the GLM
for iRoi = 1:(length(roiName)-1)
    % ENDOGENOUS condition
    % first four resps are 'contralateral' for right hemi ROIs
    if strfind(roiName{iRoi}, 'r_')
        ehdrEndoC(:,iRoi) = ehdr_endo{iRoi}((1+idx):(4+idx));
        ehdrEndoI(:,iRoi) = ehdr_endo{iRoi}((5+idx):(8+idx));
    elseif strfind(roiName{iRoi}, 'l_')
        ehdrEndoC(:,iRoi) = ehdr_endo{iRoi}((5+idx):(8+idx));
        ehdrEndoI(:,iRoi) = ehdr_endo{iRoi}((1+idx):(4+idx));
    else
        disp(sprintf('UHOH: Does not match left or right hemisphere'));
        return;
    end
    temp = roiName{iRoi};
    temp = fixBadChars(temp, [],{'r_',''});
    temp = fixBadChars(temp, [],{'l_',''});
    temp = fixBadChars(temp, [], {'v3d','v3'});
    temp = fixBadChars(temp, [], {'v2d','v2'});
    endoName{iRoi} = temp;
    
    % EXOGENOUS condition
    % first four resps are 'contralateral' for right hemi ROIs
    if strfind(roiName{iRoi}, 'r_')
        ehdrExoC(:,iRoi) = ehdr_exo{iRoi}((1+idx):(4+idx));
        ehdrExoI(:,iRoi) = ehdr_exo{iRoi}((5+idx):(8+idx));
    elseif strfind(roiName{iRoi}, 'l_')
        ehdrExoC(:,iRoi) = ehdr_exo{iRoi}((5+idx):(8+idx));
        ehdrExoI(:,iRoi) = ehdr_exo{iRoi}((1+idx):(4+idx));
    else
        disp(sprintf('UHOH: Does not match left or right hemisphere'));
        return;
    end
    temp = roiName{iRoi};
    temp = fixBadChars(temp, [],{'r_',''});
    temp = fixBadChars(temp, [],{'l_',''});
    temp = fixBadChars(temp, [], {'v3d','v3'});
    temp = fixBadChars(temp, [], {'v2d','v2'});
    exoName{iRoi} = temp;
    
end

% average over right and left hemipshere betas
aveExoC=[];aveExoI=[];aveEndoC=[];aveEndoI=[];
for iRoi=1:length(roiToPlot)
    % find indices matching roiNames for exo
    roiInd = strcmp(exoName, roiToPlot{iRoi});
    aveExoC(:,iRoi) = mean(ehdrExoC(:,roiInd)');
    aveExoI(:,iRoi) = mean(ehdrExoI(:,roiInd)');
    % find indices matching roiNames for endo
    roiInd = strcmp(endoName, roiToPlot{iRoi});
    aveEndoC(:,iRoi) = mean(ehdrEndoC(:,roiInd)');
    aveEndoI(:,iRoi) = mean(ehdrEndoI(:,roiInd)');
end


%% Plot data CONTRALATERAL

if contra_ipsi == 1
    aveEndoC = aveEndoC + 1;
    aveExoC = aveExoC + 1;
    % create valid-invalid and pre-post index plots
    endoVI = ( mean(aveEndoC([1 3],:)) - mean(aveEndoC([2 4],:)) ) ./ ( mean(aveEndoC([1 3],:)) + mean(aveEndoC([2 4],:)) );
    endoPP = ( mean(aveEndoC([1 2],:)) - mean(aveEndoC([3 4],:)) ) ./ ( mean(aveEndoC([1 2],:)) + mean(aveEndoC([3 4],:)) );
    exoVI = ( mean(aveExoC([1 3],:)) - mean(aveExoC([2 4],:)) ) ./ ( mean(aveExoC([1 3],:)) + mean(aveExoC([2 4],:)) );
    exoPP = ( mean(aveExoC([1 2],:)) - mean(aveExoC([3 4],:)) ) ./ ( mean(aveExoC([1 2],:)) + mean(aveExoC([3 4],:)) );
    
    smartfig('indindplot'); clf; hold on;
    for iRoi = 1:length(roiToPlot);
        line([endoVI(iRoi) exoVI(iRoi)], [endoPP(iRoi) exoPP(iRoi)], 'color', [.5 .5 .5]);
        h1 = text(endoVI(iRoi), endoPP(iRoi), upper(roiToPlot{iRoi}),'FontSize',14,'FontWeight','bold','FontAngle',...
            'italic','color',[0 0 1],'HorizontalAlignment','Center');
        h2 = text(exoVI(iRoi), exoPP(iRoi), upper(roiToPlot{iRoi}),'FontSize',14,'FontWeight','bold','FontAngle',...
            'italic','color',[1 0 0],'HorizontalAlignment','Center');
    end
    
    scale_axis = .06;
    axis([-scale_axis scale_axis -scale_axis scale_axis]);
    hline(0);
    vline(0);
    ylabel('<------ post-cue     pre-cue ------>','FontSize', 14, 'FontAngle', 'Italic');
    xlabel('<------ invalid     valid ------>', 'FontSize', 14, 'FontAngle', 'Italic');
    set(gca, 'YTick', [-scale_axis 0 scale_axis], 'XTick', [-scale_axis 0 scale_axis], 'tickdir', 'out')
    axis square
    
    if strcmp(CI,'correct')
        title([whichAnal ' analysis (correct trials only - contralateral)'],'FontSize', 16)
    elseif strcmp(CI,'incorrect')
        title([whichAnal ' analysis (incorrect trials only - contralateral)'],'FontSize', 16)
    end
    print('-djpeg','-r500',['allIdx_' obs '_' whichAnal '_' CI '_contra']);
    
    smartfig('index-by-index'); clf; hold on;
    
    if strcmp(CI,'correct')
        suptitle(sprintf([whichAnal ' analysis (endogenous condition - correct trials only - contralateral)'],'FontSize', 16))
    elseif strcmp(CI,'incorrect')
        suptitle(sprintf([whichAnal ' analysis (endogenous condition - incorrect trials only - contralateral)'],'FontSize', 16))
    end
    
    subplot(1,2,1);
    cla
    bar(endoVI, 'facecolor', [0 0 0]);
    ylim([min([exoVI endoVI exoPP endoPP]) max([exoVI endoVI exoPP endoPP])])
    axis square;
    drawPublishAxis('xTickLabel',roiToPlot,'titleStr', 'Valid vs. Invalid index')
    
    subplot(1,2,2);
    cla
    bar(endoPP, 'facecolor', [0 0 0]);
    axis square;
    ylim([min([exoVI endoVI exoPP endoPP]) max([exoVI endoVI exoPP endoPP])])
    drawPublishAxis('xTickLabel',roiToPlot,'titleStr', 'Pre vs. Post-cueing index')
    
    print('-djpeg','-r500',['endoIdx_' obs '_' whichAnal '_' CI '_contra']);
    
    smartfig('index-by-index'); clf; hold on;
    
    if strcmp(CI,'correct')
        suptitle(sprintf([whichAnal ' analysis (exogenous condition - correct trials only - contralateral)'],'FontSize', 16))
    elseif strcmp(CI,'incorrect')
        suptitle(sprintf([whichAnal ' analysis (exogenous condition - incorrect trials only - contralateral)'],'FontSize', 16))
    end
    
    subplot(1,2,1);
    cla
    bar(exoVI, 'facecolor', [0 0 0]);
    axis square;
    ylim([min([exoVI endoVI exoPP endoPP]) max([exoVI endoVI exoPP endoPP])])
    drawPublishAxis('xTickLabel',roiToPlot,'titleStr', 'Valid vs. Invalid index')
    
    subplot(1,2,2);
    cla
    bar(exoPP, 'facecolor', [0 0 0]);
    axis square;
    ylim([min([exoVI endoVI exoPP endoPP]) max([exoVI endoVI exoPP endoPP])])
    drawPublishAxis('xTickLabel',roiToPlot,'titleStr', 'Pre vs. Post-cueing index')
    
    print('-djpeg','-r500',['exoIdx_' obs '_' whichAnal '_' CI '_contra']);
end

%% Plot data IPSILATERAL

if contra_ipsi == 2
    aveEndoC = aveEndoC + 1;
    aveExoC = aveExoC + 1;
    % create valid-invalid and pre-post index plots
    endoVI = ( mean(aveEndoI([1 3],:)) - mean(aveEndoI([2 4],:)) ) ./ ( mean(aveEndoI([1 3],:)) + mean(aveEndoI([2 4],:)) );
    endoPP = ( mean(aveEndoI([1 2],:)) - mean(aveEndoI([3 4],:)) ) ./ ( mean(aveEndoI([1 2],:)) + mean(aveEndoI([3 4],:)) );
    exoVI = ( mean(aveExoI([1 3],:)) - mean(aveExoI([2 4],:)) ) ./ ( mean(aveExoI([1 3],:)) + mean(aveExoI([2 4],:)) );
    exoPP = ( mean(aveExoI([1 2],:)) - mean(aveExoI([3 4],:)) ) ./ ( mean(aveExoI([1 2],:)) + mean(aveExoI([3 4],:)) );
    
    smartfig('indindplot'); clf; hold on;
    for iRoi = 1:length(roiToPlot);
        line([endoVI(iRoi) exoVI(iRoi)], [endoPP(iRoi) exoPP(iRoi)], 'color', [.5 .5 .5]);
        h1 = text(endoVI(iRoi), endoPP(iRoi), upper(roiToPlot{iRoi}),'FontSize',14,'FontWeight','bold','FontAngle',...
            'italic','color',[0 0 1],'HorizontalAlignment','Center');
        h2 = text(exoVI(iRoi), exoPP(iRoi), upper(roiToPlot{iRoi}),'FontSize',14,'FontWeight','bold','FontAngle',...
            'italic','color',[1 0 0],'HorizontalAlignment','Center');
    end
    
    scale_axis = .4;
    axis([-scale_axis scale_axis -scale_axis scale_axis]);
    hline(0);
    vline(0);
    ylabel('<------ post-cue     pre-cue ------>','FontSize', 14, 'FontAngle', 'Italic');
    xlabel('<------ invalid     valid ------>', 'FontSize', 14, 'FontAngle', 'Italic');
    set(gca, 'YTick', [-scale_axis 0 scale_axis], 'XTick', [-scale_axis 0 scale_axis], 'tickdir', 'out')
    axis square
    
    print('-djpeg','-r500',['allIdx_' obs '_' whichAnal '_' CI '_ipsi']);
    
    
    if strcmp(CI,'correct')
        title([whichAnal ' analysis (correct trials only -ipsilateral)'],'FontSize', 16)
    elseif strcmp(CI,'incorrect')
        title([whichAnal ' analysis (incorrect trials only - ipsilateral)'],'FontSize', 16)
    end
    
    smartfig('index-by-index'); clf; hold on;
    
    if strcmp(CI,'correct')
        suptitle(sprintf([whichAnal ' analysis (endogenous condition - correct trials only - ipsilateral)'],'FontSize', 16))
    elseif strcmp(CI,'incorrect')
        suptitle(sprintf([whichAnal ' analysis (endogenous condition - incorrect trials only - ipsilateral)'],'FontSize', 16))
    end
    
    subplot(1,2,1);
    cla
    bar(endoVI, 'facecolor', [0 0 0]);
    ylim([min([exoVI endoVI exoPP endoPP]) max([exoVI endoVI exoPP endoPP])])
    axis square;
    drawPublishAxis('xTickLabel',roiToPlot,'titleStr', 'Valid vs. Invalid index')
    
    subplot(1,2,2);
    cla
    bar(endoPP, 'facecolor', [0 0 0]);
    ylim([min([exoVI endoVI exoPP endoPP]) max([exoVI endoVI exoPP endoPP])])
    axis square;
    drawPublishAxis('xTickLabel',roiToPlot,'titleStr', 'Pre vs. Post-cueing index')
    
    print('-djpeg','-r500',['endoIdx_' obs '_' whichAnal '_' CI '_ipsi']);
    
    smartfig('index-by-index'); clf; hold on;
    
    if strcmp(CI,'correct')
        suptitle(sprintf([whichAnal ' analysis (exogenous condition - correct trials only - ipsilateral)'],'FontSize', 16))
    elseif strcmp(CI,'incorrect')
        suptitle(sprintf([whichAnal ' analysis (exogenous condition - incorrect trials only - ipsilateral)'],'FontSize', 16))
    end
    
    subplot(1,2,1);
    cla
    bar(exoVI, 'facecolor', [0 0 0]);
    ylim([min([exoVI endoVI exoPP endoPP]) max([exoVI endoVI exoPP endoPP])])
    axis square;
    drawPublishAxis('xTickLabel',roiToPlot,'titleStr', 'Valid vs. Invalid index')
    
    subplot(1,2,2);
    cla
    bar(exoPP, 'facecolor', [0 0 0]);
    ylim([min([exoVI endoVI exoPP endoPP]) max([exoVI endoVI exoPP endoPP])])
    axis square;
    drawPublishAxis('xTickLabel',roiToPlot,'titleStr', 'Pre vs. Post-cueing index')
    
    print('-djpeg','-r500',['exoIdx_' obs '_' whichAnal '_' CI '_ipsi']);
end
end