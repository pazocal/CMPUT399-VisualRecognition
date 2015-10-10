function ev = cross_validate_knn(X,y,ks,n)
% X: all feature vectors for all training set, this is a m by p matrix,
% where m is the dimention of the feature vector, and p is the number of
% data points
% y: people count for the training set, p by 1 vector
% ks: range of values of k of a knn classifier, say 1:8.
% n: a number indicating how many folds of cross validation to do,
% typically 10
% ev: mean error vector that you will output
% y = reshape(y,n,[]);

% n=10;
[Xr,Xc] = size(X);
% Compute the size of each fold. In this case, it should be 2500
fold = Xc/10;  % n = 10

% For testing in cmd
% ks = 8;
% n = 10;

% For this assignment, use mean method.
combine_method = 'mean';

% Define a KNN parameter value
knn_val = ks;


for j = 1:knn_val,
    for i = 1:n %2:3; %set 2:3 for test ,
        % temp store
        rX = X;
        ry = y;
        
        Xi(:,1:fold) = X(:,1+(i-1)*fold:i*fold);
        yi = y(1+(i-1)*fold:i*fold);
        
        % http://www.mathworks.com/matlabcentral/answers/40705-how-to-delete-a-column-from-the-matrix
        % delete specified columns from the matrix.
        rX(:,1+(i-1)*fold:i*fold)=[];
        ry(1+(i-1)*fold:i*fold)=[];
        Xi_ = rX;
        yi_ = ry;
        
        yip = PredictPeopleCount(Xi_, yi_, Xi, j, combine_method)
        
        error_val=abs(yi-yip);
        ei(i)=mean(error_val);
%         e1 = mean(abs(yip-yi))
%         flag = 1 + endInd;
%         endInt = endInt + foldInd
%         endInd += foldInd;
% 
%         X_new = mat2cell(X, 128,repmat(100, 5, 1));
%         M = randn(300,25);
%         M1 = M(1:30,:);
%         A = your 300x25 matrix
%         X = mat2cell(A,30*ones(10,1),25);
%         http://www.mathworks.com/help/matlab/ref/reshape.html?searchHighlight=reshape
%         
%         yi = y{:,i};
%         xi_ = 0;
%         yi_ = 0;
%         yip = PredicPeopleCOunt(X,y);
%         ei = abs(mean(yi,yip))
    end 
    
     ev(j)=mean(ei);
    
end 
fprintf('Finished cross_validate_knn\n');
% Compute ev, the mean error vector, as mean of ei's over n folds

%%%%%%%%%%% Pseudo code for n-fold cross validation
% for all values of k in ks
%   for i = 1 to n
%       Xi  = ith fold of X
%       yi  = ith fold of y
%       Xi_ = all folds of X, except the ith fold
%       yi_ = all folds of y, except the ith fold
%         yip = PredictPeopleCount(X, y, Xt, k, combine_method)
%         function yt = PredictPeopleCount(X, y, Xt, k, combine_method)
%       yip = use knn to predict count for Xi using Xi_ and yi_. Call
%       "PredictPeopleCount" to accomplish this. You will also pass k to
%       this function as an argument
%       ei  = compute mean absolute error between yi and yip. Use Matlab
%               functions "abs" and "mean"
%   end for
% end for

% Compute ev, the mean error vector, as mean of ei's over n folds.