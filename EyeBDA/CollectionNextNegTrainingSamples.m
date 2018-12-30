clear all;
close all;
clc;

ExperimentsIndex = '01';
NodeIndex = '01'; 

ScaleFactor = 0.8;
nNeg = 2800;
MaxScoreForNeg = 0.2;
MinScoreNeg = 10000;

FlagTrVal = 1;
if FlagTrVal == 1
    FolderImages = 'Images-Training';
    FolderPath = ['Experiments' ExperimentsIndex '\Cascade-BDA\Node0' num2str(str2double(NodeIndex)-1) '\Training'];
    FolderPathOut = ['Experiments' ExperimentsIndex '\Cascade-BDA\Node' NodeIndex '\Training'];
elseif FlagTrVal == 2
    FolderImages = 'Images-Validation';
    FolderPath = ['Experiments' ExperimentsIndex '\Cascade-BDA\Node0' num2str(str2double(NodeIndex)-1) '\Validation'];
    FolderPathOut = ['Experiments' ExperimentsIndex '\Cascade-BDA\Node' NodeIndex '\Validation'];
end
ImgFiles = dir([FolderImages '\*.bmp']);
nFiles = size(ImgFiles,1);
FidNeg = fopen([FolderPathOut '\CollectedNegSampInformation.dat'],'w');

nCandEachImage = 100;
CandForFP = zeros(nFiles*nCandEachImage,8);
IndexNeg = 0;
for i=1:nFiles
    FileName = ImgFiles(i,1).name;
    FPs = load([FolderPath '\ResultsOfScanningBDA\BDA_FP_0' num2str(str2double(NodeIndex)-1) '_' FileName '.dat']);
    nFPs = size(FPs,1);
    if nFPs > 0
        [SortedScore,Index] = sort(FPs(:,7));        
        for j=1:min(nCandEachImage,nFPs)
            if FPs(Index(end-j+1),7) > MaxScoreForNeg
                IndexNeg = IndexNeg + 1;
                CandForFP(IndexNeg,1) = i;
                CandForFP(IndexNeg,2) = FPs(Index(end-j+1),1);
                CandForFP(IndexNeg,3) = FPs(Index(end-j+1),2);
                CandForFP(IndexNeg,4) = FPs(Index(end-j+1),3);
                CandForFP(IndexNeg,5) = FPs(Index(end-j+1),4);
                CandForFP(IndexNeg,6) = FPs(Index(end-j+1),5);
                CandForFP(IndexNeg,7) = FPs(Index(end-j+1),6);
                CandForFP(IndexNeg,8) = FPs(Index(end-j+1),7);
            end
        end
    end
end
display(IndexNeg);
CandForFP = CandForFP(1:IndexNeg,:);

start_idx = size(dir([FolderPathOut '\NegativeSamples\*.bmp']),1);

Order = randperm(IndexNeg);
for i = 1 : nNeg - start_idx
    if rem(i,100) == 0
        display(['Collected Negative Samples : ' num2str(i)]);
    end
        
    Index = Order(i);
    FileName = ImgFiles(CandForFP(Index,1),1).name;
    ImgMat = imread([FolderImages '\' FileName],'bmp');
    
    ImgSizeX = CandForFP(Index,2);
    ImgSizeY = CandForFP(Index,3);
    TopLeftX = CandForFP(Index,4);
    TopLeftY = CandForFP(Index,5);
    BottomRightX = CandForFP(Index,6);
    BottomRightY = CandForFP(Index,7);
    PatchScore = CandForFP(Index,8);
        
    Flag = 0;
    while Flag == 0
        if size(ImgMat,1)==ImgSizeY && size(ImgMat,2)==ImgSizeX
            ImgPatch = ImgMat(TopLeftY:BottomRightY,TopLeftX:BottomRightX);
            imwrite(uint8(ImgPatch),[FolderPathOut '\NegativeSamples\Neg' num2str(i+start_idx) '.bmp'],'bmp');
            fprintf(FidNeg,'SampIndex: %d, PatchScore: %f, Image:%s\n',i,PatchScore,FileName);
            MinScoreNeg = min(MinScoreNeg,PatchScore);
            Flag = 1;
        else
            ImgMat = ImageScaleDown(double(ImgMat), ScaleFactor);
        end
    end
    
end
display(MinScoreNeg);
fclose(FidNeg);

nNeg = 1400;
MinScoreNeg = 10000;

FlagTrVal = 2;
if FlagTrVal == 1    
    FolderImages = 'Images-Training';
    FolderPath = ['Experiments' ExperimentsIndex '\Cascade-BDA\Node0' num2str(str2double(NodeIndex)-1) '\Training'];
    FolderPathOut = ['Experiments' ExperimentsIndex '\Cascade-BDA\Node' NodeIndex '\Training'];
elseif FlagTrVal == 2
    FolderImages = 'Images-Validation';
    FolderPath = ['Experiments' ExperimentsIndex '\Cascade-BDA\Node0' num2str(str2double(NodeIndex)-1) '\Validation'];
    FolderPathOut = ['Experiments' ExperimentsIndex '\Cascade-BDA\Node' NodeIndex '\Validation'];
end
ImgFiles = dir([FolderImages '\*.bmp']);
nFiles = size(ImgFiles,1);
FidNeg = fopen([FolderPathOut '\CollectedNegSampInformation.dat'],'w');

nCandEachImage = 100;
CandForFP = zeros(nFiles*nCandEachImage,8);
IndexNeg = 0;
for i=1:nFiles    
    FileName = ImgFiles(i,1).name;
    FPs = load([FolderPath '\ResultsOfScanningBDA\BDA_FP_0' num2str(str2double(NodeIndex)-1) '_' FileName '.dat']);
    nFPs = size(FPs,1);
    if nFPs > 0
        [SortedScore,Index] = sort(FPs(:,7));        
        for j=1:min(nCandEachImage,nFPs)
            if FPs(Index(end-j+1),7) > MaxScoreForNeg
                IndexNeg = IndexNeg + 1;
                CandForFP(IndexNeg,1) = i;
                CandForFP(IndexNeg,2) = FPs(Index(end-j+1),1);
                CandForFP(IndexNeg,3) = FPs(Index(end-j+1),2);
                CandForFP(IndexNeg,4) = FPs(Index(end-j+1),3);
                CandForFP(IndexNeg,5) = FPs(Index(end-j+1),4);
                CandForFP(IndexNeg,6) = FPs(Index(end-j+1),5);
                CandForFP(IndexNeg,7) = FPs(Index(end-j+1),6);
                CandForFP(IndexNeg,8) = FPs(Index(end-j+1),7);
            end
        end
    end
end
display(IndexNeg);
CandForFP = CandForFP(1:IndexNeg,:);

start_idx = size(dir([FolderPathOut '\NegativeSamples\*.bmp']),1);

Order = randperm(IndexNeg);
for i = 1 : nNeg - start_idx
    if rem(i,100) == 0
        display(['Collected Negative Samples : ' num2str(i)]);
    end
        
    Index = Order(i);
    FileName = ImgFiles(CandForFP(Index,1),1).name;
    ImgMat = imread([FolderImages '\' FileName],'bmp');
    
    ImgSizeX = CandForFP(Index,2);
    ImgSizeY = CandForFP(Index,3);
    TopLeftX = CandForFP(Index,4);
    TopLeftY = CandForFP(Index,5);
    BottomRightX = CandForFP(Index,6);
    BottomRightY = CandForFP(Index,7);
    PatchScore = CandForFP(Index,8);
        
    Flag = 0;
    while Flag == 0
        if size(ImgMat,1)==ImgSizeY && size(ImgMat,2)==ImgSizeX
            ImgPatch = ImgMat(TopLeftY:BottomRightY,TopLeftX:BottomRightX);
            imwrite(uint8(ImgPatch),[FolderPathOut '\NegativeSamples\Neg' num2str(i+start_idx) '.bmp'],'bmp');
            fprintf(FidNeg,'SampIndex: %d, PatchScore: %f, Image:%s\n',i,PatchScore,FileName);
            MinScoreNeg = min(MinScoreNeg,PatchScore);
            Flag = 1;
        else
            ImgMat = ImageScaleDown(double(ImgMat), ScaleFactor);
        end
    end
    
end
display(MinScoreNeg);
fclose(FidNeg);
