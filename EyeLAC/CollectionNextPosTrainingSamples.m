clear all;
close all;
clc;

ExperimentsIndex = '11';
NodeIndex = '08';

nPos = 2800;

FlagTrVal = 1;
if FlagTrVal == 1
    FolderEyes = 'EyePatchTr';
    FolderPathOut = ['Experiments' ExperimentsIndex '\Cascade-LAC\Node' NodeIndex '\Training'];
elseif FlagTrVal == 2
    FolderEyes = 'EyePatchVal';
    FolderPathOut = ['Experiments' ExperimentsIndex '\Cascade-LAC\Node' NodeIndex '\Validation'];
end

ImgEyes = dir([FolderEyes '\*.png']);
nEyesTotal = size(ImgEyes,1);
if str2double(NodeIndex) == 1
    EstClassPre = ones(nEyesTotal,1);
else
    if str2double(NodeIndex) <= 10
        if FlagTrVal == 1
            EstClassPre = load(['Experiments' ExperimentsIndex '\Cascade-LAC\Node0' num2str(str2double(NodeIndex)-1) '\Training\ResultsOfClassifyingTrEyePatchesLAC_Node0' num2str(str2double(NodeIndex)-1) '.dat']);
        elseif FlagTrVal == 2
            EstClassPre = load(['Experiments' ExperimentsIndex '\Cascade-LAC\Node0' num2str(str2double(NodeIndex)-1) '\Validation\ResultsOfClassifyingTrEyePatchesLAC_Node0' num2str(str2double(NodeIndex)-1) '.dat']);
        end
    else
        if FlagTrVal == 1
            EstClassPre = load(['Experiments' ExperimentsIndex '\Cascade-LAC\Node' num2str(str2double(NodeIndex)-1) '\Training\ResultsOfClassifyingTrEyePatchesLAC_Node' num2str(str2double(NodeIndex)-1) '.dat']);
        elseif FlagTrVal == 2
            EstClassPre = load(['Experiments' ExperimentsIndex '\Cascade-LAC\Node' num2str(str2double(NodeIndex)-1) '\Validation\ResultsOfClassifyingTrEyePatchesLAC_Node' num2str(str2double(NodeIndex)-1) '.dat']);
        end
    end
end

Order = randperm(nEyesTotal);
nSelectedEyes = 0;
Index = 0;
while nSelectedEyes < nPos
    Index = Index + 1;
     if EstClassPre(Order(Index)) == 1
        nSelectedEyes = nSelectedEyes + 1;
        if rem(nSelectedEyes,100) == 0
            if FlagTrVal == 1
                display([ num2str(nSelectedEyes) '/' num2str(nPos) '(TrainingPositive)']);
            else
                display([ num2str(nSelectedEyes) '/' num2str(nPos) '(ValidationPositive)']);
            end
        end
        FileName = ImgEyes(Order(Index),1).name;
        ImgMat = imread([FolderEyes '\' FileName],'png');
        imwrite(ImgMat,[FolderPathOut '\PositiveSamples\Pos' num2str(Index) '.bmp'],'bmp');
     end
end

nPos = 1400;

FlagTrVal = 2;
if FlagTrVal == 1
    FolderEyes = 'EyePatchTr';
    FolderPathOut = ['Experiments' ExperimentsIndex '\Cascade-LAC\Node' NodeIndex '\Training'];
elseif FlagTrVal == 2
    FolderEyes = 'EyePatchVal';
    FolderPathOut = ['Experiments' ExperimentsIndex '\Cascade-LAC\Node' NodeIndex '\Validation'];
end

ImgEyes = dir([FolderEyes '\*.png']);
nEyesTotal = size(ImgEyes,1);
if str2double(NodeIndex) == 1
    EstClassPre = ones(nEyesTotal,1);
else
    if str2double(NodeIndex) <= 10
        if FlagTrVal == 1
            EstClassPre = load(['Experiments' ExperimentsIndex '\Cascade-LAC\Node0' num2str(str2double(NodeIndex)-1) '\Training\ResultsOfClassifyingValEyePatchesLAC_Node0' num2str(str2double(NodeIndex)-1) '.dat']);
        elseif FlagTrVal == 2
            EstClassPre = load(['Experiments' ExperimentsIndex '\Cascade-LAC\Node0' num2str(str2double(NodeIndex)-1) '\Validation\ResultsOfClassifyingValEyePatchesLAC_Node0' num2str(str2double(NodeIndex)-1) '.dat']);
        end
    else
        if FlagTrVal == 1
            EstClassPre = load(['Experiments' ExperimentsIndex '\Cascade-LAC\Node' num2str(str2double(NodeIndex)-1) '\Training\ResultsOfClassifyingValEyePatchesLAC_Node' num2str(str2double(NodeIndex)-1) '.dat']);
        elseif FlagTrVal == 2
            EstClassPre = load(['Experiments' ExperimentsIndex '\Cascade-LAC\Node' num2str(str2double(NodeIndex)-1) '\Validation\ResultsOfClassifyingValEyePatchesLAC_Node' num2str(str2double(NodeIndex)-1) '.dat']);
        end
    end
end

Order = randperm(nEyesTotal);
nSelectedEyes = 0;
Index = 0;
while nSelectedEyes < nPos
    Index = Index + 1;
     if EstClassPre(Order(Index)) == 1
        nSelectedEyes = nSelectedEyes + 1;
        if rem(nSelectedEyes,100) == 0
            if FlagTrVal == 1
                display([ num2str(nSelectedEyes) '/' num2str(nPos) '(TrainingPositive)']);
            else
                display([ num2str(nSelectedEyes) '/' num2str(nPos) '(ValidationPositive)']);
            end
        end
        FileName = ImgEyes(Order(Index),1).name;
        ImgMat = imread([FolderEyes '\' FileName],'png');
        imwrite(ImgMat,[FolderPathOut '\PositiveSamples\Pos' num2str(Index) '.bmp'],'bmp');
     end
end