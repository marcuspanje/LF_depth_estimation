%scale and display h
z = real(ifft2(Fx));
min_th = 20;
zpos = z(z > min_th);
mu = mean(zpos); sig = std(zpos);
max_th = mu + sig 
min_th = mu - sig 
zdisp = max(z, min_th);
zdisp = min(zdisp, max_th);
zdisp = (1./zdisp);
zdisp = zdisp./max(zdisp(:));
figure(1);
subplot(1,3,1);
imshow(zdisp);
title('OF map with admm');

hpos = h(h>min_th);
mu = mean(hpos); sig = std(hpos);
hdisp = max(h, min_th);
hdisp = min(hdisp, max_th);
hdisp = 1./hdisp;
hdisp = hdisp ./ max(hdisp(:));
subplot(1,3,2);
imshow(hdisp);
title('OF map');

subplot(1,3,3);
imshow(squeeze(lf(:,:,nV_2,nV_2,:)));
title('original');
        
     

