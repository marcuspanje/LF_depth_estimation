%%% compute optical flow %%%
%computes pixel gradients(Dx) and viewpoint gradients(Dv) to estimate  
%h: (shift in viewpoint)/(shift in pixel) 
%Dx_x I(i,j) = I(i+1,j) - I(i,j)  
%Dx_y I(i,j) = I(i,j+1) - I(i,j)  
%Dv_x I(i,j) = I(,,vx+1,vy) - I(,,vx,vy)
%Dv_y I(i,j) = I(,,v,vy+1) - I(,,vx,vy)


%indices of shift (centered at middle image)
%right , down in positive
sz_lf = size(lf);
nViews = sz_lf(3);
nV_2 = round(nViews/2);
%pitch of pixel and viewing dist
%pxPitch = data.frames{1}.frame.metadata.devices.sensor.pixelPitch;
%vPitch = data.frames{1}.frame.metadata.devices.mla.lensPitch;
%shift in pixel, and viewpoint should be the same units,
%so estimate the baseline of 1 viewpoint shift along an axis
%as #pixels in an image along that axis
%viewPitch = sz_lf(1);
dvx = viewPitch*(linspace(1,nViews,nViews)-nV_2);
dvy = viewPitch*(linspace(1,nViews,nViews)-nV_2);

%mark valid viewpoints. viewpoints near corners are invalid
valid = logical(zeros(nViews, nViews)); 
validImagesPerRow = [0 6 8 10 10 10 10 10 10 10 10 8 6 0]; 
for i = 1:nViews
  n = validImagesPerRow(i)/2;
  valid(i, nV_2-n+1:nV_2+n) = logical(1);
end

valid = logical(ones(nViews, nViews));
 

%take center view as reference point
%compute h value of each pixel by estimating by the h-value for its
%surrounding patch 
szP = 3; %should be odd
FK = psf2otf(ones(szP), sz_lf(1:2)); %convolution kernel for patch averaging
%pixel gradients
Ix = zeros(sz_lf(1), sz_lf(2), 1, 1, 3);
Iy = zeros(sz_lf(1), sz_lf(2), 1, 1, 3); 
%pxPitch = 1;
Ix(1:end-1,:,:,:,:) = (lf(2:end,:,nV_2, nV_2,:) - lf(1:end-1,:,nV_2, nV_2,:))/(pxPitch);
Iy(:,1:end-1,:,:,:) = (lf(:,2:end,nV_2, nV_2,:) - lf(:,1:end-1,nV_2, nV_2,:))/(pxPitch);
%C is confidence value, the sum of gradients at a pixel
C = squeeze(Ix.^2 + Iy.^2);
K_Ix2_Iy2 = real(ifft2(FK.*fft2(C)));

%viewpoint gradient
diffV = lf - lf(:,:,nV_2,nV_2,:);
Ix_diffV = diffV .* Ix;
Iy_diffV = diffV .* Iy;

Fnum = zeros(sz_lf(1:2));
den = zeros(sz_lf(1:2));
%for loop over every valid view and color
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

h = real(ifft2(Fnum) ./ den);  
hsc = mean_scale(h, 0.1, 10);
