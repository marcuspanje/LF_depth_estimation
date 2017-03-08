C1 = sum(C,3);
max_thc = mean(C1(:)) + 0.5*std(C1(:));
C1disp = min(C1, max_thc);
figure(2);
C1disp = C1disp ./max(C1disp);
C1(h<0) = 0;
C1(h>max_th) = 0.5;
imshow(C1disp./max(C1disp));

