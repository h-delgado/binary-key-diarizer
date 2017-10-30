# binary-key-diarizer
Speaker diarization system using Binary Key modelling

For more information about the binary key speaker diarization process, refer to the following publication:

Héctor Delgado, Xavier Anguera, Corinne Fredouille and Javier Serrano, "Fast Single- and Cross-Show Speaker Diarization Using Binary Key Speaker Modeling," IEEE/ACM Transactions on Audio, Speech, and Language Processing, 23-12, pp 2286-2297, 2015.

Also, if you use the code in your research, please cite the aforementioned publication.

The code has been developed and tested in Matlab R20015b

Matlab toolboxes required:
=========================
- Statistics toolbox
- Parallel computing toolbox (optional, only if you want to take advantage of the cpu cores by using workers)

External toolboxes required:
===========================

The system also requires some functions of external freely available toolboxes, but you do not need to download them: those funcions are included in the "/matlab/external" folder of this package. The required functions are the following:

- mvn_new.m: for handling multivariate normal distributions. From "Matlab/Octave Multivariate Normals Toolbox (Version 1)" (http://www.ofai.at/~dominik.schnitzer/mvn)

- readhtk.m: for reading HTK feature files. From "VOICEBOX: Speech Processing Toolbox for MATLAB" (http://www.ee.ic.ac.uk/hp/staff/dmb/voicebox/voicebox.html):
	
- pdist2.m (renamed to pdist22.m to avoid conflict with matlab pdist2 function): For calculating the chi-square similarity. From "Piotr's Computer Vision Matlab Toolbox" (http://vision.ucsd.edu/~pdollar/toolbox/doc/index.html).

- VLFeat (http://www.vlfeat.org/): The function "vl_gmm" is used for GMM training.

Running the system:
===================

The included package consists of the following folders:

- /eval/ 		contains the NIST md-eval-v21.pl for system evaluation
- /featureFiles/ 	input feature files folder
- /log/			generated log files are stored here
- /matlab/		contains the matlab code
- /out/			diarization outputs are stored here
- /reference/		contains the reference files necessary to evaluate the system
- /sad/			to place the Speech Activity Detection Files
- /uem/			to place the UEM partition files

IMPORTANT NOTICE: Note that the system does not perform Feature Extraction nor Speech Activity Detection. You have to provide these files by yourself. For feature extraction, you can use HTK feature files, or just an ascii file in which each line is a feature composed of the coefficients separated by blanks.

In order to easily test the system, we have provided some example data:

* In /featureFiles folder you can find 5 feature files:

- 3054300.mfc
- 3055877.mfc
- 3056696.mfc
- 3057402.mfc
- 3063115.mfc

Those are 19-order MFCCs feature files in HTK format. They were extracted from audio files of the SAIVT-BNEWS database of Australian broadcast news (https://wiki.qut.edu.au/display/saivt/SAIVT-BNEWS). We cannot distribute them (copyright All Rights Reserved by Fairfax Media), but you can watch/get the videos in:

- 3054300.mfc http://mediadownload2.f2.com.au/flash/media/2012/02/19/3054300/3054300_high.mp4
- 3055877.mfc http://mediadownload2.f2.com.au/flash/media/2012/02/20/3055877/3055877_high.mp4
- 3056696.mfc http://mediadownload2.f2.com.au/flash/media/2012/02/20/3056696/3056696_high.mp4
- 3057402.mfc http://mediadownload2.f2.com.au/flash/media/2012/02/20/3057402/3057402_high.mp4
- 3063115.mfc http://mediadownload2.f2.com.au/flash/media/2012/02/22/3063115/3063115_high.mp4

* In "/sad" folder we include speech/non-speech label files. They were actually extracted from the reference speaker labels in "/reference" folder, so the SAD files are "perfect" in this example.

In the root folder of this package, the file "main.m" is included. This is a matlab script file in which all the system parameters are configured and from which the speaker diarization system is called. The possible values of the parameters are explained in the code comments. Read them carefully.

The list of input feature files is obtained by scanning the folder specified for feature files. See the example inside.

Once the "main.m" has been edited (you can leave the values provided as a starting point), we are ready to run the system:

- Run "main.m"

	>> main;

The standard output will show information about the processes. Once finished, the output RTTM file will be at "/out" folder, and the log file at "/log" folder

Evaluating the obtained solution
================================

In "/eval" folder, we have included the NIST md-eval script widely used to assess speaker diarization technology. Open a terminal and go to the package root folder.

- run: $ eval/md-eval-v21.pl -af -c 0.25 -s out/[experiment_name].rttm -r reference/reference.rttm

(where [experiment_name] is the name you assigned to the variable "experimentName" in "main.m")

You will get the evaluation report in the standard output. If everything went fine the final result should be:

	"OVERALL SPEAKER DIARIZATION ERROR = 4.62 percent of scored speaker time  `(ALL)"

If you have any question or comment, you can reach me by email.

Thanks for downloading and using the system!

Héctor Delgado <hecdelflo at gmail.com>

Change log:
===========

v1.1:
=====
- The routines for importing UEM and SAD labels have been refined and several bugs were fixed.
- The KBM size can now be set as a percentage of the size of the initial Gaussian pool by means of parameters "useRelativeKBMsize" and "relKBMsize"
- Added support for clustering with three different linkage criteria: single, complete and average.
- Added a final re-segmentation stage based on GMM-ML to improve segment boundaries.
