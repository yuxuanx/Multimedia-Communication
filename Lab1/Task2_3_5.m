%clc;clear
%% Parameters
fs = 8e3; % sampling frequency
t = 15; % sound duration
nChannel = 1; % number of channels
nBits = 16; % number of bits

% setting audio recorder object
mySentence = audiorecorder(fs, nBits, nChannel);

%% Step 2.1
pause;
recordblocking(mySentence,  t); % record the sound
%play(myVowel);

audioData = getaudiodata(mySentence);
audiowrite('MySentence.wav', audioData, fs);

% [audio_data, audio_f] = audioread('MySentence.wav');
% pause;
% play(mySentence);

%% Step 2.2
[speechSignal, speech_f] = audioread('MySentence.wav');
nSamples = length(speechSignal); % total number of samples
tBlock = 0.02; % each block with duration 20ms
nBlocks = t/tBlock;

blockLen = tBlock*fs; % number of samples in each block
p = 10; % order of lpc model
a = zeros(p+1, nBlocks);

% for each block, estimate lpc parameters
for i=1:nBlocks
    blockData = speechSignal((i-1)*blockLen + 1:i*blockLen);
    [a(:,i), err] = lpc(blockData, p);
end

%% Step 2.3
e_hat = zeros(nSamples,1);
% for each block, estimate residual sequence and stack
% also remember to use samples from previous block except the first one
blockData = speechSignal(1:blockLen);
e_hat(1:blockLen) = filter(a(:,1), 1, blockData);

for j=2:nBlocks
    blockData = speechSignal((j-1)*blockLen + 1 - p:j*blockLen);
    filterData = filter(a(:,j), 1, blockData);
    % remove the previous data
    e_hat((j-1)*blockLen + 1:j*blockLen) = filterData(p+1:end);
end

timeX = (1:nSamples)/fs;
figure;
plot(timeX,e_hat);title('Residual Sequence');
xlabel('t(s)');ylabel('amplitude');

index = 300;
blockChoosen = (index - 1)*blockLen : (index + 1)*blockLen;

timeX = blockChoosen/fs;
figure;
subplot(2,1,1);
plot(timeX,speechSignal(blockChoosen));
title('Speech Signal Sequence of Two Blocks');xlabel('t(s)');ylabel('amplitude');
subplot(2,1,2);
plot(timeX,e_hat(blockChoosen));
title('Residual Sequence of Two Blocks');xlabel('t(s)');ylabel('amplitude');

%% Step 2.4
s_hat = zeros(nSamples,1);

% first block
s_hat(1:blockLen) = filter(1, a(:,1), e_hat(1:blockLen));

for j=2:nBlocks
    blockResidual = e_hat((j-1)*blockLen + 1 - p:j*blockLen);
    filterResidual = filter(1, a(:,j), blockResidual);
    % remove the previous data
    s_hat((j-1)*blockLen + 1:j*blockLen) = filterResidual(p+1:end);
end

timeX = (1:nSamples)/fs;
figure;
subplot(3,1,1)
plot(timeX,speechSignal);title('Original Speech Signal')
xlabel('t(s)');ylabel('amplitude');
subplot(3,1,2)
plot(timeX,s_hat);title('Re-synthesized Speech Signal');
xlabel('t(s)');ylabel('amplitude');
subplot(3,1,3)
plot(timeX,e_hat);title('Residual Sequence');
xlabel('t(s)');ylabel('amplitude');

% player = audioplayer(s_hat,fs,nBits);
% play(mySentence);
% play(player);
% 
audiowrite('ResynSpeech.wav', s_hat, fs);

%% Step 3.1
K = 25; % 25/10/128 Step 3.3

blockResidual = zeros(blockLen, nBlocks);
for i=1:nBlocks
    blockResidual(:,i) = e_hat((i-1)*blockLen + 1:i*blockLen);
    % find most significant absolute residual
    [~,index] = sort(abs(blockResidual(:,i)),'descend'); 
    % set the remaining values to zero
    blockResidual(index(K+1:end),i) = 0;
end

e_modify = reshape(blockResidual,nSamples,1);

%% Step 3.2
s_hat = zeros(nSamples,1);

% first block
s_hat(1:blockLen) = filter(1, a(:,1), e_modify(1:blockLen));

for j=2:nBlocks
    blockResidual = e_modify((j-1)*blockLen + 1 - p:j*blockLen);
    filterResidual = filter(1, a(:,j), blockResidual);
    % remove the previous data
    s_hat((j-1)*blockLen + 1:j*blockLen) = filterResidual(p+1:end);
end

timeX = (1:nSamples)/fs;
figure;
subplot(2,1,1)
plot(timeX,speechSignal);title('Original Speech Signal')
xlabel('t(s)');ylabel('amplitude');
subplot(2,1,2)
plot(timeX,s_hat);title('Re-synthesized Speech Signal');
xlabel('t(s)');ylabel('amplitude');

% player = audioplayer(s_hat,fs,nBits);
% play(mySentence);
% play(player);
% 
filename = 'ResynSpeech_K_10.wav';
audiowrite(filename, s_hat, fs);

%% Step 5.1

% using the lpc coefficients from Step 2.2
fm = 0:fs/2;
omega = 2*pi*fm/fs;
expo = zeros(fs/2+1,p+1);

% lpc magnitude spectrum for speech signal
A = zeros(fs/2+1,nBlocks);
P = zeros(fs/2+1,nBlocks);

for i=1:nBlocks
    a_l = a(:,i);
    
    for l=0:p
        expo(:,l+1) = a_l(l+1)*exp(-1j*omega*l);
    end
    
    absoluteSum = abs(sum(expo,2));
    A(:,i) = 1./absoluteSum;
    P(:,i) = A(:,i).^2;
end

% lpc magnitude spectrum for synthetic speech signal
% for each block, estimate lpc parameters
a_hat = zeros(p+1, nBlocks);
for i=1:nBlocks
    blockData = s_hat((i-1)*blockLen + 1:i*blockLen);
    [a_hat(:,i), ~] = lpc(blockData, p);
end

A_hat = zeros(fs/2+1,nBlocks);
P_hat = zeros(fs/2+1,nBlocks);

for i=1:nBlocks
    a_l = a_hat(:,i);
    
    for l=0:p
        expo(:,l+1) = a_l(l+1)*exp(-1j*omega*l);
    end
    
    absoluteSum = abs(sum(expo,2));
    A_hat(:,i) = 1./absoluteSum;
    P_hat(:,i) = A_hat(:,i).^2;
end

% choose a block to compare difference
index = 200;
figure;
subplot(2,1,1)
plot(omega,P(:,index));
title('Power Spectral of Original Signal (one block)');
xlabel('\omega');ylabel('power');
subplot(2,1,2)
plot(omega,P_hat(:,index));
title('Power Spectral of synthetic Signal (one block)');
xlabel('\omega');ylabel('power');

%% Step 5.2
d = zeros(nBlocks,1);
M = fs/2;

for i=1:nBlocks
    summ = 10*log10(abs(A(:,i) - A_hat(:,i)).^2);
    d(i) = 1/M*sum(summ);
end

figure;
plot(1:nBlocks,d);title('Average distortion')
xlabel('block number');ylabel('distortion (dB)');

figure;
subplot(3,1,1)
plot(1:nBlocks,d1);title('Average distortion (Entire residual sequence)')
xlabel('block number');ylabel('distortion (dB)');

subplot(3,1,2)
plot(1:nBlocks,d2);title('Average distortion with 128 most significant residual sequence')
xlabel('block number');ylabel('distortion (dB)');

subplot(3,1,3)
plot(1:nBlocks,d3);title('Average distortion with 25 most significant residual sequence')
xlabel('block number');ylabel('distortion (dB)');


