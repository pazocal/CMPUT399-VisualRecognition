close all;
clear all;

% read two files
[FileName,PathName,~] = uigetfile('*.*');
I = imread([PathName FileName]);
I = rgb2gray(I);
[FileName,PathName,~] = uigetfile('*.*');
J = imread([PathName FileName]);
J = rgb2gray(J);

% compute two normalized histogram
hist1 = imhist(I,64);
hist1 = hist1/sum(hist1);
hist2 = imhist(J,64);
hist2 = hist2/sum(hist2);

% plot histograms
figure(2),subplot(2,1,1),plot(hist1);
figure(2),subplot(2,1,2),plot(hist2);

% compute BC
BC = sum(sqrt(hist1).*sqrt(hist2));
disp(BC)