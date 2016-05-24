clc;clear

% Divide the speech sentence into blocks with each of 20ms duration.
tBlock=20e-3;   
[s,fs]=audioread('Mysentence.wav');
L=tBlock*fs;

TotalBlocks=20;

ceptrum=zeros(11*L,TotalBlocks);
for i=50:TotalBlocks+49
    %% step 4.1.1
    x=s((i-1)*L+1:i*L);
    x=x.*hamming(L); % reduce Gibbs effect by using blocks

    %% step 4.1.2
    y=[x; zeros(10*L,1)]; % make it linear convolution by padding zeros

    %% step 4.1.3
    n = length(y);
    odd = fix(rem(n,2));
    wn = [1; 2*ones((n+odd)/2-1,1) ; ones(1-rem(n,2),1); zeros((n+odd)/2-1,1)];
    y = y.*wn;
    S=fft(y);
    C=log(abs(S));
    ceptrum(:,i)=abs(ifft(C));
    
end

%% step 4.1.5
figure;
const=1;
t=tBlock*linspace(0,1-1/(L),L);
for i=50:TotalBlocks+49
    cBlock=ceptrum(:,i)+i*const;
    plot(cBlock);
    hold on;
end
title('Cepstra for 30 Blocks');
xlabel('samples(n)');
ylabel('c_s(n)');