%use confidence values as weights
Csc = sum(C,3);
Csc = mean_scale(Csc, 0.1, 2);
%Csc(h<0) = 0;
offset = 0.2;
Csc = (1-offset)*Csc + offset;
%Csc = ones(sz_lf(1:2));

%run admm w TV prior
sz_h = size(h);
x = zeros(sz_h(1), sz_h(2));
z = zeros(sz_h(1), sz_h(2),2);
u = zeros(sz_h(1), sz_h(2),2);
rho = 10;
lambda = 0.05; 
thresh = lambda/rho;
b1 = Csc.*hsc;
nIter = 30;
tol = 1e-10;
maxIter = 50;
%Afun is a function file that gets additional parameters
Afunline = @(x) Afun(x, sz_h, Csc, rho);
loss = zeros(nIter, 1);
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
  l1 = Csc.^2.*((x-hsc).^2);
  l2 = abs(Dxk);
  loss(k) = 0.5*sum(l1(:)) + lambda*sum(l2(:));
end
