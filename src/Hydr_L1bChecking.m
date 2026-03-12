function Hydr_L1bChecking(configurationPath)
close all
clearvars -except  configurationPath
% clear all
ex=exist('configurationPath') ;
if ex ==0
    mode="GUI" ;
    
    [configurationfile configurationPath] = uigetfile('../*.cfg', 'Select input configuration file') ; 
    configurationPath= [ configurationPath configurationfile]  ; 
else
    if ~isfile(configurationPath)
        throw(MException('INPUT:ERROR', "Cannot find configuration file. Please check the command line and try again."))
    end
    mode="input" ;
end
% 
% 
% 
% H_file='D:\home on Dell NP (gordiani)\HydroGNSS_PhCDE\HydroGNSSCalVal\HydroGNSS_Extract\output\Extract10feb_26-02-15_51-43.mat' ;
% C_file='D:\home on Dell NP (gordiani)\HydroGNSS_PhCDE\HydroGNSSCalVal\CyGNSS_Extraction\output\MyBrench_20260127-20260130_2026-02-04_21-57-45.mat' ;

[H_file, C_file, ThresholdTimeDelay, ThresholDist, SNRThr, colocMode] = ReadConfFile(configurationPath);

switch mode
    case "GUI" 
%
% ****** get inputs from GUI
%
    disp('GUI mode')
% *************  Start GUI 
Answer{1}= char(H_file) ;  
Answer{2}= char(C_file)  ;      
Answer{3}= char(string(ThresholdTimeDelay)) ;
Answer{4}= char(string(ThresholDist)) ;
Answer{5}= char(string(SNRThr))  ;
Answer{6}= char(colocMode) ; 

% ****** get inputs from GUI
prompt={ 'HydroGNSS extracted file : ',...
         'CyGNSS extracted file: ',...
         'Maximum observations time delay [hours]: ',...
         'Maximum distance [meters]: ', ...
         'SNR threshold for reflectivity comparison [dB]: ',...
         'Colocation Mode [fast | accurate]: '}  ; 
opts.Resize='on';
opts.WindowStyle='normal';
opts.Interpreter='tex';
name='HydroGNSS vs CyGNSS L1B data comparison';
numlines=[1 150; 1 150; 1 90; 1 90; 1 90; 1 90] ; 
defaultanswer={Answer{1},Answer{2},...
                 Answer{3},Answer{4},Answer{5},Answer{6} };
Answer=inputdlg(prompt,name,numlines,defaultanswer,opts);

H_file= Answer{1};
C_file= Answer{2};
ThresholdTimeDelay= str2num(Answer{3});
ThresholDist= str2num(Answer{4});
SNRThr=str2num(Answer{5});
colocMode=Answer{6} ; 
%
% ****** Save GUI input into Input Configuration File 
% save('../conf/Configuration.mat', 'Answer', '-append') ;

WriteConfig(configurationPath, H_file, C_file, ThresholdTimeDelay, ThresholDist, SNRThr, colocMode);

% switch mode
    case "input" 
    disp('input mode')

[H_file, C_file, ThresholdTimeDelay, ThresholDist, SNRThr, colocMode] = ReadConfFile(configurationPath);

end
%
%%%%  Initiate processing
startIndex=regexp(configurationPath, '\configuration') ;
load([extractBefore(configurationPath, startIndex) 'periodHydr2.mat']) ; 
%
load(H_file)
H_specularPointLat=specularPointLat ;
H_specularPointLon=specularPointLon ;
H_reflectivityLinear_1_L=reflectivityLinear_1_L ;
H_reflectivityLinear_1_R=reflectivityLinear_1_R ;
H_reflectivityLinear_5_L=reflectivityLinear_5_L ;
H_reflectivityLinear_5_R=reflectivityLinear_5_R ; 
H_SNR_1_L=SNR_1_L ;
H_SNR_1_R=SNR_1_R ;
H_SNR_5_L=SNR_5_L ;
H_SNR_5_R=SNR_5_R ;
H_time=timeUTC ;  
H_constellation=constellation ; 
H_Landtypesub=Landtypesub ;
% clearvars -except H_specularPointLat H_specularPointLon H_reflectivityLinear_5_L...
%     H_reflectivityLinear_5_R  H_SNR_5_L H_SNR_5_R H_time H_file C_file...
%     H_reflectivityLinear_5_L  H_reflectivityLinear_5_R H_SNR_5_L H_SNR_5_R...
%     sizesave ThresholDist ThresholdTimeDelay SNRThr colocMode H_constellation H_Landtypesub
% load(C_file)
% C_specularPointLat=specularPointLat ;
% C_specularPointLon=specularPointLon ;
% C_reflectivityLinear_5_L=reflectivityLinear_L1_L ;
% % C_reflectivityLinear_5_R=reflectivityLinear_5_R ; 
% SNR_L1_L(find(SNR_L1_L==-9999))=NaN ; 
% SNR_L1_L(find(SNR_L1_L<=0))=NaN ; 
% C_SNR_5_L=10*log10(10.^(SNR_L1_L/10)-1) ;
% % C_SNR_5_R=SNR_5_R ;
% C_time=timeUTC ; 
% clearvars -except C_specularPointLat C_specularPointLon C_reflectivityLinear_5_L...
%     C_reflectivityLinear_5_R  C_SNR_5_L H_SNR_5_R H_time C_time H_specularPointLat...
%     H_specularPointLon H_reflectivityLinear_5_L H_reflectivityLinear_5_R  H_SNR_5_L...
%     H_reflectivityLinear_5_L  H_reflectivityLinear_5_R H_SNR_5_L H_SNR_5_R...
%     H_SNR_5_R H_timeUTC H_file C_file sizesave ThresholDist ThresholdTimeDelay...
%     SNRThr H_constellation colocMode
% H_time=datetime(H_timeUTC) ; 
% C_time=datetime(C_timeUTC) ;
H_geo=[H_specularPointLat, H_specularPointLon] ;
% C_geo=[C_specularPointLat, C_specularPointLon] ;
clearvars H_specularPointLat H_specularPointLon 
H_length=length(H_time) ;
% C_length=length(C_time) ; 

in=find(isnan(hour(H_time))==0) ; 
% in=ones(H_length, 1) ; 
% load coastlines ;
% in = inpolygon(H_geo(:,2), H_geo(:,1), coastlon, coastlat);
figure, geoscatter(H_geo(in,1),H_geo(in,2), 2, 10*log10(reflectivityLinear_1_L(in)), 'filled')
c=colorbar ; c.Label.String = 'L1/E1 Reflectivity  [dB]';
caxis([-35, 0])
title('HydroGNSS unfiltered Reflectivity L1/E1 Left [dB]')

figure
t=tiledlayout(2,2) ; 
nexttile ; 
histogram(10*log10(H_reflectivityLinear_1_L(intersect(in, find(H_constellation=='GPS')))))
hold on, histogram(10*log10(H_reflectivityLinear_1_R(intersect(in, find(H_constellation=='GPS')))))
xlim([-50,5])
legend('Left', 'Right')
title('Overland unfiltered reflectivity L1')
xlabel('Reflectivity [dB]')
P11=length(find(10*log10(H_reflectivityLinear_1_L(intersect(in, find(H_constellation=='GPS')))) > 40)) ;
P12=length(find(10*log10(H_reflectivityLinear_1_R(intersect(in, find(H_constellation=='GPS')))) > 40)) ;
str11 = {[char(string(P11)) ' SP''s >40 dB'],...
         [char(string(P12)) ' SP''s >40 dB']} ;
text(-15,4000,str11,'FontSize',6)

nexttile
histogram(10*log10(H_reflectivityLinear_1_L(intersect(in, find(H_constellation=='Galileo')))))
hold on, histogram(10*log10(H_reflectivityLinear_1_R(intersect(in, find(H_constellation=='Galileo')))))
xlim([-50,5])
legend('Left', 'Right')
title('Overland unfiltered reflectivity E1')
xlabel('Reflectivity [dB]')
P11=length(find(10*log10(H_reflectivityLinear_1_L(intersect(in, find(H_constellation=='Galileo')))) > 40)) ;
P12=length(find(10*log10(H_reflectivityLinear_1_R(intersect(in, find(H_constellation=='Galileo')))) > 40)) ;
str11 = {[char(string(P11)) ' SP''s >40 dB'],...
         [char(string(P12)) ' SP''s >40 dB']} ;
text(-10,6000,str11,'FontSize',6)

nexttile
histogram(10*log10(H_reflectivityLinear_5_L(intersect(in, find(H_constellation=='GPS')))))
hold on, histogram(10*log10(H_reflectivityLinear_5_R(intersect(in, find(H_constellation=='GPS')))))
xlim([-50,5])
legend('Left', 'Right')
title('Overland unfiltered reflectivity L5')
xlabel('Reflectivity [dB]')
P11=length(find(10*log10(H_reflectivityLinear_5_L(intersect(in, find(H_constellation=='GPS')))) > 40)) ;
P12=length(find(10*log10(H_reflectivityLinear_5_R(intersect(in, find(H_constellation=='GPS')))) > 40)) ;
str11 = {[char(string(P11)) ' SP''s >40 dB'],...
         [char(string(P12)) ' SP''s >40 dB']} ;
text(-15,4000,str11,'FontSize',6)

nexttile
histogram(10*log10(H_reflectivityLinear_5_L(intersect(in, find(H_constellation=='Galileo')))))
hold on, histogram(10*log10(H_reflectivityLinear_5_R(intersect(in, find(H_constellation=='Galileo')))))
xlim([-50,5])
legend('Left', 'Right')
title('Overland unfiltered reflectivity E5')
xlabel('Reflectivity [dB]')
P11=length(find(10*log10(H_reflectivityLinear_5_L(intersect(in, find(H_constellation=='Galileo')))) > 40)) ;
P12=length(find(10*log10(H_reflectivityLinear_5_R(intersect(in, find(H_constellation=='Galileo')))) > 40)) ; 
str11 = {[char(string(P11)) ' SP''s >40 dB'],...
         [char(string(P12)) ' SP''s >40 dB']} ;
text(-15,4000,str11,'FontSize',6)

figure
tt=tiledlayout(2,2) ; 
nexttile
histogram(10*log10(H_reflectivityLinear_1_L(intersect(in, find(H_constellation=='GPS')))))
hold on, histogram(10*log10(H_reflectivityLinear_1_L(intersect(in, find(H_constellation=='Galileo')))))
xlim([-50,0])
legend('L1 Left', 'E1 Left')
title('Over land L1 and E1 Left comparison')
xlabel('Reflectivity [dB]')
P11=length(find(isnan(H_reflectivityLinear_1_L(intersect(in, find(H_constellation=='GPS'))))>0));
P11=round(100*P11/length(H_reflectivityLinear_1_L(intersect(in, find(H_constellation=='GPS')))),1) ; 
P12=length(find(isnan(H_reflectivityLinear_1_L(intersect(in, find(H_constellation=='Galileo'))))>0)) ;
P12=round(100*P12/length(H_reflectivityLinear_1_L(intersect(in, find(H_constellation=='Galileo')))),1) ;
str11 = {['Missed ' char(string(P11)) '% GPS SP''s'],...
         ['Missed ' char(string(P12)) '% Galileo SP''s']} ;
text(-15,5000,str11,'FontSize',8)

nexttile
histogram(10*log10(H_reflectivityLinear_1_R(intersect(in, find(H_constellation=='GPS')))))
hold on, histogram(10*log10(H_reflectivityLinear_1_R(intersect(in, find(H_constellation=='Galileo')))))
xlim([-50,0])
legend('L1 Right', 'E1 Right')
title('Over land L1 and E1 Right  comparison')
xlabel('Reflectivity [dB]')
P11=length(find(isnan(H_reflectivityLinear_1_R(intersect(in, find(H_constellation=='GPS'))))>0)); 
P11=round(100*P11/length(H_reflectivityLinear_1_R(intersect(in, find(H_constellation=='GPS')))),1) ; 
P12=length(find(isnan(H_reflectivityLinear_1_R(intersect(in, find(H_constellation=='Galileo'))))>0)) ;
P12=round(100*P12/length(H_reflectivityLinear_1_R(intersect(in, find(H_constellation=='Galileo')))),1) ;
str11 = {['Missed ' char(string(P11)) '% GPS SP''s'],...
         ['Missed ' char(string(P12)) '% Galileo SP''s']} ;
text(-20,5000,str11,'FontSize',8)

nexttile
histogram(10*log10(H_reflectivityLinear_5_L(intersect(in, find(H_constellation=='GPS')))))
hold on, histogram(10*log10(H_reflectivityLinear_5_L(intersect(in, find(H_constellation=='Galileo')))))
xlim([-50,0])
legend('L5 Left', 'E5 Left')
title('Over land L5 and E5 Left comparison')
xlabel('Reflectivity [dB]')
P11=length(find(isnan(H_reflectivityLinear_5_L(intersect(in, find(H_constellation=='GPS'))))>0)); 
P11=round(100*P11/length(H_reflectivityLinear_5_L(intersect(in, find(H_constellation=='GPS')))),1) ; 
P12=length(find(isnan(H_reflectivityLinear_5_L(intersect(in, find(H_constellation=='Galileo'))))>0)) ;
P12=round(100*P12/length(H_reflectivityLinear_5_L(intersect(in, find(H_constellation=='Galileo')))),1) ;
str11 = {['Missed ' char(string(P11)) '% GPS SP''s'],...
         ['Missed ' char(string(P12)) '% Galileo SP''s']} ;
text(-20,5000,str11,'FontSize',8)

nexttile
histogram(10*log10(H_reflectivityLinear_5_R(intersect(in, find(H_constellation=='GPS')))))
hold on, histogram(10*log10(H_reflectivityLinear_5_R(intersect(in, find(H_constellation=='Galileo')))))
xlim([-50,0])
legend('L5 Right', 'E5 Right')
title('Over land L5 and E5 Right comparison')
xlabel('Reflectivity [dB]')
P11=length(find(isnan(H_reflectivityLinear_5_R(intersect(in, find(H_constellation=='GPS'))))>0)); 
P11=round(100*P11/length(H_reflectivityLinear_5_R(intersect(in, find(H_constellation=='GPS')))),1) ; 
P12=length(find(isnan(H_reflectivityLinear_5_R(intersect(in, find(H_constellation=='Galileo'))))>0)) ;
P12=round(100*P12/length(H_reflectivityLinear_5_R(intersect(in, find(H_constellation=='Galileo')))),1) ;
str11 = {['Missed ' char(string(P11)) '% GPS SP''s'],...
         ['Missed ' char(string(P12)) '% Galileo SP''s']} ;
text(-20,5000,str11,'FontSize',8)
%% comparison GPS Galile SNR
figure
tt2=tiledlayout(2,2) ; 
nexttile
histogram((H_SNR_1_L(intersect(in, find(H_constellation=='GPS')))),100)
hold on, histogram((H_SNR_1_L(intersect(in, find(H_constellation=='Galileo')))),100)
xlim([-15,25])
legend('L1 Left', 'E1 Left')
title('Over land L1 and E1 Left SNR comparison')
xlabel('SNR [dB]')
P11=length(find(isnan(H_SNR_1_L(intersect(in, find(H_constellation=='GPS'))))>0));
P11=round(100*P11/length(H_SNR_1_L(intersect(in, find(H_constellation=='GPS')))),1) ; 
P12=length(find(isnan(H_SNR_1_L(intersect(in, find(H_constellation=='Galileo'))))>0)) ;
P12=round(100*P12/length(H_SNR_1_L(intersect(in, find(H_constellation=='Galileo')))),1) ;
str11 = {['Missed ' char(string(P11)) '% GPS SP''s'],...
         ['Missed ' char(string(P12)) '% Galileo SP''s']} ;
text(5,6000,str11,'FontSize',8)

nexttile
histogram((H_SNR_1_R(intersect(in, find(H_constellation=='GPS')))),100)
hold on, histogram((H_SNR_1_R(intersect(in, find(H_constellation=='Galileo')))),100)
xlim([-15,25])
legend('L1 Right', 'E1 Right')
title('Over land L1 and E1 Right SNR comparison')
xlabel('SNR [dB]')
P11=length(find(isnan(H_SNR_1_R(intersect(in, find(H_constellation=='GPS'))))>0)); 
P11=round(100*P11/length(H_SNR_1_R(intersect(in, find(H_constellation=='GPS')))),1) ; 
P12=length(find(isnan(H_SNR_1_R(intersect(in, find(H_constellation=='Galileo'))))>0)) ;
P12=round(100*P12/length(H_SNR_1_R(intersect(in, find(H_constellation=='Galileo')))),1) ;
str11 = {['Missed ' char(string(P11)) '% GPS SP''s'],...
         ['Missed ' char(string(P12)) '% Galileo SP''s']} ;
text(5,6000,str11,'FontSize',8)

nexttile
histogram((H_SNR_5_L(intersect(in, find(H_constellation=='GPS')))),100)
hold on, histogram((H_SNR_5_L(intersect(in, find(H_constellation=='Galileo')))),100)
xlim([-15,25])
legend('L5 Left', 'E5 Left')
title('Over land L5 and E5 Left SNR comparison')
xlabel('SNR [dB]')
P11=length(find(isnan(H_SNR_5_L(intersect(in, find(H_constellation=='GPS'))))>0)); 
P11=round(100*P11/length(H_SNR_5_L(intersect(in, find(H_constellation=='GPS')))),1) ; 
P12=length(find(isnan(H_SNR_5_L(intersect(in, find(H_constellation=='Galileo'))))>0)) ;
P12=round(100*P12/length(H_SNR_5_L(intersect(in, find(H_constellation=='Galileo')))),1) ;
str11 = {['Missed ' char(string(P11)) '% GPS SP''s'],...
         ['Missed ' char(string(P12)) '% Galileo SP''s']} ;
text(5,6000,str11,'FontSize',8)

nexttile
histogram((H_SNR_5_R(intersect(in, find(H_constellation=='GPS')))), 100)
hold on, histogram((H_SNR_5_R(intersect(in, find(H_constellation=='Galileo')))), 100)
xlim([-15,25])
legend('L5 Right', 'E5 Right')
title('Over land L5 and E5 Right SNR comparison')
xlabel('SNR [dB]')
P11=length(find(isnan(H_SNR_5_R(intersect(in, find(H_constellation=='GPS'))))>0)); 
P11=round(100*P11/length(H_SNR_5_R(intersect(in, find(H_constellation=='GPS')))),1) ; 
P12=length(find(isnan(H_SNR_5_R(intersect(in, find(H_constellation=='Galileo'))))>0)) ;
P12=round(100*P12/length(H_SNR_5_R(intersect(in, find(H_constellation=='Galileo')))),1) ;
str11 = {['Missed ' char(string(P11)) '% GPS SP''s'],...
         ['Missed ' char(string(P12)) '% Galileo SP''s']} ;
text(5,6000,str11,'FontSize',8)
%%
figure
ttt=tiledlayout(2,2) ; 
nexttile
histogram(H_SNR_1_L(intersect(in, find(H_constellation=='GPS'))))
hold on, histogram(H_SNR_1_R(intersect(in, find(H_constellation=='GPS'))))
xlim([-15,25])
legend('Left', 'Right')
title('Over land SNR L1')
xlabel('SNR [dB]')
P11=round(100*length(find(H_SNR_1_L(intersect(in, find(H_constellation=='GPS')))>0.5))/length(H_SNR_1_L(intersect(in, find(H_constellation=='GPS')))),1) ; 
P12=round(100*length(find(H_SNR_1_L(intersect(in, find(H_constellation=='GPS')))>2))/length(H_SNR_1_L(intersect(in, find(H_constellation=='GPS')))),1) ; 
P21=round(100*length(find(H_SNR_1_R(intersect(in, find(H_constellation=='GPS')))>0.5))/length(H_SNR_1_R(intersect(in, find(H_constellation=='GPS')))),1) ; 
P22=round(100*length(find(H_SNR_1_R(intersect(in, find(H_constellation=='GPS')))>2))/length(H_SNR_1_R(intersect(in, find(H_constellation=='GPS')))),1) ; 
str11 = {['Left : ' char(string(P11)) '% SNR>' char(string(0.5)) 'dB'],...
    ['Left : ' char(string(P12)) '% SNR>' char(string(2)) 'dB'],...
    ['Right: ' char(string(P21)) '% SNR>' char(string(0.5)) 'dB'],...
    ['Right: ' char(string(P22)) '% SNR>' char(string(2)) 'dB']} ;
text(10,5000,str11,'FontSize',6)

nexttile
histogram(H_SNR_1_L(intersect(in, find(H_constellation=='Galileo'))))
hold on, histogram(H_SNR_1_R(intersect(in, find(H_constellation=='Galileo'))))
xlim([-15,25])
legend('Left', 'Right')
title('Over land SNR E1')
xlabel('SNR [dB]')
P11=round(100*length(find(H_SNR_1_L(intersect(in, find(H_constellation=='Galileo')))>0.5))/length(H_SNR_1_L(intersect(in, find(H_constellation=='Galileo'))))) ; 
P12=round(100*length(find(H_SNR_1_L(intersect(in, find(H_constellation=='Galileo')))>2))/length(H_SNR_1_L(intersect(in, find(H_constellation=='Galileo'))))) ; 
P21=round(100*length(find(H_SNR_1_R(intersect(in, find(H_constellation=='Galileo')))>0.5))/length(H_SNR_1_R(intersect(in, find(H_constellation=='Galileo'))))) ; 
P22=round(100*length(find(H_SNR_1_R(intersect(in, find(H_constellation=='Galileo')))>2))/length(H_SNR_1_R(intersect(in, find(H_constellation=='Galileo'))))) ; 
str11 = {['Left: ' char(string(P11)) '% SNR>' char(string(0.5)) 'dB'],...
    ['Left: ' char(string(P12)) '% SNR>' char(string(2)) 'dB'],...
    ['Right: ' char(string(P21)) '% SNR>' char(string(0.5)) 'dB'],...
    ['Right: ' char(string(P22)) '% SNR>' char(string(2)) 'dB']} ;
text(10,5000,str11,'FontSize',6)

nexttile
histogram(H_SNR_5_L(intersect(in, find(H_constellation=='GPS'))))
hold on, histogram(H_SNR_5_R(intersect(in, find(H_constellation=='GPS'))))
xlim([-15,25])
legend('Left', 'Right')
title('Over land SNR L5')
xlabel('SNR [dB]')
P11=round(100*length(find(H_SNR_5_L(intersect(in, find(H_constellation=='GPS')))>0.5))/length(H_SNR_5_L(intersect(in, find(H_constellation=='GPS')))),1) ; 
P12=round(100*length(find(H_SNR_5_L(intersect(in, find(H_constellation=='GPS')))>2))/length(H_SNR_5_L(intersect(in, find(H_constellation=='GPS')))),1) ; 
P21=round(100*length(find(H_SNR_5_R(intersect(in, find(H_constellation=='GPS')))>0.5))/length(H_SNR_5_R(intersect(in, find(H_constellation=='GPS')))),1) ; 
P22=round(100*length(find(H_SNR_5_R(intersect(in, find(H_constellation=='GPS')))>2))/length(H_SNR_5_R(intersect(in, find(H_constellation=='GPS')))),1) ; 
str11 = {['Left : ' char(string(P11)) '% SNR>' char(string(0.5)) 'dB'],...
    ['Left : ' char(string(P12)) '% SNR>' char(string(2)) 'dB'],...
    ['Right: ' char(string(P21)) '% SNR>' char(string(0.5)) 'dB'],...
    ['Right: ' char(string(P22)) '% SNR>' char(string(2)) 'dB']} ;
text(10,5000,str11,'FontSize',6)

nexttile
histogram(H_SNR_5_L(intersect(in, find(H_constellation=='Galileo'))))
hold on, histogram(H_SNR_5_R(intersect(in, find(H_constellation=='Galileo'))))
xlim([-15,25])
legend('Left', 'Right')
title('Over land SNR E5')
xlabel('SNR [dB]')
P11=round(100*length(find(H_SNR_5_L(intersect(in, find(H_constellation=='Galileo')))>0.5))/length(H_SNR_5_L(intersect(in, find(H_constellation=='Galileo')))),1) ; 
P12=round(100*length(find(H_SNR_5_L(intersect(in, find(H_constellation=='Galileo')))>2))/length(H_SNR_5_L(intersect(in, find(H_constellation=='Galileo')))),1) ; 
P21=round(100*length(find(H_SNR_5_R(intersect(in, find(H_constellation=='Galileo')))>0.5))/length(H_SNR_5_R(intersect(in, find(H_constellation=='Galileo')))),1) ; 
P22=round(100*length(find(H_SNR_5_R(intersect(in, find(H_constellation=='Galileo')))>2))/length(H_SNR_5_R(intersect(in, find(H_constellation=='Galileo')))),1) ; 
str11 = {['Left: ' char(string(P11)) '% SNR>' char(string(0.5)) 'dB'],...
    ['Left: ' char(string(P12)) '% SNR>' char(string(2)) 'dB'],...
    ['Right: ' char(string(P21)) '% SNR>' char(string(0.5)) 'dB'],...
    ['Right: ' char(string(P22)) '% SNR>' char(string(2)) 'dB']} ;
text(10,5000,str11,'FontSize',6)
%""""""""""""""""""
figure
tttt=tiledlayout(2,2) ; 
nexttile
scatter(rxAntennaGain_1_L, 10*log10(reflectivityLinear_1_L), 2, SNR_1_L)
xlim([-5,12]) ; ylim([-50,10])
xlabel('rxAntennaGain L1/E1 Left [dB]')
ylabel('Reflectivity L1/E1 Left [dB]')
title('Reflectivitty L1/E1 Left vs ant. gain vs SNR')
c=colorbar ; c.Label.String = 'SNR [dB]';
nexttile
scatter(rxAntennaGain_5_L, 10*log10(reflectivityLinear_5_L), 2, SNR_5_L)
xlim([-5,12]) ; ylim([-50,10])
xlabel('rxAntennaGain L5/E5 Left [dB]')
ylabel('Reflectivity L5/E5 Left [dB]')
title('Reflectivitty L5/E5 Left vs ant. gain vs SNR')
c=colorbar ; c.Label.String = 'SNR [dB]';
nexttile
scatter(rxAntennaGain_1_R, 10*log10(reflectivityLinear_1_R), 2, SNR_1_R)
xlim([-5,12]) ; ylim([-50,10])
xlabel('rxAntennaGain L1/E1 Right[dB]')
ylabel('Reflectivity L1/E1 Right [dB]')
title('Reflectivitty L1/E1 Right vs ant. gain vs SNR')
c=colorbar; c.Label.String = 'SNR [dB]';
nexttile
scatter(rxAntennaGain_5_R, 10*log10(reflectivityLinear_5_R), 2, SNR_5_R)
xlim([-5,12]) ; ylim([-50,10])
xlabel('rxAntennaGain L5/E5 Right [dB]')
ylabel('Reflectivity L5/E5 Right [dB]')
title('Reflectivitty L5/E5 Right vs ant. gain vs SNR')
c=colorbar; c.Label.String = 'SNR [dB]';

figure
ttttt=tiledlayout(2,2) ; 
nexttile
scatter(10*log10(reflectivityLinear_1_L(constellation=='GPS')), 10*log10(reflectivityLinear_1_R(constellation=='GPS')),3,SNR_1_L(constellation=='GPS'), 'filled')
xlim([-60, 20])
ylim([-60, 20])
xlabel('Reflectivity L1 Left [dB]')
ylabel('Reflectivity L1 Right [dB]')
title('GPS L1 reflectivity Right vs Left vs SNR Left')
c=colorbar ; caxis([-1 25]) ; c.Label.String = 'SNR [dB]';
line([-60, 20], [-60, 20])

nexttile
scatter(10*log10(reflectivityLinear_1_L(constellation=='Galileo')), 10*log10(reflectivityLinear_1_R(constellation=='Galileo')),3,SNR_1_L(constellation=='Galileo'), 'filled')
xlim([-60, 20])
ylim([-60, 20])
xlabel('Reflectivity E1 Left [dB]')
ylabel('Reflectivity E1 Right [dB]')
title('Galileo E1 reflectivity Right vs Left vs SNR Left')
c=colorbar ; caxis([-5 25]) ; c.Label.String = 'SNR [dB]';
line([-60, 20], [-60, 20])

nexttile
scatter(10*log10(reflectivityLinear_5_L(constellation=='GPS')), 10*log10(reflectivityLinear_5_R(constellation=='GPS')),3,SNR_5_L(constellation=='GPS'), 'filled')
xlim([-60, 20])
ylim([-60, 20])
xlabel('Reflectivity L5 Left [dB]')
ylabel('Reflectivity L5 Right [dB]')
title('GPS L5 reflectivity Right vs Left vs SNR Left')
c=colorbar ; caxis([-5 25]); c.Label.String = 'SNR [dB]';
line([-60, 20], [-60, 20])

nexttile
scatter(10*log10(reflectivityLinear_5_L(constellation=='Galileo')), 10*log10(reflectivityLinear_5_R(constellation=='Galileo')),3,SNR_5_L(constellation=='Galileo'), 'filled')
xlim([-60, 20])
ylim([-60, 20])
xlabel('Reflectivity E5 Left [dB]')
ylabel('Reflectivity E5 Right [dB]')
title('Galileo E5 reflectivity Right vs Left vs SNR Left')
c=colorbar ; caxis([-5 25]) ; c.Label.String = 'SNR [dB]';
line([-60, 20], [-60, 20])

figure
tttttt=tiledlayout(2,2) ; 
nexttile
scatter(10*log10(reflectivityLinear_1_L(constellation=='GPS')), 10*log10(reflectivityLinear_1_R(constellation=='GPS')),3,'filled')
hold on, scatter(10*log10(reflectivityLinear_1_L(constellation=='Galileo')), 10*log10(reflectivityLinear_1_R(constellation=='Galileo')),3,'filled')
xlim([-60, 20])
ylim([-60, 20])
xlabel('Reflectivity Left [dB]')
ylabel('Reflectivity Right [dB]')
title('GPS L1 and Galileo E1 reflectivity Right vs Left')
legend('GPS L1', 'Galileo E1')
line([-60, 20], [-60, 20])

nexttile
scatter(10*log10(reflectivityLinear_1_L(constellation=='GPS'))+rxAntennaGain_1_L(constellation=='GPS'), 10*log10(reflectivityLinear_1_R(constellation=='GPS'))+rxAntennaGain_1_R(constellation=='GPS'),3,'filled')
hold on, scatter(10*log10(reflectivityLinear_1_L(constellation=='Galileo'))+rxAntennaGain_1_L(constellation=='Galileo')-3, 10*log10(reflectivityLinear_1_R(constellation=='Galileo'))+rxAntennaGain_1_R(constellation=='Galileo')-3,3,'filled')
xlim([-60, 20])
ylim([-60, 20])
xlabel('Reflectivity Left "corrected" [dB]')
ylabel('Reflectivity Right "corrected" [dB]')
title('GPS L1 and Galileo E1 "corrected" reflectivity Right vs Left')
legend('GPS L1', 'Galileo E1')
line([-60, 20], [-60, 20])

nexttile
histogram(10*log10(reflectivityLinear_1_L(constellation=='GPS'))+rxAntennaGain_1_L(constellation=='GPS'),100)
hold on, histogram(10*log10(reflectivityLinear_1_L(constellation=='Galileo'))+rxAntennaGain_1_L(constellation=='Galileo')-3,100)
xlim([-40,10])
legend('L1 Left', 'E1 Left')
title('Over land L1 and E1 Left "corrected" comparison')
xlabel('Reflectivity "corrected" [dB]')
P11=10*log10(mean(reflectivityLinear_1_L(constellation=='GPS' & SNR_1_L>0.5 & reflectivityLinear_1_L<1 & reflectivityLinear_1_L>0).*10.^(rxAntennaGain_1_L(constellation=='GPS' & SNR_1_L>0.5 & reflectivityLinear_1_L<1 & reflectivityLinear_1_L>0)/10), 'omitnan')) ;
P12=-3+ 10.*log10(mean(reflectivityLinear_1_L(constellation=='Galileo' & SNR_1_L>0.5 & reflectivityLinear_1_L<1 & reflectivityLinear_1_L>0).*10.^(rxAntennaGain_1_L(constellation=='Galileo' & SNR_1_L>0.5 & reflectivityLinear_1_L<1 & reflectivityLinear_1_L>0)/10), 'omitnan')) ; 
str11 = {['GPS linear mean: ' char(string(round(P11,1))) 'dB (SNR>0.5)' ],...
    ['Galileo linear mean: ' char(string(round(P12,1))) 'dB (SNR>0.5)']} ; 
text(-10,10000,str11,'FontSize',8)

nexttile
histogram(10*log10(reflectivityLinear_1_R(constellation=='GPS'))+rxAntennaGain_1_R(constellation=='GPS'),100)
hold on, histogram(10*log10(reflectivityLinear_1_R(constellation=='Galileo'))+rxAntennaGain_1_R(constellation=='Galileo')-3,100)
xlim([-40,10])
legend('L1 Right', 'E1 Right')
title('Over land L1 and E1 Right "corrected" comparison')
xlabel('Reflectivity "corrected" [dB]')
P11=10*log10(mean(reflectivityLinear_1_R(constellation=='GPS' & SNR_1_R>0.5 & reflectivityLinear_1_R<1 & reflectivityLinear_1_R>0).*10.^(rxAntennaGain_1_R(constellation=='GPS' & SNR_1_R>0.5 & reflectivityLinear_1_R<1 & reflectivityLinear_1_R>0)/10), 'omitnan')) ;
P12=-3+ 10.*log10(mean(reflectivityLinear_1_R(constellation=='Galileo' & SNR_1_R>0.5 & reflectivityLinear_1_R<1 & reflectivityLinear_1_R>0).*10.^(rxAntennaGain_1_R(constellation=='Galileo' & SNR_1_R>0.5 & reflectivityLinear_1_R<1 & reflectivityLinear_1_R>0)/10), 'omitnan')) ; 
str11 = {['GPS linear mean: ' char(string(round(P11,1))) 'dB (SNR>0.5)' ],...
    ['Galileo linear mean: ' char(string(round(P12,1))) 'dB (SNR>0.5)']} ; 
text(-10,10000,str11,'FontSize',8)

figure
ttttttt=tiledlayout(2,2) ; 
nexttile
scatter(10*log10(reflectivityLinear_5_L(constellation=='GPS')), 10*log10(reflectivityLinear_5_R(constellation=='GPS')),3,'filled')
hold on, scatter(10*log10(reflectivityLinear_5_L(constellation=='Galileo')), 10*log10(reflectivityLinear_5_R(constellation=='Galileo')),3,'filled')
xlim([-60, 20])
ylim([-60, 20])
legend('GPS L5', 'Galileo E5')
xlabel('Reflectivity Left [dB]')
ylabel('Reflectivity Right [dB]')
title('GPS L5 and Galileo E5 reflectivity Right vs Left')
line([-60, 20], [-60, 20])

nexttile
scatter(10*log10(reflectivityLinear_5_L(constellation=='GPS'))+rxAntennaGain_5_L(constellation=='GPS'), 10*log10(reflectivityLinear_5_R(constellation=='GPS'))+rxAntennaGain_5_R(constellation=='GPS'),3,'filled')
hold on, scatter(10*log10(reflectivityLinear_5_L(constellation=='Galileo'))+rxAntennaGain_5_L(constellation=='Galileo')-3, 10*log10(reflectivityLinear_5_R(constellation=='Galileo'))+rxAntennaGain_5_R(constellation=='Galileo')-3,3,'filled')
xlim([-60, 20])
ylim([-60, 20])
legend('GPS L5', 'Galileo E5')
xlabel('Reflectivity Left [dB]')
ylabel('Reflectivity Right [dB]')
title('GPS L5 and Galileo E5 "corrected" reflectivity Right vs Left')
line([-60, 20], [-60, 20])

nexttile
histogram(10*log10(reflectivityLinear_5_L(constellation=='GPS'))+rxAntennaGain_5_L(constellation=='GPS'),100)
hold on, histogram(10*log10(reflectivityLinear_5_L(constellation=='Galileo'))+rxAntennaGain_5_L(constellation=='Galileo')-3,100)
xlim([-40,10])
legend('L1 Left', 'E1 Left')
title('Over land L5 and E5 Left "corrected" comparison')
xlabel('Reflectivity [dB]')
P11=10.*log10(mean(reflectivityLinear_5_L(constellation=='GPS' & SNR_5_L>0.5 & reflectivityLinear_5_L<1 & reflectivityLinear_5_L>0).*10.^(rxAntennaGain_5_L(constellation=='GPS'& SNR_5_L>0.5 & reflectivityLinear_5_L<1 & reflectivityLinear_5_L>0)/10), 'omitnan')) ;
P12=-3+ 10.*log10(mean(reflectivityLinear_5_L(constellation=='Galileo' & SNR_5_L>0.5 & reflectivityLinear_5_L<1 & reflectivityLinear_5_L>0).*10.^(rxAntennaGain_5_L(constellation=='Galileo' & SNR_5_L>0.5 & reflectivityLinear_5_L<1 & reflectivityLinear_5_L>0)/10), 'omitnan')) ; 
str11 = {['GPS linear mean: ' char(string(round(P11,1))) 'dB (SNR>0.5)' ],...
    ['Galileo linear mean: ' char(string(round(P12,1))) 'dB (SNR>0.5)']} ; 
text(-20,15000,str11,'FontSize',8)

nexttile
histogram(10*log10(reflectivityLinear_5_R(constellation=='GPS'))+rxAntennaGain_5_R(constellation=='GPS'),100)
hold on, histogram(10*log10(reflectivityLinear_5_R(constellation=='Galileo'))+rxAntennaGain_5_R(constellation=='Galileo')-3,100)
xlim([-40,10])
legend('L1 Right', 'E1 Right')
title('Over land L5 and E5 Right "corrected" comparison')
xlabel('Reflectivity [dB]')
P11=10.*log10(mean(reflectivityLinear_5_R(constellation=='GPS' & SNR_5_R>0.5 & reflectivityLinear_5_R<1 & reflectivityLinear_5_R>0).*10.^(rxAntennaGain_5_R(constellation=='GPS'& SNR_5_R>0.5 & reflectivityLinear_5_R<1 & reflectivityLinear_5_R>0)/10), 'omitnan')) ;
P12=-3+ 10.*log10(mean(reflectivityLinear_5_R(constellation=='Galileo' & SNR_5_R>0.5 & reflectivityLinear_5_R<1 & reflectivityLinear_5_R>0).*10.^(rxAntennaGain_5_R(constellation=='Galileo' & SNR_5_R>0.5 & reflectivityLinear_5_R<1 & reflectivityLinear_5_R>0)/10), 'omitnan')) ; 
str11 = {['GPS linear mean: ' char(string(round(P11,1))) 'dB (SNR>0.5)' ],...
    ['Galileo linear mean: ' char(string(round(P12,1))) 'dB (SNR>0.5)']} ; 
text(-20,15000,str11,'FontSize',8)
a=1

figure, histogram(incidenceAngleDeg(pitch40), 20) ;
hold on, histogram(incidenceAngleDeg(pitch00), 20)
hold on, histogram(incidenceAngleDeg(pitch20), 20)
title('histogram of incidence angle with different pitch angle') 
legend('pitch -40 deg', 'pitch 0 deg', 'pitch -20 deg')
xlabel('Incidence angle [deg]')

figure, histogram(rxAntennaGain_1_L(pitch40))
xlim([-4 14])
hold on, histogram(rxAntennaGain_1_L(pitch00))
hold on, histogram(rxAntennaGain_1_L(pitch20))
title('Antenna gain L1/E1 Left with different pitch angle')
xlabel('RX antenna gain L1/E1 [dB]')
legend('pitch -40 deg', 'pitch 0 deg', 'pitch -20 deg')

figure, histogram(rxAntennaGain_5_L(pitch40))
xlim([-4 14])
hold on, histogram(rxAntennaGain_5_L(pitch00))
hold on, histogram(rxAntennaGain_5_L(pitch20))
title('Antenna gain L5/E5 Left with different pitch angle')
xlabel('RX antenna gain L5/E5 [dB]')
legend('pitch -40 deg', 'pitch 0 deg', 'pitch -20 deg')

figure, histogram(SNR_1_L(pitch40),50)
xlim([-10 20])
hold on, histogram(SNR_1_L(pitch00),50)
hold on, histogram(SNR_1_L(pitch20),50)
title('SNR L1/E1 Left with different pitch angle')
xlabel('SNR L1/E1 [dB]')
legend('pitch -40 deg', 'pitch 0 deg', 'pitch -20 deg')

figure, histogram(SNR_5_L(pitch40),50, 'Normalization', 'pdf')
xlim([-10 20])
hold on, histogram(SNR_5_L(pitch00),50)
hold on, histogram(SNR_5_L(pitch20),50)
title('SNR L5/E5 Left with different pitch angle')
xlabel('SNR L5/E5 [dB]')
legend('pitch -40 deg', 'pitch 0 deg', 'pitch -20 deg')

% comparing coherent integration and AGC

figure, histogram(rxAntennaGain_1_L(pitch20),100, 'Normalization', 'pdf')
xlim([-10 15])
hold on, histogram(rxAntennaGain_1_L(tc1msec),100,'Normalization', 'pdf')
hold on, histogram(rxAntennaGain_1_L(fixgain),100,'Normalization', 'pdf')
title('Antenna gain L1/E1 Left with different coherent integration and AGC')
xlabel('rxAntennaGain L1/E1 [dB]')
legend('Nominal', 'Tc=1msec', 'fixed gain')

figure, histogram(SNR_1_L(pitch20),100, 'Normalization', 'pdf')
xlim([-15 20])
hold on, histogram(SNR_1_L(tc1msec),100,'Normalization', 'pdf')
hold on, histogram(SNR_1_L(fixgain),100,'Normalization', 'pdf')
title('SNR L1/E1 Left with different coherent integration and AGC')
xlabel('SNR L1/E1 [dB]')
legend('Nominal', 'Tc=1msec', 'fixed gain')

figure, histogram(rxAntennaGain_5_L(pitch20),100, 'Normalization', 'pdf')
xlim([-10 15])
hold on, histogram(rxAntennaGain_5_L(tc1msec),100,'Normalization', 'pdf')
hold on, histogram(rxAntennaGain_5_L(fixgain),100,'Normalization', 'pdf')
title('Antenna gain L5/E5 Left with different coherent integration and AGC')
xlabel('rxAntennaGain L5/E5 [dB]')
legend('Nominal', 'Tc=1msec', 'fixed gain')

figure, histogram(SNR_5_L(pitch20),100, 'Normalization', 'pdf')
xlim([-15 20])
hold on, histogram(SNR_5_L(tc1msec),100,'Normalization', 'pdf')
hold on, histogram(SNR_5_L(fixgain),100,'Normalization', 'pdf')
title('SNR L5/E5 Left with different coherent integration and AGC')
xlabel('SNR L5/E5 [dB]')
legend('Nominal', 'Tc=1msec', 'fixed gain')

%%% STATISTICS
SNR_GT05(1,1)=round(100*length(100*intersect(pitch20, find(constellation=='GPS' & SNR_1_L >=0.5)))/length(intersect(pitch20, find(constellation=='GPS' & isnan(SNR_1_L)==0))),1) ;
SNR_GT05(1,3)=round(100*length(100*intersect(pitch00, find(constellation=='GPS' & SNR_1_L >=0.5)))/length(intersect(pitch00, find(constellation=='GPS' & isnan(SNR_1_L)==0))),1) ;
SNR_GT05(1,4)=round(100*length(100*intersect(pitch40, find(constellation=='GPS' & SNR_1_L >=0.5)))/length(intersect(pitch40, find(constellation=='GPS' & isnan(SNR_1_L)==0))),1) ;
SNR_GT05(1,2)=round(100*length(100*intersect(tc1msec, find(constellation=='GPS' & SNR_1_L >=0.5)))/length(intersect(tc1msec, find(constellation=='GPS' & isnan(SNR_1_L)==0))),1) ;
SNR_GT05(1,5)=round(100*length(100*intersect(linesp, find(constellation=='GPS' & SNR_1_L >=0.5)))/length(intersect(linesp, find(constellation=='GPS' & isnan(SNR_1_L)==0))),1) ;
SNR_GT05(1,6)=round(100*length(100*intersect(fixgain, find(constellation=='GPS' & SNR_1_L >=0.5)))/length(intersect(fixgain, find(constellation=='GPS' & isnan(SNR_1_L)==0))),1) ;
SNR_GT05(1,7)=round(100*length(100*intersect(offsets, find(constellation=='GPS' & SNR_1_L >=0.5)))/length(intersect(offsets, find(constellation=='GPS' & isnan(SNR_1_L)==0))),1) ;

SNR_GT05(2,1)=round(100*length(100*intersect(pitch20, find(constellation=='GPS' & SNR_1_R >=0.5)))/length(intersect(pitch20, find(constellation=='GPS' & isnan(SNR_1_L)==0))),1) ;
SNR_GT05(2,3)=round(100*length(100*intersect(pitch00, find(constellation=='GPS' & SNR_1_R >=0.5)))/length(intersect(pitch00, find(constellation=='GPS' & isnan(SNR_1_L)==0))),1) ;
SNR_GT05(2,4)=round(100*length(100*intersect(pitch40, find(constellation=='GPS' & SNR_1_R >=0.5)))/length(intersect(pitch40, find(constellation=='GPS' & isnan(SNR_1_L)==0))),1) ;
SNR_GT05(2,2)=round(100*length(100*intersect(tc1msec, find(constellation=='GPS' & SNR_1_R >=0.5)))/length(intersect(tc1msec, find(constellation=='GPS' & isnan(SNR_1_L)==0))),1) ;
SNR_GT05(2,5)=round(100*length(100*intersect(linesp, find(constellation=='GPS' & SNR_1_R>=0.5)))/length(intersect(linesp, find(constellation=='GPS' & isnan(SNR_1_L)==0))),1) ;
SNR_GT05(2,6)=round(100*length(100*intersect(fixgain, find(constellation=='GPS' & SNR_1_R >=0.5)))/length(intersect(fixgain, find(constellation=='GPS' & isnan(SNR_1_L)==0))),1) ;
SNR_GT05(2,7)=round(100*length(100*intersect(offsets, find(constellation=='GPS' & SNR_1_R >=0.5)))/length(intersect(offsets, find(constellation=='GPS' & isnan(SNR_1_L)==0))),1) ;

SNR_GT05(3,1)=round(100*length(100*intersect(pitch20, find(constellation=='Galileo' & SNR_1_L >=0.5)))/length(intersect(pitch20, find(constellation=='Galileo' & isnan(SNR_1_L)==0))),1) ;
SNR_GT05(3,3)=round(100*length(100*intersect(pitch00, find(constellation=='Galileo' & SNR_1_L >=0.5)))/length(intersect(pitch00, find(constellation=='Galileo' & isnan(SNR_1_L)==0))),1) ;
SNR_GT05(3,4)=round(100*length(100*intersect(pitch40, find(constellation=='Galileo' & SNR_1_L >=0.5)))/length(intersect(pitch40, find(constellation=='Galileo' & isnan(SNR_1_L)==0))),1) ;
SNR_GT05(3,2)=round(100*length(100*intersect(tc1msec, find(constellation=='Galileo' & SNR_1_L >=0.5)))/length(intersect(tc1msec, find(constellation=='Galileo' & isnan(SNR_1_L)==0))),1) ;
SNR_GT05(3,5)=round(100*length(100*intersect(linesp, find(constellation=='Galileo' & SNR_1_L >=0.5)))/length(intersect(linesp, find(constellation=='Galileo' & isnan(SNR_1_L)==0))),1) ;
SNR_GT05(3,6)=round(100*length(100*intersect(fixgain, find(constellation=='Galileo' & SNR_1_L >=0.5)))/length(intersect(fixgain, find(constellation=='Galileo' & isnan(SNR_1_L)==0))),1) ;
SNR_GT05(3,7)=round(100*length(100*intersect(offsets, find(constellation=='Galileo' & SNR_1_L >=0.5)))/length(intersect(offsets, find(constellation=='Galileo' & isnan(SNR_1_L)==0))),1) ;

SNR_GT05(4,1)=round(100*length(100*intersect(pitch20, find(constellation=='Galileo' & SNR_1_R >=0.5)))/length(intersect(pitch20, find(constellation=='Galileo' & isnan(SNR_1_L)==0))),1) ;
SNR_GT05(4,3)=round(100*length(100*intersect(pitch00, find(constellation=='Galileo' & SNR_1_R >=0.5)))/length(intersect(pitch00, find(constellation=='Galileo' & isnan(SNR_1_L)==0))),1) ;
SNR_GT05(4,4)=round(100*length(100*intersect(pitch40, find(constellation=='Galileo' & SNR_1_R >=0.5)))/length(intersect(pitch40, find(constellation=='Galileo' & isnan(SNR_1_L)==0))),1) ;
SNR_GT05(4,2)=round(100*length(100*intersect(tc1msec, find(constellation=='Galileo' & SNR_1_R >=0.5)))/length(intersect(tc1msec, find(constellation=='Galileo' & isnan(SNR_1_L)==0))),1) ;
SNR_GT05(4,5)=round(100*length(100*intersect(linesp, find(constellation=='Galileo' & SNR_1_R >=0.5)))/length(intersect(linesp, find(constellation=='Galileo' & isnan(SNR_1_L)==0))),1) ;
SNR_GT05(4,6)=round(100*length(100*intersect(fixgain, find(constellation=='Galileo' & SNR_1_R >=0.5)))/length(intersect(fixgain, find(constellation=='Galileo' & isnan(SNR_1_L)==0))),1) ;
SNR_GT05(4,7)=round(100*length(100*intersect(offsets, find(constellation=='Galileo' & SNR_1_R >=0.5)))/length(intersect(offsets, find(constellation=='Galileo' & isnan(SNR_1_L)==0))),1) ;
%%
SNR_GT05(5,1)=round(100*length(100*intersect(pitch20, find(constellation=='GPS' & SNR_5_L >=0.5)))/length(intersect(pitch20, find(constellation=='GPS' & isnan(SNR_1_L)==0))),1) ;
SNR_GT05(5,3)=round(100*length(100*intersect(pitch00, find(constellation=='GPS' & SNR_5_L >=0.5)))/length(intersect(pitch00, find(constellation=='GPS' & isnan(SNR_1_L)==0))),1) ;
SNR_GT05(5,4)=round(100*length(100*intersect(pitch40, find(constellation=='GPS' & SNR_5_L >=0.5)))/length(intersect(pitch40, find(constellation=='GPS' & isnan(SNR_1_L)==0))),1) ;
SNR_GT05(5,2)=round(100*length(100*intersect(tc1msec, find(constellation=='GPS' & SNR_5_L >=0.5)))/length(intersect(tc1msec, find(constellation=='GPS' & isnan(SNR_1_L)==0))),1) ;
SNR_GT05(5,5)=round(100*length(100*intersect(linesp, find(constellation=='GPS' & SNR_5_L >=0.5)))/length(intersect(linesp, find(constellation=='GPS' & isnan(SNR_1_L)==0))),1) ;
SNR_GT05(5,6)=round(100*length(100*intersect(fixgain, find(constellation=='GPS' & SNR_5_L >=0.5)))/length(intersect(fixgain, find(constellation=='GPS' & isnan(SNR_1_L)==0))),1) ;
SNR_GT05(5,7)=round(100*length(100*intersect(offsets, find(constellation=='GPS' & SNR_5_L >=0.5)))/length(intersect(offsets, find(constellation=='GPS' & isnan(SNR_1_L)==0))),1) ;

SNR_GT05(6,1)=round(100*length(100*intersect(pitch20, find(constellation=='GPS' & SNR_5_R >=0.5)))/length(intersect(pitch20, find(constellation=='GPS' & isnan(SNR_1_L)==0))),1) ;
SNR_GT05(6,3)=round(100*length(100*intersect(pitch00, find(constellation=='GPS' & SNR_5_R >=0.5)))/length(intersect(pitch00, find(constellation=='GPS' & isnan(SNR_1_L)==0))),1) ;
SNR_GT05(6,4)=round(100*length(100*intersect(pitch40, find(constellation=='GPS' & SNR_5_R >=0.5)))/length(intersect(pitch40, find(constellation=='GPS' & isnan(SNR_1_L)==0))),1) ;
SNR_GT05(6,2)=round(100*length(100*intersect(tc1msec, find(constellation=='GPS' & SNR_5_R >=0.5)))/length(intersect(tc1msec, find(constellation=='GPS' & isnan(SNR_1_L)==0))),1) ;
SNR_GT05(6,5)=round(100*length(100*intersect(linesp, find(constellation=='GPS' & SNR_5_R>=0.5)))/length(intersect(linesp, find(constellation=='GPS' & isnan(SNR_1_L)==0))),1) ;
SNR_GT05(6,6)=round(100*length(100*intersect(fixgain, find(constellation=='GPS' & SNR_5_R >=0.5)))/length(intersect(fixgain, find(constellation=='GPS' & isnan(SNR_1_L)==0))),1) ;
SNR_GT05(6,7)=round(100*length(100*intersect(offsets, find(constellation=='GPS' & SNR_5_R >=0.5)))/length(intersect(offsets, find(constellation=='GPS' & isnan(SNR_1_L)==0))),1) ;

SNR_GT05(7,1)=round(100*length(100*intersect(pitch20, find(constellation=='Galileo' & SNR_5_L >=0.5)))/length(intersect(pitch20, find(constellation=='Galileo' & isnan(SNR_1_L)==0))),1) ;
SNR_GT05(7,3)=round(100*length(100*intersect(pitch00, find(constellation=='Galileo' & SNR_5_L >=0.5)))/length(intersect(pitch00, find(constellation=='Galileo' & isnan(SNR_1_L)==0))),1) ;
SNR_GT05(7,4)=round(100*length(100*intersect(pitch40, find(constellation=='Galileo' & SNR_5_L >=0.5)))/length(intersect(pitch40, find(constellation=='Galileo' & isnan(SNR_1_L)==0))),1) ;
SNR_GT05(7,2)=round(100*length(100*intersect(tc1msec, find(constellation=='Galileo' & SNR_5_L >=0.5)))/length(intersect(tc1msec, find(constellation=='Galileo' & isnan(SNR_1_L)==0))),1) ;
SNR_GT05(7,5)=round(100*length(100*intersect(linesp, find(constellation=='Galileo' & SNR_5_L >=0.5)))/length(intersect(linesp, find(constellation=='Galileo' & isnan(SNR_1_L)==0))),1) ;
SNR_GT05(7,6)=round(100*length(100*intersect(fixgain, find(constellation=='Galileo' & SNR_5_L >=0.5)))/length(intersect(fixgain, find(constellation=='Galileo' & isnan(SNR_1_L)==0))),1) ;
SNR_GT05(7,7)=round(100*length(100*intersect(offsets, find(constellation=='Galileo' & SNR_5_L >=0.5)))/length(intersect(offsets, find(constellation=='Galileo' & isnan(SNR_1_L)==0))),1) ;

SNR_GT05(8,1)=round(100*length(100*intersect(pitch20, find(constellation=='Galileo' & SNR_5_R >=0.5)))/length(intersect(pitch20, find(constellation=='Galileo' & isnan(SNR_1_L)==0))),1) ;
SNR_GT05(8,3)=round(100*length(100*intersect(pitch00, find(constellation=='Galileo' & SNR_5_R >=0.5)))/length(intersect(pitch00, find(constellation=='Galileo' & isnan(SNR_1_L)==0))),1) ;
SNR_GT05(8,4)=round(100*length(100*intersect(pitch40, find(constellation=='Galileo' & SNR_5_R >=0.5)))/length(intersect(pitch40, find(constellation=='Galileo' & isnan(SNR_1_L)==0))),1) ;
SNR_GT05(8,2)=round(100*length(100*intersect(tc1msec, find(constellation=='Galileo' & SNR_5_R >=0.5)))/length(intersect(tc1msec, find(constellation=='Galileo' & isnan(SNR_1_L)==0))),1) ;
SNR_GT05(8,5)=round(100*length(100*intersect(linesp, find(constellation=='Galileo' & SNR_5_R >=0.5)))/length(intersect(linesp, find(constellation=='Galileo' & isnan(SNR_1_L)==0))),1) ;
SNR_GT05(8,6)=round(100*length(100*intersect(fixgain, find(constellation=='Galileo' & SNR_5_R >=0.5)))/length(intersect(fixgain, find(constellation=='Galileo' & isnan(SNR_1_L)==0))),1) ;
SNR_GT05(8,7)=round(100*length(100*intersect(offsets, find(constellation=='Galileo' & SNR_5_R >=0.5)))/length(intersect(offsets, find(constellation=='Galileo' & isnan(SNR_1_L)==0))),1) ;

Channel={'L1 Left';'L1 Right';'E1 Left';'E1 Right';'L5 Left';'L5 Right';'E5 Left';'E5 Right'; 'Mean channels'};
tutti=round(mean(SNR_GT05, 1),1) ;
Nominal=SNR_GT05(:,1) ; Nominal=[Nominal; tutti(1)] ; 
ONEmsec=SNR_GT05(:,2) ; ONEmsec=[ONEmsec; tutti(2)] ;
Pitch0=SNR_GT05(:,3) ; Pitch0=[Pitch0; tutti(3)] ;
Pitch40=SNR_GT05(:,4) ; Pitch40=[Pitch40; tutti(4)] ;
Linespacing=SNR_GT05(:,5) ; Linespacing=[Linespacing; tutti(5)] ;
Fixedgain=SNR_GT05(:,6) ; Fixedgain=[Fixedgain; tutti(6)] ;
Offsets=SNR_GT05(:,7) ; Offsets=[Offsets; tutti(7)] ;
TSNR = table(Channel,Nominal,ONEmsec,Pitch0,Pitch40,Linespacing,Fixedgain,Offsets ) ;
TSNR.Properties.Description = '     Percentage across valid values of SNR>=0.5dB for different modes'; 
disp(TSNR.Properties.Description) ; disp(TSNR) ;

%%%  rxAntennaGain

rxGain_GT05(1,1)=round(100*length(100*intersect(pitch20, find(constellation=='GPS' & rxAntennaGain_1_L >=0.5)))/length(intersect(pitch20, find(constellation=='GPS' & isnan(rxAntennaGain_1_L)==0))),1) ;
rxGain_GT05(1,3)=round(100*length(100*intersect(pitch00, find(constellation=='GPS' & rxAntennaGain_1_L >=0.5)))/length(intersect(pitch00, find(constellation=='GPS' & isnan(rxAntennaGain_1_L)==0))),1) ;
rxGain_GT05(1,4)=round(100*length(100*intersect(pitch40, find(constellation=='GPS' & rxAntennaGain_1_L >=0.5)))/length(intersect(pitch40, find(constellation=='GPS' & isnan(rxAntennaGain_1_L)==0))),1) ;
rxGain_GT05(1,2)=round(100*length(100*intersect(tc1msec, find(constellation=='GPS' & rxAntennaGain_1_L >=0.5)))/length(intersect(tc1msec, find(constellation=='GPS' & isnan(rxAntennaGain_1_L)==0))),1) ;
rxGain_GT05(1,5)=round(100*length(100*intersect(linesp, find(constellation=='GPS' & rxAntennaGain_1_L >=0.5)))/length(intersect(linesp, find(constellation=='GPS' & isnan(rxAntennaGain_1_L)==0))),1) ;
rxGain_GT05(1,6)=round(100*length(100*intersect(fixgain, find(constellation=='GPS' & rxAntennaGain_1_L >=0.5)))/length(intersect(fixgain, find(constellation=='GPS' & isnan(rxAntennaGain_1_L)==0))),1) ;
rxGain_GT05(1,7)=round(100*length(100*intersect(offsets, find(constellation=='GPS' & rxAntennaGain_1_L >=0.5)))/length(intersect(offsets, find(constellation=='GPS' & isnan(rxAntennaGain_1_L)==0))),1) ;

rxGain_GT05(2,1)=round(100*length(100*intersect(pitch20, find(constellation=='GPS' & rxAntennaGain_1_R >=0.5)))/length(intersect(pitch20, find(constellation=='GPS' & isnan(rxAntennaGain_1_R)==0))),1) ;
rxGain_GT05(2,3)=round(100*length(100*intersect(pitch00, find(constellation=='GPS' & rxAntennaGain_1_R >=0.5)))/length(intersect(pitch00, find(constellation=='GPS' & isnan(rxAntennaGain_1_R)==0))),1) ;
rxGain_GT05(2,4)=round(100*length(100*intersect(pitch40, find(constellation=='GPS' & rxAntennaGain_1_R >=0.5)))/length(intersect(pitch40, find(constellation=='GPS' & isnan(rxAntennaGain_1_R)==0))),1) ;
rxGain_GT05(2,2)=round(100*length(100*intersect(tc1msec, find(constellation=='GPS' & rxAntennaGain_1_R >=0.5)))/length(intersect(tc1msec, find(constellation=='GPS' & isnan(rxAntennaGain_1_R)==0))),1) ;
rxGain_GT05(2,5)=round(100*length(100*intersect(linesp, find(constellation=='GPS' & rxAntennaGain_1_R>=0.5)))/length(intersect(linesp, find(constellation=='GPS' & isnan(rxAntennaGain_1_R)==0))),1) ;
rxGain_GT05(2,6)=round(100*length(100*intersect(fixgain, find(constellation=='GPS' & rxAntennaGain_1_R >=0.5)))/length(intersect(fixgain, find(constellation=='GPS' & isnan(rxAntennaGain_1_R)==0))),1) ;
rxGain_GT05(2,7)=round(100*length(100*intersect(offsets, find(constellation=='GPS' & rxAntennaGain_1_R >=0.5)))/length(intersect(offsets, find(constellation=='GPS' & isnan(rxAntennaGain_1_R)==0))),1) ;

rxGain_GT05(3,1)=round(100*length(100*intersect(pitch20, find(constellation=='Galileo' & rxAntennaGain_1_L >=0.5)))/length(intersect(pitch20, find(constellation=='Galileo' & isnan(rxAntennaGain_1_L)==0))),1) ;
rxGain_GT05(3,3)=round(100*length(100*intersect(pitch00, find(constellation=='Galileo' & rxAntennaGain_1_L >=0.5)))/length(intersect(pitch00, find(constellation=='Galileo' & isnan(rxAntennaGain_1_L)==0))),1) ;
rxGain_GT05(3,4)=round(100*length(100*intersect(pitch40, find(constellation=='Galileo' & rxAntennaGain_1_L >=0.5)))/length(intersect(pitch40, find(constellation=='Galileo' & isnan(rxAntennaGain_1_L)==0))),1) ;
rxGain_GT05(3,2)=round(100*length(100*intersect(tc1msec, find(constellation=='Galileo' & rxAntennaGain_1_L >=0.5)))/length(intersect(tc1msec, find(constellation=='Galileo' & isnan(rxAntennaGain_1_L)==0))),1) ;
rxGain_GT05(3,5)=round(100*length(100*intersect(linesp, find(constellation=='Galileo' & rxAntennaGain_1_L >=0.5)))/length(intersect(linesp, find(constellation=='Galileo' & isnan(rxAntennaGain_1_L)==0))),1) ;
rxGain_GT05(3,6)=round(100*length(100*intersect(fixgain, find(constellation=='Galileo' & rxAntennaGain_1_L >=0.5)))/length(intersect(fixgain, find(constellation=='Galileo' & isnan(rxAntennaGain_1_L)==0))),1) ;
rxGain_GT05(3,7)=round(100*length(100*intersect(offsets, find(constellation=='Galileo' & rxAntennaGain_1_L >=0.5)))/length(intersect(offsets, find(constellation=='Galileo' & isnan(rxAntennaGain_1_L)==0))),1) ;

rxGain_GT05(4,1)=round(100*length(100*intersect(pitch20, find(constellation=='Galileo' & rxAntennaGain_1_R >=0.5)))/length(intersect(pitch20, find(constellation=='Galileo' & isnan(rxAntennaGain_1_R)==0))),1) ;
rxGain_GT05(4,3)=round(100*length(100*intersect(pitch00, find(constellation=='Galileo' & rxAntennaGain_1_R >=0.5)))/length(intersect(pitch00, find(constellation=='Galileo' & isnan(rxAntennaGain_1_R)==0))),1) ;
rxGain_GT05(4,4)=round(100*length(100*intersect(pitch40, find(constellation=='Galileo' & rxAntennaGain_1_R >=0.5)))/length(intersect(pitch40, find(constellation=='Galileo' & isnan(rxAntennaGain_1_R)==0))),1) ;
rxGain_GT05(4,2)=round(100*length(100*intersect(tc1msec, find(constellation=='Galileo' & rxAntennaGain_1_R >=0.5)))/length(intersect(tc1msec, find(constellation=='Galileo' & isnan(rxAntennaGain_1_R)==0))),1) ;
rxGain_GT05(4,5)=round(100*length(100*intersect(linesp, find(constellation=='Galileo' & rxAntennaGain_1_R >=0.5)))/length(intersect(linesp, find(constellation=='Galileo' & isnan(rxAntennaGain_1_R)==0))),1) ;
rxGain_GT05(4,6)=round(100*length(100*intersect(fixgain, find(constellation=='Galileo' & rxAntennaGain_1_R >=0.5)))/length(intersect(fixgain, find(constellation=='Galileo' & isnan(rxAntennaGain_1_R)==0))),1) ;
rxGain_GT05(4,7)=round(100*length(100*intersect(offsets, find(constellation=='Galileo' & rxAntennaGain_1_R >=0.5)))/length(intersect(offsets, find(constellation=='Galileo' & isnan(rxAntennaGain_1_R)==0))),1) ;
%%
rxGain_GT05(5,1)=round(100*length(100*intersect(pitch20, find(constellation=='GPS' & rxAntennaGain_5_L >=0.5)))/length(intersect(pitch20, find(constellation=='GPS' & isnan(rxAntennaGain_5_L)==0))),1) ;
rxGain_GT05(5,3)=round(100*length(100*intersect(pitch00, find(constellation=='GPS' & rxAntennaGain_5_L >=0.5)))/length(intersect(pitch00, find(constellation=='GPS' & isnan(rxAntennaGain_5_L)==0))),1) ;
rxGain_GT05(5,4)=round(100*length(100*intersect(pitch40, find(constellation=='GPS' & rxAntennaGain_5_L >=0.5)))/length(intersect(pitch40, find(constellation=='GPS' & isnan(rxAntennaGain_5_L)==0))),1) ;
rxGain_GT05(5,2)=round(100*length(100*intersect(tc1msec, find(constellation=='GPS' & rxAntennaGain_5_L >=0.5)))/length(intersect(tc1msec, find(constellation=='GPS' & isnan(rxAntennaGain_5_L)==0))),1) ;
rxGain_GT05(5,5)=round(100*length(100*intersect(linesp, find(constellation=='GPS' & rxAntennaGain_5_L >=0.5)))/length(intersect(linesp, find(constellation=='GPS' & isnan(rxAntennaGain_5_L)==0))),1) ;
rxGain_GT05(5,6)=round(100*length(100*intersect(fixgain, find(constellation=='GPS' & rxAntennaGain_5_L >=0.5)))/length(intersect(fixgain, find(constellation=='GPS' & isnan(rxAntennaGain_5_L)==0))),1) ;
rxGain_GT05(5,7)=round(100*length(100*intersect(offsets, find(constellation=='GPS' & rxAntennaGain_5_L >=0.5)))/length(intersect(offsets, find(constellation=='GPS' & isnan(rxAntennaGain_5_L)==0))),1) ;

rxGain_GT05(6,1)=round(100*length(100*intersect(pitch20, find(constellation=='GPS' & rxAntennaGain_5_R >=0.5)))/length(intersect(pitch20, find(constellation=='GPS' & isnan(rxAntennaGain_5_R)==0))),1) ;
rxGain_GT05(6,3)=round(100*length(100*intersect(pitch00, find(constellation=='GPS' & rxAntennaGain_5_R >=0.5)))/length(intersect(pitch00, find(constellation=='GPS' & isnan(rxAntennaGain_5_R)==0))),1) ;
rxGain_GT05(6,4)=round(100*length(100*intersect(pitch40, find(constellation=='GPS' & rxAntennaGain_5_R >=0.5)))/length(intersect(pitch40, find(constellation=='GPS' & isnan(rxAntennaGain_5_R)==0))),1) ;
rxGain_GT05(6,2)=round(100*length(100*intersect(tc1msec, find(constellation=='GPS' & rxAntennaGain_5_R >=0.5)))/length(intersect(tc1msec, find(constellation=='GPS' & isnan(rxAntennaGain_5_R)==0))),1) ;
rxGain_GT05(6,5)=round(100*length(100*intersect(linesp, find(constellation=='GPS' & rxAntennaGain_5_R>=0.5)))/length(intersect(linesp, find(constellation=='GPS' & isnan(rxAntennaGain_5_R)==0))),1) ;
rxGain_GT05(6,6)=round(100*length(100*intersect(fixgain, find(constellation=='GPS' & rxAntennaGain_5_R >=0.5)))/length(intersect(fixgain, find(constellation=='GPS' & isnan(rxAntennaGain_5_R)==0))),1) ;
rxGain_GT05(6,7)=round(100*length(100*intersect(offsets, find(constellation=='GPS' & rxAntennaGain_5_R >=0.5)))/length(intersect(offsets, find(constellation=='GPS' & isnan(rxAntennaGain_5_R)==0))),1) ;

rxGain_GT05(7,1)=round(100*length(100*intersect(pitch20, find(constellation=='Galileo' & rxAntennaGain_5_L >=0.5)))/length(intersect(pitch20, find(constellation=='Galileo' & isnan(rxAntennaGain_5_L)==0))),1) ;
rxGain_GT05(7,3)=round(100*length(100*intersect(pitch00, find(constellation=='Galileo' & rxAntennaGain_5_L >=0.5)))/length(intersect(pitch00, find(constellation=='Galileo' & isnan(rxAntennaGain_5_L)==0))),1) ;
rxGain_GT05(7,4)=round(100*length(100*intersect(pitch40, find(constellation=='Galileo' & rxAntennaGain_5_L >=0.5)))/length(intersect(pitch40, find(constellation=='Galileo' & isnan(rxAntennaGain_5_L)==0))),1) ;
rxGain_GT05(7,2)=round(100*length(100*intersect(tc1msec, find(constellation=='Galileo' & rxAntennaGain_5_L >=0.5)))/length(intersect(tc1msec, find(constellation=='Galileo' & isnan(rxAntennaGain_5_L)==0))),1) ;
rxGain_GT05(7,5)=round(100*length(100*intersect(linesp, find(constellation=='Galileo' & rxAntennaGain_5_L >=0.5)))/length(intersect(linesp, find(constellation=='Galileo' & isnan(rxAntennaGain_5_L)==0))),1) ;
rxGain_GT05(7,6)=round(100*length(100*intersect(fixgain, find(constellation=='Galileo' & rxAntennaGain_5_L >=0.5)))/length(intersect(fixgain, find(constellation=='Galileo' & isnan(rxAntennaGain_5_L)==0))),1) ;
rxGain_GT05(7,7)=round(100*length(100*intersect(offsets, find(constellation=='Galileo' & rxAntennaGain_5_L >=0.5)))/length(intersect(offsets, find(constellation=='Galileo' & isnan(rxAntennaGain_5_L)==0))),1) ;

rxGain_GT05(8,1)=round(100*length(100*intersect(pitch20, find(constellation=='Galileo' & rxAntennaGain_5_R >=0.5)))/length(intersect(pitch20, find(constellation=='Galileo' & isnan(rxAntennaGain_5_R)==0))),1) ;
rxGain_GT05(8,3)=round(100*length(100*intersect(pitch00, find(constellation=='Galileo' & rxAntennaGain_5_R >=0.5)))/length(intersect(pitch00, find(constellation=='Galileo' & isnan(rxAntennaGain_5_R)==0))),1) ;
rxGain_GT05(8,4)=round(100*length(100*intersect(pitch40, find(constellation=='Galileo' & rxAntennaGain_5_R >=0.5)))/length(intersect(pitch40, find(constellation=='Galileo' & isnan(rxAntennaGain_5_R)==0))),1) ;
rxGain_GT05(8,2)=round(100*length(100*intersect(tc1msec, find(constellation=='Galileo' & rxAntennaGain_5_R >=0.5)))/length(intersect(tc1msec, find(constellation=='Galileo' & isnan(rxAntennaGain_5_R)==0))),1) ;
rxGain_GT05(8,5)=round(100*length(100*intersect(linesp, find(constellation=='Galileo' & rxAntennaGain_5_R >=0.5)))/length(intersect(linesp, find(constellation=='Galileo' & isnan(rxAntennaGain_5_R)==0))),1) ;
rxGain_GT05(8,6)=round(100*length(100*intersect(fixgain, find(constellation=='Galileo' & rxAntennaGain_5_R >=0.5)))/length(intersect(fixgain, find(constellation=='Galileo' & isnan(rxAntennaGain_5_R)==0))),1) ;
rxGain_GT05(8,7)=round(100*length(100*intersect(offsets, find(constellation=='Galileo' & rxAntennaGain_5_R >=0.5)))/length(intersect(offsets, find(constellation=='Galileo' & isnan(rxAntennaGain_5_R)==0))),1) ;

Channel={'L1 Left';'L1 Right';'E1 Left';'E1 Right';'L5 Left';'L5 Right';'E5 Left';'E5 Right'; 'Mean channels'};
tutti=round(mean(rxGain_GT05, 1),1) ;
Nominal=rxGain_GT05(:,1) ; Nominal=[Nominal; tutti(1)] ; 
ONEmsec=rxGain_GT05(:,2) ; ONEmsec=[ONEmsec; tutti(2)] ;
Pitch0=rxGain_GT05(:,3) ; Pitch0=[Pitch0; tutti(3)] ;
Pitch40=rxGain_GT05(:,4) ; Pitch40=[Pitch40; tutti(4)] ;
Linespacing=rxGain_GT05(:,5) ; Linespacing=[Linespacing; tutti(5)] ;
Fixedgain=rxGain_GT05(:,6) ; Fixedgain=[Fixedgain; tutti(6)] ;
Offsets=rxGain_GT05(:,7) ; Offsets=[Offsets; tutti(7)] ;
TrxGain = table(Channel,Nominal,ONEmsec,Pitch0,Pitch40,Linespacing,Fixedgain,Offsets ) ;
TrxGain.Properties.Description = '     Percentage across valid values of antenna gain>=0.5 dB for different modes'; 
disp(TrxGain.Properties.Description) ; disp(TrxGain) ;

%%% FIND NaN 
NoDataValues(1,1)=round(100*length(find(isnan(reflectivityLinear_1_L)>0 & constellation=='GPS'))/length(reflectivityLinear_1_L(constellation=='GPS')),1) ;
NoDataValues(1,2)=round(100*length(find(isnan(reflectivityLinear_1_R)>0 & constellation=='GPS'))/length(reflectivityLinear_1_R(constellation=='GPS')),1) ;
NoDataValues(1,3)=round(100*length(find(isnan(reflectivityLinear_1_L)>0 & constellation=='Galileo'))/length(reflectivityLinear_1_L(constellation=='Galileo')),1) ;
NoDataValues(1,4)=round(100*length(find(isnan(reflectivityLinear_1_R)>0 & constellation=='Galileo'))/length(reflectivityLinear_1_R(constellation=='Galileo')),1) ;
NoDataValues(1,5)=round(100*length(find(isnan(reflectivityLinear_5_L)>0 & constellation=='GPS'))/length(reflectivityLinear_5_L(constellation=='GPS')),1) ;
NoDataValues(1,6)=round(100*length(find(isnan(reflectivityLinear_5_R)>0 & constellation=='GPS'))/length(reflectivityLinear_5_R(constellation=='GPS')),1) ;
NoDataValues(1,7)=round(100*length(find(isnan(reflectivityLinear_5_L)>0 & constellation=='Galileo'))/length(reflectivityLinear_5_L(constellation=='Galileo')),1) ;
NoDataValues(1,8)=round(100*length(find(isnan(reflectivityLinear_5_R)>0 & constellation=='Galileo'))/length(reflectivityLinear_5_R(constellation=='Galileo')),1) ;

NoDataValues(2,1)=round(100*length(find(isnan(SNR_1_L)>0 & constellation=='GPS'))/length(SNR_1_L(constellation=='GPS')),1) ;
NoDataValues(2,2)=round(100*length(find(isnan(SNR_1_R)>0 & constellation=='GPS'))/length(SNR_1_R(constellation=='GPS')),1) ;
NoDataValues(2,3)=round(100*length(find(isnan(SNR_1_L)>0 & constellation=='Galileo'))/length(SNR_1_L(constellation=='Galileo')),1) ;
NoDataValues(2,4)=round(100*length(find(isnan(SNR_1_R)>0 & constellation=='Galileo'))/length(SNR_1_R(constellation=='Galileo')),1) ;
NoDataValues(2,5)=round(100*length(find(isnan(SNR_5_L)>0 & constellation=='GPS'))/length(SNR_5_L(constellation=='GPS')),1) ;
NoDataValues(2,6)=round(100*length(find(isnan(SNR_5_R)>0 & constellation=='GPS'))/length(SNR_5_R(constellation=='GPS')),1) ;
NoDataValues(2,7)=round(100*length(find(isnan(SNR_5_L)>0 & constellation=='Galileo'))/length(SNR_5_L(constellation=='Galileo')),1) ;
NoDataValues(2,8)=round(100*length(find(isnan(SNR_5_R)>0 & constellation=='Galileo'))/length(SNR_5_R(constellation=='Galileo')),1) ;


NoDataValues(3,1)=round(100*length(find(isnan(rxAntennaGain_1_L)>0 & constellation=='GPS'))/length(rxAntennaGain_1_L(constellation=='GPS')),1) ;
NoDataValues(3,2)=round(100*length(find(isnan(rxAntennaGain_1_R)>0 & constellation=='GPS'))/length(rxAntennaGain_1_R(constellation=='GPS')),1) ;
NoDataValues(3,3)=round(100*length(find(isnan(rxAntennaGain_1_L)>0 & constellation=='Galileo'))/length(rxAntennaGain_1_L(constellation=='Galileo')),1) ;
NoDataValues(3,4)=round(100*length(find(isnan(rxAntennaGain_1_R)>0 & constellation=='Galileo'))/length(rxAntennaGain_1_R(constellation=='Galileo')),1) ;
NoDataValues(3,5)=round(100*length(find(isnan(rxAntennaGain_5_L)>0 & constellation=='GPS'))/length(rxAntennaGain_5_L(constellation=='GPS')),1) ;
NoDataValues(3,6)=round(100*length(find(isnan(rxAntennaGain_5_R)>0 & constellation=='GPS'))/length(rxAntennaGain_5_R(constellation=='GPS')),1) ;
NoDataValues(3,7)=round(100*length(find(isnan(rxAntennaGain_5_L)>0 & constellation=='Galileo'))/length(rxAntennaGain_5_L(constellation=='Galileo')),1) ;
NoDataValues(3,8)=round(100*length(find(isnan(rxAntennaGain_5_R)>0 & constellation=='Galileo'))/length(rxAntennaGain_5_R(constellation=='Galileo')),1) ;

Channel={'L1 Left';'L1 Right';'E1 Left';'E1 Right';'L5 Left';'L5 Right';'E5 Left';'E5 Right'; 'Mean across channels'};
tutti=round(mean(NoDataValues, 2),1) ;
MissingReflectivity=NoDataValues(1,:)' ; MissingReflectivity=[MissingReflectivity; tutti(1)] ; 
MissingSNR=NoDataValues(2,:)' ; MissingSNR=[MissingSNR; tutti(2)] ; 
MissingAntennaGain=NoDataValues(3,:)' ; MissingAntennaGain=[MissingAntennaGain; tutti(3)] ;
Tnan = table(Channel,MissingReflectivity, MissingSNR, MissingAntennaGain ) ;
Tnan.Properties.Description = '         Missing  percentage (% of total SP''s) of variables'; 
disp(Tnan.Properties.Description) ; disp(Tnan) ;
%%%%%%%%%%%%%%%%%%%

NoDataValuesMod(1,1)=round(100*length(intersect(pitch20,find(isnan(reflectivityLinear_1_L)>0 & constellation=='GPS')))/length(reflectivityLinear_1_L(intersect(pitch20, find(constellation=='GPS')))),1) ;
NoDataValuesMod(1,2)=round(100*length(intersect(pitch00,find(isnan(reflectivityLinear_1_L)>0 & constellation=='GPS')))/length(reflectivityLinear_1_L(intersect(pitch00, find(constellation=='GPS')))),1) ;
NoDataValuesMod(1,3)=round(100*length(intersect(pitch40,find(isnan(reflectivityLinear_1_L)>0 & constellation=='GPS')))/length(reflectivityLinear_1_L(intersect(pitch40, find(constellation=='GPS')))),1) ;
NoDataValuesMod(1,4)=round(100*length(intersect(tc1msec,find(isnan(reflectivityLinear_1_L)>0 & constellation=='GPS')))/length(reflectivityLinear_1_L(intersect(tc1msec, find(constellation=='GPS')))),1) ;
NoDataValuesMod(1,5)=round(100*length(intersect(linesp,find(isnan(reflectivityLinear_1_L)>0 & constellation=='GPS')))/length(reflectivityLinear_1_L(intersect(linesp, find(constellation=='GPS')))),1) ;
NoDataValuesMod(1,6)=round(100*length(intersect(fixgain,find(isnan(reflectivityLinear_1_L)>0 & constellation=='GPS')))/length(reflectivityLinear_1_L(intersect(fixgain, find(constellation=='GPS')))),1) ;
NoDataValuesMod(1,7)=round(100*length(intersect(offsets,find(isnan(reflectivityLinear_1_L)>0 & constellation=='GPS')))/length(reflectivityLinear_1_L(intersect(offsets, find(constellation=='GPS')))),1) ;

NoDataValuesMod(3,1)=round(100*length(intersect(pitch20,find(isnan(reflectivityLinear_1_L)>0 & constellation=='Galileo')))/length(reflectivityLinear_1_L(intersect(pitch20, find(constellation=='Galileo')))),1) ;
NoDataValuesMod(3,2)=round(100*length(intersect(pitch00,find(isnan(reflectivityLinear_1_L)>0 & constellation=='Galileo')))/length(reflectivityLinear_1_L(intersect(pitch00, find(constellation=='Galileo')))),1) ;
NoDataValuesMod(3,3)=round(100*length(intersect(pitch40,find(isnan(reflectivityLinear_1_L)>0 & constellation=='Galileo')))/length(reflectivityLinear_1_L(intersect(pitch40, find(constellation=='Galileo')))),1) ;
NoDataValuesMod(3,4)=round(100*length(intersect(tc1msec,find(isnan(reflectivityLinear_1_L)>0 & constellation=='Galileo')))/length(reflectivityLinear_1_L(intersect(tc1msec, find(constellation=='Galileo')))),1) ;
NoDataValuesMod(3,5)=round(100*length(intersect(linesp,find(isnan(reflectivityLinear_1_L)>0 & constellation=='Galileo')))/length(reflectivityLinear_1_L(intersect(linesp, find(constellation=='Galileo')))),1) ;
NoDataValuesMod(3,6)=round(100*length(intersect(fixgain,find(isnan(reflectivityLinear_1_L)>0 & constellation=='Galileo')))/length(reflectivityLinear_1_L(intersect(fixgain, find(constellation=='Galileo')))),1) ;
NoDataValuesMod(3,7)=round(100*length(intersect(offsets,find(isnan(reflectivityLinear_1_L)>0 & constellation=='Galileo')))/length(reflectivityLinear_1_L(intersect(offsets, find(constellation=='Galileo')))),1) ;

NoDataValuesMod(2,1)=round(100*length(intersect(pitch20,find(isnan(reflectivityLinear_1_R)>0 & constellation=='GPS')))/length(reflectivityLinear_1_R(intersect(pitch20, find(constellation=='GPS')))),1) ;
NoDataValuesMod(2,2)=round(100*length(intersect(pitch00,find(isnan(reflectivityLinear_1_R)>0 & constellation=='GPS')))/length(reflectivityLinear_1_R(intersect(pitch00, find(constellation=='GPS')))),1) ;
NoDataValuesMod(2,3)=round(100*length(intersect(pitch40,find(isnan(reflectivityLinear_1_R)>0 & constellation=='GPS')))/length(reflectivityLinear_1_R(intersect(pitch40, find(constellation=='GPS')))),1) ;
NoDataValuesMod(2,4)=round(100*length(intersect(tc1msec,find(isnan(reflectivityLinear_1_R)>0 & constellation=='GPS')))/length(reflectivityLinear_1_R(intersect(tc1msec, find(constellation=='GPS')))),1) ;
NoDataValuesMod(2,5)=round(100*length(intersect(linesp,find(isnan(reflectivityLinear_1_R)>0 & constellation=='GPS')))/length(reflectivityLinear_1_R(intersect(linesp, find(constellation=='GPS')))),1) ;
NoDataValuesMod(2,6)=round(100*length(intersect(fixgain,find(isnan(reflectivityLinear_1_R)>0 & constellation=='GPS')))/length(reflectivityLinear_1_R(intersect(fixgain, find(constellation=='GPS')))),1) ;
NoDataValuesMod(2,7)=round(100*length(intersect(offsets,find(isnan(reflectivityLinear_1_R)>0 & constellation=='GPS')))/length(reflectivityLinear_1_R(intersect(offsets, find(constellation=='GPS')))),1) ;

NoDataValuesMod(4,1)=round(100*length(intersect(pitch20,find(isnan(reflectivityLinear_1_R)>0 & constellation=='Galileo')))/length(reflectivityLinear_1_R(intersect(pitch20, find(constellation=='Galileo')))),1) ;
NoDataValuesMod(4,2)=round(100*length(intersect(pitch00,find(isnan(reflectivityLinear_1_R)>0 & constellation=='Galileo')))/length(reflectivityLinear_1_R(intersect(pitch00, find(constellation=='Galileo')))),1) ;
NoDataValuesMod(4,3)=round(100*length(intersect(pitch40,find(isnan(reflectivityLinear_1_R)>0 & constellation=='Galileo')))/length(reflectivityLinear_1_R(intersect(pitch40, find(constellation=='Galileo')))),1) ;
NoDataValuesMod(4,4)=round(100*length(intersect(tc1msec,find(isnan(reflectivityLinear_1_R)>0 & constellation=='Galileo')))/length(reflectivityLinear_1_R(intersect(tc1msec, find(constellation=='Galileo')))),1) ;
NoDataValuesMod(4,5)=round(100*length(intersect(linesp,find(isnan(reflectivityLinear_1_R)>0 & constellation=='Galileo')))/length(reflectivityLinear_1_R(intersect(linesp, find(constellation=='Galileo')))),1) ;
NoDataValuesMod(4,6)=round(100*length(intersect(fixgain,find(isnan(reflectivityLinear_1_R)>0 & constellation=='Galileo')))/length(reflectivityLinear_1_R(intersect(fixgain, find(constellation=='Galileo')))),1) ;
NoDataValuesMod(4,7)=round(100*length(intersect(offsets,find(isnan(reflectivityLinear_1_R)>0 & constellation=='Galileo')))/length(reflectivityLinear_1_R(intersect(offsets, find(constellation=='Galileo')))),1) ;
%
NoDataValuesMod(5,1)=round(100*length(intersect(pitch20,find(isnan(reflectivityLinear_5_L)>0 & constellation=='GPS')))/length(reflectivityLinear_5_L(intersect(pitch20, find(constellation=='GPS')))),1) ;
NoDataValuesMod(5,2)=round(100*length(intersect(pitch00,find(isnan(reflectivityLinear_5_L)>0 & constellation=='GPS')))/length(reflectivityLinear_5_L(intersect(pitch00, find(constellation=='GPS')))),1) ;
NoDataValuesMod(5,3)=round(100*length(intersect(pitch40,find(isnan(reflectivityLinear_5_L)>0 & constellation=='GPS')))/length(reflectivityLinear_5_L(intersect(pitch40, find(constellation=='GPS')))),1) ;
NoDataValuesMod(5,4)=round(100*length(intersect(tc1msec,find(isnan(reflectivityLinear_5_L)>0 & constellation=='GPS')))/length(reflectivityLinear_5_L(intersect(tc1msec, find(constellation=='GPS')))),1) ;
NoDataValuesMod(5,5)=round(100*length(intersect(linesp,find(isnan(reflectivityLinear_5_L)>0 & constellation=='GPS')))/length(reflectivityLinear_5_L(intersect(linesp, find(constellation=='GPS')))),1) ;
NoDataValuesMod(5,6)=round(100*length(intersect(fixgain,find(isnan(reflectivityLinear_5_L)>0 & constellation=='GPS')))/length(reflectivityLinear_5_L(intersect(fixgain, find(constellation=='GPS')))),1) ;
NoDataValuesMod(5,7)=round(100*length(intersect(offsets,find(isnan(reflectivityLinear_5_L)>0 & constellation=='GPS')))/length(reflectivityLinear_5_L(intersect(offsets, find(constellation=='GPS')))),1) ;

NoDataValuesMod(7,1)=round(100*length(intersect(pitch20,find(isnan(reflectivityLinear_5_L)>0 & constellation=='Galileo')))/length(reflectivityLinear_5_L(intersect(pitch20, find(constellation=='Galileo')))),1) ;
NoDataValuesMod(7,2)=round(100*length(intersect(pitch00,find(isnan(reflectivityLinear_5_L)>0 & constellation=='Galileo')))/length(reflectivityLinear_5_L(intersect(pitch00, find(constellation=='Galileo')))),1) ;
NoDataValuesMod(7,3)=round(100*length(intersect(pitch40,find(isnan(reflectivityLinear_5_L)>0 & constellation=='Galileo')))/length(reflectivityLinear_5_L(intersect(pitch40, find(constellation=='Galileo')))),1) ;
NoDataValuesMod(7,4)=round(100*length(intersect(tc1msec,find(isnan(reflectivityLinear_5_L)>0 & constellation=='Galileo')))/length(reflectivityLinear_5_L(intersect(tc1msec, find(constellation=='Galileo')))),1) ;
NoDataValuesMod(7,5)=round(100*length(intersect(linesp,find(isnan(reflectivityLinear_5_L)>0 & constellation=='Galileo')))/length(reflectivityLinear_5_L(intersect(linesp, find(constellation=='Galileo')))),1) ;
NoDataValuesMod(7,6)=round(100*length(intersect(fixgain,find(isnan(reflectivityLinear_5_L)>0 & constellation=='Galileo')))/length(reflectivityLinear_5_L(intersect(fixgain, find(constellation=='Galileo')))),1) ;
NoDataValuesMod(7,7)=round(100*length(intersect(offsets,find(isnan(reflectivityLinear_5_L)>0 & constellation=='Galileo')))/length(reflectivityLinear_5_L(intersect(offsets, find(constellation=='Galileo')))),1) ;

NoDataValuesMod(6,1)=round(100*length(intersect(pitch20,find(isnan(reflectivityLinear_5_R)>0 & constellation=='GPS')))/length(reflectivityLinear_5_R(intersect(pitch20, find(constellation=='GPS')))),1) ;
NoDataValuesMod(6,2)=round(100*length(intersect(pitch00,find(isnan(reflectivityLinear_5_R)>0 & constellation=='GPS')))/length(reflectivityLinear_5_R(intersect(pitch00, find(constellation=='GPS')))),1) ;
NoDataValuesMod(6,3)=round(100*length(intersect(pitch40,find(isnan(reflectivityLinear_5_R)>0 & constellation=='GPS')))/length(reflectivityLinear_5_R(intersect(pitch40, find(constellation=='GPS')))),1) ;
NoDataValuesMod(6,4)=round(100*length(intersect(tc1msec,find(isnan(reflectivityLinear_5_R)>0 & constellation=='GPS')))/length(reflectivityLinear_5_R(intersect(tc1msec, find(constellation=='GPS')))),1) ;
NoDataValuesMod(6,5)=round(100*length(intersect(linesp,find(isnan(reflectivityLinear_5_R)>0 & constellation=='GPS')))/length(reflectivityLinear_5_R(intersect(linesp, find(constellation=='GPS')))),1) ;
NoDataValuesMod(6,6)=round(100*length(intersect(fixgain,find(isnan(reflectivityLinear_5_R)>0 & constellation=='GPS')))/length(reflectivityLinear_5_R(intersect(fixgain, find(constellation=='GPS')))),1) ;
NoDataValuesMod(6,7)=round(100*length(intersect(offsets,find(isnan(reflectivityLinear_5_R)>0 & constellation=='GPS')))/length(reflectivityLinear_5_R(intersect(offsets, find(constellation=='GPS')))),1) ;

NoDataValuesMod(8,1)=round(100*length(intersect(pitch20,find(isnan(reflectivityLinear_5_R)>0 & constellation=='Galileo')))/length(reflectivityLinear_5_R(intersect(pitch20, find(constellation=='Galileo')))),1) ;
NoDataValuesMod(8,2)=round(100*length(intersect(pitch00,find(isnan(reflectivityLinear_5_R)>0 & constellation=='Galileo')))/length(reflectivityLinear_5_R(intersect(pitch00, find(constellation=='Galileo')))),1) ;
NoDataValuesMod(8,3)=round(100*length(intersect(pitch40,find(isnan(reflectivityLinear_5_R)>0 & constellation=='Galileo')))/length(reflectivityLinear_5_R(intersect(pitch40, find(constellation=='Galileo')))),1) ;
NoDataValuesMod(8,4)=round(100*length(intersect(tc1msec,find(isnan(reflectivityLinear_5_R)>0 & constellation=='Galileo')))/length(reflectivityLinear_5_R(intersect(tc1msec, find(constellation=='Galileo')))),1) ;
NoDataValuesMod(8,5)=round(100*length(intersect(linesp,find(isnan(reflectivityLinear_5_R)>0 & constellation=='Galileo')))/length(reflectivityLinear_5_R(intersect(linesp, find(constellation=='Galileo')))),1) ;
NoDataValuesMod(8,6)=round(100*length(intersect(fixgain,find(isnan(reflectivityLinear_5_R)>0 & constellation=='Galileo')))/length(reflectivityLinear_5_R(intersect(fixgain, find(constellation=='Galileo')))),1) ;
NoDataValuesMod(8,7)=round(100*length(intersect(offsets,find(isnan(reflectivityLinear_5_R)>0 & constellation=='Galileo')))/length(reflectivityLinear_5_R(intersect(offsets, find(constellation=='Galileo')))),1) ;

NoDataValuesMod(1,8)=round(100*length((find(isnan(reflectivityLinear_1_L)>0 & constellation=='GPS')))/length(reflectivityLinear_1_L((find(constellation=='GPS')))),1) ;
NoDataValuesMod(2,8)=round(100*length((find(isnan(reflectivityLinear_1_R)>0 & constellation=='GPS')))/length(reflectivityLinear_1_R((find(constellation=='GPS')))),1) ;
NoDataValuesMod(3,8)=round(100*length((find(isnan(reflectivityLinear_1_L)>0 & constellation=='Galileo')))/length(reflectivityLinear_1_L((find(constellation=='Galileo')))),1) ;
NoDataValuesMod(4,8)=round(100*length((find(isnan(reflectivityLinear_1_R)>0 & constellation=='Galileo')))/length(reflectivityLinear_1_R((find(constellation=='Galileo')))),1) ;
NoDataValuesMod(5,8)=round(100*length((find(isnan(reflectivityLinear_5_L)>0 & constellation=='GPS')))/length(reflectivityLinear_5_L((find(constellation=='GPS')))),1) ;
NoDataValuesMod(6,8)=round(100*length((find(isnan(reflectivityLinear_5_R)>0 & constellation=='GPS')))/length(reflectivityLinear_5_R((find(constellation=='GPS')))),1) ;
NoDataValuesMod(7,8)=round(100*length((find(isnan(reflectivityLinear_5_L)>0 & constellation=='Galileo')))/length(reflectivityLinear_5_L((find(constellation=='Galileo')))),1) ;
NoDataValuesMod(8,8)=round(100*length((find(isnan(reflectivityLinear_5_R)>0 & constellation=='Galileo')))/length(reflectivityLinear_5_R((find(constellation=='Galileo')))),1) ;

Channel={'L1 Left';'L1 Right';'E1 Left';'E1 Right';'L5 Left';'L5 Right';'E5 Left';'E5 Right'; 'Mean channels'};
tutti=round(mean(NoDataValuesMod, 1),1) ;
Nominal=NoDataValuesMod(:,1) ; Nominal=[Nominal; tutti(1)] ; 
ONEmsec=NoDataValuesMod(:,2) ; ONEmsec=[ONEmsec; tutti(2)] ;
Pitch0=NoDataValuesMod(:,3) ; Pitch0=[Pitch0; tutti(3)] ;
Pitch40=NoDataValuesMod(:,4) ; Pitch40=[Pitch40; tutti(4)] ;
Linespacing=NoDataValuesMod(:,5) ; Linespacing=[Linespacing; tutti(5)] ;
Fixedgain=NoDataValuesMod(:,6) ; Fixedgain=[Fixedgain; tutti(6)] ;
Offsets=NoDataValuesMod(:,7) ; Offsets=[Offsets; tutti(7)] ;
AllModes=NoDataValuesMod(:,8) ; AllModes=[AllModes; tutti(8)] ;
TmissingMode = table(Channel,Nominal,ONEmsec,Pitch0,Pitch40,Linespacing,Fixedgain,Offsets,AllModes ) ;
TmissingMode.Properties.Description = '      Percentage of missed channels for different modes'; 
disp(TmissingMode.Properties.Description) ; disp(TmissingMode) ;

a=1


end