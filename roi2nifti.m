function [] = roi2nifti(outputname)

baseAnatomy = viewGet(getMLRView, 'baseAnatomy');

roiNifti = zeros(baseAnatomy.hdr.dim(2:4)');

roi = viewGet(getMLRView, 'roi');

disppercent(-inf, 'Creating ROI');
for iVox=1:length(roi.coords)
    roiNifti(roi.coords(1,iVox), roi.coords(2,iVox), roi.coords(3,iVox)) = 1;
    disppercent(iVox/length(roi.coords));
end
disppercent(inf);

cbiWriteNifti(outputname, roiNifti, baseAnatomy.hdr);
