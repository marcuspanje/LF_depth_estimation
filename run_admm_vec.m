%use confidence values as weights
Csc = sum(C,3);
Csc = mean_scale(Csc, 0, 2);
Csc(h<0) = 0;
offset = 0.3;
Csc = (1-offset)*Csc + offset;
Csc = Csc.^2;
%Csc = ones(sz_lf(1:2));

%run admm w TV prior
sz_h = size(h);
x = zeros(sz_h(1), sz_h(2));
z = zeros(sz_h(1), sz_h(2),3);
u = zeros(sz_h(1), sz_h(2),3);
rho = 10;
lambda = 0.01; 
thresh = lambda/rho;
b1 = Csc.*hsc;
%b1 = Csc .* h;
nIter = 30;
tol = 1e-10;
maxIter = 50;
%Afun is a function file that gets additional parameters
Afunline = @(x) Afun(x, sz_h, Csc, rho);
loss = zeros(nIter, 1);
loss2 = zeros(nIter, 1);
Kx = zeros(size(z));
pos_th = 0.001;
h_true = f*(focus_plane-depth_true)/((focus_plane-f)*depth_true);
for k = 1:nIter
  v = z-u;
  %pcg with (Ax = b), x, b are vectors
  b = b1 + rho*(opDtx(v(:,:,1:2)) + v(:,:,3));
  x = reshape(pcg(Afunline, b(:), tol, maxIter), sz_h(1), sz_h(2)); 

  Dxk = opDx(x);

  v = Dxk + u(:,:,1:2);  
  ind1 = v > thresh;
  ind2 = v < -thresh;
  z1 = zeros(sz_h(1), sz_h(2), 2);
  z1(ind1) = v(ind1)-thresh;
  z1(ind2) = v(ind2)+thresh;
  z(:,:,1:2) = z1;

  v = x + u(:,:,3); 
  z(:,:,3) = max(pos_th, v);
  Kx(:,:,1:2) = Dxk;
  Kx(:,:,3) = x;

  u = u + Kx - z;
  l1 = Csc.*((x-hsc).^2);
  l2 = abs(Dxk);
  l3 = sum(x(:) > pos_th);
  loss(k) = 0.5*sum(l1(:)) + lambda*(sum(l2(:)) + l3);
  loss2(k) = sumsqr(x-h_true);
end
