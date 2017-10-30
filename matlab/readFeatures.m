function [ data ] = readFeatures(path,filename,ext,format)
%READFEATURES   Reads a feature file and store the feature vectors in a
%   matrix
%
% Inputs:
%   PATH = path to the feature file
%   FILENAME = name of the feature file without extension
%   EXT = file extension
%   FORMAT = feature file format. Possible values are
%       'HTK'   HTK feature file  
%       'ASCII' ASCII file where each line is the set of coefficients of
%       the feature vector
% Output:
%   DATA = N*M matrix where N is the number of feature vectors and M is the
%   dimension of the feature vectors
%
% HTK feature files reading is done by the function READHTK from the
% VOICEBOX toolbox for speech processing.

if nargin<4
    error('Wrong number of input arguments')
end

featureFile=strcat(path, filename, ext);

switch format
    case 'HTK'
        [data,~,~,~,~]=readhtk(featureFile);
    case 'ASCII'
        data=dlmread(featureFile);
    otherwise
        error('Format must be HTK or ASCII');
end