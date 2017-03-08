%use confidence values as weights
Csc = sum(C, 3);
maxCsc = mean(Csc(:)) + 0.5*std(Csc(:));
Csc = min(Csc, maxCsc); 
Csc = Csc ./ maxCsc;
Csc(h<0) = 0;

%run admm w TV prior
sz_h = size(h);
x = zeros(sz_h(1), sz_h(2));
z = zeros(sz_h(1), sz_h(2),2);
u = zeros(sz_h(1), sz_h(2),2);
Dx = [0 0 0; 1 -1 0; 0 0 0];
Dy = [0 1 0; 0 -1 0; 0 0 0];
FDx = psf2otf(Dx, sz_h(1:2));
FDy = psf2otf(Dy, sz_h(1:2));
FD = zeros(sz_h(1), sz_h(2),2);
FD(:,:,1) = FDx;
FD(:,:,2) = FDy;
FDT = conj(FD);
FDxT = conj(FDx);
FDyT = conj(FDy);
rho = 10;
lambda = 0.01; 
thresh = lambda/rho;

b1 = Csc.*hsc;
lenh = sz_h(1)*sz_h(2);
Afun = @(x) reshape(Csc.*reshape(x, sz_h) + ...
  real(rho*ifft2((FDxT.*FDx + FDyT.*FDy).*...
  fft2(reshape(x,sz_h)))),lenh, 1);

nIter = 30;
tol = 1e-10;
maxIter = 50;
for k = 1:nIter
  v = z-u;
  %pcg with (Ax = b), x, b are vectors
  b = b1 + rho*real(ifft2(sum(FDT.*fft2(v),3)));
  x = reshape(pcg(Afun, b(:), tol, maxIter), sz_h(1), sz_h(2)); 
  Dxk = real(ifft2(FD.*fft2(x)));
  v = Dxk + u;  
  ind1 = v > thresh;
  ind2 = v < -thresh;
  z(ind1) = v(ind1)-thresh;
  z(ind2) = v(ind2)+thresh;
  z(~(ind1|ind2)) = 0;
  u = u + Dxk - z;
end
