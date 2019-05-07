clc
clear all
%% Add path tothe Cique-top library
addpath("clique-top")

%% Load image
checkboard_image = imread('649j210.png');
candle_image = imread('64caf10.png');

% Change the colour of the image to grayscale
gray_image = rgb2gray(candle_image);

% Normailzie to the maximal value
gray_image = im2double(gray_image);


%% Reduce the size of the image
% Divide the image into non-overlapping squares. Then take the average
% value of the pixel in the square and let the square be represened by its
% average.

% Tile is a matrix in which values are averaged
tile_size = 6;
number_of_vertical_tiles = ceil(size(gray_image,1)/tile_size);
number_of_horizontal_tiles = ceil(size(gray_image,2)/tile_size);

new_size_vert = number_of_vertical_tiles*tile_size;
new_size_hor = number_of_horizontal_tiles*tile_size;

% Reshape the image
reshaped_image = imresize(gray_image, [new_size_vert new_size_hor]);

% Divide image into squares called tiles
set_of_tiles = mat2tiles(reshaped_image, tile_size, tile_size);

% Get the average value in each square
averaged_image = zeros(number_of_vertical_tiles);

for k = 1:number_of_vertical_tiles
    for m=1:number_of_vertical_tiles
        averaged_image(k,m) = mean(mean(cell2mat(set_of_tiles(k,m))));
    end
end

imshow(mat2gray(averaged_image))


%% Threshold image
threshold_lower = 0.4;
threshold_upper = 0.6;
% Get the values of the image which are lower/higher than the thresholds
indices_lower = averaged_image > threshold_lower;
indices_upper = averaged_image < threshold_upper;

% Get the values which are in between the thresholds
thresholded_image = indices_lower + indices_upper;
thresholded_image = thresholded_image >=2;

imshow(mat2gray(int8(thresholded_image)))

% Get the indexes of the non zero elements
[row,col] = find(thresholded_image);
indices = [row,col];

% Normalize indicies
indices = indices/max(max(indices));

% Compute distances
distance_matrix = pdist2(indices, indices,'euclidean');


%% Image fft
F = fft2(thresholded_image);
F2 = log(abs(F));
imshow(F2);%,[-1 5],'InitialMagnification','fit');
colormap(jet); 
colorbar
[row,col] = find(F2<1);

A = [row,col];
% Compute distances
distance_matrix = pdist2(A, A,'euclidean');
%% Compute the clique topology of the distance matrix of the image
% Reduce the number of elements in distance matrix to speed up computations
ending = 48;

[bettiCurves, edgeDensities, persistenceIntervals,...
    unboundedIntervals] =  compute_clique_topology(distance_matrix(1:ending, 1:ending), 'Algorithm', 'split');

%% Print the Betti curves

plot(edgeDensities, bettiCurves(:,1))
hold on
plot(edgeDensities, bettiCurves(:,2))
plot(edgeDensities, bettiCurves(:,3))

title("Betti curves for image")
legend("\beta_0","\beta_1","\beta_2")
hold off

