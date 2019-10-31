%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% L-EFT script
% 07/2017 by Mackenzie Sunday
% Set the Screen to 1024x768 resolution.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [] = LEFT(subjno,subjini,age,sex,hand)
try
    commandwindow;
    whichScreen = 0; %changed to 1 to test on laptop
    
    key1 = KbName('1'); key2 = KbName('2'); key3 = KbName('3'); %makes it so you use the number pad
    key4 = KbName('4$'); key5 = KbName('5%'); key6 = KbName('6^');
    key7 = KbName('7&'); key8 = KbName('8*'); key9 = KbName('9(');
    spaceBar = KbName('space');
    esc_key = KbName('escape'); %this key will kill the script during the experiment
    
    
    % setting up keyboards
    devices = PsychHID('Devices');
    kbs = find([devices(:).usageValue] == 6);
    usethiskeyboard = kbs(end);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    imfolder = 'LEFTimages';
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    studytime = 3;  %time before the target and choices disappear
    
     HideCursor;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Open Screens.
    bcolor=0;
    AssertOpenGL;
    ScreenNumber=whichScreen;
    [w, ScreenRect]=Screen('OpenWindow',ScreenNumber, bcolor, [], 32, 2);
    white=WhiteIndex(w); %get white value
    midWidth=round(RectWidth(ScreenRect)/2);
    midLength=round(RectHeight(ScreenRect)/2);
    Screen('FillRect', w, [255 255 255]); % set screen to white
    Screen('Flip',w);
    Priority(MaxPriority(w));
    
    Screen_X = RectWidth(ScreenRect);
    Screen_Y = RectHeight(ScreenRect);
    cx = round(Screen_X/2);
    cy = round(Screen_Y/2);
    
    ScreenBlank = Screen(w, 'OpenOffScreenWindow', white, ScreenRect);
    [oldFontName, oldFontNumber] = Screen(w, 'TextFont', 'Helvetica' ); %set font
    [oldFontName, oldFontNumber] = Screen(ScreenBlank, 'TextFont', 'Helvetica' );
    oldFontSize=Screen(w,'TextSize',[40]); %set text size
    
    %% create files for saving data
    cd('LEFT_Data')
    fileName1 = ['LEFT_' num2str(subjno) '_' subjini '.txt'];
    dataFile = fopen(fileName1, 'w');
    cd('..')
    
    ListenChar(2);
    %HideCursor;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    fprintf(dataFile, ['\nsubjno\tsubjini\ttrialnum\tstudydisp\trespdisp\ttarloc\tresp\tac\trt']); %prints headers
    
    startexpt = GetSecs; %get time of the start of the experiment
    
    fixation = uint8(ones(7)*255);
    fixation(4,:) = 0;
    fixation(:,4) = 0;
    
    %read in the trial info from the text file
    [trialnum studydisp respdisp tarloc]=...
        textread('LEFT.txt','%s %s %s %u');
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Prepare & give instructions. Both matlab text and image texts can be
    %used
    
    notEnd = 'You finished this task!';
    
    
    %read in instruction images
    instruct1=imread('instruct1.jpg'); instruct2=imread('instruct2.jpg');
    instruct3=imread('instruct3.jpg'); instruct4=imread('instruct4.jpg');
    
    Screen('PutImage', w, instruct1);
    Screen('Flip', w);
    WaitSecs(.5);
    touch=0;
    while touch==0
        [touch,tpress,keyCode]=PsychHID('KbCheck',usethiskeyboard);
        if keyCode(spaceBar); break; else touch=0; end
    end; while KbCheck; end
    
    Screen('PutImage', w, instruct2);
    Screen('Flip', w);
    WaitSecs(.5);
    touch=0;
    while touch==0
        [touch,tpress,keyCode]=PsychHID('KbCheck',usethiskeyboard);
        if keyCode(spaceBar); break; else touch=0; end
    end; while KbCheck; end
    
    Screen('PutImage', w, instruct3);
    Screen('Flip', w);
    WaitSecs(.5);
    touch=0;
    while touch==0
        [touch,tpress,keyCode]=PsychHID('KbCheck',usethiskeyboard);
        if keyCode(spaceBar); break; else touch=0; end
    end; while KbCheck; end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Practice trails
    prac1study=imread('prac1.jpg'); prac1resp=imread('trial_2.jpg');
    prac2study=imread('prac2.jpg'); prac2resp=imread('trial_2.jpg');
    
    %Beginning of a trial.
    Screen('FillRect', w, white); Screen('Flip', w); WaitSecs(.2);
    Screen('PutImage', w, prac1study);
    Screen('Flip', w);
    
    tstart=GetSecs;
    tendStudy= tstart+studytime;
    touch=0; noresponse=0;
    
    while touch==0
        [touch,tpress,keyCode]=PsychHID('KbCheck',usethiskeyboard);
        rt=(tpress-tstart)*1000;
        if  keyCode(key1)||keyCode(key2)||keyCode(key3); break;
            
        else if touch; end; touch=0; end
        if GetSecs > tendStudy
            Screen('PutImage', w, prac1resp);
            Screen('Flip', w);
        end
        touch=0;
    end
    
    FlushEvents('keyDown');
    Screen('FillRect', w, white);
    Screen('Flip', w); WaitSecs(.5);
    
    if ~noresponse
        if keyCode(key1); resp = 1;
            ac=0; fdbkmsg= 'INCORRECT';
        elseif keyCode(key2); resp = 2;
            ac=1; fdbkmsg= 'CORRECT';
        elseif keyCode(key3); resp = 3;
            ac=0; fdbkmsg= 'INCORRECT!';
        end
    else
        resp='nil'; ac=-1; rt=-1;
    end
    
    fprintf(dataFile, ('\n%s\t%s\t%s\t%s\t%s\t%d\t%d\t%d\t%f'),...
        subjno,subjini,'0','prac1','prac1',2,resp,ac,rt);
    
    [nx, ny, bbox] = DrawFormattedText(w, fdbkmsg, 'center', 'center'); %centers and draws feedback message
    Screen('Flip', w); WaitSecs(2);
    
    %second practice trial
    
    Screen('FillRect', w, white); Screen('Flip', w); WaitSecs(.2);
    Screen('PutImage', w, prac2study);
    Screen('Flip', w);
    
    tstart=GetSecs;
    tendStudy= tstart+studytime;
    touch=0; noresponse=0;
    
    while touch==0
        [touch,tpress,keyCode]=PsychHID('KbCheck',usethiskeyboard);
        rt=(tpress-tstart)*1000;
        if  keyCode(key1)||keyCode(key2)||keyCode(key3); break;
            
        else if touch; end; touch=0; end
        if GetSecs > tendStudy
            Screen('PutImage', w, prac2resp);
            Screen('Flip', w);
        end
        touch=0;
    end
    
    FlushEvents('keyDown');
    Screen('FillRect', w, white);
    Screen('Flip', w); WaitSecs(.5);
    
    if ~noresponse
        if keyCode(key1); resp = 1;
            ac=0; fdbkmsg= 'INCORRECT';
        elseif keyCode(key2); resp = 2;
            ac=0; fdbkmsg= 'INCORRECT';
        elseif keyCode(key3); resp = 3;
            ac=1; fdbkmsg= 'CORRECT!';
        end
    else
        resp='nil'; ac=-1; rt=-1;
    end
    
    fprintf(dataFile, ('\n%s\t%s\t%s\t%s\t%s\t%d\t%d\t%d\t%f'),...
        subjno,subjini,'0','prac2','prac2',3,resp,ac,rt);
    
    [nx, ny, bbox] = DrawFormattedText(w, fdbkmsg, 'center', 'center'); %centers and draws feedback message
    Screen('Flip', w); WaitSecs(2);
    
    %screen to start experiment
    Screen('PutImage', w, instruct4);
    Screen('Flip', w);
    WaitSecs(.5);
    touch=0;
    while touch==0
        [touch,tpress,keyCode]=PsychHID('KbCheck',usethiskeyboard);
        if keyCode(spaceBar); break; else touch=0; end
    end; while KbCheck; end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %  Experimental trials
    for m = 1:numel(studydisp)
        %Beginning of a trial.
        study = imread([studydisp{m}], 'jpg');
        Screen('FillRect', w, white); Screen('Flip', w); WaitSecs(.2);
        Screen('PutImage', w, study);
        Screen('Flip', w);
        
        tstart=GetSecs;
        tendStudy= tstart+studytime;
        touch=0; noresponse=0;
        
        while touch==0
            [touch,tpress,keyCode]=PsychHID('KbCheck',usethiskeyboard);
            rt(m)=(tpress-tstart)*1000;
            if  keyCode(key1)||keyCode(key2)||keyCode(key3); break;
                
            else if touch; end; touch=0; end
            if GetSecs > tendStudy
                respscreen = imread([respdisp{m}], 'jpg');
                Screen('PutImage', w, respscreen);
                Screen('Flip', w);
            end
            touch=0;
        end
        
        if ~noresponse
            if keyCode(key1); resp = 1;
                if tarloc(m)==1; ac(m)=1;
                else ac(m)=0; end
            elseif keyCode(key2); resp = 2;
                if tarloc(m)==2; ac(m)=1;
                else ac(m)=0; end
            elseif keyCode(key3); resp = 3;
                if tarloc(m)==3; ac(m)=1;
                else ac(m)=0; end
            end
        else
            resp='nil'; ac(m)=-1; rt(m)=-1;
        end
        
        %change screen
        
        fprintf(dataFile, ('\n%s\t%s\t%s\t%s\t%s\t%d\t%d\t%d\t%f'),...
            subjno,subjini,trialnum{m},studydisp{m},respdisp{m},tarloc(m),resp,ac(m),rt(m));
        
        FlushEvents('keyDown');
        WaitSecs(.5);
        touch=0;
        
    end
    
    ListenChar(0);
    fclose('all');
    
    [nx, ny, bbox] = DrawFormattedText(w, notEnd, 'center', 'center'); %draws end note to get experimenter
    Screen('Flip', w);
    WaitSecs(.2);
    
    %press the spacebar to end
    FlushEvents('keyDown');
    touch=0;
    while touch==0
        [touch,tpress,keyCode]=PsychHID('KbCheck',usethiskeyboard);
        if keyCode(spaceBar); break; else touch=0; end
    end; while KbCheck; end
    
    totalExptTime = (GetSecs - startexpt)/60;
    ACmean = mean(ac);
    RTmean = mean(rt);
    
    %prints to command window
    fprintf('\nExperiment time:\t%4f\t minutes',totalExptTime);
    fprintf('\nAverage accuracy:\t%4f',ACmean);
    fprintf('\nAverage response time:\t%4f\n',RTmean);
    
    Screen('CloseAll');
    ShowCursor; ListenChar;
    Priority(0);
    tLEFT = totalExptTime;
    
catch
    ListenChar(0);
    ShowCursor;
    Screen('CloseAll');
    rethrow(lasterror);
end
end