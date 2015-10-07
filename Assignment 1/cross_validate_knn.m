function ev = cross_validate_knn(X,y,ks,n)
% X: all feature vectors for all training set, this is a m by p matrix,
% where m is the dimention of the feature vector, and p is the number of
% data points
% y: people count for the training set, p by 1 vector
% ks: range of values of k of a knn classifier, say 1:8.
% n: a number indicating how many folds of cross validation to do,
% typically 10
% ev: mean error vector that you will output
for j = 1:ks,
    for i = 1:n,
        xi = X[i];
        yi = y[i];
        xi_ = 0;
        yi_ = 0;
        yip = PredicPeopleCOunt(X,y);
        ei = abs(mean(yi,yip))
    end 
end 

% Compute ev, the mean error vector, as mean of ei's over n folds

%%%%%%%%%%% Pseudo code for n-fold cross validation
% for all values of k in ks
%   for i = 1 to n
%       Xi  = ith fold of X
%       yi  = ith fold of y
%       Xi_ = all folds of X, except the ith fold
%       yi_ = all folds of y, except the ith fold
%       yip = use knn to predict count for Xi using Xi_ and yi_. Call
%       "PredictPeopleCount" to accomplish this. You will also pass k to
%       this function as an argument
%       ei  = compute mean absolute error between yi and yip. Use Matlab
%               functions "abs" and "mean"
%   end for
% end for

% Compute ev, the mean error vector, as mean of ei's over n folds.