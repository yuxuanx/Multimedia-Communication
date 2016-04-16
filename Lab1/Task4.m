clc;clear

% Divide the speech sentence into blocks with each of 20ms duration.
tBlock=20e-3;   
[s,fs]=audioread('bird.wav');
L=tBlock*fs;

TotalBlocks=30;

ceptrum=zeros(L,TotalBlocks);
for i=1:TotalBlocks
    %% step 4.1.1
    x=s((i-1)*L+1:i*L);
    x=x.*hamming(L); % reduce Gibbs effect by using blocks

    %% step 4.1.2
    y=[x; zeros(10*L,1)]; % make it linear convolution by padding zeros

    %% step 4.1.3
    % NFFT=2^nextpow2(11*L);
    S=fft(y);
    C=log(abs(S));
    ceptrum(:,i)=abs(ifft(C,L));
end

%% step 4.1.5
figure;
const=0.5;
t=tBlock*linspace(0,1-1/L,L);
for i=1:TotalBlocks
    cBlock=ceptrum(:,i)+i*const;
    plot(t,cBlock);
    hold on;
end
title('Cepstra for 30 Blocks');
xlabel('T/s');
ylabel('c_s(n)');