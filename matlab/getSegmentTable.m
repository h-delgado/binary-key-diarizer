function [ segmentTable ] = getSegmentTable( mask, wLength, wIncr, wShift )
%GETSEGMENTTABLE builds a table of speech temporal segments for the intput
%feature files after removing the frames of nonspeech content.

% The resulting segments will be of WLENGTH length plus WINCR after and
% begfore, being the resulting length equal to WLENGTH + 2*WINCR. The
% segments are calculated at the rate specified by WSHIFT. If a given
% segment is interrupted by the occurrence of a nonspeech region, then the
% segment end boundary is adjusted to such change point.
%
% Inputs:
%   NONSPEECHSEGMENTS = 2xM matrix of M nonspeech segments calculated by
%   'getNonspeechSegments' function
%   WLENGTH = segment length in number of frames
%   WINCR = window increment that is added at the begining and end of the
%   segment (for defining overlapping segments), in number of frames
%   WSHIFT = rate used for calculating segments, in number of frames
% Output:
%   SEGMENTTABLE = 4xN matrix on N segments. First column indicates segment
%   beginning considering the increment. Second column indicates the
%   segment actual beginning. Third column indicates the segment actual
%   end. Forth column indicates segment end considering the increment.
%   Everything is measured in number of frames.

if nargin<4
    error('Wrong number of input arguments')
end

changePoints = diff(mask);

segBeg(:,1) = find(changePoints==1)+1;
segEnd(:,1) = find(changePoints==-1);

% if audio start with speech
if mask(1)==1
    segBeg(:,1) = 1:segBeg(:,1);    
end
% if audio ends with speech
if mask(end)==1
    segEnd(:,1) = 1:segEnd(:,1);
end

nSegs = length(segBeg);
segmentTable = [];

for i=1:nSegs
    begs = (segBeg(i):wShift:segEnd(i))';
    bbegs = max(segBeg(i),begs-wIncr);
    ends = min(begs+wLength-1,segEnd(i));
    eends = min(ends+wIncr,segEnd(i));    
    segmentTable = [segmentTable; [bbegs begs ends eends]];
end

end

