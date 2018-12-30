function OutSumPix = HaarLikeFeat(FeatType,ScaleY,ScaleX,p,q,ImgInt)

if FeatType == 1
    nRectY = 1; nRectX = 3;
elseif FeatType == 2
    nRectY = 1; nRectX = 2;
elseif FeatType == 3
    nRectY = 2; nRectX = 1;
elseif FeatType == 4
    nRectY = 3; nRectX = 1;
elseif FeatType == 5
    nRectY = 1; nRectX = 4;
elseif FeatType == 6
    nRectY = 4; nRectX = 1;
elseif FeatType == 7
    nRectY = 3; nRectX = 3;
end

SumPixs = zeros(nRectY,nRectX);

WinSubY = ScaleY / nRectY;
WinSubX = ScaleX / nRectX;

[WinY,WinX] = size(ImgInt);
for k=1:nRectY
    for l=1:nRectX
        Point4(1,:) = [ p-1+WinSubY*(k-1) q-1+WinSubX*(l-1) ];
        Point4(2,:) = [ p-1+WinSubY*(k-1) min(WinX,q-1+WinSubX*(l)) ];
        Point4(3,:) = [ min(WinY,p-1+WinSubY*(k)) q-1+WinSubX*(l-1) ];
        Point4(4,:) = [ min(WinY,p-1+WinSubY*(k)) min(WinX,q-1+WinSubX*(l)) ];
        SumPixs(k,l) = SumPixIntgImg(ImgInt,round(Point4));
    end
end


if FeatType == 1
    OutSumPix = SumPixs(1,1) - SumPixs(1,2) + SumPixs(1,3);
elseif FeatType == 2 || FeatType == 3
    OutSumPix = -1*SumPixs(1) + SumPixs(2);
elseif FeatType == 4
    OutSumPix = SumPixs(1,1) - SumPixs(2,1) + SumPixs(3,1);
elseif FeatType == 5
    OutSumPix = SumPixs(1,1) - SumPixs(1,2) - SumPixs(1,3) + SumPixs(1,4);
elseif FeatType == 6
    OutSumPix = SumPixs(1,1) - SumPixs(2,1) - SumPixs(3,1) + SumPixs(4,1);
elseif FeatType == 7
    OutSumPix =  SumPixs(1,1) + SumPixs(2,1) + SumPixs(3,1) + SumPixs(2,1) + SumPixs(2,3) + SumPixs(3,1) + SumPixs(3,2) + SumPixs(3,3) - SumPixs(2,2);
end

