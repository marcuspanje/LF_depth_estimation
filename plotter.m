%scale and display h
%focal length
%sensor distance from lens
%Sd = data.frames{1}.frame.metadata.devices.mla.sensorOffset.z;
%focal length
saveImages = 1;
f = 0.05
if validData == 1
    f = data.frames{1}.frame.metadata.devices.lens.focalLength;
end
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
depth_smooth_hsv = ones([sz_lf(1:2) 3]);
%depth_smooth_hsv(:,:,1) = 0.75*depth_smooth;
depth_smooth_hsv(:,:,1) = 0.75*mean_scale(depth_smooth, 0, 1.8);
figure(1);
subplot(2,2,1);
depth_smooth_rgb = hsv2rgb(depth_smooth_hsv);
imshow(depth_smooth_rgb);
title(sprintf('OF depth with admm, lambda = %.3f, rho = %.2f', lambda, rho));


subplot(2,2,2);
depth_hsv = ones([sz_lf(1:2) 3]);
depth_hsv(:,:,1) = 0.75*mean_scale(depth_raw, 0, 1.8);
%depth_hsv(:,:,3) = Csc;
depth_rgb = hsv2rgb(depth_hsv);
imshow(depth_rgb);
title('OF depth');

subplot(2,2,3);
imshow(5*squeeze(lf(:,:,nV_2,nV_2,:)));
title('original');
        
subplot(2,2,4);
imshow(Csc);
title('Confidence of OF');

figure(2);
histogram(depth_raw(:));

figure(3);
plot(1:nIter, loss)
xlabel('iterations', 'FontSize', 15);
ylabel('ADMM loss', 'FontSize', 15);
plot(1:nIter, loss)

if saveImages
    imwrite(depth_smooth_rgb, sprintf('lf_images/%s/%s_depth_smooth.png', fname, fname));
    imwrite(depth_rgb, sprintf('lf_images/%s/%s_depth_raw.png', fname, fname));
    imwrite(Csc, sprintf('lf_images/%s/%s_conf.png', fname, fname));
end

