% Adding matrix interleaver and deinterleaver
clc;clear
load('rs_codes')
%% Step 7.1
% Interleaving
n = 2^8 - 1;
[nw,~] = size(codes);
codewords = codes.x;

int_codewords = matintrlv(codewords',1,n);

%% Step 7.2
% De-interleaving
deint_codewords = matdeintrlv(int_codewords,1,n);

%% Step 7.3
% Verification