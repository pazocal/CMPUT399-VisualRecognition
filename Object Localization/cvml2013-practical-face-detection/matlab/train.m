setup
colormap(gray)

clear all;

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
ntrainpos=1200;
ntrainneg=1200;
indpostrain=1:ntrainpos; indposval=indpostrain+ntrainpos;
indnegtrain=1:ntrainneg; indnegval=indnegtrain+ntrainneg;

Xtrain=[Xpos(indpostrain,:); Xneg(indnegtrain,:)];
ytrain=[ypos(indpostrain); yneg(indnegtrain)];
Xval=[Xpos(indposval,:); Xneg(indnegval,:)];
yval=[ypos(indposval); yneg(indnegval)];



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
[ypredtrain,acctrain,conftrain]=svmvalmod(Xtrain,ytrain,Xsup,yalpha,b,kernel,kerneloption);
[ypredval,accval,confval]=svmvalmod(Xval,yval,Xsup,yalpha,b,kernel,kerneloption);
fprintf('Training accuracy: %1.3f; validation accuracy: %1.3f\n',acctrain(1),accval(1))
% fprintf('press a key...'), pause, fprintf('\n')



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

clf, showimage(reshape(W,24,24))

Call=[100 10 1 .1 .01 .001 .0001 .00001];
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
      save('raw.mat','Cbest','Wbest','bbest','yalpha','Xsup')
  end
 
end
fprintf(' -> Best accuracy %1.3f for C=%1.5f\n',accbest,Cbest)
% fprintf('press a key...'), pause, fprintf('\n')


%%%%%%%%%%%%%%% **************************************************************
%%%%%%%%%%%%%%% ******************* END of EXERCISE 2 ************************
%%%%%%%%%%%%%%% **************************************************************



% change the cellSize for optimal solution, default 8
cellSize=8;
for i=1:size(possamples,3)
    hog = vl_hog(single(possamples(:,:,i)), cellSize, 'verbose');
%     hog = vl_hog('render', hog, 'verbose', 'variant', 'dalaltriggs') ;
    reX = reshape(hog,[size(hog,1)*size(hog,2)*size(hog,3) 1]);
    Xhogpos(i,:) = reX;
end

for i=1:size(negsamples,3)
    hog = vl_hog(single(negsamples(:,:,i)), cellSize, 'verbose');
%     hog = vl_hog('render', hog, 'verbose', 'variant', 'dalaltriggs') ;
    reX = reshape(hog,[size(hog,1)*size(hog,2)*size(hog,3) 1]);
    Xhogneg(i,:) = reX;
end

Xhogpos=double(Xhogpos);
Xhogneg=double(Xhogneg);
Xtrain=[Xhogpos(indpostrain,:); Xhogneg(indnegtrain,:)];
Xval=[Xhogpos(indposval,:); Xhogneg(indnegval,:)];

Call=[100 10 1 .1 .01 .001 .0001 .00001];
accbest=-inf; 
modelbest=[];
for i=1:length(Call)
  C=Call(i);
  [Xsup,yalpha,b,pos]=svmclass(Xtrain,ytrain,C,epsilon,kernel,kerneloption,verbose);
  [ypredtrain,acctrain,conftrain]=svmvalmod(Xtrain,ytrain,Xsup,yalpha,b,kernel,kerneloption);
  [ypredval,accval,confval]=svmvalmod(Xval,yval,Xsup,yalpha,b,kernel,kerneloption);
  W = (yalpha'*Xsup)';
  s=sprintf('C=%1.5f | Training accuracy: %1.3f; validation accuracy: %1.3f',C,acctrain,accval);
  title(s); fprintf([s '\n']); drawnow
  if accbest<accval,
      accbest = accval;
      Cbest = C;
      Wbest = W;
      bbest = b;
      save('hog.mat','Cbest','Wbest','bbest','yalpha','Xsup')
  end
 
end
fprintf(' -> Best accuracy %1.3f for C=%1.5f\n',accbest,Cbest)
clear all