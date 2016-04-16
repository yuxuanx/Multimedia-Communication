clc;clear
%% Parameters
fs = 8e3; % sampling frequency
t = 10; % sound duration
nChannel = 1; % number of channels
nBits = 8; % number of bits

% setting audio recorder object
myVowel = audiorecorder(fs, nBits, nChannel);

%% Step 1.1
pause;
recordblocking(myVowel, t); % record the sound
%play(myVowel);

audioData = getaudiodata(myVowel);
audiowrite('MyVowel.wav', audioData, fs);

[audio_data, audio_f] = audioread('MyVowel.wav');
pause;
%play(myVowel);

timeX = (1:length(audio_data))/audio_f;
figure;
plot(timeX, audio_data);
xlabel('t(s)');ylabel('amplitude');
title('Sound Waveform');

%% Step 1.2
p = 10; % order of LPC model
blockDuration = 0.3; % 300ms

L = fs*blockDuration; % number of samples per block
index = 10; % index of the choosing block
blockData = audio_data((index-1)*L+1:index*L);

[a_hat, errVar] = lpc(blockData, p); % lpc estimation

%% Step 1.3
b = 1; 
% through inverse filter to obtain residual sequence
e_hat = filter(a_hat, b, blockData);
figure;
timeX = (1:length(blockData))/audio_f;
plot(timeX, blockData);hold on
plot(timeX, e_hat);
xlabel('t(s)');ylabel('amplitude');
title('Sound Waveform of Speech Signal and Residual Sequence');

%% Step 1.4
% re-synthesize the speech
s_hat = filter(b, a_hat, e_hat);
audiowrite('Resynthesize.wav', s_hat, fs);

figure;
plot(timeX, blockData,'.');hold on
plot(timeX, s_hat);
xlabel('t(s)');ylabel('amplitude');
title('Sound Waveform of Original and Resynthesize Speech Signal');

