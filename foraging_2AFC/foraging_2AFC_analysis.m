

clear all;
close all;
clc;



cd('/Users/baptiste/Documents/MATLAB/foraging/experiments/foraging_2AFC/');


fileList = {
    'foraging_2AFC_baptisteC_12-12-2017_14-19-25'
};

nSub = length(fileList);

pffit = @(p,d) -sum(log(d(:,2).*normcdf(d(:,1),p(1),p(2))+(1-d(:,2)).*(1-normcdf(d(:,1),p(1),p(2)))));
pffit2 = @(p,d) -sum(log(d(:,7).*normcdf(d(:,1),p(1),d(:,2:6)*p(2:6))+(1-d(:,7)).*(1-normcdf(d(:,1),p(1),d(:,2:6)*p(2:6)))));

for ss=1:nSub
    load(['./data/' fileList{ss}])
    colVec = [linspace(0,1,length(E.stimConcentration))',zeros(length(E.stimConcentration),1),linspace(1,0,length(E.stimConcentration))'];
    
    for cc=1:length(E.stimConcentration)
        
        for mm=1:length(E.stimMean)
            meanResp(cc,mm) = mean(R.responseList((E.concentrationList==E.stimConcentration(cc))&(E.meanList==E.stimMean(mm))));
        end
        
        param(cc,:) = fminsearch(pffit,[0.5,0.1],[],[E.meanList(E.concentrationList==E.stimConcentration(cc)),R.responseList(E.concentrationList==E.stimConcentration(cc))]);
        
    end
    
    concMat = (repmat(E.stimConcentration,E.nTrials,1)==repmat(E.concentrationList,1,length(E.stimConcentration)));
    paramCom = fminsearch(pffit2, [0.5;1./(1:5)'],[],[E.meanList,concMat,R.responseList]);
    
    figure(1)
    subplot(1,2,1)
    hold on
    for cc=1:length(E.stimConcentration)
        plot(linspace(0,1,101),normcdf(linspace(0,1,101),param(cc,1),param(cc,2)),'Color',colVec(cc,:),'LineWidth',4)
    end
    legend(cellstr(num2str(E.stimConcentration', '%2.1e')))
    for cc=1:length(E.stimConcentration)
        plot(E.stimMean,meanResp(cc,:),'--','Color',colVec(cc,:))
    end
    xlabel('Stimulus range ([-pi/2,0])')
    ylabel('Fraction "red"')
    
    subplot(1,2,2)
    hold on
    for cc=1:length(E.stimConcentration)
        plot(linspace(0,1,101),normcdf(linspace(0,1,101),paramCom(1),paramCom(cc+1)),'Color',colVec(cc,:),'LineWidth',4)
    end
    legend(cellstr(num2str(E.stimConcentration', '%2.1e')))
    for cc=1:length(E.stimConcentration)
        plot(E.stimMean,meanResp(cc,:),'--','Color',colVec(cc,:))
    end
    xlabel('Stimulus range ([-pi/2,0])')
    ylabel('Fraction "red"')
    
end

figure(2)
plot(log(E.stimConcentration),4*param(:,2),log(E.stimConcentration),4*paramCom(2:6))
xlabel('Log concentration')
ylabel('Threshold (in rad)')
legend({'Separate PSE','Common PSE'})


figure(3)
plot(log([0.1,2]),log([0.1,2]),'k--',log(paramCom(2:6)),log(param(:,2)),'o')
