clear all;

% This is the main program to train people counting machine learner
% With a 10-fold cross validation the program learns the parameter k of a
% k nearest neighbor program

% Step 1: Reading images from a folder
%   Use "dir" program to list a folder where training images are kept. Use
%   "imread" to read images.
% Initialization

img_fmt='png';
load test_set.mat;
load vidf_mask.mat;
load training_set.mat;
train_img_dir='vidf_images';
ks=8; % Could be changed
ktest=1;
no_of_fold=10;
no_of_bin=128;
[testrow,testcol] = size(test_set);
train_file_list=dir(strcat(train_img_dir,'/*.',img_fmt));
[trainrow,traincol]=size(training_set);
train_size=trainrow;
images=cell(train_size, 1);
image_id=1;

% Step 2: Compute features and store them in a matrix X; Store counts in a
% vector y. Use "my_feature" function for which a template is
% supplied.

for i=1:train_size,
    filename=training_set{i,1}; % get the file name
    if mod(i, 1000)==0,
        fprintf('Processed %d images\n', i);
        fprintf('Filename is %s\n',filename);
    end
    img=imread(strcat(train_img_dir, '/',filename));
    images{i}=img;
    X(:,i)=my_feature(images{i,1},binary_mask,no_of_bin);
    y(i)= training_set{i,2};
end

%   Step 3: Do a 10-fold cross validation to train k nearest neighbor
%   You will need to use your function "cross_validate_knn" for this purpose
%   "cross_validate_knn" retruns average errors over
%   all folds for a range of values of k. Choose the value of k for which 
%   you obtained the lowest cross validation error.

ev=cross_validate_knn(X,y,ks,no_of_fold);
for i=1:size(ev)
    if ev(i)==min(ev)
        k=i;
    end
end

% Step 4: Now build a kd tree with the entire traiing set X and the learned
% parameter value of k in step 3.

fprintf('\nStep 4 mark: Building KD tree...');
kd_tree=vl_kdtreebuild(X);

% Step 5: Read the test images and keep features in Xt and labels in Yt.
% You will need to call "my_feature" function again.

for i=1:testrow,
    filename=test_set{i,1}; % get the file name
    if mod(i, 1000)==0
        fprintf('Processed %d test images\n', i);
    end
    img=imread(strcat(train_img_dir, '/',filename));
    imagesT{i}=img;
    Xt(:,i)=my_feature(imagesT{i},binary_mask,no_of_bin);
    yt(i)= test_set{i,2};
end

% Step 6: Find out k nearest neighbors for Xt. 
% Use the k value you learned
% in Step 3. Compute average prediction error on the test set. Display
% this error with "disp" function.

[row,col]=size(Xt);
% http://www.vlfeat.org/overview/kdtree.html
[index,~] = vl_kdtreequery(kd_tree,X,Xt,'numneighbors',k);
% http://www.mathworks.com/help/nnet/ref/mae.html?searchHighlight=mae
for i=1:col,
    sum_value = sum(y(index([1:k],i)));
    ytt(i)=sum_value/k;
end
% mae function??
er = abs(yt-ytt);
avg_error = mean(er);
disp (avg_error);
