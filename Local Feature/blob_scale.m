close all
clear all

I = imread('pinkflower.jpg');
I = single(rgb2gray(I));
I = imresize(I,0.25);
figure(1),imagesc(I),colormap(gray),axis image;
[x,y] = ginput(1);
x = round(x);
y = round(y);
fact = 3;
resp = zeros(10,1);
for i = 1:15,
    hsize = 6*round(i*fact) + 1;
    h = fspecial('log',[hsize hsize], i*fact);
    J = imfilter(I,h,'same','conv','replicate');
    resp(i) = J(y,x);
end
figure(2),plot(fact*(1:15)',resp);
title('LoG filter response versus scale');
maxi = find(imregionalmax(resp));
% [maxv,maxi] = max(resp);
figure(1),hold on; circle([x,y],2*maxi(end)*fact,200,'-'); hold off;