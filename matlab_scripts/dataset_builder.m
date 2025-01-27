% Define the folder paths
cleanFolder = 'C:\Users\Rohan Mahesh Rao\Desktop\Dip\Image-Despeckling\New_images\clean_rename\';
noisyFolder = 'C:\Users\Rohan Mahesh Rao\Desktop\Dip\Image-Despeckling\New_images\noisy\';

% Get the list of PNG files in the clean folder
cleanFiles = dir([cleanFolder, 'clean*.png']);

% Create the output CSV file
outputFile = 'results.csv';
fid = fopen(outputFile, 'w');
fprintf(fid, 'Filename,Max_SSIM,H,S,V\n');
%% 

% Loop through each clean image
for i = 1:length(cleanFiles)
    % Read the clean and noisy images
    cleanFilename = fullfile(cleanFolder, cleanFiles(i).name);
    noisyFilename = fullfile(noisyFolder, ['speckled', num2str(i), '.png']);
    I_clean = imread(cleanFilename);
    I_noisy = imread(noisyFilename);
    
    %Apply the Lee filter and post-processing

    lee_2 = Leefilter(I_noisy, 2);
    lee_3 = Leefilter(I_noisy, 3);
    lee_4 = Leefilter(I_noisy, 4);
    lee_5 = Leefilter(I_noisy, 5);
    lee_6 = Leefilter(I_noisy, 6);
    lee_7 = Leefilter(I_noisy, 7);
    lee_8 = Leefilter(I_noisy, 8);
    
    output_lee_2 = postpr(lee_2);
    output_lee_3 = postpr(lee_3);
    output_lee_4 = postpr(lee_4);
    output_lee_5 = postpr(lee_5);
    output_lee_6 = postpr(lee_6);
    output_lee_7 = postpr(lee_7);
    output_lee_8 = postpr(lee_8);
    
    % Calculate H, S, and V values for each output image
    H = zeros(7, 1);
    S = zeros(7, 1);
    V = zeros(7, 1);
    maxSSIM = 0;
    
    outputs = {output_lee_2, output_lee_3, output_lee_4, output_lee_5, output_lee_6, output_lee_7, output_lee_8};
    
    for j = 1:7
        % Convert the output image to RGB color space
        outputs{j} = im2uint8(outputs{j});
        outputs{j} = cat(3, outputs{j}, outputs{j}, outputs{j});
        
        hsv = rgb2hsv(outputs{j});
        H(j) = max(hsv(:,:,1), [], 'all');
        S(j) = max(hsv(:,:,2), [], 'all');
        V(j) = max(hsv(:,:,3), [], 'all');
        
        % Calculate SSIM between the current output and the clean image
        SSIM = ssim(outputs{j}, I_clean);
        if SSIM > maxSSIM
            maxSSIM = SSIM;
        end
    end
    
    % Write the results to the CSV file
    fprintf(fid, '%s,%f,%f,%f,%f\n', cleanFiles(i).name, maxSSIM, H(1), S(1), V(1));
end

% Close the CSV file
fclose(fid);
disp('Results written to the CSV file.');

function lee_output = Leefilter(img,window_size)

img = double(img);
lee_output = img;
means = imfilter(img, fspecial('average', window_size), 'replicate');
sigmas = sqrt((img-means).^2/window_size^2);
sigmas = imfilter(sigmas, fspecial('average', window_size), 'replicate');

ENLs = (means./sigmas).^2;
sx2s = ((ENLs.*(sigmas).^2) - means.^2)./(ENLs + 1);
fbar = means + (sx2s.*(img-means)./(sx2s + (means.^2 ./ENLs)));
lee_output(means~=0) = fbar(means~=0);

end

function post_out = postpr(a)
    mf = ones(3, 3)/9;
    meanfilt = imfilter(a,mf);
    c =imsharpen(meanfilt,'Radius',3.5,'Amount',3.5);
    post_out = imfilter(c,mf);
end
