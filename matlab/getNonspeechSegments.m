function [ nonspeechSegments ] = getNonspeechSegments( mask,nFeatures )
%GETNONSPEECHSEGMENTS builds a matrix of temporal segments of nonspeech
%content from the input mask of nonspeech frames
%
% Inputs:
%   MASK = 1*NFEATURES vector where positions set to 1 indicate frame
%   indices to be discarded
%   NFFEATURES = number of total feature vectors in the original
%   feature file
% Output:
%   NONSPEECHSEGMENTS = 2xN matrix on N segments where each row inidicate
%   a temporal segment in the form of "initFrame endFrame". The segment
%   are measured in frames

if nargin<2
    error('Wrong number of input arguments')
end

nonspeechSegmentsInit = find(diff(mask)==1)'+1;
nonspeechSegmentsEnd = find(diff(mask)==-1)';

if(isempty(nonspeechSegmentsInit) && isempty(nonspeechSegmentsEnd))
    nonspeechSegments = [];
elseif isempty(nonspeechSegmentsInit) && ~isempty(nonspeechSegmentsEnd)
    nonspeechSegmentsInit = 1;
elseif ~isempty(nonspeechSegmentsInit) && isempty(nonspeechSegmentsEnd)
    nonspeechSegmentsEnd = nFeatures;
else
    if(length(nonspeechSegmentsInit)==length(nonspeechSegmentsEnd))
        if(nonspeechSegmentsEnd(1)<nonspeechSegmentsInit(1))
            nonspeechSegmentsInit = [1; nonspeechSegmentsInit];
            nonspeechSegmentsEnd = [nonspeechSegmentsEnd; nFeatures];
        end
    else
        if(nonspeechSegmentsEnd(1)<nonspeechSegmentsInit(1))
            nonspeechSegmentsInit = [1; nonspeechSegmentsInit];
        else
            nonspeechSegmentsEnd = [nonspeechSegmentsEnd; nFeatures];
        end
    end
end
nonspeechSegments = [nonspeechSegmentsInit nonspeechSegmentsEnd];
end

