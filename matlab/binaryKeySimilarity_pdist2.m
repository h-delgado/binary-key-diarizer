function [ S ] = binaryKeySimilarity_pdist2( metric, bkT1, cvT1, bkT2, cvT2 )
%BINARYKEYSIMILARITY_pdist2 Returns the matrix of pair-wise similarity
%between two sets of binary keys or cumulative vectors
%
% Input:
%   METRIC = similarity metric. Possible values are:
%       'cosine'
%       'chisq'
%       'jaccard'
%   BKT1 = first set of binary keys
%   CVT1 = first set of cumulative vectors
%   BKT2 = second set of binary keys
%   CVT2 = second set of cumulative vectors
if nargin<5
    error('Wrong number of input arguments')
end

switch metric
    case 'cosine'
        S = 1 - pdist2(cvT1,cvT2, 'cosine');
    case 'chisquared'
        S = 1 - pdist22(cvT1,cvT2, 'chisq');
    case 'jaccard'
        S = 1 - pdist2(bkT1,bkT2, 'jaccard');  
    otherwise
        error('Metric must be cosine, chisq or jaccard')
end
end

