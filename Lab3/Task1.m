% Scalar quantization
clc;clear
%% Step 1.1
% Generate a synthetic signal
t = 0:.1:10*pi; % Times at which to sample the sine function
signal = sin(t); % Original signal, a sine wave
figure
plot(t,signal);xlabel('t');ylabel('Amplitude');title('Original signal');

%% Step 1.2
% Scalar quantization
partition = -1:1/127:1; % Length 255, to represent 8 bits (256) intervals
codebook = (-1-1/127):1/127:1; % Length 256, one entry for each interval
[index,quants] = quantiz(signal,partition,codebook); % Quantize
figure
plot(t,signal,t,quants,'x')
legend('Original signal','Quantized signal');
xlabel('t');ylabel('Amplitude')

%% Step 1.3
% Convert quantization indices to quantized values
qSignal = codebook(index+1); % Quantized values of the signal

%% Step 1.4
% Verification
figure
plot(t,signal,t,qSignal,'x')
legend('Original signal','Quantized signal');
xlabel('t');ylabel('Amplitude')



