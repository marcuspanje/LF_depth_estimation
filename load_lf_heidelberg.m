load(sprintf('%s/%s.mat', foldername, fname));
nViews = size(LF.LF, 1);
w = size(LF.LF, 3);
lf = zeros(w,w,nViews,nViews,3);
for u = 1:nViews
  for v = 1:nViews
    lf(:,:,u,v,:) = LF.LF(u,v,:,:,:);
  end
end

f = LF.parameters.intrinsics.focal_length_mm/1000;
pxPitch = 1;
viewPitch = 1;
focus_plane = LF.parameters.extrinsics.focus_distance_m;
depth_true = LF.depth_lowres;
baseline = LF.parameters.extrinsics.baseline_mm/1000;
SensorWidthPx = max(LF.parameters.intrinsics.image_resolution_x_px,LF.parameters.intrinsics.image_resolution_y_px);
SensorWidth = LF.parameters.intrinsics.sensor_size_mm/1000;
h_true = LF.disp_lowres;

getDepth=@(disparity) (baseline*f*focus_plane*SensorWidthPx)./(disparity*focus_plane*SensorWidth + baseline*f*SensorWidthPx); 
