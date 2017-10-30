function [evaluatedFramesMask] = readSADfile( path,filename,ext,nFeatures, format)
%READSADLABELS Reads a file with speech segments and returns a mask where the positions set to 1
%indicate the frames that must be considered
%
% Inputs:
%   PATH = path to the feature file
%   FILENAME = name of the SAD file without extension
%   EXT = file extension
%   NFEATURES = number of total feature vectors in the original
%   feature file
%   FORMAT = format of the SAD file. It can take the values:
%       'LBL'   each segmet follows the format "initTimeInSeconds endTimeInSeconds label"
%       'RTTM'  for RTTM file format
%       'MDTM'  for MDTM file format
% Output:
%   EVALUATEDFRAMESMASK = 1xNUMBEROFFEATURES binary vector where
%   positions set to 1 indicate the feature vectors to be considered


%Asumiré que el archivo sólo contendrá los segmentos de speech, ya que es
%lo más frecuente

if nargin<5
    error('Wrong number of input arguments')
end

global frameLength;
sadFile = strcat(path,filename,ext);

evaluatedFramesMask=zeros(1, nFeatures);

fileID = fopen(sadFile,'r');
if fileID<0
    error('Error reading file %s', sadFile)
end

switch format
    case 'LBL'
        formatSpec = '%f %f %s';
        C = textscan(fileID, formatSpec);
        initTime = round(cell2mat(C(:,1))/frameLength) + 1;
        endTime = round(cell2mat(C(:,2))/frameLength) - 1;        
        
    case 'RTTM'
        formatSpec = 'SPEAKER %s 1 %f %f <NA> <NA> %s <NA> <NA>\n';
        C = textscan(fileID, formatSpec);
        %indx = find(C(4)(:),strcmp(C(4)(:),'sp'))    
        %indx = find(strcmp(C{4},'sp')==1);
        indx = 1:length(C{4});
        initTime = cell2mat(C(:,2));
        durTime = cell2mat(C(:,3));
        
        initTime = round(initTime(indx)/frameLength)+1;
        durTime = round(durTime(indx)/frameLength);        
        endTime = initTime + durTime - 1;
    case 'MDTM'
        formatSpec = '%s 1 %f %f speaker NA unknown speaker%d\n';
        C = textscan(fileID, formatSpec);
        initTime = cell2mat(C(:,2));
        durTime = cell2mat(C(:,3));
        
        initTime = round(initTime(indx)/frameLength)+1;
        durTime = round(durTime(indx)/frameLength);        
        endTime = initTime + durTime - 1;
    otherwise
        error('Format must be LBL, RTTM or MDTM');
end

fclose(fileID);

% create table of evaluated segments: First column is the initial time
% and second column is the end time

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