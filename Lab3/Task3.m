% Reed-Solomon (RS) encoding and decoding
clc;clear
load('packets')
%% Step 3.1
% RS encoding
m = 8; % Bits per symbol
n = 2^m - 1; % Codeword length
k = 127;
msgwords = gf(packets,m); % Represent data by Galois array
codes = rsenc(msgwords,n,k); % Perform RS encoder
codewords = codes.x; % Extract rows of codewords from GF array

%% Step 3.2
% RS decoding
dec_msg = rsdec(codes,n,k);
isequal(dec_msg,msgwords)

%% Step 3.3
% Verification
t = 0:.1:10*pi;
signal = sin(t);
partition = -1:1/127:1;
codebook = (-1-1/127):1/127:1;
[index,quants] = quantiz(signal,partition,codebook);

k = 127; 
len = length(index); 
z = k - rem(len,k); 
indices = [index,zeros(1,z)];
packets = reshape(indices,length(indices)/k,k);

m = 8; 
n = 2^m - 1; 
msgwords = gf(packets,m); 
codes = rsenc(msgwords,n,k);
codewords = codes.x;
dec_msg = rsdec(codes,n,k);
packets = dec_msg.x;

dePackets = reshape(packets,1,numel(packets));
symbols = dePackets(1:len);
qSignal = codebook(symbols+1);
figure
plot(t,signal,t,qSignal,'x')
legend('Original signal','Quantized signal');
xlabel('t');ylabel('Amplitude')
