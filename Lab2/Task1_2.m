clc;clear;close all
% Block-based DCT-domain Image Compression
%% Step 2.1
img = imread('frame50.bmp');
if length(size(img)) == 3
    img = rgb2gray(img);
end
%% Step 2.2
img = mat2gray(img); % Convert format to intensity image
figure
imagesc(img)
colormap gray
% divide into 8*8 size blocks, each block performs DCT 
fun = @(block_struct) dct2(block_struct.data);
F2 = blockproc(img, [8 8], fun);
figure
imagesc(F2)
colormap gray

%% Step 2.3
% fun = @(block_struct) blockCompression(block_struct.data);
% F2 = blockproc(F2, [8 8], fun);
F2 = Compression( F2 );

%% Step 2.4
fun = @(block_struct) idct2(block_struct.data);
I2 = blockproc(F2, [8 8], fun);
figure
imagesc(I2)
colormap gray

%% Step 2.5
e2 = abs(img - I2);
figure
imagesc(e2*30)
colormap gray
[x,y] = size(img);

% PSNR measure
nBits = 1;
Max = 2^nBits-1;
squareError = e2.^2;
MSE = sum(squareError(:))/(x*y);
PSNR2 = 10*log10(Max^2/MSE); % acceptable > 30dB

% MSSIM measure
MSSIM2 = meanSSIM(img,I2);



