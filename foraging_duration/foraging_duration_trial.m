

function R = foraging_duration_trial(W,L,A,K,E,R,tt)
    
    
    %% display fixation

    fixRect = [W.center-0.5*E.fixationSizePix,W.center+0.5*E.fixationSizePix];
    
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
    
    oldSpectrum = (randn(E.stimWidthPix) + 1i*randn(E.stimWidthPix)) .* sqrt(S_f);
    
    % time freq weighting
    speedchange = 20;
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
    vbl = Screen('Flip', W.n, vbl+E.durFixSec-0.25*W.ifi);
    timeBlankFix = vbl;
    if strcmp(R.subjectName,'screenshots')
        I = Screen('GetImage', W.n);
        imwrite(I,'blank1.png');
    end
    
    
    %% display stim
    stimPatch = NaN([E.stimWidthPix,E.stimWidthPix,3]);
    timeStim = NaN(E.durList(tt)/W.ifi,1);
    for ff=1:(E.durList(tt)/W.ifi)
        % compute new spectrum
        tempSpectrum = (randn(E.stimWidthPix) + 1i*randn(E.stimWidthPix)) .* sqrt(S_f);
        newSpectrum = invk.*oldSpectrum + sqrt(1-invk.^2).*tempSpectrum;
        Xgray = ifft2(newSpectrum);
        oldSpectrum = newSpectrum;
        
        % map colors
        Xgray = angle(Xgray + E.concentrationList(tt).*exp(1i.*(-0.5*pi+0.5*E.meanList(tt)*pi)));
        Xgray = 0.5.*Xgray./pi + (Xgray<=0);
        
        for cc=1:3
            stimPatch(:,:,cc) = reshape(L.Xrgb(cc,ceil(Xgray*L.clutpoints)),E.stimWidthPix,E.stimWidthPix);
        end
        stimTex = Screen('MakeTexture', W.n, stimPatch);
        
        Screen('DrawTexture', W.n, stimTex, [], patchRect);
        Screen('DrawTexture', W.n, winTex, [], patchRect);
        vbl = Screen('Flip', W.n, timeBlankFix+E.durGapSec+(ff-1.25)*E.durFrameSec);
        timeStim(ff) = vbl;
        if strcmp(R.subjectName,'screenshots')
            I = Screen('GetImage', W.n);
            imwrite(I,'stim.png');
        end
        
        Screen('Close', stimTex);
    end
    
    
    %% blank stim
    Screen('Fillrect', W.n, W.bg*255);
    vbl = Screen('Flip', W.n, timeBlankFix+E.durGapSec+E.durList(tt)-0.25*W.ifi);
    timeBlankStim = vbl;
    if strcmp(R.subjectName,'screenshots')
        I = Screen('GetImage', W.n);
        imwrite(I,'blank2.png');
    end
    
    
    %% get response
    while 1
        
        Screen('FillRect', W.n, W.bg*255);
        Screen('FrameRect', W.n,  E.fixationColor*255, fixRect, E.fixationThicknessPix);
        Screen('Flip', W.n);
        
        [keyIsDown, timeResp, keyCode] = KbCheck;
        if keyIsDown
            k = find(keyCode,1);
            switch k
                case K.left % blue
                    R.responseList(tt) = 0;
                    break
                case K.right % red
                    R.responseList(tt) = +1;
                    break
                case K.quit
                    ListenChar(0);
                    LoadIdentityClut(W.n);
                    Screen('CloseAll')
                    fclose(R.fid);
                    error('Interupted by user')
            end
        end 
    end
    
    
    R.rtList(tt) = timeResp-timeStim(end);
    R.timeMat(tt,:) = [timeStart,timeBlankFix,timeStim(end),timeBlankStim,timeResp];
    R.timeStim{tt} = timeStim-(timeBlankFix+E.durGapSec);
    
    
    R.correctList(tt) = (R.responseList(tt)==(E.meanList(tt)>0.5));

    if R.correctList(tt)
        PsychPortAudio('FillBuffer', A.p, A.soundBuffer1);
    else
        PsychPortAudio('FillBuffer', A.p, A.soundBuffer2);
    end
    PsychPortAudio('Start', A.p, 1, 0);

    Screen('Close', winTex);
    
    while KbCheck; end
    
    
end

