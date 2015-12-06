function yt = PredictPeopleCount(X, y, Xt, k, combine_method)
% This function returns predicted count yt for test data Xt
% It uses k nearest neighbor with training data (X, y) and parameter value k

% X is the training feature and y is the training response
% X is m by n and y is n by 1. n is the number of data points, m is the
% dimension of the feature vector.
% Xt is the m by p test feature. p is the number of test data points.
% k is the knn parameter k
% compbine_method is a string: 'mean' or 'mode'; you can use 'mean' for your
% assignment. When k is greater than 1, you will use combine_method to 
% combine the responses of the neareast neighbors. Use
% strcmp(combine_method, 'mean') to see if the input was 'mean', etc.
% yt is the predicted count for the test set Xt. dimention of ty is p by 1.

if nargin<5% the last argument (combine_method) has not been provided so we default it to 'mean'
    combine_method='mean';
end
kd_tree=vl_kdtreebuild(X);
test_size=size(Xt, 2);
yt=zeros(test_size, 1);
[idx, ~]=vl_kdtreequery(kd_tree, X, Xt,  'numneighbors', k);
yt_k=y(idx);
if k==1% yt_k has a single count for each test image which is thus the final predicted count too
    yt=yt_k;
else% yt_k has k counts for each test image which must be combined to get the final predicted count
    if strcmp(combine_method, 'mean')
        yt=round(mean(yt_k,1));% mean of a set of integers may not be an integer but the predicted count must be one
        % so we round to the nearest integer
    elseif strcmp(combine_method, 'mode')
        yt=mode(yt_k,1);
    else
        error(strcat('Invalid combine methiod specified: ', combine_method));
    end
end
yt=yt(:);