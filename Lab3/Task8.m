close all;
clear all;
clc;

%% Block 1
image=imread('lena.bmp');
image=mat2gray(image);
fun=@(block_struct)dct2(block_struct.data);
F=blockproc(image,[16 16],fun);
fun=@(block_struct)zigzag(block_struct.data);
seq=blockproc(F,[16 16],fun);
oneseq=reshape(seq.',1,[]);

%% Block 2
partition=linspace(min(oneseq),max(oneseq),255);
codebook=linspace(min(oneseq),max(oneseq),256);
[index,~]=quantiz(oneseq,partition,codebook);

%% Block 3
k=127;
index=[index zeros(1,k-mod(length(index),k))];
packets=reshape(index,k,[]);
packets=packets.';

%% Block 4
m=8;
n=2^m-1;
msgwords=gf(packets,m);
codes=rsenc(msgwords,n,k);

%% Block 5
% incodes=codes;
Nrows=259;
Ncols=255;
incodes=reshape(codes.',[],1);
incodes=matintrlv(incodes,Nrows,Ncols);
incodes=reshape(incodes,Ncols,Nrows);
incodes=incodes.';

%% Block 7
step=1;
switch step
    case 1
        % symbol errors
        t=50;
        nw=size(incodes,1);
        noise=(1+randint(nw,n,2^m-1)).*randerr(nw,n,t);
        cnoisy=incodes+noise;
    case 2
        % packet losses
        nw=size(incodes,1);
        t=round(0.03*nw);
        e_packet=zeros(1,n);
        errorpacket=gf(e_packet,m);
        indices=randperm(nw,t);
        cnoisy=incodes;
        for i=1:t
            cnoisy(indices(i),:)=errorpacket;
        end
    otherwise
        cnoisy=incodes;
end

%% Block 8
% decnoisy=cnoisy;
decnoisy=reshape(cnoisy.',[],1);
decnoisy=matdeintrlv(decnoisy,Nrows,Ncols);
decnoisy=reshape(decnoisy,Ncols,Nrows);
decnoisy=decnoisy.';

%% Block 9
[dec_msg,cnumerr,corrcode]=rsdec(decnoisy,n,k);
decodewords=dec_msg.x;

%% Block 10
decodewords=reshape(decodewords.',1,[]);

%% Block 11
quantsig=codebook(decodewords+1);

%% Block 12
quantsig=quantsig(1:length(oneseq));
reseq=reshape(quantsig,[],16);
reseq=reseq.';
F2=zeros(size(F));
for i=1:16
    for j=1:16
        F2((i-1)*16+1:i*16,(j-1)*16+1:j*16)=inversezigzag(reseq(i,(j-1)*128+1:j*128));
    end
end
fun=@(block_struct)idct2(block_struct.data);
reimage=blockproc(F2,[16 16],fun);

%% plot
figure;
subplot(1,2,1);
imshow(image);
title('Original image');
subplot(1,2,2);
imshow(reimage);
title('Reconstructed image');

%% PSNR and MSSIM
Maxx=1;
MSE=sum(sum((image-reimage).^2))/numel(image);
PSNR=10*log10(Maxx^2/MSE)
MSSIM=ssim(reimage,image)