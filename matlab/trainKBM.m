function [ kbm, gmPool ] = trainKBM( data, windowLength, windowRate, kbmSize )
%TRAINKBM Trains a KBM for the current audio signal
%
% Inputs:
%   DATA = matrix of input data feature vectors
%   WINDOWLENGTH = window used for Gaussian computation, in number of
%   frames
%   WINDOWRATE = widow rate for Gaussian computation, in number of frames
%   KBMSIZE = target number of Gaussian components in the KBM
% OutputS:
%   KBM = 1xKBMSIZE vector with the indexes of the Gaussian components (stored in GMPOOL)
%   which conform the KBM
%   GMPOOL = Pool of all Gaussians computed on DATA

if nargin<4
    error('Wrong number of input arguments')
end


%define subMatrix to store feature segments
d = zeros(windowLength,size(data,2));
%Calculate number of gaussian components in the whole gaussian pool
numberOfComponents = floor((size(data,1)-windowLength)/windowRate);
%Create the gaussian pool as a cell array

%Add new array for storing the mvn objects
gmPool = cell(numberOfComponents,1);
likelihoodVector = zeros(numberOfComponents, 1);

muVector = zeros(numberOfComponents,size(data,2));
sigmaVector = zeros(numberOfComponents,size(data,2));

%Train the gaussian components for the KBM

parfor i=1:numberOfComponents
    [ muVector(i,:), sigmaVector(i,:) ] = normfit(data(((i-1)*windowRate)+1:((i-1)*windowRate+windowLength),:));
    gmPool{i} = mvn_new(diag(sigmaVector(i,:)), muVector(i,:));
    likelihoodVector(i) = -sum(log(mvnpdf(data(((i-1)*windowRate)+1:((i-1)*windowRate+windowLength),:), muVector(i,:), sigmaVector(i,:))));
end;

%define the global dissimilarity vector
v_KL2 = inf(numberOfComponents,1);

%Create a binary vector to specify the KBM components: binaryKbm(i) = 1 if
%gaussian i is selected, otherwise, binaryKbm(i) = 0
%binaryKbm = zeros(size(gmPool,1),1);
%Create the kbm itself, which is a vector of kbmSize size, and contains the
%gaussian IDs of the components
kbm = zeros(kbmSize,1);


%as the stored likelihoods are negative, get the minimum likelihood
bestGaussianID = find(likelihoodVector==min(likelihoodVector));

currentGaussianID = bestGaussianID(1);
%binaryKbm(currentGaussianID) = 1;
currentGaussianMean = muVector(currentGaussianID,:);
kbm(1) = currentGaussianID;
v_KL2(currentGaussianID) = -inf;    % Set the value to -inf to avoid problems when selecting the most dissimilar element in v_KL2


%compare the current gaussian with the remaining ones

fprintf('Selecting gaussian ');
for j=2:kbmSize
    fprintf('%d ', j);
    D=pdist2(currentGaussianMean,muVector,'cosine');
    for i=1:numberOfComponents
        v_KL2(i) = min(v_KL2(i), D(i));       
    end
   
    %once all distances are computed, get the position with highest value
    %set this position to 1 in the binary KBM ponemos a 1 en el vector kbm
    %store the gaussian ID in the KBM

    currentGaussianID = find(v_KL2==max(v_KL2));
    currentGaussianMean = muVector(currentGaussianID,:);    
    kbm(j) = currentGaussianID;
    v_KL2(currentGaussianID) = -inf;    %Set the value to -inf to aovid problems when selecting the most dissimilar element in v_KL2
end
end

