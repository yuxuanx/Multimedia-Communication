function [ mssim ] = meanSSIM( img1, img2 )
% Compute the mean SSIM value of two images
k1 = 0.01;
k2 = 0.03;
L = 1; % Indensity image dynamic range is 1
c1 = (k1*L)^2;
c2 = (k2*L)^2;

gaussFilt = fspecial('Gaussian',[11 11],1.5); % 11*11 size Gaussian window

mux2 = imfilter(img1, gaussFilt,'conv','replicate');
muy2 = imfilter(img2, gaussFilt,'conv','replicate');
muxy = mux2.*muy2;
mux2 = mux2.^2;
muy2 = muy2.^2;

sigmax2 = imfilter(img1.^2,gaussFilt,'conv','replicate') - mux2;
sigmay2 = imfilter(img2.^2,gaussFilt,'conv','replicate') - muy2;
sigmaxy = imfilter(img1.*img2,gaussFilt,'conv','replicate') - muxy;

num = (2*muxy + c1).*(2*sigmaxy + c2);
den = (mux2 + muy2 + c1).*(sigmax2 + sigmay2 + c2);

SSIM = num./den;
mssim = mean(SSIM(:));


end

