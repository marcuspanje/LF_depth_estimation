%run_params
%1 - run alg from the start
%2 - run after lf is in memory
%3 - run after the noisy depth map, h, is in memory
run_params = 1;
fname = 'people_14_eslf';
if run_params < 2
  disp('loading lf image');
  fname_all = sprintf('lf_images/%s.png', fname);
  img = im2double(imread(fname_all));
  sz = size(img);
  nViews = 14;
  %light field buffer
  lf = zeros(sz(1)/nViews, sz(2)/nViews, nViews, nViews, 3);
  for u = 1:nViews
    for v = 1:nViews
      lf(:,:,u,v,:) = img(u:nViews:end, v:nViews:end, :);
    end
  end
end


if run_params < 3
  %indices of shift (centered at middle image)
  %right , down in positive
  nViews = 14;
  nV_2 = round(nViews/2);
  dvx = (linspace(1,nViews,nViews)-nV_2);
  dvy = linspace(1,nViews,nViews)-nV_2;
  sz_lf = size(lf);
  valid = logical(zeros(nViews, nViews)); 
  validImagesPerRow = [0 6 8 10 10 10 10 10 10 10 10 8 6 0]; 
  for i = 1:nViews
    n = validImagesPerRow(i)/2;
    valid(i, nV_2-n+1:nV_2+n) = logical(1);
  end
   
  %size of patch
  szP = 3; %should be odd
  %FK = fft2(ones(szP), sz_lf(1), sz_lf(2));
  FK = psf2otf(ones(szP), sz_lf(1:2));

  %dvx(pos shift) and dx(pixel shift) must be of the same scale
  %set dvx = 1 for an image 1 position shift away. 
  %1 image row has sz_lf(1) px, so 
  %dx = 1/sz_lf(1) 
  disp('precompute gradients');
  Ix = zeros(sz_lf(1), sz_lf(2), 1, 1, 3);
  Iy = zeros(sz_lf(1), sz_lf(2), 1, 1, 3); 
  Ix(1:end-1,:,:,:,:) = (lf(2:end,:,nV_2, nV_2,:) - lf(1:end-1,:,nV_2, nV_2,:))./sz_lf(1);
  Iy(:,1:end-1,:,:,:) = (lf(:,2:end,nV_2, nV_2,:) - lf(:,1:end-1,nV_2, nV_2,:))./sz_lf(2);
  %Ix(1:end-1,:,:,:,:) = (lf(2:end,:,nV_2, nV_2,:) - lf(1:end-1,:,nV_2, nV_2,:));
  %Iy(:,1:end-1,:,:,:) = (lf(:,2:end,nV_2, nV_2,:) - lf(:,1:end-1,nV_2, nV_2,:));
  C = squeeze(Ix.^2 + Iy.^2);
  K_Ix2_Iy2 = ifft2(FK.*fft2(C));

  diffV = lf - lf(:,:,nV_2,nV_2,:);
  Ix_diffV = diffV .* Ix;
  Iy_diffV = diffV .* Iy;

  disp('compute optical flow');
  %compute optical flow about center image
  Fnum = zeros(sz_lf(1:2));
  den = zeros(sz_lf(1:2));
  for vx = 1:nViews
    for vy = 1:nViews
      if ~valid(vx,vy)
        continue;
      end
      for c = 1:3
        Fnum = Fnum + FK.*fft2(Ix_diffV(:,:,vx,vy,c)./(dvx(vx) + (dvx(vx) == 0)));
        Fnum = Fnum + FK.*fft2(Iy_diffV(:,:,vx,vy,c)./(dvy(vy) + (dvy(vy) == 0)));
        den = den + K_Ix2_Iy2(:,:,c);
      end
    end
  end


  real_den = real(den);
  real_den(real_den <= 0) = 1;
  
  %h = real(ifft2(Fnum))./real_den;
  h = real(ifft2(Fnum) ./ den);  

end


disp('run admm');
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
lambda = 3; 
thresh = lambda/rho;

Fnum1 = FIT.*fft2(h);
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

plotter


