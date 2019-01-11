
%% foraging_duration
%
% Effect of stimulus duration for foraging stimuli
%
% Baptiste Caziot, December 2017


clear all;
close all;


platform = 0;   % 0=mbp/mbp 1=T517D/iiyama 

switch platform
    case 0
        cd('/Users/baptiste/Documents/MATLAB/foraging/experiments/foraging_duration/');
    case 1
        cd('/Users/baptiste/Documents/MATLAB/multisensory/multisensory_looming/multisensory_looming_causality_v04/');
    case 2
        cd('/Users/baptistecaziot/Documents/MATLAB/multisensory_looming_causality_v04/');
end


W = foraging_duration_screen(platform); 	% open PTB window

L = foraging_duration_clut;                 % generate lookup table

K = foraging_duration_keys(platform);    	% set up keys

E = foraging_duration_setup(W);          	% set up experimental design

A = foraging_duration_audio(platform);    	% open psychportaudio

R = foraging_duration_header(E,platform); 	% create data text file


ListenChar(2);
clc;


if strcmp(R.subjectName,'robot')
    
elseif strcmp(R.subjectName,'train1')

elseif strcmp(R.subjectName,'train2')

elseif strcmp(R.subjectName,'train3')

elseif strcmp(R.subjectName,'train4')

elseif strcmp(R.subjectName,'screenshots')
    E.concentrationList(:) = max(E.stimConcentration);
end


R.timeStart = GetSecs;


for tt=1:E.nTrials
    
    % display messages
    if (tt==1)||(E.blockList(tt)~=E.blockList(tt-1))
        foraging_duration_messages(W,E,tt);
        fprintf('\n%s\n', R.header);
    end
    
    % display trial
    if ~strcmp(R.subjectName,'robot')
        R = foraging_duration_trial(W,L,A,K,E,R,tt);
    else
        R.responseList(tt) = 0.5*sign(normcdf(E.meanList(tt),0.5,0.005./E.concentrationList(tt))-rand)+0.5;
        R.rtList(tt) = 0;
    end
    
    textLine = foraging_duration_write(E,R,tt);
    fprintf(textLine);
    
end


R.timeStop = GetSecs;


save(R.fileName);

fclose(R.fid);

foraging_duration_messages(W,E,0);

fprintf('\n\nTime total: %i min', round((R.timeStop-R.timeStart)/60));

LoadIdentityClut(W.n);

Screen('CloseAll');

ListenChar(0);


