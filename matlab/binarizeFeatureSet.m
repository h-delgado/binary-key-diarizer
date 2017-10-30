function [ binaryKey, v_f ] = binarizeFeatureSet( A, binaryKeySize, Vg, bitsPerSegmentFactor)
%BINARIZEMATRIX Extracts a binary key and a cumulative vector from the the
%rows of VG specified by vector A
%
% Inputs:
%   A = 2xM matrix of M nonspeech segments calculated by
%   BINARYKEYSIZE = binary key size
%   VG = matrix of top Gaussians per frame, returned by 'getVgMatrix' function
%   BITSPERSEGMENTFACTOR = Proportion of positions of the binary key which
%   will be set to 1
% Output:
%   BINARYKEY = 1xBINARYKEYSIZE binary key
%   V_F = 1xBINARYKEYSIZE cumulative vector

if nargin<4
    error('Wrong number of input arguments')
end

numberOfElementsBinaryKey = floor(binaryKeySize * bitsPerSegmentFactor);

%Declare binaryKey
binaryKey = zeros (1, binaryKeySize);

%Declare cumulative vector v_f
v_f = zeros (1, binaryKeySize);

for i=1:size(A,2)
        v_f(Vg(A(i),:)) = v_f(Vg(A(i),:)) + 1;
end

[sortedValues,sortIndex] = sort(v_f(1,:),'descend');
binaryKey(1,sortIndex(1:numberOfElementsBinaryKey)) = 1;
%normalize v_f
v_f = v_f/sum(v_f);

end