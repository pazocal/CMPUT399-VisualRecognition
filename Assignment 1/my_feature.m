function h = my_feature(I, B, b)
% I: input grayscale image
% B: mask image to indicate region of interest, i.e., where to compute histogram
% b: number of histogram bins
% h: b-dimensional histogram

% You will want to use the Matlab function "hist" for computing h only
% inside the region of interest

% There are two ways to deal with this function. I choose method 2 for this
% function

% Method 1 from:
% http://www.mathworks.com/matlabcentral/answers/38547-masking-out-image-area-using-binary-mask
% I = I.*uint8(B);

% Method 2 from:
% http://stackoverflow.com/questions/26876290/how-to-extract-region-of-interest-with-binary-mask

ROI = I;
ROI(b == 0) = 0;
[row,col] = size(I);
hist=imhist(ROI, b);

h=(hist/(row*col));

