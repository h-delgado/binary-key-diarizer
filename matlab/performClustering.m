function [ finalClusteringTable, k ] = performClustering( speechMapping, segmentTable, segmentBKTable, segmentCVTable, Vg, bitsPerSegmentFactor, kbmSize, N_init, initialClustering, metric )
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

if nargin<10
    error('Wrong number of input arguments')
end

numberOfSegments = size(segmentTable,1);
% in this table we store to which cluster each segment belongs. Each column
% represents a different clustering. Each subsequent cluster will have one
% cluster less
clusteringTable = zeros(numberOfSegments, N_init);
% store the clusterings which will be ouput
finalClusteringTable = zeros(numberOfSegments, N_init);
% this vector will store which clusters are active 
activeClusters = ones(1, N_init);
%this table contain the binary key for each cluster
clustersBKTable = zeros(N_init, kbmSize);
clustersCVTable = zeros(N_init, kbmSize);

%Calculate binary keys for each initial cluster

parfor i=1:N_init
         if activeClusters(1,i)
             %prepare the features to binarize
             segmentsToBinarize = find(initialClustering==i);
             M = [];
             for l=1:size(segmentsToBinarize, 1)        
                M = [M segmentTable(segmentsToBinarize(l),2):segmentTable(segmentsToBinarize(l),3)];
             end 
             
             [clustersBKTable(i,:), clustersCVTable(i,:)] = binarizeFeatures(kbmSize, Vg(speechMapping(M),:), bitsPerSegmentFactor);
         else
             clustersBKTable(i,:) = zeros(1, kbmSize);
             clustersCVTable(i,:) = -inf(1, kbmSize);
         end
     end

%%%%%%% Here the clustering algorithm begins. Steps are:
%%%%%%% 1. Reassign all data among all existing signatures and retrain them
%%%%%%% using the new clustering
%%%%%%% 2. Save the resulting clustering solution
%%%%%%% 3. Compare all signatures with each other and merge those two with
%%%%%%% highest similarity, creating a new signature for the resulting
%%%%%%% cluster
%%%%%%% 4. Back to 1 if #clusters > 1



for k=1:N_init
    
    %%%%%%% 1. Data reassignment. Calculate the similarity between the current
    %%%%%%% segment with all clusters and assign it to the one which maximizes
    %%%%%%% the similarity. Finally re-calculate binaryKeys for all cluster

    %declare a vector to store the partial similarities between current segment
    %and all clusters
    
    %before doing anything, check if there are remaining clusters
    %if there is only one active cluster, break
    
    if(sum(activeClusters) == 1)
       break; 
    end

    %segmentToClusterSimilarityVector = zeros (numberOfSegments, N_init);
    
    clustersStillActive = zeros (1, N_init);       
         
    segmentToClusterSimilarityMatrix = binaryKeySimilarity_pdist2(metric, segmentBKTable, segmentCVTable, clustersBKTable, clustersCVTable);
    [~, assignment] = max(segmentToClusterSimilarityMatrix, [],2);
    clusteringTable(:,k) = assignment;
    finalClusteringTable(:,k) = assignment;
    
    clustersStillActive(unique(assignment)) = 1;
      
    %%%%%% update all binaryKeys for all new clusters

       activeClusters = clustersStillActive;

    
     parfor i=1:N_init
         if activeClusters(1,i)
             %prepare the features to binarize
             segmentsToBinarize = find(clusteringTable(:,k)==i);
             M = [];
             for l=1:size(segmentsToBinarize, 1)        
                %M = [M segmentTable(segmentsToBinarize(l),1):segmentTable(segmentsToBinarize(l),4)];
                M = [M segmentTable(segmentsToBinarize(l),2):segmentTable(segmentsToBinarize(l),3)];
             end 
             
             [clustersBKTable(i,:), clustersCVTable(i,:)] = binarizeFeatures(kbmSize, Vg(speechMapping(M),:), bitsPerSegmentFactor);
         else
             clustersBKTable(i,:) = zeros(1, kbmSize);
             clustersCVTable(i,:) = -inf(1, kbmSize);
         end
     end
    
    

    %%%%%%% 2. Compare all signatures with each other and merge those two with
    %%%%%%% highest similarity, creating a new signature for the resulting


    clusterSimilarityMatrix = binaryKeySimilarity_pdist(metric,clustersBKTable,clustersCVTable);
    clusterSimilarityMatrix = clusterSimilarityMatrix - eye(size(clusterSimilarityMatrix));

    
    [value, location] = max(clusterSimilarityMatrix(:));
    [R,C] = ind2sub(size(clusterSimilarityMatrix),location);
    
    %%% Then we merge clusters R and C, i.e. C=R
    fprintf('merging clusters %d and %d with a similarity score of %f\n', R, C, value);

    %deactivate cluster with highest ID
    activeClusters(C) = 0;

    %%%%%%% 3. Save the resulting clustering and go back to 1 if the number of
    %%%%%%% clusters is > 1
    
    mergingClusterIndices = find(clusteringTable(:,k)==C);
    %update clustering table
    clusteringTable(mergingClusterIndices,k) = R;
    %remove binaryKey for removed cluster
    clustersBKTable(C,:) = zeros(1, kbmSize); 
    clustersCVTable(C,:) = -inf(1, kbmSize); 
    
    %prepare the vector with the indices of the features of new cluster and
    %then binarize
    
    segmentsToBinarize = find(clusteringTable(:,k)==R);
    M = [];
    for l=1:size(segmentsToBinarize, 1)        
        %M = [M segmentTable(segmentsToBinarize(l),1):segmentTable(segmentsToBinarize(l),4)];
        M = [M segmentTable(segmentsToBinarize(l),2):segmentTable(segmentsToBinarize(l),3)];
    end  
            
    %updating binaryKey for new cluster
    [clustersBKTable(R,:), clustersCVTable(R,:)] = binarizeFeatures(kbmSize, Vg(speechMapping(M),:), bitsPerSegmentFactor);   
    
end

fprintf('done\n');



end

