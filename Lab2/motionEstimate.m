function [ blockEstimate ] = motionEstimate( block )
% Estimate motion vectors for motion blocks using MAE criterion
if (~isempty(find(block)~=0))
    blockEstimate = ones(size(block));
else
    blockEstimate = zeros(size(block));
end

