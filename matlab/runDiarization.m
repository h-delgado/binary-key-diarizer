%start timer
time = tic;

%Prompt configuration parameters
printParameters;

%read feature file
data=readFeatures(featuresPath,showName{1},featuresExt,format);
nFeatures = size(data,1);

fprintf('\nshowName\t\t%s\n',showName{1});
fprintf('Initial number of features\t%d\n',nFeatures);

%read the SAD and UEM files

maskUEM = readUEMfile(UEMPath, showName{1}, UEMExt, nFeatures);
maskSAD = readSADfile(SADPath, showName{1}, SADExt, nFeatures, SADformat);
% in the masks, 1 = speech, 0 = nonspeech
%do merging of the two masks containing the frames to consider
mask=maskUEM&maskSAD;

%if the SAD or UEM segments exceed the real size of audio, we trim the mask
mask = mask(1:nFeatures);
nSpeechFeatures=sum(mask);

speechMapping = zeros(1,nFeatures);
speechMapping(mask) = 1:1:nSpeechFeatures;

%apply mask to data
data=data(mask,:);

% All the input features are grouped into equal-sized segments. The
% variables for defining the segments are "clusteringWindowLength",
% "clusteringWindowIncrement" and "clusteringWindowRate". Those segments will
% then be clustered in the Aglomerative clustering stage

%segment table is a Nx4 matrix, where N is the number of segments. The 4
%columns represent the extended begining, begining, end and extended end of
%the segments. The extended beginning is obtained by extending the
%beginning "clusteringWindowIncrement" frames before. The extended end is
%obtained similarly by extending the end of the segment
%"clusteringWindowIncrement" frames after
%the actual length of a segment is normally defined by variable
%"clusteringWindowLength". However, the segment can be shortened if a speech
%bondary from the SAD labels is detected.

segmentTable = getSegmentTable(mask, clusteringWindowLength, clusteringWindowIncrement, clusteringWindowRate);
numberOfSegments = size(segmentTable,1);

%remove the features corresponding to not evaluated audio from SAD and UEM files
%data=allData;
%data(mask==1,:)=[];

fprintf('Number of speech features\t%d\n',nSpeechFeatures);

%accumulate all speech frames for calculating the global real-time factor
totalFramesSpeech = totalFramesSpeech + nSpeechFeatures;

%create the KBM
fprintf('\nTraining the KBM... ');

%set the window rate in order to obtain "minimumNumberOfInitialGaussians" gaussians
if floor((nSpeechFeatures-windowLength)/minimumNumberOfInitialGaussians) < maximumKBMWindowRate
    windowRate = floor((nSpeechFeatures-windowLength)/minimumNumberOfInitialGaussians);
else
    windowRate = maximumKBMWindowRate;
end

poolSize = floor((nSpeechFeatures-windowLength)/windowRate);
if useRelativeKBMsize
    kbmSize = floor(poolSize*relKBMsize);
end

fprintf('\nTraining pool of %d gaussians with a rate of %d frames\n',poolSize,windowRate);
[kbm, gmPool] = trainKBM( data, windowLength, windowRate, kbmSize );
fprintf('\nSelected %d gaussians from the pool\n', kbmSize);

% get the Vg matrix. This NxM matrix contains the IDs of the M top
% Gaussians for the N feature vectors. The value of M is defined by
% variable "topGaussiansPerFrame"

Vg = getVgMatrix(data,gmPool,kbm,topGaussiansPerFrame);

%train Binary Keys and Cumulative Vectors for each input segment

fprintf('Computing binary keys for all segments... ');

[segmentBKTable, segmentCVTable ] = getSegmentBKs(segmentTable, kbmSize, Vg, bitsPerSegmentFactor, speechMapping);



%cluster initialization

fprintf('Performing initial clustering... ');
initialClustering = flatInitializeClustering( N_init, numberOfSegments);
fprintf('done\n');


%agglomerative clustering
fprintf('Performing agglomerative clustering... ');
if linkage==1
    [finalClusteringTable, k] = performClusteringLinkage(segmentBKTable, segmentCVTable, N_init, metric);
else
    [finalClusteringTable, k] = performClustering(speechMapping, segmentTable, segmentBKTable, segmentCVTable, Vg, bitsPerSegmentFactor, kbmSize, N_init, initialClustering, metric);
end

%select output clustering

fprintf('Selecting best clustering...\n');
bestClusteringID = getBestClustering( metric_clusteringSelection, segmentBKTable, segmentCVTable, finalClusteringTable, k );

fprintf('Best clustering:\t%d. ', bestClusteringID);
fprintf('Number of clusters:\t%d\n', size(unique(finalClusteringTable(:,bestClusteringID)),1));

%Resegmentation (based on GMMs on the selected clustering solution)

if resegmentation
    fprintf('Performing GMM-ML resegmentation... ');
    [finalClusteringTableResegmentation,finalSegmentTable] = performResegmentation(data,speechMapping, mask,finalClusteringTable(:,bestClusteringID),segmentTable,modelSize,nbIter,smoothWin,nSpeechFeatures);
    fprintf('done\n');
    getSegmentationFile(outputFormat, finalSegmentTable, finalClusteringTableResegmentation, showName{1}, experimentName, outputPath, outputExt);
else
    %get output file
    getSegmentationFile(outputFormat, segmentTable, finalClusteringTable(:,bestClusteringID), showName{1}, experimentName, outputPath, outputExt);
end

if returnAllPartialSolutions
    if ~(exist(outputPath,'dir')==7)
        mkdir(outputPath);
    end
    outputPathInd = strcat(outputPath, experimentName, '/',showName{1}, '/');
    if ~(exist(outputPathInd,'dir')==7)
        mkdir(outputPathInd);
    end
    for i=1:k
        getSegmentationFile(outputFormat, segmentTable, finalClusteringTable(:,k), indices, nFeatures, showName{1}, strcat(showName{1}, '_', num2str(length(unique(finalClusteringTable(:,i)))), '_spk'), outputPathInd, outputExt);
    end
end

%stop timer
tt=toc(time);
realtimeFactor = tt / (nSpeechFeatures*frameLength);
%write in log file
formatSpec = 'KBM_SIZE: %d File: %s bestClustering %d numberOfClusters %d time (s): %f xRT: %f\n';
fprintf(fileID, formatSpec, kbmSize, showName{1}, bestClusteringID, size(unique(finalClusteringTable(:,bestClusteringID)),1), tt, realtimeFactor);


fprintf('File %s finished in %f seconds. xRT = %f\n\n', showName{1}, tt, realtimeFactor);
fprintf('\n**********************************************************************************\n');
fprintf('\n**********************************************************************************\n');

