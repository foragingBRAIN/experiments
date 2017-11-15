

function buttonPressed = mouseCheck

    [~,~,buttons] = GetMouse;
    buttonPressed = sum(buttons)>0;
    
end