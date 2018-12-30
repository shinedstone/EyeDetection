function SumPix = SumPixIntgImg(ImgIntg,Point4)

SumPixs = zeros(4,1);

SumPixs(4) = ImgIntg(Point4(4,1),Point4(4,2));

if Point4(2,1) == 0
    SumPixs(2) = 0;
elseif Point4(2,2) == 0
    SumPixs(2) = 0;
else
    SumPixs(2) = ImgIntg(Point4(2,1),Point4(2,2));
end

if Point4(3,1) == 0
    SumPixs(3) = 0;
elseif Point4(3,2) == 0
    SumPixs(3) = 0;
else
    SumPixs(3) = ImgIntg(Point4(3,1),Point4(3,2));
end

if Point4(1,1) == 0
    SumPixs(1) = 0;
elseif Point4(1,2) == 0
    SumPixs(1) = 0;
else
    SumPixs(1) = ImgIntg(Point4(1,1),Point4(1,2));
end

SumPix = SumPixs(4) - SumPixs(2) - SumPixs(3) + SumPixs(1);