imwrite(depth_smooth_rgb, sprintf('%s/depth_smooth.png', foldername));
imwrite(depth_rgb, sprintf('%s/depth_raw.png', foldername));
imwrite(gnd_rgb, sprintf('%s/gnd.png', foldername));
%imwrite(Csc, sprintf('lf_images/%s/%s_conf.png', fname, fname));
