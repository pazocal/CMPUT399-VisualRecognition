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

[Xr,Xc] = size(X);
% Compute the size of each fold. In this case, it should be 2500
fold = Xc/10;  

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
    end 
     ev(j)=mean(ei);    
end 
fprintf('Finished cross_validate_knn\n');