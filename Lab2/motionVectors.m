function [ MV ] = motionVectors( block, Nx, Ny, Iold, location )
% Compute motion vectors in current block
[Mx,My] = size(block);
maes = zeros(Nx-Mx+1,Ny-My+1);
if (~isempty((find(block)~=0)))
    for xidx = 1:Nx-Mx+1
        for yjdy = 1:Ny-My+1
            Iold_motion = Iold(xidx:xidx+Mx-1,yjdy:yjdy+My-1);
            absoluteValue = abs(block-Iold_motion);
            maes(xidx,yjdy) = sum(absoluteValue(:))/Mx/My;
        end
    end
    [row,column] = find(maes == min(maes(:)));
    dx = location(1) - row;
    dy = location(2) - column;
    MV = [dx,dy];
else
    MV = [0,0];
end
end

