function [Neuro,Params] = RunLoop(Params,Neuro,DataDir)
% Defines the structure of collected data on each trial
% Loops through blocks and trials within blocks

%% Start Experiment
DataFields = struct(...
    'Params',Params,...
    'Trial',NaN,...
    'TrialStartTime',NaN,...
    'TrialEndTime',NaN,...
    'Time',[],...
    'NeuralTime',[],...
    'NeuralTimeBR',[],...
    'NeuralSamps',[],...
    'NeuralFeatures',{{}},...
    'BroadbandData',{{}},...
    'ProcessedData',{{}},...
    'Events',[]...
    );

%%  Loop Through Blocks of Trials
tlast = GetSecs;
Neuro.LastPredictTime = tlast;
Neuro.LastUpdateTime = tlast;

Trial = 0;
done = 0;
while ~done,
    % update trial
    Trial = Trial + 1;
    
    % set up trial
    TrialData = DataFields;
    TrialData.Trial = Trial;
    
    % Run Trial
    TrialData.TrialStartTime  = GetSecs;
    if Params.SerialSync, fprintf(Params.SerialPtr, '%s\n', 'TST'); end
    [TrialData,Neuro,Params] = RunTrial(TrialData,Params,Neuro);
    if Params.SerialSync, fprintf(Params.SerialPtr, '%s\n', 'TET'); end
    TrialData.TrialEndTime    = GetSecs;
    
    % Save Data from Single Trial
    save(...
        fullfile(DataDir,sprintf('Data%04i.mat',Trial)),...
        'TrialData',...
        '-v7.3','-nocompression');
    
    % Give Break Btw Trials
    str = input('\nPress 0/1 to continue/end task. ', 's');
    done = str2num(str);
    figure(Params.Fig);
    % set done to 1, to end gracefully
    
end % Trial Loop


end % RunLoop



