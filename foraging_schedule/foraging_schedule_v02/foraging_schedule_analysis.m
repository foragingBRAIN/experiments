

clear all;
close all;
clc;



cd('/Users/baptiste/Documents/MATLAB/foraging/experiments/foraging_schedule/');


fileList = {
%     'foraging_schedule_test_29-5-2018_17-33-39'
%     'foraging_schedule_test_29-5-2018_19-43-14'
%     'foraging_schedule_baptisteC_30-5-2018_22-41-3'
    'foraging_schedule_henryS_31-5-2018_15-56-46'
};

nSub = length(fileList);
nbstrp = 1000;

nCond = 5;

colMat = [linspace(0,1,nCond);zeros(1,nCond);linspace(1,0,nCond)]';
for cc=1:nCond
    schedVec{cc} = [];
end

for su=1:nSub
    load(['./data/' fileList{su}])
    
    for tt=1:E.nTrials
        
        temp1 = [];
        for ss=1:E.scheduleNumber
%             temp1 = [temp1;[E.visualScheduleList(ss,tt)*ones(length(R.clickList{tt}{ss}),1)-E.scheduleTau,R.clickList{tt}{ss}'-R.startTime(ss,tt)]];
            temp1 = [temp1;[E.visualScheduleList(ss,tt)-E.scheduleTau,R.clickList{tt}{ss}(1)-R.startTime(ss,tt)]];
        end
        
        trialCond = find(E.stimConcentration(1:nCond)==E.concentrationList(tt));
%         if (trialCond~=5)
            schedVec{trialCond} = [schedVec{trialCond};temp1];
%         end
        
    end
    
end

for cc=1:nCond
    temp1 = schedVec{cc};
    corrList(cc) = diag(corr(temp1),-1);
    for bb=1:nbstrp
        temp2(bb) = diag(corr(temp1(ceil(size(temp1,1)*rand(size(temp1,1),1)),:)),-1);
    end

    medianRT(cc) = median(temp1(:,2));
    stdRT(cc) = std(temp1(:,2));
    
    corrbstrp(:,cc) = sort(temp2);
    [ppar(cc,:),pint(:,:,cc)] = regress(temp1(:,2),[temp1(:,1),ones(size(temp1,1),1)]);
%     ppar(cc,:) = robustfit(temp1(:,1),temp1(:,2));

    figure(1)
    subplot(2,3,cc)
    plot(schedVec{cc}(:,1),schedVec{cc}(:,2),'.',[-2,+2],polyval(ppar(cc,:),[-2,+2]),'Color',colMat(cc,:))
%     plot(schedVec{cc}(:,1),schedVec{cc}(:,2),'.',[-2,+2],polyval(fliplr(ppar(cc,:)),[-2,+2]),'Color',colMat(cc,:))
    axis([-2,+2,0,6])
    title(sprintf('Log concentration: %i',log(E.stimConcentration(cc))))
    xlabel('Perturbation');
    ylabel('First click time (sec)');
    
end

figure(10)
% subplot(1,2,1)
% plot([log(min(E.stimConcentration(1:nCond)))-1,log(max(E.stimConcentration(1:nCond)))+1],[0,0],'k--',log(E.stimConcentration(1:nCond)),corrList,'k',[log(E.stimConcentration(1:nCond));log(E.stimConcentration(1:nCond))],[corrbstrp(0.025*nbstrp,:);corrbstrp((1-0.025)*nbstrp,:)],'k')
% axis([log(min(E.stimConcentration(1:nCond)))-1,log(max(E.stimConcentration(1:nCond)))+1,-1,+1])

% subplot(1,2,2)
plot([log(min(E.stimConcentration(1:nCond)))-1,log(max(E.stimConcentration(1:nCond)))+1],[0,0],'k--',log(E.stimConcentration(1:nCond)),ppar(:,1),'k',[log(E.stimConcentration(1:nCond));log(E.stimConcentration(1:nCond))],squeeze(pint(1,:,:)),'k')
axis([log(min(E.stimConcentration(1:nCond)))-1,log(max(E.stimConcentration(1:nCond)))+1,-2,+2])
xlabel('Log stim concentration');
ylabel('Regression slope');

figure(11)
subplot(1,2,1)
plot(log(E.stimConcentration(1:nCond)),medianRT,'k')
axis([log(min(E.stimConcentration(1:nCond)))-1,log(max(E.stimConcentration(1:nCond)))+1,0,4])
xlabel('Log stim concentration');
ylabel('Median  RT');

subplot(1,2,2)
plot(log(E.stimConcentration(1:nCond)),stdRT,'k')
axis([log(min(E.stimConcentration(1:nCond)))-1,log(max(E.stimConcentration(1:nCond)))+1,0,2])
xlabel('Log stim concentration');
ylabel('STD RT');
