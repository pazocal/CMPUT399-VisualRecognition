close all;
clear all;

I = imread('cameraman.tif');
figure(1),imagesc(I),colormap(gray),axis image;

[x,y] = ginput(1);
x = round(x); 
y = round(y);

[Ix,Iy] = gradient(double(I));

w = fspecial('Gaussian',[5 5],1);

M_for = zeros(2,2);
for i=-2:2,
    for j=-2:2,
        M_for = M_for + w(3+i,3+j)*[Ix(y+i,x+j)^2 Ix(y+i,x+j)*Iy(y+i,x+j); ...
                                    Ix(y+i,x+j)*Iy(y+i,x+j) Iy(y+i,x+j)^2];
    end
end

M11 = imfilter(Ix.^2,w,'same','conv','replicate');
M22 = imfilter(Iy.^2,w,'same','conv','replicate');
M12 = imfilter(Ix.*Iy,w,'same','conv','replicate');

% M matrix at (x,y) point
M_xy = [M11(y,x) M12(y,x); M12(y,x) M22(y,x)];

% eigenvalues of M at (x,y)
d = eig(M_xy);

% compute cornerness score f at (x,y)
f = (d(1)*d(2))/(d(1) + d(2));

% display f
disp(['Corness score: ' num2str(f)]);

% optional computing cornerness on the entire matrix
% we need to work with a different, but equivalent formula
% https://en.wikipedia.org/wiki/Corner_detection

% numerator
N = M11.*M22 - M12.^2;
% denominator
D = M11 + M22 + eps;
F = N./D;

figure(2),imagesc(F),axis image;