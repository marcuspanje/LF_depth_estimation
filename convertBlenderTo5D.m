%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  This file is part of the 4D Light Field Benchmark.                      %
%                                                                          %
%  This work is licensed under the Creative Commons                        %
%  Attribution-NonCommercial-ShareAlike 4.0 International License.         %
%  To view a copy of this license,                                         %
%  visit http://creativecommons.org/licenses/by-nc-sa/4.0/.                %
%                                                                          %
%  Authors: Katrin Honauer & Ole Johannsen                                 %
%  Contact: contact@lightfield-analysis.net                                %
%  Website: www.lightfield-analysis.net                                    %
%                                                                          %
%  The 4D Light Field Benchmark was jointly created by the University of   %
%  Konstanz and the HCI at Heidelberg University. If you use any part of   %
%  the benchmark, please cite our paper "A dataset and evaluation          %
%  methodology for depth estimation on 4D light fields". Thanks!           %
%                                                                          %
%  @inproceedings{honauer2016benchmark,                                    %
%    title={A dataset and evaluation methodology for depth estimation on   %
%           4D light fields},                                              %
%    author={Honauer, Katrin and Johannsen, Ole and Kondermann, Daniel     %
%            and Goldluecke, Bastian},                                     %
%    booktitle={Asian Conference on Computer Vision},                      %
%    year={2016},                                                          %
%    organization={Springer}                                               %
%    }                                                                     %
%                                                                          %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [ outname ] = convertBlenderTo5D( dataFolder,varargin)
%./lib contains the ini parser and the pfm IO files
addpath('./lib');

p = inputParser;

%currently we just have one parameter... so the input parser might seem
%like an overkill
addRequired (p,'dataFolder',@ischar);

parse(p,dataFolder,varargin{:});

dataFolder   = p.Results.dataFolder;

%% read ini file
cfgfile=[dataFolder '/parameters.cfg'];

ini = IniConfig();
ini.ReadFile(cfgfile);
sections = ini.GetSections();

for iIni=1:3 %intrinsics extrinsics meta
    [keys, ~] = ini.GetKeys(sections{iIni});
    values = ini.GetValues(sections{iIni}, keys);
    for iKeys=1:length(keys)
        LF.parameters.(sections{iIni}(2:end-1)).(keys{iKeys})=values{iKeys};
    end
end

LFsize=[LF.parameters.extrinsics.num_cams_y,LF.parameters.extrinsics.num_cams_x,LF.parameters.intrinsics.image_resolution_y_px,LF.parameters.intrinsics.image_resolution_x_px,3];
LF.f=LF.parameters.extrinsics.focus_distance_m*1000;

Hx = LF.parameters.intrinsics.sensor_size_mm*LF.parameters.intrinsics.image_resolution_x_px/max(LF.parameters.intrinsics.image_resolution_x_px,LF.parameters.intrinsics.image_resolution_y_px)/LF.parameters.intrinsics.focal_length_mm*LF.f;
Hy = LF.parameters.intrinsics.sensor_size_mm*LF.parameters.intrinsics.image_resolution_y_px/max(LF.parameters.intrinsics.image_resolution_x_px,LF.parameters.intrinsics.image_resolution_y_px)/LF.parameters.intrinsics.focal_length_mm*LF.f;


centerview=(LFsize(1:2)+1)/2;

% H matrix as in Donald Dansereaus Light Field Toolbox
LF.H=[LF.parameters.extrinsics.baseline_mm 0 0 0 -centerview(1)*LF.parameters.extrinsics.baseline_mm;...
      0 LF.parameters.extrinsics.baseline_mm 0 0 -centerview(2)*LF.parameters.extrinsics.baseline_mm;...
      0 0 Hy/(LFsize(3)-1) 0   -Hy/2-Hy/(LFsize(3)-1);...
      0 0 0  Hx/(LFsize(4)-1)  -Hx/2-Hx/(LFsize(4)-1);...
      0 0 0 0 1]; 

  
  
imageFiles = dir([dataFolder '/input*.png']);      
nfiles = length(imageFiles);    % Number of files found
data=imread([dataFolder  '/' imageFiles(1).name]);
assert(LFsize(3)==size(data,1),'data dimension missmatch');
assert(LFsize(4)==size(data,2),'data dimension missmatch');
assert(LFsize(5)==size(data,3),'data dimension missmatch');

LF.LF=zeros(LFsize);



for i=1:nfiles
    currentfilename=imageFiles(i).name;

    data=imread([dataFolder  '/' currentfilename]);

    data=double(data)/double(intmax(class(data)));


    [t,s]=ind2sub(LFsize(1:2),i);
    LF.LF(s,t,:,:,:)=data;
end

if exist([dataFolder '/gt_depth_highres.pfm'], 'file') == 2
    LF.depth_highres=pfmread([dataFolder '/gt_depth_highres.pfm']);
end

if exist([dataFolder '/gt_disp_highres.pfm'], 'file') == 2
    LF.disp_highres=pfmread([dataFolder '/gt_disp_highres.pfm']);
end

if exist([dataFolder '/gt_depth_lowres.pfm'], 'file') == 2
    LF.depth_lowres=pfmread([dataFolder '/gt_depth_lowres.pfm']);
end

if exist([dataFolder '/gt_disp_lowres.pfm'], 'file') == 2
    LF.disp_lowres=pfmread([dataFolder '/gt_disp_lowres.pfm']);
end
if exist([dataFolder '/objectids_highres.png'], 'file') == 2
    LF.mask=imread([dataFolder '/objectids_highres.png']);
end    

if exist([dataFolder '/centerview_highres.png'], 'file') == 2
    LF.centerview=imread([dataFolder '/centerview_highres.png']);
end

%no normals for now...
%     if exist([dataFolder 'gt_normal.png'], 'file') == 2
%        LF.normal=imread([dataFolder '/gt_normal.png']);
%        LF.normal=single(LF.normal)/single(intmax(class(LF.normal)));
%     end      

outname=[dataFolder '/LF.mat'];
save(outname,'LF','-v7.3');


end

