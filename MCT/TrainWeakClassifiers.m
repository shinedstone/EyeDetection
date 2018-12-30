function [MinLocation,MinError,TablePos,TableNeg] = TrainWeakClassifiers(MCTPos,MCTNeg,WeightPos,WeightNeg)

% Training MCT-based weak classifiers
% Written by Jiyong Oh (11. July. 2011)

nMCTValues = 2^9;

[WinY,WinX,nPos] = size(MCTPos);
nNeg = size(MCTNeg,3);

nLocations = WinY*WinX;
Locations = zeros(nLocations,2);
Index = 0;
for i=1:WinY
    for j=1:WinX
        Index = Index + 1;
        Locations(Index,1) = i;
        Locations(Index,2) = j;
    end
end

t0 = clock;
G_Pos = zeros(nLocations,nMCTValues);
G_Neg = zeros(nLocations,nMCTValues);
Errors = zeros(nLocations,1);
Index = 0;
for i=1:WinY
    for j=1:WinX
        Index = Index + 1;
        for k=0:nMCTValues-1
            for p=1:nPos
                if MCTPos(i,j,p)==k
                    G_Pos(Index,k+1) = G_Pos(Index,k+1) + WeightPos(p);
                end
            end
            for p=1:nNeg
                if MCTNeg(i,j,p)==k
                    G_Neg(Index,k+1) = G_Neg(Index,k+1) + WeightNeg(p);
                end                
            end
        end
        for k=1:nMCTValues
            Errors(Index) = Errors(Index) + min(G_Pos(Index,k),G_Neg(Index,k));
        end
        
    end
end
[MinError,MinIndex] = min(Errors);
MinLocation = Locations(MinIndex,:);
t1 = etime(clock,t0);
display(['e-Time for training weak-classifiers : ' num2str(t1)]);
TablePos = G_Pos(MinIndex,:);
TableNeg = G_Neg(MinIndex,:);

