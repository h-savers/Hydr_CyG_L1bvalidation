function [H_file, C_file, ThresholdTimeDelay, ThresholDist, SNRThr, colocMode] = ReadConfFile(configurationPath)
%%%%%%%  Read configuration file
%
            lines = string(splitlines(fileread(configurationPath)));
%         
            ConfigRightLine= contains(lines,'H_file')  ;  
            ConfigRightLine= find(ConfigRightLine==1)  ;   
            startIndex= regexp(lines(ConfigRightLine),'=') ; 
            H_file= extractAfter(lines(ConfigRightLine),startIndex) ;         
%%         
            ConfigRightLine= contains(lines,'C_file')  ;  
            ConfigRightLine= find(ConfigRightLine==1)  ;   
            startIndex= regexp(lines(ConfigRightLine),'=') ; 
            C_file= extractAfter(lines(ConfigRightLine),startIndex) ;
%%                  
            ConfigRightLine= contains(lines,'ThresholdTimeDelay')  ;  
            ConfigRightLine= find(ConfigRightLine==1)  ;   
            startIndex= regexp(lines(ConfigRightLine),'=') ; 
            ThresholdTimeDelay= extractAfter(lines(ConfigRightLine),startIndex) ; % max distance between SP and SMAP grid cell in meters
            ThresholdTimeDelay=double(ThresholdTimeDelay) ; 
%%                  
            ConfigRightLine= contains(lines,'ThresholDist')  ;  
            ConfigRightLine= find(ConfigRightLine==1)  ;   
            startIndex= regexp(lines(ConfigRightLine),'=') ; 
            ThresholDist= extractAfter(lines(ConfigRightLine),startIndex) ; % max distance between SP and SMAP grid cell in meters
            ThresholDist=double(ThresholDist) ; 
%%                  
            ConfigRightLine= contains(lines,'SNRThr')  ;  
            ConfigRightLine= find(ConfigRightLine==1)  ;   
            startIndex= regexp(lines(ConfigRightLine),'=') ; 
            SNRThr= extractAfter(lines(ConfigRightLine),startIndex) ; % max distance between SP and SMAP grid cell in meters
            SNRThr=double(SNRThr) ; 

%%                  
            ConfigRightLine= contains(lines,'colocMode')  ;  
            ConfigRightLine= find(ConfigRightLine==1)  ;   
            startIndex= regexp(lines(ConfigRightLine),'=') ; 
            colocMode= extractAfter(lines(ConfigRightLine),startIndex) ; 
end