f1 = 0.026159;
l1 = 58.23825;
So = 0.38;
z1 = -348;
Si1 = 1/(1/f1 - 1/So);
Si1 = 1/(1/f1-1/l1);

f2 = 0.014043;
l2 = 19.12472;
z2 = 113;
Si2 = 1/(1/f2 - 1/So);
Si2 = 1/(1/f2-1/l2);


A = [z1 1; z2 1];
b = [(Si1*f1)/(Si1-f1); (Si2*f2)/(Si2-f2)];
b = [f1/(f1-Si1); f2/(f2-Si2)];
c = inv(A)*b;

fname = 'cars_1';
addpath('jsonlab-1.5/jsonlab-1.5');
data = loadjson('lf_images/maxF_minZ.json'); 
f = data.frames{1}.frame.metadata.devices.lens.focalLength;
L = data.frames{1}.frame.metadata.devices.lens.infinityLambda;
a = 1;
b = 2*f-L;
c = f^2;
t1 = -b/(2*a);
t2 = sqrt(b^2-4*a*c)/(2*a);
f1 = [t1+t2; t1-t2];
Si = f + f1;
So = 1./(1/f-1./Si) 

