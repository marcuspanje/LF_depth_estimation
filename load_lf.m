fname_all = sprintf('lf_images/%s/%s_eslf.png', fname, fname);
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

%get camera metatdata extracted from lytro .LFP file
%see https://github.com/nrpatel/lfptools on how to obtain this file
try
    data = loadjson(sprintf('lf_images/%s/%s.json', fname, fname)); 
    f = data.frames{1}.frame.metadata.devices.lens.focalLength;
    apertureDiameter = f/data.frames{1}.frame.metadata.devices.lens.fNumber;
    pxWidth = data.frames{1}.frame.metadata.devices.sensor.pixelPitch;
catch
    disp('no camera meta data found');
    f = 0.05;
    apertureDiameter = 0.006;
    pxWidth = 1e-6;
end
viewPitch = apertureDiameter/nViews;
pxPitch = nViews*pxWidth;
