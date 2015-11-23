setup
colormap(gray)



% Load and normalize the training images

load possamples;
load negsamples;

npos=size(possamples,3);
nneg=size(negsamples,3);  
possamples=double(possamples);
negsamples=double(negsamples);

fprintf('load  %6d positive samples from \n',npos)
fprintf('load  %6d negative samples from \n\n',nneg)


possampleimage=[];
negsampleimage=[];
for i=1:10
  indpos=randperm(npos);
  indneg=randperm(nneg);
  posfaces=reshape(shiftdim(possamples(:,:,indpos(1:10)),1),24*10,24);
  negfaces=reshape(shiftdim(negsamples(:,:,indneg(1:10)),1),24*10,24);
  possampleimage=cat(2,possampleimage,posfaces);
  negsampleimage=cat(2,negsampleimage,negfaces);
end


%%%%%%%%%%%%%%%% Positive training images have been manually aligned
%%%%%%%%%%%%%%%% by x-y coordinates. However, they may have large
%%%%%%%%%%%%%%%% variation in the amplitude. To remove this variation
%%%%%%%%%%%%%%%% we normalize pixel values of all samples to zero mean
%%%%%%%%%%%%%%%% and variance value=1
%%%%%%%%%%%%%%%%
possamples=meanvarpatchnorm(possamples);
negsamples=meanvarpatchnorm(negsamples);


%%%%%%%%%%%%%%% SVM training and classification assumes each sample
%%%%%%%%%%%%%%% in the form of a vector. Let's flatten training images
%%%%%%%%%%%%%%% into one vector per sample
%%%%%%%%%%%%%%%
xsz=size(possamples,2);
ysz=size(possamples,1);
Xpos=transpose(reshape(possamples,ysz*xsz,npos));
Xneg=transpose(reshape(negsamples,ysz*xsz,nneg));


%%%%%%%%%%%%%%% make vectore with sample labels:
%%%%%%%%%%%%%%% +1 for positives
%%%%%%%%%%%%%%% -1 for negatives
%%%%%%%%%%%%%%%
ypos=ones(npos,1);
yneg=-ones(nneg,1);


%%%%%%%%%%%%%%% separate data into the training and validation set
%%%%%%%%%%%%%%% 
ntrainpos=1000;
ntrainneg=1000;
indpostrain=1:ntrainpos; indposval=indpostrain+ntrainpos;
indnegtrain=1:ntrainneg; indnegval=indnegtrain+ntrainneg;

Xtrain=[Xpos(indpostrain,:); Xneg(indnegtrain,:)];
ytrain=[ypos(indpostrain); yneg(indnegtrain)];
Xval=[Xpos(indposval,:); Xneg(indnegval,:)];
yval=[ypos(indposval); yneg(indnegval)];
% 
% % change the cellSize for optimal solution, default 8
% cellSize=8;
% for i=1:size(possamples,3)
%     hog = vl_hog(single(possamples(:,:,i)), cellSize, 'verbose');
%     reX = reshape(hog,[size(hog,1)*size(hog,2)*size(hog,3) 1]);
%     Xhogpos(i,:) = reX;
% end
% 
% for i=1:size(negsamples,3)
%     hog = vl_hog(single(negsamples(:,:,i)), cellSize, 'verbose');
%     reX = reshape(hog,[size(hog,1)*size(hog,2)*size(hog,3) 1]);
%     Xhogneg(i,:) = reX;
% end

clear possamples negsamples






%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%% Part 2: Train and test SVM classifier, analyze parameters %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%% set SVM parameters: linear kernel with C-parameter specified
%%%%%%%%%%%%%%%

c = 0.001;       % c-parameter
epsilon = .000001;
kerneloption= 1; % degree of polynomial kernel (1=linear)
kernel='poly';   % polynomial kernel
verbose = 0;
tic
fprintf('Training SVM classifier with %d pos. and %d neg. samples...',sum(ytrain==1),sum(ytrain~=1))
[Xsup,yalpha,b,pos]=svmclass(Xtrain,ytrain,c,epsilon,kernel,kerneloption,verbose);
fprintf(' -> %d support vectors (%1.1fsec.)\n',size(Xsup,1),toc)


%%%%%%%%%%%%%%% get prediction for training and validation samples
%%%%%%%%%%%%%%%
fprintf('Running evaluation... ')
[ypredtrain,acctrain,conftrain]=svmvalmod(Xtrain,ytrain,Xsup,yalpha,b,kernel,kerneloption);
[ypredval,accval,confval]=svmvalmod(Xval,yval,Xsup,yalpha,b,kernel,kerneloption);
fprintf('Training accuracy: %1.3f; validation accuracy: %1.3f\n',acctrain(1),accval(1))
% fprintf('press a key...'), pause, fprintf('\n')



%%%%%%%%%%%%%%% **************************************************************
%%%%%%%%%%%%%%% **************************************************************
%%%%%%%%%%%%%%% *                                                            *
%%%%%%%%%%%%%%% *                       EXERCISE 1:                          *
%%%%%%%%%%%%%%% *                                                            *
%%%%%%%%%%%%%%% *       Compute SVM hyper-plane W from support vectors       *
%%%%%%%%%%%%%%% *                                                            *
%%%%%%%%%%%%%%% **************************************************************
%%%%%%%%%%%%%%% **************************************************************
%%%%%%%%%%%%%%%                                                             
%%%%%%%%%%%%%%% Linear SVM classifier can be expressed in the form of a 
%%%%%%%%%%%%%%% hyper-plane W in the original feature space, i.e. 24*25=576-D
%%%%%%%%%%%%%%% space of face-image pixel values. Let's construct W.
%%%%%%%%%%%%%%% 
%%%%%%%%%%%%%%% Recall that W can be expressed in terms of support vectors
%%%%%%%%%%%%%%% and their coefficients as W = sum_i [alpha_i*y_i*X_i]
%%%%%%%%%%%%%%% The solution above provides support vecotors in 'Xsup'
%%%%%%%%%%%%%%% and alpha_i*y_i in 'yalpha'. 
%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%% TODO:
%%%%%%%%%%%%%%% 1.1 Compute W from Xsup and yalpha
%%%%%%%%%%%%%%% 1.2 re-compute confidence for training and validation samples values
%%%%%%%%%%%%%%%     as distances between sample vectors X and W using bias 'b' as 
%%%%%%%%%%%%%%%     conf=X*W+b


% 1.1
W = (yalpha'*Xsup)';


% 1.2 
conftrainnew = Xtrain*W+b;
confvalnew   = Xval*W+b;


%%%%%%%%%%%%%%% Re-compute classification accuracy using true sample labels 'y'
%%%%%%%%%%%%%%% for training and validation samples

acctrainnew = mean((conftrainnew>0)*2-1==ytrain);
accvalnew   = mean((confvalnew>0)*2-1==yval);
fprintf('Training and validation accuracy re-computed from W,b: %1.3f; %1.3f\n',acctrainnew,accvalnew)
% fprintf('press a key...'), pause, fprintf('\n')


%%%%%%%%%%%%%%% **************************************************************
%%%%%%%%%%%%%%% ******************* END of EXERCISE 1 ************************
%%%%%%%%%%%%%%% **************************************************************



%%%%%%%%%%%%%%% The values of the hyper-plane W are
%%%%%%%%%%%%%%% the weights of individual pixel values and can be displayed
%%%%%%%%%%%%%%% as an image. Let's construct W from support vectors
%%%%%%%%%%%%%%%
clf, showimage(reshape(W,24,24))


%%%%%%%%%%%%%%% **************************************************************
%%%%%%%%%%%%%%% **************************************************************
%%%%%%%%%%%%%%% *                                                            *
%%%%%%%%%%%%%%% *                       EXERCISE 2:                          *
%%%%%%%%%%%%%%% *                                                            *
%%%%%%%%%%%%%%% *        Optimize C parameter on the validation set          *
%%%%%%%%%%%%%%% *                                                            *
%%%%%%%%%%%%%%% **************************************************************
%%%%%%%%%%%%%%% **************************************************************
%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%% SVM generalization ability depends on the constant C
%%%%%%%%%%%%%%% A standard practice for choosing C is to empirically
%%%%%%%%%%%%%%% select the best value of C by maximizing performance on
%%%%%%%%%%%%%%% the validation set. (Note that C or any other parameters
%%%%%%%%%%%%%%% should never be optimized on the final test set.)
%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%% TODO:
%%%%%%%%%%%%%%% 2.1 train linear SVM as above for different values of C
%%%%%%%%%%%%%%%     and select the best C 'Cbest' and the best model 'Wbest'
%%%%%%%%%%%%%%%     and 'bbest' maximizing accuracy on the validation set.
%%%%%%%%%%%%%%%     Hint: try exponentially distribution values, e.g. 
%%%%%%%%%%%%%%%     [1000 100 10 1 .1 .01 .001 .0001 .00001];
%%%%%%%%%%%%%%% 2.2 When traibning for different C values, compute W,b
%%%%%%%%%%%%%%%     and visualize W as an image (see above)
%%%%%%%%%%%%%%%
Call=[1000 100 10 1 .1 .01 .001 .0001 .00001];
accbest=-inf; 
modelbest=[];
for i=1:length(Call)
  C=Call(i);
  % fill-in this part with the training of linear SVM for
  % the current C value (see code above). Select the model 
  % 'modelbest' maximizing accuracy on the validation set. 
  % Compute and display W for the current model
  
  [Xsup,yalpha,b,pos]=svmclass(Xtrain,ytrain,C,epsilon,kernel,kerneloption,verbose);
  [ypredtrain,acctrain,conftrain]=svmvalmod(Xtrain,ytrain,Xsup,yalpha,b,kernel,kerneloption);
  [ypredval,accval,confval]=svmvalmod(Xval,yval,Xsup,yalpha,b,kernel,kerneloption);
  W = (yalpha'*Xsup)';
  clf, showimage(reshape(W,24,24));
  s=sprintf('C=%1.5f | Training accuracy: %1.3f; validation accuracy: %1.3f',C,acctrain,accval);
  title(s); fprintf([s '\n']); drawnow
  if accbest<accval,
      accbest = accval;
      Cbest = C;
      Wbest = W;
      bbest = b;
  end
end
fprintf(' -> Best accuracy %1.3f for C=%1.5f\n',accbest,Cbest)
% fprintf('press a key...'), pause, fprintf('\n')


%%%%%%%%%%%%%%% **************************************************************
%%%%%%%%%%%%%%% ******************* END of EXERCISE 2 ************************
%%%%%%%%%%%%%%% **************************************************************














%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%% Part 3: Scanning window face detection %%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% 
% %%%%%%%%%%%%%%% load test image
% %%%%%%%%%%%%%%%
% imgfname='img1.jpg';
% img=imread([imgpath '/' imgfname]);
% showimage(img), title(imgfname)
% gimg=mean(img,3);
% 
% %%%%%%%%%%%%%%% decompose the image into sub-windows
% %%%%%%%%%%%%%%%
% [ysz,xsz,csz]=size(img);
% wxsz=24; wysz=24;
% [x,y]=meshgrid(1:xsz-wxsz,1:ysz-wysz);
% bbox=[x(:) y(:) x(:)+wxsz-1 y(:)+wysz-1];
% n=size(bbox,1);
% imgcropall=zeros(wysz,wxsz,length(x(:)));
% for i=1:size(bbox,1)
%   imgcropall(:,:,i)=cropbbox(gimg,bbox(i,:));
% end
% 
% 
% 
% %%%%%%%%%%%%%%% Linear SVM classifier can be evaluated efficiently by
% %%%%%%%%%%%%%%% using dot-product between image patches and W. Before
% %%%%%%%%%%%%%%% computing the confidence we need to normalize and reshape
% %%%%%%%%%%%%%%% test image patches.
% 
% imgcropall=meanvarpatchnorm(imgcropall);
% X=transpose([reshape(imgcropall,wysz*wxsz,n)]);
% conf=X*Wbest-bbest;
% 
% 
% %%%%%%%%%%%%%%% display most confident detections
% %%%%%%%%%%%%%%%
% n=20;
% [vs,is]=sort(conf,'descend');
% clf, showimage(img), showbbox(bbox(is(1:n),:))
% title(sprintf('%d best detections',n),'FontSize',14)
% fprintf('press a key...'), pause, fprintf('\n')
% 
% 
% 
% 
% 
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
% confthresh=4.7;
% indsel=find(conf>confthresh);
% [nmsbbox,nmsconf]=prunebboxes(bbox(indsel,:),conf(indsel),0.2);
% 
% 
% %%%%%%%%%%%%%%% display detections above threshold after non-max suppression
% %%%%%%%%%%%%%%% 
% confthreshnms=4.5;
% clf, showimage(img)
% indsel=find(nmsconf>confthreshnms);
% showbbox(nmsbbox(indsel,:),[1 1 0],regexp(num2str(nmsconf(indsel)'),'\d+\.\d+','match'));
% title(sprintf('%d NMS detections above threshold %1.3f',size(nmsbbox,1),confthreshnms),'FontSize',14)
% fprintf('press a key...'), pause, fprintf('\n')
% 
% 
% %%%%%%%%%%%%%%% **************************************************************
% %%%%%%%%%%%%%%% ******************* END of EXERCISE 3 ************************
% %%%%%%%%%%%%%%% **************************************************************
% 


