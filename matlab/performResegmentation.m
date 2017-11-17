function [finalClusteringTableResegmentation,finalSegmentTable] = performResegmentation(data, speechMapping,mask,finalClusteringTable,segmentTable,modelSize,nbIter,smoothWin,numberOfSpeechFeatures);

% obtain the speech segments
changePoints = diff(mask);

segBeg(:,1) = find(changePoints==1)+1;
segEnd(:,1) = find(changePoints==-1);

% if audio start with speech
if mask(1)==1
    segBeg = [1;segBeg];    
end
% if audio ends with speech
if mask(end)==1
    segEnd = [segEnd;length(mask)];
end

nSegs = length(segBeg);

% get speaker's training data for GMM training
speakerIDs = unique(finalClusteringTable);
trainingData = cell(length(speakerIDs),1);
for i=1:length(speakerIDs)
    spkID = speakerIDs(i);
    speakerFeatureIndxs = [];
    idxs = find(finalClusteringTable==spkID);
    for j=1:length(idxs)
        speakerFeatureIndxs = [speakerFeatureIndxs segmentTable(idxs(j),2):segmentTable(idxs(j),3)];
    end
    trainingData{i} = data(speechMapping(speakerFeatureIndxs),:);
end

% training the models
spkModels = cell(length(speakerIDs),1);
for i=1:length(speakerIDs)
    rng default     % initialize random number generation (used by vlFeat to randomly initialize Gaussians)
    
    %initialize GMM    
    msize = min(modelSize,size(trainingData{i},1));        
    initMeans = trainingData{i}(randi([1 size(trainingData{i},1)],1,msize),:);
    initCovariances = repmat(diag(cov(trainingData{i})),1,msize)';
    initPriors = ones(msize,1)/msize;
    
    [spkModels{i}.means, spkModels{i}.covs, spkModels{i}.w] = vl_gmm(trainingData{i}', msize, 'MaxNumIterations',nbIter, 'initialization','custom', 'InitMeans',initMeans', 'InitCovariances',initCovariances', 'InitPriors',initPriors);
end

    resegmentation = zeros(1,numberOfSpeechFeatures);
    llkMatrix = zeros(length(speakerIDs),numberOfSpeechFeatures);
    
    for i=1:length(speakerIDs)
        llkMatrix(i,:) = compute_llk(data',spkModels{i}.means, spkModels{i}.covs, spkModels{i}.w);
    end
    
    
    %smooth the likelihoods in windows of size smoothWin size;
    for i = 1:length(speakerIDs)
        for j=1:nSegs
            llkMatrix_smoothed(i,speechMapping(segBeg(j)):speechMapping(segEnd(j))) = smooth(llkMatrix(i,speechMapping(segBeg(j)):speechMapping(segEnd(j))),smoothWin);        
        end
    end
    
    
    
    [~,segOut] = (max(llkMatrix_smoothed));
    segOut = segOut';
    segChangePoints = diff(segOut);
    changes = find(segChangePoints~=0); % changes of speaker in the speech matrix
    % but we need also to specify where in the reduced matric there are
    % changes because of SAD
    relSegEnds = speechMapping(segEnd);
    relSegEnds(end) = [];
    changes = sort(unique([changes; relSegEnds']));
   
    %create the new segment and clustering tables
    currentPoint = 1;
    finalSegmentTable=[];
    finalClusteringTableResegmentation = [];
    for i=1:length(changes)
        finalSegmentTable = [finalSegmentTable; find(speechMapping==currentPoint) find(speechMapping==currentPoint) find(speechMapping==changes(i)) find(speechMapping==changes(i))];
        finalClusteringTableResegmentation = [finalClusteringTableResegmentation; segOut(changes(i)) ];
        currentPoint = changes(i)+1;
    end
    finalSegmentTable = [finalSegmentTable; find(speechMapping==currentPoint) find(speechMapping==currentPoint) find(speechMapping==numberOfSpeechFeatures) find(speechMapping==numberOfSpeechFeatures)];
    finalClusteringTableResegmentation = [finalClusteringTableResegmentation; segOut(changes(i)+1) ];