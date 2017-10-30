function [ Vg ] = getVgMatrix( data, gmPool, kbm, topGaussiansPerFrame )
%GETVGMATRIX returns the IDs of the top TOPGAUSSIANSPERFRAME Gaussians of the kbm for each input feature
%vector in DATA
%
% Inputs:
%   DATA = matrix of feature vectors
%   GMPOOL = pool of Gaussian components of the kbm model
%   KBM = vector containing the IDs of the components of GMPOOL that
%   actually conform the kbm model
%   TOPGAUSSIANSPERFRAME = number of the desired top Gaussians to be
%   calculated for each feature in DATA
% Output:
%   VG = NxTOPGAUSSIANSPERFRAME matrix containing the TOPGAUSSIANSPERFRAME
%   IDs of the TOPGAUSSIANSPERFRAME components for each feature one of the
%   N features in DATA, sorted by degree of importance

if nargin<4
    error('Wrong number of input arguments')
end

fprintf('Calculating log-likelihood table... ');
logLikelihoodTable = getLikelihoodTable( data, gmPool, kbm );
fprintf('done\n');

fprintf('Calculating Vg matrix... ');
Vg = calculateVgMatrix( logLikelihoodTable, topGaussiansPerFrame );
fprintf('done\n');

end

