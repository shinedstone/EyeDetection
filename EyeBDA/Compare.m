clear all;
close all;
clc;

IndexExperiments = '01';
IndexNode = '08';

nFeats = 54;
nBDAs = 1;

figure(1);
grid on;
title('nNode = 8');
axis([0 100 0 100]);

Method = 'Adaboost';

MinDetectRates = 0;
MaxFalsePosRates = 100;

nPos = 2800;
nNeg = 2800;

FolderPath = ['Experiments' IndexExperiments '\Cascade-LAC\Node' IndexNode '\Training'];
FolderPathVal = ['Experiments' IndexExperiments '\Cascade-LAC\Node' IndexNode '\Validation'];
TrainDataTotal = load([ FolderPath '\OutPutOfHaarFeatsSelectedByFFS_Node' IndexNode '.dat'])';

TrainClass = [ ones(nPos,1) ; zeros(nNeg,1) ];
[nTrain,nMaxFeats] = size(TrainDataTotal);

% Evaludation for validation samples---------------------------------------------------------------------
HaarFeatByFFS = zeros(nMaxFeats,6);
FidHaarFeats = fopen([FolderPath '\HaarFeatsSelectedByFFS_Node' IndexNode '.dat'] ,'r');
StrTemp = fgetl(FidHaarFeats);
for k=1:nMaxFeats
    StrTemp = fgetl(FidHaarFeats);
    NumsTemp = str2num(StrTemp);
    HaarFeatByFFS(k,:) = NumsTemp;
end
fclose(FidHaarFeats);

ThresholdsOfHaarFeats = load([FolderPath '\ThresholdsOfHaarFeatsSelectedByFFS_Node' IndexNode '.dat']);
ImgPos = dir([FolderPathVal '\PositiveSamples\*.bmp']);
nPosVal = size(ImgPos,1);
ImgNeg = dir([FolderPathVal '\NegativeSamples\*.bmp']);
nNegVal = size(ImgNeg,1);
nValidation = nPosVal + nNegVal;
ValidationClass = [ ones(nPosVal,1) ; zeros(nNegVal,1) ];
ValidationTotal = zeros(nValidation,nMaxFeats);
for k=1:nValidation
    if k<=nPosVal
        FileName = ImgPos(k,1).name;
        ImgPatch = imread([FolderPathVal '\PositiveSamples\' FileName],'bmp');
    else
        FileName = ImgNeg(k-nPosVal,1).name;
        ImgPatch = imread([FolderPathVal '\NegativeSamples\' FileName],'bmp');
    end
    ImgPatchNorm = ImageNormalization(double(ImgPatch));
    ImgPatchNorm = IntgImg(double(ImgPatchNorm),1);
    
    for i=1:nMaxFeats
        FeatType = HaarFeatByFFS(i,1);
        SizeY = HaarFeatByFFS(i,2);
        SizeX = HaarFeatByFFS(i,3);
        StartY = HaarFeatByFFS(i,4);
        StartX = HaarFeatByFFS(i,5);
        Polarity = HaarFeatByFFS(i,6);
        Theta = ThresholdsOfHaarFeats(i);
        
        OutSumPix = HaarLikeFeat(FeatType,SizeY,SizeX,StartY,StartX,ImgPatchNorm);
        
        if Polarity*OutSumPix >= Polarity*Theta
            ValidationTotal(k,i) = 1;
        else
            ValidationTotal(k,i) = 0;
        end
    end
end
% -------------------------------------------------------------------------------------------------------------------


TrainData = TrainDataTotal(:,1:nFeats);
ValidationData = ValidationTotal(:,1:nFeats);

MeanPos = mean(TrainData(1:nPos,:));
MeanNeg = mean(TrainData(nPos+1:end,:));

%% BDA
WBDA = BDA(TrainData(1:nPos,:),TrainData(nPos+1:end,:),MeanPos);
TrainProj = TrainData * WBDA;
MeanPosProj = mean(TrainProj(1:nPos,:));
ValidationProj = ValidationData * WBDA;
DistFromPosMean = zeros(nValidation,1);
for i=1:nValidation
    DistFromPosMean(i) = sqrt( (ValidationProj(i,1:nBDAs)-MeanPosProj(1:nBDAs))*(ValidationProj(i,1:nBDAs)-MeanPosProj(1:nBDAs))' );
end
[FPR,DR]=ROC(DistFromPosMean,[ones(nPosVal,1);zeros(nNegVal,1)],nPosVal,nNegVal,1);

plot(FPR,DR,'b-');
hold on;

%% LAC
CovPos = zeros(nFeats,nFeats);
for j=1:nPos
    CovPos = CovPos + (TrainData(j,:)-MeanPos)'*(TrainData(j,:)-MeanPos);
end
CovPos = CovPos / nPos;
CovPos = CovPos + 0.01*eye(nFeats);

WLAC = (MeanPos-MeanNeg)/CovPos;
WLAC = WLAC / norm(WLAC);

ValidationProj = ValidationData * WLAC';

[FPR,DR]=ROC(ValidationProj,[ones(nPosVal,1);zeros(nNegVal,1)],nPosVal,nNegVal,0);
plot(FPR,DR,'r-');
hold on;

%% SBDA
WSBDA = SBDA(TrainData(1:nPos,:),TrainData(nPos+1:end,:),1);
TrainProj = TrainData * WSBDA;
MeanPosProj = mean(TrainProj(1:nPos,:));
ValidationProj = ValidationData * WSBDA;
DistFromPosMean = zeros(nValidation,1);
for i=1:nValidation
    DistFromPosMean(i) = sqrt( (ValidationProj(i,1:nBDAs)-MeanPosProj(1:nBDAs))*(ValidationProj(i,1:nBDAs)-MeanPosProj(1:nBDAs))' );
end
[FPR,DR]=ROC(DistFromPosMean,[ones(nPosVal,1);zeros(nNegVal,1)],nPosVal,nNegVal,1);

plot(FPR,DR,'g-');
hold on;

%% FDA
WFDA = LDA(TrainData,[ones(nPos,1);zeros(nNeg,1)],0);
ValidationProj = ValidationData * WFDA;
if mean(ValidationProj(1:nPosVal)) >= mean(ValidationProj(nPosVal+1:end))
    [FPR,DR]=ROC(ValidationProj,[ones(nPosVal,1);zeros(nNegVal,1)],nPosVal,nNegVal,0);
else
    [FPR,DR]=ROC(ValidationProj,[ones(nPosVal,1);zeros(nNegVal,1)],nPosVal,nNegVal,1);
end

plot(FPR,DR,'c-');
hold on;

%% LFDA
WLFDA = LFDA(TrainData',[ones(nPos,1);zeros(nNeg,1)]');
TrainProj = TrainData * WLFDA;
MeanPosProj = mean(TrainProj(1:nPos,:));
ValidationProj = ValidationData * WLFDA;
DistFromPosMean = zeros(nValidation,1);
for i=1:nValidation
    DistFromPosMean(i) = sqrt( (ValidationProj(i,1:nBDAs)-MeanPosProj(1:nBDAs))*(ValidationProj(i,1:nBDAs)-MeanPosProj(1:nBDAs))' );
end
[FPR,DR]=ROC(DistFromPosMean,[ones(nPosVal,1);zeros(nNegVal,1)],nPosVal,nNegVal,1);

plot(FPR,DR,'m-');
hold on;

legend('BDA','LAC','SBDA','FDA','LFDA');