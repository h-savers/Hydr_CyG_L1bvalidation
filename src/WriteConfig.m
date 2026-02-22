function WriteConfig(configurationPath, H_file, C_file, ThresholdTimeDelay, ThresholDist, SNRThr, colocMode)
conffileID = fopen(configurationPath, 'W') ; 
% conffileID = fopen(configurationPath) ; 
fprintf(conffileID,'%s',['H_file=' H_file] ); fprintf(conffileID,'\n') ; 
fprintf(conffileID,'%s', ['C_file=' C_file] ); fprintf(conffileID,'\n') ; 
fprintf(conffileID,['ThresholdTimeDelay=' char(string(ThresholdTimeDelay))] ); fprintf(conffileID,'\n') ; 
fprintf(conffileID,['ThresholDist=' char(string(ThresholDist))] ); fprintf(conffileID,'\n') ; 
fprintf(conffileID,['SNRThr=' char(string(SNRThr))] ); fprintf(conffileID,'\n') ; 
fprintf(conffileID,'%s',['colocMode=' colocMode] ); fprintf(conffileID,'\n') ; 
fclose(conffileID) ;
end