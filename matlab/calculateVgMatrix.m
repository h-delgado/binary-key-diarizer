function [ Vg ] = calculateVgMatrix( logLikelihoodTable, N_g )
%GETVGMATRIX returns the matrix of the indixes of the N_G highest elements
%for each row
%
% Inputs:
%   LOGLIKELIHOODTABLE = matrix of log-likelihoods calculated by
%   'getLikelihoodTable' function
%   N_G = Number of top positions to select in each row
% Output:
%   VG = NxN_G matrix containing the indices of the top N_G positions of
%   each row in LOGLIKELIHOODTABLE

if nargin<2
    error('Wrong number of input arguments')
end

M = size(logLikelihoodTable, 1);
Vg = zeros (M, N_g);


parfor i=1:M
    [~,sortIndex] = sort(logLikelihoodTable(i,:),'descend');
    Vg(i,:) = sortIndex(1:N_g);
end

end

