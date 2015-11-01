function [imdb] = constructIMDB(dir_name, count, no_of_words)
% reads images from the given directory and constructs a database

% default parameters
if nargin<3
    numWords = 0;
    % unquote next line and quote above line for 1K, 5K, 10K
    % no_of_words=5000;
end
if nargin<2
    count=1063;
end
if nargin<1
    dir_name='Lip6OutdoorDataSet/Images';
end
load 'oxbuild_lite_imdb_100k_ellipse_dog.mat'
% Step 1: Initialize imdb structure
images.name=cell(1, count);
images.id=1:count;
images.frames=cell(1, count);
images.words=cell(1, count);
images.descrs=cell(1, count);
imdb.images=images;
imdb.dir=dir_name;
imdb.featureOpts={'method','dog','affineAdaptation',true,'orientation',false};
imdb.numWords=numWords;
% unquote next line and quote above line for 1K, 5K, 10K
% imdb.numWords=no_of_words;
imdb.sqrtHistograms=0;

% a variable where you will save the imdb database later
% save_template='loop_closure_imdb'; 

% we add a postfix (i.e. the number of words) for the original template therefore I can keep 3
% generated imdb files at the same time.
save_template=['loop_closure_imdb_',num2str(imdb.numWords)];

% Step 2: Read images and extract features
% Here you will be reading images, calling "getFeatures" function and populating
% imdb.images.name, imdb.images.frames and imdb.images.descrs cell arrays
img_type = '/*.ppm';

img_set = dir([imdb.dir img_type]);
for i=1:count
    if mod(i, 100)==0,
        fprintf('Processed %d images\n', i);
    end
    imdb.images.name{1,i} = img_set(i).name;
    image = imread([imdb.dir '/' img_set(i).name]);
    % get the feature, pop frames and descrs
    [frame, descrs] = getFeatures(image,imdb.featureOpts{:}) ;
    imdb.images.frames{1,i} = frame;
    imdb.images.descrs{1,i} = descrs;
end

% Step 3: Construct a vocabulary of words from the combined features of all the images
% using K-Means clustering. Call "vl_kmeans" function with combined features and
% imdb.numWords to assign vocabulary to imdb.vocab

% contruct the vocab: cat the imdb.images.descrs to a 2-D array first then
% call vl_kmeans, here ANN algorithm is chosen.

% unquote next line and quote above line for 1K, 5K, 10K
% imdb.vocab = vl_kmeans(cat(2,imdb.images.descrs{:}),imdb.numWords,'algorithm','ANN');
 imdb.vocab = vocab;
 
% Step 4: Construct a KD tree from this vocabulary and assign to imdb.kdtree

imdb.kdtree = vl_kdtreebuild(imdb.vocab);

% Step 5: Find the words present in each image through NN search of the
% vocabulary to populate imdb.images.words cell array. Use "vl_kdtreequery" 
% function for the NN search.

for i = 1:count
    imdb.images.words{i} = vl_kdtreequery(imdb.kdtree, imdb.vocab,imdb.images.descrs{i});
end

% Step 6: Compute indexes and idf weights by calling "loadIndex" function
imdb = loadIndex(imdb);

% Step 7: Save imdb in a .mat file
save(strcat(save_template, '.mat'), 'imdb');