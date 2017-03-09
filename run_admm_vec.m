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
rho = 10;
lambda = 0.01; 
thresh = lambda/rho;
b1 = Csc.*hsc;
nIter = 30;
tol = 1e-10;
maxIter = 50;
Afunline = @(x) Afun(x, sz_h, Csc);
for k = 1:nIter
  v = z-u;
  %pcg with (Ax = b), x, b are vectors
  b = b1 + rho*opDtx(v);
  x = reshape(pcg(Afunline, b(:), tol, maxIter), sz_h(1), sz_h(2)); 
  Dxk = opDx(x);
  v = Dxk + u;  
  ind1 = v > thresh;
  ind2 = v < -thresh;
  z(ind1) = v(ind1)-thresh;
  z(ind2) = v(ind2)+thresh;
  z(~(ind1|ind2)) = 0;
  u = u + Dxk - z;
end
