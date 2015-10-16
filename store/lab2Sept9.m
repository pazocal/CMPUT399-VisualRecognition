close all;
clear all;

% image gradient
% 1
[FileName,PathName,~] = uigetfile('*.jpg');
I = imread([PathName FileName]);
figure,imagesc(I),axis image;

% 2
G = rgb2gray(I);
% [Gx,Gy] = my_gradient(double(G));
[Gx,Gy] = my_forloop_gradient(double(G));
% [Gx,Gy] = gradient(double(G));

% 3
Gm = sqrt(Gx.^2 + Gy.^2);
figure,imagesc(Gm),colormap(gray),axis image;

% 4
figure,quiver(Gx,Gy),axis ij;