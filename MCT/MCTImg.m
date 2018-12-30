function ImgMCT = MCTImg(Img)
[nRow,nCol] = size(Img);
ImgMCT = zeros(nRow-2,nCol-2);
for i = 2:nRow-1
    for j = 2:nCol-1
        temp = Img(i-1:i+1,j-1:j+1);
        m = mean(mean(temp,1),2);
        temp = temp > m;
        sum = 0;
        for k = 1:9
            sum = sum + 2^(9-k)*temp(k);
        end
        ImgMCT(i-1,j-1) = sum;
    end
end