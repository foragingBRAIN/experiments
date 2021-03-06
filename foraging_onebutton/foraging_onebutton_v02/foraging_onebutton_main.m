
%% foraging_onebutton
%
% One button press experiment for POMDP framework
%
% Baptiste Caziot, June 2017


clear all;
close all;


platform = 0;   % 0=mbp/mbp 1=mbp/samsung 2=SS1/sony

switch platform
    case 0
        cd('/Users/baptiste/Documents/MATLAB/foraging/experiments/foraging_onebutton/foraging_onebutton_v02/');
    case 1
        cd('/Users/baptiste/Documents/MATLAB/multisensory/multisensory_looming/multisensory_looming_causality_v04/');
    case 2
        cd('/Users/baptistecaziot/Documents/MATLAB/multisensory_looming_causality_v04/');
end


W = foraging_onebutton_screen(platform);       % open PTB window

L = foraging_onebutton_clutLuv;                    % comoute CLUT

K = foraging_onebutton_keys(platform);         % set up keys

E = foraging_onebutton_setup(W);               % set up experimental design

A = foraging_onebutton_audio(platform);         % open psychportaudio

R = foraging_onebutton_header(W,E);             % create data text file


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
end


R.timeStart = GetSecs;


for bb=1:E.nCond
    
    % display messages    
    foraging_onebutton_messages(W,E,bb);
    fprintf('\n%s\n', R.header);
    
    % display trial
    if ~strcmp(R.subjectName,'robot')
        R = foraging_onebutton_trial(W,L,A,K,E,R,bb);
    else
%         R.responseList(tt) = sign(normcdf(E.distList(tt),0,0.05)-rand);
%         R.rtList(tt) = 0;
    end
    
%     textLine = foraging_onebutton_write(E,R,bb);
%     fprintf(textLine);
    
end


R.timeStop = GetSecs;


save(R.fileName);

fclose(R.fid);

foraging_onebutton_messages(W,E,0);

fprintf('\n\nTime total: %i min', round((R.timeStop-R.timeStart)/60));

LoadIdentityClut(W.n);

Screen('CloseAll');

ListenChar(0);


