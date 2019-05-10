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
number_of_points = 7;

horizontal_indicies = 1:floor(vid_width/number_of_points):vid_width;
vertical_indicies = 1:floor(vid_height/number_of_points):vid_height;

[X, Y] = meshgrid(horizontal_indicies, vertical_indicies);

indicies = [horizontal_indicies; vertical_indicies];

%% Extract  pixel changes 

extracted_pixels = zeros(size(vertical_indicies,2),...
                         size(horizontal_indicies,2),...
                         vid_frames_cont);

frame_number = 1;
while hasFrame(video_file)
    vid_frame = readFrame(video_file);
    gray_frame = rgb2gray(vid_frame);

    extracted_pixels(:,:,frame_number) = gray_frame(vertical_indicies,...
                                                    horizontal_indicies);
    frame_number = frame_number + 1;
end

%% Reshape the extracted pixels to the vector form
rows = size(extracted_pixels,1);
vector_pixels = zeros(rows^2, length(extracted_pixels));

index = 1;
for row=1:rows
    for column=1:rows
        vector_pixels(index,:) = extracted_pixels(row, column,:);
        index = index+1;
    end
end

%%
% number_of_signals = length(vector_pixels);
% C_ij = zeros(size(vector_pixels,1));
% 
% for row=1:number_of_signals
%     for column=1:number_of_signals
    i = 5;
    j = 4;

    % Consider the signals as neuron spike train in the total time duration T
    signal_ij = extracted_pixels(i,j,:);
    signal_ij = squeeze(signal_ij);

    signal_ji = extracted_pixels(i+1,j,:);
    signal_ji = squeeze(signal_ji);

    T = length(signal_ji);

    subplot(3, 1, 1)
    hold on
    plot(signal_ij)
    plot(signal_ji)
    hold off
    xlabel("Frame number")
    ylabel("Pixel value")
    legend("Signal 1", "Signal 2")


    % Create mean over interval
    % This is taking the mean firing rate of the neuron spike train
    interval_length = 15;
    subs = zeros(length(signal_ij),1);

    for i=1:interval_length:vid_frames_cont
        subs(i:end) = subs(i:end) + 1;
    end

    averaged_signal_1 = accumarray(subs, signal_ij,[],@sum);
    averaged_signal_2 = accumarray(subs, signal_ji,[],@sum);
    x = (1:length(averaged_signal_1))*interval_length ;

    subplot(3, 1, 2)
    hold on
    plot(x, averaged_signal_1, 'x-')
    plot(x, averaged_signal_2, 'x-')
    hold off
    xlabel("Frame number")
    ylabel(sprintf("Pixel sum over %d frames",frames))
    legend("Averaged signal 1", "Averaged signal 2")


    % cross_corelation
    [ccg_ij, lags] = xcorr(averaged_signal_1, averaged_signal_2); % , 'normalized'
    [ccg_ji, lags] = xcorr(averaged_signal_2, averaged_signal_1);

    ccg_ij = ccg_ij ./ T;
    ccg_ji = ccg_ji ./ T;

    subplot(3, 1, 3)
    stem(lags, ccg_ij)
    xlabel("Frame bin shift")
    ylabel("Normalized coerrelation")
    legend("Crosscorelation")

    %% correlation matrix
    [max_val_ij, middle_ij] = max(ccg_ij);
    [max_val_ji, middle_ji] = max(ccg_ji);

    tau_max = 10; % this is given in frames

    % What distribution does the pixel have?
    r_i = mean(signal_ij);
    r_j = mean(signal_ji);

    A = sum(ccg_ij(middle_ij:middle_ij+tau_max));
    B = sum(ccg_ji(middle_ji:middle_ji+tau_max ));

    c_ij = max([A B])/(tau_max*r_i*r_j);
    c_ij
    r_i*r_j
%     end
% end
