

clearvars
close all



dataFolder = '~/Documents/python/rPi/data/';

fileList = dir(dataFolder);
fileList(1:3) = [];

monkNames = {'ody','kraut','hansel','lysander','achilles'};
typeNames = {'log','data'};

monkList = zeros(length(fileList),1);
taskList = zeros(length(fileList),1);
typeList = zeros(length(fileList),1);
dateList = cell(length(fileList),1);

for ff=1:length(fileList)
    
    parsInd = strfind(fileList(ff).name,'_');
    
    temp = fileList(ff).name(1:parsInd(1)-1);
    for mm=1:length(monkNames)
        if strcmp(monkNames{mm},temp)
                monkList(ff) = mm;
            break
        end
    end
    
    taskList(ff) = str2double(fileList(ff).name(parsInd(2)-1));
    
    temp = fileList(ff).name(parsInd(2)+1:parsInd(3)-1);
    for tt=1:length(typeNames)
        if strcmp(typeNames{tt},temp)
                typeList(ff) = tt;
            break
        end
    end
    
    dateList{ff} = fileList(ff).name(parsInd(3)+1:parsInd(4)-1);
    
end

task1list = find((taskList==1)&(typeList==1));

colTable = lines(length(task1list));
for ff=1:length(task1list)
    
    fprintf('\nFile %i/%i',ff,length(task1list));
    
    fid = fopen([dataFolder,fileList(task1list(ff)).name]);
    cc = 0;
    while 1
        line = fgets(fid);
        if ~(line==-1)
            cc = cc+1;
            timeClick{ff}(cc) = str2double(line(1:find(line==' ',1)));
        else
            break
        end
    end
    fclose(fid);
    
    figure(1)
    hold on
    plot(timeClick{ff}',ff*ones(size(timeClick{ff}))','o','Color',colTable(ff,:))
    legFields{ff} = [monkNames{monkList(task1list(ff))} ', ' dateList{task1list(ff)}];
    
    figure(2)
    hold on
    plot(timeClick{ff}',(1:49)./49,'Color',colTable(ff,:))
    legFields{ff} = [monkNames{monkList(task1list(ff))} ', ' dateList{task1list(ff)}];
    
    figure(3)
    hold on
    [vv(ff,:),bb(ff,:)] = hist(timeClick{ff}(2:end)-timeClick{ff}(1:end-1),linspace(0,50,41));
%     bar(bb(ff,:),vv(ff,:)./48,'FaceColor',colTable(ff,:),'EdgeColor','none')
    plot(bb(ff,:),vv(ff,:)./48,'Color',colTable(ff,:))
    
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
    


