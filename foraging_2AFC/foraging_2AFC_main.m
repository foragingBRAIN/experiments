
%% foraging_2AFC
%
% 2AFC task with foraging stimulus. Tests multiple display times for
% 1: static stimuli, 2: stimuli with 1/f temporal structure and 3: stimuli
% with 0 correlation in time
%
% Baptiste Caziot, January 2019


clear all;
close all;


platform = 2;   % 0=mbp/mbp 1=T517D/samsung 2=SS1/sony

switch platform
    case 0
        cd('/Users/baptiste/Documents/MATLAB/foraging/experiments/foraging_2AFC/');
    case 1
        cd('C:/Users/baptiste/Documents/MATLAB/foraging/experiments/foraging_2AFC/');
    case 2
        cd('/home/lab/Documents/MATLAB/foraging/experiments/foraging_2AFC/');
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
    E.condList(:) = 1;
    E.durList(:) = max(E.durStimSec);
elseif strcmp(R.subjectName,'train2')
    E.condList(:) = 2;
    E.durList(:) = max(E.durStimSec);
    E.concentrationList(:) = max(E.stimConcentration);
elseif strcmp(R.subjectName,'train3')
    E.condList(:) = 3;
    E.durList(:) = max(E.durStimSec);
elseif strcmp(R.subjectName,'screenshots')
    E.concentrationList(:) = max(E.stimConcentration);
end


rand(1,'gpuArray');
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
        R.rtList(tt) = 0;
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


