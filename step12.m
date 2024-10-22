clear;
clc;

% Parameters
N = 5;  % Number of exposure levels
image_folder = 'LoL2_image\';  % Replace with the actual folder path

% Virtual exposure enhancer function
enhance_image = @(I0, k) min(I0 + k * I0 .* (1 - I0), 1);

% Load low-light images from the specified folder
low_light_images = dir(fullfile(image_folder, '*.png'));  % Assuming images are in PNG format

% Process each low-light image
for img_idx = 1:numel(low_light_images)
    % Read the low-light image
    I0 = imread(fullfile(image_folder, low_light_images(img_idx).name));
    
    % Convert the image to double
    I0_double = im2double(I0);
    
    % Generate virtual exposure images
    k_values = linspace(0.01, 1, N);  % Adjust the range of k values as needed
    virtual_exposure_images = cell(1, N);

    figure;
    for i = 1:N
        virtual_exposure_images{i} = enhance_image(I0_double, k_values(i));

        % Step 2: Calculate Weight Maps in MATLAB

        % Read the image
        img = virtual_exposure_images{i}; % Replace with your image path
        
        % Convert to grayscale for contrast calculation
        grayImg = rgb2gray(img);
        
        % Normalize the pixel values to [0, 1] for contrast
        normalizedImg = double(grayImg) / 255;
        
        % Define the Laplacian filter for contrast
        laplacianFilter = [0 1 0; 1 -4 1; 0 1 0];
        
        % Apply the Laplacian filter for contrast
        filteredImg = imfilter(normalizedImg, laplacianFilter, 'replicate');
        
        % Take the absolute value to get the contrast
        contrastWeight = abs(filteredImg);
        
        % Saturation calculation
        % Extract R, G, B components
        R = double(img(:,:,1)) / 255;
        G = double(img(:,:,2)) / 255;
        B = double(img(:,:,3)) / 255;
        
        % Mean of the R, G, B components
        m_bar = (R + G + B) / 3;
        
        % Calculate the standard deviation for saturation
        saturationWeight = sqrt(((R - m_bar).^2 + (G - m_bar).^2 + (B - m_bar).^2) / 3);
        
        % Visual Saliency calculation
        % Convert to Lab color space
        labImg = rgb2lab(img);
        
        % Gaussian blurring
        sigma = size(img,2) / 2.75;
        blurredLab = imgaussfilt(labImg, sigma);
        
        % Saliency weight map calculation
        saliencyWeight = sqrt(sum((labImg - blurredLab).^2, 3));
        
        % Calculate the final weight by multiplying contrast, saturation, and saliency weights
        finalWeight = contrastWeight .* saturationWeight .* saliencyWeight;
        
        % Normalize the final weight
        normalizedWeight = finalWeight ./ max(finalWeight(:));
        
        % Displaying the results
        subplot(6, N, i + N * 0); imshow(virtual_exposure_images{i}); title(['VE Image ' num2str(i)]);
        subplot(6, N, i + N * 1); imshow(contrastWeight, []); title('Contrast Weight');
        subplot(6, N, i + N * 2); imshow(saturationWeight, []); title('Saturation Weight');
        subplot(6, N, i + N * 3); imshow(saliencyWeight, []); title('Saliency Weight');
        subplot(6, N, i + N * 4); imshow(finalWeight, []); title('Final Weight');
        subplot(6, N, i + N * 5); imshow(normalizedWeight, []); title('Normalized Final Weight');
    end
end
