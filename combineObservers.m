% combineObservers.m
%
%      usage: combineObservers
%         by: eli & laura
%       date: 02/20/15

%% set conditions to run
obs = {'nms' 'mr' 'id'}; % 'rd'
whichAnal = 'TPJ'; % 'first' or 'visualCortex' or 'TPJ'
% roiName = {'r_v1','r_v2d','r_v3d','r_v3a','r_v3b','r_v4','r_vo1', 'r_vo2','r_v7',...
%     'l_v1','l_v2d', 'l_v3d','l_v3a','l_v3b','l_v4','l_vo1', 'l_vo2','l_v7','r_vTPJ'};
roiName = {'r_vTPJ'};
% roitoPlot = {'v1','v2d','v3d','v3a','v3b','v4','vo1', 'vo2','v7','vTPJ'};
roitoPlot = {'vTPJ'};
% roiName = {'r_vo1','l_vo1'};
% roitoPlot = {'vo1'};
numRoi = 9; % without counting rTPJ
tpjOn = 1;  % 1 if plotting rTPJ
%{'l_v1', 'l_v4', 'l_vo1', 'l_vo2', 'l_v2d', 'l_v3d', 'l_v3a', 'l_v3b', 'l_lo1', 'l_lo2','l_v7','l_ips1','l_ips2','l_ips3','l_ips4',...
%'r_v1', 'r_v4', 'r_vo1', 'r_vo2', 'r_v2d', 'r_v2d', 'r_v3a', 'r_v3b', 'r_lo1', 'r_lo2','r_v7','r_ips1','r_ips2','r_ips3','r_ips4',...
%'r_vTPJ'};

%% Load data over observers for each ROI - ENDO
countROI = 0;
endo{size(roiName,2)} = [];
for iROI = roiName
    %% Set variables
    countObs = 0;
    countROI = countROI + 1;
    ehdr_endo = zeros(size(obs,2),8);
    for iObs = obs
        countObs = countObs + 1;
        %% Set directory
        dir = ['/Local/Users/purpadmin/Laura/MRI/Data/' iObs{:} '/' iObs{:} 'Merge'];
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
    ehdr_exo = zeros(size(obs,2),8);
    for iObs = obs
        countObs = countObs + 1;
        %% Set directory
        dir = ['/Local/Users/purpadmin/Laura/MRI/Data/' iObs{:} '/' iObs{:} 'Merge'];
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
    avgEndo{countROI} = mean(endo{countROI});
    avgExo{countROI} = mean(exo{countROI});
    steEndo{countROI} = std(endo{countROI})./size(obs,2);
    steExo{countROI} = std(exo{countROI})./size(obs,2);
end

%% Plot the data for Valid and Invalid correct trials, roi-by-roi
if strcmp(whichAnal,'TPJ')
%     for iROI = 1:numRoi
%         toplot = [mean([avgExo{iROI}(4:5);avgExo{iROI+numRoi}(4:5)]) mean([avgEndo{iROI}(4:5);avgEndo{iROI+numRoi}(4:5)])];
%         stetoplot = [sqrt(((steExo{iROI}(4:5)).^2)+((steExo{iROI+numRoi}(4:5)).^2)) sqrt(((steEndo{iROI}(4:5)).^2)+((steEndo{iROI+numRoi}(4:5)).^2))];
%         
%         % set boudaries
%         yMax = ceil(10*(max(toplot+max(stetoplot))))/10;
%         yMin = min(0, floor(10*(min(toplot)-max(stetoplot)))/10);
%         
%         % create a new figure
%         smartfig('Valid-Invalid'); clf;
%         % title  for the figure based on the ROI
%         % suptitle('Valid vs. Invalid - correct trials');
%         suptitle(sprintf('Valid vs. Invalid - correct trials (%s)', roitoPlot{iROI}));
%         
%         cla
%         bar(toplot, 'facecolor', 'k');
%         hold on
%         errorbar(toplot, stetoplot, 'ko');
%         
%         yaxis([yMin yMax]);
%         axis square;box off;
%         set(gca,'xTickLabel',{'Valid-Exo' 'Invalid-Exo' 'Valid-Endo' 'Invalid-Endo'},'FontSize',14);
%         ylabel('fMRI resp (% chg img intensity)');
%         
%         print('-djpeg','-r500',['/Local/Users/purpadmin/Desktop/Laura/validInvalid_' roitoPlot{iROI}]);
%     end
    if tpjOn
        toplot = [avgExo{end}(4:5) avgEndo{end}(4:5)];
        stetoplot = [steExo{end}(4:5) steEndo{end}(4:5)];
        
        % set boudaries
        yMax = ceil(10*(max(toplot+max(stetoplot))))/10;
        yMin = min(0, floor(10*(min(toplot)-max(stetoplot)))/10);
        
        % create a new figure
        smartfig('Valid-Invalid'); clf;
        % title  for the figure based on the ROI
        % suptitle('Valid vs. Invalid - correct trials');
        suptitle(sprintf('Valid vs. Invalid - correct trials (%s)', roitoPlot{end}));
        
        cla
        bar(toplot, 'facecolor', 'k');
        hold on
        errorbar(toplot, stetoplot, 'ko');
        
        yaxis([yMin yMax]);
        axis square;box off;
        set(gca,'xTickLabel',{'Valid-Exo' 'Invalid-Exo' 'Valid-Endo' 'Invalid-Endo'},'FontSize',14);
        ylabel('fMRI resp (% chg img intensity)');
        
        print('-djpeg','-r500',['/Local/Users/purpadmin/Desktop/Laura/validInvalid_r' roitoPlot{1}]);
    end
end

%% Plot the data for Pre vs. Post cueing, roi-by-roi
if strcmp(whichAnal,'visualCortex')
    for iROI = 1:numRoi
        % Contralateral activity
        toplot = [mean([avgExo{iROI}(1:2);avgExo{iROI+numRoi}(3:4)]) mean([avgEndo{iROI}(1:2);avgEndo{iROI+numRoi}(3:4)])];
        stetoplot = [sqrt(((steExo{iROI}(1:2)).^2)+((steExo{iROI+numRoi}(3:4)).^2)) sqrt(((steEndo{iROI}(1:2)).^2)+((steEndo{iROI+numRoi}(3:4)).^2))];
        
        % set boudaries
        yMax = ceil(10*(max(toplot+max(stetoplot))))/10;
        yMin = min(0, floor(10*(min(toplot)-max(stetoplot)))/10);
        
        % set colors
        myColors{1}=[10 55 191]/255;
        myColors{2}=[191 0 0]/255;
        myColors{3}=[207 219 255]/255;
        myColors{4}=[255 204 204]/255;
        
        % create a new figure
        smartfig('Pre-Post'); clf;
        % title  for the figure based on the ROI
        % suptitle('Valid vs. Invalid - correct trials');
        suptitle(sprintf('Pre vs. Post-Cueing - Contra (%s)', roitoPlot{iROI}));
        
        cla
        bar(toplot, 'facecolor', 'k');
        hold on
        errorbar(toplot, stetoplot, 'ko');
        
        yaxis([yMin yMax]);
        axis square;box off;
        set(gca,'xTickLabel',{'Pre-Exo' 'Post-Exo' 'Pre-Endo' 'Post-Endo'},'FontSize',14);
        ylabel('fMRI resp (% chg img intensity)');
        
        print('-djpeg','-r500',['/Local/Users/purpadmin/Desktop/Laura/prePost_' roitoPlot{iROI}]);
        
        % Ipsilateral activity
        toplot_ipsi_exo = [toplot(1:2) mean([avgExo{iROI}(3:4);avgExo{iROI+numRoi}(1:2)])];
        stetoplot_ipsi_exo = [stetoplot(1:2) sqrt(((steExo{iROI}(3:4)).^2)+((steExo{iROI+numRoi}(1:2)).^2))];
        toplot_ipsi_endo = [toplot(3:4) mean([avgEndo{iROI}(3:4);avgEndo{iROI+numRoi}(1:2)])];
        stetoplot_ipsi_endo = [stetoplot(3:4) sqrt(((steEndo{iROI}(3:4)).^2)+((steEndo{iROI+numRoi}(1:2)).^2))];
        
        % create a new figure
        smartfig('Pre-Post'); clf;
        % title  for the figure based on the ROI
        % suptitle('Valid vs. Invalid - correct trials');
        suptitle(sprintf('Pre vs. Post-Cueing (%s)', roitoPlot{iROI}));
        
        cla
        subplot(1,2,1)
        bar(toplot_ipsi_exo, 'facecolor', 'k');
        hold on
        errorbar(toplot_ipsi_exo, stetoplot_ipsi_exo, 'ko');
        
        yaxis([yMin yMax]);
        xaxis([0 5]);
        axis square;box off;
        set(gca,'xTickLabel',{'Pre-C' 'Post-C' 'Pre-I' 'Post-I'},'FontSize',14);
        ylabel('fMRI resp (% chg img intensity)');
        title('Exogenous attention')
        
        subplot(1,2,2)
        bar(toplot_ipsi_endo, 'facecolor', 'k');
        hold on
        errorbar(toplot_ipsi_endo, stetoplot_ipsi_endo, 'ko');
        
        yaxis([yMin yMax]);
        axis square;box off;
        set(gca,'xTickLabel',{'Pre-C' 'Post-C' 'Pre-I' 'Post-I'},'FontSize',14);
        ylabel('fMRI resp (% chg img intensity)');
        title('Endogenous attention')
        
        print('-djpeg','-r500',['/Local/Users/purpadmin/Desktop/Laura/contraIpsi_prePost_' roitoPlot{iROI}]);
    end
    if tpjOn
        toplot = [avgExo{end}(1:2) avgEndo{end}(1:2)];
        stetoplot = [steExo{end}(1:2) steEndo{end}(1:2)];
        
        % set boudaries
        yMax = ceil(10*(max(toplot+max(stetoplot))))/10;
        yMin = min(0, floor(10*(min(toplot)-max(stetoplot)))/10);
        
        % create a new figure
        smartfig('Pre-Post'); clf;
        % title  for the figure based on the ROI
        % suptitle('Valid vs. Invalid - correct trials');
        suptitle(sprintf('Pre vs. Post-Cueing - correct trials (%s)', roitoPlot{end}));
        
        cla
        bar(toplot, 'facecolor', 'k');
        hold on
        errorbar(toplot, stetoplot, 'ko');
        
        yaxis([yMin yMax]);
        axis square;box off;
        set(gca,'xTickLabel',{'Pre-Exo' 'Post-Exo' 'Pre-Endo' 'Post-Endo'},'FontSize',14);
        ylabel('fMRI resp (% chg img intensity)');
        
        print('-djpeg','-r500','/Local/Users/purpadmin/Desktop/Laura/prePost_rvTPJ');
    end
end

%% Plot the data for Valid and Invalid correct trials, roi-by-roi
if strcmp(whichAnal,'first')
    % Valid-Pre-Left % Invalid-Pre-Left % Valid-Post-Left % Invalid-Post-Left
    % Valid-Pre-Right % Invalid-Pre-Right % Valid-Post-Right % Invalid-Post-Right
    % CueOnly-Left % CueOnly-Right % Blank % Blink
    
    for iROI = 1:numRoi
        toplotExo = mean([avgExo{iROI}(1:4);avgExo{iROI+numRoi}(1:4)]);
        toplotEndo = mean([avgEndo{iROI}(1:4);avgEndo{iROI+numRoi}(1:4)]);
        stetoplotExo = sqrt(((steExo{iROI}(1:4)).^2)+((steExo{iROI+numRoi}(1:4)).^2));
        stetoplotEndo = sqrt(((steEndo{iROI}(1:4)).^2)+((steEndo{iROI+numRoi}(1:4)).^2));
        
        % set boudaries
        yMax = ceil(10*(max(toplotEndo+max(stetoplotEndo))))/10;
        yMin = min(0, floor(10*(min(toplotEndo)-max(stetoplotEndo)))/10);
        
        % create a new figure
        smartfig('Valid-Invalid'); clf;
        % title  for the figure based on the ROI
        % suptitle('Valid vs. Invalid - correct trials');
        suptitle(sprintf('%s', roitoPlot{iROI}));
        
        subplot(1,2,1)
        cla
        bar(toplotExo, 'facecolor', 'k');
        hold on
        errorbar(toplotExo, stetoplotExo, 'ko');
        
        yaxis([yMin yMax]);
        axis square;box off;
        title('Exogenous attention','FontSize',14)
        set(gca,'xTickLabel',{'Pre_V' 'Pre_I' 'Post_V' 'Post_I'},'FontSize',14);
        ylabel('fMRI resp (% chg img intensity)');
        
        subplot(1,2,2)
        cla
        bar(toplotEndo, 'facecolor', 'k');
        hold on
        errorbar(toplotEndo, stetoplotEndo, 'ko');
        
        yaxis([yMin yMax]);
        axis square;box off;
        title('Endogenous attention','FontSize',14)
        set(gca,'xTickLabel',{'Pre_V' 'Pre_I' 'Post_V' 'Post_I'},'FontSize',14);
        ylabel('fMRI resp (% chg img intensity)');
        
        print('-djpeg','-r500',['/Local/Users/purpadmin/Desktop/Laura/validInvalidPrePost_' roitoPlot{iROI}]);
    end
    if tpjOn
        %%% LEFTT HEMI
        toplotExo = avgExo{end}(1:4); 
        toplotEndo = avgEndo{end}(1:4);
        stetoplotExo = steExo{end}(1:4);
        stetoplotEndo = steEndo{end}(1:4);
        
        % set boudaries
        yMax = ceil(10*(max(toplotEndo+max(stetoplotEndo))))/10;
        yMin = min(0, floor(10*(min(toplotEndo)-max(stetoplotEndo)))/10);
        
        % create a new figure
        smartfig('Valid-Invalid'); clf;
        % title  for the figure based on the ROI
        % suptitle('Valid vs. Invalid - correct trials');
        suptitle('Left Hemifield - (right vTPJ)');
        
        subplot(1,2,1)
        cla
        bar(toplotExo, 'facecolor', 'k');
        hold on
        errorbar(toplotExo, stetoplotExo, 'ko');
        
        yaxis([yMin yMax]);
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
        axis square;box off;
        set(gca,'xTickLabel',{'Pre_V' 'Pre_I' 'Post_V' 'Post_I'},'FontSize',14);
        ylabel('fMRI resp (% chg img intensity)');
        title('Endogenous attention','FontSize',14)
        
        print('-djpeg','-r500','/Local/Users/purpadmin/Desktop/Laura/leftHemi_validInvalid_rvTPJ');
        
        %%% RIGHT HEMI
        toplotExo = avgExo{end}(5:8); 
        toplotEndo = avgEndo{end}(5:8);
        stetoplotExo = steExo{end}(5:8);
        stetoplotEndo = steEndo{end}(5:8);
        
        % set boudaries
        yMax = ceil(10*(max(toplotEndo+max(stetoplotEndo))))/10;
        yMin = min(0, floor(10*(min(toplotEndo)-max(stetoplotEndo)))/10);
        
        % create a new figure
        smartfig('Valid-Invalid'); clf;
        % title  for the figure based on the ROI
        % suptitle('Valid vs. Invalid - correct trials');
        suptitle('Right Hemifield - (right vTPJ)');
        
        subplot(1,2,1)
        cla
        bar(toplotExo, 'facecolor', 'k');
        hold on
        errorbar(toplotExo, stetoplotExo, 'ko');
        
        yaxis([yMin yMax]);
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
        axis square;box off;
        set(gca,'xTickLabel',{'Pre_V' 'Pre_I' 'Post_V' 'Post_I'},'FontSize',14);
        ylabel('fMRI resp (% chg img intensity)');
        title('Endogenous attention','FontSize',14)
        
        print('-djpeg','-r500','/Local/Users/purpadmin/Desktop/Laura/rightHemi_validInvalid_rvTPJ');
    end
end