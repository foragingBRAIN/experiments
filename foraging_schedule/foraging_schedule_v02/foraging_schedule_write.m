


function textLine = foraging_schedule_write(E,R,tt)


    textLine = sprintf('\n%i\t%2.1f\t%2.1f\t%2.2f\t%i\t%2.2f',...
        tt, E.durList(tt), E.meanList(tt), E.concentrationList(tt), R.responseList(tt), R.rtList(tt));
    

end