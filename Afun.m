function [Afunx] = Afun(x, sz_h, Csc)
  xmat = reshape(x, sz_h(1), sz_h(2));
  Ax = Csc.*xmat + opDtx(opDx(xmat));
  Afunx = Ax(:);
end
