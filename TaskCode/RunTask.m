function [Neuro,Params] = RunTask(Params,Neuro)
% Explains the task to the subject, and serves as a reminder for pausing
% and quitting the experiment (w/o killing matlab or something)

% output to screen
fprintf('\n\nFeature Matching:\n')
fprintf('  Saving data to %s\n\n',Params.Datadir)

[Neuro,Params] = RunLoop(Params,Neuro,Params.Datadir);

end % RunTask
