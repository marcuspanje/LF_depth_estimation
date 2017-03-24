%run_params
tic;
%'lytro' or 'heidelberg'
%heidelberg is the dataset from http://hci-lightfield.iwr.uni-heidelberg.de/
%lytro is the raw lytro image converted to png format
img_format = 'lytro';

fname = 'books_4';
foldername = 'lf_images/books_4';

disp('loading light field image');
if strcmp('lytro', img_format)
  load_lf_lytro;
elseif strcmp('heidelberg', img_format)
  load_lf_heidelberg;
else
  error('format not recognized');
end

disp('compute optical flow');
compute_of;

disp('run admm with TV prior');
run_admm_vec;

disp('plot');
plotter;
toc;
