% Noise: bit errors and packet losses
% Using switch to choose case 1 or case 2
clc;clear
load('packets')
%% Step 5.1
% Case 1: bit errors in the channel
t = 60; % Number of errors
m = 8; % Bits per symbol
n = 2^m - 1; % Codeword length
k = 127;
msgwords = gf(packets,m); % Represent data by Galois array
codes = rsenc(msgwords,n,k); % Perform RS encoder
[nw,~] = size(codes);
noise = (1+randi(nw,nw,n)).*randerr(nw,n,t); % t errors per row
cnoisy = codes + noise; % Add noise to the code
% RS decoding
[dc, nerrs, corrcode] = rsdec(cnoisy,n,k);

%% Step 5.2
% Case 2: network packet loss
e_packet = zeros(1,n); % Generate a codeword with zero values
errorpacket = gf(e_packet,m); % Generate an error packet in class gf
% Replace the random chosen 10% codeword by a packet with zero values
nb = floor(nw/10);
codes(randsample(1:nw,nb),:) = errorpacket; 



