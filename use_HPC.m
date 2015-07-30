% Laura - HPC
% Here are instructions to run a given program on the NYU HPC
% It's running through the terminal with the bash option
% Note default Hypatia is: /bin/tcsh

%% Access the virtual computer
% ssh hpctunnel
% ssh mercer
% cd /scratch/ld1439

%% Clone some repository from github if necessary
% MRI analysis programs: git clone https://github.com/LauraDugue/endo_exo_MRI.git
% mrTool: git clone https://github.com/justingardner/mrTools.git

%% Create a folder
% mkdir data 

%% Zip and Unzip folder
% zip -r coMerge.zip coMerge
% unzip coMerge.zip

%% Transfer the data
% From Hypatia to the virtual computer: scp /Volumes/DRIVE1/DATA/laura/MRI/Group/endo_data_hpc.mat mercer:/scratch/ld1439/data/
% From the virtual computer to Hypatia: scp s0*_dataset.mat purpadmin@hypatia.psych.nyu.edu:~/Desktop/
