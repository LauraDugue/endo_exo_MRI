% endoexoIndexPlot.m
%
%      usage: endoexoIndexPlot()
%         by: eli merriam
%       date: 07/28/14
%    purpose:
%
function retval = endoexoIndexPlot2(baselineCorrect)

% check arguments
if ~any(nargin == [1])
    help endoexoIndexPlot
    return
end

% get listing of all files in analysis directory
fEndo = dir(fullfile('Anal/endo/anal*.mat'));
fExo = dir(fullfile('Anal/exo/anal*.mat'));

% init variables
ehdrEndoC=[]; ehdrEndoI=[]; ehdrExoC=[]; ehdrExoI=[]; endoName=[];exoName=[];
% loop over ROIs, accumulating the beta's from the GLM
for iRoi = 1:length(fEndo)
    % load file from endo analysis
    anal = load(fullfile('Anal/endo/', fEndo(iRoi).name));
    if baselineCorrect
        anal.dGLM = anal.dGLM2;
    end
    % first four resps are 'contralateral' for right hemi ROIs
    if strfind(fEndo(iRoi).name, '_r_')
        ehdrEndoC(:,iRoi) = anal.dGLM.ehdr(1:4);
        ehdrEndoI(:,iRoi) = anal.dGLM.ehdr(5:8);
    elseif strfind(fEndo(iRoi).name, '_l_')
        ehdrEndoC(:,iRoi) = anal.dGLM.ehdr(5:8);
        ehdrEndoI(:,iRoi) = anal.dGLM.ehdr(1:4);
    else
        disp(sprintf('UHOH: Does not match left or right hemisphere'));
        return;
    end
    temp = anal.rois{1}.name;
    temp = fixBadChars(temp, [],{'r_',''});
    temp = fixBadChars(temp, [],{'l_',''});
    temp = fixBadChars(temp, [], {'v3d','v3'});
    temp = fixBadChars(temp, [], {'v2d','v2'});
    endoName{iRoi} = temp;
    
    % load file from exo analysis
    anal = load(fullfile('Anal/exo/', fExo(iRoi).name));
    if baselineCorrect
        anal.dGLM = anal.dGLM2;
    end
    % first four resps are 'contralateral' for right hemi ROIs
    if strfind(fExo(iRoi).name, '_r_')
        ehdrExoC(:,iRoi) = anal.dGLM.ehdr(1:4);
        ehdrExoI(:,iRoi) = anal.dGLM.ehdr(5:8);
    elseif strfind(fExo(iRoi).name, '_l_')
        ehdrExoC(:,iRoi) = anal.dGLM.ehdr(5:8);
        ehdrExoI(:,iRoi) = anal.dGLM.ehdr(1:4);
    else
        disp(sprintf('UHOH: Does not match left or right hemisphere'));
        return;
    end
    temp = anal.rois{1}.name;
    temp = fixBadChars(temp, [],{'r_',''});
    temp = fixBadChars(temp, [],{'l_',''});
    temp = fixBadChars(temp, [], {'v3d','v3'});
    temp = fixBadChars(temp, [], {'v2d','v2'});
    exoName{iRoi} = temp;
    
end

    
roiNames = {'lo1','lo2','mt','v1','v2','v3a','v3b','v3','v4','v7','vo1','vo2','ips1','ips2','ips3','ips4'};

% average over right and left hemipshere betas
aveExoC=[];aveExoI=[];aveEndoC=[];aveEndoI=[];
for iRoi=1:length(roiNames)
    % find indices matching roiNames for exo 
    roiInd = strcmp(exoName, roiNames{iRoi});
    aveExoC(:,iRoi) = mean(ehdrExoC(:,roiInd)');
    aveExoI(:,iRoi) = mean(ehdrExoI(:,roiInd)');
    % find indices matching roiNames for endo
    roiInd = strcmp(endoName, roiNames{iRoi});
    aveEndoC(:,iRoi) = mean(ehdrEndoC(:,roiInd)');
    aveEndoI(:,iRoi) = mean(ehdrEndoI(:,roiInd)');
end

% create valid-invalid and pre-post index plots
endoVI = ( mean(aveEndoC([1 3],:)) - mean(aveEndoC([2 4],:)) ) ./ ( mean(aveEndoC([1 3],:)) + mean(aveEndoC([2 4],:)) );
endoPP = ( mean(aveEndoC([1 2],:)) - mean(aveEndoC([3 4],:)) ) ./ ( mean(aveEndoC([1 2],:)) + mean(aveEndoC([3 4],:)) );
exoVI = ( mean(aveExoC([1 3],:)) - mean(aveExoC([2 4],:)) ) ./ ( mean(aveExoC([1 3],:)) + mean(aveExoC([2 4],:)) );
exoPP = ( mean(aveExoC([1 2],:)) - mean(aveExoC([3 4],:)) ) ./ ( mean(aveExoC([1 2],:)) + mean(aveExoC([3 4],:)) );

smartfig('indindplot', 'reuse'); clf; hold on;
for iRoi = 1:length(roiNames);
    line([endoVI(iRoi) exoVI(iRoi)], [endoPP(iRoi) exoPP(iRoi)], 'color', [.5 .5 .5]);
    h1 = text(endoVI(iRoi), endoPP(iRoi), upper(roiNames{iRoi}),'FontSize',14,'FontWeight','bold','FontAngle',...
        'italic','color',[0 0 1],'HorizontalAlignment','Center');
    h2 = text(exoVI(iRoi), exoPP(iRoi), upper(roiNames{iRoi}),'FontSize',14,'FontWeight','bold','FontAngle',...
        'italic','color',[1 0 0],'HorizontalAlignment','Center');
end

scale_axis = 1.2;
axis([-scale_axis scale_axis -scale_axis scale_axis]);
hline(0);
vline(0);
ylabel('<------ post-cue     pre-cue ------>','FontSize', 14, 'FontAngle', 'Italic');
xlabel('<------ invalid     valid ------>', 'FontSize', 14, 'FontAngle', 'Italic');
set(gca, 'YTick', [-scale_axis 0 scale_axis], 'XTick', [-scale_axis 0 scale_axis], 'tickdir', 'out')
axis square

if baselineCorrect
    title('With baseline correction','FontSize', 16)
else
    title('Without baseline correction','FontSize', 16)
end

% namefig=sprintf(['/Local/Users/purpadmin/Laura/MRI/Data/mr/mrMerge/newIndex_notcombined']);
% print ('-djpeg', '-r500',namefig);

%     % valid vs. invalid ENDO
%     ind.validinvalidEndoC(iRoi) = (mean(ehdrEndoC([1 3])) - mean(ehdrEndoC([2 4]))) / (mean(ehdrEndoC([1 3])) + mean(ehdrEndoC([2 4])));
%     
%     % pre vs. post ENDO
%     temp = zeros(2,1);
%     temp(1) = (ehdrEndoC(1)-ehdrEndoC(3))/(ehdrEndoC(1)+ehdrEndoC(3));
%     temp(2) = (ehdrEndoC(2)-ehdrEndoC(4))/(ehdrEndoC(2)+ehdrEndoC(4));
%     ind.prepostEndoC(iRoi) = mean(temp);
%     
%     % valid vs. invalid EXO
%     temp = zeros(2,1);
%     temp(1) = (ehdrExoC(1)-ehdrExoC(2))/(ehdrExoC(1)+ehdrExoC(2));
%     temp(2) = (ehdrExoC(3)-ehdrExoC(4))/(ehdrExoC(3)+ehdrExoC(4));
%     ind.validinvalidExoC(iRoi) = mean(temp);
%     
%     % pre vs. post EXO
%     temp = zeros(2,1);
%     temp(1) = (ehdrExoC(1)-ehdrExoC(3))/(ehdrExoC(1)+ehdrExoC(3));
%     temp(2) = (ehdrExoC(2)-ehdrExoC(4))/(ehdrExoC(2)+ehdrExoC(4));
%     ind.prepostExoC(iRoi) = mean(temp);
%     
%     roiname = stripext(fEndo(iRoi).name(6:end));
%     roiname = fixBadChars(roiname, [], {'r_',''});
%     roiname = fixBadChars(roiname, [], {'l_',''});
%     roiname = fixBadChars(roiname, [], {'_endo',''});
%     roiname = fixBadChars(roiname, [], {'_exo',''});
%     roiname = fixBadChars(roiname, [], {'v3d','v3'});
%     roiname = fixBadChars(roiname, [], {'v2d','v2'});
%     roiname = upper(roiname);
%     ind.name{iRoi} = roiname;
%     
% end

% namefig=sprintf(['/Local/Users/purpadmin/Laura/MRI/Data/mr/mrMerge/newIndex_notcombined']);
% print ('-djpeg', '-r500',namefig);

%% New index: Combining left and right

% 
% figure; hold on;
% for i=1:length(roiNames);
%     h1 = text(aveValidInvalidEndoC(i), aveprepostEndoC(i), roiNames{i},'FontSize',14,'FontWeight','bold','FontAngle',...
%         'italic','color',[0 0 1],'HorizontalAlignment','Center');
% end
% for i=1:length(roiNames);
%     h2 = text(aveValidInvalidExoC(i), aveprepostExoC(i), roiNames{i},'FontSize',14,'FontWeight','bold','FontAngle',...
%         'italic','color',[1 0 0],'HorizontalAlignment','Center');
% end
% scale_axis = 55;
% axis([-scale_axis scale_axis -scale_axis scale_axis]);
% hline(0);
% vline(0);
% ylabel('<------ post-cue     pre-cue ------>','FontSize', 14, 'FontAngle', 'Italic');
% xlabel('<------ invalid     valid ------>', 'FontSize', 14, 'FontAngle', 'Italic');
% set(gca, 'YTick', [-scale_axis 0 scale_axis], 'XTick', [-scale_axis 0 scale_axis], 'tickdir', 'out')
% 
% if baselineCorrect
%     title('With baseline correction','FontSize', 16)
% else
%     title('Without baseline correction','FontSize', 16)
% end
% keyboard
% %%
% ind.name = cell(length(fEndo), 1);
% 
% ROI_To_Analyze_l = 1:12;
% ROI_To_Analyze_r = 13:24;
% 
% for iRoi = 1:(length(fEndo)/2)
%     anal = load(fullfile('Anal/endo', fEndo(ROI_To_Analyze_l(iRoi)).name));
%     if baselineCorrect
%         anal.dGLM = anal.dGLM2;
%     end
%     ehdr_l = anal.dGLM.ehdr;
%     ehdrste_l = anal.dGLM.ehdrste;
%     
%     anal = load(fullfile('Anal/exo', fExo(ROI_To_Analyze_r(iRoi)).name));
%     if baselineCorrect
%         anal.dGLM = anal.dGLM2;
%     end
%     ehdr_r = anal.dGLM.ehdr;
%     ehdrste_r = anal.dGLM.ehdrste;
%     
%     % concat and  average ipsilateral responses
%     % for left ROI, the first four response are ipsilateral
%     % for right ROI, the second set of four respones are ipsilateral
%     glmehdrI = cat(3, ehdr_l(1:4,:), ehdr_r(5:8,:));
%     glmehdrI = mean(glmehdrI, 3);
%     
%     glmehdrsteI = cat(3, ehdrste_l(1:4,:), ehdrste_r(5:8,:));
%     glmehdrsteI = sqrt(sum(glmehdrsteI.^2,3))/2;
%     
%     baseline_glmehdr = mean(glmehdrI,1);
%     baseline_glmehdrste = sqrt(sum(glmehdrsteI.^2))/2;
%     
%     % do the contralateral hemifield
%     glmehdrC = cat(3, ehdr_l(5:8,:), ehdr_r(1:4,:));
%     glmehdrC = mean(glmehdrC, 3);
%     glmehdrC = cat(1, glmehdrC, baseline_glmehdr);
%     
%     glmehdrsteC = cat(3, ehdr_l(5:8,:), ehdr_r(1:4,:));
%     glmehdrsteC = sqrt(sum(glmehdrsteC.^2,3))/2;
%     glmehdrsteC = cat(1, glmehdrsteC, baseline_glmehdrste);
%     
%     % valid vs. invalid
%     temp = zeros(2,1);
%     temp(1) = (glmehdrC(1)-glmehdrC(2))/(glmehdrC(1)+glmehdrC(2));
%     temp(2) = (glmehdrC(3)-glmehdrC(4))/(glmehdrC(3)+glmehdrC(4));
%     ind.x(iRoi) = mean(temp);
%     
%     % pre vs. post
%     temp = zeros(2,1);
%     temp(1) = (glmehdrC(1)-glmehdrC(3))/(glmehdrC(1)+glmehdrC(3));
%     temp(2) = (glmehdrC(2)-glmehdrC(4))/(glmehdrC(2)+glmehdrC(4));
%     ind.y(iRoi) = mean(temp);
%     
%     roiname = stripext(f(ROI_To_Analyze_l(iRoi)).name(6:end));
%     roiname = fixBadChars(roiname, [], {'r_',''});
%     roiname = fixBadChars(roiname, [], {'l_',''});
%     roiname = fixBadChars(roiname, [], {['_' attCond],''});
%     %   roiname = fixBadChars(roiname, [], {'v3d','v3'});
%     %   roiname = fixBadChars(roiname, [], {'v2d','v2'});
%     roiname = upper(roiname);
%     ind.name{iRoi} = roiname;
%     
% end
% 
% figure;
% for i=1:4
%     h = text(ind.x(i), ind.y(i), ind.name{i},'FontSize',14,'FontWeight','bold','FontAngle','italic','color',[0 0 1],'HorizontalAlignment','Center');
% end
% 
% scale_axis = .2;
% 
% axis([-scale_axis scale_axis -scale_axis scale_axis]);
% hline(0);
% vline(0);
% ylabel('<------ post-cue     pre-cue ------>','FontSize', 14, 'FontAngle', 'Italic');
% xlabel('<------ invalid     valid ------>', 'FontSize', 14, 'FontAngle', 'Italic');
% set(gca, 'YTick', [-scale_axis 0 scale_axis], 'XTick', [-scale_axis 0 scale_axis], 'tickdir', 'out')
% 
% namefig=sprintf(['/Local/Users/purpadmin/Laura/MRI/Data/mr/mrMerge/newIndex_combined']);
% print ('-djpeg', '-r500',namefig);
% 
% %% Liu et al. 2005 Index
% 
% ind.name = cell(length(f), 1);
% 
% for iRoi = 1:length(f)
%     anal = load(fullfile(['Anal/' attCond], f(iRoi).name));
%     if strfind(f(iRoi).name, 'r_')
%         ehdr = anal.dGLM.ehdr(1:4);
%     else
%         ehdr = anal.dGLM.ehdr(5:8);
%     end
%     
%     % valid higher than evrything else
%     baseline = [ehdr(2) ehdr(3) ehdr(4)];
%     baseline = mean(baseline);
%     
%     ind.data(iRoi) = (ehdr(1)-baseline)/(ehdr(1)+baseline);
%     
%     roiname = stripext(f(iRoi).name(6:end));
%     roiname = fixBadChars(roiname, [], {'r_',''});
%     roiname = fixBadChars(roiname, [], {'l_',''});
%     roiname = fixBadChars(roiname, [], {['_' attCond],''});
%     %   roiname = fixBadChars(roiname, [], {'v3d','v3'});
%     %   roiname = fixBadChars(roiname, [], {'v2d','v2'});
%     roiname = upper(roiname);
%     ind.name{iRoi} = num2str(roiname);
%     
% end
% 
% figure;
% h = bar(ind.data(1:12));
% axis square
% title('Left ROIs')
% ylabel('(PreValid - baseline) / (PreValid + baseline)')
% set(gca,'XTick',1:12)
% set(gca,'XTicklabel',{ind.name{1};ind.name{2};...
%     ind.name{3};ind.name{4};ind.name{5};ind.name{6};...
%     ind.name{7};ind.name{8};ind.name{9};ind.name{10};...
%     ind.name{11};ind.name{12}})
% 
% figure;
% h = bar(ind.data(13:24));
% axis square
% title('Right ROIs')
% ylabel('(PreValid - baseline) / (PreValid + baseline)')
% set(gca,'XTick',1:12)
% set(gca,'XTicklabel',{ind.name{13};ind.name{14};...
%     ind.name{15};ind.name{16};ind.name{17};ind.name{18};...
%     ind.name{19};ind.name{20};ind.name{21};ind.name{22};...
%     ind.name{23};ind.name{24}})
% 
% avg_idx = [ind.data(1:12);ind.data(13:end)];
% avg_idx = mean(avg_idx,1);
% 
% figure;
% h = bar(avg_idx);
% axis square
% title('AMI averaged over left and right ROIs','Fontsize',14)
% ylabel('(PreValid - baseline) / (PreValid + baseline)','Fontsize',14)
% set(gca,'XTick',1:12)
% set(gca,'XTicklabel',{ind.name{13};ind.name{14};...
%     ind.name{15};ind.name{16};ind.name{17};ind.name{18};...
%     ind.name{19};ind.name{20};ind.name{21};ind.name{22};...
%     ind.name{23};ind.name{24}})
% namefig=sprintf(['/Local/Users/purpadmin/Laura/MRI/Data/mr/mrMerge/LiuIndex_allRois']);
% print ('-djpeg', '-r500',namefig);
% 
% %% Focus on V1, hV4 and V7
% 
% focus_idx = [avg_idx(4),avg_idx(9),avg_idx(10)];
% 
% figure;
% h = bar(focus_idx);
% axis square
% title('AMI averaged over left and right ROIs','Fontsize',14)
% ylabel('(PreValid - baseline) / (PreValid + baseline)','Fontsize',14)
% set(gca,'XTick',1:3)
% set(gca,'XTicklabel',{ind.name{4};ind.name{9};ind.name{10}})
% set(gca,'YTick',0:.1:.2)
% 
% namefig=sprintf(['/Local/Users/purpadmin/Laura/MRI/Data/mr/mrMerge/LiuIndex']);
% print ('-djpeg', '-r500',namefig);

