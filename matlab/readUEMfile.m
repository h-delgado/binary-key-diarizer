function [ evaluatedFramesMask ] = readUEMfile( path,filename,ext, nFeatures )
%READUEM Reads a UEM file and returns a mask where the positions set to 1
%indicate the frames that must be considered
%
% Inputs:
%   PATH = path to the feature file
%   FILENAME = name of the UEM file without extension
%   EXT = file extension
%   NFEATURES = number of total feature vectors in the original
%   feature file
% Output:
%   EVALUATEDFRAMESMASK = 1xNUMBEROFFEATURES binary vector where
%   positions set to 1 indicate the feature vectors to be considered

if nargin<4
    error('Wrong number of input arguments')
end

global frameLength;
uemFile = strcat(path,filename,ext);

evaluatedFramesMask=zeros(1, nFeatures);

fileID = fopen(uemFile,'r');
C = textscan(fileID, '%s %d %f %f');
fclose(fileID);

initTime = cell2mat(C(:,3));
endTime = cell2mat(C(:,4));
%convert to seconds to frame index
if isempty(initTime)
    evaluatedFramesMask = ones(1, nFeatures);
else
    initTime = floor(initTime/frameLength);
    endTime = floor(endTime/frameLength)-1;
    
    for i=1:size(initTime,1)
        if initTime(i)==0
            it = 1;
        else
            it = initTime(i);
        end
        
        if endTime(i)>nFeatures
            et = nFeatures;
        else
            et = endTime(i);
        end
        evaluatedFramesMask(it:et)=1;
    end
end
end
