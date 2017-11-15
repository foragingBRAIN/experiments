

function R = foraging_onebutton_header(W,E)

    
    while 1
        subjectName = input('\nSubject Name? ', 's');
        if isempty(regexp(subjectName, '[/\*:?"<>|]', 'once'))
            break
        else
            fprintf('\nInvalid file name!');
        end
    end
    
    time = clock;   % [year,month,day,hour,minute,seconds]
    
    
    R.subjectName = subjectName;
    R.fileName = sprintf('%s/data/foraging_onebutton_%s_%i-%i-%i_%i-%i-%i', cd, subjectName, time(3), time(2), time(1), time(4), time(5), round(time(6)));
    
    R.fid = fopen(sprintf('%s.dat',R.fileName),'w');

    
    R.scoreList = NaN(E.nCond,1);
    R.lambdaVec = NaN(E.durTrial/W.ifi,E.nCond);
    R.availVec = NaN(E.durTrial/W.ifi,E.nCond);
    R.timeMat = NaN(E.durTrial/W.ifi+1,E.nCond);
    
    
    R.header = sprintf('%s\t','block', 'reward', 'cost', 'score');
    
end