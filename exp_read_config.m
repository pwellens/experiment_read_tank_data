function run = exp_read_config( run_nmb, prj_nmb )
%EXP_READ_CONFIG Read config files for data sets at the Delft University
%towing tank
%   run = EXP_READ_CONFIG( run_nmb, prj_nmb ) reads the config file of a
%   run identified by run_nmb within the project identified by prj_nmb. The
%   input can be provided as character arrays or as a number. For older
%   experiments prj_nmb can be an empty character array. The contents of
%   the configuration file are stored in a struct called 'run'.
%   
%   EXP_READ_CONFIG is typically not called by the user but from
%   EXP_READ_DATA. If called by the user then the run number and project
%   numer can be found from the name of the configuration file. These files
%   are named:
%   <prj_nmb>-Run<run_nmb>.cfg
%
%   Dependencies:
%   EXP_READ_CONFIG requires STR_DEJITTER to be stored in a directory
%   "string_manipulation" contained by the same directory that also
%   contains "experiment", in which EXP_READ_CONFIG is stored.
%
%   See also EXP_READ_DATA, STR_DEJITTER.

%   Copyright 2020 Peter Wellens (p.r.wellens@tudelft.nl)
%   Version information:
%   date    #      git hash               purpose
%   201014  0.01   <none>                 preparation for publication on github


% resolve dependencies

% exp_read_config requires str_dejitter, which removes nonalpha characters
% from strings so that they can be used as field names. It is assumed that
% str_dejitter resides in a directory called 'string_manipulation' in the
% same directory that also contains 'experiment/exp_read_data'
if ~exist('str_dejitter','file')
    path_to_expreaddata = which( 'exp_read_data' );
    str_lookahead = [ 'experiment' filesep 'experiment_read_tank_data' filesep 'exp_read_data' ];
    expression = [ '.*(?=' str_lookahead ')' ];
    path_to_directory = regexp( path_to_expreaddata, expression, 'match' );
    path_to_function = [ path_to_directory{:} 'string_manipulation' ];
    addpath( path_to_function, path );
end

% convert to string if the run number run_nmb is provided as numeric input
if ~ischar(run_nmb)
    run_nmb = num2str(run_nmb);
end

% convert to string if the project number pfj_nmb is given as numeric input
if ~isempty(prj_nmb)
    if ~ischar(prj_nmb)
        prj_nmb = num2str(prj_nmb);
    end
    prj_nmb = [prj_nmb '-'];
end

% check if the file with data being referenced by the .cfg file actually
% exists (in the same directory)
fnm = [ prj_nmb 'Run' run_nmb '.cfg' ];
if ~exist( fnm, 'file' )
    error( 'File name not found in exp_read_config' );
end

% open the .cfg file
fid = fopen( fnm, 'r' );

% check if it indeed appears to be a .cfg file
str = fgetl(fid);
if ~strcmp( str, '[System]' )
    error( 'This does not to be a configuration file for an experiment' );
end

% loop over all lines to store the information in a struct called 'run'
run.system = [];
run.src = [];
run.channel = [];

str = fgetl(fid);
while ~strcmp( str, '[Sources]' )
    % match everything in str before '=' to get the field name
    cfd = regexp(str,'^.*(?==)','match');
    % match everything in str after '=' to get the field value
    cvl = regexp(str,'(?<==).*$', 'match');
    % check for zeros length of cvl
    if ~isempty(cvl)
        % convert char to number if possible
        [ vle, sts ] = str2num( cvl{1} );
        if sts
            % assign field value to field
            run.system.(cfd{1}) = vle;
        else
            run.system.(cfd{1}) = cvl{1};
        end
    else
        run.system.(cfd{1}) = '';
    end

    str = fgetl(fid);
end

str = fgetl(fid);
while ~strcmp( str, '[Kanaal1]' )
    % match
    cfd = regexp(str,'^.*(?==)','match');
    cvl = regexp(str,'(?<==).*$', 'match');
    % extract a source number
    snr = str2double( cfd{1}(end) );
    [ vle, sts ] = str2num( cvl{1} );
    if sts
        % assign field value to field
        run.src(snr).(cfd{1}(1:end-1)) = vle;
    else
        run.src(snr).(cfd{1}(1:end-1)) = cvl{1};
    end
    str = fgetl(fid);
end

% initialize the number of channels per source for each source
for ii = 1:snr
    run.src(ii).nch = 0;
end

cnr = 1; % channel number
while ~feof(fid)
    str = fgetl(fid);
    if contains( str, '[Kanaal' )
        cnr = cnr + 1;
    else
        % match
        cfd = regexp(str,'^.*(?==)','match');
        cvl = regexp(str,'(?<==).*$', 'match');
        % assign field value to field
        [ vle, sts ] = str2num( cvl{1} );
        if sts
            run.channel(cnr).(cfd{1}) = vle;
        else
            run.channel(cnr).(cfd{1}) = cvl{1};
        end
        if strcmp(cfd{1}, 'BronId')
            % allocate the channel to the correct source
            run.src(vle+1).nch = run.src(vle+1).nch + 1;
            % note that we need to add 1 to the value of BronID to get the
            % right source number
        end
    end
end
    
return
