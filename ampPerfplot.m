% ampPerfplot.m
%
%      usage: ampPerfplot
%         by: laura
%       date: 07/09/15

%%% This program plot the data obtained through ampPerf

%% Number of Bins
runampPerf = 1;

%% Run ampPerf
if runampPerf
    nBins = 2;
    ampPerfCondByCond({'mr'},'first','exo',0,nBins);
    ampPerfCondByCond({'mr'},'first','endo',0,nBins);
    clear all;nBins = 2;
    ampPerfCondByCond({'id'},'first','exo',0,nBins);
    ampPerfCondByCond({'id'},'first','endo',0,nBins);
    clear all;nBins = 2;
    ampPerfCondByCond({'nms'},'first','exo',0,nBins);
    ampPerfCondByCond({'nms'},'first','endo',0,nBins);
    clear all;nBins = 2;
    ampPerfCondByCond({'rd'},'first','exo',0,nBins);
    ampPerfCondByCond({'rd'},'first','endo',0,nBins);
    clear all;nBins = 2;
    ampPerfCondByCond({'co'},'first','exo',0,nBins);
    ampPerfCondByCond({'co'},'first','endo',0,nBins);
    clear all;
end
%% set conditions to run
nBins = 2;
obs = {'co' 'nms' 'mr' 'rd' 'id'}; %
roiName = {'vTPJ','pTPJ','Ins'};

%% Load the data
for iSub = 1:size(obs,2)
    dataEndo{iSub} = load(['/Volumes/DRIVE1/DATA/laura/MRI/' obs{iSub} '/' obs{iSub} 'Merge/perfCondbyCond_' obs{iSub} '_endo_' num2str(nBins) 'bins.mat']);
    dataExo{iSub} = load(['/Volumes/DRIVE1/DATA/laura/MRI/' obs{iSub} '/' obs{iSub} 'Merge/perfCondbyCond_' obs{iSub} '_exo_' num2str(nBins) 'bins.mat']);
end

%% Plot the data
for iRoi = 1:3
    figure;
    % Valid performance Endo
    subplot(2,2,1)
    hold on;
    for iSub = 1:size(obs,2)
        % perfValid(iRoi,iBin)
        plot(dataEndo{iSub}.perfValid(iRoi,:),'o')
    end
    ylim([.5 1])
    xlim([0 nBins+1])
    set(gca,'XTick',1:nBins,'FontSize',14)
    set(gca,'YTick',.5:.2:1,'FontSize',14)
    ylabel('Performance','FontSize',14)
    title(['Endo - Valid (' roiName{iRoi} ')'],'FontSize',16)
    % Invalid performance Endo
    subplot(2,2,2)
    hold on;
    for iSub = 1:size(obs,2)
        plot(dataEndo{iSub}.perfInvalid(iRoi,:),'o')
    end
    ylim([.5 1])
    xlim([0 nBins+1])
    set(gca,'XTick',1:nBins,'FontSize',14)
    set(gca,'YTick',.5:.2:1,'FontSize',14)
    title('Endo - Invalid','FontSize',16)
    % Valid performance Exo
    subplot(2,2,3)
    hold on;
    for iSub = 1:size(obs,2)
        % perfValid(iRoi,iBin)
        plot(dataExo{iSub}.perfValid(iRoi,:),'o')
    end
    ylim([.5 1])
    xlim([0 nBins+1])
    set(gca,'XTick',1:3,'FontSize',14)
    set(gca,'YTick',.5:.2:1,'FontSize',14)
    ylabel('Performance','FontSize',14)
    xlabel('Bin of Amplitude','FontSize',14)
    title('Exo - Valid','FontSize',16)
    % Invalid performance Exo
    subplot(2,2,4)
    hold on;
    for iSub = 1:size(obs,2)
        plot(dataExo{iSub}.perfInvalid(iRoi,:),'o')
    end
    ylim([.5 1])
    xlim([0 nBins+1])
    set(gca,'XTick',1:nBins,'FontSize',14)
    set(gca,'YTick',.5:.2:1,'FontSize',14)
    xlabel('Bin of Amplitude','FontSize',14)
    title('Exo - Invalid','FontSize',16)
    
    print('-djpeg','-r500',['/Local/Users/purpadmin/Desktop/Laura/Bin/' num2str(nBins) 'bins_' roiName{iRoi}]); 
end

%% Correlation analyses for vTPJ
clc
for iSub = 1:size(obs,2)
    vTPJEndoValid(iSub,:) = dataEndo{iSub}.perfValid(1,:);
    vTPJEndoInvalid(iSub,:) = dataEndo{iSub}.perfInvalid(1,:);
    vTPJExoValid(iSub,:) = dataExo{iSub}.perfValid(1,:);
    vTPJExoInvalid(iSub,:) = dataExo{iSub}.perfInvalid(1,:);
end
% [RHO,PVAL] = corr(vTPJEndoValid(:,1),vTPJEndoValid(:,nBins))
% [RHO,PVAL] = corr(vTPJEndoInvalid(:,1),vTPJEndoInvalid(:,nBins))
% [RHO,PVAL] = corr(vTPJExoValid(:,1),vTPJExoValid(:,nBins))
% [RHO,PVAL] = corr(vTPJExoInvalid(:,1),vTPJExoInvalid(:,nBins))

[H,P,CI,STATS] = ttest(vTPJEndoValid(:,1),vTPJEndoValid(:,2)) % *
[H,P,CI,STATS] = ttest(vTPJEndoInvalid(:,1),vTPJEndoInvalid(:,2))

[H,P,CI,STATS] = ttest(vTPJExoValid(:,1),vTPJExoValid(:,2))
[H,P,CI,STATS] = ttest(vTPJExoInvalid(:,1),vTPJExoInvalid(:,2))

%% Correlation analyses for pTPJc
clc
for iSub = 1:size(obs,2)
    vTPJEndoValid(iSub,:) = dataEndo{iSub}.perfValid(2,:);
    vTPJEndoInvalid(iSub,:) = dataEndo{iSub}.perfInvalid(2,:);
    vTPJExoValid(iSub,:) = dataExo{iSub}.perfValid(2,:);
    vTPJExoInvalid(iSub,:) = dataExo{iSub}.perfInvalid(2,:);
end
% [RHO,PVAL] = corr(vTPJEndoValid(:,1),vTPJEndoValid(:,nBins))
% [RHO,PVAL] = corr(vTPJEndoInvalid(:,1),vTPJEndoInvalid(:,nBins))
% [RHO,PVAL] = corr(vTPJExoValid(:,1),vTPJExoValid(:,nBins))
% [RHO,PVAL] = corr(vTPJExoInvalid(:,1),vTPJExoInvalid(:,nBins))

[H,P,CI,STATS] = ttest(vTPJEndoValid(:,1),vTPJEndoValid(:,2))
[H,P,CI,STATS] = ttest(vTPJEndoInvalid(:,1),vTPJEndoInvalid(:,2)) % *

[H,P,CI,STATS] = ttest(vTPJExoValid(:,1),vTPJExoValid(:,2))
[H,P,CI,STATS] = ttest(vTPJExoInvalid(:,1),vTPJExoInvalid(:,2))

%% Correlation analyses for Ins
clc
for iSub = 1:size(obs,2)
    vTPJEndoValid(iSub,:) = dataEndo{iSub}.perfValid(3,:);
    vTPJEndoInvalid(iSub,:) = dataEndo{iSub}.perfInvalid(3,:);
    vTPJExoValid(iSub,:) = dataExo{iSub}.perfValid(3,:);
    vTPJExoInvalid(iSub,:) = dataExo{iSub}.perfInvalid(3,:);
end
% [RHO,PVAL] = corr(vTPJEndoValid(:,1),vTPJEndoValid(:,nBins))
% [RHO,PVAL] = corr(vTPJEndoInvalid(:,1),vTPJEndoInvalid(:,nBins))
% [RHO,PVAL] = corr(vTPJExoValid(:,1),vTPJExoValid(:,nBins))
% [RHO,PVAL] = corr(vTPJExoInvalid(:,1),vTPJExoInvalid(:,nBins))

[H,P,CI,STATS] = ttest(vTPJEndoValid(:,1),vTPJEndoValid(:,2))
[H,P,CI,STATS] = ttest(vTPJEndoInvalid(:,1),vTPJEndoInvalid(:,2))

[H,P,CI,STATS] = ttest(vTPJExoValid(:,1),vTPJExoValid(:,2))
[H,P,CI,STATS] = ttest(vTPJExoInvalid(:,1),vTPJExoInvalid(:,2))

%% Plot the data
for iRoi = 1:3
    temp1 = []; temp2 = []; temp3 = []; temp4 = [];
    for iSub = 1:size(obs,2)
        temp1 = [temp1;dataEndo{iSub}.perfValid(iRoi,:)];
        temp2 = [temp2;dataEndo{iSub}.perfInvalid(iRoi,:)];
        temp3 = [temp3;dataExo{iSub}.perfValid(iRoi,:)];
        temp4 = [temp4;dataExo{iSub}.perfInvalid(iRoi,:)];
    end
    avg_endovalid{iRoi} = temp1;
    avg_endoinvalid{iRoi} = temp2;
    avg_exovalid{iRoi} = temp3;
    avg_exoinvalid{iRoi} = temp4;
end

for iRoi = 1:3
    figure;
    % Valid performance Endo
    subplot(1,2,1)
    hold on;
    for iSub = 1:size(obs,2)
        % perfValid(iRoi,iBin)
        plot([dataEndo{iSub}.perfValid(iRoi,:) dataEndo{iSub}.perfInvalid(iRoi,:)],'o')
    end
    errorbar(1:nBins*2,[mean(avg_endovalid{iRoi}) mean(avg_endoinvalid{iRoi})],[std(avg_endovalid{iRoi})./sqrt(size(obs,2)) std(avg_endoinvalid{iRoi})./sqrt(size(obs,2))],...
        '-or','LineWidth',2,'MarkerSize',10,'MarkerFaceColor',[1 1 1])
    ylim([.5 1])
    xlim([0 nBins*2+1])
    set(gca,'XTick',1:nBins*2,'FontSize',14)
    set(gca,'XTickLabel',{'V_b1' 'V_b2' 'I_b1' 'I_b2'},'FontSize',14)
    set(gca,'YTick',.5:.2:1,'FontSize',14)
    ylabel('Performance','FontSize',14)
    xlabel('Bin of Amplitude','FontSize',14)
    title(['Endo (' roiName{iRoi} ')'],'FontSize',16)
    
    % Valid performance Exo
    subplot(1,2,2)
    hold on;
    for iSub = 1:size(obs,2)
        % perfValid(iRoi,iBin)
        plot([dataExo{iSub}.perfValid(iRoi,:) dataExo{iSub}.perfInvalid(iRoi,:)],'o')
    end
    errorbar(1:nBins*2,[mean(avg_exovalid{iRoi}) mean(avg_exoinvalid{iRoi})],[std(avg_exovalid{iRoi})./sqrt(size(obs,2)) std(avg_exoinvalid{iRoi})./sqrt(size(obs,2))],...
        '-or','LineWidth',2,'MarkerSize',10,'MarkerFaceColor',[1 1 1])
    ylim([.5 1])
    xlim([0 nBins*2+1])
    set(gca,'XTick',1:nBins*2,'FontSize',14)
    set(gca,'XTickLabel',{'V_b1' 'V_b2' 'I_b1' 'I_b2'},'FontSize',14)
    set(gca,'YTick',.5:.2:1,'FontSize',14)
    title('Exo','FontSize',16)
    xlabel('Bin of Amplitude','FontSize',14)
    
    print('-djpeg','-r500',['/Local/Users/purpadmin/Desktop/Laura/Bin/' num2str(nBins) 'bins_' roiName{iRoi}]);
    
end

%% T-Tests analyses for vTPJ
clc
for iSub = 1:size(obs,2)
    vTPJEndoValid(iSub,:) = dataEndo{iSub}.perfValid(1,:);
    vTPJEndoInvalid(iSub,:) = dataEndo{iSub}.perfInvalid(1,:);
    vTPJExoValid(iSub,:) = dataExo{iSub}.perfValid(1,:);
    vTPJExoInvalid(iSub,:) = dataExo{iSub}.perfInvalid(1,:);
end

[H,P,CI,STATS] = ttest(vTPJEndoValid(:,2),vTPJEndoInvalid(:,2)) % 
[H,P,CI,STATS] = ttest(vTPJExoValid(:,2),vTPJExoInvalid(:,2)) % 

%% T-Tests analyses for pTPJ
clc
for iSub = 1:size(obs,2)
    vTPJEndoValid(iSub,:) = dataEndo{iSub}.perfValid(2,:);
    vTPJEndoInvalid(iSub,:) = dataEndo{iSub}.perfInvalid(2,:);
    vTPJExoValid(iSub,:) = dataExo{iSub}.perfValid(2,:);
    vTPJExoInvalid(iSub,:) = dataExo{iSub}.perfInvalid(2,:);
end
[H,P,CI,STATS] = ttest(vTPJEndoValid(:,2),vTPJEndoInvalid(:,2)) % 
[H,P,CI,STATS] = ttest(vTPJExoValid(:,2),vTPJExoInvalid(:,2)) % 

%% T-Tests analyses for Ins

clc
for iSub = 1:size(obs,2)
    vTPJEndoValid(iSub,:) = dataEndo{iSub}.perfValid(3,:);
    vTPJEndoInvalid(iSub,:) = dataEndo{iSub}.perfInvalid(3,:);
    vTPJExoValid(iSub,:) = dataExo{iSub}.perfValid(3,:);
    vTPJExoInvalid(iSub,:) = dataExo{iSub}.perfInvalid(3,:);
end
[H,P,CI,STATS] = ttest(vTPJEndoValid(:,2),vTPJEndoInvalid(:,2),'tail','left') % 
[H,P,CI,STATS] = ttest(vTPJExoValid(:,2),vTPJExoInvalid(:,2),'tail','left') % 

%% Plot the data - separately for pre and post cueing
for iRoi = 1:3
    temp1 = []; temp2 = []; temp3 = []; temp4 = [];
    temp5 = []; temp6 = []; temp7 = []; temp8 = [];
    for iSub = 1:size(obs,2)
        temp1 = [temp1;dataEndo{iSub}.perfValidpre(iRoi,2)];
        temp2 = [temp2;dataEndo{iSub}.perfInvalidpre(iRoi,2)];
        temp3 = [temp3;dataExo{iSub}.perfValidpre(iRoi,2)];
        temp4 = [temp4;dataExo{iSub}.perfInvalidpre(iRoi,2)];
        temp5 = [temp1;dataEndo{iSub}.perfValidpost(iRoi,2)];
        temp6 = [temp2;dataEndo{iSub}.perfInvalidpost(iRoi,2)];
        temp7 = [temp3;dataExo{iSub}.perfValidpost(iRoi,2)];
        temp8 = [temp4;dataExo{iSub}.perfInvalidpost(iRoi,2)];
    end
    avg_endovalidpre{iRoi} = temp1;
    avg_endoinvalidpre{iRoi} = temp2;
    avg_exovalidpre{iRoi} = temp3;
    avg_exoinvalidpre{iRoi} = temp4;
    avg_endovalidpost{iRoi} = temp5;
    avg_endoinvalidpost{iRoi} = temp6;
    avg_exovalidpost{iRoi} = temp7;
    avg_exoinvalidpost{iRoi} = temp8;
end

for iRoi = 1:3
    figure;
    % Valid performance Endo
    subplot(1,2,1)
    hold on;
    for iSub = 1:size(obs,2)
        % perfValid(iRoi,iBin)
        plot([dataEndo{iSub}.perfValidpre(iRoi,2) dataEndo{iSub}.perfInvalidpre(iRoi,2) dataEndo{iSub}.perfValidpost(iRoi,2) dataEndo{iSub}.perfInvalidpost(iRoi,2)],'o')
    end
    errorbar(1:nBins*2,[mean(avg_endovalidpre{iRoi}) mean(avg_endoinvalidpre{iRoi}) mean(avg_endovalidpost{iRoi}) mean(avg_endoinvalidpost{iRoi})],...
        [std(avg_endovalidpre{iRoi})./sqrt(size(obs,2)) std(avg_endoinvalidpre{iRoi})./sqrt(size(obs,2)) std(avg_endovalidpost{iRoi})./sqrt(size(obs,2)) std(avg_endoinvalidpost{iRoi})./sqrt(size(obs,2))],...
        '-or','LineWidth',2,'MarkerSize',10,'MarkerFaceColor',[1 1 1])
    ylim([.5 1])
    xlim([0 nBins*2+1])
    set(gca,'XTick',1:nBins*2,'FontSize',14)
    set(gca,'XTickLabel',{'VPre' 'IPre' 'VPost' 'IPost'},'FontSize',14)
    set(gca,'YTick',.5:.2:1,'FontSize',14)
    ylabel('Performance','FontSize',14)
    xlabel('For Bin 2','FontSize',14)
    title(['Endo (' roiName{iRoi} ')'],'FontSize',16)
    
    % Valid performance Exo
    subplot(1,2,2)
    hold on;
    for iSub = 1:size(obs,2)
        % perfValid(iRoi,iBin)
        plot([dataExo{iSub}.perfValidpre(iRoi,2) dataExo{iSub}.perfInvalidpre(iRoi,2) dataExo{iSub}.perfValidpost(iRoi,2) dataExo{iSub}.perfInvalidpost(iRoi,2)],'o')
    end
    errorbar(1:nBins*2,[mean(avg_exovalidpre{iRoi}) mean(avg_exoinvalidpre{iRoi}) mean(avg_exovalidpost{iRoi}) mean(avg_exoinvalidpost{iRoi})],...
        [std(avg_exovalidpre{iRoi})./sqrt(size(obs,2)) std(avg_exoinvalidpre{iRoi})./sqrt(size(obs,2)) std(avg_exovalidpost{iRoi})./sqrt(size(obs,2)) std(avg_exoinvalidpost{iRoi})./sqrt(size(obs,2))],...
        '-or','LineWidth',2,'MarkerSize',10,'MarkerFaceColor',[1 1 1])
    ylim([.5 1])
    xlim([0 nBins*2+1])
    set(gca,'XTick',1:nBins*2,'FontSize',14)
    set(gca,'XTickLabel',{'VPre' 'IPre' 'VPost' 'IPost'},'FontSize',14)
    set(gca,'YTick',.5:.2:1,'FontSize',14)
    title('Exo','FontSize',16)
    xlabel('For Bin 2','FontSize',14)
    
    print('-djpeg','-r500',['/Local/Users/purpadmin/Desktop/Laura/Bin/prepost_' num2str(nBins) 'bins_' roiName{iRoi}]);
    
end

%% T-Tests analyses for vTPJ
clc
for iSub = 1:size(obs,2)
    vTPJEndoValidpre(iSub,:) = dataEndo{iSub}.perfValidpre(1,:);
    vTPJEndoInvalidpre(iSub,:) = dataEndo{iSub}.perfInvalidpre(1,:);
    vTPJExoValidpre(iSub,:) = dataExo{iSub}.perfValidpre(1,:);
    vTPJExoInvalidpre(iSub,:) = dataExo{iSub}.perfInvalidpre(1,:);
    vTPJEndoValidpost(iSub,:) = dataEndo{iSub}.perfValidpost(1,:);
    vTPJEndoInvalidpost(iSub,:) = dataEndo{iSub}.perfInvalidpost(1,:);
    vTPJExoValidpost(iSub,:) = dataExo{iSub}.perfValidpost(1,:);
    vTPJExoInvalidpost(iSub,:) = dataExo{iSub}.perfInvalidpost(1,:);
end

[H,P,CI,STATS] = ttest(vTPJEndoValidpre(:,2),vTPJEndoInvalidpre(:,2)) % 
[H,P,CI,STATS] = ttest(vTPJEndoValidpost(:,2),vTPJEndoInvalidpost(:,2)) % 
[H,P,CI,STATS] = ttest(vTPJExoValidpre(:,2),vTPJExoInvalidpre(:,2)) % 
[H,P,CI,STATS] = ttest(vTPJExoValidpost(:,2),vTPJExoInvalidpost(:,2)) % 

%% T-Tests analyses for pTPJ
clc
for iSub = 1:size(obs,2)
    vTPJEndoValidpre(iSub,:) = dataEndo{iSub}.perfValidpre(2,:);
    vTPJEndoInvalidpre(iSub,:) = dataEndo{iSub}.perfInvalidpre(2,:);
    vTPJExoValidpre(iSub,:) = dataExo{iSub}.perfValidpre(2,:);
    vTPJExoInvalidpre(iSub,:) = dataExo{iSub}.perfInvalidpre(2,:);
    vTPJEndoValidpost(iSub,:) = dataEndo{iSub}.perfValidpost(2,:);
    vTPJEndoInvalidpost(iSub,:) = dataEndo{iSub}.perfInvalidpost(2,:);
    vTPJExoValidpost(iSub,:) = dataExo{iSub}.perfValidpost(2,:);
    vTPJExoInvalidpost(iSub,:) = dataExo{iSub}.perfInvalidpost(2,:);
end

[H,P,CI,STATS] = ttest(vTPJEndoValidpre(:,2),vTPJEndoInvalidpre(:,2)) % 
[H,P,CI,STATS] = ttest(vTPJEndoValidpost(:,2),vTPJEndoInvalidpost(:,2)) % 
[H,P,CI,STATS] = ttest(vTPJExoValidpre(:,2),vTPJExoInvalidpre(:,2)) % 
[H,P,CI,STATS] = ttest(vTPJExoValidpost(:,2),vTPJExoInvalidpost(:,2)) % 

%% T-Tests analyses for Ins

clc
for iSub = 1:size(obs,2)
    vTPJEndoValidpre(iSub,:) = dataEndo{iSub}.perfValidpre(3,:);
    vTPJEndoInvalidpre(iSub,:) = dataEndo{iSub}.perfInvalidpre(3,:);
    vTPJExoValidpre(iSub,:) = dataExo{iSub}.perfValidpre(3,:);
    vTPJExoInvalidpre(iSub,:) = dataExo{iSub}.perfInvalidpre(3,:);
    vTPJEndoValidpost(iSub,:) = dataEndo{iSub}.perfValidpost(3,:);
    vTPJEndoInvalidpost(iSub,:) = dataEndo{iSub}.perfInvalidpost(3,:);
    vTPJExoValidpost(iSub,:) = dataExo{iSub}.perfValidpost(3,:);
    vTPJExoInvalidpost(iSub,:) = dataExo{iSub}.perfInvalidpost(3,:);
end

[H,P,CI,STATS] = ttest(vTPJEndoValidpre(:,2),vTPJEndoInvalidpre(:,2)) % 
[H,P,CI,STATS] = ttest(vTPJEndoValidpost(:,2),vTPJEndoInvalidpost(:,2)) % 
[H,P,CI,STATS] = ttest(vTPJExoValidpre(:,2),vTPJExoInvalidpre(:,2)) % 
[H,P,CI,STATS] = ttest(vTPJExoValidpost(:,2),vTPJExoInvalidpost(:,2)) % 


