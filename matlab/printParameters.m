fprintf('\n\nConfiguration parameters:\n');
fprintf('*************************\n');

fprintf('\nGeneral variables:\n');
fprintf('******\n');
fprintf('experimentName\t\t\t%s\n',experimentName);
global frameLength;
fprintf('frameLength\t\t\t%f\n',frameLength);

fprintf('\nPath variables:\n');
fprintf('***************\n');
fprintf('featuresPath\t\t\t%s\n',featuresPath);
fprintf('UEMPath\t\t\t\t%s\n',UEMPath);
fprintf('SADPath\t\t\t\t%s\n',SADPath);
fprintf('outputPath\t\t\t%s\n',outputPath);
fprintf('logPath\t\t\t\t%s\n',logPath);


fprintf('\nFile extensions:\n');
fprintf('***************\n');
fprintf('featuresExt\t\t\t%s\n',featuresExt);
fprintf('UEMExt\t\t\t\t%s\n',UEMExt);
fprintf('SADExt\t\t\t\t%s\n',SADExt);
fprintf('outputExt\t\t\t%s\n',outputExt);

fprintf('\nFile formats:\n');
fprintf('***************\n');
fprintf('format\t\t\t\t%s\n',format);
fprintf('SADformat\t\t\t%s\n',SADformat)


fprintf('\nKBM:\n');
fprintf('******\n');
fprintf('minimumNumberOfInitialGaussians\t\t%d\n',minimumNumberOfInitialGaussians);
fprintf('maximumKBMWindowRate\t\t\t%d\n',maximumKBMWindowRate);
fprintf('windowLength\t\t\t\t%d\n',windowLength);
fprintf('kbmSize\t\t\t\t\t%d\n',kbmSize);

fprintf('\nSegment parameters:\n');
fprintf('*********************\n');
fprintf('clusteringWindowLength\t\t%d\n',clusteringWindowLength);
fprintf('clusteringWindowRate\t\t%d\n',clusteringWindowRate);
fprintf('clusteringWindowIncrement\t%d\n',clusteringWindowIncrement);


fprintf('\nBianary keys:\n');
fprintf('*************\n');
fprintf('topGaussiansPerFrame\t\t%d\n',topGaussiansPerFrame);
fprintf('bitsPerSegmentFactor\t\t%f\n',bitsPerSegmentFactor);
fprintf('metric\t\t\t\t%s\n',metric);

fprintf('\nClustering parameters:\n');
fprintf('*******************\n');
fprintf('N_init\t\t\t\t%d\n',N_init);

fprintf('\nOutput segmentation format\n');
fprintf('*********************\n');
fprintf('outputFormat\t\t\t%s\n',outputFormat);
fprintf('returnAllPartialSolitions\t%d\n',returnAllPartialSolutions);

