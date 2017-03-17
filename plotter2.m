getDepth=@(disparity) (baseline*f*focus_plane*SensorWidthPx)./(disparity*focus_plane*SensorWidth + baseline*f*SensorWidthPx); 

depth_smooth = getDepth(x);
depth_raw = getDepth(h);
maxD = max(depth_smooth(:));

depth_smooth_hsv = ones([sz_lf(1:2) 3]);

depth_smooth_hsv(:,:,1) = 0.75*mean_scale(depth_smooth, 0, 10);
figure(1);
subplot(2,2,1);
depth_smooth_rgb = hsv2rgb(depth_smooth_hsv);
imshow(depth_smooth_rgb);
title(sprintf('OF depth with admm, lambda = %.3f, rho = %.2f', lambda, rho));


subplot(2,2,2);
depth_hsv = ones([sz_lf(1:2) 3]);
depth_hsv(:,:,1) = 0.75*mean_scale(min(depth_raw, maxD), 0, 10);
%depth_hsv(:,:,3) = Csc;
depth_rgb = hsv2rgb(depth_hsv);
imshow(depth_rgb);
title('OF depth, C brightened');

gnd = 0.75*depth_true./max(depth_true(:));
gnd_hsv = ones([sz_lf(1:2) 3]); 
gnd_hsv(:,:,1) = gnd;
gnd_rgb = hsv2rgb(gnd_hsv);


subplot(2,2,3);
%imshow(2*squeeze(lf(:,:,nV_2,nV_2,:)));
imshow(gnd_rgb);
title('gnd truth');
        
subplot(2,2,4);
imshow(Csc);
title('Confidence of OF');

figure(2);
subplot(2,1,1);
plot(1:nIter, loss)
xlabel('iterations', 'FontSize', 15);
ylabel('ADMM loss', 'FontSize', 15);

subplot(2,1,2);
plot(1:nIter, loss2)
xlabel('iterations', 'FontSize', 15);
ylabel('gnd truth loss', 'FontSize', 15);

figure(3);
subplot(2,1,1);
histogram(depth_raw(:));
title('raw depth hist');
subplot(2,1,2);
histogram(depth_smooth(:));
title('smooth depth hist');



figure(4)
xline = 280;
dline = depth_smooth(xline, :) .* (Csc(xline, :) > 0.1);
dline(dline > 10) = 0;
plot(1:sz_lf(2), dline, 'o', 1:sz_lf(2), LF.depth_lowres(xline, :), 'x');
legend('results', 'gnd truth');
xlabel('pixel column', 'FontSize', 15);
ylabel('depth (m)');
