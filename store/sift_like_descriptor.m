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

% find out orientation of the descriptor at (x,y)
hsize = 6*round(scale) + 1;
h = fspecial('Gaussian',[hsize hsize],scale);
J = imfilter(I,h,'same','conv','replicate');

[Jx,Jy] = gradient(double(J));
theta = atan2(Jy(y,x),Jx(y,x));

% draw the gradient orientation as a line starting at (x, y)

x0 = x + scale*cos(theta);
y0 = y - scale*sin(theta);
figure(1),hold on, plot([x x0],[y y0],'r', 'LineWidth',5); hold off;

% draw a square of size 2*scale by 2*scale with orientation theta around
% (x, y)

x1 = x + sqrt(2)*scale*cos(theta+pi/4);
y1 = y - sqrt(2)*scale*sin(theta+pi/4);
x2 = x + sqrt(2)*scale*cos(theta+pi/4+pi/2);
y2 = y - sqrt(2)*scale*sin(theta+pi/4+pi/2);
x3 = x + sqrt(2)*scale*cos(theta+pi/4+pi/2+pi/2);
y3 = y - sqrt(2)*scale*sin(theta+pi/4+pi/2+pi/2);
x4 = x + sqrt(2)*scale*cos(theta+pi/4+pi/2+pi/2+pi/2);
y4 = y - sqrt(2)*scale*sin(theta+pi/4+pi/2+pi/2+pi/2);

figure(1),hold on, plot([x1 x2 x3 x4 x1],[y1 y2 y3 y4 y1],'g', 'LineWidth', 5); hold off;

% now divide the square into four smaller squares and compute 8 bin
% histogram of gradient orientations in each square
[~,B] = roifill(I,[x1 x2 x3 x4 x1],[y1 y2 y3 y4 y1]);
figure,imagesc(B),colormap(gray),axis image;

all_theta = atan2(Jy,Jx);
orient_hist = hist(all_theta(B),8);
figure,plot(orient_hist);

% dividing the square into four quadrants and computing 8 element vector in
% each
[~,B1] = roifill(I,[x1 (x1+x2)/2 x (x4+x1)/2 x1],[y1 (y1+y2)/2 y (y4+y1)/2 y1]);
[~,B2] = roifill(I,[(x1+x2)/2 x2 (x2+x3)/2 x],[(y1+y2)/2 y2 (y2+y3)/2 y]);
[~,B3] = roifill(I,[(x2+x3)/2 x3 (x3+x4)/2 x],[(y2+y3)/2 y3 (y3+y4)/2 y]);
[~,B4] = roifill(I,[x (x3+x4)/2 x4 (x1+x4)/2],[y (y3+y4)/2 y4 (y1+y4)/2]);

% concatenate descriptors within 
v = [hist(all_theta(B1),8) hist(all_theta(B2),8) hist(all_theta(B3),8) hist(all_theta(B4),8)];
figure,plot(v);

