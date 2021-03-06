% exoCombined.m
%
%      usage: exoCombined
%         by: eli & laura
%       date: 02/20/15

%% set conditions to run
obs = {'nms' 'mr' 'id' 'rd'}; %
whichAnal = 'first'; % 'first' or 'TPJ'
plotBothHemi = 1;
roiName = {'r_vTPJ'};
roitoPlot = {'vTPJ'};

%% Load data over observers for each ROI - EXO
countROI = 0;
exo{size(roiName,2)} = [];
for iROI = roiName
    %% Set variables
    countObs = 0;
    countROI = countROI + 1;
    if strcmp(whichAnal,'TPJ')
        ehdr_exo = zeros(size(obs,2),8);
    elseif strcmp(whichAnal,'TPJ')
        ehdr_exo = zeros(size(obs,2),12);
    end
    for iObs = obs
        countObs = countObs + 1;
        %% Set directory
        if strcmp(iObs{:},'rd') || strcmp(iObs{:},'co')
            dir = ['/Volumes/DRIVE1/DATA/laura/MRI/' iObs{:} '/' iObs{:} 'Merge'];
        else
            dir = ['/Local/Users/purpadmin/Laura/MRI/Data/' iObs{:} '/' iObs{:} 'Merge'];
        end
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
avgExo{size(roiName,2)} = [];
steExo{size(roiName,2)} = [];
countROI = 0;
for iROI = roiName
    countROI = countROI + 1;
    avgExo{countROI} = mean(exo{countROI});
    steExo{countROI} = std(exo{countROI})./size(obs,2);
end

%% Plot the data for Valid and Invalid correct trials, roi-by-roi
if strcmp(whichAnal,'TPJ')
    toplot = avgExo{end}(4:5);
    stetoplot = steExo{end}(4:5);
    
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
    set(gca,'xTickLabel',{'Valid-Exo' 'Invalid-Exo'},'FontSize',14);
    ylabel('fMRI resp (% chg img intensity)');
    
    %         print('-djpeg','-r500',['/Local/Users/purpadmin/Desktop/Laura/validInvalid_r' roitoPlot{1}]);
end

%% Plot the data for Valid and Invalid correct trials, roi-by-roi
if strcmp(whichAnal,'first')
    %%% AVERAGE OF BOTH HEMI
    toplotExo = [avgExo{end}(1:4);avgExo{end}(5:8)];
    stetoplotExo = [steExo{end}(1:4);avgExo{end}(5:8)];
    
    toplotExo = mean(toplotExo,1);
    stetoplotExo = sqrt(stetoplotExo(1,:).^2+stetoplotExo(2,:).^2);
    
    % set boudaries
    yMax = ceil(10*(max(toplotExo+max(stetoplotExo))))/10;
    yMin = min(0, floor(10*(min(toplotExo)-max(stetoplotExo)))/10);
    
    % create a new figure
    smartfig('Valid-Invalid'); clf;
    % title  for the figure based on the ROI
    % suptitle('Valid vs. Invalid - correct trials');
    suptitle(sprintf('Both Hemifield - %s', roitoPlot{end}));
    
    cla
    bar(toplotExo, 'facecolor', 'k');
    hold on
    errorbar(toplotExo, stetoplotExo, 'ko');
    
    yaxis([yMin yMax]);
    axis square;box off;
    set(gca,'xTickLabel',{'Pre_V' 'Pre_I' 'Post_V' 'Post_I'},'FontSize',14);
    ylabel('fMRI resp (% chg img intensity)');
    title('Exogenous attention','FontSize',14)
    
    %         print('-djpeg','-r500','/Local/Users/purpadmin/Desktop/Laura/leftHemi_validInvalid_rvTPJ');
    
    if plotBothHemi
        %%% LEFT HEMI
        toplotExo = avgExo{end}(1:4);
        stetoplotExo = steExo{end}(1:4);
        
        % set boudaries
        yMax = ceil(10*(max(toplotExo+max(stetoplotExo))))/10;
        yMin = min(0, floor(10*(min(toplotExo)-max(stetoplotExo)))/10);
        
        % create a new figure
        smartfig('Valid-Invalid'); clf;
        % title  for the figure based on the ROI
        % suptitle('Valid vs. Invalid - correct trials');
        suptitle(sprintf('Left Hemifield - %s', roitoPlot{end}));
        
        cla
        bar(toplotExo, 'facecolor', 'k');
        hold on
        errorbar(toplotExo, stetoplotExo, 'ko');
        
        yaxis([yMin yMax]);
        axis square;box off;
        set(gca,'xTickLabel',{'Pre_V' 'Pre_I' 'Post_V' 'Post_I'},'FontSize',14);
        ylabel('fMRI resp (% chg img intensity)');
        title('Exogenous attention','FontSize',14)
        
        %         print('-djpeg','-r500','/Local/Users/purpadmin/Desktop/Laura/leftHemi_validInvalid_rvTPJ');
        
        %%% RIGHT HEMI
        toplotExo = avgExo{end}(5:8);
        stetoplotExo = steExo{end}(5:8);
        
        % create a new figure
        smartfig('Valid-Invalid'); clf;
        % title  for the figure based on the ROI
        % suptitle('Valid vs. Invalid - correct trials');
        suptitle(sprintf('Right Hemifield - %s', roitoPlot{end}));
        
        cla
        bar(toplotExo, 'facecolor', 'k');
        hold on
        errorbar(toplotExo, stetoplotExo, 'ko');
        
        yaxis([yMin yMax]);
        axis square;box off;
        set(gca,'xTickLabel',{'Pre_V' 'Pre_I' 'Post_V' 'Post_I'},'FontSize',14);
        ylabel('fMRI resp (% chg img intensity)');
        title('Exogenous attention','FontSize',14)
        
        %         print('-djpeg','-r500','/Local/Users/purpadmin/Desktop/Laura/rightHemi_validInvalid_rvTPJ');
    end
end