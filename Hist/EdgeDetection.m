close all;
clear all;

% read file
[FileName,PathName,~] = uigetfile('*.*');
I = imread([PathName FileName]);
G = rgb2gray(I)

% find the edge by Canny/Prewitt method
BW1 = edge(double(G),'canny');
BW2 = edge(double(G),'prewitt');

% display
imshowpair(BW1,BW2,'montage');