% Parameters
N = 5;  % Number of exposure levels
image_folder = 'LoL2_image\';  % Replace with the actual folder path

% Virtual exposure enhancer function
enhance_image = @(I0, k) min(I0 + k * I0 .* (1 - I0), 1);

% Load low-light images from the specified folder
low_light_images = dir(fullfile(image_folder, '*.png'));  % Assuming images are in JPEG format

% Process each low-light image
for img_idx = 1:numel(low_light_images)
    % Read the low-light image
    I0 = imread(fullfile(image_folder, low_light_images(img_idx).name));
    
    % Generate virtual exposure images
    k_values = linspace(0.1, 2, N);  % Adjust the range of k values as needed
    virtual_exposure_images = cell(1, N);

    figure;
    subplot(2, 3, 1); imshow(I0); title('Original Image');

    for i = 1:N
        virtual_exposure_images{i} = enhance_image(I0, k_values(i));
        subplot(2, 3, i+1); imshow(virtual_exposure_images{i});
        title(['Virtual Exposure Image ' num2str(i) ', k = ' num2str(k_values(i))]);
    end
    
    % Plot image conversion curve
    figure;
    for i = 1:N
        plot(linspace(0, 1, 100), enhance_image(linspace(0, 1, 100), k_values(i)), 'LineWidth', 2);
        hold on;
    end
    hold off;
    title('Image Conversion Curve');
    xlabel('Input Image Intensity');
    ylabel('Enhanced Image Intensity');
    grid on;

    % Alternative to suptitle (available in recent MATLAB versions)
    sgtitle(['Processing Low-Light Image ' num2str(img_idx)]);
end
