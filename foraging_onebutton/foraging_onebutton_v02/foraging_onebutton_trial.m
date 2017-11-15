

function R = foraging_onebutton_trial(W,L,A,K,E,R,bb)
    

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
    
    % compute rect
    patchRect = [W.center,W.center] + 0.5*round(E.stimWidthPix)*[-1,-1,+1,+1];
    
    
    
    while mouseCheck; end
    
    
    currColor = 1;
    currClick = 0;
    wasClicked = 0;
    
    timeFrames = NaN(E.durTrial/W.ifi,1);
    lambdaVec = NaN(E.durTrial/W.ifi,1);
    availVec = NaN(E.durTrial/W.ifi,1);
    avail = 0;
    
    for frameNum=1:(E.durTrial/W.ifi)
        
        if frameNum>1
        	lambdaVec(frameNum) = lambdaVec(frameNum-1)+E.stimRepl(E.replList(bb))*(1-lambdaVec(frameNum-1))*W.ifi;
        else
            lambdaVec(frameNum) = E.stimLambdaStart;
        end
        
        [cursorx,cursory,buttons] = GetMouse;
        
        if buttons(1)
            if ~wasClicked
                if avail
                    currColor = 2;
                    currScore = currScore+E.stimReward;
                    currClick = currClick+1;
                    R.clickTimes{bb}(currClick) = GetSecs;
                    R.clickRewards{bb}(currClick) = 1;
                    PsychPortAudio('FillBuffer', A.p, A.feedback1);
                    
                    avail = 0;
                    lambdaVec(frameNum) = lambdaVec(frameNum-1)*(1-E.stimDepl(E.deplList(bb)));
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
            wasClicked = 1;
        else
            wasClicked = 0;
            currColor = 1;
        end
        
        pup = 1./E.stimTau;
        pdown = pup.*(1-lambdaVec(frameNum))./lambdaVec(frameNum);
        
        if ~avail && rand<(pup*W.ifi)
            avail = 1;
        elseif avail && rand<(pdown*W.ifi)
            avail = 0;
        end
        availVec(frameNum) = avail;
        
        
        % generate textures
        currNoise = E.stimNoise*frameNum./(E.durTrial/W.ifi);
        stimPatch = NaN([ceil(E.stimWidthPix),ceil(E.stimWidthPix),3]);
        
        phi = rand(ceil(E.stimWidthPix));
        Xgray = ifftn(sqrt(S_f).*cos(2*pi*phi) + 1i.*sqrt(S_f).*sin(2*pi*phi));
        Xgray = real(Xgray);
        Xgray = -((1-lambdaVec(frameNum))*E.stimRange + Xgray(:)*currNoise*E.stimRange./std(Xgray(:)));
        Xgray = mod(round(Xgray*L.clutpoints),L.clutpoints);
        Xgray(Xgray<=0) = L.clutpoints+Xgray(Xgray<=0);
        for cc=1:3
            stimPatch(:,:,cc) = reshape(L.Xrgb(cc,Xgray),ceil(E.stimWidthPix),ceil(E.stimWidthPix));
        end
        stimTex = Screen('MakeTexture', W.n, stimPatch(:,:,:));

        
%         currStimColor = [lambdaVec(frameNum)*255,0,(1-lambdaVec(frameNum))*255];
        
            
        Screen('FillRect', W.n, W.bg*255);
        Screen('DrawTexture', W.n, stimTex, [], patchRect);
        Screen('DrawTexture', W.n, winTex, [], patchRect);
        Screen('DrawDots', W.n, [cursorx;cursory], E.cursorSizePix, E.cursorColor(currColor,:), [0,0], 2);
        Screen('DrawText', W.n, sprintf('%i',currScore), W.center(1)-0.5*scoreBounds(3), W.center(2)-200, 0);
        vbl = Screen('Flip', W.n, timeStart+E.durFixSec+(frameNum-0.25)*W.ifi);
        
        timeFrames(frameNum) = vbl;
        
    end
    
    R.scoreList(bb) = currScore;
    
    R.lambdaVec(:,bb) = lambdaVec;
    R.availVec(:,bb) = availVec;
    R.timeMat(:,bb) = [timeStart;timeFrames];
    
    while (KbCheck||mouseCheck); end
    
end

