function W_BDA = BDA(TrainPos,TrainNeg,MeanPosTrain)

nTrainPos  = size(TrainPos,1);
nTrainNeg  = size(TrainNeg,1);
nPix = size(MeanPosTrain,2);

Sx = zeros(nPix,nPix);
for i=1:nTrainPos
    Sx = Sx + (TrainPos(i,:)-MeanPosTrain)'*(TrainPos(i,:)-MeanPosTrain);
end
Sx = Sx / nTrainPos;

Sx = Sx + 0.01*eye(nPix);

Sy = zeros(nPix,nPix);
for i=1:nTrainNeg
    Sy = Sy + (TrainNeg(i,:)-MeanPosTrain)'*(TrainNeg(i,:)-MeanPosTrain);
end
Sy = Sy / nTrainNeg;

[EigVector,EigValue] = diagonal(Sx);

for i=1:nPix
    EigVector(:,i) = EigVector(:,i) / sqrt(EigValue(i));
end

W1 = EigVector;
SyTemp = W1' * Sy * W1;

W2 = diagonal(SyTemp);
W_BDA = W1 * W2;
