# experiment_read_tank_data

GitHub repository for loading data of experiments conducted at the Ship Hydromechanics Laboratory at
Delft University of Technology.

The data is contained in two files per test (where there are multiple tests per experiment). File
names are:
- <project_number>-Run<run_number>_Src<src_number>.bin
- <project_number>-Run<run_number>.cfg

The former contains the data, the latter the information about which data acquisition sources and
data channels were used.

Loading the data is accomplished by the MATLAB functions in the repository. A help section with
examples of usage is contained within the respective .m-files.

For more information, contact Peter Wellens (p.r.wellens@tudelft.nl)
