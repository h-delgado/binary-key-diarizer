function [ out ] = getSegmentationFile( format, finalSegmentTable, finalClusteringTableResegmentation, showName, filename, outputPath, outputExt )
%GETSEGMENTATIONFILE Creates the output file with the speaker diarization
%solution
%

global frameLength;

if nargin<7
    error('Wrong number of input arguments')
end

numberOfSpeechFeatures = finalSegmentTable(end,3);

solutionVector = zeros(1,numberOfSpeechFeatures);
for i=1:size(finalSegmentTable,1)
    solutionVector(finalSegmentTable(i,2):finalSegmentTable(i,3)) = finalClusteringTableResegmentation(i);
end
    
% matrix for segments
seg = [];

% get segments information
solutionDiff = diff(solutionVector);

first = 1;
for i=1:length(solutionDiff)
    if solutionDiff(i)
        last = i;
        seg1 = (first - 1) * frameLength; % I subtract 1 to compesnate for the processing done in reading SAD file
        seg2 = (last-first+1) * frameLength;
        seg3 = solutionVector(last);
        seg = [seg; seg1 seg2 seg3];
        first = i+1;
    end
end
%last segment
last = length(solutionVector);
seg1 = (first - 1) * frameLength; % I subtract 1 to compesnate for the processing done in reading SAD file
seg2 = (last-first+1) * frameLength;
seg3 = solutionVector(last);

seg = [seg; seg1 seg2 seg3];

S = strcat(outputPath, filename, outputExt);
fileID = fopen(S,'a+');
if fileID<0
    error('Cannot open file %s', S);
end

switch format
    case 'MDTM'
        formatSpec = '%s 1 %f %f speaker NA unknown speaker%d\n';        
    case 'RTTM'
        formatSpec = 'SPEAKER %s 1 %f %f <NA> <NA> speaker%d <NA>\n';
    otherwise
        fprinf('Output file format must be MDTM or RTTM\n');
end

for i=1:size(seg, 1)
    if(seg(i,3))
        fprintf(fileID, formatSpec, showName, seg(i,1), seg(i,2), seg(i,3));
    end
end

fclose(fileID); 
out = 1;
end

