%% run_all_combinations
obs = 'mr';

%% JUST TPJ

endoexoCombineResps_TPJ('anal_r_vTPJ_exo', 'exo',obs,1);

%% Exogenous attention
endoexoCombineResps_Laura('anal_l_v1_exo', 'anal_r_v1_exo', 'exo',obs,1);
endoexoCombineResps_Laura('anal_l_v2d_exo', 'anal_r_v2d_exo', 'exo',obs,1);
endoexoCombineResps_Laura('anal_l_v3d_exo', 'anal_r_v3d_exo', 'exo',obs,1);
endoexoCombineResps_Laura('anal_l_v3a_exo', 'anal_r_v3a_exo', 'exo',obs,1);
endoexoCombineResps_Laura('anal_l_v3b_exo', 'anal_r_v3b_exo', 'exo',obs,1);
endoexoCombineResps_Laura('anal_l_v4_exo', 'anal_r_v4_exo', 'exo',obs,1);
endoexoCombineResps_Laura('anal_l_v7_exo', 'anal_r_v7_exo', 'exo',obs,1);

% endoexoCombineResps_Laura('anal_l_v1_exo', 'anal_r_v1_exo', 'exo',obs,0);
% endoexoCombineResps_Laura('anal_l_v2d_exo', 'anal_r_v2d_exo', 'exo',obs,0);
% endoexoCombineResps_Laura('anal_l_v3d_exo', 'anal_r_v3d_exo', 'exo',obs,0);
% endoexoCombineResps_Laura('anal_l_v3a_exo', 'anal_r_v3a_exo', 'exo',obs,0);
% endoexoCombineResps_Laura('anal_l_v3b_exo', 'anal_r_v3b_exo', 'exo',obs,0);
% endoexoCombineResps_Laura('anal_l_v4_exo', 'anal_r_v4_exo', 'exo',obs,0);
% endoexoCombineResps_Laura('anal_l_v7_exo', 'anal_r_v7_exo', 'exo',obs,0);

%% Endogenous attention
endoexoCombineResps_Laura('anal_l_v1_endo', 'anal_r_v1_endo', 'endo',obs,1);
endoexoCombineResps_Laura('anal_l_v2d_endo', 'anal_r_v2d_endo', 'endo',obs,1);
endoexoCombineResps_Laura('anal_l_v3d_endo', 'anal_r_v3d_endo', 'endo',obs,1);
endoexoCombineResps_Laura('anal_l_v3a_endo', 'anal_r_v3a_endo', 'endo',obs,1);
endoexoCombineResps_Laura('anal_l_v3b_endo', 'anal_r_v3b_endo', 'endo',obs,1);
endoexoCombineResps_Laura('anal_l_v4_endo', 'anal_r_v4_endo', 'endo',obs,1);
endoexoCombineResps_Laura('anal_l_v7_endo', 'anal_r_v7_endo', 'endo',obs,1);

% endoexoCombineResps_Laura('anal_l_v1_endo', 'anal_r_v1_endo', 'endo',obs,0);
% endoexoCombineResps_Laura('anal_l_v2d_endo', 'anal_r_v2d_endo', 'endo',obs,0);
% endoexoCombineResps_Laura('anal_l_v3d_endo', 'anal_r_v3d_endo', 'endo',obs,0);
% endoexoCombineResps_Laura('anal_l_v3a_endo', 'anal_r_v3a_endo', 'endo',obs,0);
% endoexoCombineResps_Laura('anal_l_v3b_endo', 'anal_r_v3b_endo', 'endo',obs,0);
% endoexoCombineResps_Laura('anal_l_v4_endo', 'anal_r_v4_endo', 'endo',obs,0);
% endoexoCombineResps_Laura('anal_l_v7_endo', 'anal_r_v7_endo', 'endo',obs,0);