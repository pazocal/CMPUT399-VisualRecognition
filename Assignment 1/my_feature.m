function h = my_feature(I, B, b)
% I: input grayscale image
% B: mask image to indicate region of interest, i.e., where to compute histogram
% b: number of histogram bins
% h: b-dimensional histogram

% You will want to use the Matlab function "hist" for computing h only
% inside the region of interest
% normalize h so that sum(h) = 1.