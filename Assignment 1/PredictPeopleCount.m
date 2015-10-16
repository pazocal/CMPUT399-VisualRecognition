function yt = PredictPeopleCount(X, y, Xt, k, combine_method)
% This function returns predicted count yt for test data Xt
% It uses k nearest neighbor with training data (X, y) and parameter value k

% X is the training feature and y is the training response
% X is m by n and y is n by 1. n is the number of data points, m is the
% dimension of the feature vector.
% Xt is the m by p test feature. p is the number of test data points.
% k is the knn parameter k
% combine_method is a string: 'mean' or 'mode'; you can use 'mean' for your
% assignment. When k is greater than 1, you will use combine_method to 
% combine the responses of the neareast neighbors. Use
% strcmp(combine_method, 'mean') to see if the input was 'mean', etc.
% yt is the predicted count for the test set Xt. dimention of yt is p by 1.

% kd_tree=vl_kdtreebuild(X,'ThresholdMethod','mean');
kd_tree=vl_kdtreebuild(X);

% http://www.vlfeat.org/overview/kdtree.html
[index,~] = vl_kdtreequery(kd_tree,X,Xt,'numneighbors',k);
[row,col]=size(Xt);

% http://www.mathworks.com/help/matlab/ref/sum.html?searchHighlight=sum
for i=1:col,
    ele = y(index([1:k],i));
    sum_value = sum(ele);
    yt(i)=sum_value/k;
end

