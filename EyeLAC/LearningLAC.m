clear all;
close all;
clc;

IndexExperiments = '09';
IndexNode = '01';

MinDetectRates = 98;
MaxFalsePosRates = 100;

nPos = 2800;
nNeg = 2800;

FolderPath = ['Experiments' IndexExperiments '\Cascade-LAC\Node' IndexNode '\Training'];
FolderPathVal = ['Experiments' IndexExperiments '\Cascade-LAC\Node' IndexNode '\Validation'];
TrainDataTotal = load([ FolderPath '\OutPutOfHaarFeatsSelectedByFFS_Node' IndexNode '.dat'])';

FidWeights = fopen([FolderPath '\ResultsOfLAC_Weights_UsingSelectedFeatsByFFS_Node' IndexNode '.dat'],'w');
fprintf(FidWeights,'nFeats     Weights\n');

FidResults = fopen([FolderPath '\ResultsOfLAC_EnTheta_UsingSelectedFeatsByFFS_Node' IndexNode '.dat'],'w');
fprintf(FidResults,'nFeats    EnTheta    DetectRates(Val)    FalsePosRates(Val)    DetectRates(Tr)    FalsePosRates(Tr)\n');

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
%-------------------------------------------------------------------------------------------------------------------

TPF = zeros(nMaxFeats,1);
for k=3:3
    
    TrainData = TrainDataTotal(:,1:k);
    ValidationData = ValidationTotal(:,1:k);
    
    MeanPos = mean(TrainData(1:nPos,:));
    MeanNeg = mean(TrainData(nPos+1:end,:));
    
    CovPos = zeros(k,k);
    for j=1:nPos
        CovPos = CovPos + (TrainData(j,:)-MeanPos)'*(TrainData(j,:)-MeanPos);
    end
    CovPos = CovPos / nPos;
    CovPos = CovPos + 0.01*eye(k);
    
    a = (MeanPos-MeanNeg)/CovPos;
    a = a / norm(a);
    fprintf(FidWeights,'%d  ',k);
    for j=1:k
        fprintf(FidWeights,'%f, ',a(j));
    end
    fprintf(FidWeights,'\n');
    
    b = a*MeanNeg';
    
    TrainProj = TrainData * a';
    
    ValidationProj = ValidationData * a';
    [nOutValues,OutValues,nSampEachValue] = class_information(ValidationProj);
    
    for i=1:nOutValues
        EnTheta = OutValues(i);
        
        nDetect = 0;
        nFalsePos = 0;
        for j=1:nTrain
            if TrainProj(j) >= EnTheta
                EstClass = 1;
            else
                EstClass = 0;
            end
            if EstClass == 1 && TrainClass(j) == 1
                nDetect = nDetect + 1;
            elseif EstClass == 1 && TrainClass(j) == 0
                nFalsePos = nFalsePos + 1;
            end
        end
        DetectRates = nDetect/nPos*100;
        FalsePosRates = nFalsePos/nNeg*100;
        
        nDetectVal = 0;
        nFalsePosVal = 0;
        for j=1:nValidation
            if ValidationProj(j) >= EnTheta
                EstClass = 1;
            else
                EstClass = 0;
            end
            if EstClass == 1 && ValidationClass(j) == 1
                nDetectVal = nDetectVal + 1;
            elseif EstClass == 1 && ValidationClass(j) == 0
                nFalsePosVal = nFalsePosVal + 1;
            end
        end
        DetectRatesVal = nDetectVal/nPosVal*100;
        FalsePosRatesVal = nFalsePosVal/nNegVal*100;
        
        if DetectRatesVal>=MinDetectRates && FalsePosRatesVal<MaxFalsePosRates
            fprintf(FidResults,'%d    %f    %.2f    %.2f    %.2f    %.2f\n',k,EnTheta,DetectRatesVal,FalsePosRatesVal,DetectRates,FalsePosRates);
            TPF(k) = FalsePosRatesVal;
        end
    end
    fprintf(FidResults,'\n');
end
fclose(FidWeights);
fclose(FidResults);
figure(2);
plot(TPF);