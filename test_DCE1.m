clear;
clc;
% Parameters
N = 5;  % Number of exposure levels
I0 = imread('m2.jpg');  % Replace 'low_light_image.jpg' with the actual filename

img=I0;
 % Convert the image to double
 I0 = im2double(I0);
% Virtual exposure enhancer function
enhance_image = @(I0, k) min(I0 + k * I0 .* (1 - I0), 1);

% Generate virtual exposure images
k_values = linspace(0.05, 12, N);  % Adjust the range of k values as needed
virtual_exposure_images = cell(1, N);

figure;
subplot(2, 3, 1); imshow(I0); title('Original Image');

for i = 1:N
    virtual_exposure_images{i} = enhance_image(I0, k_values(i));
    subplot(2, 3, i+1); imshow(virtual_exposure_images{i});
    title(['Virtual Exposure Image ' num2str(i) ', k = ' num2str(k_values(i))]);
end


% disp(I0(1:4,1:4,1));
% disp(virtual_exposure_images{5}(1:4,1:4,1));

figure;
subplot(2,2,1);
imshow(histeq(img));
title("Image  after histogram equalization");

subplot(2,2,3);
histogram(histeq(img));
title("Histogram after histeq() function");

subplot(2,2,2);
imshow(virtual_exposure_images{3});
title("Enhanced image after virtual exposure");

subplot(2,2,4);
histogram(virtual_exposure_images{3});
title("Histogram of virtual exposure image");