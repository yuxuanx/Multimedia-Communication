% Image compression by block-based 2D DCT, zigzag to 1D source symbol
% sequence and its reverse process
clc;clear
%% Step 4.1
% Load a 2D image
img = imread('lena.bmp');
if length(size(img)) == 3
    img = rgb2gray(img);
end
img = mat2gray(img); % Convert format to intensity image
figure
imagesc(img)
colormap gray

%% Step 4.2
% Set a compression ratio
r = 0.5; % Compression ratio
N = 16^2; % Block size
N1 = round(r*N); % Number of coefficients removed

%% Step 4.3.1
% Block-based 2D DCTs
fun = @(block_struct) dct2(block_struct.data);
dcts = blockproc(img, [16 16], fun);

%% Step 4.3.2
% Zigzag scanning DCT coefficients
Nc = N - N1;
fun = @(block_struct) zigzag(block_struct.data, 16, Nc);
zigzagScan = blockproc(dcts, [16 16], fun);
scannedSequence = reshape(zigzagScan,1,numel(zigzagScan));

%% Step 4.4.1
% Inverse process of zigzag scanning DCT
sequences = reshape(scannedSequence,16,length(scannedSequence)/16);
fun = @(block_struct) inverseZigzag(block_struct.data, 16, N1);
dctBlocks = blockproc(sequences, [1 128], fun);

%% Step 4.4.2
% Block-based inverse 2D DCTs
fun = @(block_struct) idct2(block_struct.data);
reImg = blockproc(dctBlocks, [16 16], fun); % Reconstructed image

%% Step 4.5
% Verification
r = 0.5;
N = 16^2;
N1 = round(r*N);
fun = @(block_struct) dct2(block_struct.data);
dcts = blockproc(img, [16 16], fun);

Nc = N - N1;
fun = @(block_struct) zigzag(block_struct.data, 16, Nc);
zigzagScan = blockproc(dcts, [16 16], fun);
scannedSequence = reshape(zigzagScan,1,numel(zigzagScan));

ma = max(scannedSequence);
mi = min(scannedSequence);

partition = (mi-(ma-mi)/253):(ma-mi)/253:ma;
codebook = (mi-(ma-mi)/253):(ma-mi)/253:(ma+(ma-mi)/253);
[index,quants] = quantiz(scannedSequence,partition,codebook);

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

sequences = reshape(qSignal,16,length(qSignal)/16);
fun = @(block_struct) inverseZigzag(block_struct.data, 16, N1);
dctBlocks = blockproc(sequences, [1 128], fun);

fun = @(block_struct) idct2(block_struct.data);
reImg = blockproc(dctBlocks, [16 16], fun);
figure
imshow(reImg)