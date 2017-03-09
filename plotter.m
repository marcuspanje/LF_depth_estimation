%scale and display h
%focal length
%sensor distance from lens
Sd = data.frames{1}.frame.metadata.devices.mla.sensorOffset.z;
%focal length
f = data.frames{1}.frame.metadata.devices.lens.focalLength * 1e-3;
Sd = f + 0.5*f;


D = 1/(1/f - 1/Sd);
%D = 2;
depth_raw = f*D./(h.*(D-f) + f);
depth_smooth = f*D./(x.*(D-f) + f);

depth_smooth_sc = depth_smooth ./max(depth_smooth(:));
figure(1);
subplot(2,2,1);
imshow(depth_smooth_sc);
title(sprintf('OF depth with admm, lambda = %.3f, rho = %.2f', lambda, rho));

subplot(2,2,2);
me = mean(depth_raw(:));
depth_raw_sc = min(depth_raw, 2*me);
depth_raw_sc = max(depth_raw_sc, 0.1*me);
depth_raw_sc = depth_raw_sc ./ max(depth_raw_sc(:));
imshow(depth_raw_sc);
title('OF depth');

subplot(2,2,3);
imshow(3*squeeze(lf(:,:,nV_2,nV_2,:)));
title('original');
        

Cdisp = sum(C,3);
Cdisp = Cdisp./max(Cdisp);
subplot(2,2,4);
imshow(Cdisp);
title('Confidence of OF');

