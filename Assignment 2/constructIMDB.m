function [imdb] = constructIMDB(dir_name, count, no_of_words)
% reads images from the given directory and constructs a database

% default parameters
if nargin<3
    no_of_words=10000;
end
if nargin<2
    count=1063;
end
if nargin<1
    dir_name='Lip6OutdoorDataSet/Images';
end

% Step 1: Initialize imdb structure
images.name=cell(1, count);
images.id=1:count;
images.frames=cell(1, count);
images.words=cell(1, count);
images.descrs=cell(1, count);
imdb.images=images;
imdb.dir=dir_name;
imdb.featureOpts={'method','dog','affineAdaptation',true,'orientation',false};
imdb.numWords=no_of_words;
imdb.sqrtHistograms=0;

% a variable where you will save the imdb database later
save_template='loop_closure_imdb'; 

% Step 2: Read images and extract features
% Here you will be reading images, calling "getFeatures" function and populating
% imdb.images.name, imdb.images.frames and imdb.images.descrs cell arrays

Image_type = '/*.ppm';

disp('Please wait for a long time!');
ImageUse = dir([imdb.dir Image_type]);
for i=1:count
    imdb.images.name{1,i} = ImageUse(i).name;
    image = imread([imdb.dir '/' ImageUse(i).name]);
    [frame, descrs] = getFeatures(image,imdb.featureOpts{:}) ;
    imdb.images.frames{1,i} = frame;
    imdb.images.descrs{1,i} = descrs;
end

% Step 3: Construct a vocabulary of words from the combined features of all the images
% using K-Means clustering. Call "vl_kmeans" function with combined features and
% imdb.numWords to assign vocabulary to imdb.vocab

des = cat(2,imdb.images.descrs{:});
centerWord = vl_kmeans(des,imdb.numWords,'algorithm','ANN');
imdb.vocab = centerWord;

% Step 4: Construct a KD tree from this vocabulary and assign to imdb.kdtree

imdb.tree = vl_kdtreebuild(centerWord);

% Step 5: Find the words present in each image through NN search of the
% vocabulary to populate imdb.images.words cell array. Use "vl_kdtreequery" 
% function for the NN search.


for i = 1:count
    imdb.images.words{i} = vl_kdtreequery(imdb.tree, imdb.vocab,imdb.images.descrs{i});
end


% Step 6: Compute indexes and idf weights by calling "loadIndex" function
imdb = loadIndex(imdb);

% Step 7: Save imdb in a .mat file
save(strcat(save_template, '.mat'), 'imdb');