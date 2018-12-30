clear all;
close all;
clc;

nSamps = 100;

Pos1 = randn(nSamps,1)*1;
Pos2 = randn(nSamps,1)*.5;
Pos = [ Pos1 Pos2 ];

theta = 45*180/pi;
R = [ cos(theta) -sin(theta) ; sin(theta) cos(theta) ];
Pos = R * Pos';
Pos = Pos';
% Pos(:,1) = Pos(:,1) - 3*ones(nSamps,1);

Neg1 = randn(nSamps,1)*2;
Neg2 = randn(nSamps,1)*5;
Neg = [ Neg1 Neg2 ];

Neg = R * Neg';
Neg = Neg';
% Neg(:,1) = Neg(:,1) + 3*ones(nSamps,1);

Samps = [ Pos ; Neg ];
MeanSamps = mean(Samps);
MeanPos = mean(Pos);
MeanNeg = mean(Neg);
C = zeros(2,2);
for i=1:size(Samps,1)
    C = C + (Samps(i,:) - MeanSamps)'*(Samps(i,:) - MeanSamps);
end
C = C / size(Samps,1);
WLAC = (MeanPos-MeanNeg)/C;
WLAC = WLAC / norm(WLAC);

x = -15:0.1:15;
y_lac = WLAC(2)/WLAC(1) * x;
TrainClass = [ones(nSamps,1) ; zeros(nSamps,1)];
Wbda = BDA(Pos,Neg,MeanPos);
y_bda = Wbda(2)/Wbda(1) * x;

plot(Pos(:,1),Pos(:,2),'bo',Neg(:,1),Neg(:,2),'rx',x,y_lac,'k:',x,y_bda,'k-');
axis([-15 15 -15 15]);
grid on;
legend('Positive','Negative','LAC','BDA');
