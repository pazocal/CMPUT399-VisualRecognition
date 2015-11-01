function [match_fracs] = matchImages(imdb_path, seq_cutoff, verify_geom)
% Compares each image in imdb with all images upto 'seq_cutoff' time before it.
% The degree of match between two images is measured by the fraction of
% words that they have in common and they are considered matched if this
% is not less than 'match_thresh'.
if nargin<3
    verify_geom=1; % set this to 0 to turn off geometric verification step
end
if nargin<2
    seq_cutoff=10; % no. of images before the current image that are not matched
end
if nargin<1
    imdb_path='loop_closure_imdb_100000.mat';
    % need to be change with above file name
end

load(imdb_path);
no_of_images=numel(imdb.images.id);
if verify_geom
    disp('Geometric verification is enabled');
else
    disp('No geometric verification');
end

% Matrix for computing loop closure detection
match_fracs=double(zeros(no_of_images));

% %%%%%%%  pseudo-code outline for matching %%%%%%%%
%
% for every pair of images that are at least seq_cutoff apart,
% call "matchWords" function to obtain number of matched words.
%
% If verify_geom variable is 0, divide number of matched words by the
% number of words present in the image pair to compute the degree of match
% between the image pair. Populate match_fracs matrix with the degree of match
%
% If verify_geom variable is 1, call "geometricVerification" function,
% which outputs number of geoVerifica. Divide number of geoVerifica by the
% number of words present in the image pair to compute the degree of match
% between the image pair. Populate match_fracs matrix with the degree of match
%
% Call supplied function "convertToBinary" to decide a suitable threshold
% for match_fractions. Match your binary matrix output (O) with ground truth
% binary matrix (G) by computing Jaccard score: sum(sum(and(O,G)))/ sum(sum(or(O,G)))

for i=1:size(imdb.images.id,2)
    for j=1:i - seq_cutoff
        % compare every possible pair until the cutoff img 
        matchResult = matchWords(imdb.images.words{i},imdb.images.words{j});
        wordLen = length(unique(imdb.images.words{i}));
        if verify_geom== 1
            % geo = 'g'
            % ignore empty match result to avoid error
            if ~isempty(matchResult)
                % call gemVerification
                geoVerifica = geometricVerification(imdb.images.frames{i},imdb.images.frames{j},matchResult);
                % divide # of geoVer by the # of words present in the image pair
                match_fracs(i,j) = length(geoVerifica)/wordLen;
            end
        else
            % geo = 'ng'
            match_fracs(i,j) = length(matchResult)/wordLen;
        end
    end
end


% here I add 2 new parameters for the convertToBinary funtion.
% therefore we can pass the truth value of geoVerif and the number of words 
% for descriptive file name
convertToBinary(match_fracs,imdb.numWords,verify_geom);




