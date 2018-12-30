clear all;
close all;
clc;

IndexExperiments = '01';
IndexNode = '01';

MinDetectRates = 90;
MaxFalsePosRates = 50;

nPos = 2800;
nNeg = 2800;

FolderPath = ['Experiments' IndexExperiments '\Cascade-BDA\Node' IndexNode '\Training'];
FolderPathVal = ['Experiments' IndexExperiments '\Cascade-BDA\Node' IndexNode '\Validation'];
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

FidWeights = fopen([FolderPath '\ResultsOfBDA_WeightsOfHaarFeatsByFFS_Node' IndexNode '.dat'],'w');
FidPosMean = fopen([FolderPath '\ResultsOfBDA_MeanPosSampsOfHaarFeatsByFFS_Node' IndexNode '.dat'],'w');
FidResults = fopen([FolderPath '\ResultsOfBDA_EnTheta_UsingSelectedFeatsByFFS_Node' IndexNode '.dat'],'w');
fprintf(FidResults,'nFeats    nBDA    EnTheta    DetectRates(Val)    FalsePosRates(Val)    \n');
num = 1;
for k = 3 : 3
    TrainData = TrainDataTotal(:,1:k);
    ValidationData = ValidationTotal(:,1:k);
    MeanPos = mean(TrainData(1:nPos,:));
    WBDA = BDA(TrainData(1:nPos,:),TrainData(nPos+1:end,:),MeanPos);
    TrainProj = TrainData * WBDA;
    MeanPosProj = mean(TrainProj(1:nPos,:));
    ValidationProj = ValidationData * WBDA;
    for nFeats = 1 : min(k,5)
        DistFromPosMean = zeros(nValidation,1);
        for i=1:nValidation
            DistFromPosMean(i) = sqrt( (ValidationProj(i,1:nFeats)-MeanPosProj(1:nFeats))*(ValidationProj(i,1:nFeats)-MeanPosProj(1:nFeats))' );
        end
        eval(['[FPR' num2str(nFeats) ',DR' num2str(nFeats) ',Threshold]=ROC(DistFromPosMean,[ones(nPosVal,1);zeros(nNegVal,1)],nPosVal,nNegVal,1);']);
        if (k == 1) && (nFeats == 1)
            for i = 1 : size(Threshold,1)
                fprintf(FidResults,'%d    %d    %.6f    %.2f    %.2f    \n',k,nFeats,Threshold(i),DR1(i),FPR1(i));
            end
            for i=1:k
                fprintf(FidPosMean,'%f, ',MeanPos(i));
            end
            fprintf(FidPosMean,'\n');
            for i=1:k
                for j=1:nFeats
                    fprintf(FidWeights,'%f, ',WBDA(i,j));
                end
                fprintf(FidWeights,'\n');
            end
        end
    end
    eval(['figure(' num2str(t) ')']);
    figure(1);
    subplot(2,5,num);
    if k == 1
        plot(FPR1,DR1);
    elseif k == 2
        plot(FPR1,DR1,FPR2,DR2);
    elseif k == 3
        plot(FPR1,DR1,FPR2,DR2,FPR3,DR3);
    elseif k == 4
        plot(FPR1,DR1,FPR2,DR2,FPR3,DR3,FPR4,DR4);
    else
        plot(FPR1,DR1,FPR2,DR2,FPR3,DR3,FPR4,DR4,FPR5,DR5);
    end
    legend('1','2','3','4','5');
    grid on;
    title(['nFeat = ' num2str(k)]);
    axis([0 100 90 100]);
    num = num + 1;
end
fclose(FidPosMean);
fclose(FidWeights);
fclose(FidResults);