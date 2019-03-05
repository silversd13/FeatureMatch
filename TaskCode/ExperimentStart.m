function ExperimentStart(Subject,BLACKROCK,DEBUG)
% function ExperimentStart(Subject,ControlMode)
% Subject - string for the subject id
% BLACKROCK - [0,1] if 1, collects, processes, and saves neural data
% DEBUG - [0,1] if 1, enters DEBUG mode in which screen is small and cursor
%   remains unhidden

%% Clear All and Close All
clearvars -global -except Subject ControlMode BLACKROCK DEBUG
clc, close all
warning off

if ~exist('Subject','var'), Subject = 'Test'; DEBUG = 1; end
if ~exist('BLACKROCK','var'), BLACKROCK = 0; end
if ~exist('DEBUG','var'), DEBUG = 0; end

AssertOpenGL;
KbName('UnifyKeyNames');

if strcmpi(Subject,'Test'), Subject = 'Test'; end

%% Retrieve Parameters from Params File
Params.Subject = Subject;
Params.BLACKROCK = BLACKROCK;
Params.DEBUG = DEBUG;
Params = GetParams(Params);

%% Initialize Blackrock System
if BLACKROCK,
    addpath('C:\Program Files (x86)\Blackrock Microsystems\Cerebus Windows Suite')
    cbmex('close'); % always close
    cbmex('open'); % open library
    cbmex('trialconfig', 1); % empty the buffer
end

%% Initialize Sync to Blackrock
if Params.SerialSync,
    Params.SerialPtr = serial(Params.SyncDev, 'BaudRate', Params.BaudRate);
    fopen(Params.SerialPtr);
end

%% Neural Signal Processing
% create neuro structure for keeping track of all neuro updates/state
% changes
Neuro.ZscoreRawFlag     = Params.ZscoreRawFlag;
Neuro.ZscoreFeaturesFlag= Params.ZscoreFeaturesFlag;
Neuro.SaveProcessed     = Params.SaveProcessed;
Neuro.SaveRaw           = Params.SaveRaw;
Neuro.FilterBank        = Params.FilterBank;
Neuro.NumChannels       = Params.NumChannels;
Neuro.BufferSamps       = Params.BufferSamps;
Neuro.BadChannels       = Params.BadChannels;
Neuro.ReferenceMode     = Params.ReferenceMode;
Neuro.NumFeatures       = Params.NumFeatures;
Neuro.LastUpdateTime    = GetSecs;

% initialize filter bank state
for i=1:length(Params.FilterBank),
    Neuro.FilterBank(i).state = [];
end

% initialize stats for each channel for z-scoring
Neuro.ChStats.wSum1  = 0; % count
Neuro.ChStats.wSum2  = 0; % squared count
Neuro.ChStats.mean   = zeros(1,Params.NumChannels); % estimate of mean for each channel
Neuro.ChStats.S      = zeros(1,Params.NumChannels); % aggregate deviation from estimated mean for each channel
Neuro.ChStats.var    = zeros(1,Params.NumChannels); % estimate of variance for each channel

% initialize stats for each feature for z-scoring
Neuro.FeatureStats.wSum1  = 0; % count
Neuro.FeatureStats.wSum2  = 0; % squared count
Neuro.FeatureStats.mean   = zeros(1,Params.NumChannels); % estimate of mean for each channel
Neuro.FeatureStats.S      = zeros(1,Params.NumChannels); % aggregate deviation from estimated mean for each channel
Neuro.FeatureStats.var    = zeros(1,Params.NumChannels); % estimate of variance for each channel

% create low freq buffers
Neuro.FilterDataBuf = zeros(Neuro.BufferSamps,Neuro.NumChannels,3);

%% Check Important Params with User
LogicalStr = {'off', 'on'};
Params.Subject = Subject;
Params.BLACKROCK = BLACKROCK;
Params.DEBUG = DEBUG;

fprintf('\n\nImportant Experimental Parameters:')
fprintf('\n\n  Task Parameters:')
fprintf('\n    - task: %s', Params.Task)
fprintf('\n    - subject: %s', Params.Subject)
fprintf('\n    - blackrock mode: %s', LogicalStr{Params.BLACKROCK+1})
fprintf('\n    - debug mode: %s', LogicalStr{Params.DEBUG+1})
fprintf('\n    - serial sync: %s', LogicalStr{Params.SerialSync+1})

fprintf('\n\n  Neuro Processing Pipeline:')
if Params.GenNeuralFeaturesFlag,
    fprintf('\n    - generating neural features!')
else,
    fprintf('\n    - reference mode: %s', Params.ReferenceModeStr)
    fprintf('\n    - zscore raw: %s', LogicalStr{Params.ZscoreRawFlag+1})
    fprintf('\n    - zscore features: %s', LogicalStr{Params.ZscoreFeaturesFlag+1})
    fprintf('\n    - save filtered data: %s', LogicalStr{Params.ZscoreRawFlag+1})
end

str = input('\n\nContinue? (''n'' to quit, otherwise continue)\n' ,'s');
if strcmpi(str,'n'),
    fprintf('\n\nExperiment Ended\n\n')
    return
end

%% Load Channel Layout
tmp = load(Params.ChLayoutFile);
Params.ChLayout = tmp.ecog_grid;

%% Initialize Window
Params.Fig = figure('units','normalized','position',[.25,.2,.5,.6]);
Params.TargetAxis = subplot(2,1,1);
Params.FeedbackAxis = subplot(2,1,2);
% plot target map
PlotFeatureMap(Params.TargetAxis,...
    Params.TargetVec,...
    Params.ChLayout,...
    'Target Map');

%% Start
try    
    % run
    RunTask(Params,Neuro);
    
    % Pause and Finish!
    ExperimentStop(0,Params);
    
catch ME, % handle errors gracefully
    Screen('CloseAll')
    for i=length(ME.stack):-1:1,
        if i==1,
            errorMessage = sprintf('Error in function %s() at line %d.\n\nError Message:\n%s\n\n', ...
                ME.stack(1).name, ME.stack(1).line, ME.message);
        else,
            errorMessage = sprintf('Error in function %s() at line %d.\n\n', ...
                ME.stack(i).name, ME.stack(i).line);
        end
        fprintf(1,'\n%s\n', errorMessage);
    end
    keyboard;
end

end % ExperimentStart
