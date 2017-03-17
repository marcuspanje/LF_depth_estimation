%run_params
%1 - run alg from the start
%2 - run from compute optical flow
%3 - run from admm
%4 - run from plotter

run_params = 1;
%'lytro' or 'heidelberg'
%heidelberg is the dataset from http://hci-lightfield.iwr.uni-heidelberg.de/
%lytro is the raw lytro image converted to png format

img_format = 'heidelberg';

fname = 'LF.mat';
foldername = 'lf_images/cotton';
%path to json library
addpath('jsonlab-1.5/jsonlab-1.5');

disp('loading light field image');
if strcmp('lytro', img_format)
  load_lf;
elseif strcmp('heidelberg', img_format)
  load_lf2;
else
  error('format not recognized');
end

disp('compute optical flow');
compute_of;

disp('run admm with TV prior');
run_admm_vec;

disp('plot');
plotter2;

