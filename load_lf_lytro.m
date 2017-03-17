img = im2double(imread(sprintf('%s/%s_eslf.png', foldername, fname)));
sz = size(img);
nViews = 14;
%light field buffer
lf = zeros(sz(1)/nViews, sz(2)/nViews, nViews, nViews, 3);
for u = 1:nViews
  for v = 1:nViews
    lf(:,:,u,v,:) = img(u:nViews:end, v:nViews:end, :);
  end
end
sz_lf = size(lf);

pxPitch = 1;
viewPitch = 1;
h_true = zeros(sz_lf(1:2));
depth_true = zeros(sz_lf(1:2));
getDepth = @(disparity) (1./(disparity - min(disparity(:)) + 1));

