clc;clear;close all
% DCT-based Image Compression
%% Step 1.1
vidObj = VideoReader('Trees1.avi');
implay('Trees1.avi');
vidHeight = vidObj.Height;
vidWidth = vidObj.Width;

% MATLAB movie structure array
s = struct('cdata',zeros(vidHeight,vidWidth,3,'uint8'),...
    'colormap',[]);
% Read one frame at a time until the end of the file is reached
k = 1;
while hasFrame(vidObj)
    s(k).cdata = readFrame(vidObj);
    k = k+1;
end

[~,nFrames] = size(s); % Number of frames in video
% Selecting 2 image frames
index = [50,60];
frame1 = s(index(1)).cdata;
frame2 = s(index(2)).cdata;

% If colored, convert to gray scale
if length(size(frame1)) == 3
    frame1 = rgb2gray(frame1);
    frame2 = rgb2gray(frame2);
end

% Save image as .bmp format
imwrite(frame1,'frame50.bmp','bmp');
imwrite(frame2,'frame60.bmp','bmp');
figure
imagesc(frame1)
colormap gray

%% Step 1.2
frame1 = mat2gray(frame1); % Convert format to intensity image
F = dct2(frame1); % Apply 2D DCT to an entire image
figure
imagesc(F)
colormap gray

%% Step 1.3
reshape_F = reshape(F,vidHeight*vidWidth,1);
[~,I] = sort(reshape_F); 
th = I(round(0.9*vidHeight*vidWidth)); % Set threshold position

F1 = F;
F1(abs(F1)<reshape_F(th)) = 0; % For value below threshold, replace with 0

figure
imagesc(F1)
colormap gray

%% Step 1.4
I1 = idct2(F1);
figure
imagesc(I1)
colormap gray

e1 = abs(frame1 - I1); % Compute error image
e = 30*e1; % 30 times enlarge
figure
imagesc(e)
colormap gray

% PSNR measure
nBits = 8;
Max = 2^nBits-1;
squareError = e1.^2;
MSE = sum(squareError(:))/vidHeight*vidWidth;
PSNR = 10*log10(Max^2/MSE); % acceptable > 30dB

% Mean SSIM measure
MSSIM = meanSSIM(frame1,I1);