
%% foraging_schedule_v02
%
% Human version of the visual schedule experiment
%
% Baptiste Caziot, April 2018


clear all;
close all;


platform = 0;   % 0=mbp/mbp 1=mbp/samsung 2=SS1/sony

switch platform
    case 0
        cd('/Users/baptiste/Documents/MATLAB/foraging/experiments/foraging_schedule/foraging_schedule_v02/');
    case 1
        cd('/Users/baptiste/Documents/MATLAB/multisensory/multisensory_looming/multisensory_looming_causality_v04/');
    case 2
        cd('/Users/baptistecaziot/Documents/MATLAB/multisensory_looming_causality_v04/');
end


W = foraging_schedule_screen(platform); 	% open PTB window

L = foraging_schedule_clut;                 % generate lookup table

K = foraging_schedule_keys(platform);    	% set up keys

E = foraging_schedule_setup(W);          	% set up experimental design

A = foraging_schedule_audio(platform);    	% open psychportaudio

R = foraging_schedule_header(E,platform); 	% create data text file


ListenChar(2);
clc;


if strcmp(R.subjectName,'robot')
    
elseif strcmp(R.subjectName,'train1')
    E.visualScheduleList(:,:) = E.scheduleTau;
    E.stimIntStd(:) = 1/12;
elseif strcmp(R.subjectName,'train2')
    E.visualScheduleList(:,:) = E.scheduleTau;
    E.stimIntStd(:) = 1/6;
elseif strcmp(R.subjectName,'train3')
    E.visualScheduleList(:,:) = E.scheduleTau;
    E.stimIntStd(:) = 1/3;
elseif strcmp(R.subjectName,'train4')

elseif strcmp(R.subjectName,'screenshots')
    E.concentrationList(:) = max(E.stimConcentration);
end


R.timeStart = GetSecs;


for tt=1:E.nTrials
    
    % display messages
    foraging_schedule_messages(W,E,tt);
    fprintf('\n%s\n', R.header);
    
    % display trial
    if ~strcmp(R.subjectName,'robot')
        R = foraging_schedule_trial(W,L,A,K,E,R,tt);
    else
        R.responseList(tt) = 0.5*sign(normcdf(E.meanList(tt),0.5,0.005./E.concentrationList(tt))-rand)+0.5;
        R.rtList(tt) = 0;
    end
    
%     textLine = foraging_schedule_write(E,R,tt);
%     fprintf(textLine);
    
end


R.timeStop = GetSecs;


save(R.fileName);

fclose(R.fid);

foraging_schedule_messages(W,E,0);

fprintf('\n\nTime total: %i min', round((R.timeStop-R.timeStart)/60));

LoadIdentityClut(W.n);

Screen('CloseAll');

ListenChar(0);


