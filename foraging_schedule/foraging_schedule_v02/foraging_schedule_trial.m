

function R = foraging_schedule_trial(W,L,A,K,E,R,tt)
    
    
    %% display fixation
    
    fixRect = [W.center-0.5*E.fixationSizePix,W.center+0.5*E.fixationSizePix];
    
    scoreNum = 0;
    scoreText = sprintf('%i',scoreNum);
    scoreRect = Screen('TextBounds', W.n, scoreText);
    
    Screen('FillRect', W.n, W.bg*255);
    Screen('FrameRect', W.n,  E.fixationColor*255, fixRect, E.fixationThicknessPix);
    vbl = Screen('Flip', W.n, 0);
    timeStart = vbl;
    if strcmp(R.subjectName,'screenshots')
        I = Screen('GetImage', W.n);
        imwrite(I,'fixation.png');
    end
    
    %% compute textures
    % texture spectrum
    beta = -2;
    spect_u = [(0:floor(E.stimWidthPix/2)) -(ceil(E.stimWidthPix/2)-1:-1:1)]'/E.stimWidthPix;
    spect_u = repmat(spect_u,1,E.stimWidthPix);
    spect_v = [(0:floor(E.stimWidthPix/2)) -(ceil(E.stimWidthPix/2)-1:-1:1)]/E.stimWidthPix;
    spect_v = repmat(spect_v,E.stimWidthPix,1);
    S_f = (spect_u.^2 + spect_v.^2).^(beta/2);
	S_f(S_f==inf) = 0;
    
    oldSpectrum = (randn(E.stimWidthPix)+1i*randn(E.stimWidthPix)).*sqrt(S_f);
    
    % time freq weighting
    speedchange = 2;
    k = sqrt(spect_u.^2 + spect_v.^2);
    invk = exp(-k.*speedchange);
    invk(isinf(invk)) = 0;
    
    % window
    [x,y] = meshgrid(1:ceil(E.stimWidthPix),1:ceil(E.stimWidthPix));
    d = sqrt((x-0.5*(ceil(E.stimWidthPix)+1)).^2+(y-0.5*(ceil(E.stimWidthPix)+1)).^2);
    windowmat(:,:,1:3) = repmat(W.bg*ones(ceil(E.stimWidthPix),ceil(E.stimWidthPix)),[1,1,3]);
    windowmat(:,:,4) = normcdf(d,0.45*ceil(E.stimWidthPix),0.02*E.stimWidthPix);
    winTex = Screen('MakeTexture', W.n, 255*windowmat);
    
    % compute rect
    patchRect = [W.center,W.center] + 0.5*round(E.stimWidthPix)*[-1,-1,+1,+1];
    
    
    %% blank fixation
    Screen('Fillrect', W.n, W.bg*255);
    Screen('DrawText', W.n, scoreText, W.center(1)+E.scorePosPix(1)-0.5*scoreRect(3), W.center(2)+E.scorePosPix(2)-0.5*scoreRect(4), 0);
    vbl = Screen('Flip', W.n, vbl+E.durFixSec-0.25*W.ifi);
    timeBlankFix = vbl;
    if strcmp(R.subjectName,'screenshots')
        I = Screen('GetImage', W.n);
        imwrite(I,'blank1.png');
    end
    
    
    %% display stim
    stimPatch = NaN([E.stimWidthPix,E.stimWidthPix,3]);
    currReward = 1;
    startTime = NaN(E.scheduleNumber,1);
    startTime(1) = GetSecs;
    timeAvailable = NaN(E.scheduleNumber,1);
    availability = 0;
    currClick = 0;
    lastClick = 0;
    wasClicked = 0;
    lastResponse = -1;
    while 1
        currProb = 1-exp(-(GetSecs-startTime(currReward))./E.visualScheduleList(currReward,tt));
        
        if (GetSecs-startTime(currReward))>E.timeAvailableList(currReward,tt)
            availability = 1;
            timeAvailable(currReward) = GetSecs;
        end
        
        [mousex,mousey,buttons] = GetMouse;
        if buttons(1)
            if ~wasClicked
                currClick = currClick+1;
                lastClick = GetSecs;
                clickList{currReward}(currClick) = lastClick;
                if availability
                    scoreNum = scoreNum+E.stimReward;
                    if currReward==E.scheduleNumber
                        break;
                    else
                        currReward = currReward+1;
                        availability = 0;
                        startTime(currReward) = GetSecs;
                        currClick = 0;
                    end
                    lastResponse = 1;
                    PsychPortAudio('FillBuffer', A.p, A.soundBuffer1);
                else
                    scoreNum = scoreNum+E.stimCost;
                    lastResponse = 0;
                    PsychPortAudio('FillBuffer', A.p, A.soundBuffer2);
                end
                PsychPortAudio('Start', A.p, 1, 0);
                scoreText = sprintf('%i',scoreNum);
                scoreRect = Screen('TextBounds', W.n, scoreText);
            end
            wasClicked = 1;
        else
            wasClicked = 0;
        end
        
        if (GetSecs-lastClick)<E.cursorDur
            if lastResponse
                currCol = 2;
            else
                currCol = 3;
            end
        else
            currCol = 1;
        end

        
        % compute new spectrum
%         phi = rand(E.stimWidthPix);
        tempSpectrum = (randn(E.stimWidthPix)+1i*randn(E.stimWidthPix)).*sqrt(S_f);
        newSpectrum = invk.*oldSpectrum + sqrt(1-invk.^2).*tempSpectrum;
        Xgray = ifft2(newSpectrum);
        oldSpectrum = newSpectrum;
        
        % map colors
        Xgray = E.stimIntMin + (E.stimIntMax-E.stimIntMin).*currProb + E.stimIntStd(tt)*real(Xgray)./std(real(Xgray(:)));
        stimTex = Screen('MakeTexture', W.n, min(max(Xgray,0),1).*255);
        
        Screen('DrawTexture', W.n, stimTex, [], patchRect);
        Screen('DrawTexture', W.n, winTex, [], patchRect);
        Screen('DrawDots', W.n,[mousex;mousey], E.cursorSize, E.cursorCol(:,currCol), [0,0], 2);
        Screen('DrawText', W.n, scoreText, W.center(1)+E.scorePosPix(1)-0.5*scoreRect(3), W.center(2)+E.scorePosPix(2)-0.5*scoreRect(4), 0);
        vbl = Screen('Flip', W.n, vbl+0.75*E.durFrameSec);
        if strcmp(R.subjectName,'screenshots')
            I = Screen('GetImage', W.n);
            imwrite(I,'stim.png');
        end
        
        Screen('Close', stimTex);
        
        [keyIsDown, timeResp, keyCode] = KbCheck;
        if keyIsDown
            k = find(keyCode,1);
            switch k
                case K.quit
                    ListenChar(0);
                    LoadIdentityClut(W.n);
                    Screen('CloseAll')
                    fclose(R.fid);
                    error('Interupted by user')
            end
        end 
    end
    
    
    %% blank stim
    Screen('Fillrect', W.n, W.bg*255);
    vbl = Screen('Flip', W.n, 0.75*W.ifi);
    timeBlankStim = vbl;
    if strcmp(R.subjectName,'screenshots')
        I = Screen('GetImage', W.n);
        imwrite(I,'blank2.png');
    end
    

    Screen('Close', winTex);
    
    R.startTime(:,tt) = startTime;
    R.timeAvailable(:,tt) = timeAvailable;
    R.clickList{tt} = clickList;
    
    while KbCheck; end
    
    
end

