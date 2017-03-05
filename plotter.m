%scale and display h
zdisp = real(ifft2(Fx));
%zdisp(z<0) = 0;
zdisp = zdisp-min(min(zdisp));
maxZ = max(zdisp(:));
zdisp = 1-(zdisp./maxZ);
figure(1);
imshow(zdisp);

h(h<0) = 0;
hdisp = h - min(h(:));
hdisp = 1 - (hdisp ./ max(hdisp(:)));
figure(2);
imshow(hdisp);
        
     

