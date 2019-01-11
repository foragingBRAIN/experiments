

clearvars
close all



dataFolder = '~/Documents/python/rPi/data/';

fileList = dir([dataFolder,'*.log']);

monkNames = {'ody','kraut','hansel','lysander','achilles'};

monkList = zeros(length(fileList),1);
taskList = zeros(length(fileList),1);
dateList = zeros(length(fileList),1);
dayList = zeros(length(fileList),1);
monthList = zeros(length(fileList),1);

for ff=1:length(fileList)
    parsed = sscanf(fileList(ff).name,'monkey%i_task%i_%i-%i-%i_%i-%i-%i.log');
    
    monkList(ff) = parsed(1);
    taskList(ff) = parsed(2);
    dateList(ff) = datenum(parsed(3),parsed(4),parsed(5),parsed(6),parsed(7),parsed(8));
    dayList(ff) = parsed(5);
    monthList(ff) = parsed(4);
end

task1list = find(taskList==1);

colTable = lines(length(task1list));
for ff=1:length(task1list)
    
    fprintf('\nFile %i/%i',ff,length(task1list));
    
    fid = fopen([dataFolder,fileList(task1list(ff)).name]);
    cc = 0;
    while 1
        line = fgets(fid);
        if line==-1
            break;
        end
        cc = cc+1;
        temp = sscanf(line,'%f,1,%i');
        timeClick{ff}(cc) = temp(1);
    end
    fclose(fid);
    
    legFields{ff} = [monkNames{monkList(task1list(ff))} ', ' [num2str(monthList(task1list(ff))) '/' num2str(dayList(task1list(ff)))]];
    
    figure(1)
    hold on
    plot(timeClick{ff}',ff*ones(size(timeClick{ff}))','o','Color',colTable(ff,:))
    
    figure(2)
    hold on
    plot(timeClick{ff}',(1:length(timeClick{ff}))./length(timeClick{ff}),'Color',colTable(ff,:))
    
    figure(3)
    hold on
    [vv(ff,:),bb(ff,:)] = hist(timeClick{ff}(2:end)-timeClick{ff}(1:end-1),linspace(0,50,41));
    plot(bb(ff,:),vv(ff,:)./(length(timeClick{ff})-1),'Color',colTable(ff,:))
    
end

figure(1)
axis([0,2000,0,7])
legend(legFields)
xlabel('Time (sec)')
ylabel('Session')

figure(2)
axis([0,2000,0,1])
legend(legFields)

figure(3)
legend(legFields)
hold on
plot(mean(bb),mean(vv)./48,'k','LineWidth',4)
xlabel('Inter-clicks interval (sec)')
ylabel('Density')

figure(4)
bar(bb',vv'./48,'EdgeColor','none')
    


