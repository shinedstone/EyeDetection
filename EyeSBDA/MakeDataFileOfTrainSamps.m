clear all;
close all;
clc;

WinX = 18;
WinY = 18;

ExperimentsIndex = '04';
NodeIndex = '08';

FolderPath = ['Experiments' ExperimentsIndex '\Cascade-LAC\Node' NodeIndex '\Training'];
Fid = fopen([FolderPath '\TrainSamplesIN_Node' NodeIndex '.dat'],'w');

ImgPos = dir([FolderPath '\PositiveSamples\*.bmp']);
nPos = size(ImgPos,1);
for k=1:nPos
    if rem(k,100) == 0
        display(['TrPositive - ' num2str(k)]);
    end
    FileName = ImgPos(k,1).name;
    ImgPatch = imread([FolderPath '\PositiveSamples\' FileName],'bmp');
    ImgPatchNorm = ImageNormalization(double(ImgPatch));
    ImgPatchNorm = IntgImg(double(ImgPatchNorm),1);
    ImgVec = reshape(ImgPatchNorm',[1,WinY*WinX]);
    for i=1:WinY*WinX
        fprintf(Fid,'%f ',ImgVec(i));
    end
    fprintf(Fid,'%d\n',1);
end
    
ImgNeg = dir([FolderPath '\NegativeSamples\*.bmp']);
nNeg = size(ImgNeg,1);
for k=1:nNeg
    if rem(k,100) == 0
        display(['TrNegative - ' num2str(k)]);
    end
    FileName = ImgNeg(k,1).name;
    ImgPatch = imread([FolderPath '\NegativeSamples\' FileName],'bmp');
    ImgPatchNorm = ImageNormalization(double(ImgPatch));
    ImgPatchNorm = IntgImg(double(ImgPatchNorm),1);
    ImgVec = reshape(ImgPatchNorm',[1,WinY*WinX]);
    for i=1:WinY*WinX
        fprintf(Fid,'%f ',ImgVec(i));
    end
    fprintf(Fid,'%d\n',0);
end
fclose(Fid);

FolderPath = ['Experiments' ExperimentsIndex '\Cascade-LAC\Node' NodeIndex '\Validation'];
Fid = fopen([FolderPath '\TestSamplesIN_Node' NodeIndex '.dat'],'w');

ImgPos = dir([FolderPath '\PositiveSamples\*.bmp']);
nPos = size(ImgPos,1);
for k=1:nPos
    if rem(k,100) == 0
        display(['ValPositive - ' num2str(k)]);
    end
    FileName = ImgPos(k,1).name;
    ImgPatch = imread([FolderPath '\PositiveSamples\' FileName],'bmp');
    ImgPatchNorm = ImageNormalization(double(ImgPatch));
    ImgPatchNorm = IntgImg(double(ImgPatchNorm),1);
    ImgVec = reshape(ImgPatchNorm',[1,WinY*WinX]);
    for i=1:WinY*WinX
        fprintf(Fid,'%f ',ImgVec(i));
    end
    fprintf(Fid,'%d\n',1);
end
    
ImgNeg = dir([FolderPath '\NegativeSamples\*.bmp']);
nNeg = size(ImgNeg,1);
for k=1:nNeg
    if rem(k,100) == 0
        display(['ValNegative - ' num2str(k)]);
    end
    FileName = ImgNeg(k,1).name;
    ImgPatch = imread([FolderPath '\NegativeSamples\' FileName],'bmp');
    ImgPatchNorm = ImageNormalization(double(ImgPatch));
    ImgPatchNorm = IntgImg(double(ImgPatchNorm),1);
    ImgVec = reshape(ImgPatchNorm',[1,WinY*WinX]);
    for i=1:WinY*WinX
        fprintf(Fid,'%f ',ImgVec(i));
    end
    fprintf(Fid,'%d\n',0);
end
fclose(Fid);