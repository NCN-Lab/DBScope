# DBScope as a versatile computational toolbox for the visualization and analysis of sensing data from deep brain stimulation

DBScope is described in the following paper published in npj Parkinson's Disease:

Oliveira AM*, Carvalho E*, Barros B, Soares C, Ferreira-Pinto MJ, Vaz R, Aguiar P., "<i>DBScope as a versatile computational toolbox for the visualization and analysis of sensing data from deep brain stimulation</i>". npj Parkinson's Disease. 2024 Jul 15;10(1):132.
(* equal contribution)

https://doi.org/10.1038/s41531-024-00740-z

******************************************************************************************************************************************

DBScope version 0.4, 04.07.2025
+ Added parser for ProgrammerVersion 5.0.676.
+ Added some fail-safes and corrected minor bugs on the plotted VisualizationWindows.
+ Corrected hemisphere mislabeling problem in some files (where hemisphere order in json is right-left).
+ Corrected error where Setup ON and OFF would only show data from first run.

DBScope version 0.3, 02.07.2024
+ Group history is now stored.
+ Missing samples of streaming recordings are now automatically corrected by parser.
+ Parsing functions were renamed for consistency.

DBScope version 0.2, 03.05.2024
+ Minor correction in applyFilt_ordered.m function.

Core maintainers: Eduardo Carvalho*, Pedro Melo*, Andreia M Oliveira, Paulo Aguiar

Neuroengineering and Computational Neuroscience (NCN) Lab,

i3S – Instituto de Investigação e Inovação em Saúde

Porto, Portugal 

Contact: pauloaguiar@i3s.up.pt

******************************************************************************************************************************************

For more information regarding the structure of the toolbox, workflows and case-studies, please check the paper published in npj Parkinson's Disease: https://doi.org/10.1038/s41531-024-00740-z

For more information regarding the use of the toolbox, please refer to the **USER GUIDE** and **DEMO VIDEO**, available in the Github page.

https://github.com/NCN-Lab/DBScope


**Note for MATLAB users:**

Before running the toolbox, add the DBScope folder (with subfolders) to the MATLAB's search path.
