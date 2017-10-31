%PARAMETER SETTINGS: you can edit this section of this script file to configure the system
clear, clc
%***********************************************
%***********************************************
numberOfMatlabWorkers = 2;
%set a name for the experiment
experimentName = 'demo_BK_res';

%General variables
%%%%%%%%%%%%%%%%%%

global frameLength;
frameLength = 0.01;       %amount of time represented by each feature vector

SADformat = 'RTTM';        %format of SAD files (LBL, MDTM or RTTM)

%PATH VARIABLES
%%%%%%%%%%%%%%%

featuresPath = 'featureFiles/';
UEMPath = 'uem/';
SADPath = 'sad/';
outputPath = './out/';              %path to the output files
logPath = './log/';                 %path to the log files

%FILE EXTENSIONS
%%%%%%%%%%%%%%%%

featuresExt = '.mfc';
UEMExt = '.uem';
SADExt = '.rttm';
outputExt = '.rttm';

%FEATURE VECTORS
%%%%%%%%%%%%%%%%%%%

format = 'HTK';       % Format of feature files. It can be 'HTK' or 'ASCII'

%KBM PARAMETERS
%%%%%%%%%%%%%%%

minimumNumberOfInitialGaussians = 1024;     % Minimum number of Gaussians in the initial pool
maximumKBMWindowRate = 50;                  % Maximum window rate for Gaussian computation
windowLength = 200;                         % Window length for computing Gaussians
kbmSize = 320;                              % Number of final Gaussian components in the KBM
useRelativeKBMsize = 1;                     % If set to 1, the KBM size is set as a proportion, given by "relKBMsize", of the pool size
relKBMsize = 0.3;                           % Relative KBM size if "useRelativeKBMsize = 1" (value between 0 and 1).

%SEGMENT PARAMETERS
%%%%%%%%%%%%%%%%%%%

clusteringWindowLength = 100;               % window size in frames
clusteringWindowIncrement = 100;            % window increment after and before window in frames
clusteringWindowRate = 100;                 % window shifting in frames

%BINARY KEY PARAMETERS
%%%%%%%%%%%%%%%%%%%%%%

topGaussiansPerFrame = 5;           %Number of top selected components per frame
bitsPerSegmentFactor = 0.2;         %Percentage of bits set to 1 in the binary keys
metric = 'cosine';                  %Similarity metric: 'cosine' and 'chisquared' for Cumulative Vectors, and 'jaccard' for Binary Keys

%CLUSTERING PARAMETERS
%%%%%%%%%%%%%%%%%%%%%%
N_init = 16;                        %Number of initial clusters
linkage = 0;                        %Set to one to perform linkage clustering instead of clustering/reasignment
linkageCriterion = 'average';       %Linkage criterion used if linkage=1 ('average', 'single', 'complete')

%CLUSTERING SELECTION PARAMETERS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
metric_clusteringSelection = 'cosine';  % distance metric used in the selection of the output clustering solution ('jaccard','cosine','chisquared')

%RESEGMENTATION PARAMETERS
resegmentation = 1;                 %Set to 1 to perform re-segmentation
modelSize = 128;                    %Number of GMM components
nbIter = 10;                        %Number of EM iterations
smoothWin = 100;                    %Size of the likelihood smoothing window in nb of frames

%OUTPUT SEGMENTATION FILE FORMAT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
outputFormat = 'RTTM';              % 'MDTM' or 'RTTM'
returnAllPartialSolutions = 0 ;     % If 0, all the segmentation outputs are stored in a single output file
% If 1, all partial clustering
% solutions obtained at every iteration
% are stored in separated files


%NO MORE EDITING FROM HERE ON!!
%***********************************************
%***********************************************

addpath(genpath('matlab'));

%if you have the parallel computing toolbox, you can open a pool of workers
if isempty(gcp);
    parpool(numberOfMatlabWorkers);
end

%LIST OF INPUT FILES
%%%%%%%%%%%%%%%%%%%%

% create directories
mkdir(outputPath);
mkdir(logPath);

% scan the input feature folder to get the list of files with the
% specified file extension
showNameList = textscan(ls(strcat(featuresPath,'*',featuresExt)),'%s');
showNameList = showNameList{1};
for i=1:length(showNameList)
    [~,showNameList{i},~]=fileparts(showNameList{i});
end
showNameList = showNameList';

%Creating directories
if ~exist(logPath,'dir')==7
    mkdir(logPath);
end

%Opening log file
S = strcat(logPath, experimentName, '.log');
fileID = fopen(S,'a+');
fprintf(fileID,datestr(clock,0));
fprintf(fileID,'\n');

%Remove output file and folder if they already exist
if exist(strcat(outputPath,experimentName,outputExt),'file')==2
    delete(strcat(outputPath,experimentName,outputExt));
end
if exist(strcat(outputPath,experimentName),'dir')==7
    rmdir(strcat(outputPath,experimentName),'s');
end



%finally, run diarization for each input file
timeGlobal = tic;
totalFramesSpeech = 0;
for showName = showNameList
    runDiarization;
end
t = toc(timeGlobal);
realtimeFactorGlobal = t / (totalFramesSpeech*frameLength);
fprintf(fileID, 'End KBM = %d   Execution time: %f seconds  xRT = %f\n', kbmSize, t, realtimeFactorGlobal);

fclose(fileID);         %close log file
