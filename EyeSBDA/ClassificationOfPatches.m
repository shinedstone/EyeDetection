clear all;
close all;
clc;

ExperimentsIndex = '04';
NodeIndex = '08';

WinSize = 18;

FlagTrVal = 1;
if FlagTrVal == 1
    FolderPath = ['Experiments' ExperimentsIndex '\Cascade-LAC\Node' NodeIndex '\Training'];
    FolderPathEyes = 'EyePatchTr';
    FolderPathNonEyes = 'NonEyePatchTr';
elseif FlagTrVal == 2
    FolderPath = ['Experiments' ExperimentsIndex '\Cascade-LAC\Node' NodeIndex '\Training'];
    FolderPathEyes = 'EyePatchVal';
    FolderPathNonEyes = 'NonEyePatchVal';
end

nEyes = 25200;

if str2double(NodeIndex) == 1
    EstClassPre = ones(nEyes,1);
else
    if str2double(NodeIndex) <= 10
        if FlagTrVal == 1
            EstClassPre = load(['Experiments' ExperimentsIndex '\Cascade-LAC\Node0' num2str(str2double(NodeIndex)-1) '\Training\ResultsOfClassifyingTrEyePatchesSBDA_Node0' num2str(str2double(NodeIndex)-1) '.dat']);
        elseif FlagTrVal == 2
            EstClassPre = load(['Experiments' ExperimentsIndex '\Cascade-LAC\Node0' num2str(str2double(NodeIndex)-1) '\Validation\ResultsOfClassifyingValEyePatchesSBDA_Node0' num2str(str2double(NodeIndex)-1) '.dat']);
        end
    else
        if FlagTrVal == 1
            EstClassPre = load(['Experiments' ExperimentsIndex '\Cascade-LAC\Node' num2str(str2double(NodeIndex)-1) '\Training\ResultsOfClassifyingTrEyePatchesSBDA_Node' num2str(str2double(NodeIndex)-1) '.dat']);
        elseif FlagTrVal == 2
            EstClassPre = load(['Experiments' ExperimentsIndex '\Cascade-LAC\Node' num2str(str2double(NodeIndex)-1) '\Validation\ResultsOfClassifyingValEyePatchesSBDA_Node' num2str(str2double(NodeIndex)-1) '.dat']);
        end
    end
end

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

OutPutHaarFeats = zeros(nEyes,nHaarFeats);
FidSamples = fopen('TrainingEyeSamples.dat','r');
for k=1:nEyes
    StrTemp = fgetl(FidSamples);
    if EstClassPre(k) == 1
        ImgPatchNorm = str2num(StrTemp);
        ImgPatchNorm = reshape(ImgPatchNorm(1:end-1)', [WinSize, WinSize] );
        ImgPatchNorm = ImgPatchNorm';
        
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
                OutPutHaarFeats(k,j) = 1;
            else
                OutPutHaarFeats(k,j) = 0;
            end
        end
    end
end
fclose(FidSamples);

FidResults = fopen([FolderPath '\ResultsOfClassifyingTrEyePatchesSBDA_Node' NodeIndex '.dat'],'w');
nEyesPassed = 0;
DistFromPosMean = zeros(nEyes,1);
for i=1:nEyes
    if EstClassPre(i) == 1
        TrainProj = OutPutHaarFeats(i,:) * Weights;
        MeanPosProj = MeanPos * Weights;
        DistFromPosMean(i) = sqrt( (TrainProj(1:nSBDA)-MeanPosProj(1:nSBDA)) * (TrainProj(1:nSBDA)-MeanPosProj(1:nSBDA))' );
        if DistFromPosMean(i) <= EnTheta
            fprintf(FidResults,'%d\n',1);
            nEyesPassed = nEyesPassed + 1;
        else
            fprintf(FidResults,'%d\n',0);
        end
    elseif EstClassPre(i) == 0
        fprintf(FidResults,'%d\n',0);
    end
end
fclose(FidResults);
display(['nEyesPassed=' num2str(nEyesPassed) ' /' num2str(nEyes) ]);

FlagTrVal = 2;
if FlagTrVal == 1
    FolderPath = ['Experiments' ExperimentsIndex '\Cascade-LAC\Node' NodeIndex '\Validation'];
    FolderPathEyes = ['EyePatchTr'];
    FolderPathNonEyes = ['NonEyePatchTr'];
elseif FlagTrVal == 2
    FolderPath = ['Experiments' ExperimentsIndex '\Cascade-LAC\Node' NodeIndex '\Validation'];
    FolderPathEyes = ['EyePatchVal'];
    FolderPathNonEyes = ['NonEyePatchVal'];
end

nEyes = 12600;

if str2double(NodeIndex) == 1
    EstClassPre = ones(nEyes,1);
else
    if str2double(NodeIndex) <= 10
        if FlagTrVal == 1
            EstClassPre = load(['Experiments' ExperimentsIndex '\Cascade-LAC\Node0' num2str(str2double(NodeIndex)-1) '\Training\ResultsOfClassifyingTrEyePatchesSBDA_Node0' num2str(str2double(NodeIndex)-1) '.dat']);
        elseif FlagTrVal == 2
            EstClassPre = load(['Experiments' ExperimentsIndex '\Cascade-LAC\Node0' num2str(str2double(NodeIndex)-1) '\Validation\ResultsOfClassifyingValEyePatchesSBDA_Node0' num2str(str2double(NodeIndex)-1) '.dat']);
        end
    else
        if FlagTrVal == 1
            EstClassPre = load(['Experiments' ExperimentsIndex '\Cascade-LAC\Node' num2str(str2double(NodeIndex)-1) '\Training\ResultsOfClassifyingTrEyePatchesSBDA_Node' num2str(str2double(NodeIndex)-1) '.dat']);
        elseif FlagTrVal == 2
            EstClassPre = load(['Experiments' ExperimentsIndex '\Cascade-LAC\Node' num2str(str2double(NodeIndex)-1) '\Validation\ResultsOfClassifyingValEyePatchesSBDA_Node' num2str(str2double(NodeIndex)-1) '.dat']);
        end
    end
end

FidSamples = fopen('ValidationEyeSamples.dat','r');
for k=1:nEyes
    StrTemp = fgetl(FidSamples);
    if EstClassPre(k) == 1
        ImgPatchNorm = str2num(StrTemp);
        ImgPatchNorm = reshape(ImgPatchNorm(1:end-1)', [WinSize, WinSize] );
        ImgPatchNorm = ImgPatchNorm';
        
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
                OutPutHaarFeats(k,j) = 1;
            else
                OutPutHaarFeats(k,j) = 0;
            end
        end
    end
end
fclose(FidSamples);

FidResults = fopen([FolderPath '\ResultsOfClassifyingValEyePatchesSBDA_Node' NodeIndex '.dat'],'w');
nEyesPassed = 0;
DistFromPosMean = zeros(nEyes,1);
for i=1:nEyes
    if EstClassPre(i) == 1
        TrainProj = OutPutHaarFeats(i,:) * Weights;
        MeanPosProj = MeanPos * Weights;
        DistFromPosMean(i) = sqrt( (TrainProj(1:nSBDA)-MeanPosProj(1:nSBDA)) * (TrainProj(1:nSBDA)-MeanPosProj(1:nSBDA))' );
        if DistFromPosMean(i) <= EnTheta
            fprintf(FidResults,'%d\n',1);
            nEyesPassed = nEyesPassed + 1;
        else
            fprintf(FidResults,'%d\n',0);
        end
    elseif EstClassPre(i) == 0
        fprintf(FidResults,'%d\n',0);
    end
end
fclose(FidResults);
display(['nEyesPassed=' num2str(nEyesPassed) ' /' num2str(nEyes) ]);