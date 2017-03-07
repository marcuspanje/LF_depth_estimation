%run_params
%1 - run alg from the start
%2 - run after lf is in memory
%3 - run after the noisy depth map, h, is in memory
%4 - run after admm
run_params = 1;
fname = 'lf_images/books';

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
  run_admm;
end

disp('plot');
plotter;

