%% run_all_ROIs
%%% mr: scanNum=1 for exo and scanNum=2 for endo
%%% id: scanNum=1 for exo and scanNum=2 for endo
%%% nms: scanNum=1 for exo and scanNum=2 for endo

scanNum = 1:2;
hemi = {'l', 'r'};
roiNames = {'v1', 'v4', 'vo1', 'vo2', 'v2d', 'v3d', 'v3a', 'v3b', 'lo1', 'lo2','v7','ips1','ips2','ips3','ips4'};
v = newView;

for iScan=scanNum;
    for iHemi=1:length(hemi)
        for iRoi=1:length(roiNames)
            v = endoexoRvL2(v, sprintf('%s_%s', hemi{iHemi}, roiNames{iRoi}), sprintf('scanNum=%i', iScan));
        end
    end
end

% Run vTPJ analysis but just on the right hemishphere
v = endoexoRvL2(v, 'r_vTPJ', 'scanNum=1');
v = endoexoRvL2(v, 'r_vTPJ', 'scanNum=2');

%%
clear all;
scanNum = 1:2;%
hemi = {'l','r'};%
roiNames = {'v1', 'v4', 'vo1', 'vo2', 'v2d', 'v3d', 'v3a', 'v3b', 'lo1', 'lo2','v7','ips1','ips2','ips3','ips4'};
v = newView;

for iScan=scanNum;
    for iHemi=1:length(hemi)
        for iRoi=1:length(roiNames)
            v = endoexoRvLCorb(v, sprintf('%s_%s', hemi{iHemi}, roiNames{iRoi}), sprintf('scanNum=%i', iScan));
        end
    end
end

% Run vTPJ analysis but just on the right hemishphere
v = endoexoRvLCorb(v, 'r_vTPJ', 'scanNum=1');
v = endoexoRvLCorb(v, 'r_vTPJ', 'scanNum=2');

