function ev = cross_validate_knn(X,y,ks,n)
% X: all feature vectors for all training set, this is a m by n matrix,
% where m is the dimention of the feature vector, and n is the number of
% data points
% y: people count for the training set, n by 1 vector
% ks: range of values of k of a knn classifier, say 1:10.
% n: a number indicating how many folds of cross validation to do,
% typically 10
% ev: mean error vector that you will output

%%%%%%%%%%% Pseudo code for n-fold cross validation
% for all values of k in ks
%   for i = 1 to n
%       Xi  = ith fold of X
%       yi  = ith fold of y
%       Xi_ = all folds of X, except the ith fold
%       yi_ = all folds of y, except the ith fold
%       yip = use knn to predict count for Xi using Xi_ and yi_. Call
%       "PredictPeopleCount" to accomplish this.
%       ei  = compute mean absolute error between yi and yip. Use Matlab
%               functions "abs" and "mean"
%   end for
% end for

% In the above code chunk properly populate ev, the mean error vector

% Use kd_tree of Vlfeat package to predict count with knn

% the following code (lines 30-43) has been setup to allow this function to
% be called without specifying some or all of the input arguments. All
% arguments that are not specified are loaded instead from a mat file where
% they should previousl;y have been saved. This way you can selectively
% debug this function without having to rerun all the other code.
training_feat_file='training_features.mat';
training_features=load(training_feat_file);
if nargin<4% nargin gives the number of arguments actually provided
    % so nargin<4 means that the fourth argument (n) has not been provided
    n=training_features.no_of_folds;
end
if nargin<3 % third and fourth arguments have not been provided
    ks=training_features.ks;
end
if nargin<2% second, third and fourth arguments have not been provided
    y=training_features.y;
end
if nargin<1% no arguments have been provided
    X=training_features.X;
end     

training_size=size(X, 2);
fold_size=ceil(training_size/n); % if n is not a factor of training_size,
% one of the folds will be smaller than the rest
evall=zeros(n, numel(ks));% numel gives the no. of elements in an array
% evall will contain the errors for all folds for each k
for k_id=1:numel(ks)
    k=ks(k_id);
    for i = 1:n
        fold_start_idx=(i-1)*fold_size + 1;% index at with this fold starts
        fold_end_idx=i*fold_size;  % index at with this fold ends      
        % get validation data
        Xi=X(:, fold_start_idx:fold_end_idx);
        yi=y(fold_start_idx:fold_end_idx);
        % get training data
        other_folds_idx=[1:fold_start_idx-1 fold_end_idx+1:training_size];% indexes of all the other folds
        Xi_=X(:, other_folds_idx);
        yi_=y(other_folds_idx);
        
        yip = PredictPeopleCount(Xi_, yi_, Xi, k, 'mean');     

        ei=mean(abs(yi-yip));
        evall(i, k_id)=ei;
    end
    fprintf('\tDone with k=%d\n', k);
end
ev = mean(evall,1);
end