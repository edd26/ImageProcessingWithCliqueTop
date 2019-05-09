clc
clear all
%% Add path tothe Cique-top library
addpath("clique-top")

%% Load video
video_file =  VideoReader('64caf10.avi');

vid_width = video_file.Width;
vid_height = video_file.Height;
vid_frames_cont = video_file.Duration*video_file.FrameRate;
%% Create set of evenly distributed indicies
number_of_points = 15;

horizontal_indicies = 1:floor(vid_width/number_of_points):vid_width;
vertical_indicies = 1:floor(vid_height/number_of_points):vid_height;

[X, Y] = meshgrid(horizontal_indicies, vertical_indicies);

indicies = [horizontal_indicies; vertical_indicies];

%% Extract  pixel changes 

extracted_pixels = zeros(size(indicies,1),size(indicies,2), vid_frames_cont);

while hasFrame(video_file)
    vid_frame = readFrame(video_file);
    gray_frame = rgb2gray(vid_frame);
%     extracted_pixels = gray_frame(indicies);
% TODO: Indicies are at the moment extracting values from diagonal. Mesh
% over matrix is required
end

%% Reduce the size of the image
% Divide the image into non-overlapping squares. Then take the average
% value of the pixel in the square and let the square be represened by its
% average.

% Tile is a matrix in which values are averaged
tile_size = 4;
number_of_vertical_tiles = ceil(size(gray_image,1)/tile_size);
number_of_horizontal_tiles = ceil(size(gray_image,2)/tile_size);

new_size_vert = number_of_vertical_tiles*tile_size;
new_size_hor = number_of_horizontal_tiles*tile_size;

% Reshape the image
reshaped_image = imresize(gray_image, [new_size_vert new_size_hor]);

% Divide image into squares called tiles
set_of_tiles = mat2tiles(reshaped_image, tile_size, tile_size);

% Get the average value in each square
mean_image = zeros(number_of_vertical_tiles);
std_image = zeros(number_of_vertical_tiles);
skew_image = zeros(number_of_vertical_tiles);
kurt_image = zeros(number_of_vertical_tiles);

for k = 1:number_of_vertical_tiles
    for m=1:number_of_vertical_tiles
        tile_set = cell2mat(set_of_tiles(k,m));
        
        mean_image(k,m) = mean2(tile_set);
        std_image(k,m) = std2(tile_set);
        skew_image(k,m) = skewness(tile_set,1,'all');
        kurt_image(k,m) = kurtosis(tile_set,1,'all');
    end
end

imshow(mat2gray(std_image))

%% Distances
% Treat all the statistic measures of an image as set of coordinates.
% Compute the 
coordinate_matrix = zeros(number_of_vertical_tiles, number_of_vertical_tiles, 4);
coordinate_matrix(:,:,1) = mean_image;
coordinate_matrix(:,:,2) = std_image;
coordinate_matrix(:,:,3) = skew_image;
coordinate_matrix(:,:,4) = kurt_image;

%% Betti curve field
distance_matrix1 = zeros(number_of_vertical_tiles, number_of_vertical_tiles, number_of_vertical_tiles);
% What is the distance 
for k =1:number_of_vertical_tiles
    distance_matrix1(:,:,k) = pdist2(squeeze(coordinate_matrix(k,:,:)), ...
        squeeze(coordinate_matrix(k,:,:)),'euclidean');
end

bettiCurves_set = zeros(700, 3, number_of_vertical_tiles);
edgeDensities_set = zeros(700, 1, number_of_vertical_tiles);
% edgeDensities = zeros(number_of_vertical_tiles, number_of_vertical_tiles, number_of_vertical_tiles);
m = 72;

for k =1:number_of_vertical_tiles
    [bettiCurves, edgeDensities ] = ...
        compute_clique_topology(-distance_matrix1(1:m,1:m,k), 'Algorithm', 'split');
    bettiCurves_set(1:length(bettiCurves),:,k) = bettiCurves(:,:);
    edgeDensities_set(1:length(bettiCurves),:,k) = edgeDensities(:,:);
    fprintf("%d\n",k)
end

