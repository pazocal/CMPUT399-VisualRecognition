close all;
clear all;

[FileName,PathName,~] = uigetfile('*.*');
I = imread([PathName FileName]);
G = rgb2gray(I)

hist1 = imhist(G,64);
figure(1), imagesc(G),colormap(gray),axis image;

hist2 = imhist(G,16);
figure(2),subplot(2,1,1),plot(hist1);
figure(2),subplot(2,1,2),plot(hist2);