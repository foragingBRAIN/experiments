
%% foraging_threebuttons
%
% Three buttons experiment for POMDP framework
%
% Baptiste Caziot, Sept 2017


clear all;
close all;


platform = 0;   % 0=mbp/mbp 1=otherplatform

switch platform
    case 0
        cd('/Users/baptiste/Documents/MATLAB/foraging/experiments/foraging_threebuttons/foraging_threebuttons_v03/');
    case 1
        cd('experimentfolderdirectory');
end

% get subject name
while 1
    subjectName = input('\nSubject Name? ', 's');
    if isempty(regexp(subjectName, '[/\*:?"<>|]', 'once'))
        break
    else
        fprintf('\nInvalid subject name!');
    end
end

% set experiment up
W = foraging_threebuttons_screen(platform); 	% open PTB window

K = foraging_threebuttons_keys(platform);    	% set up keys

E = foraging_threebuttons_setup(W);          	% set up experimental design

L = foraging_threebuttons_clut(W,E);           	% generate color lookup table

A = foraging_threebuttons_audio(platform);    	% open psychportaudio

R = foraging_threebuttons_header(subjectName); 	% create data text file


ListenChar(2);
clc;


if strcmp(R.subjectName,'robot')
    
end


R.timeStart = GetSecs;


for tt=1:E.nTrials
    
    % display messages    
    foraging_threebuttons_messages(W,E,tt);
    fprintf('\n%s\n', R.header);
    
    % display trial
    if ~strcmp(R.subjectName,'robot')
        R = foraging_threebuttons_trial(W,L,A,K,E,R,tt);
    else

    end
    
    textLine = foraging_threebuttons_write(E,R,tt);
    fprintf(textLine);
    
end


R.timeStop = GetSecs;

save(R.fileName);

fclose(R.fid);

foraging_threebuttons_messages(W,E,0);

fprintf('\n\nTime total: %i min\n\n', round((R.timeStop-R.timeStart)/60));

LoadIdentityClut(W.n);

Screen('CloseAll');

ListenChar(0);


