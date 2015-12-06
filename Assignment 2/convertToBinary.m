function convertToBinary(match_fracs, thresholds)
% computes and displays a series of binary images for 'match_fracs'
% corresponding to several thresholds varying from 0 to 1.
if nargin<2
    thresholds=0:0.1:1;
end
if nargin<1
    load('match_fracs_geom.mat');
end
warning('off','all');
ground_truth_file='Lip6OutdoorDataSet\Lip6OutdoorGroundTruth';
load(ground_truth_file);
if nargin<2
    thresholds=0:0.01:0.5;
end
no_of_threshols=length(thresholds);
binary_matrices=cell(no_of_threshols, 2);
jacc_scores=zeros(no_of_threshols, 2);
id=1;
figure;
max_score=0;
max_thresh=0;
for thresh=thresholds
    matches=zeros(size(match_fracs));
    matches(match_fracs>=thresh)=1;
    jacc_scores(id, 1)=thresh;
    jacc_score=sum(sum(and(matches,truth)))/ sum(sum(or(matches,truth)));
    if jacc_score>max_score
        max_score=jacc_score;
        max_thresh=thresh;
        max_id=id;
    end
    jacc_scores(id, 2)=jacc_score;
    binary_matrices{id, 1}=thresh;
    binary_matrices{id, 2}=matches;
    id=id+1;
    img_title=sprintf('Threshold %5.2f', thresh);
    imshow(matches), title(img_title);
    filename=sprintf('matches_thresh_%5.2f.jpg', thresh);
    imwrite(matches,filename)
    pause(0.1);
end
save('binary_matrices.mat', 'binary_matrices', 'jacc_scores');
fprintf('Maximum Jaccard Score=%f corresponding to threshold %5.2f\n',...
    max_score, max_thresh);
figure, plot(jacc_scores(:, 1), jacc_scores(:, 2)),...
    title('Jaccard Scores'), xlabel('Threshold'), ylabel('Score');
figure, imshow(binary_matrices{max_id, 2}), title('Optimal Binay Image');
