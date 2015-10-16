close all;
clear all;

% read two images
I = imread('cameraman.tif');
J = imread('pout.tif');

% show the images
figure(1),subplot(2,1,1),imagesc(I),colormap(gray),axis image;
figure(1),subplot(2,1,2),imagesc(J),colormap(gray),axis image;

% compute histograms using imhist
hist1 = imhist(I,64);
hist1 = hist1/sum(hist1); % normalized histogram

hist2 = imhist(J,64);
hist2 = hist2/sum(hist2); % normalized histogram

% plot histograms
figure(2),subplot(2,1,1),plot(hist1);
figure(2),subplot(2,1,2),plot(hist2);

% compute Bhattacharya coefficient
BC = sum(sqrt(hist1).*sqrt(hist2));
disp(BC);