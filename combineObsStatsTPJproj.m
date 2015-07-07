% combineObsStatsTPJproj.m
%
%      usage: combineObsStatsTPJproj
%         by: laura
%       date: 07/07/15

%% set conditions to run
obs = {'nms' 'mr' 'id' 'rd' 'co'}; %
whichAnal = 'TPJ'; % 'first' or 'TPJ'
roiName = {'r_vTPJ','r_pTPJ'};

%% Load data over observers for each ROI - ENDO
countROI = 0;
endo{size(roiName,2)} = [];
for iROI = roiName
    %% Set variables
    countObs = 0;
    countROI = countROI + 1;
    if strcmp(whichAnal,'TPJ')
        ehdr_endo = zeros(size(obs,2),8);
    elseif strcmp(whichAnal,'first')
        ehdr_endo = zeros(size(obs,2),12);
    end
    for iObs = obs
        countObs = countObs + 1;
        %% Set directory
        dir = ['/Volumes/DRIVE1/DATA/laura/MRI/' iObs{:} '/' iObs{:} 'Merge'];
        cd(dir)
        %% set parameters fro mrTool
        % open a new view
        v = newView;
        % get attention condition
        v = viewSet(v, 'curGroup', 'endo');
        %% average across voxels within each ROI
        [v,x,~] = dnoiseEndoExo(v, whichAnal, iROI{:}, 'w-endo');
        ehdr_endo(countObs,:) = x{1};
        %% Quit mrLoadRet to open a new view
        mrQuit()
    end
    endo{countROI} = ehdr_endo;
end

%% Load data over observers for each ROI - EXO
countROI = 0;
exo{size(roiName,2)} = [];
for iROI = roiName
    %% Set variables
    countObs = 0;
    countROI = countROI + 1;
    if strcmp(whichAnal,'TPJ')
        ehdr_exo = zeros(size(obs,2),8);
    elseif strcmp(whichAnal,'first')
        ehdr_exo = zeros(size(obs,2),12);
    end
    for iObs = obs
        countObs = countObs + 1;
        %% Set directory
        dir = ['/Volumes/DRIVE1/DATA/laura/MRI/' iObs{:} '/' iObs{:} 'Merge'];
        cd(dir)
        %% set parameters fro mrTool
        % open a new view
        v = newView;
        % get attention condition
        v = viewSet(v, 'curGroup', 'exo');
        %% average across voxels within each ROI
        [v,x,~] = dnoiseEndoExo(v, whichAnal, iROI{:}, 'w-exo');
        ehdr_exo(countObs,:) = x{1};
        %% Quit mrLoadRet to open a new view
        mrQuit()
    end
    exo{countROI} = ehdr_exo;
end

%% Average data across observers
avgEndo{size(roiName,2)} = [];
avgExo{size(roiName,2)} = [];
steEndo{size(roiName,2)} = [];
steExo{size(roiName,2)} = [];
countROI = 0;
for iROI = roiName
    countROI = countROI + 1;
    avgEndo{countROI} = nanmean(endo{countROI});
    avgExo{countROI} = nanmean(exo{countROI});
    steEndo{countROI} = nanstd(endo{countROI})./size(obs,2);
    steExo{countROI} = nanstd(exo{countROI})./size(obs,2);
end

%% Plot the data for Valid and Invalid correct trials, roi-by-roi
if strcmp(whichAnal,'TPJ')
    %% Statistics
    countROI = 0;
    exoCorrect = {};exoIncorrect = {};endoCorrect = {};endoIncorrect = {};
    for iROI = roiName
        countROI = countROI + 1;
        exoCorrect{countROI} = exo{countROI}(:,4:5);
        exoIncorrect{countROI} = exo{countROI}(:,6:7);
        endoCorrect{countROI} = endo{countROI}(:,4:5);
        endoIncorrect{countROI} = endo{countROI}(:,6:7);
        
        exoVI{countROI} = cat(3,exoCorrect{countROI},exoIncorrect{countROI});
        exoVI{countROI} = mean(exoVI{countROI},3);
        endoVI{countROI} = cat(3,endoCorrect{countROI},endoIncorrect{countROI});
        endoVI{countROI} = mean(endoVI{countROI},3);
    end
    
    %%% Averaging correct and incorrect trials
    TheRoiToAnalyze = 1;
    % Dep var
    matData(:,1) = [exoVI{TheRoiToAnalyze}(:);endoVI{TheRoiToAnalyze}(:)];
    % Ind var 1 = Endo vs. Exo
    matData(1:10,2) = 1;matData(11:end,2) = 2;
    % Ind var 1 = Valid vs. Invalid
    matData(1:5,3) = 1;matData(6:10,3) = 2;matData(11:15,3) = 1;matData(16:end,3) = 2;
    countObs = 0;
    for iObs = 1:size(matData,1)
        countObs = countObs + 1;
        matData(iObs,4) = countObs;
        if countObs == 5;countObs = 0;end
    end
    RMAOV2(matData)
    
    %%% On correct trials
    TheRoiToAnalyze = 2;
    matData(:,1) = [exoCorrect{TheRoiToAnalyze}(:);endoCorrect{TheRoiToAnalyze}(:)];
    matData(1:10,2) = 1;matData(11:end,2) = 2;
    matData(1:5,3) = 1;matData(6:10,3) = 2;matData(11:15,3) = 1;matData(16:end,3) = 2;
    countObs = 0;
    for iObs = 1:size(matData,1)
        countObs = countObs + 1;
        matData(iObs,4) = countObs;
        if countObs == 5;countObs = 0;end
    end
    RMAOV2(matData)
    
    % t-tests used as post-hoc comparisons
    TheRoiToAnalyze = 2;
    [H,P,CI,STATS] = ttest(exoCorrect{TheRoiToAnalyze}(:,1),exoCorrect{TheRoiToAnalyze}(:,2),'tail','left') %V vs. I
    [H,P,CI,STATS] = ttest(endoCorrect{TheRoiToAnalyze}(:,1),endoCorrect{TheRoiToAnalyze}(:,2),'tail','left') %V vs. I
    
    
    %%% On incorrect trials
    matData(:,1) = [exoIncorrect{TheRoiToAnalyze}(:);endoIncorrect{TheRoiToAnalyze}(:)];
    matData(1:10,2) = 1;matData(11:end,2) = 2;
    matData(1:5,3) = 1;matData(6:10,3) = 2;matData(11:15,3) = 1;matData(16:end,3) = 2;
    countObs = 0;
    for iObs = 1:size(matData,1)
        countObs = countObs + 1;
        matData(iObs,4) = countObs;
        if countObs == 5;countObs = 0;end
    end
    RMAOV2(matData)
    
    %% Plot the data
    TheRoiToPlot = 2;
    if TheRoiToPlot == 1
        roitoPlot = 'vTPJ';
    elseif TheRoiToPlot == 2
        roitoPlot = 'pTPJ';
    end
        
    toplot = [avgExo{TheRoiToPlot}(4:5) avgEndo{TheRoiToPlot}(4:5)];
    stetoplot = [steExo{TheRoiToPlot}(4:5) steEndo{TheRoiToPlot}(4:5)];
    
    % set boudaries
    yMax = ceil(10*(max(toplot+max(stetoplot))))/10;
    yMin = min(0, floor(10*(min(toplot)-max(stetoplot)))/10);
    
    % create a new figure
    smartfig('Valid-Invalid'); clf;
    % title  for the figure based on the ROI
    % suptitle('Valid vs. Invalid - correct trials');
    suptitle(sprintf('Valid vs. Invalid - correct trials (%s)', roitoPlot));
    
    cla
    bar(toplot, 'facecolor', 'k');
    hold on
    errorbar(toplot, stetoplot, 'ko');
    
    yaxis([yMin yMax]);
    axis square;box off;
    set(gca,'xTickLabel',{'Valid-Exo' 'Invalid-Exo' 'Valid-Endo' 'Invalid-Endo'},'FontSize',14);
    ylabel('fMRI resp (% chg img intensity)');
    
    print('-djpeg','-r500',['/Local/Users/purpadmin/Desktop/Laura/validInvalid_r' roitoPlot '_correct']);
    
    toplot = [avgExo{TheRoiToPlot}(6:7) avgEndo{TheRoiToPlot}(6:7)];
    stetoplot = [steExo{TheRoiToPlot}(6:7) steEndo{TheRoiToPlot}(6:7)];
    
    % set boudaries
    yMax = ceil(10*(max(toplot+max(stetoplot))))/10;
    yMin = min(0, floor(10*(min(toplot)-max(stetoplot)))/10);
    
    % create a new figure
    smartfig('Valid-Invalid'); clf;
    % title  for the figure based on the ROI
    % suptitle('Valid vs. Invalid - correct trials');
    suptitle(sprintf('Valid vs. Invalid - incorrect trials (%s)', roitoPlot));
    
    cla
    bar(toplot, 'facecolor', 'k');
    hold on
    errorbar(toplot, stetoplot, 'ko');
    
    yaxis([yMin yMax]);
    axis square;box off;
    set(gca,'xTickLabel',{'Valid-Exo' 'Invalid-Exo' 'Valid-Endo' 'Invalid-Endo'},'FontSize',14);
    ylabel('fMRI resp (% chg img intensity)');
    
    print('-djpeg','-r500',['/Local/Users/purpadmin/Desktop/Laura/validInvalid_r' roitoPlot '_incorrect']);
    
end

%% Plot the data for Valid and Invalid correct trials, roi-by-roi
if strcmp(whichAnal,'first')
    % Valid-Pre-Left % Invalid-Pre-Left % Valid-Post-Left % Invalid-Post-Left
    % Valid-Pre-Right % Invalid-Pre-Right % Valid-Post-Right % Invalid-Post-Right
    % CueOnly-Left % CueOnly-Right % Blank % Blink
    
    %% Statistics
    countROI = 0;
    exoCorrect = {};exoIncorrect = {};endoCorrect = {};endoIncorrect = {};
    for iROI = roiName
        countROI = countROI + 1;
        exoLeft{countROI} = exo{countROI}(:,1:4);
        exoRight{countROI} = exo{countROI}(:,5:8);
        endoLeft{countROI} = endo{countROI}(:,1:4);
        endoRight{countROI} = endo{countROI}(:,5:8);
        
        exoAll{countROI} = cat(3,exoLeft{countROI},exoRight{countROI});
        exoAll{countROI} = mean(exoAll{countROI},3);
        endoAll{countROI} = cat(3,endoLeft{countROI},endoRight{countROI});
        endoAll{countROI} = mean(endoAll{countROI},3);
    end
    
    %%% Averaging correct and incorrect trials
    TheRoiToAnalyze = 2;
    % Dep Variable
    matData(:,1) = [exoAll{TheRoiToAnalyze}(:);endoAll{TheRoiToAnalyze}(:)];
    % Ind var 1 = Endo vs. Exo
    matData(1:20,2) = 1;matData(21:end,2) = 2;
    % Ind var 2 = Valid vs. Invalid
    matData(1:5,3) = 1;matData(6:10,3) = 2;matData(11:15,3) = 1;matData(16:20,3) = 2;
    matData(21:25,3) = 1;matData(26:30,3) = 2;matData(31:35,3) = 1;matData(36:40,3) = 2;
    % Ind var 3 = Pre vs. Post
    matData(1:10,4) = 1;matData(11:20,4) = 2;matData(21:30,4) = 1;matData(31:40,4) = 2;
    % Obs
    countObs = 0;
    for iObs = 1:size(matData,1)
        countObs = countObs + 1;
        matData(iObs,5) = countObs;
        if countObs == 5;countObs = 0;end
    end
    RMAOV33(matData)
    
    % 2-way anova combining PreV, PreI, PostV and PostI in 1 factor, separately for exo and endo
    matData = [];
    TheRoiToAnalyze = 1;
    matData(:,1) = [exoAll{TheRoiToAnalyze}(:);endoAll{TheRoiToAnalyze}(:)];
    % Ind var 1 = Endo vs. Exo
    matData(1:20,2) = 1;matData(21:end,2) = 2;
    % Ind var 2 = Cue type
    matData(1:5,3) = 1;matData(6:10,3) = 2;matData(11:15,3) = 3;matData(16:20,3) = 4;
    matData(21:25,3) = 1;matData(26:30,3) = 2;matData(31:35,3) = 3;matData(36:40,3) = 4;
    countObs = 0;
    for iObs = 1:size(matData,1)
        countObs = countObs + 1;
        matData(iObs,4) = countObs;
        if countObs == 5;countObs = 0;end
    end
    RMAOV2(matData)
    
    % t-tests used as post-hoc comparisons
    TheRoiToAnalyze = 1;
    [H,P,CI,STATS] = ttest(exoAll{TheRoiToAnalyze}(:,1),exoAll{TheRoiToAnalyze}(:,2),'tail','left') %PreV vs. PreI
    [H,P,CI,STATS] = ttest(exoAll{TheRoiToAnalyze}(:,3),exoAll{TheRoiToAnalyze}(:,4),'tail','left') %PostV vs. PostI
    [H,P,CI,STATS] = ttest(endoAll{TheRoiToAnalyze}(:,1),endoAll{TheRoiToAnalyze}(:,2),'tail','left') %PreV vs. PreI
    [H,P,CI,STATS] = ttest(endoAll{TheRoiToAnalyze}(:,3),endoAll{TheRoiToAnalyze}(:,4),'tail','left') %PostV vs. PostI
    
    
    %%% BOTH HEMI
    toplotExo = mean([avgExo{end}(1:4);avgExo{end}(5:8)]);
    toplotEndo = mean([avgEndo{end}(1:4);avgEndo{end}(5:8)]);
    stetoplotExo = sqrt(steExo{end}(1:4).^2+steExo{end}(5:8).^2);
    stetoplotEndo = sqrt(steEndo{end}(1:4).^2+steEndo{end}(5:8).^2);
    
    % set boudaries
    yMax = ceil(10*(max(toplotEndo+max(stetoplotEndo))))/10;
    yMin = min(0, floor(10*(min(toplotEndo)-max(stetoplotEndo)))/10);
    
    % create a new figure
    smartfig('Valid-Invalid'); clf;
    % title  for the figure based on the ROI
    % suptitle('Valid vs. Invalid - correct trials');
    suptitle(['right ' roitoPlot{:}]);
    
    subplot(1,2,1)
    cla
    bar(toplotExo, 'facecolor', 'k');
    hold on
    errorbar(toplotExo, stetoplotExo, 'ko');
    
    yaxis([yMin yMax]);
    xaxis([0 5]);
    axis square;box off;
    set(gca,'xTickLabel',{'Pre_V' 'Pre_I' 'Post_V' 'Post_I'},'FontSize',14);
    ylabel('fMRI resp (% chg img intensity)');
    title('Exogenous attention','FontSize',14)
    
    subplot(1,2,2)
    cla
    bar(toplotEndo, 'facecolor', 'k');
    hold on
    errorbar(toplotEndo, stetoplotEndo, 'ko');
    
    yaxis([yMin yMax]);
    xaxis([0 5]);
    axis square;box off;
    set(gca,'xTickLabel',{'Pre_V' 'Pre_I' 'Post_V' 'Post_I'},'FontSize',14);
    ylabel('fMRI resp (% chg img intensity)');
    title('Endogenous attention','FontSize',14)
    
    print('-djpeg','-r500',['/Local/Users/purpadmin/Desktop/Laura/prePost_r' roitoPlot{:}]);
    
    
    %         %%% LEFT HEMI
    %         toplotExo = avgExo{end}(1:4);
    %         toplotEndo = avgEndo{end}(1:4);
    %         stetoplotExo = steExo{end}(1:4);
    %         stetoplotEndo = steEndo{end}(1:4);
    %
    %         % set boudaries
    %         yMax = ceil(10*(max(toplotEndo+max(stetoplotEndo))))/10;
    %         yMin = min(0, floor(10*(min(toplotEndo)-max(stetoplotEndo)))/10);
    %
    %         % create a new figure
    %         smartfig('Valid-Invalid'); clf;
    %         % title  for the figure based on the ROI
    %         % suptitle('Valid vs. Invalid - correct trials');
    %         suptitle('Left Hemifield - (right vTPJ)');
    %
    %         subplot(1,2,1)
    %         cla
    %         bar(toplotExo, 'facecolor', 'k');
    %         hold on
    %         errorbar(toplotExo, stetoplotExo, 'ko');
    %
    %         yaxis([yMin yMax]);
    %         xaxis([0 5])
    %         axis square;box off;
    %         set(gca,'xTickLabel',{'Pre_V' 'Pre_I' 'Post_V' 'Post_I'},'FontSize',14);
    %         ylabel('fMRI resp (% chg img intensity)');
    %         title('Exogenous attention','FontSize',14)
    %
    %         subplot(1,2,2)
    %         cla
    %         bar(toplotEndo, 'facecolor', 'k');
    %         hold on
    %         errorbar(toplotEndo, stetoplotEndo, 'ko');
    %
    %         yaxis([yMin yMax]);
    %         xaxis([0 5])
    %         axis square;box off;
    %         set(gca,'xTickLabel',{'Pre_V' 'Pre_I' 'Post_V' 'Post_I'},'FontSize',14);
    %         ylabel('fMRI resp (% chg img intensity)');
    %         title('Endogenous attention','FontSize',14)
    %
    %         print('-djpeg','-r500','/Local/Users/purpadmin/Desktop/Laura/leftHemi_validInvalid_rvTPJ');
    %
    %         %%% RIGHT HEMI
    %         toplotExo = avgExo{end}(5:8);
    %         toplotEndo = avgEndo{end}(5:8);
    %         stetoplotExo = steExo{end}(5:8);
    %         stetoplotEndo = steEndo{end}(5:8);
    %
    %         % set boudaries
    %         yMax = ceil(10*(max(toplotEndo+max(stetoplotEndo))))/10;
    %         yMin = min(0, floor(10*(min(toplotEndo)-max(stetoplotEndo)))/10);
    %
    %         % create a new figure
    %         smartfig('Valid-Invalid'); clf;
    %         % title  for the figure based on the ROI
    %         % suptitle('Valid vs. Invalid - correct trials');
    %         suptitle('Right Hemifield - (right vTPJ)');
    %
    %         subplot(1,2,1)
    %         cla
    %         bar(toplotExo, 'facecolor', 'k');
    %         hold on
    %         errorbar(toplotExo, stetoplotExo, 'ko');
    %
    %         yaxis([yMin yMax]);
    %         xaxis([0 5])
    %         axis square;box off;
    %         set(gca,'xTickLabel',{'Pre_V' 'Pre_I' 'Post_V' 'Post_I'},'FontSize',14);
    %         ylabel('fMRI resp (% chg img intensity)');
    %         title('Exogenous attention','FontSize',14)
    %
    %         subplot(1,2,2)
    %         cla
    %         bar(toplotEndo, 'facecolor', 'k');
    %         hold on
    %         errorbar(toplotEndo, stetoplotEndo, 'ko');
    %
    %         yaxis([yMin yMax]);
    %         xaxis([0 5])
    %         axis square;box off;
    %         set(gca,'xTickLabel',{'Pre_V' 'Pre_I' 'Post_V' 'Post_I'},'FontSize',14);
    %         ylabel('fMRI resp (% chg img intensity)');
    %         title('Endogenous attention','FontSize',14)
    %
end