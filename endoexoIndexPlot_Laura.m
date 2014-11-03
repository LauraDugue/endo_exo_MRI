% endoexoIndexPlot.m
%
%      usage: endoexoIndexPlot()
%         by: eli merriam
%       date: 07/28/14
%    purpose: 
%
function retval = endoexoIndexPlot()

% check arguments
if ~any(nargin == [0])
  help endoexoIndexPlot
  return
end

%%% Anal = avg projected out
%%% Anal.bak = avg NOT projected out

f = dir('Anal/anal_*.mat');

%% New index
ind.name = cell(length(f), 1);

for iRoi = 1:length(f)
  anal = load(fullfile('Anal', f(iRoi).name));
  if strfind(f(iRoi).name, 'r_')
    ehdr = anal.dGLM.ehdr(1:4);
  else
    ehdr = anal.dGLM.ehdr(5:8);
  end
  
  % valid vs. invalid
  temp = zeros(2,1);
  temp(1) = (ehdr(1)-ehdr(2))/(ehdr(1)+ehdr(2));
  temp(2) = (ehdr(3)-ehdr(4))/(ehdr(3)+ehdr(4));
  ind.x(iRoi) = mean(temp);

  % pre vs. post
  temp = zeros(2,1);
  temp(1) = (ehdr(1)-ehdr(3))/(ehdr(1)+ehdr(3));
  temp(2) = (ehdr(2)-ehdr(4))/(ehdr(2)+ehdr(4));
  ind.y(iRoi) = mean(temp);
  
  roiname = stripext(f(iRoi).name(6:end));
%   roiname = fixBadChars(roiname, [], {'r_',''});
%   roiname = fixBadChars(roiname, [], {'l_',''});
%   roiname = fixBadChars(roiname, [], {'v3d','v3'});
%   roiname = fixBadChars(roiname, [], {'v2d','v2'});
  roiname = upper(roiname);
  ind.name{iRoi} = roiname;

end

figure;
for i=1:length(f); 
  h = text(ind.x(i), ind.y(i), ind.name{i},'FontSize',14,'FontWeight','bold','FontAngle','italic','color',[0 0 1],'HorizontalAlignment','Center'); 
end

scale_axis = .6;

axis([-scale_axis scale_axis -scale_axis scale_axis]);
hline(0);
vline(0);
ylabel('<------ post-cue     pre-cue ------>','FontSize', 14, 'FontAngle', 'Italic');
xlabel('<------ invalid     valid ------>', 'FontSize', 14, 'FontAngle', 'Italic');
set(gca, 'YTick', [-scale_axis 0 scale_axis], 'XTick', [-scale_axis 0 scale_axis], 'tickdir', 'out')

namefig=sprintf(['/Users/dugue/Documents/Post_doc/MRI_project/wiki/pilot_ec_mri/Index/newIndex_notcombined']);
print ('-djpeg', '-r500',namefig);

%% New index: Combining left and right
ind.name = cell(length(f), 1);

ROI_To_Analyze_l = [9 14 1];
ROI_To_Analyze_r = [16 22 27];

for iRoi = 1:3
  anal = load(fullfile('Anal', f(ROI_To_Analyze_l(iRoi)).name));
  ehdr_l = anal.dGLM.ehdr;
  ehdrste_l = anal.dGLM.ehdrste;

  anal = load(fullfile('Anal', f(ROI_To_Analyze_r(iRoi)).name));
  ehdr_r = anal.dGLM.ehdr;
  ehdrste_r = anal.dGLM.ehdrste;

  % concat and  average ipsilateral responses
  % for left ROI, the first four response are ipsilateral
  % for right ROI, the second set of four respones are ipsilateral
  glmehdrI = cat(3, ehdr_l(1:4,:), ehdr_r(5:8,:));
  glmehdrI = mean(glmehdrI, 3);
  
  glmehdrsteI = cat(3, ehdrste_l(1:4,:), ehdrste_r(5:8,:));
  glmehdrsteI = sqrt(sum(glmehdrsteI.^2,3))/2;
  
  baseline_glmehdr = mean(glmehdrI,1);
  baseline_glmehdrste = sqrt(sum(glmehdrsteI.^2))/2;
  
  % do the contralateral hemifield
  glmehdrC = cat(3, ehdr_l(5:8,:), ehdr_r(1:4,:));
  glmehdrC = mean(glmehdrC, 3);
  glmehdrC = cat(1, glmehdrC, baseline_glmehdr);
  
  glmehdrsteC = cat(3, ehdr_l(5:8,:), ehdr_r(1:4,:));
  glmehdrsteC = sqrt(sum(glmehdrsteC.^2,3))/2;
  glmehdrsteC = cat(1, glmehdrsteC, baseline_glmehdrste);
  
  % valid vs. invalid
  temp = zeros(2,1);
  temp(1) = (glmehdrC(1)-glmehdrC(2))/(glmehdrC(1)+glmehdrC(2));
  temp(2) = (glmehdrC(3)-glmehdrC(4))/(glmehdrC(3)+glmehdrC(4));
  ind.x(iRoi) = mean(temp);

  % pre vs. post
  temp = zeros(2,1);
  temp(1) = (glmehdrC(1)-glmehdrC(3))/(glmehdrC(1)+glmehdrC(3));
  temp(2) = (glmehdrC(2)-glmehdrC(4))/(glmehdrC(2)+glmehdrC(4));
  ind.y(iRoi) = mean(temp);
  
  roiname = stripext(f(ROI_To_Analyze_l(iRoi)).name(6:end));
  roiname = fixBadChars(roiname, [], {'r_',''});
  roiname = fixBadChars(roiname, [], {'l_',''});
  roiname = fixBadChars(roiname, [], {'v3d','v3'});
  roiname = fixBadChars(roiname, [], {'v2d','v2'});
  roiname = upper(roiname);
  ind.name{iRoi} = roiname;

end

figure;
for i=1:3
  h = text(ind.x(i), ind.y(i), ind.name{i},'FontSize',14,'FontWeight','bold','FontAngle','italic','color',[0 0 1],'HorizontalAlignment','Center'); 
end

scale_axis = .2;

axis([-scale_axis scale_axis -scale_axis scale_axis]);
hline(0);
vline(0);
ylabel('<------ post-cue     pre-cue ------>','FontSize', 14, 'FontAngle', 'Italic');
xlabel('<------ invalid     valid ------>', 'FontSize', 14, 'FontAngle', 'Italic');
set(gca, 'YTick', [-scale_axis 0 scale_axis], 'XTick', [-scale_axis 0 scale_axis], 'tickdir', 'out')

namefig=sprintf(['/Users/dugue/Documents/Post_doc/MRI_project/wiki/pilot_ec_mri/Index/newIndex_combined']);
print ('-djpeg', '-r500',namefig);


%% Liu et al. 2005 Index

ind.name = cell(length(f), 1);

for iRoi = 1:length(f)
  anal = load(fullfile('Anal', f(iRoi).name));
  if strfind(f(iRoi).name, 'r_')
    ehdr = anal.dGLM.ehdr(1:4);
  else
    ehdr = anal.dGLM.ehdr(5:8);
  end
  
  % valid higher than evrything else
  baseline = [ehdr(2) ehdr(3) ehdr(4)];
  baseline = mean(baseline);
  
  ind.data(iRoi) = (ehdr(1)-baseline)/(ehdr(1)+baseline);
  
  roiname = stripext(f(iRoi).name(6:end));
  roiname = fixBadChars(roiname, [], {'r_',''});
  roiname = fixBadChars(roiname, [], {'l_',''});
  roiname = fixBadChars(roiname, [], {'v3d','v3'});
  roiname = fixBadChars(roiname, [], {'v2d','v2'});
  roiname = upper(roiname);
  ind.name{iRoi} = num2str(roiname);

end

for i=1:length(f)
    
end

figure;
h = bar(ind.data(1:15)); 
axis square
title('Left ROIs')
ylabel('(PreValid - baseline) / (PreValid + baseline)')
set(gca,'XTick',1:15)
set(gca,'XTicklabel',{ind.name{1};ind.name{2};...
    ind.name{3};ind.name{4};ind.name{5};ind.name{6};...
    ind.name{7};ind.name{8};ind.name{9};ind.name{10};...
    ind.name{11};ind.name{12};ind.name{13};ind.name{14};ind.name{15}})

figure;
h = bar(ind.data(16:28)); 
axis square
title('Right ROIs')
ylabel('(PreValid - baseline) / (PreValid + baseline)')
set(gca,'XTick',1:13)
set(gca,'XTicklabel',{ind.name{16};ind.name{17};...
    ind.name{18};ind.name{19};ind.name{20};ind.name{21};...
    ind.name{22};ind.name{23};ind.name{24};ind.name{25};...
    ind.name{26};ind.name{27};ind.name{18}})

avg_idx = [ind.data(1) ind.data(4:15);ind.data(16:end)];
avg_idx = mean(avg_idx,1);

figure;
h = bar(avg_idx); 
axis square
title('AMI averaged over left and right ROIs','Fontsize',14)
ylabel('(PreValid - baseline) / (PreValid + baseline)','Fontsize',14)
set(gca,'XTick',1:13)
set(gca,'XTicklabel',{ind.name{16};ind.name{17};...
    ind.name{18};ind.name{19};ind.name{20};ind.name{21};...
    ind.name{22};ind.name{23};ind.name{24};ind.name{25};...
    ind.name{26};ind.name{27};ind.name{18}})


figure;
h = bar(avg_idx); 
axis square
title('AMI averaged over left and right ROIs','Fontsize',14)
ylabel('(PreValid - baseline) / (PreValid + baseline)','Fontsize',14)
set(gca,'XTick',1:13)
set(gca,'XTicklabel',{ind.name{16};ind.name{17};...
    ind.name{18};ind.name{19};ind.name{20};ind.name{21};...
    ind.name{22};ind.name{23};ind.name{24};ind.name{25};...
    ind.name{26};ind.name{27};ind.name{18}})
namefig=sprintf(['/Users/dugue/Documents/Post_doc/MRI_project/wiki/pilot_ec_mri/Index/LiuIndex_allRois']);
print ('-djpeg', '-r500',namefig);

%% Focus on V1, hV4 and IPS1
focus_idx = [avg_idx(7),avg_idx(12),avg_idx(1)];

figure;
h = bar(focus_idx); 
axis square
title('AMI averaged over left and right ROIs','Fontsize',14)
ylabel('(PreValid - baseline) / (PreValid + baseline)','Fontsize',14)
set(gca,'XTick',1:3)
set(gca,'XTicklabel',{ind.name{15+7};ind.name{15+12};ind.name{15+1}})
set(gca,'YTick',0:.1:.2)

namefig=sprintf(['/Users/dugue/Documents/Post_doc/MRI_project/wiki/pilot_ec_mri/Index/LiuIndex']);
print ('-djpeg', '-r500',namefig);

