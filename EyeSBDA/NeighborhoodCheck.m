function ClusterLabels = NeighborhoodCheck(RefPoint,SPPoints,ClusterLabels,Threshold,ClusterNum)

nSPPoints = size(SPPoints);
for i=1:nSPPoints
    if ClusterLabels(i) == 0
        if norm(RefPoint-SPPoints(i,:)) <= Threshold && norm(RefPoint-SPPoints(i,:)) > 0
            ClusterLabels(i) = ClusterNum;
            RefPointNew = SPPoints(i,:);            %% Modified by 5Ryong 2010.3.16 ; RefPoint -> RefPointNew
            ClusterLabels = NeighborhoodCheck(RefPointNew,SPPoints,ClusterLabels,Threshold,ClusterNum);     %% Modified by 5Ryong 2010.3.16 ; RefPoint -> RefPointNew
        end
    end
end

            
            
            
