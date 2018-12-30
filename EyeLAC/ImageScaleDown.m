function ImgMatDown = ImageScaleDown(ImgMat, ScaleFactor)

[Height,Width] = size(ImgMat);
HeightNew = round(Height*ScaleFactor);
WidthNew = round(Width*ScaleFactor);

ImgMatDown = zeros(HeightNew,WidthNew);

for i=1:HeightNew
    for j=1:WidthNew
        
        y_Ori=floor(i/ScaleFactor);
        x_Ori=floor(j/ScaleFactor);
        %display(['(x,y)=(' num2str(x_Ori) ',' num2str(y_Ori) ')']);
        y_Ori = min(max(1,y_Ori),Height-1);
        x_Ori = min(max(1,x_Ori),Width-1);        
        %display(['(x,y)=(' num2str(x_Ori) ',' num2str(y_Ori) ') in (1<=x<=' num2str(Width) ',1<=y<=' num2str(Height) ')']);
        
        DistY = i/ScaleFactor-y_Ori;
        DistX = j/ScaleFactor-x_Ori;
        
        x1 = x_Ori;
        y1 = y_Ori;
        x2 = x_Ori+1;
        y2 = y_Ori+1;
        
        PixValue1 = ImgMat(y1,x1);
        PixValue2 = ImgMat(y1,x2);
        PixValue3 = ImgMat(y2,x1);
        PixValue4 = ImgMat(y2,x2);
                
        ImgMatDown(i,j) = round(PixValue1*(1-DistY)*(1-DistX) + PixValue2*(1-DistY)*DistX + PixValue3*DistY*(1-DistX) + PixValue4*DistY*DistX);
    end
end

        
        