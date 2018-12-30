clear all;
close all;
clc;

ExperimentsIndex = '02';
NodeIndex = '01';

TrNonEyePatchError = load('TrNonEyePatchError.dat');
ValNonEyePatchError = load('ValNonEyePatchError.dat');

nPos = 2800;

PathEyes = 'EyePatchTr';

PathOutPos = ['Experiments'  ExperimentsIndex '\Cascade-LAC\Node' NodeIndex '\Training\PositiveSamples'];

EyePatches = dir([PathEyes '\*.png']);
for i=1:nPos
    FileName = EyePatches(i,1).name;
    Patch = imread([PathEyes '\' FileName],'png');
    imwrite(Patch,[PathOutPos '\' FileName(1:end-4) '.bmp'],'bmp');
end
     
nNeg = 2800;

PathNonEyes = 'NonEyePatchTr';

PathOutNeg = ['Experiments'  ExperimentsIndex '\Cascade-LAC\Node' NodeIndex '\Training\NegativeSamples'];

NonEyePatches = dir([PathNonEyes '\*.png']);
nNonEyes = size(NonEyePatches,1);

Order = randperm(nNonEyes);
nSelectedEyes = 0;
Index = 0;
while nSelectedEyes < nNeg
    Index = Index + 1;
    index = Order(Index);
    if TrNonEyePatchError(index) >= 50
        nSelectedEyes = nSelectedEyes + 1;
        FileName = NonEyePatches(index,1).name;
        Patch = imread([PathNonEyes '\' FileName],'png');
        imwrite(Patch,[PathOutNeg '\' FileName(1:end-4) '.bmp'],'bmp');
    end
end

nPos = 1400;

PathEyes = 'EyePatchVal';

PathOutPos = ['Experiments'  ExperimentsIndex '\Cascade-LAC\Node' NodeIndex '\Validation\PositiveSamples'];

EyePatches = dir([PathEyes '\*.png']);
for i=1:nPos
    FileName = EyePatches(i,1).name;
    Patch = imread([PathEyes '\' FileName],'png');
    imwrite(Patch,[PathOutPos '\' FileName(1:end-4) '.bmp'],'bmp');
end

nNeg = 1400;

PathNonEyes = 'NonEyePatchVal';

PathOutNeg = ['Experiments'  ExperimentsIndex '\Cascade-LAC\Node' NodeIndex '\Validation\NegativeSamples'];

NonEyePatches = dir([PathNonEyes '\*.png']);
nNonEyes = size(NonEyePatches,1);

Order = randperm(nNonEyes);
nSelectedEyes = 0;
Index = 0;
while nSelectedEyes < nNeg
    Index = Index + 1;
    index = Order(Index);
    if ValNonEyePatchError(index) >= 50
        nSelectedEyes = nSelectedEyes + 1;
        FileName = NonEyePatches(index,1).name;
        Patch = imread([PathNonEyes '\' FileName],'png');
        imwrite(Patch,[PathOutNeg '\' FileName(1:end-4) '.bmp'],'bmp');
    end
end