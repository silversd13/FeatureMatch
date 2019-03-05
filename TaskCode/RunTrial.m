function [Data, Neuro, Params] = RunTrial(Data,Params,Neuro)
% Runs a trial, saves useful data along the way

%% Set up trial
% Output to Command Line
fprintf('\nTrial: %i\n',Data.Trial)
dt_vec = [];
dT_vec = [];

%% Go to reach target
tstart  = GetSecs;
Data.Events(end+1).Time = tstart;
Data.Events(end).Str  = 'Reach Target';
if Params.SerialSync, fprintf(Params.SerialPtr, '%s\n', 'RT'); end

done = 0;
while ~done,
    % Update Time & Position
    tim = GetSecs;
    
    % Update Screen
    if (tim-Neuro.LastPredictTime) > 1/Params.ScreenRefreshRate,
        % time
        dt = tim - Neuro.LastPredictTime;
        dt_vec(end+1) = dt;
        Neuro.LastPredictTime = tim;
        Data.Time(1,end+1) = tim;
        
        % grab and process neural data
        if ((tim-Neuro.LastUpdateTime)>1/Params.UpdateRate),
            dT = tim-Neuro.LastUpdateTime;
            dT_vec(end+1) = dT;
            Neuro.LastUpdateTime = tim;
            if Params.BLACKROCK,
                [Neuro,Data] = NeuroPipeline(Neuro,Data);
                Data.NeuralTime(1,end+1) = tim;
            end
            if Params.GenNeuralFeaturesFlag,
                Neuro.NeuralFeatures = VelToNeuralFeatures(Params);
                Data.NeuralFeatures{end+1} = Neuro.NeuralFeatures;
            end
        end
        
        % draw
        PlotFeatureMap(Params.FeedbackAxis,Neuro.NeuralFeatures(Params.FeatureIdx,:),Params.ChLayout,'Current Feature Map');
    end
    
    % end if in start target for hold time
    if (tim-tstart) > Params.TrialTime,
        done = 1;
    end
    
end % Trial Loop


%% Completed Trial - Give Feedback

% output update times
if Params.Verbose,
    fprintf('Screen Update Frequency: Goal=%iHz, Actual=%.2fHz (+/-%.2fHz)\n',...
        Params.ScreenRefreshRate,mean(1./dt_vec),std(1./dt_vec))
    fprintf('System Update Frequency: Goal=%iHz, Actual=%.2fHz (+/-%.2fHz)\n',...
        Params.UpdateRate,mean(1./dT_vec),std(1./dT_vec))
end

end % RunTrial



