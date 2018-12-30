function ImgIntg = IntgImg(Img,flag)

[nRow,nCol] = size(Img);
ImgIntg = zeros(nRow,nCol);
if flag == 1
    ImgRowSum = zeros(nRow,nCol);
    for i=1:nRow
        if i == 1
            ImgRowSum(i,:) = Img(i,:);
        else
            ImgRowSum(i,:) = ImgRowSum(i-1,:) + Img(i,:);
        end
    end
    for i=1:nCol
        if i == 1
            ImgIntg(:,i) = ImgRowSum(:,i);
        else
            ImgIntg(:,i) = ImgIntg(:,i-1) + ImgRowSum(:,i);
        end
    end
elseif flag == 2
    ImgRowSumSq = zeros(nRow,nCol);
    for i=1:nRow
        if i == 1
            for j=1:nCol
                ImgRowSumSq(i,j) = Img(i,j)*Img(i,j);
            end
        else
            for j=1:nCol
                ImgRowSumSq(i,j) = ImgRowSumSq(i-1,j) + Img(i,j)*Img(i,j);
            end
        end
    end
    for i=1:nCol
        if i == 1
            ImgIntgSq(:,i) = ImgRowSumSq(:,i);
        else
            ImgIntgSq(:,i) = ImgIntgSq(:,i-1) + ImgRowSumSq(:,i);
        end
    end
    ImgIntg = ImgIntgSq;
end