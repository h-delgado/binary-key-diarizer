function [ initialClustering ] = flatInitializeClustering( N_init, nSegments )
%INITIALIZECLUSTERING returns a NSEGMENTSx1 matrix defining a partition of
%the segments into N_INIT clusters
%
% Inputs:
%   N_INIT = number of cluster
%   NSEGMENTS = number of segments
%
% Output:
%   INITIALCLUSTERING = NSEGMETNSx1 matrix defining a data partition by
%   assigning an integer cluster ID

if nargin<2
    error('Wrong number of input arguments')
end

initialClustering = zeros(nSegments,1);
nSegmentsPerCluster = floor(nSegments/N_init);

for i=1:N_init
    initialClustering((i-1)*nSegmentsPerCluster+1:i*nSegmentsPerCluster) = i;
end

initialClustering(i*nSegmentsPerCluster+1:nSegments) = N_init;

end


