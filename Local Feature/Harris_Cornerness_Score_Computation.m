close all;
clear all;

% http://www.mathworks.com/help/images/ref/fspecial.html?searchHighlight=fspecial
% read file
[FileName,PathName,~] = uigetfile('*.jpg');
I = imread([PathName FileName]);
I = rgb2gray(I);
figure,imagesc(I),axis image;
a = 1
b = 1
while(a < 10)
    [x,y]=ginput(1);
    x = round(x);
    y = round(y)
    [Ix,Iy]=gradient(double(I));
    w = fspecial('Gaussian',[5,5],1);
    M_for = zeros(2,2);
    for i=-2:2,
        for j=-2:2,
            M_for = M_for + w(3+i,3+j)*[Ix(y+i,x+j)^2 Ix(y+i,x+j)*Iy(y+i,x+j);...
                Ix(y+i,x+j)*Iy(y+i,x+j) Iy(y+i,x+j)^2];
        end
    end
    if (a == 1)
        M11 = imfilter(Ix.^2,w,'same','conv','replicate');
        M22 = imfilter(Iy.^2,w,'same','conv','replicate');
        M12 = imfilter(Ix.*Iy,w,'same','conv','replicate');

        M_xy = [M11(y,x) M12(y,x); M12(y,x) M22(y,x)];
    end

    d = eig(M_xy);

    f = (d(1)*d(2)/(d(1)+d(2)));

    disp('The cornorness score is:');
    disp(f);
    disp('Second part score is:');
    disp(M_for);
end


