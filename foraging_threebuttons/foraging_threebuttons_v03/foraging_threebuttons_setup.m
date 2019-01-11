


function E = foraging_threebuttons_setup(W)
    
    
    %% set parameters
    
    nTrials = 10;
    
    fixationColor = [ 0,0,0 ; 1,1,1 ];
    fixationSizeDeg = 0.4;
    fixationThicknessDeg = 0.1;
    fixationTextDistDeg = 8;
    
    stimNumber = 20;
    stimLambdaStart = 0.5;
    stimTau = 0.5;
    stimRepl = [0.1,0.2,0.4];
    stimDepl = [0.8,0.5,0.2];
    stimReward = +2;
    stimCost = -1;
    stimWidthDeg = 4;
    stimDistDeg = 4;
    stimRange = 0.25;
    stimConcentration = exp(-2);
    
    targetSizeDeg = 0.2;
    targetColor = [0,0,0];
    
    cursorSizeDeg = 0.4;
    cursorColor = [255,255,255;0,255,0;255,0,0];
    cursorSpeedDegSec = 4;
    
    durFixSec = 0.5;
    durFrameSec = 0.05;
    durTrial = 30;
    durItiSec = 0.5;
    durPauseSec = 5;
    
    textSize = 32;
    textStyle = 0;
    textFont = 'Arial';
    textColor = 255;
    textFreqHz = 1;
    
    
    %% convert units
    
    fixationSizeRad = fixationSizeDeg*pi/180;
    fixationThicknessRad = fixationThicknessDeg*pi/180;
    fixationTextDistRad = fixationTextDistDeg*pi/180;
    stimWidthRad = stimWidthDeg*pi/180;
    stimDistRad = stimDistDeg*pi/180;
    cursorSizeRad = cursorSizeDeg*pi/180;
	cursorSpeedRadSec = cursorSpeedDegSec*pi/180;
    targetSizeRad = targetSizeDeg*pi/180;
    
    fixationSizeCm = W.viewingDistCm*tan(fixationSizeRad);
    fixationThicknessCm = W.viewingDistCm*tan(fixationThicknessRad);
    fixationTextDistCm = W.viewingDistCm*tan(fixationTextDistRad);
    stimWidthCm = W.viewingDistCm*tan(stimWidthRad);
    stimDistCm = W.viewingDistCm*tan(stimDistRad);
    cursorSizeCm = W.viewingDistCm*tan(cursorSizeRad);
    cursorSpeedCmSec = W.viewingDistCm*tan(cursorSpeedRadSec);
    targetSizeCm = W.viewingDistCm*tan(targetSizeRad);
    
    fixationSizePix = fixationSizeCm/W.pixSize;
    fixationThicknessPix = fixationThicknessCm/W.pixSize;
    fixationTextDistPix = fixationTextDistCm/W.pixSize;
    stimWidthPix = round(stimWidthCm/W.pixSize);
    stimDistPix = stimDistCm/W.pixSize;
    cursorSizePix = cursorSizeCm/W.pixSize;
    cursorSpeedPixSec = cursorSpeedCmSec/W.pixSize;
    targetSizePix = targetSizeCm/W.pixSize;
    
    cursorSpeedPixFrames = cursorSpeedPixSec*durFrameSec;
    
    
    %% set up design
    
    replList = NaN(nTrials,3);
    deplList = NaN(nTrials,3);
    for tt=1:nTrials
        replList(tt,:) = randi(3,[1,3]);
        deplList(tt,:) = randi(3,[1,3]);
    end
    
    
    %% generate structure
    
    E = struct(...
        'nTrials',                      nTrials , ....
        'fixationColor',                fixationColor , ...
        'fixationSizeDeg',              fixationSizeDeg , ...
        'fixationThicknessDeg',         fixationThicknessDeg , ...
        'fixationTextDistDeg',          fixationTextDistDeg , ...
        'fixationSizeRad',              fixationSizeRad , ...
        'fixationThicknessRad',         fixationThicknessRad , ...
        'fixationTextDistRad',          fixationTextDistRad , ...
        'fixationSizeCm',               fixationSizeCm , ...
        'fixationThicknessCm',          fixationThicknessCm , ...
        'fixationTextDistCm',           fixationTextDistCm' , ...
        'fixationSizePix',              fixationSizePix , ...
        'fixationThicknessPix',         fixationThicknessPix , ...
        'fixationTextDistPix',        	fixationTextDistPix , ...
        'stimNumber',                   stimNumber , ...
        'stimLambdaStart',              stimLambdaStart , ...
        'stimTau',                      stimTau , ...
        'stimRepl',                     stimRepl , ...
        'stimDepl',                     stimDepl , ...
        'stimReward',                   stimReward , ...
        'stimCost',                     stimCost , ...
        'stimWidthDeg',                 stimWidthDeg , ...
        'stimDistDeg',                  stimDistDeg , ...
        'stimWidthRad',                 stimWidthRad , ...
        'stimDistRad',                  stimDistRad , ...
        'stimWidthCm',                  stimWidthCm , ...
        'stimDistCm',                   stimDistCm , ...
        'stimWidthPix',                 stimWidthPix , ...
        'stimDistPix',                  stimDistPix , ...
        'stimRange',                    stimRange , ...
        'stimConcentration',            stimConcentration , ...
        'cursorColor',                  cursorColor , ...
        'cursorSizeDeg',              	cursorSizeDeg , ...
        'cursorSizeRad',              	cursorSizeRad , ...
        'cursorSizeCm',               	cursorSizeCm , ...
        'cursorSizePix',              	cursorSizePix , ...
        'cursorSpeedDegSec',          	cursorSpeedDegSec , ...
        'cursorSpeedRadSec',        	cursorSpeedRadSec , ...
        'cursorSpeedCmSec',           	cursorSpeedCmSec , ...
        'cursorSpeedPixSec',        	cursorSpeedPixSec , ...
        'cursorSpeedPixFrames',        	cursorSpeedPixFrames , ...
        'targetColor',                  targetColor , ...
        'targetSizeDeg',              	targetSizeDeg , ...
        'targetSizeRad',              	targetSizeRad , ...
        'targetSizeCm',               	targetSizeCm , ...
        'targetSizePix',              	targetSizePix , ...
        'durFixSec',                    durFixSec , ...
        'durFrameSec',                  durFrameSec , ...
        'durTrial',                     durTrial , ...
        'durItiSec',                    durItiSec , ...
        'durPauseSec',                  durPauseSec , ...
        'replList',                     replList , ...
        'deplList',                     deplList , ...
        'textSize',                     textSize , ...
        'textStyle',                    textStyle , ...
        'textFont',                     textFont , ...
        'textColor',                    textColor , ...
        'textFreqHz',                   textFreqHz ...
        );
    
    
end

