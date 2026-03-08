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
%
load(H_file)
H_specularPointLat=specularPointLat ;
H_specularPointLon=specularPointLon ;
H_reflectivityLinear_5_L=reflectivityLinear_5_L ;
H_reflectivityLinear_5_R=reflectivityLinear_5_R ;
H_reflectivityLinear_5_L=reflectivityLinear_5_L ;
H_reflectivityLinear_5_R=reflectivityLinear_5_R ; 
H_SNR_5_L=SNR_5_L ;
H_SNR_5_R=SNR_5_R ;
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
caxis([-45, 0])
title('HydroGNSS unfiltered Reflectivity L1/E1 Left [dB]')

figure
t=tiledlayout(2,2) ; 
nexttile ; 
histogram(10*log10(H_reflectivityLinear_5_L(intersect(in, find(H_constellation=='GPS')))))
hold on, histogram(10*log10(H_reflectivityLinear_5_R(intersect(in, find(H_constellation=='GPS')))))
xlim([-50,5])
legend('Left', 'Right')
title('Overland unfiltered reflectivity L1')
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
title('Overland unfiltered reflectivity E1')
xlabel('Reflectivity [dB]')
P11=length(find(10*log10(H_reflectivityLinear_5_L(intersect(in, find(H_constellation=='Galileo')))) > 40)) ;
P12=length(find(10*log10(H_reflectivityLinear_5_R(intersect(in, find(H_constellation=='Galileo')))) > 40)) ;
str11 = {[char(string(P11)) ' SP''s >40 dB'],...
         [char(string(P12)) ' SP''s >40 dB']} ;
text(-15,3000,str11,'FontSize',6)

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
histogram(10*log10(H_reflectivityLinear_5_L(intersect(in, find(H_constellation=='GPS')))))
hold on, histogram(10*log10(H_reflectivityLinear_5_L(intersect(in, find(H_constellation=='Galileo')))))
xlim([-50,0])
legend('L1 Left', 'E1 Left')
title('Over land L1 and E1 Left comparison')
xlabel('Reflectivity [dB]')
P11=length(find(isnan(H_reflectivityLinear_5_L(intersect(in, find(H_constellation=='GPS'))))>0));
P11=round(100*P11/length(H_reflectivityLinear_5_L(intersect(in, find(H_constellation=='GPS')))),1) ; 
P12=length(find(isnan(H_reflectivityLinear_5_L(intersect(in, find(H_constellation=='Galileo'))))>0)) ;
P12=round(100*P12/length(H_reflectivityLinear_5_L(intersect(in, find(H_constellation=='Galileo')))),1) ;
str11 = {['Missed ' char(string(P11)) '% GPS SP''s'],...
         ['Missed ' char(string(P12)) '% Galileo SP''s']} ;
text(-15,5000,str11,'FontSize',8)

nexttile
histogram(10*log10(H_reflectivityLinear_5_R(intersect(in, find(H_constellation=='GPS')))))
hold on, histogram(10*log10(H_reflectivityLinear_5_R(intersect(in, find(H_constellation=='Galileo')))))
xlim([-50,0])
legend('L1 Right', 'E1 Right')
title('Over land L1 and E1 Right  comparison')
xlabel('Reflectivity [dB]')
P11=length(find(isnan(H_reflectivityLinear_5_R(intersect(in, find(H_constellation=='GPS'))))>0)); 
P11=round(100*P11/length(H_reflectivityLinear_5_R(intersect(in, find(H_constellation=='GPS')))),1) ; 
P12=length(find(isnan(H_reflectivityLinear_5_R(intersect(in, find(H_constellation=='Galileo'))))>0)) ;
P12=round(100*P12/length(H_reflectivityLinear_5_R(intersect(in, find(H_constellation=='Galileo')))),1) ;
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
P12=length(find(isnan(H_reflectivityLinear_5_L(intersect(in, find(H_constellation=='Galileo'))))>0))
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
P12=length(find(isnan(H_reflectivityLinear_5_R(intersect(in, find(H_constellation=='Galileo'))))>0))
P12=round(100*P12/length(H_reflectivityLinear_5_R(intersect(in, find(H_constellation=='Galileo')))),1) ;
str11 = {['Missed ' char(string(P11)) '% GPS SP''s'],...
         ['Missed ' char(string(P12)) '% Galileo SP''s']} ;
text(-20,5000,str11,'FontSize',8)


figure
ttt=tiledlayout(2,2) ; 
nexttile
histogram(H_SNR_5_L(intersect(in, find(H_constellation=='GPS'))))
hold on, histogram(H_SNR_5_R(intersect(in, find(H_constellation=='GPS'))))
xlim([-15,25])
legend('Left', 'Right')
title('Over land SNR L1')
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
title('Over land SNR E1')
xlabel('SNR [dB]')
P11=round(100*length(find(H_SNR_5_L(intersect(in, find(H_constellation=='Galileo')))>0.5))/length(H_SNR_5_L(intersect(in, find(H_constellation=='Galileo'))))) ; 
P12=round(100*length(find(H_SNR_5_L(intersect(in, find(H_constellation=='Galileo')))>2))/length(H_SNR_5_L(intersect(in, find(H_constellation=='Galileo'))))) ; 
P21=round(100*length(find(H_SNR_5_R(intersect(in, find(H_constellation=='Galileo')))>0.5))/length(H_SNR_5_R(intersect(in, find(H_constellation=='Galileo'))))) ; 
P22=round(100*length(find(H_SNR_5_R(intersect(in, find(H_constellation=='Galileo')))>2))/length(H_SNR_5_R(intersect(in, find(H_constellation=='Galileo'))))) ; 
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

figure
tttt=tiledlayout(2,2) ; 
nexttile
scatter(rxAntennaGain_1_L, 10*log10(reflectivityLinear_1_L), 2, SNR_1_L)
xlim([-5,12]) ; ylim([-50,5])
xlabel('rxAntennaGain L1/E1 Left [dB]')
ylabel('Reflectivity L1/E1 Left [dB]')
title('Reflectivitty L1/E1 Left vs ant. gain vs SNR')
c=colorbar ; c.Label.String = 'SNR [dB]';
nexttile
scatter(rxAntennaGain_5_L, 10*log10(reflectivityLinear_5_L), 2, SNR_5_L)
xlim([-5,12]) ; ylim([-50,5])
xlabel('rxAntennaGain L5/E5 Left [dB]')
ylabel('Reflectivity L5/E5 Left [dB]')
title('Reflectivitty L5/E5 Left vs ant. gain vs SNR')
c=colorbar ; c.Label.String = 'SNR [dB]';
nexttile
scatter(rxAntennaGain_1_R, 10*log10(reflectivityLinear_1_R), 2, SNR_1_R)
xlim([-5,12]) ; ylim([-50,5])
xlabel('rxAntennaGain L1/E1 Right[dB]')
ylabel('Reflectivity L1/E1 Right [dB]')
title('Reflectivitty L1/E1 Right vs ant. gain vs SNR')
c=colorbar; c.Label.String = 'SNR [dB]';
nexttile
scatter(rxAntennaGain_5_R, 10*log10(reflectivityLinear_5_R), 2, SNR_5_R)
xlim([-5,12]) ; ylim([-50,5])
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

end