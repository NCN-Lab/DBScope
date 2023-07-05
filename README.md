# DBScope: Toolbox for import, preprocessing, visualization and analysis of sensing recordings extracted from Deep Brain Stimulation neurostimulators

https://github.com/NCN-Lab/DBScope

For referencing, please use: Andreia M. Oliveira, Eduardo Carvalho, Beatriz Barros, Carolina Soares, Manuel Ferreira-Pinto, Rui Vaz, Paulo Aguiar, DBScope: a versatile computational toolbox for the visualization and analysis of sensing data from Deep Brain Stimulation, XXX doi: XXX.

Version 1, 2023
Contributors: Andreia M Oliveira, Eduardo Carvalho, Beatriz Barros, Paulo Aguiar
Neuroengineering and Computational Neuroscience (NCN) Lab,
I3S – Instituto de Investigação e Inovação em Saúde
Porto, Portugal 
Contact: pauloaguiar@i3s.up.pt

For more information regarding the structure of the toolbox ( Figura 1 & 2) , workflow ( Figure 3 ), and case-studies ( Figura 4 & 5 ), please consult publication (doi: XXX).
For more information regarding the utilization the toolbox, please refer to the USER GUIDE, available in the Github page.

**Before running the toolbox, add folder (with subfolders) to path.

**Code is accessible through the command window or through the UI 'DBScope'

# Structure
The toolbox is built in Object Oriented Programming.  For more information, see figure 1 of the publication (doi: XXX),
The main UI allows for consultation of system and calibration information, and analysis of chronic and streaming data. Corresponding methods for the analysis of the different recording modes are only made available if those 
data fields are present in the uploaded files.
In the calibration section there is a button ('Inspect for Artifacts') that opens a secondary UI that allows for the exploration of artifacts in recordings 'Survey'. This app only operates on Survey recordings.
In the streaming section, there is a button ('Filter') that opens a secondary UI that allows for the application and visualization of filters on Streaming recordings. 

 # Classes
The class NCNPERCEPT_BATCH initializes the patient object(s) and the inherited classes. It can operate on single file, multiple files, folders or previously saved workspaces.
There are  
>> 5 main operational classes:
 RECORDINGMODE_SURVEY
 This class provides visualization and filtering methods for the survey recording mode.
 RECORDINGMODE_SETUP
 This class provides visualization methods for the setup recording mode: on and off stimulation.
 RECORDINGMODE_STREAMING
 This class provides visualization and filtering methods for the online streaming recording mode. It requires the user to run an algorithm for ECG cleaning before any other operation. Then, it provides three options: 1) a secondary interface for the filtering of the signal, and the output of this secondary GUI is accessible via the main GUI; 2) a summary of the analysis (raw signal, spectrogram and wavelet transform), and 3) a set of spectral and correlation analysis tools.
 RECORDINGMODE_CHRONIC
 This class allows for the study of chronic sensing recording, as well as further tools for the analysis of LFP snapshots corresponding to the events logs.
 WEARABLES_EXTERNAL
 This class allows to load and visualize signals from motion sensors, and to simultaneously visualize corresponding STREAMING signals.
 The wearable data must be in a .CSV file (for more information, see the "External Wearables" section of the USER GUIDE).
 >>  2 auxiliary classes (auxiliary classes run in the background, and are not directly accessible by the user):
RECORDINGMODE_COMMONMETHODS
NCNPERCEPT FILE
