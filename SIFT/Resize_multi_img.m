% mkdir('ImgResult') 
% for i=1:12;
%     [FileName,PathName,~] = uigetfile('*.jpg');
%     I = imread([PathName FileName]);
%     % change the second parameters for different result size.
%     J = imresize(I,0.6)
%     imwrite(J,strcat('ImgResult\',int2str(i),'.jpg'));
% end
% 

    [FileName,PathName,~] = uigetfile('*.jpg');
    I = imread([PathName FileName]);
    % change the second parameters for different result size.
    J = imresize(I,0.6)
    imwrite(J,strcat('ImgResult\',int2str(12),'.jpg'));