%{
fname = 'cars_1_eslf';
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
%}

%indices of shift (centered at middle image)
%right , down in positive
nViews = 14;
nV_2 = round(nViews/2);
dvx = linspace(1,nViews,nViews)-nV_2;
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
cP_2 = (szP-1)/2;

Prows = 1:szP:sz_lf(1);
Prows = Prows(1:end-1);
Pcols = 1:szP:sz_lf(2); 
Pcols = Pcols(1:end-1);

h = zeros(sz_lf(1:2));

Ix = zeros(sz_lf(1), sz_lf(2), 1, 1, 3);
Iy = zeros(sz_lf(1), sz_lf(2), 1, 2, 3); 
%compute optical flow about center image
for x = cP_2+1:sz_lf(1)-cP_2-1
  for y = cP_2+1:sz_lf(2)-cP_2-1 
    %for each pixel, form surrounding patch
    rows = x-cP_2:x+cP_2;
    cols = y-cP_2:y+cP_2;
    center = lf(rows,cols,nV_2,nV_2,:);
    Iy = lf(rows,cols+1,nV_2,nV_2,:) - center;
    Ix = lf(rows+1,cols,nV_2,nV_2,:) - center;
    den1 = Ix.^2 + Iy.^2;
    den1 = sum(den1(:));
    den = 0;
    num = 0;
    for vx = 1:nViews
      for vy = 1:nViews
        %offset from center
        if valid(vx,vy)%some pictures like image edges are invalid
          Ivx = (lf(rows,cols,vx,vy,:) - center)./(dvx(vx) + (dvx(vx) == 0));
          Ivy = (lf(rows,cols,vx,vy,:) - center)./(dvy(vy) + (dvy(vy)==0));
          num1 = Ix.*Ivx + Iy.*Ivy;
          num = num + sum(num1(:));
          den = den + den1;
        end
      end
    end
    h(x,y) = num/den;
  end
end

plotter
