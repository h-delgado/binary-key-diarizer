function [ logLikelihoodTable ] = getLikelihoodTable( data, gmPool, kbm)
%GETLIKELIHOODTABLE computes the log-likelihood of each feature in DATA
%against all the Gaussians of GMPOOL specified by KBM vector
%

% Inputs:
%   DATA = matrix of feature vectors
%   GMPOOL = pool of Gaussians of the kbm model
%   KBM = vector of the IDs of the actual Gaussians of the KBM
% Output:
%   LOGLIKELIHOODTABLE = NxM matrix storing the log-likelihood of each of
%   the N features given each of th M Gaussians in the KBM

if nargin<3
    error('Wrong number of input arguments')
end

kbmSize = length(kbm);
logLikelihoodTable = zeros(size(data,1), kbmSize); %declare table to store the likelihoods

% fill in the likelihood table
parfor i=1:kbmSize
    logLikelihoodTable(:,i) = log(mvnpdf(data, gmPool{kbm(i)}.m', diag(gmPool{kbm(i)}.cov)'));
end

end
