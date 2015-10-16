close all;
clear all;

% read an image
I = imread('cameraman.tif');

% create a Gaussian matrix using fspecial
h = fspecial('Gaussian',[101 101],15);

% use imfilter to smooth the image
J = imfilter(I,h,'same','conv','replicate');

figure(1),subplot(2,1,1),imagesc(I),colormap(gray),axis image;
figure(1),subplot(2,1,2),imagesc(J),colormap(gray),axis image;

[Gx,Gy] = gradient(double(h));
Ix = imfilter(double(I),Gx,'same','conv','replicate');
Iy = imfilter(double(I),Gy,'same','conv','replicate');

figure(2),subplot(2,1,1),imagesc(Ix),colormap(gray),axis image;
figure(2),subplot(2,1,2),imagesc(Iy),colormap(gray),axis image;

[Ixp,Iyp] = gradient(double(J));
figure(3),subplot(2,1,1),imagesc(Ixp),colormap(gray),axis image;
figure(3),subplot(2,1,2),imagesc(Iyp),colormap(gray),axis image;
