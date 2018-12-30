function MCTMat = MCT(ImgMat)
[Height,Width] = size(ImgMat);
MCTMat = zeros(Height-2,Width-2);
for i=1:Height-2
    for j=1:Width-2
        y=i+1; x=j+1;
        NeighborMat = ImgMat(y-1:y+1,x-1:x+1);
        OrderedVec = reshape(NeighborMat,1,9);
        Target = mean(OrderedVec);
        BinaryIndex = OrderedVec>Target;
        KernelIndex = 0;
        for p=1:length(BinaryIndex)
            KernelIndex = KernelIndex + BinaryIndex(p)*2^(length(BinaryIndex)-p);
        end
        MCTMat(i,j) = KernelIndex;
    end
end