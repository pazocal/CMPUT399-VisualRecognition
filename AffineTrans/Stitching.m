clear all;
close all;

% read two images to stitch
% I1 = imread('C:\Users\Nilanjan\CMPUT399\GeoVerificationLab\Picture1.jpg');
% I2 = imread('C:\Users\Nilanjan\CMPUT399\GeoVerificationLab\Picture2.jpg');
I1 = imread('C:\Users\Nilanjan\CMPUT399\GeoVerificationLab\BLDG11_F264P1_501M.bmp');
I2 = imread('C:\Users\Nilanjan\CMPUT399\GeoVerificationLab\BLDG11_F264P1_1000M.bmp');
% show images
figure(1),subplot(1,2,1),imagesc(I1); axis equal off; subplot(1,2,2),imagesc(I2);axis equal off; 

% compute SIFT feature points and extract descriptors
% [frames1, descrs1] = vl_sift(single(rgb2gray(I1))) ;
% [frames2, descrs2] = vl_sift(single(rgb2gray(I2))) ;
[frames1, descrs1] = vl_sift(single(I1)) ;
[frames2, descrs2] = vl_sift(single(I2)) ;

% show SIFT feature points
figure(2);subplot(1,2,1); imagesc(I1); axis equal off; hold on ;
vl_plotframe(frames1, 'linewidth', 2); hold off;
figure(2),subplot(1,2,2);axis equal off; hold on; imagesc(I2),vl_plotframe(frames2, 'linewidth', 2) ; hold off;

% Find nearest neighbors
nn = findNeighbours(double(descrs1), double(descrs2)) ;
% Construct a matrix of matches. Each column stores two index of
% matching features in I1 and I2
matches = [1:size(descrs1,2) ; nn(1,:)] ;
% plot matches
figure(3),plotMatches(I1,I2,frames1,frames2,matches) ;

% Compute homography and inliers
% [inliers, H] = geometricVerification(frames1, frames2, matches, 'numRefinementIterations', 8) ;
[inliers, H] = myAffineT(frames1, frames2, matches);
matches_geo = matches(:, inliers);
% plot geometric matches after geometric verification
figure(4),plotMatches(I1,I2,frames1,frames2,matches_geo, 'homography', H) ;

% Now stitch images
[~,xdataim2t,ydataim2t]=imtransform(I2,maketform('Projective',H'));
% now xdataim2t and ydataim2t store the bounds of the transformed I2
xdataout=[min(1,xdataim2t(1)) max(size(I1,2),xdataim2t(2))];
ydataout=[min(1,ydataim2t(1)) max(size(I1,1),ydataim2t(2))];
% let's transform both images with the computed xdata and ydata
I2t=imtransform(I2,maketform('Projective',H'),'XData',xdataout,'YData',ydataout);
I1t=imtransform(I1,maketform('affine',eye(3)),'XData',xdataout,'YData',ydataout);

% Visualizations: now I1t and I2t are equal-size images ready to be merged. Let's average them

Is=I1t/2+I2t/2;
figure(5), imshow(Is);
