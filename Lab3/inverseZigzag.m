function [ block ] = inverseZigzag( sequence, blocksize, nb_zeros )
% Inverse process of zigzag scanning, output 1D sequence with zeros added
sequence = [sequence,zeros(1,nb_zeros)];
m = 1;
for i = 2:blocksize+1
    if rem(i,2) == 1
        for j = 1:i-1
            block(j,i-j) = sequence(m);
            m = m+1;
        end
    else
        for j = i-1:-1:1
            block(j,i-j) = sequence(m);
            m = m+1;
        end
    end
end

m = 1;
flip_sequence = flip(sequence);
for i = 2:blocksize+1
    if rem(i,2) == 1
        for j = 1:i-1
            flip_block(j,i-j) = flip_sequence(m);
            m = m+1;
        end
    else
        for j = i-1:-1:1
            flip_block(j,i-j) = flip_sequence(m);
            m = m+1;
        end
    end
end
flip_block = rot90(flip_block,2);
flip_block = flip_block.*(ones(blocksize,blocksize)-flip(eye(blocksize)));
block = block + flip_block;
end

