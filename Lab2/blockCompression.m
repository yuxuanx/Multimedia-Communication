function [ blockCompre ] = blockCompression( blockData )
% Implement compression for each block
[x,y] = size(blockData);
reshape_F = reshape(blockData,x*y,1);
[~,I] = sort(reshape_F); 
th = I(round(0.9*x*y)); % Set threshold position

blockCompre = blockData;
% For value below threshold, replace with 0
blockCompre(abs(blockCompre)<reshape_F(th)) = 0; 


end

