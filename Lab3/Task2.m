% Packetization and depacketization
clc;clear
load('signaIndices.mat')
%% Step 2.1
% Packetization
k = 127; % Size of packets (127 symbols per)
len = length(index); 
z = k - rem(len,k); % Number of zeros added to make an entire packet
indices = [index,zeros(1,z)];
packets = reshape(indices,length(indices)/k,k);

%% Step 2.2
% Depacketization
dePackets = reshape(packets,1,numel(packets));
symbols = dePackets(1:len);

%% Step 2.3
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
dePackets = reshape(packets,1,numel(packets));
symbols = dePackets(1:len);
qSignal = codebook(symbols+1);
figure
plot(t,signal,t,qSignal,'x')
legend('Original signal','Quantized signal');
xlabel('t');ylabel('Amplitude')
