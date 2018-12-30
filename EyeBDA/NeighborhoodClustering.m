function [ClusterLabels,CLabels,nPointPerCluster] = NeighborhoodClustering(SPPoints,Threshold)

nSPPoints = size(SPPoints,1);

ClusterLabels = zeros(nSPPoints,1);
ClusterNum = 0;
ClusterFlag = 0;
while ClusterFlag == 0
    ClusterNum = ClusterNum + 1;
    
    RefFlag = 0;
    idx = 0;
    while RefFlag == 0 && idx < nSPPoints
        idx = idx + 1;
        if ClusterLabels(idx) == 0
            RefFlag = 1;
        end
    end
    RefPoint = SPPoints(idx,:);
    ClusterLabels(idx) = ClusterNum;
    
    ClusterLabels = NeighborhoodCheck(RefPoint,SPPoints,ClusterLabels,Threshold,ClusterNum);
            
    [nCluster,CLabels,nPointPerCluster] = class_information(ClusterLabels);
    if CLabels(1) ~= 0
        ClusterFlag = 1;
    end        
end
