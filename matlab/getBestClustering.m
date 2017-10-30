function [ bestClusteringID ] = getBestClustering(metric, bkT, cvT, clusteringTable, n )
%GETBESTCLUSTERING returns the ID of the output clustering from those
%clusterings generated in the AHC stage
%
% Inputs:
%   METRIC = distance metric used. Possible values are
%       'cosine'
%       'chisq'
%   BKT = Table of binary keys of all input segments
%   CVT = Table of cumulative vectors of all input segments
%   CLUSTERINGTABLE = Table of all partial clustering solutions returned by
%   'performClustering' function
%   N = id of the last iteration returned by 'performClustering' function
%
% Output:
%   BESTCLUSTERINGID = ID of the selected clustering solution

if nargin<5
    error('Wrong number of input arguments')
end

wss = zeros(1, n);
overallMean = mean(cvT,1);
%wss(n) = sum(pdist2(overallMean, X,'cosine'))/length(X);

switch metric
    case 'cosine'
        distances = pdist2(overallMean, cvT,'cosine');
    case 'chisquared'
        distances = pdist22(overallMean, cvT,'chisq');
    case 'jaccard'
        nBitsTo1 = sum(bkT(1,:));
        [~,indices] = sort(overallMean,'descend');
        overallMean = zeros(1,size(bkT,2));
        overallMean(1,indices(1:nBitsTo1)) = 1;
        distances = pdist2(overallMean, bkT,'jaccard');
    otherwise
        error('Metric for clustering selection must be cosine or chisq')
end


distances2 = distances.^2; 
wss(n) = sum(distances2);

for i=1:n-1
    T = clusteringTable(:,i);
    clusterIDs = unique(T);
    vars = zeros(length(clusterIDs),1);
    
    for j=1:length(clusterIDs)
        meanVector = mean(cvT(find(T==clusterIDs(j)),:),1);
        switch metric
            case 'cosine'
                distances = pdist2( meanVector, cvT(find(T==clusterIDs(j)), :), 'cosine' );
            case 'chisquared'
                distances = pdist22( meanVector, cvT(find(T==clusterIDs(j)), :), 'chisq' );
            case 'jaccard'
                [~,indices] = sort(meanVector,'descend');
                meanVector = zeros(1,size(bkT,2));
                meanVector(1,indices(1:nBitsTo1)) = 1;
                distances = pdist2(meanVector, bkT(find(T==clusterIDs(j)), :),'jaccard');
        end               
        distances2 = distances.^2;
        vars(j) = sum(distances2);
    end
    wss(i) = sum(vars);
end

nPoints = length(wss);
allCoord = [1:nPoints;wss]';
firstPoint = allCoord(1,:);
allCoord = allCoord(find(allCoord(:,2)==min(allCoord(:,2))):nPoints,:);
nPoints=size(allCoord,1);
lineVec = allCoord(end,:) - firstPoint;
lineVecN = lineVec / sqrt(sum(lineVec.^2));
vecFromFirst = bsxfun(@minus, allCoord, firstPoint);
scalarProduct = dot(vecFromFirst, repmat(lineVecN,nPoints,1), 2);
vecFromFirstParallel = scalarProduct * lineVecN;
vecToLine = vecFromFirst - vecFromFirstParallel;
distToLine = sqrt(sum(vecToLine.^2,2));
%figure('Name','distance from curve to line'), plot(distToLine);
bestClusteringID = allCoord(find(distToLine==max(distToLine)));
bestClusteringID = bestClusteringID(1);

end

