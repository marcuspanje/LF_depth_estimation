%scale and display h

z = real(h);
zdisp = z-min(min(z));
zdisp = 1-(zdisp./max(max(zdisp)));
figure(1);
imshow(zdisp);
        
     

