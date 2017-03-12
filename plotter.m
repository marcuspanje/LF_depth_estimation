%scale and display h
%focal length
%sensor distance from lens
%Sd = data.frames{1}.frame.metadata.devices.mla.sensorOffset.z;
%focal length
f = 0.05;
%f = data.frames{1}.frame.metadata.devices.lens.focalLength;
%zstep = data.frames{1}.frame.metadata.devices.lens.focusStep;
%a = -26.0697;
%b = -13.5265;
%M = a*zstep + b; 
%Sd = (M*f -f) / M; 


%Sd = f + 0.5*f;

%D = 1/(1/f - 1/Sd);
%depth_raw = f*D./(h.*(D-f) + f);
%depth_smooth = f*D./(x.*(D-f) + f);
%depth_raw = f ./ (h - min(h(:)) + 0.1);
depth_raw = f./hsc;
depth_raw(isnan(depth_raw)) = max(depth_raw(:));
depth_raw(depth_raw < 0) = 0;
depth_smooth = f./x;

depth_smooth_sc = depth_smooth ./max(depth_smooth(:));
figure(1);
subplot(2,2,1);
imshow(depth_smooth_sc);
title(sprintf('OF depth with admm, lambda = %.3f, rho = %.2f', lambda, rho));

Cdisp = sum(C,3);
me = mean(Cdisp(:));
Cdisp_sc = min(Cdisp, 2*me);
Cdisp_sc = Cdisp_sc ./max(Cdisp_sc(:));

subplot(2,2,2);
me = mean(depth_raw(:));
st = std(depth_raw(:));
depth_raw_sc = min(depth_raw, 1.8*me);
depth_raw_sc = max(depth_raw_sc, 0.1*me);
depth_raw_sc = depth_raw_sc ./ max(depth_raw_sc(:));
depth_raw_sc = 0.75*depth_raw_sc;
depth_hsv = ones([sz_lf(1:2) 3]);
depth_hsv(:,:,1) = depth_raw_sc;
depth_hsv(:,:,3) = Cdisp_sc;
imshow(hsv2rgb(depth_hsv));
title('OF depth');

subplot(2,2,3);
imshow(3*squeeze(lf(:,:,nV_2,nV_2,:)));
title('original');
        

subplot(2,2,4);
imshow(Cdisp_sc);
title('Confidence of OF');

figure(2);
histogram(depth_raw_sc(:));
title('hist of scaled depth');

figure(3)
histogram(depth_raw(:));
title('hist of raw depth');

