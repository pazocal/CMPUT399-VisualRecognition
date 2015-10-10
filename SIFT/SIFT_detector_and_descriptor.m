I = vl_impattern('roofs1') ;
% image(I) ;
Ia = imread('img1.*') ;
Ib = imread('img2.*') ;

I = single(rgb2gray(I)) ;
Ia = single(rgb2gray(Ia)) ;
Ib = single(rgb2gray(Ib)) ;


[f,d] = vl_sift(I) ;
[fa, da] = vl_sift(Ia) ;
[fb, db] = vl_sift(Ib) ;
[matches, scores] = vl_ubcmatch(da, db) ;

% 
% perm = randperm(size(f,2)) ;
% sel = perm(1:50) ;
% h1 = vl_plotframe(f(:,sel)) ;
% h2 = vl_plotframe(f(:,sel)) ;
% % set(h1,'color','k','linewidth',3) ;
% % set(h2,'color','y','linewidth',2) ;
% 
% h3 = vl_plotsiftdescriptor(d(:,sel),f(:,sel)) ;
% set(h3,'color','g') ;