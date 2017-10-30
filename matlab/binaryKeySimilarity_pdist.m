function [ S ] = binaryKeySimilarity_pdist( metric, bkT1, cvT1 )
%BINARYKEYSIMILARITY_pdist returns the matrix of pair-wise similarity
%between all member pairs of the binary key or cumulative vector set
%
% Input:
%   METRIC = similarity metric. Possible values are:
%       'cosine'
%       'chisq'
%       'jaccard'
%   BKT1 = set of binary keys
%   CVT1 = set of cumulative vectors

if nargin<3
    error('Wrong number of input arguments')
end

switch metric
    case 'cosine'
        S = 1 - pdist(cvT1, 'cosine');
        S = squareform(S);
    case 'chisquared'
        S = 1 - pdist22(cvT1, cvT1, 'chisq');
    case 'jaccard'
        S = 1 - pdist(bkT1, 'jaccard');
        S = squareform(S);
    otherwise
        error('Metric must be cosine, chisq or jaccard')
end    
end

