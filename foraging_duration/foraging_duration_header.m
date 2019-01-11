

function R = foraging_duration_header(E,platform)

    
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
    R.fileName = sprintf('%s/data/foraging_duration_%s_%i-%i-%i_%i-%i-%i', cd, subjectName, time(3), time(2), time(1), time(4), time(5), round(time(6)));
    
    R.fid = fopen(sprintf('%s.dat',R.fileName),'w');
    
    
    R.responseList =  NaN(E.nTrials,1);
    R.rtList = NaN(E.nTrials,1);
    R.timeMat = NaN(E.nTrials,5);
    R.correctList = NaN(E.nTrials,1);
    
    R.header = sprintf('%s\t','trial', 'dur', 'mean', 'conc', 'resp', 'rt');
    
end