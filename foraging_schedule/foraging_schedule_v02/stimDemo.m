
% parameters
stimSize = 500;
stimIntMin = 1/3;
stimIntMax = 2/3;
stimIntStd = 1/6;
scheduleTau = 2;


%% compute textures
% texture spectrum
beta = -2;
spect_u = [(0:floor(stimSize/2)) -(ceil(stimSize/2)-1:-1:1)]'/stimSize;
spect_u = repmat(spect_u,1,stimSize);
spect_v = [(0:floor(stimSize/2)) -(ceil(stimSize/2)-1:-1:1)]/stimSize;
spect_v = repmat(spect_v,stimSize,1);
S_f = (spect_u.^2 + spect_v.^2).^(beta/2);
S_f(S_f==inf) = 0;

oldSpectrum = (randn(stimSize)+1i*randn(stimSize)).*sqrt(S_f);

% time freq weighting
speedChange = 2;
k = sqrt(spect_u.^2 + spect_v.^2);
invk = exp(-k.*speedChange);
invk(isinf(invk)) = 0;


tic;
while 1
    currProb = 1-exp(-toc./scheduleTau);
    
    % compute new spectrum
    tempSpectrum = (randn(stimSize)+1i*randn(stimSize)).*sqrt(S_f);
    newSpectrum = invk.*oldSpectrum + sqrt(1-invk.^2).*tempSpectrum;
    Xgray = ifft2(newSpectrum);
    Xgray = stimIntMin + (stimIntMax-stimIntMin).*currProb + stimIntStd*real(Xgray)./std(real(Xgray(:))); 
    
    oldSpectrum = newSpectrum;
    
    figure(1)
    imshow(min(max(Xgray,0),1))
    drawnow;
end
