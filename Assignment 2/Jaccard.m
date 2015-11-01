% Jaccord.m is for computing the Jaccard score, you can change the value of geo and
% num variable. Options for geo are 1 and 0, 1, options for num is 1000, 5000, and 10000 

% run this script to start comput j_score
% load truth
load 'Lip6OutdoorDataSet\Lip6OutdoorGroundTruth'

% change the following two varibales to find the score
geo = 0;
num = 10000;

j_res = [];
% iteration from 0 to 0.5, bin value = 0.05
for threshold=0.00:0.05:0.50
    filename=sprintf('%s_%s_matches_thresh_%5.2f.jpg',num2str(num),num2str(geo), threshold);
    image = imread(filename);
    % Jaccard score: sum(sum(and(O,G)))/ sum(sum(or(O,G)))
    j_score = sum(sum(and(image,truth)))/sum(sum(or(image,truth)));
    j_res = [j_res;[threshold,j_score]];
end
disp(j_res);
