    % current level set is 20, scale factor is 1.205
    % best case is level at 16, and you can see from the command window when it
    % prints Level:     16
    %        Scale factor:     1.2050
    % Then it is the best case



    % set up factors
    clear all;
    level=16;
    factor=1.205;
    ctemp=[1,1,0];

    %%%%%%%%%%%%%%% load test image
    %%%%%%%%%%%%%%%
    % imgfname='test2.jpg';
    imgfname='test_img.jpg';
    img=imread(imgfname);
    img=rgb2gray(img);

    % showimage(img), title(imgfname)
    gimg=mean(img,3);



    rawdata = load('raw.mat');
    hogdata = load('hog.mat');
    GI = GaussianPyramid(gimg,level,factor)
    %%%%%%%%%%%%%%% decompose the image into sub-windows
    %%%%%%%%%%%%%%%
    W_raw=(rawdata.yalpha'*rawdata.Xsup)';
    [ysz,xsz,csz]=size(img);
    wxsz=24; wysz=24;

    [x,y]=Stage1Detector(double(GI{level}),reshape(W_raw,24,24));
    
    %rescale the x and y 
    x=x*(factor^(level-1)); y=y*(factor^(level-1));
    bbox=[x(:)-wxsz*(factor^(level-1))/2 y(:)-wysz*(factor^(level-1))/2 x(:)+wxsz*(factor^(level-1))/2-1 y(:)+wysz*(factor^(level-1))/2-1];
    tempbbox = [x(:)-wxsz/2 y(:)-wysz/2 x(:)+wxsz/2-1 y(:)+wysz/2-1];
    
    
    
    clf, showimage(img), showbbox(bbox,ctemp);
    n=size(bbox,1);
    fprintf('Press a key to cont'),pause,fprintf('\n');
    
    imgcropall=zeros(wysz,wxsz,length(x(:)));
    for i=1:size(tempbbox,1)
      imgcropall(:,:,i)=cropbbox(GI{level},tempbbox(i,:));
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

    
    
    
    confthresh=4;
    indsel=find(conf>confthresh);
    [nmsbbox,nmsconf]=prunebboxes(bbox(indsel,:),conf(indsel),0.2);
    
    %%%%%%%%%%%%%%% display detections above threshold after non-max suppression
    %%%%%%%%%%%%%%% 
    confthreshnms=4;
    clf, showimage(img)
    indsel=find(nmsconf>confthreshnms);
    
    
    
    showbbox(nmsbbox,[0 1 0],regexp(num2str(nmsconf(indsel)'),'\d+\.\d+','match'));
    title(sprintf('%d NMS detections above threshold %1.3f confthresh %1.3f',size(nmsbbox,1),confthreshnms,confthresh),'FontSize',14)
    fprintf('Level: ');
    disp(level);
    fprintf('Scale factor: ');
    disp(factor)
    fprintf('press a key...'), pause, fprintf('\n')
    
    clear Xhogtest

