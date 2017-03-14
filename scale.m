%I = im2double(imread('lf_images/books_4/books_4_depth.png'));
I = repmat(flipud((1:100)'), 1, 30); 
I = I./max(I(:));
I_hsv = ones(size(I, 1), size(I, 2), 3);
I_hsv(:,:,1) = 0.75*I;
imshow(hsv2rgb(I_hsv));

