clear all;

MaxNumLocations = 10;
nMCTValues = 2^9;

FaceFiles = dir('Faces24x24\*.bmp');
NonFaceFiles = dir('NonFaces24x24\*.bmp');

nFaces = size(FaceFiles,1);
nNonFaces = size(NonFaceFiles,1);

display('Performing MCT');
t0 = clock;
MCTFaces = zeros(22,22,nFaces);
MCTNonFaces = zeros(22,22,nNonFaces);

for k=1:nFaces
    FileName = FaceFiles(k,1).name;    
    ImgMat = imread(['Faces24x24\' FileName],'bmp');
    MCTFaces(:,:,k) = MCT(ImgMat);
end

for k=1:nNonFaces
    FileName = NonFaceFiles(k,1).name;
    ImgMat = imread(['NonFaces24x24\' FileName],'bmp');
    MCTNonFaces(:,:,k) = MCT(ImgMat);
end
t1 = etime(clock,t0);
display(['e-Time for MCT : ' num2str(t1)]);

fidFeat = fopen('SelectedMCTFeat2.dat','w');
fidGT = fopen('SelectedMCTGT2.dat','w');

OutputPos = zeros(nFaces,MaxNumLocations);
OutputNeg = zeros(nNonFaces,MaxNumLocations);
SelectedLocations = zeros(MaxNumLocations,2);
Alpha = zeros(MaxNumLocations,1);
TotalTablePos = zeros(MaxNumLocations,nMCTValues);
TotalTableNeg = zeros(MaxNumLocations,nMCTValues);
WeightBFaces = ones(nFaces,1)/(2*nFaces);           % Weights of Positive Samples for Boosting
WeightBNonFaces = ones(nNonFaces,1)/(2*nNonFaces);  % Weights of Negative Samples for Boosting
for k=1:MaxNumLocations
    display(['Weak classifer : ' num2str(k)]);
    [MinLocation,MinError,TableFace,TableNonFace] = TrainWeakClassifiers(MCTFaces,MCTNonFaces,WeightBFaces,WeightBNonFaces);
    SelectedLocations(k,1) = MinLocation(1);
    SelectedLocations(k,2) = MinLocation(2);
    alpha = 1/2*log((1-MinError)/MinError);
    Alpha(k) = alpha;
    TotalTablePos(k,:) = TableFace;
    TotalTableNeg(k,:) = TableNonFace;
    
    for i=1:nFaces
        SumTemp = 0;
        for j=1:k
            Y = SelectedLocations(j,1);
            X = SelectedLocations(j,2);
            gamma = MCTFaces(Y,X,i);
            if TotalTablePos(j,gamma+1) <= TotalTableNeg(j,gamma+1)
                SumTemp = SumTemp + Alpha(j);
            end
        end
        OutputPos(i,k) = SumTemp;
    end
    
    for i=1:nNonFaces
        SumTemp = 0;
        for j=1:k
            Y = SelectedLocations(j,1);
            X = SelectedLocations(j,2);
            gamma = MCTNonFaces(Y,X,i);
            if TotalTablePos(j,gamma+1) <= TotalTableNeg(j,gamma+1)
                SumTemp = SumTemp + Alpha(j);
            end
        end
        OutputNeg(i,k) = SumTemp;
    end
    
    fprintf(fidFeat,'%d %d %d\n',SelectedLocations(k,1),SelectedLocations(k,2),Alpha(k));
    for i = 1 : 512
        fprintf(fidGT,'%d ',TotalTablePos(k,i));
    end
    fprintf(fidGT,'\n');
    for i = 1 : 512
        fprintf(fidGT,'%d ',TotalTableNeg(k,i));
    end
    fprintf(fidGT,'\n');
        
    %Update boosting weight
    for i=1:nFaces
        gamma = MCTFaces(MinLocation(1),MinLocation(2),i);
        if TableFace(gamma+1) > TableNonFace(gamma+1)
            WeightBFaces(i) = WeightBFaces(i) * exp(-alpha);
        else
            WeightBFaces(i) = WeightBFaces(i) * exp(alpha);
        end
    end
    for i=1:nNonFaces
        gamma = MCTNonFaces(MinLocation(1),MinLocation(2),i);
        if TableFace(gamma+1) <= TableNonFace(gamma+1)
            WeightBNonFaces(i) = WeightBNonFaces(i) * exp(-alpha);
        else
            WeightBNonFaces(i) = WeightBNonFaces(i) * exp(alpha);
        end
    end
    sumb = sum(WeightBFaces) + sum(WeightBNonFaces);
    WeightBFaces = WeightBFaces / sumb;
    WeightBNonFaces = WeightBNonFaces / sumb;
end

for i=1:MaxNumLocations
    display(['Num. of selected feature = ' num2str(i)]);
    Outputs = [ OutputPos(:,i) ; OutputNeg(:,i) ];
    [nOutputValues,OutputValues] = class_information(Outputs);
    DetectRate = zeros(nOutputValues,1);
    FalsePosRate = zeros(nOutputValues,1);    
    [SortedOutputValues,Index] = sort(OutputValues);
    for j=1:nOutputValues
        Threshold = OutputValues(Index(j));
        nDetect = 0;
        for k=1:nFaces
            if OutputPos(k,i) < Threshold
                nDetect = nDetect + 1;
            end
        end
        DetectRate(j) = nDetect/nFaces*100;
        
        nFalsePos = 0;
        for k=1:nNonFaces
            if OutputNeg(k,i) < Threshold
                nFalsePos = nFalsePos + 1;
            end
        end
        FalsePosRate(j) = nFalsePos/nNonFaces*100;
        
        display(['Threshold=' num2str(Threshold) ' -->  DetectRates=' num2str(DetectRate(j)) ',   FalsePosRates=' num2str(FalsePosRate(j))]);
    end
    
end
fclose(fidFeat);
fclose(fidGT);