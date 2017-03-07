fname_all = sprintf('%s.png', fname);
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
