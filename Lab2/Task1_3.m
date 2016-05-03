clc;clear;close all
% Subband Image Compression using Wavelets
%% Step 3.5
img = imread('frame50.bmp');
img = mat2gray(img); % Convert format to intensity image
figure
imagesc(img)
colormap gray

I3 = imread('step3_4.bmp');
I3 = mat2gray(I3); % Convert format to intensity image
figure
imagesc(I3)
colormap gray

e3 = abs(img - I3);
figure
imagesc(e3*30)
colormap gray
[x,y] = size(img);

% PSNR measure
nBits = 1;
Max = 2^nBits-1;
squareError = e3.^2;
MSE = sum(squareError(:))/(x*y);
PSNR3 = 10*log10(Max^2/MSE); % acceptable > 30dB (unsigned char)

% MSSIM measure
MSSIM3 = meanSSIM(img,I3);

