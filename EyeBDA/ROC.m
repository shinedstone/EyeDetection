function [FalPosRate,DetectRate,Threshold] = ROC(Data1D,ClassOfData,nPos,nNeg,BDAFlag)

[nValue,DataValue] = class_information(Data1D);
DetectRate = zeros(nValue,1);
FalPosRate = zeros(nValue,1);
Threshold = zeros(nValue,1);
for i=1:nValue
    Theta = DataValue(i);
    Threshold(i) = Theta;
    
    for j=1:(nPos+nNeg)
        if BDAFlag == 1
            if Data1D(j) <= Theta
                EstClass = 1;
            else
                EstClass = 0;
            end
        else
            if Data1D(j) >= Theta
                EstClass = 1;
            else
                EstClass = 0;
            end
        end
            
        if ClassOfData(j) == 1 && EstClass == 1
            DetectRate(i) = DetectRate(i) + 1;
        elseif ClassOfData(j) == 0 && EstClass == 1
            FalPosRate(i) = FalPosRate(i) + 1;
        end
    end
    DetectRate(i) = DetectRate(i) / nPos * 100;
    FalPosRate(i) = FalPosRate(i) / nNeg * 100;
end
% if BDAFlag == 1
%     DetectRate = [ 0 ; DetectRate ; 100 ];
%     FalPosRate = [ 0 ; FalPosRate ; 100 ];
% end
%     DetectRate = [ 100 ; DetectRate ; 0 ];
%     FalPosRate = [ 100 ; FalPosRate ; 0 ];
% end
