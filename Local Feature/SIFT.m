close all;
clear all;

% http://www.mathworks.com/help/images/ref/fspecial.html?searchHighlight=fspecial
% read file
[FileName,PathName,~] = uigetfile('*.jpg');
I = imread([PathName FileName]);

I = rgb2gray(I);
figure,imagesc(I),colormap(gray),axis image;

I_resize = imresize(I,0.25);
figure,imagesc(I_resize),colormap(gray),axis image;

[x,y] = ginput(1);

for s = 3:4,
    I_resize = imresize(I,s);
    h = fspecial('log',[6*s+1,6*s+1],s);
    R = imfilter(I_resize,h,'same','conv','replicate');
end



% if (nargin <3),
%  error('Please see help for INPUT DATA.');
% elseif (nargin==3)
%     style='b-';
% end;
% THETA=linspace(0,2*pi,NOP);
% RHO=ones(1,NOP)*radius;
% [X,Y] = pol2cart(THETA,RHO);
% X=X+center(1);
% Y=Y+center(2);
% H=plot(X,Y,style);
% axis square;

