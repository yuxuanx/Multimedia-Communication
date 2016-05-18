clc;clear
img = imread('lena.bmp');
if length(size(img)) == 3
    img = rgb2gray(img);
end
img = mat2gray(img); % Convert format to intensity image
figure
imagesc(img)
colormap gray

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
[n_w,~] = size(codewords);

inCodewords = gf(codewords,m); 

t = 64;
noise = randi(n,n_w,n).*randerr(n_w,n,t); % t errors per row
cnoisy = noise+inCodewords;

% e_packet = zeros(1,n_w); % Generate a codeword with zero values
% errorpacket = gf(e_packet,m); % Generate an error packet in class gf
% % Replace the random chosen (1/50) codeword by a packet with zero values
% nb = floor(n_w/50); 
% cnoisy(randsample(1:n_w,nb),:) = repmat(errorpacket,nb,1);

noisePacket = cnoisy.x;

deCode = gf(noisePacket,m); 

dec_msg = rsdec(deCode,n,k);
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