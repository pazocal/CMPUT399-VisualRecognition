function h = my_feature(I, B, b)
% I: input grayscale image
% B: mask image to indicate where to compute histogram
% b: number of histogram bins
% h: b-dimensional histogram

% You will want to use the Matlab function "hist" for computing h
% normalize h so that sum(h) = 1.

h=imhist(I(B), b);% compute the histogram of image 'I' with 'b' bins
% using only those pixels where 'B' is not 0
h=h(:)./sum(h);% normalize the histogram