sz_h = size(h);
%run admm w TV prior
x = zeros(sz_h(1), sz_h(2));
z = zeros(sz_h(1), sz_h(2),2);
u = zeros(sz_h(1), sz_h(2),2);
Dx = [0 0 0; 0 -1 1; 0 0 0];
Dy = [0 0 0; 0 -1 0; 0 1 0];
FDx = psf2otf(Dx, sz_h(1:2));
FDy = psf2otf(Dy, sz_h(1:2));
FD = zeros(sz_h(1), sz_h(2),2);
FD(:,:,1) = FDx;
FD(:,:,2) = FDy;
FDT = conj(FD);
FDxT = conj(FDx);
FDyT = conj(FDy);
FI = psf2otf([0 0 0; 0 1 0; 0 0 0], sz_h(1:2));
FIT = conj(FI);
rho = 10;
lambda = 0.01; 
thresh = lambda/rho;

Fnum1 = FIT.*fft2(hsc);
Fden = FIT.*FI + rho*(FDxT.*FDx + FDyT.*FDy);
nIter = 30;
for k = 1:nIter
  v = z-u;
  Fnum = Fnum1 + rho*(sum(FDT.*fft2(v),3));
  Fx = (Fnum ./Fden); 
  Dxk = ifft2(FD.*Fx);
  v = Dxk + u;  
  ind1 = v > thresh;
  ind2 = v < -thresh;
  z(ind1) = v(ind1)-thresh;
  z(ind2) = v(ind2)+thresh;
  z(~(ind1|ind2)) = 0;
  u = u + Dxk - z;
end
z = real(ifft2(Fx));
