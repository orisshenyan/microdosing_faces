% Parameters for generating multiple noise images
imageSize = [1080, 1920]; % Image size
numImages = 10; % Number of images to generate
outputDir = 'Output'; % Specify your output directory here

% Ensure the output directory exists, create it if not
if ~exist(outputDir, 'dir')
    mkdir(outputDir);
end

% Original parameters for noise generation
baseSDs = [10, 16, 32]; % Base standard deviations (SDs) for Gaussian blobs
baseIntensities = [-0.3, -0.25, -0.2, 0.2, 0.25, 0.3]; % Base intensity amplitudes
coverageWeights = [0.6, 0.3, 0.1]; % Weights for each blob size indicating their pixel coverage

% Loop to generate multiple noise images
for imgNum = 1:numImages
    % Initialize the image matrix with mean gray (0 intensity) for each new image
    imageMatrix = zeros(imageSize);
    
    % Introduce slight variations to SDs and intensities for each image
    SDs = baseSDs + randn(size(baseSDs)) * 0.5; % Add small random variations to SDs
    intensities = baseIntensities + randn(size(baseIntensities)) * 0.05; % Add small random variations to intensities

    % Calculate total area to be covered by blobs
    totalArea = imageSize(1) * imageSize(2);
    
    % Determine the area each weight category should cover
    coverageAreas = totalArea * coverageWeights;
    
    % Loop over each varied SD to place blobs
    for i = 1:length(SDs)
        % Estimate area covered by a single blob of this SD
        blobArea = pi * SDs(i)^2;
        
        % Calculate the number of blobs needed to cover the desired area
        numBlobs = round(coverageAreas(i) / blobArea);
        
        for j = 1:numBlobs
            % Choose a random position for the blob within the image
            xPos = randi([1, imageSize(2)]);
            yPos = randi([1, imageSize(1)]);
            
            % Select a random intensity for the blob
            intensity = intensities(randi(length(intensities)));
            
            % Generate and add the Gaussian blob to the image matrix
            [X, Y] = meshgrid(1:imageSize(2), 1:imageSize(1));
            gaussianBlob = exp(-((X-xPos).^2 + (Y-yPos).^2) / (2 * SDs(i)^2));
            gaussianBlob = gaussianBlob * intensity;
            imageMatrix = imageMatrix + gaussianBlob;
        end
    end
    
    % Normalize the imageMatrix to the range [0, 1] for display
    imageMatrix = imageMatrix - min(imageMatrix(:));
    imageMatrix = imageMatrix / max(imageMatrix(:));
    
    % Save each generated noise image to a file
    fileName = fullfile(outputDir, sprintf('gaussian_noise_stimuli_%d.png', imgNum));
    imwrite(imageMatrix, fileName);
end
