%scale and display h
zdisp = (1./z);
zdisp = zdisp./max(zdisp(:));
figure(1);
subplot(2,2,1);
imshow(zdisp);
title(sprintf('OF depth with admm, lambda = %.2f, rho = %.2f', lambda, rho));

subplot(2,2,2);
depth = 1./hsc;
depth = depth ./ max(depth(:));
imshow(depth);
title('OF depth');

subplot(2,2,3);
imshow(3*squeeze(lf(:,:,nV_2,nV_2,:)));
title('original');
        

Cdisp = sum(C,3);
Cdisp = Cdisp./max(Cdisp);
subplot(2,2,4);
imshow(Cdisp);
title('Confidence of OF');


