


function textLine = foraging_onebutton_write(E,R,bb)

    
    textLine = sprintf('\n%i\t%2.1f\t%2.2f\t%i\t%i\t%i',...
        bb, E.stimRate(E.rateList(bb))*60, mean(R.clickDelay{bb}), E.stimReward, E.stimCost(E.costList(bb)), R.scoreList(bb));
    

end