clear all;

WinX = 24;
WinY = 24;
nClassifier = 1;
nMaxFeat = 10;

display('Loading Training Samples');
FileNames = dir('Faces24x24\*.bmp');
nPos = size(FileNames,1);

ImgPos = zeros(WinY,WinX,nPos);
ImgMCTPos = zeros(WinY-2,WinX-2,nPos);
for i=1:nPos
    FileName = FileNames(i,1).name;
    ImgPos(:,:,i) = imread(['Faces24x24\' FileName],'bmp');
    ImgMCTPos(:,:,i) = MCTImg(ImgPos(:,:,i));
end

FileNames = dir('NonFaces24x24\*.bmp');
nNeg = size(FileNames,1);

ImgNeg = zeros(WinY,WinX,nNeg);
ImgMCTNeg = zeros(WinY-2,WinX-2,nNeg);
for i=1:nNeg
    FileName = FileNames(i,1).name;
    ImgNeg(:,:,i) = imread(['NonFaces24x24\' FileName],'bmp');
    ImgMCTNeg(:,:,i) = MCTImg(ImgNeg(:,:,i));
end

ImgMCT = zeros(WinY-2,WinX-2,nPos+nNeg);
for i=1:nPos+nNeg
    if i<=nPos
        ImgMCT(:,:,i) = ImgMCTPos(:,:,i);
    else
        ImgMCT(:,:,i) = ImgMCTNeg(:,:,i-nPos);
    end
end
TrainClass = [ zeros(nPos,1) ; ones(nNeg,1) ];
nTrain = nPos + nNeg;

fidFeat = fopen('SelectedMCTFeat.dat','w');
fidGT = fopen('SelectedMCTGT.dat','w');

DetectRatesTarget = 100;
FalPosRatesTarget = 0;
Dpos = 1/(2*nPos)*ones(nPos,1);
Dneg = 1/(2*nNeg)*ones(nNeg,1);
D = [ Dpos ; Dneg ];
Alphaa = zeros(nMaxFeat,1);
Pixel = zeros(nMaxFeat,2);
gt = zeros(nMaxFeat,2,512);
FlagStopLearning = 0;
t = 0;
CM = zeros(2,2,nMaxFeat);
tic
while FlagStopLearning == 0 && t < nMaxFeat
    t = t + 1;
    display(['WeakClassifier:' num2str(t)]);
    
    %% Calculation of weighted error(Epsilon)
    Error = zeros(WinY-2,WinX-2);
    gt0 = zeros(WinY-2,WinX-2,512);
    gt1 = zeros(WinY-2,WinX-2,512);
    for y = 1 : WinY-2
        for x = 1 : WinX-2
            for r = 1 : 512
                for i = 1 : nTrain
                    if ImgMCT(y,x,i) == r-1
                        if TrainClass(i) == 0
                            gt0(y,x,r) = gt0(y,x,r) + D(i);
                        else
                            gt1(y,x,r) = gt1(y,x,r) + D(i);
                        end
                    end
                end
                Error(y,x) = Error(y,x) + min(gt0(y,x,r),gt1(y,x,r));
            end
        end
    end
    MinError = min(min(Error));
    [xt , yt] = find(Error' == MinError);
    yt = yt(1);
    xt = xt(1);
    Pixel(t,1) = yt;
    Pixel(t,2) = xt;
    gt(t,1,:) = gt0(yt,xt,:);
    gt(t,2,:) = gt1(yt,xt,:);
    Alphaa(t) = 0.5 * log((1-MinError)/MinError);
    
    fprintf(fidFeat,'%d %d %d\n',yt,xt,Alphaa(t));
    for i = 1 : 2
        for j = 1 : 512
            fprintf(fidGT,'%d ',gt(t,i,j));
        end
        fprintf(fidGT,'\n');
    end
    
    %% Update the Weight Distribution
    for i = 1 : nTrain
        rt = ImgMCT(yt,xt,i) + 1;
        if gt(t,1,rt) > gt(t,2,rt)
            flag = 0;
        else
            flag = 1;
        end
        if TrainClass(i) == flag
            D(i) = D(i) * exp( -Alphaa(t) );
        else
            D(i) = D(i) * exp( Alphaa(t) );
        end
    end
    
    D(:) = D(:) / sum(D);
    
    %% Evaludation of 1~z-th Haar-like feats. that have been selected until
    SumAlpha = 0;
    for z = 1 : t
        SumAlpha = SumAlpha + Alphaa(t);
    end
    
    for i= 1 : nTrain
        WeightedH = 0;
        for z = 1 : t
            rt = ImgMCT(Pixel(z,1),Pixel(z,2),i)+1;
            if gt(z,2,rt) >= gt(z,1,rt)
                EstClass = 1;
            else
                EstClass = 0;
            end
            WeightedH = WeightedH + Alphaa(z) * EstClass;
        end
        
        if WeightedH < 0.5*SumAlpha
            if TrainClass(i) == 0
                CM(1,1,t) = CM(1,1,t) + 1;
            else
                CM(2,2,t) = CM(2,2,t) + 1;
            end
        else
            if TrainClass(i) == 1
                CM(1,2,t) = CM(1,2,t) + 1;
            else
                CM(2,1,t) = CM(2,1,t) + 1;
            end
        end
        
    end
    DetectRatesTr = CM(1,1,t) / (CM(1,1,t) + CM(2,1,t))*100;
    FalPosRatesTr = CM(2,2,t) / (CM(2,2,t) + CM(1,2,t))*100;
    display(['nFeat:' num2str(z)]);
    display(['For Training Set, Deteiction-Rates:' num2str(DetectRatesTr) '    / False-Positive-Rates:' num2str(FalPosRatesTr) ]);
         
    if DetectRatesTr >= DetectRatesTarget && FalPosRatesTr <= FalPosRatesTarget
        FlagStopLearning = 0;
    end
    
end
toc
fclose(fidFeat);
fclose(fidGT);