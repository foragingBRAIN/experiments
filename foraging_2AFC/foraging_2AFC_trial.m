

function R = foraging_2AFC_trial(W,L,A,K,E,R,tt)
    
    
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
    
    
    %% compute texture
    stimSize = round(E.stimWidthPix*E.stimScale);
    
    % texture spectrum
    beta = -2;
    spect_u = [(0:floor(stimSize/2)) -(ceil(stimSize/2)-1:-1:1)]'/stimSize;
    spect_u = gpuArray(repmat(spect_u,1,stimSize));
    spect_v = [(0:floor(stimSize/2)) -(ceil(stimSize/2)-1:-1:1)]/stimSize;
    spect_v = gpuArray(repmat(spect_v,stimSize,1));
    S_f = (spect_u.^2 + spect_v.^2).^(beta/2);
	S_f(S_f==inf) = 0;
 	
    %% Temporal weighting
    k = sqrt(spect_u.^2 + spect_v.^2);
    invk = exp(-k.*E.stimSpeedChange);
    invk(isinf(invk)) = 0;
    
    % iFFT
    oldSpectrum = (randn(stimSize,'gpuArray') + 1i*randn(stimSize,'gpuArray')) .* sqrt(S_f);
    
    stimPatch = NaN([stimSize,stimSize,3]);
    stimTex = cell(1,E.durList(tt)*W.fps);
    for ff=1:E.durList(tt)*W.fps
        if E.condList(tt)>1
        	newSpectrum = (randn(stimSize,'gpuArray') + 1i*randn(stimSize,'gpuArray')) .* sqrt(S_f);
            if E.condList(tt)==2
                oldSpectrum = invk.*oldSpectrum + sqrt(1-invk.^2).*newSpectrum;
            elseif E.condList(tt)==3
                if rem(ff,E.stimFrames)==0
                    oldSpectrum = newSpectrum;
                end
            end
        end
        
        Xmat = ifft2(oldSpectrum);
        Xmat = angle(Xmat + E.concentrationList(tt).*exp(1i.*(-0.5*pi+0.5*E.meanList(tt)*pi)));
        Xmat = gather(0.5.*Xmat./pi + (Xmat<=0));
        
        for cc=1:3
            stimPatch(:,:,cc) = reshape(L.Xrgb(cc,ceil(Xmat*L.clutpoints)),stimSize,stimSize);
        end
        stimTex{ff} = Screen('MakeTexture', W.n, stimPatch);
    end
    
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
    Screen('Fillrect', W.n, W.bg*255);
    vbl = Screen('Flip', W.n, timeBlankFix+E.durGapSec-1.25*W.ifi);
    
    frameTimes = NaN(E.durList(tt)*W.fps,1);
    for ff=1:E.durList(tt)*W.fps
        Screen('DrawTexture', W.n, stimTex{ff}, [], patchRect);
        Screen('DrawTexture', W.n, winTex, [], patchRect);
        vbl = Screen('Flip', W.n, vbl+0.75*W.ifi);
        frameTimes(ff) = vbl;
        if strcmp(R.subjectName,'screenshots')
            I = Screen('GetImage', W.n);
            imwrite(I,sprintf('stim%i.png',ff));
        end
    end
    
    
    %% blank stim
    Screen('Fillrect', W.n, W.bg*255);
    vbl = Screen('Flip', W.n, frameTimes(1)+E.durList(tt)-0.25*W.ifi);
    timeBlankStim = vbl;
    if strcmp(R.subjectName,'screenshots')
        I = Screen('GetImage', W.n);
        imwrite(I,'blank2.png');
    end
    
    
    %% get response
    while 1
        
        Screen('FillRect', W.n, W.bg*255);
        if (GetSecs-timeBlankStim)>E.durGapSec
            Screen('FrameRect', W.n,  E.fixationColor*255, fixRect, E.fixationThicknessPix);
        end
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
    
    
    R.rtList(tt) = timeResp-frameTimes(1);
    R.timeMat(tt,:) = [timeStart,timeBlankFix,frameTimes(1),timeBlankStim,timeResp];
    R.frameTimes{tt} = frameTimes;
    
    R.correctList(tt) = (R.responseList(tt)==(E.meanList(tt)>0.5));
    
    
    if R.correctList(tt)
        PsychPortAudio('FillBuffer', A.p, A.soundBuffer1);
    else
        PsychPortAudio('FillBuffer', A.p, A.soundBuffer2);
    end
    PsychPortAudio('Start', A.p, 1, 0);

    for ff=1:E.durList(tt)*W.fps
        Screen('Close', stimTex{ff});
    end
    Screen('Close', winTex);
    
    while KbCheck; end
    
    
end

