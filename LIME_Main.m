%%%%%%%%%%%%%%%%%%%%% Project Group 5 %%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Project Name :Integrating Virtual Exposure in LIME Low-light Image Enhancement
% Ahsan Md Sajid Khan, Yang Gao, Jun Cheng, and He Yan
% CPSC5416 - Digital Image Processing & Computer Vision
% MSc Computational Sciences

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


clear;
clc;

%% Adding folder locations for required functions
addpath('functions');

% Parameters
N = 5;  % Number of virtual exposure levels
I0 = imread('High/lampicka11.png');  % Reading low-light image

img=I0;
 % Convert the image to double
 I0 = im2double(I0);


%%%%%%%%%% Virtual exposure enhancer function %%%%%%%%%%%%%%%%%%%%
enhance_image = @(I0, k) min(I0 + k * I0 .* (1 - I0), 1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



figure(1);
subplot(2, 3, 1); imshow(I0); title('Original Image');

%%%%%%%%%%%%%%%%%%%%%%%%% Generaating Virtual Exposure Images %%%%%%%%%%%%%%%%%%%

k_values = linspace(0.5, 8, N);  % Adjust the range of k values as needed. Prefered maximum 8-15

%%%%% Initializing Virtual Exposure image array %%%%%%%%%%%
virtual_exposure_images = zeros(size(I0,1),size(I0,2),size(I0,3),N); 


for i = 1:N

    virtual_exposure_images(:,:,:,i) = enhance_image(I0, k_values(i));

    % wls_weight(:,:,i) = wlsFilter(rgb2gray(virtual_exposure_images(:,:,:,i)),0.5);

    subplot(2, 3, i+1); imshow(virtual_exposure_images(:,:,:,i));
    title(['Virtual Exposure Image ' num2str(i) ', k = ' num2str(k_values(i))]);
end

%%%%%%%%%%%%%%% Ploting Image Conversion Curve %%%%%%%%%%%%%%%%%%
figure(2);
   
    for i = 1:N
        plot(linspace(0, 1, 100), enhance_image(linspace(0, 1, 100), k_values(i)), 'LineWidth', 2);
        hold on;
    end
    hold off;
    title('Image Conversion Curve');
    xlabel('Input Image Intensity');
    ylabel('Enhanced Image Intensity');
    grid on;
    legend(cellstr(num2str(k_values', 'k = %0.2f')));


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%% Weight Calculations %%%%%%%%%%%%%%%%%%%%%%%%%%
w_con = weight_contrast(virtual_exposure_images); %% Weight calculation for contrast of N numbers of images
w_sal = weight_saliency(virtual_exposure_images); %% Weight calculation for saliency of N numbers of images
w_sat = weight_saturation(virtual_exposure_images); %% Weight calculation for saturation of N numbers of images

%%% Constructing weight %%%%%%%%%%%%
weights = w_construct(w_con.*w_sal.*w_sat);

%%% Normalizing weights %%%%%%%%%%%%
w_norm = normalizeWeights(weights);



%%%%%%%%%%%%% Applying Laplacian, Gaussian and reconstruction %%%%%%%%

layer = 20; %%% Layer of pyramid
out_img = fusion_pyramid(virtual_exposure_images,w_norm,layer);

figure(3);
subplot(1,2,1);
imshow(img);
title("Original Low-Light Image");

subplot(1,2,2);
imshow(out_img);
title("Enhanced Image")




  

