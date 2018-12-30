clear all;
close all;
clc;

WinX = 18;
WinY = 18;

FolderPath = 'EyePatchTr';
Fid = fopen('TrainingEyeSamples.dat','w');

ImgPos = dir([FolderPath '\*.png']);
nPos = size(ImgPos,1);
for k=1:nPos
    if rem(k,100) == 0
        display(['TrPositive - ' num2str(k)]);
    end
    FileName = ImgPos(k,1).name;
    ImgPatch = imread([FolderPath '\' FileName],'png');
    ImgPatchNorm = ImageNormalization(double(ImgPatch));
    ImgPatchNorm = IntgImg(double(ImgPatchNorm),1);
    ImgVec = reshape(ImgPatchNorm',[1,WinY*WinX]);
    for i=1:WinY*WinX
        fprintf(Fid,'%f ',ImgVec(i));
    end
    fprintf(Fid,'%d\n',1);
end

FolderPath = 'EyePatchVal';
Fid = fopen('ValidationEyeSamples.dat','w');

ImgPos = dir([FolderPath '\*.png']);
nPos = size(ImgPos,1);
for k=1:nPos
    if rem(k,100) == 0
        display(['ValPositive - ' num2str(k)]);
    end
    FileName = ImgPos(k,1).name;
    ImgPatch = imread([FolderPath '\' FileName],'png');
    ImgPatchNorm = ImageNormalization(double(ImgPatch));
    ImgPatchNorm = IntgImg(double(ImgPatchNorm),1);
    ImgVec = reshape(ImgPatchNorm',[1,WinY*WinX]);
    for i=1:WinY*WinX
        fprintf(Fid,'%f ',ImgVec(i));
    end
    fprintf(Fid,'%d\n',1);
end
    