clear all;
close all;
clc;

WinY = 18;
WinX = 18;

FileName = 'HaarFeatCandidates18x18.dat';
OutFileName = 'HaarFeatInfo18x18.dat';

SeperatedOutFileName{1} = ['HaarFeatInfo18x18_1of4.dat'];
SeperatedOutFileName{2} = ['HaarFeatInfo18x18_2of4.dat'];
SeperatedOutFileName{3} = ['HaarFeatInfo18x18_3of4.dat'];
SeperatedOutFileName{4} = ['HaarFeatInfo18x18_4of4.dat'];

FidType = fopen(FileName,'r');
Strs = fgetl(FidType);
Strs = fgetl(FidType);
FidInfo = fopen(OutFileName,'w');

nTypeHaarFeat = 7;
nFeats = zeros(7,1);
for t = 1 : nTypeHaarFeat
    Strs = fgetl(FidType);
    Numbs = str2num(Strs);
    nRectY = Numbs(1);
    nRectX = Numbs(2);
    ScaleY1 = Numbs(3);
    ScaleYStep = Numbs(4);
    ScaleYEnd = Numbs(5);
    ScaleX1 = Numbs(6);
    ScaleXStep = Numbs(7);
    ScaleXEnd = Numbs(8);
    for i=ScaleY1:ScaleYStep:ScaleYEnd
        for j=ScaleX1:ScaleXStep:ScaleXEnd
            nFeatFixedSize = 0;
            for p=2:WinY-i+1
                for q=2:WinX-j+1
                    nFeatFixedSize = nFeatFixedSize + 1;
                    fprintf(FidInfo,'%d %d %d %d %d \n',t,i,j,p,q);
                end
            end           
            nFeats(t) = nFeats(t) + nFeatFixedSize;
        end
    end
end

fclose(FidType);
fclose(FidInfo);
NumOfTotalHaarFeats = sum(nFeats);
NumOfHaarFeats = NumOfTotalHaarFeats / 4;

FidInfo = fopen(OutFileName,'r');
for i = 1 : 4
    FidTemp = fopen(SeperatedOutFileName{i},'w');
    for j = 1 : NumOfHaarFeats
        Strs = fgetl(FidInfo);
        Numbs = str2num(Strs);
        for k = 1 : 5
            fprintf(FidTemp,'%d ',Numbs(k));
        end
        fprintf(FidTemp,'\n');
    end
    fclose(FidTemp);
end
fclose(FidInfo);