close all;
clear all;

% read, write etc.
% 1, a, b, and c
[FileName,PathName,~] = uigetfile('*.jpg');
I = imread([PathName FileName]);
figure,imagesc(I),axis image;

% 2
[x,y] = ginput(2);
hold on, plot([x(1) x(2) x(2) x(1) x(1)],[y(1) y(1) y(2) y(2) y(1)],'g'); hold off;

% 3
x = round(x);
y = round(y);
J = I(min(y):max(y),min(x):max(x),:);
figure,imagesc(J),axis image;

% 4
imwrite(J,'crop.jpg');