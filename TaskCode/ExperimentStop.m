function ExperimentStop(fromPause,Params)
if ~exist('fromPause', 'var'), fromPause = 0; end

% Close Screen
close(Params.Fig);

% Close Serial Port
if Params.SerialSync,
    fclose(Params.SerialPtr);
end

% quit
if fromPause, keyboard; end

end % ExperimentStop
