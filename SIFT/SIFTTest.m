close all
clear all

I = imread('Picture1.jpg');
I = single(rgb2gray(I));
% I = imresize(I,0.25);

figure(1),imagesc(I),colormap(gray),axis image;
x = 346; y = 131;
figure(1),hold on, plot(x,y,'*'); hold off;
resp = zeros(15,1);
for i = 1:15,
    hsize = 6*round(i) + 1;
    h = fspecial('log',[hsize hsize], i);
    J = imfilter(I,h,'same','conv','replicate');
    resp(i) = J(y,x);
end
figure(2),plot((1:15)',resp);
title('LoG filter response versus scale');
maxi = find(imregionalmax(resp));
scale = maxi(end);
figure(1),hold on; circle([x,y],scale,200,'-'); hold off; axis image;


hsize = 6 * scale + 1;
h = fspecial('Gaussian',[hsize hsize],scale);
J = imfilter(I,h,'same','conv','replicate');
figure(2),imagesc(J),colormap(gray),axis image;

[Jx,Jy] = gradient(double(J));
theta = atan2(Jy(x,y),Jx(x,y));
thetat = atan2(Jy,Jx);

% atan2 funtion for compute
% we want the direction for a particular point [x,y]'

xt = x + scale*cos(theta);
yt = y - scale*sin(theta);


x1 = xt + scale*cos(theta-pi/2)*sqrt(2);
y1 = yt - scale*sin(theta-pi/2)*sqrt(2);

x2 = xt + scale*cos(theta-pi/2)*sqrt(2);
y2 = yt - scale*sin(theta-pi/2)*sqrt(2);

x3 = xt + scale*cos(theta-pi/2)*sqrt(2);
y3 = yt - scale*sin(theta-pi/2)*sqrt(2);

x4 = xt + scale*cos(theta-pi/2)*sqrt(2);
y4 = yt - scale*sin(theta-pi/2)*sqrt(2);
hold on; plot([], 'g'); hold off;






