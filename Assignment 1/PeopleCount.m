% This is the main program to train people counting machine learner
% With a 10-fold cross validation the program learns the parameter k of a
% k nearest neighbor program

% Step 1: Reading images from a folder
%   Use "dir" program to list a folder where training images are kept. Use
%   "imread" to read images.

% Step 2: Compute features and store them in a matrix X; Store counts in a
% vector y. Use "my_feature" function for which a template is
% supplied

% Step 3: Do a 10-fold cross validation to train k nearest neighbor
%   You will need to use your function "cross_validate_knn" for this purpose
%   "cross_validate_knn" retruns average errors over
%   all folds for a range of values of k. Choose the value of k for which 
%   you obtained the lowest cross validation error.

% Step 4: Now build a kd tree with the entire traiing set X. 

% Step 5: Read the test images and keep features in Xt and labels in Yt.
% You will need to call "My_feature" function again.

% Step 6: Find out k nearest neighbors for Xt. Use the k value you learned
%   in Step 3. Compute average prediction error on the test set. Display
%   this error with "disp" function.

% default parameters
vlfeat_dir='vlfeat-0.9.18';
img_dir='vidf_images';
img_fmt='png';
min_k=1;
max_k=10;
no_of_bins=32;
no_of_folds=10;
combine_method='mean';
training_feat_file='training_features.mat';

run(strcat(vlfeat_dir, '/toolbox/vl_setup')); % initialize vl_feat toolbox
ks=min_k:max_k;

disp('Loading names and counts of training images...');
% Following procedure should be used if you do not know the name
% of the variable loaded from mat file.
train_set_struct=load('training_set.mat'); % load data from mat file into a structure
field_name=fieldnames(train_set_struct);% get the names of all fields in this structure
train_set=train_set_struct.(field_name{1});% get training set from the first field
% which in this case is 'training_set' so this statement is equivalent to:
% train_set=train_set_struct.training_set

disp('Loading binary mask...');
% load binary mask using the same procedure as above
mask_struct=load('vidf_mask.mat');
field_name=fieldnames(mask_struct);
mask=mask_struct.(field_name{1}); % same as mask=mask_struct.binary_mask

disp('Training started');
train_size=length(train_set);
X=zeros(no_of_bins, train_size);
y=zeros(train_size,1);
tic% tic toc is used to display the time elapsed between the execution of two statements
for i=1:train_size
    if mod(i, 1000)==0
        fprintf('\tProcessed %d of %d images...\n', i, train_size);
    end
    img_name=train_set{i, 1};
    y(i)=train_set{i, 2};
    img=imread(strcat(img_dir,'/',img_name));
    h = my_feature(img, mask, no_of_bins);
    X(:, i)=h;
end
save(training_feat_file, 'X', 'y', 'ks', 'no_of_folds');
toc

disp('Performing cross validation...');
tic
ev = cross_validate_knn(X,y,ks,no_of_folds);
figure(1),plot(ks,ev);
xlabel('No. of nearest neighbors (k)');
ylabel('Mean error');
title('Variation of mean error with no. of nearest neighbors'); 
drawnow;

% display k value corresponding to the lowest value of the cross validation
% error.
[minev, minind] = min(ev);
cross_v_k = ks(minind(1)); % k with the minimum error
fprintf('Optimal k=%d\n', cross_v_k);
toc

% test data
disp('Loading names and counts of test images...');
test_set_struct=load('test_set.mat');
field_name=fieldnames(test_set_struct);
test_set=test_set_struct.(field_name{1});

disp('Testing started');
test_size=length(test_set);
Xt=zeros(no_of_bins, test_size);
yt=zeros(test_size,1);
tic
for i=1:test_size
    if mod(i, 100)==0
        fprintf('\tProcessed %d of %d images...\n', i, test_size);
    end
    img_name=test_set{i, 1};
    yt(i)=test_set{i, 2};
    img=imread(strcat(img_dir,'/',img_name));
    h = my_feature(img, mask, no_of_bins);
    Xt(:, i)=h;
end
toc

% the following code can also be replaced by a call to PredictPeopleCount
disp('building kd-tree...');
tic
kd_tree=vl_kdtreebuild(X);% build the KD tree using the training set
k = cross_v_k;
[idx, ~]=vl_kdtreequery(kd_tree, X, Xt,  'numneighbors', k);% get the predicted counts for the test set
yt_k=y(idx);
if k==1% yt_k has a single count for each test image which is thus the final predicted count too
    ytp=yt_k;
else% yt_k has k counts for each test image which must be combined to get the final predicted count
    if strcmp(combine_method, 'mean')
        ytp=round(mean(yt_k,1));
    elseif strcmp(combine_method, 'mode')
        ytp=mode(yt_k,1);
    else
        error(strcat('Invalid combine methiod specified: ', combine_method));
    end
end
ytp=ytp(:);
toc
fprintf('Mean error=%f\n', mean(abs(yt-ytp)));
