

function K = foraging_2AFC_keys(platform)


    switch platform
        case 0
            K.left = KbName('LeftArrow');
            K.right = KbName('RightArrow');
            K.up = KbName('UpArrow');
            K.down = KbName('DownArrow');
            K.quit = KbName('ESCAPE');
        case 1
            K.left = KbName('Left');
            K.right = KbName('Right');
            K.up = KbName('Up');
            K.down = KbName('Down');
            K.quit = KbName('esc');
        case 2
            K.left = KbName('Left');
            K.right = KbName('Right');
            K.up = KbName('Up');
            K.down = KbName('Down');
            K.quit = KbName('Escape');
            
    end


end