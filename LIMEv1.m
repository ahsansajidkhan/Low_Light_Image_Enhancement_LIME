
%%%%%%%%%%%% Project Group - 5 %%%%%%%%%%%%%
clear;
clc;

% Specify the directory containing input images (different exposures).
imageDirectory = 'LoL2_image\';

% List the image files in the directory
imageFiles = dir(fullfile(imageDirectory, '*.png'));

% Load the input images
numImages = numel(imageFiles);
% images = cell(1, numImages);

[height,width,rgb,~] = size(imread(fullfile(imageDirectory, imageFiles(1).name)));
% 
images = zeros(height, width, rgb, numImages);


for i = 1:numImages
    filename = fullfile(imageDirectory, imageFiles(i).name);
    % images{i} = imread(filename);
    images(:,:,:,i) = im2double(imread(filename));
end

b=image_fusion(images,numImages);

% % % Display and save the fused image

imshow(b);
 title('Fused Image');




%%%%%%%%%%%%%%%%%%%%%%%%%% Functions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function fused_image = image_fusion(images,elm_no)

% Number of pyramid levels
numLevels = 4;

%%%%% Creating Gaussian Pyramid of all images for the given level number/s
g_pyramid = cell(elm_no,numLevels);

    for l=1:elm_no
        g_pyramid(l,:)=buildGaussianPyramid(images(:,:,:,l),numLevels);
       
    end

    
    fused_pyramid =cell(size(g_pyramid(1,:)));

    for l=1:numLevels
    fused_pyramid{l}=blendImagesAtLevel(g_pyramid(:,l),elm_no);
    end

   fused_image =reconstructFromPyramid(fused_pyramid);
 
   
end

%%%%%%%%%%%%%%%%%%%%%% %%%%%%%%%%%%%% %%%%%%%%%%%%%%%%%%%%%%%%%%

% Function to build a Gaussian pyramid for an image
function pyramid = buildGaussianPyramid(image, levels)
    pyramid = cell(1, levels);
    pyramid{1} = image;
    for level = 2:levels
        pyramid{level} = impyramid(pyramid{level - 1}, 'reduce');
    end
   
end

%%%%%%%%%%%%%%%%%%%%%%% %%%%%%%%%%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Function to blend images at a specific pyramid level
function blendedImage = blendImagesAtLevel(images,elm_no)
    % Apply fusion method (e.g., weighted average)
   weight = 1/elm_no;

   % blendedImage = cell(size(images{1}));

  % Loop through each element in the cell arrays
    for n = 1:elm_no
        % Apply the operation to each element
        temp = images{n} * weight;

        % Add the results to the blendedImage cell array
        if n == 1
            blendedImage = temp;
        else
            blendedImage = blendedImage + temp;
        end
    end

   
end

%%%%%%%%%%%%%% %%%%%%%%%%%% %%%%%%%%%%%%%%%%%%%%%%%%

% Function to reconstruct the fused image from the fused pyramid
function image = reconstructFromPyramid(pyramid)
    levels = length(pyramid);
    image = pyramid{levels};
    for level = levels-1:-1:1
        % Upsample the current image to match the size of the next level
        upsampledImage = impyramid(image, 'expand');
        [h, w, ~] = size(pyramid{level});
        % Resize the upsampled image to match the size of the current level
        upsampledImage = imresize(upsampledImage, [h, w]);
        image = upsampledImage + pyramid{level}; % Add the current level details
    end
end

