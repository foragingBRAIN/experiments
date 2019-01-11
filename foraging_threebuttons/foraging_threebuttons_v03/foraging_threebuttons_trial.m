

function R = foraging_threebuttons_trial(W,L,A,K,E,R,tt)
    

    currScore = 0;
    scoreBounds = Screen('TextBounds', W.n, sprintf('%i',currScore));  
    
    Screen('FillRect', W.n, W.bg*255);
    Screen('DrawText', W.n, sprintf('%i',currScore), W.center(1)-0.5*scoreBounds(3), W.center(2)-0.5*scoreBounds(4), 0);
    vbl = Screen('Flip', W.n, 0);
    timeStart = vbl;
    if strcmp(R.subjectName,'screenshots')
        I = Screen('GetImage', W.n);
        imwrite(I,'fixation.png');
    end
    
    % texture spectrum
    beta = -2;
    spect_u = [(0:floor(E.stimWidthPix/2)) -(ceil(E.stimWidthPix/2)-1:-1:1)]'/E.stimWidthPix;
    spect_u = repmat(spect_u,1,E.stimWidthPix);
    spect_v = [(0:floor(E.stimWidthPix/2)) -(ceil(E.stimWidthPix/2)-1:-1:1)]/E.stimWidthPix;
    spect_v = repmat(spect_v,E.stimWidthPix,1);
    S_f = (spect_u.^2 + spect_v.^2).^(beta/2);
	S_f(S_f==inf) = 0;
    
    oldSpectrum = (randn(E.stimWidthPix) + 1i*randn(E.stimWidthPix)) .* sqrt(S_f);
    
    % time freq weighting
    speedchange = 1;
    k = sqrt(spect_u.^2 + spect_v.^2);
    invk = exp(-k.*speedchange);
    invk(isinf(invk)) = 0;
    
    % window
    [x,y] = meshgrid(1:ceil(E.stimWidthPix),1:ceil(E.stimWidthPix));
    d = sqrt((x-0.5*(ceil(E.stimWidthPix)+1)).^2+(y-0.5*(ceil(E.stimWidthPix)+1)).^2);
    windowmat(:,:,1:3) = repmat(W.bg*ones(ceil(E.stimWidthPix),ceil(E.stimWidthPix)),[1,1,3]);
    windowmat(:,:,4) = normcdf(d,0.45*ceil(E.stimWidthPix),0.02*E.stimWidthPix);
    winTex = Screen('MakeTexture', W.n, 255*windowmat);
    
    % patch coord
    patchCenter = NaN(3,2);
    patchRect = NaN(3,4);
    randAngle = rand*2*pi/3;
    for ss=1:3
        patchCenter(ss,:) = [cos(randAngle+ss*2*pi/3)*E.stimDistPix , sin(randAngle+ss*2*pi/3)*E.stimDistPix];
        patchRect(ss,:) = [W.center,W.center] + [patchCenter(ss,:),patchCenter(ss,:)] + 0.5*round(E.stimWidthPix)*[-1,-1,+1,+1];
    end
    
    while MouseCheck; end
    
    
    cursorx = W.center(1);  cursory = W.center(2);
    currColor = 1;
    currClick = 0;
    wasClicked = 0;
    
    lambdaVec = NaN(E.durTrial/E.durFrameSec,3);
    availVec = NaN(E.durTrial/E.durFrameSec,3);
    timeFrames = NaN(E.durTrial/E.durFrameSec,1);
    
    stimPatch = NaN([E.stimWidthPix,E.stimWidthPix,3]);
    stimTex = cell(3,1);
    
    for frameNum=1:(E.durTrial/E.durFrameSec)
        
        % compute lambdas
        for ss=1:3
            if frameNum>1
                lambdaVec(frameNum,ss) = lambdaVec(frameNum-1,ss) + E.stimRepl(E.replList(tt,ss))*(1-lambdaVec(frameNum-1,ss))*E.durFrameSec;
            else
                lambdaVec(frameNum,ss) = E.stimLambdaStart;
                availVec(frameNum,:) = 0;
            end
        end
        
        % switch process
        pup = [1,1,1]./E.stimTau;
        pdown = pup.*(1-lambdaVec(frameNum,:))./lambdaVec(frameNum,:);
        
        for ss=1:3
            if frameNum>1
                if ~availVec(frameNum-1,ss)
                    if rand<(pup(ss)*E.durFrameSec)
                        availVec(frameNum,ss) = 1;
                    else
                        availVec(frameNum,ss) = 0;
                    end
                elseif availVec(frameNum-1,ss)
                    if rand<(pdown(ss)*E.durFrameSec)
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
                for ss=1:3
                    if ((cursorx-W.center(1)-patchCenter(ss,1))^2 + (cursory-W.center(2)-patchCenter(ss,2))^2) < (0.5*E.stimWidthPix)^2
                        if availVec(frameNum,ss)==1
                            currColor = 2;
                            currScore = currScore+E.stimReward;
                            currClick = currClick+1;
                            R.clickTimes{tt}(currClick) = GetSecs;
                            R.clickRewards{tt}(currClick) = 1;
                            PsychPortAudio('FillBuffer', A.p, A.feedback1);

                            availVec(frameNum,ss) = 0;
                            lambdaVec(frameNum,ss) = lambdaVec(frameNum,ss)*(1-E.stimDepl(E.deplList(tt,ss)));
                        else
                            currColor = 3;
                            currScore = currScore+E.stimCost;
                            currClick = currClick+1;
                            R.clickTimes{tt}(currClick) = GetSecs;
                            R.clickRewards{tt}(currClick) = 0;
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
        
        
        for ss=1:3
            % compute new spectrum
            tempSpectrum = (randn(E.stimWidthPix) + 1i*randn(E.stimWidthPix)) .* sqrt(S_f);
            newSpectrum = invk.*oldSpectrum + sqrt(1-invk.^2).*tempSpectrum;
            Xgray = ifft2(newSpectrum);
            oldSpectrum = newSpectrum;

            % map colors
            Xgray = angle(Xgray + E.stimConcentration.*exp(1i.*(-0.5*pi+0.5*lambdaVec(frameNum,ss)*pi)));
            Xgray = 0.5.*Xgray./pi + (Xgray<=0);

            for cc=1:3
                stimPatch(:,:,cc) = reshape(L.Xrgb(cc,ceil(Xgray*L.clutpoints)),E.stimWidthPix,E.stimWidthPix);
            end
            stimTex{ss} = Screen('MakeTexture', W.n, stimPatch(:,:,:));
        end
        
            
        Screen('FillRect', W.n, W.bg*255);
        for ss=1:3
            Screen('DrawTexture', W.n, stimTex{ss}, [], patchRect(ss,:));
            Screen('DrawTexture', W.n, winTex, [], patchRect(ss,:));
        end
        Screen('DrawDots', W.n, [targetx,cursorx;targety,cursory], [E.targetSizePix,E.cursorSizePix], [E.targetColor;E.cursorColor(currColor,:)]', [0,0], 2);
        Screen('DrawText', W.n, sprintf('%i',currScore), W.center(1)-0.5*scoreBounds(3), W.center(2)-0.5*scoreBounds(4), 0);
        vbl = Screen('Flip', W.n, timeStart+E.durFixSec+(frameNum-0.25)*E.durFrameSec);
        timeFrames(frameNum) = vbl;
        
        for ss=1:3
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
    
    R.scoreList(tt) = currScore;
    
    R.lambdaVec(:,:,tt) = lambdaVec;
    R.availVec(:,:,tt) = availVec;
    R.timeMat(tt,:) = [timeStart;timeFrames];
    
    Screen('Close', winTex);
    
    while (KbCheck||MouseCheck); end
    
end
