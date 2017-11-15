

function R = foraging_twobuttons_trial(W,L,A,K,E,R,bb)
    

    currScore = 0;
    scoreBounds = Screen('TextBounds', W.n, sprintf('%i',currScore));  
    
    Screen('FillRect', W.n, W.bg*255);
    Screen('DrawText', W.n, sprintf('%i',currScore), W.center(1)-0.5*scoreBounds(3), W.center(2)-200, 0);
    vbl = Screen('Flip', W.n, 0);
    timeStart = vbl;
    if strcmp(R.subjectName,'screenshots')
        I = Screen('GetImage', W.n);
        imwrite(I,'fixation.png');
    end
    
    % textures spectrum
    beta = -2;
    spect_u = [(0:floor(E.stimWidthPix/2)) -(ceil(E.stimWidthPix/2)-1:-1:1)]'/E.stimWidthPix;
    spect_u = repmat(spect_u,1,ceil(E.stimWidthPix));
    spect_v = [(0:floor(E.stimWidthPix/2)) -(ceil(E.stimWidthPix/2)-1:-1:1)]/E.stimWidthPix;
    spect_v = repmat(spect_v,ceil(E.stimWidthPix),1);
    S_f = (spect_u.^2 + spect_v.^2).^(beta/2);
	S_f(S_f==inf) = 0;
            
    % window
    [x,y] = meshgrid(1:ceil(E.stimWidthPix),1:ceil(E.stimWidthPix));
    d = sqrt((x-0.5*(ceil(E.stimWidthPix)+1)).^2+(y-0.5*(ceil(E.stimWidthPix)+1)).^2);
    windowmat(:,:,1:3) = repmat(W.bg*ones(ceil(E.stimWidthPix),ceil(E.stimWidthPix)),[1,1,3]);
    windowmat(:,:,4) = normcdf(d,0.45*ceil(E.stimWidthPix),0.02*E.stimWidthPix);
    winTex = Screen('MakeTexture', W.n, 255*windowmat);
    
    % patch coord
    patchRect = NaN(2,4);
    for ss=1:2
        patchRect(ss,:) = [W.center,W.center] +2*(ss-1.5)*E.stimDistPix*[1,0,1,0] +0.5*round(E.stimWidthPix)*[-1,-1,+1,+1];
    end
    
    while mouseCheck; end
    
    
    cursorx = W.center(1);  cursory = W.center(2);
    currColor = 1;
    currClick = 0;
    wasClicked = 0;
    
    lambdaVec = NaN(E.durTrial/W.ifi,2);
    availVec = NaN(E.durTrial/W.ifi,2);
    timeFrames = NaN(E.durTrial/W.ifi,1);
    
    for frameNum=1:(E.durTrial/W.ifi)
        
        % compute lambdas
        for ss=1:2
            if frameNum>1
                lambdaVec(frameNum,ss) = lambdaVec(frameNum-1,ss)+E.stimDepl*(1-lambdaVec(frameNum-1,ss))*W.ifi;
            else
                lambdaVec(frameNum,ss) = E.stimLambdaStart;
                availVec(frameNum,:) = 0;
            end
        end
        
        % switch process
        pup = [1,1]./E.stimTau;
        pdown = pup.*(1-lambdaVec(frameNum,:))./lambdaVec(frameNum,:);
        
        for ss=1:2
            if frameNum>1
                if ~availVec(frameNum-1,ss)
                    if rand<(pup(ss)*W.ifi)
                        availVec(frameNum,ss) = 1;
                    else
                        availVec(frameNum,ss) = 0;
                    end
                elseif availVec(frameNum-1,ss)
                    if rand<(pdown(ss)*W.ifi)
                        availVec(frameNum,ss) = 0;
                    else
                        availVec(frameNum,ss) = 1;
                    end
                end
            else
                availVec(frameNum,ss) = 0;
            end
        end
        
        % get responses
        [targetx,targety,buttons] = GetMouse;
        cursdist = sqrt((targetx-cursorx).^2+(targety-cursory).^2);
        cursangle = atan2((targety-cursory),(targetx-cursorx));
        cursorx = cursorx + min(cursdist,E.cursorSpeedPixFrames).*cos(cursangle);
        cursory = cursory + min(cursdist,E.cursorSpeedPixFrames).*sin(cursangle);
        
        if buttons(1)
            if ~wasClicked
                for ss=1:2
                    if ((cursorx-W.center(1)-2*(ss-1.5)*E.stimDistPix)^2 + (cursory-W.center(2))^2) < (0.5*E.stimWidthPix)^2
                        if availVec(frameNum,ss)
                            currColor = 2;
                            currScore = currScore+E.stimReward;
                            currClick = currClick+1;
                            R.clickTimes{bb}(currClick) = GetSecs;
                            R.clickRewards{bb}(currClick) = 1;
                            PsychPortAudio('FillBuffer', A.p, A.feedback1);

                            availVec(frameNum,ss) = 0;
                            lambdaVec(frameNum,ss) = lambdaVec(frameNum-1,ss)*(1-E.stimDepl);
                        else
                            currColor = 3;
                            currScore = currScore+E.stimCost(E.costList(bb));
                            currClick = currClick+1;
                            R.clickTimes{bb}(currClick) = GetSecs;
                            R.clickRewards{bb}(currClick) = 0;
                            PsychPortAudio('FillBuffer', A.p, A.feedback2);
                        end
                        scoreBounds = Screen('TextBounds', W.n, sprintf('%i',currScore));
                        PsychPortAudio('Start', A.p, 1, 0, 0);
                    end
                end
            end
            wasClicked = 1;
        else
            wasClicked = 0;
            currColor = 1;
        end
        
        % generate textures
        currNoise = E.stimNoise*frameNum./(E.durTrial/W.ifi);
        stimPatch = NaN([ceil(E.stimWidthPix),ceil(E.stimWidthPix),3,2]);
        stimTex = cell(1,2);
        for ss=1:2
            phi = rand(ceil(E.stimWidthPix));
            Xgray = ifftn(sqrt(S_f).*cos(2*pi*phi) + 1i.*sqrt(S_f).*sin(2*pi*phi));
            Xgray = real(Xgray);
            Xgray = -((1-lambdaVec(frameNum,ss))*E.stimRange + Xgray(:)*currNoise*E.stimRange./std(Xgray(:)));
            Xgray = mod(round(Xgray*L.clutpoints),L.clutpoints);
            Xgray(Xgray<=0) = L.clutpoints+Xgray(Xgray<=0);
            for cc=1:3
                stimPatch(:,:,cc,ss) = reshape(L.Xrgb(cc,Xgray),ceil(E.stimWidthPix),ceil(E.stimWidthPix));
            end
            stimTex{ss} = Screen('MakeTexture', W.n, stimPatch(:,:,:,ss));
        end
        
            
        Screen('FillRect', W.n, W.bg*255);
        for ss=1:2
            Screen('DrawTexture', W.n, stimTex{ss}, [], patchRect(ss,:));
            Screen('DrawTexture', W.n, winTex, [], patchRect(ss,:));
        end
        Screen('DrawDots', W.n, [targetx,cursorx;targety,cursory], [E.targetSizePix,E.cursorSizePix], [E.targetColor;E.cursorColor(currColor,:)]', [0,0], 2);
        Screen('DrawText', W.n, sprintf('%i',currScore), W.center(1)-0.5*scoreBounds(3), W.center(2)-200, 0);
        vbl = Screen('Flip', W.n, timeStart+E.durFixSec+(frameNum-0.25)*W.ifi);
        timeFrames(frameNum) = vbl;
        
        for ss=1:2
            Screen('Close', stimTex{ss});
        end
        
        [keyIsDown,~,keyCode] = KbCheck;
        if keyIsDown
            k = find(keyCode,1);
            switch k
                case K.quit
                    ListenChar(0);
                    Screen('CloseAll');
                    error('Interupted by user');
            end
        end
        
    end
    
    R.scoreList(bb) = currScore;
    
    R.lambdaVec(:,:,bb) = lambdaVec;
    R.availVec(:,:,bb) = availVec;
    R.timeMat(bb,:) = [timeStart;timeFrames];
    
    Screen('Close', winTex);
    
    while (KbCheck||mouseCheck); end
    
end

