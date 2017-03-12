%run_params
%1 - run alg from the start
%2 - run from compute optical flow
%3 - run from admm
%4 - run from plotter

run_params = 1;
fname = 'room';
%path to json library
addpath('jsonlab-1.5/jsonlab-1.5');
%json filename of camera metatdata extracted from lytro .LFP file
%see https://github.com/nrpatel/lfptools on how to obtain this file
%data = loadjson(sprintf('lf_images/%s/%s.json', fname, fname)); 

if run_params < 2
  disp('loading light field image');
  load_lf;
end

if run_params < 3
  disp('compute optical flow');
  compute_of;
end

if run_params < 4
  disp('run admm with TV prior');
  run_admm_vec;
end

disp('plot');
plotter;

