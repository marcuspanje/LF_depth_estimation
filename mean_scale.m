%function that scales an image by multiples of the mean
function x_sc = mean_scale(x, minCoeff, maxCoeff);
    me = mean(x(x>0));
    st = std(x(x>0));
    x = max(x, me - minCoeff*st);
    x = min(x, me + maxCoeff*st); 
    x = x - min(x(:));
    x_sc = x ./ max(x(:));
    

