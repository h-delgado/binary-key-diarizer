function [segmentBKTable, segmentCVTable ] = getSegmentBKs(segmentTable, kbmSize, Vg, bitsPerSegmentFactor, speechMapping)
%GETSEGMENTBKS converts each of the segments in SEGMENTTABLE into a binary key
%and/or cumulative vector.
%
% Inputs:
%   SEGMENTTABLE = matrix containing temporal segments returned by 'getSegmentTable'
%   function
%   KBMSIZE = number of components in the kbm model
%   VG = matrix of the top components per frame returned by 'getVgMatrix' function
%   BITSPERSEGMENTFACTOR = proportion of bits that will be set to 1 in the
%   binary keys
% Output:
%   SEGMENTBKTABLE = NxKBMSIZE matrix containing N binary keys for each N
%   segments in SEGMENTTABLE
%   SEGMENTCVTABLE = NxKBMSIZE matrix containing N cumulative vectors for each N
%   segments in SEGMENTTABLE


if nargin<5
    error('Wrong number of input arguments')
end

numberOfSegments = size(segmentTable,1);
segmentBKTable = zeros(numberOfSegments,kbmSize);
segmentCVTable = zeros(numberOfSegments,kbmSize);


for i=1:numberOfSegments

    % conform the segment according to the segmentTable matrix
       
    beginingIndex = segmentTable(i,1);
    endIndex = segmentTable(i,4);
      
    %store indices of features of the segment
    A = speechMapping(beginingIndex):speechMapping(endIndex);
    %get the binary key for the segment    
    [ segmentBKTable(i,:), segmentCVTable(i,:) ]  = binarizeFeatures(kbmSize, Vg(A,:), bitsPerSegmentFactor);
end
fprintf('done\n');

end

