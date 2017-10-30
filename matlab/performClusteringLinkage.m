function [ clusteringTable, k ] = performClusteringLinkage(segmentBKTable, segmentCVTable, N_init, metric )
%PERFORMCLUSTERING performs agglomerative clustering based on iterative
%data re-assignment and model re-trining
%

% Inputs:
%   SEGMENTTABLE = matrix of temporal segments to be clustered, returned by
%   'getSegmentTable' function
%   SEGMENTBKTABLE = matrix of binary keys extracted from all segments of
%   SEGMENTTABLE, returned by 'getSegmentBKs' function
%   SEGMENTCVTABLE = matrix of cumulative vectors extracted from all
%   segments of SEGMENTTABLE, returned by 'getSegmentBKs' function
%   VG = matrix of the top gaussians per frame, returend by 'getVgMatrix'
%   function
%   BITSPERSEGMENTFACTOR = proportion of bits set to 1 in the binary keys
%   KBMSIZE = size of the KBM model
%   N_INIT = numer of initial clusters
%   INITIALCLUSTERING = Vector defining the initial clustering, returend by
%   'flatInitializeClustering' fuction
%   METRIC = distance metric for comparing binary keys or cumulative
%   vectors. Possible values:
%       'cosine'
%       'chisq'
%       'jaccard'
% OutputS:
%   FINALCLUSTERINGTABLE = nSEGMENTSxN_INIT matrix. Each column contains
%   the clustering obtained at iteration i. The number of cluster of column
%   i is N_INIT-i+1
%   K = ID of the last iteration (necessary if a clustering with one single
%   cluster is obtained before reaching the number of iterations N_INIT

if nargin<4
    error('Wrong number of input arguments')
end

clusteringTable = zeros(size(segmentCVTable,1), N_init);
Z = linkage(segmentCVTable,'average',metric);

for i=N_init:-1:1
    clusteringTable(:,N_init-i+1) = cluster(Z,'maxclust',i);
end
k = N_init;
fprintf('done\n');



end

