%scale and display h
%focal length
%sensor distance from lens
%Sd = data.frames{1}.frame.metadata.devices.mla.sensorOffset.z;
%focal length
saveImages = 1;
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

depth_smooth = f./x;
depth_smooth_hsv = ones([sz_lf(1:2) 3]);
%depth_smooth_hsv(:,:,1) = 0.75*depth_smooth;
depth_smooth_hsv(:,:,1) = 0.75*mean_scale(depth_smooth, 0.1, 1.8);
figure(1);
subplot(2,2,1);
depth_smooth_rgb = hsv2rgb(depth_smooth_hsv);
imshow(depth_smooth_rgb);
title(sprintf('OF depth with admm, lambda = %.3f, rho = %.2f', lambda, rho));


subplot(2,2,2);
depth_hsv = ones([sz_lf(1:2) 3]);
depth_hsv(:,:,1) = 0.75*mean_scale(depth_raw, 0.1, 1.8);
%depth_hsv(:,:,3) = Csc;
depth_rgb = hsv2rgb(depth_hsv);
imshow(depth_rgb);
title('OF depth');

subplot(2,2,3);
imshow(2*squeeze(lf(:,:,nV_2,nV_2,:)));
title('original');
        
subplot(2,2,4);
imshow(Csc);
title('Confidence of OF');

figure(2);
histogram(depth_raw(:));
title('histogram of raw depth')

figure(3);
plot(1:nIter, loss)
xlabel('iterations', 'FontSize', 15);
ylabel('ADMM loss', 'FontSize', 15);

if saveImages
    imwrite(depth_smooth_rgb, sprintf('lf_images/%s/%s_depth_smooth.png', fname, fname));
    imwrite(depth_rgb, sprintf('lf_images/%s/%s_depth_raw.png', fname, fname));
    imwrite(Csc, sprintf('lf_images/%s/%s_conf.png', fname, fname));
end

figure(4)
xline = 193;
dline = depth_smooth(xline, :) .* (Csc(xline, :) > 0.3);
%dline(dline > 3) = 0;
plot(1:sz_lf(2), dline, 'o');
xlabel('pixel column', 'FontSize', 15);
ylabel('depth (m)');

figure(5);
subplot(2,1,1);
histogram(h);
title('histogram of h');
subplot(2,1,2);
histogram(x);
title('histogram of h smooth');
