close all;
clear all;

% http://www.mathworks.com/help/images/ref/fspecial.html?searchHighlight=fspecial
% read file
[FileName,PathName,~] = uigetfile('*.jpg');
I = imread([PathName FileName]);

% create a Gaussian kernel
h = fspecial('Gaussian',[10 10],8);
figure,surf(h)

% smooth the image by imfilter
GaussianResult = imfilter(I,h,'same','conv','replicate');

% subplot command makes these two image displayed together
figure(1),subplot(2,1,1),imagesc(I),colormap(gray),axis image;
figure(1),subplot(2,1,2),imagesc(GaussianResult),colormap(gray),axis image;

% compute the gradient 
[Gx, Gy] = gradient(double(h));
Ix = imfilter(double(I),Gx,'same','conv','replicate');
Iy = imfilter(double(I),Gy,'same','conv','replicate');

figure(2),subplot(2,1,1),imagesc(Ix),colormap(gray),axis image;
figure(2),subplot(2,1,2),imagesc(Iy),colormap(gray),axis image;



