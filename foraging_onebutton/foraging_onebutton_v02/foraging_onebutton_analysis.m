

clear all;
close all;
clc;



cd('/Users/baptiste/Documents/MATLAB/foraging/foraging_onebutton/foraging_onebutton_v02/');



fileList = {
%     'foraging_onebutton_test_10-11-2017_18-23-37'
    'foraging_onebutton_test_10-11-2017_18-40-18'
};

nSub = length(fileList);

deplCol = [0,0,1;0.5,0,0.5;1,0,0];

for su=1:nSub
    
    load(sprintf('%s/data/%s',cd,fileList{su}));
    
    scoreMat = NaN(length(E.stimRepl),length(E.stimDepl),length(E.stimCost));
    
    for rr=1:length(E.stimRepl)
        for dd=1:length(E.stimDepl)
            for cc=1:length(E.stimCost)
                scoreMat(rr,dd,cc) = R.scoreList((E.replList==rr)&(E.deplList==dd)&(E.costList==cc));
            end
        end
    end
    
    figure(1)
    hold on
    for cc=1:length(E.stimCost)
        for dd=1:length(E.stimDepl)
            plot(E.stimRepl,scoreMat(:,dd,cc),'Color',deplCol(dd,:))
        end
    end
    
    figure(2)
    for rr=1:length(E.stimRepl)
        for dd=1:length(E.stimDepl)
            subplot(length(E.stimRepl),1,rr)
            hold on
            plot(1:size(R.lambdaVec,1),R.lambdaVec(:,(E.replList==rr)&(E.deplList==dd)),'Color',deplCol(dd,:))
        end
        axis([1,size(R.lambdaVec,1),0,1])
    end
    
end



