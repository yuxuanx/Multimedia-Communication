clc;clear;close all
% Intre-Frame Motion Compensation and Compression
%% Task 2.1
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
% Convert format to intensity image
frame1 = mat2gray(frame1); 
frame2 = mat2gray(frame2);

%% Task 2.2
Iold = frame1;
figure
imagesc(Iold)
colormap gray

Inew = frame2;
figure
imagesc(Inew)
colormap gray

Idiff = Inew - Iold;
th = 50/255; % Threshold
Idiff(abs(Idiff)<th) = 0;
figure
imagesc(Idiff)
colormap gray

%% Task 2.3
fun = @(block_struct) motionEstimate(block_struct.data);
Imotion = blockproc(Idiff, [16 16], fun);

figure
imagesc(Imotion)
colormap gray

%% Task 2.4
% Compute motion vectors
Inew_motion = Inew.*Imotion;
[Nx,Ny] = size(Inew);
fun = @(block_struct) motionVectors(block_struct.data,Nx,Ny,Iold,block_struct.location);
mvMatrix = blockproc(Inew_motion, [16 16], fun);
dxMatrix = mvMatrix(:,1:2:end);
dyMatrix = mvMatrix(:,2:2:end);
MV(:,:,1) = dxMatrix;
MV(:,:,2) = dyMatrix;

% Motion Compensation for motion blocks and INTRA processing of non-motion
% blocks by copying previous blocks
fun = @(block_struct) motionCompensation(block_struct.location, block_struct.blockSize, Iold, MV);
I5 = blockproc(Iold, [16 16], fun);
I4 = I5.*Imotion;
figure
imagesc(I4)
colormap gray
figure
imagesc(I5)
colormap gray

e5 = abs(Inew-I5);
figure
imagesc(e5*30)
colormap gray

% PSNR measure
nBits = 8;
Max = 2^nBits-1;
squareError = e5.^2;
MSE = sum(squareError(:))/Nx*Ny;
PSNR_I5 = 10*log10(Max^2/MSE); % acceptable > 30dB

% MSSIM measure
MSSIM_I5 = meanSSIM(Inew,I5);



