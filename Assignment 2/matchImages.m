function [match_fracs] = matchImages(imdb_path, seq_cutoff, verify_geom)
% Compares each image in imdb with all images upto 'seq_cutoff' time before it.
% The degree of match between two images is measured by the fraction of
% words that they have in common and they are considered matched if this 
% is not less than 'match_thresh'.
if nargin<3
    verify_geom=0; % set this to 0 to turn off geometric verification step
end
if nargin<2
    seq_cutoff=10; % no. of images before the current image that are not matched
end
if nargin<1
    imdb_path='loop_closure_imdb.mat';
end
load(imdb_path);
no_of_images=numel(imdb.images.id);
match_fracs=double(zeros(no_of_images));
if verify_geom
    disp('Geometric verification is enabled');
end
tic
for i=seq_cutoff+1:no_of_images
    frames1=imdb.images.frames{i};
    words1=imdb.images.words{i};
    no_of_words=length(unique(words1));
    for j=1:i-seq_cutoff
        words2=imdb.images.words{j};
        frames2=imdb.images.frames{j};
        % Get the matches based on the quantized descriptors
        matches_word = matchWords(words1,words2) ;
        no_of_matches=length(matches_word);
        if verify_geom && no_of_matches>0
            % Perform geometric verification to get inliers
            inliers_word = geometricVerification(frames1,frames2,...
                matches_word,'numRefinementIterations', 3);
            no_of_matches=length(inliers_word);
        end
        match_frac=double(no_of_matches/no_of_words);
        match_fracs(i,j)=match_frac;
    end
    if mod(i, 10)==0
        fprintf('Processed %d of %d images\n', i, no_of_images);
    end
end
toc
if verify_geom
    save_file='match_fracs_geom.mat';
else
    save_file='match_fracs_no_geom.mat';
end
figure, imshow(match_fracs);
save(save_file, 'match_fracs');
end


