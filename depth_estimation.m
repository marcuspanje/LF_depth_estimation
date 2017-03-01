%{
img = 3*im2double(imread('lytro.png'));
sz = size(img);
nViews = 14;
%light field buffer
lf = zeros(sz(1)/nViews, sz(2)/nViews, nViews, nViews, 3);
for u = 1:nViews
  for v = 1:nViews
    lf(:,:,u,v,:) = img(u:nViews:end, v:nViews:end, :);
  end
end
save('lytro.mat', 'lf');
%}
%load('lytro.mat')

%indices of shift (centered at middle image)
%right , down in positive
nViews = 14;
nV_2 = round(nViews/2);
dvx = linspace(1,nViews,nViews)-nV_2;
dvy = linspace(1,nViews,nViews)-nV_2;
sz_lf = size(lf);

%size of patch
szP = 5;

Prows = 1:szP:sz_lf(1);
Prows = Prows(1:end-1);
Pcols = 1:szP:sz_lf(2); 
Pcols = Pcols(1:end-1);
h = zeros(length(Prows), length(Pcols));


for hi = 1:length(Prows)
  for hj = 1:length(Pcols)
    %in 1 patch now
    num = 0;
    den = 0;
    rows = Prows(hi):Prows(hi)+szP-1; 
    cols = Pcols(hj):Pcols(hj)+szP-1;
    center = lf(rows,cols,nV_2,nV_2,:);
    Iy = lf(rows,cols+1,nV_2,nV_2,:) - center;
    Ix = lf(rows+1,cols,nV_2,nV_2,:) - center;
    den = Ix.^2 + Iy.^2;
    den = sum(den(:));
    for vx = 1:nViews
      %calc grad w/o division by 0
      %Ivx = (lf(rows,cols,vx,nV_2,:) - center)./(dvx(vx) + (dvx(vx) == 0));
      %num1 = Ix.*Ivx;
      %num1 = sum(num1(:));
      for vy = 1:nViews
        %offset from center
        Ivx = (lf(rows,cols,vx,vy,:) - center)./(dvx(vx) + (dvx(vx) == 0));
        num1 = Ix.*Ivx;
        num1 = sum(num1(:));

        Ivy = (lf(rows,cols,vx,vy,:) - center)./(dvy(vy) + (dvy(vy)==0));
        num2 = Iy.*Ivy;
        num2 = sum(num2(:));
        h(hi,hj) = (num1 + num2)/den ;
      end
    end
  end
end

plotter
