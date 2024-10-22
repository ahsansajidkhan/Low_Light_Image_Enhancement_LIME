clear;
clc;

%% add path of a folder including support functions
addpath('functions');


% Parameters
N = 5;  % Number of exposure levels
image_folder = 'LoL_single\';  % Replace with the actual folder path

% Virtual exposure enhancer function
enhance_image = @(I0, k) min(I0 + k * I0 .* (1 - I0), 1);

% Load low-light images from the specified folder
low_light_images = dir(fullfile(image_folder, '*.jpg'));  % Assuming images are in PNG format

% Process each low-light image
for img_idx = 1:numel(low_light_images)
    % Read the low-light image
    I0 = imread(fullfile(image_folder, low_light_images(img_idx).name));
    
    % Convert the image to double
    I0_double = im2double(I0);
    
    % Generate virtual exposure images
    k_values = linspace(0.5, 12, N);  % Adjust the range of k values as needed
    virtual_exposure_images = cell(1, N);

    figure;
    subplot(2, N+1, 1); imshow(I0_double); title('Original Image (Double)');
    
    for i = 1:N
        virtual_exposure_images{i} = enhance_image(I0_double, k_values(i));
        subplot(2, N+1, i+1); imshow(virtual_exposure_images{i});
        title(['Virtual Exposure Image ' num2str(i) ', k = ' num2str(k_values(i))]);
    end
    
    % Plot image conversion curve
    subplot(2, N+1, N+2:N*2+1);
    for i = 1:N
        plot(linspace(0, 1, 100), enhance_image(linspace(0, 1, 100), k_values(i)), 'LineWidth', 2);
        hold on;
    end
    hold off;
    title('Image Conversion Curve');
    xlabel('Input Image Intensity');
    ylabel('Enhanced Image Intensity');
    grid on;

    % Add legend with k_values
    legend(cellstr(num2str(k_values', 'k = %0.2f')));

    % Alternative to suptitle (available in recent MATLAB versions)
    sgtitle(['Processing Low-Light Image ' num2str(img_idx)]);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%% Weight Calculation %%%%%%%%%%%%%%%%%%%%%%%%

c= weight_contrast(virtual_exposure_images{1});
sal= weight_saliency(w_construct(virtual_exposure_images{1}));
sat= weight_saturation(w_construct(virtual_exposure_images{1}));

w_c_s_s = c.*sal.*sat;

wls = wlsFilter(w_c_s_s);
weight_normalize = normalizeWeights(wls);




