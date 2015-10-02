% initialization
close all;
clear all;

% read, write etc.
[FileName,PathName,~] = uigetfile('*.jpg');
I = imread([PathName FileName]);
figure,imagesc(I),axis image;

% select the area by selecting two opposite vertices. 
[x,y] = ginput(2);
hold on, plot([x(1) x(2) x(2) x(1) x(1)],[y(1) y(1) y(2) y(2) y(1)],'g'); hold off;

% Round to nearest decimal or integer
x = round(x);
y = round(y);
J = I(min(y):max(y),min(x):max(x),:);
figure,imagesc(J),axis image;

% write the result to crop.jpg
imwrite(J,'crop.jpg');
