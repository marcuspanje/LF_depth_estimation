%use confidence values as weights
Csc = sum(C,3);
Csc = mean_scale(Csc, 0, 2);
%don't let it go completely to 0
offset = 0.3;
Csc = (1-offset)*Csc + offset;
Csc = Csc.^2;
%Csc = ones(sz_lf(1:2));

%run admm w TV prior
sz_h = size(h);
x = zeros(sz_h(1), sz_h(2));
z = zeros(sz_h(1), sz_h(2),2);
u = zeros(sz_h(1), sz_h(2),2);
rho = 10;
lambda = 0.001; 
thresh = lambda/rho;
Afunline = @(x) Afun(x, sz_h, Csc, rho);
%soft_thresholding function
soft_thresh = @(v, soft_th) sign(v).*max(abs(v) - soft_th,0);

b1 = Csc .* h;
nIter = 30; %nIterations for ADMM

%tol and maxIter are for pcg function
tol = 1e-10;
maxIter = 50;
%Afun is a function file that gets additional parameters
loss = zeros(nIter, 1);
loss2 = zeros(nIter, 1);
Kx = zeros(size(z));
max_d = 5;
h_true = LF.disp_lowres;
for k = 1:nIter
  v = z-u;
  %pcg with (Ax = b), x, b are vectors
  b = b1 + rho*(opDtx(v(:,:,1:2)));
  x = reshape(pcg(Afunline, b(:), tol, maxIter), sz_h(1), sz_h(2)); 

  Dxk = opDx(x);

  v = Dxk + u;  
  z = soft_thresh(v, thresh);

  u = u + Dxk - z;
  l1 = (Csc.*(x-h)).^2;
  l2 = abs(Dxk);
  loss(k) = 0.5*sum(l1(:)) + lambda*sum(l2(:));
  loss2(k) = sumsqr(x-h_true);
end
