
%% foraging_2AFC
%
% 2AFC task with foraging stimulus
%
% Baptiste Caziot, December 2017


clear all;
close all;


platform = 0;   % 0=mbp/mbp 1=mbp/samsung 2=SS1/sony

switch platform
    case 0
        cd('/Users/baptiste/Documents/MATLAB/foraging/experiments/foraging_2AFC/');
    case 1
        cd('/Users/baptiste/Documents/MATLAB/multisensory/multisensory_looming/multisensory_looming_causality_v04/');
    case 2
        cd('/Users/baptistecaziot/Documents/MATLAB/multisensory_looming_causality_v04/');
end


W = foraging_2AFC_screen(platform);  	% open PTB window

L = foraging_2AFC_clut;                 % generate lookup table

K = foraging_2AFC_keys(platform);    	% set up keys

E = foraging_2AFC_setup(W);          	% set up experimental design

A = foraging_2AFC_audio(platform);    	% open psychportaudio

R = foraging_2AFC_header(E,platform); 	% create data text file


ListenChar(2);
clc;


if strcmp(R.subjectName,'robot')
    
elseif strcmp(R.subjectName,'train1')
    E.condList(:) = 3;
    E.deadlineList(:) = +Inf;
elseif strcmp(R.subjectName,'train2')
    E.deadlineList(:) = +Inf;
elseif strcmp(R.subjectName,'train3')
    E.condList(:) = 3;
    E.deadlineList(:) = 0.3;
elseif strcmp(R.subjectName,'train4')
    E.deadlineList(:) = 0.3;
elseif strcmp(R.subjectName,'screenshots')
    E.concentrationList(:) = max(E.stimConcentration);
end


R.timeStart = GetSecs;


for tt=1:E.nTrials
    
    % display messages
    if (tt==1)||(E.blockList(tt)~=E.blockList(tt-1))
        foraging_2AFC_messages(W,E,tt);
        fprintf('\n%s\n', R.header);
    end
    
    % display trial
    if ~strcmp(R.subjectName,'robot')
        R = foraging_2AFC_trial(W,L,A,K,E,R,tt);
    else
        R.responseList(tt) = 0.5*sign(normcdf(E.meanList(tt),0.5,0.005./E.concentrationList(tt))-rand)+0.5;
        R.rtList(tt) = 0;c
    end
    
    textLine = foraging_2AFC_write(E,R,tt);
    fprintf(textLine);
    
end


R.timeStop = GetSecs;


save(R.fileName);

fclose(R.fid);

foraging_2AFC_messages(W,E,0);

fprintf('\n\nTime total: %i min', round((R.timeStop-R.timeStart)/60));

LoadIdentityClut(W.n);

Screen('CloseAll');

ListenChar(0);


