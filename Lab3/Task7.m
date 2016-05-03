% Adding matrix interleaver and deinterleaver
clc;clear
load('rs_codes')
%% Step 7.1
% Interleaving
% Note that this process repeats for every n codewords
% To plug in the code in the system, minor changes are required
n = 2^8 - 1;
[nw,~] = size(codes);
codewords = codes.x;
nb_zeros = n-rem(nw,n);
% Add zero codewords, if the number of codewords is not divisible by n
codewords = [codewords;zeros(nb_zeros,n)]; 
int_codewords = codewords';

%% Step 7.2
% De-interleaving
deint_codewords = int_codewords';

%% Step 7.3
% Verification
