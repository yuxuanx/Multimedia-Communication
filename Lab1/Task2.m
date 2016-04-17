clc;clear
%% Parameters
fs = 8e3; % sampling frequency
t = 15; % sound duration
nChannel = 1; % number of channels
nBits = 8; % number of bits

% setting audio recorder object
mySentence = audiorecorder(fs, nBits, nChannel);

%% Step 2.1
pause;
recordblocking(mySentence, t); % record the sound
%play(myVowel);

audioData = getaudiodata(mySentence);
audiowrite('MySentence.wav', audioData, fs);

% [audio_data, audio_f] = audioread('MySentence.wav');
% pause;
play(mySentence);

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
    [a(:,i), ~] = lpc(blockData, p);
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
    e_hat((j-1)*blockLen + 1:j*blockLen) = filter(a(:,j), 1, filterData(p+1:end));
end

figure;
plot(1:nSamples,e_hat);title('Residual Sequence');
xlabel('n');ylabel('amplitude');

index = 100;
blockChoosen = (index - 1)*blockLen : (index + 1)*blockLen;

figure;
subplot(2,1,1);
plot(blockChoosen,speechSignal(blockChoosen));
title('Speech Signal Sequence');xlabel('n');ylabel('amplitude');
subplot(2,1,2);
plot(blockChoosen,e_hat(blockChoosen));
title('Residual Sequence');xlabel('n');ylabel('amplitude');

%% Step 2.4
s_hat = zeros(nSamples,1);

% first block
s_hat(1:blockLen) = filter(1, a(:,1), e_hat(1:blockLen));

for j=2:nBlocks
    blockResidual = e_hat((j-1)*blockLen + 1 - p:j*blockLen);
    filterResidual = filter(1, a(:,j), blockResidual);
    % remove the previous data
    s_hat((j-1)*blockLen + 1:j*blockLen) = filter(1, a(:,j), filterResidual(p+1:end));
end

figure;
subplot(3,1,1)
plot(1:nSamples,speechSignal);title('Original Speech Signal')
xlabel('n');ylabel('amplitude');
subplot(3,1,2)
plot(1:nSamples,s_hat);title('Re-synthesized Speech Signal');
xlabel('n');ylabel('amplitude');
subplot(3,1,3)
plot(1:nSamples,e_hat);title('Residual Sequence');
xlabel('n');ylabel('amplitude');

player = audioplayer(s_hat,fs,nBits);
play(mySentence);
play(player);

audiowrite('ResynSpeech.wav', s_hat, fs);


