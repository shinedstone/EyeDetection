clear all;

FeatSelected = load('SelectedMCTFeat.dat');
GTSelected = load('SelectedMCTGT.dat');
[row,col] = size(FeatSelected);

% gamma = 1;
nFeat = row;

WinY = 20;
WinX = 20;

display('Loading Validation Samples');
FileNames = dir('Validation\Positive\*.bmp');
nPos = size(FileNames,1);

ImgPos = zeros(WinY,WinX,nPos);
ImgMCTPos = zeros(WinY-2,WinX-2,nPos);
for i=1:nPos
    FileName = FileNames(i,1).name;
    ImgPos(:,:,i) = imread(['Validation\Positive\' FileName],'bmp');
    ImgMCTPos(:,:,i) = MCTImg(ImgPos(:,:,i));
end

FileNames = dir('Training\Negative\*.bmp');
nNeg = size(FileNames,1);

ImgNeg = zeros(WinY,WinX,nNeg);
ImgMCTNeg = zeros(WinY-2,WinX-2,nNeg);
for i=1:nNeg
    FileName = FileNames(i,1).name;
    ImgNeg(:,:,i) = imread(['Validation\Negative\' FileName],'bmp');
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
ValidationClass = [ ones(nPos,1) ; zeros(nNeg,1) ];
nSamp = nPos+nNeg;

for a = 1 : 20
    CM = zeros(2,2);        %% Confusion Matrix
    for i = 1 : nSamp
        WeightedH = 0;
        SumAlpha = 0;
        for t = 1 : nFeat
            y = FeatSelected(t,1);
            x = FeatSelected(t,2);
            alpha = FeatSelected(t,3);
            SumAlpha = SumAlpha + alpha;
            r = ImgMCT(y,x,i)+1;
            if GTSelected(2*t,r) >= GTSelected(2*t-1,r)
                EstClass = 1;
            else
                EstClass = 0;
            end
            WeightedH = WeightedH + alpha * EstClass;
        end
        
        if WeightedH < 0.5*SumAlpha*0.1*a
            if ValidationClass(i) == 0
                CM(1,1) = CM(1,1) + 1;
            else
                CM(2,2) = CM(2,2) + 1;
            end
        else
            if ValidationClass(i) == 1
                CM(1,2) = CM(1,2) + 1;
            else
                CM(2,1) = CM(2,1) + 1;
            end
        end
        
    end
    
    DetectRates = CM(1,1) / (CM(1,1) + CM(2,1))*100;
    FalPosRates = CM(2,2) / (CM(2,2) + CM(1,2))*100;
    
    display(['Gamma : ' num2str(0.1*a) '    //DetectionRates : ' num2str(DetectRates) '    // False Positive Rate : ' num2str(FalPosRates) ]);
end
