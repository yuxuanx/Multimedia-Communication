function [ blockCompensated ] = motionCompensation( location, blockSize, Iold, MV )
% Assign the values in shifted block in Iold to motion block, for non
% motion block, copy the image values in corresponding blocks in Iold
xlocation = ceil(location(1)/16);
ylocation = ceil(location(2)/16);
dx = MV(xlocation,ylocation,1);
dy = MV(xlocation,ylocation,2);
x = blockSize(1);
y = blockSize(2);
blockCompensated = zeros(x,y);
for i = location(1):location(1)+x-1
    for j = location(2):location(2)+y-1
        blockCompensated(i-location(1)+1,j-location(2)+1) = Iold(i-dx,j-dy);
    end
end

end

