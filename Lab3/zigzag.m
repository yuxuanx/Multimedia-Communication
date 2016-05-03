function [ sequence ] = zigzag( block, blocksize, savedSamples )
% Zigzag scanning block, output one 1D sequence, with only first
% savedSamples are saved
m = 1;
for i = 2:blocksize+1
    if rem(i,2) == 1
        for j = 1:i-1
            half_sequence1(m) = block(j,i-j);
            m = m+1;
        end
    else
        for j = i-1:-1:1
            half_sequence1(m) = block(j,i-j);
            m = m+1;
        end
    end
end

m = 1;
flip_block = rot90(block,2);
for i = 2:blocksize+1
    if rem(i,2) == 1
        for j = 1:i-1
            half_sequence2(m) = flip_block(j,i-j);
            m = m+1;
        end
    else
        for j = i-1:-1:1
            half_sequence2(m) = flip_block(j,i-j);
            m = m+1;
        end
    end
end
half_sequence2 = half_sequence2(1:end-blocksize);
sequence = [half_sequence1,flip(half_sequence2)];
sequence = sequence(1:savedSamples);
end

