%function that scales an image by multiples of the mean
function x_sc = mean_scale(x, minCoeff, maxCoeff);
    me = mean(x(x>0));
    x = max(x, minCoeff*me);
    x = min(x, maxCoeff*me); 
    x_sc = x ./ max(x(:));
    

