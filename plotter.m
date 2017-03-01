
%scale and display h
maxVal = 0.2;
hsc = zeros(size(h));
hsc(h>0) = max(h(h>0),maxVal);
hsc(h<0) = min(h(h<0),-maxVal);
z = 1./hsc;
zdisp = z-min(min(z));
zdisp = zdisp./max(max(zdisp));
figure(1);
imshow(zdisp);
        
     

