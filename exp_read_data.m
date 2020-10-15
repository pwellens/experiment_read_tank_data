
function run = exp_read_data( run_nmb, varargin )
%EXP_READ_DATA Read data from sets generated at the Delft University
%towing tank
%   run = EXP_READ_DATA( run_nmb, prj_nmb ) reads the data from a run
%   identified by run_nmb within the project identified by prj_nmb. The
%   input can be provided as character arrays or as a number.
%
%   run = EXP_READ_DATA( run_nmb ) reads data from older data sets that
%   were not identified by a project number yet.
%
%   The are stored in a struct called 'run' that contains the information
%   in the .cfg configuration file for that run as well.
%   
%   The run number and project number can be found from the name of the
%   data file. These files are named:
%   <prj_nmb>-Run<run_nmb>_Src<src_num>.bin
%
%   Multiple sources SrcX, with X a number, can be associated with a run.
%   Typically, each source has its own acquisition rate and therefore a
%   separate time vector. For that reason, the data is stored in the output
%   'run' struct under different sources. A list of the sources is obtained
%   by entering 'run.src(:).Src' on the command line. Each source can have
%   multiple channels, but in the config file they are not ordered
%   according to source. Rather they refer to the source with the field
%   'BronID'.
%   For convenience, a list of channels is obtained by entering
%   'run.channel(:).Naam' on the command line.
%
%   There are two ways to access the data. The first is through the src
%   field:
%   time_vector = run.src(1).tme;
%   data_vector = run.src(1).vm;
%   Here, vm is the carriage velocity, which is encountered often in
%   experiments in the towing tank. Another way to acces the data is
%   through the channel field:
%   data_vector = run.channel(1).data
%
%   Dependencies:
%   EXP_READ_DATA requires EXP_READ_CONFIG to be stored in the same
%   directory as EXP_READ_DATA.
%
%   See also EXP_READ_CONFIG.

%   Copyright 2020 Peter Wellens (p.r.wellens@tudelft.nl)
%   Version information:
%   date    #      git hash               purpose
%   201014  0.01   <none>                 preparation for publication on github

% a project number is empty, unless specified as second input entry
prj_nmb = [];
if nargin > 1
    prj_nmb = varargin{1};
end

% read the config file and store its contents in the output struct 'run'
run = exp_read_config( run_nmb, prj_nmb );

% read the data from all of the src files referenced in the config file
for ii = 1:length(run.src)
    fnm = run.src(ii).File;
    if ~exist(fnm,'file')
        warning( [ 'File "' fnm '" referenced in .cfg file not found.'] );
        continue
    end
    fid = fopen( fnm, 'rb' );
    src(ii).data = fread(fid,[run.src(ii).nch+1,Inf],'real*4');
    fclose(fid);
    run.src(ii).tme = src(ii).data(1,:); 
end

% also add the data to the channels in a run.channel(jj).data field
for jj = 1:length(run.channel)
    % allocate the correct row in src.data to the correct channel name in
    % the struct
    kk = run.channel(jj).BronId + 1;
    ll = run.channel(jj).Nr+2;
    nme = str_dejitter( run.channel(jj).Naam );
    run.src( kk ).( nme ) = src( kk ).data( ll, : );
    
    % somehow it feels consistent to also store the data within the part of
    % the struct with the channel information; note that it leads to double
    % data
    run.channel(jj).data = src( kk ).data( ll, : );
end
