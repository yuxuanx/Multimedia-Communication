function [ sequence ] = zigzag( block, blocksize, savedSamples )
% Zigzag scanning block, output one 1D sequence, with only first
% savedSamples are saved
half_sequence1 = zigzagAssign( block, blocksize );

flip_block = rot90(block,2);
half_sequence2 = zigzagAssign( flip_block, blocksize );
half_sequence2 = half_sequence2(1:end-blocksize);

sequence = [half_sequence1,flip(half_sequence2)];
sequence = sequence(1:savedSamples);
end

function [ halfSequence ] = zigzagAssign( block, blocksize )
m = 1;
for i = 2:blocksize+1
    if rem(i,2) == 1
        for j = 1:i-1
            halfSequence(m) = block(j,i-j);
            m = m+1;
        end
    else
        for j = i-1:-1:1
            halfSequence(m) = block(j,i-j);
            m = m+1;
        end
    end
end
end

