%scale and display h
z = real(ifft2(Fx));
pos = z(z > 0);
mu = mean(pos); 
max_th = 1.5*mu;
min_th = 0.5*mu;
zdisp = max(z, min_th);
zdisp = min(zdisp, max_th);
zdisp = (1./zdisp);
zdisp = zdisp./max(zdisp(:));
figure(1);
subplot(2,2,1);
imshow(zdisp);
title(sprintf('OF depth with admm, lambda = %.2f, rho = %.2f', lambda, rho));

hdisp = max(h, min_th);
hdisp = min(hdisp, max_th);
hdisp = 1./hdisp;
hdisp = hdisp ./ max(hdisp(:));
subplot(2,2,2);
imshow(hdisp);
title('OF depth');

subplot(2,2,3);
imshow(3*squeeze(lf(:,:,nV_2,nV_2,:)));
title('original');
        

Cdisp = sum(C,3);
Cdisp = Cdisp./max(Cdisp);
subplot(2,2,4);
imshow(Cdisp);
title('Confidence of OF');
