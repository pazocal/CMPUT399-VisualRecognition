function convertToBinary(match_fracs,numWords,verify_geom)
% computes and displays a series binary images for 'match_fracs' 
% corresponding to several thresholds varying from 0 to 1.
warning('off','all');
%figure;
for thresh=0:0.05:0.5
    matches=zeros(size(match_fracs));
    matches(match_fracs >= thresh) = 1;
    filename=sprintf('%s_%s_matches_thresh_%5.2f.jpg',num2str(numWords),num2str(verify_geom),thresh);  
    imwrite(matches,filename)
    pause(0.2);
end
