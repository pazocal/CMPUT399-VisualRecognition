% This is the main program to train people counting machine learner
% With a 10-fold cross validation the program learns the parameter k of a
% k nearest neighbor program

% Step 1: Reading images from a folder
%   Use "dir" program to list a folder where training images are kept. Use
%   "imread" to read images.
no_of_bins=128;
img_fmt='pgm';
train_img_dir='vidf_images';
train_data_file='train_data.mat'; % file to which the training data will be saved
use_only_pos=0; % set this to 0 to read both positive and negative training
% samples; otherwise only positive images (those containing cars) will be read
use_hist=0; % set this to 1 to use histogram as the feature;
% otherwise raw pixel values will be used


train_file_list=dir(strcat(train_img_dir,'/*.',img_fmt));
train_size=length(train_file_list);


% Step 2: Compute features and store them in a matrix X; Store counts in a
% vector y. Use "my_feature" function for which a template is
% supplied.

% Step 3: Do a 10-fold cross validation to train k nearest neighbor
%   You will need to use your function "cross_validate_knn" for this purpose
%   "cross_validate_knn" retruns average errors over
%   all folds for a range of values of k. Choose the value of k for which 
%   you obtained the lowest cross validation error.

% Step 4: Now build a kd tree with the entire traiing set X and the learned
% parameter value of k in step 3.

% Step 5: Read the test images and keep features in Xt and labels in Yt.
% You will need to call "my_feature" function again.

% Step 6: Find out k nearest neighbors for Xt. Use the k value you learned
%   in Step 3. Compute average prediction error on the test set. Display
%   this error with "disp" function.