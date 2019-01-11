


function E = foraging_schedule_setup(W)
    
    
    %% set parameters
    
    nTrialsByCond = 2;
    
    fixationColor = [ 0,0,0 ];
    fixationSizeDeg = 0.4;
    fixationThicknessDeg = 0.1;
    fixationTextDistDeg = 8;
    
    cursorSize = 20;
    cursorCol = [0,0,255;0,255,0;0,0,0];
    cursorDur = 0.1;
    
    scorePosDeg = [0,-8];
    
    stimWidthDeg = 10;
    stimIntMin = 1/3;
    stimIntMax = 2/3;
    stimIntStd = 1./[12,6,3];
    stimReward = 2;
    stimCost = -1;
    
    scheduleNumber = 20;
    scheduleTau = 4;
    scheduleVar = 0.5;
    minSchedule = 0.1;
    
    durFrameSec = 0.05;
    durFixSec = 0.5;
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
    scorePosRad = scorePosDeg*pi/180;
    stimWidthRad = stimWidthDeg*pi/180;
    
    fixationSizeCm = W.viewingDistCm*tan(fixationSizeRad);
    fixationThicknessCm = W.viewingDistCm*tan(fixationThicknessRad);
    fixationTextDistCm = W.viewingDistCm*tan(fixationTextDistRad);
    scorePosCm = W.viewingDistCm*tan(scorePosRad);
    stimWidthCm = W.viewingDistCm*tan(stimWidthRad);
    
    fixationSizePix = fixationSizeCm/W.pixSize;
    fixationThicknessPix = fixationThicknessCm/W.pixSize;
    fixationTextDistPix = fixationTextDistCm/W.pixSize;
    scorePosPix = scorePosCm/W.pixSize;
    stimWidthPix = round(stimWidthCm/W.pixSize);
    
    
    %% set up design
    
    nCond = length(stimIntStd);
    nTrials = nTrialsByCond*nCond;
    
    stdList = repmat(stimIntStd(:),nTrialsByCond,1);
    
    timeAvailableList = exprnd(scheduleTau,[scheduleNumber,nTrials]);
    visualScheduleList = max(scheduleTau+scheduleVar*randn(scheduleNumber,nTrials),minSchedule);
    
    randVec = randperm(nTrials);
	stdList = stdList(randVec);
    
    
    %% generate structure
    
    E = struct(...
        'nTrials',                      nTrials , ...
        'nTrialsByCond',                nTrialsByCond , ...
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
        'cursorSize',                   cursorSize , ...
        'cursorCol',                    cursorCol , ...
        'cursorDur',                    cursorDur , ...
        'scorePosDeg',                	scorePosDeg , ...
        'scorePosRad',                	scorePosRad , ...
        'scorePosCm',                   scorePosCm , ...
        'scorePosPix',                	scorePosPix , ...
        'stimWidthDeg',                 stimWidthDeg , ...
        'stimWidthRad',                 stimWidthRad , ...
        'stimWidthCm',                  stimWidthCm , ...
        'stimWidthPix',                 stimWidthPix , ...
        'stimIntMin',                   stimIntMin , ...
        'stimIntMax',                   stimIntMax , ...
        'stimIntStd',                   stimIntStd , ...
        'stimReward',                   stimReward , ...
        'stimCost',                     stimCost , ...
        'scheduleNumber',               scheduleNumber , ...
        'scheduleTau',                  scheduleTau , ...
        'scheduleVar',                  scheduleVar , ...
        'durFrameSec',                  durFrameSec , ...
        'durFixSec',                    durFixSec , ...
        'durItiSec',                    durItiSec , ...
        'durPauseSec',                  durPauseSec , ...
        'randVec',                      randVec , ...
        'stdList',                      stdList , ...
        'timeAvailableList',            timeAvailableList , ...
        'visualScheduleList',           visualScheduleList , ...
        'textSize',                     textSize , ...
        'textStyle',                    textStyle , ...
        'textFont',                     textFont , ...
        'textColor',                    textColor , ...
        'textFreqHz',                   textFreqHz ...
        );
    
    
end


