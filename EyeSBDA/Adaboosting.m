clear all;
close all;
clc;

ExperimentsIndex = '04';
NodeIndex = '07';

WinSize = 18;

FlagTrVal = 1;
if str2double(NodeIndex) < 9
    if FlagTrVal == 1
        FolderPath = ['Experiments' ExperimentsIndex '\Cascade-LAC\Node' NodeIndex '\Training\NegativeSamples'];
        OutFolderPath = ['Experiments' ExperimentsIndex '\Cascade-LAC\Node0' num2str(str2double(NodeIndex)+1) '\Training\NegativeSamples'];
    elseif FlagTrVal == 2
        FolderPath = ['Experiments' ExperimentsIndex '\Cascade-LAC\Node' NodeIndex '\Validation\NegativeSamples'];
        OutFolderPath = ['Experiments' ExperimentsIndex '\Cascade-LAC\Node0' num2str(str2double(NodeIndex)+1) '\Validation\NegativeSamples'];
    end
elseif str2double(NodeIndex) >= 9
    if FlagTrVal == 1
        FolderPath = ['Experiments' ExperimentsIndex '\Cascade-LAC\Node' NodeIndex '\Training\NegativeSamples'];
        OutFolderPath = ['Experiments' ExperimentsIndex '\Cascade-LAC\Node' num2str(str2double(NodeIndex)+1) '\Training\NegativeSamples'];
    elseif FlagTrVal == 2
        FolderPath = ['Experiments' ExperimentsIndex '\Cascade-LAC\Node' NodeIndex '\Validation\NegativeSamples'];
        OutFolderPath = ['Experiments' ExperimentsIndex '\Cascade-LAC\Node' num2str(str2double(NodeIndex)+1) '\Validation\NegativeSamples'];
    end
end

ImgNonEyes = dir([FolderPath '\*.bmp']);
nNonEyes = size(ImgNonEyes,1);

FidClassifier = fopen(['Experiments' ExperimentsIndex '\ResultsOfSBDATrainingAllNode.dat'],'r');
StrTemp = fgetl(FidClassifier);
Flag = 0;
while Flag == 0 && ischar(StrTemp) == 1
    StrTemp = fgetl(FidClassifier);
    NumTemp = str2num(StrTemp);
    if NumTemp(1) == str2double(NodeIndex)
        Flag = 1;
    end
end
fclose(FidClassifier);
nHaarFeats = NumTemp(2);
nSBDA = NumTemp(3);
EnTheta = NumTemp(end);

FolderPathHaarFeats = ['Experiments' ExperimentsIndex '\Cascade-LAC\Node' NodeIndex '\Training'];
Weights = load([FolderPathHaarFeats '\ResultsOfSBDA_WeightsOfHaarFeatsByFFS_alpha1_Node' NodeIndex '.dat']);
MeanPos = load([FolderPathHaarFeats '\ResultsOfSBDA_MeanPosSampsOfHaarFeatsByFFS_alpha1_Node' NodeIndex '.dat']);
ThresholdsOfHaarFeats = load([FolderPathHaarFeats '\ThresholdsOfHaarFeatsSelectedByFFS_Node' NodeIndex '.dat']);

HaarFeatByFFS = zeros(nHaarFeats,6);
FidHaarFeats = fopen([FolderPathHaarFeats '\HaarFeatsSelectedByFFS_Node' NodeIndex '.dat'] ,'r');
StrTemp = fgetl(FidHaarFeats);
for k=1:nHaarFeats
    StrTemp = fgetl(FidHaarFeats);
    NumsTemp = str2num(StrTemp);
    HaarFeatByFFS(k,:) = NumsTemp;
end
fclose(FidHaarFeats);

OutPutHaarFeats = zeros(1,nHaarFeats);
num = 0;
for k=1:nNonEyes
    FileName = ImgNonEyes(k,1).name;
    ImgPatch = imread([FolderPath '\' FileName],'bmp');
    ImgPatchNorm = ImageNormalization(double(ImgPatch));
    ImgPatchNorm = IntgImg(double(ImgPatchNorm),1);
    for j=1:nHaarFeats
        FeatType = HaarFeatByFFS(j,1);
        SizeY = HaarFeatByFFS(j,2);
        SizeX = HaarFeatByFFS(j,3);
        StartY = HaarFeatByFFS(j,4);
        StartX = HaarFeatByFFS(j,5);
        Polarity = HaarFeatByFFS(j,6);
        Theta = ThresholdsOfHaarFeats(j);
        OutSumPix = HaarLikeFeat(FeatType,SizeY,SizeX,StartY,StartX,ImgPatchNorm);
        if Polarity*OutSumPix >= Polarity*Theta
            OutPutHaarFeats(j) = 1;
        else
            OutPutHaarFeats(j) = 0;
        end
    end
    
    TrainProj = OutPutHaarFeats * Weights;
    MeanPosProj = MeanPos * Weights;
    DistFromPosMean = sqrt( (TrainProj(1:nSBDA)-MeanPosProj(1:nSBDA)) * (TrainProj(1:nSBDA)-MeanPosProj(1:nSBDA))' );
    if DistFromPosMean <= EnTheta
        num = num + 1;
        imwrite(uint8(ImgPatch),[OutFolderPath '\Neg' num2str(num) '.bmp'],'bmp');
    end
end

FlagTrVal = 2;
if str2double(NodeIndex) < 9
    if FlagTrVal == 1
        FolderPath = ['Experiments' ExperimentsIndex '\Cascade-LAC\Node' NodeIndex '\Training\NegativeSamples'];
        OutFolderPath = ['Experiments' ExperimentsIndex '\Cascade-LAC\Node0' num2str(str2double(NodeIndex)+1) '\Training\NegativeSamples'];
    elseif FlagTrVal == 2
        FolderPath = ['Experiments' ExperimentsIndex '\Cascade-LAC\Node' NodeIndex '\Validation\NegativeSamples'];
        OutFolderPath = ['Experiments' ExperimentsIndex '\Cascade-LAC\Node0' num2str(str2double(NodeIndex)+1) '\Validation\NegativeSamples'];
    end
elseif str2double(NodeIndex) >= 9
    if FlagTrVal == 1
        FolderPath = ['Experiments' ExperimentsIndex '\Cascade-LAC\Node' NodeIndex '\Training\NegativeSamples'];
        OutFolderPath = ['Experiments' ExperimentsIndex '\Cascade-LAC\Node' num2str(str2double(NodeIndex)+1) '\Training\NegativeSamples'];
    elseif FlagTrVal == 2
        FolderPath = ['Experiments' ExperimentsIndex '\Cascade-LAC\Node' NodeIndex '\Validation\NegativeSamples'];
        OutFolderPath = ['Experiments' ExperimentsIndex '\Cascade-LAC\Node' num2str(str2double(NodeIndex)+1) '\Validation\NegativeSamples'];
    end
end

ImgNonEyes = dir([FolderPath '\*.bmp']);
nNonEyes = size(ImgNonEyes,1);

num = 0;
for k=1:nNonEyes
    FileName = ImgNonEyes(k,1).name;
    ImgPatch = imread([FolderPath '\' FileName],'bmp');
    ImgPatchNorm = ImageNormalization(double(ImgPatch));
    ImgPatchNorm = IntgImg(double(ImgPatchNorm),1);
    for j=1:nHaarFeats
        FeatType = HaarFeatByFFS(j,1);
        SizeY = HaarFeatByFFS(j,2);
        SizeX = HaarFeatByFFS(j,3);
        StartY = HaarFeatByFFS(j,4);
        StartX = HaarFeatByFFS(j,5);
        Polarity = HaarFeatByFFS(j,6);
        Theta = ThresholdsOfHaarFeats(j);
        OutSumPix = HaarLikeFeat(FeatType,SizeY,SizeX,StartY,StartX,ImgPatchNorm);
        if Polarity*OutSumPix >= Polarity*Theta
            OutPutHaarFeats(j) = 1;
        else
            OutPutHaarFeats(j) = 0;
        end
    end
    
    TrainProj = OutPutHaarFeats * Weights;
    MeanPosProj = MeanPos * Weights;
    DistFromPosMean = sqrt( (TrainProj(1:nSBDA)-MeanPosProj(1:nSBDA)) * (TrainProj(1:nSBDA)-MeanPosProj(1:nSBDA))' );
    if DistFromPosMean <= EnTheta
        num = num + 1;
        imwrite(uint8(ImgPatch),[OutFolderPath '\Neg' num2str(num) '.bmp'],'bmp');
    end
end