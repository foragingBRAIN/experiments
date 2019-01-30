


function textLine = foraging_2AFC_write(E,R,tt)


    textLine = sprintf('\n%i\t%i\t%2.1f\t%2.1f\t%2.2f\t%i\t%2.2f',...
        tt, E.condList(tt), E.durList(tt), 100*E.meanList(tt), 100*E.concentrationList(tt), R.responseList(tt), R.rtList(tt));
    

end