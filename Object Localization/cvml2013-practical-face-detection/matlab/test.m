% set up factors
clear all;
level=2;
factor=1.5;
rawdata = load('raw.mat');
hogdata = load('hog.mat');

%%%%%%%%%%%%%%% load test image
%%%%%%%%%%%%%%%
% imgfname='img1.jpg';
imgfname='test_img.jpg';
img=imread(imgfname);
img=rgb2gray(img);
% showimage(img), title(imgfname)
gimg=mean(img,3);


GI = GaussianPyramid(gimg,level,factor)
%%%%%%%%%%%%%%% decompose the image into sub-windows
%%%%%%%%%%%%%%%
W_raw=(rawdata.yalpha'*rawdata.Xsup)';
[ysz,xsz,csz]=size(img);
wxsz=24; wysz=24;

for j=1:level
    [x,y]=Stage1Detector(double(GI{j}),reshape(W_raw,24,24));
    x=x*(factor^(j-1)); y=y*(factor^(j-1));
%     [x,y]=meshgrid(1:xsz-wxsz,1:ysz-wysz);
%     bbox=[x(:)-wxsz/2 y(:)-wysz/2 x(:)+wxsz/2-1 y(:)+wysz/2-1];
    bbox=[x(:)-wxsz y(:)-wysz x(:)+wxsz-1 y(:)+wysz-1]
    
    ctemp=[1,1,0]
    clf, showimage(img), showbbox(bbox,ctemp);
    n=size(bbox,1);
    fprintf('Wait'),pause,fprintf('\n');
    
    imgcropall=zeros(wysz,wxsz,length(x(:)));
%     for i=1:size(bbox,1)
%       imgcropall(:,:,i)=cropbbox(gimg,bbox(i,:));
%     end
% 
%     imgcropall=zeros(wysz,wxsz,length(x(:)));
%     cellSize=8;
%     for k=1:size(imgcropall,3)
%         hog = vl_hog(single(imgcropall(:,:,i)), cellSize, 'verbose');
%         reX = reshape(hog,[3*3*31 1]);
%         Xhogneg(i,:) = reX;
%     end
    
    
end

% 
% %%%%%%%%%%%%%%% Linear SVM classifier can be evaluated efficiently by
% %%%%%%%%%%%%%%% using dot-product between image patches and W. Before
% %%%%%%%%%%%%%%% computing the confidence we need to normalize and reshape
% %%%%%%%%%%%%%%% test image patches.
% 
imgcropall=meanvarpatchnorm(imgcropall);
X=transpose([reshape(imgcropall,wysz*wxsz,n)]);
conf=X*rawdata.Wbest-rawdata.bbest;



n=20;
[vs,is]=sort(conf,'descend');
clf, showimage(img), showbbox(bbox(is(1:n),:))
title(sprintf('%d best detections',n),'FontSize',14)
fprintf('press a key...'), pause, fprintf('\n')

% %%%%%%%%%%%%%%% **************************************************************
% %%%%%%%%%%%%%%% **************************************************************
% %%%%%%%%%%%%%%% *                                                            *
% %%%%%%%%%%%%%%% *                       EXERCISE 3:                          *
% %%%%%%%%%%%%%%% *                                                            *
% %%%%%%%%%%%%%%% *        Non-maxima suppression of multiple responses        *
% %%%%%%%%%%%%%%% *                                                            *
% %%%%%%%%%%%%%%% **************************************************************
% %%%%%%%%%%%%%%% **************************************************************
% %%%%%%%%%%%%%%%
% %%%%%%%%%%%%%%% Scanning-window style classification of image patches typically
% %%%%%%%%%%%%%%% results in many multiple responses around the target object.
% %%%%%%%%%%%%%%% A standard practice to deal with this is to remove any detector
% %%%%%%%%%%%%%%% responses in the neighborhood of detections with locally maximal
% %%%%%%%%%%%%%%% confidence scores (non-maxima suppression or NMS). NMS is
% %%%%%%%%%%%%%%% usually applied to all detections in the image with confidence
% %%%%%%%%%%%%%%% above certain threshold.
% %%%%%%%%%%%%%%%
% %%%%%%%%%%%%%%% TODO:
% %%%%%%%%%%%%%%% 3.1 Try out different threshold values to pre-selected windows
% %%%%%%%%%%%%%%%     passed to the NMS stage, see parameter 'confthresh' below.
% %%%%%%%%%%%%%%% 3.2 Try out different threshold values for NMS detections,
% %%%%%%%%%%%%%%%     see parameter 'confthreshnms'
% %%%%%%%%%%%%%%% 3.3 Try detection and with different thresholds for different
% %%%%%%%%%%%%%%%     included images: 'img1.jpg', 'img2.jpg', 'img3.jpg', 'img4.jpg'
% %%%%%%%%%%%%%%% 
threcan = [4.3 4.4 4.5 4.6 4.7];
for i=1:length(threcan)
    confthresh=threcan(i);
    % confthresh=4.45;
    indsel=find(conf>confthresh);
    [nmsbbox,nmsconf]=prunebboxes(bbox(indsel,:),conf(indsel),0.2);


    %%%%%%%%%%%%%%% display detections above threshold after non-max suppression
    %%%%%%%%%%%%%%% 
    confthreshnms=1;
    clf, showimage(img)
    indsel=find(nmsconf>confthreshnms);
    showbbox(nmsbbox(indsel,:),[1 1 0],regexp(num2str(nmsconf(indsel)'),'\d+\.\d+','match'));
    title(sprintf('%d NMS detections above threshold %1.3f confthresh %1.3f',size(nmsbbox,1),confthreshnms,confthresh),'FontSize',14)
    fprintf('press a key...'), pause, fprintf('\n')
end

% %%%%%%%%%%%%%%% **************************************************************
% %%%%%%%%%%%%%%% ******************* END of EXERCISE 3 ************************
% %%%%%%%%%%%%%%% **************************************************************

