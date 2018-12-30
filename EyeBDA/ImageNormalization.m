function ImgPatchNorm = ImageNormalization(ImgPatch)

[WinY,WinX] = size(ImgPatch);
ImgPatchVec = reshape(ImgPatch,[WinY*WinX 1]);
Mean = mean(ImgPatchVec);
Std = std(ImgPatchVec)*(WinY*WinX-1)/(WinY*WinX);

if Std == 0
    ImgPatchNorm = ( ImgPatch - Mean );
else
    ImgPatchNorm = ( ImgPatch - Mean ) / Std;
end
