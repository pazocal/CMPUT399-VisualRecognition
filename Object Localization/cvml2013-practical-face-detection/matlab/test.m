% set up factors
clear all;
level=16;
factor=1.3;
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
for j=5:level
    
    [x,y]=Stage1Detector(double(GI{j}),reshape(W_raw,24,24));
    
    %rescale the x and y 
    x=x*(factor^(j-1)); y=y*(factor^(j-1));
    bbox=[x(:)-wxsz*(factor^(j-1))/2 y(:)-wysz*(factor^(j-1))/2 x(:)+wxsz*(factor^(j-1))/2-1 y(:)+wysz*(factor^(j-1))/2-1];
    tempbbox = [x(:)-wxsz/2 y(:)-wysz/2 x(:)+wxsz/2-1 y(:)+wysz/2-1];
    ctemp=[1,1,0]
    clf, showimage(img), showbbox(bbox,ctemp);
    n=size(bbox,1);
    fprintf('Wait'),pause,fprintf('\n');
    
    imgcropall=zeros(wysz,wxsz,length(x(:)));
    for i=1:size(tempbbox,1)
      imgcropall(:,:,i)=cropbbox(GI{j},tempbbox(i,:));
    end
    
    
    % recomput hog
    cellSize=8;
    for i=1:size(imgcropall,3)
        hog = vl_hog(single(imgcropall(:,:,i)), cellSize, 'verbose');
        [a,b,c]=size(hog);
        reX = reshape(hog,1,a*b*c);
        Xhogtest(i,:) = reX;
    end
    % recompute conf by the new hog result and previous data
    conf=Xhogtest*hogdata.Wbest-hogdata.bbest;
    [vs,is]=sort(conf,'descend');

    
    
    
    confthresh=5;
    indsel=find(conf>confthresh);
    [nmsbbox,nmsconf]=prunebboxes(bbox(indsel,:),conf(indsel),0.2);
    
    %%%%%%%%%%%%%%% display detections above threshold after non-max suppression
    %%%%%%%%%%%%%%% 
    confthreshnms=5;
    clf, showimage(img)
    indsel=find(nmsconf>confthreshnms);
    showbbox(nmsbbox,[0 1 0],regexp(num2str(nmsconf(indsel)'),'\d+\.\d+','match'));
    title(sprintf('%d NMS detections above threshold %1.3f confthresh %1.3f',size(nmsbbox,1),confthreshnms,confthresh),'FontSize',14)
    fprintf('press a key...'), pause, fprintf('\n')
    
    clear Xhogtest
end
