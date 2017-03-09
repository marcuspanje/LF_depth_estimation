%run_params
%1 - run alg from the start
%2 - run from compute optical flow
%3 - run from admm
%4 - run from plotter

run_params = 1;
fname = 'cars_1';
addpath('jsonlab-1.5/jsonlab-1.5');
data = loadjson(sprintf('lf_images/%s/%s.json', fname, fname)); 

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

