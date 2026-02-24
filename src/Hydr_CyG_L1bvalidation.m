function Hydr_CyG_L1bvalidation(configurationPath)
close all
clearvars -except  configurationPath

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
% H_file='D:\home on Dell NP (gordiani)\HydroGNSS_PhCDE\HydroGNSSCalVal\HydroGNSS_Extract\output\Extract10feb_26-02-15_11-33.mat' ;
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
H_reflectivityLinear_1_L=reflectivityLinear_1_L ;
H_reflectivityLinear_1_R=reflectivityLinear_1_R ; 
H_SNR_1_L=SNR_1_L ;
H_SNR_1_R=SNR_1_R ;
H_time=timeUTC ;  
H_constellation=constellation ; 
clearvars -except H_specularPointLat H_specularPointLon H_reflectivityLinear_1_L...
    H_reflectivityLinear_1_R  H_SNR_1_L H_SNR_1_R H_time H_file C_file...
    sizesave ThresholDist ThresholdTimeDelay SNRThr colocMode H_constellation
load(C_file)
C_specularPointLat=specularPointLat ;
C_specularPointLon=specularPointLon ;
C_reflectivityLinear_1_L=reflectivityLinear_L1_L ;
% C_reflectivityLinear_1_R=reflectivityLinear_1_R ; 
SNR_L1_L(find(SNR_L1_L==-9999))=NaN ; 
SNR_L1_L(find(SNR_L1_L<=0))=NaN ; 
C_SNR_1_L=10*log10(10.^(SNR_L1_L/10)-1) ;
% C_SNR_1_R=SNR_1_R ;
C_time=timeUTC ; 
clearvars -except C_specularPointLat C_specularPointLon C_reflectivityLinear_1_L...
    C_reflectivityLinear_1_R  C_SNR_1_L H_SNR_1_R H_time C_time H_specularPointLat...
    H_specularPointLon H_reflectivityLinear_1_L H_reflectivityLinear_1_R  H_SNR_1_L...
    H_SNR_1_R H_timeUTC H_file C_file sizesave ThresholDist ThresholdTimeDelay...
    SNRThr H_constellation colocMode
% H_time=datetime(H_timeUTC) ; 
% C_time=datetime(C_timeUTC) ;
H_geo=[H_specularPointLat, H_specularPointLon] ;
C_geo=[C_specularPointLat, C_specularPointLon] ;
clearvars H_specularPointLat H_specularPointLon C_specularPointLat C_specularPointLon
H_length=length(H_time) ;
C_length=length(C_time) ; 

load coastlines ;
in = inpolygon(H_geo(:,2), H_geo(:,1), coastlon, coastlat);
figure, geoscatter(H_geo(in,1),H_geo(in,2), 2, 10*log10(H_reflectivityLinear_1_L(in)), 'filled')
c=colorbar ; 
caxis([-35, 0])
title('HydroGNSS unfiltered Reflectivity L1/E1 Left [dB]')

figure, histogram(10*log10(H_reflectivityLinear_1_L(in)))
hold on, histogram(10*log10(H_reflectivityLinear_1_R(in)))
xlim([-45,100])
legend('Left', 'Right')
title('Over land unfiltered HydroGNSS reflectivity L1/E1')
xlabel('Reflectivity [dB]')

figure, histogram(10*log10(H_reflectivityLinear_1_L(intersect(find(in==1), find(H_constellation=='GPS')))))
hold on, histogram(10*log10(H_reflectivityLinear_1_R(intersect(find(in==1), find(H_constellation=='Galileo')))))
xlim([-45,15])
legend('L1 Left', 'E1 Left')
title('Over land L1 and E1 Left reflectivity comparison')
xlabel('Reflectivity [dB]')

figure, histogram(H_SNR_1_L(in))
hold on, histogram(H_SNR_1_R(in))
xlim([-15,25])
legend('Left', 'Right')
title('Over land unfiltered HydroGNSS SNR L1/E1')
xlabel('SNR [dB]')

switch colocMode
    case 'accurate'
%
[best_dist, H_good, C_best]=geotimeloc(H_time, H_geo(:,1), H_geo(:,2),...
    C_time, C_geo(:,1), C_geo(:,2), hours(ThresholdTimeDelay), ThresholDist) ;
%
figure, geoscatter((H_geo(:,1)), (H_geo(:,2)), '.')
hold on, geoscatter((C_geo(C_best,1)), (C_geo(C_best,2)), '.r')
title('HydroGNSS and colocated CyGNSS SP locations')
legend('HydroGNSS', 'CyGNSS')
% test of results
figure, histogram((H_time(H_good))-(C_time(C_best)))
title('Time delay between selected HydroGNSS and CyGNSS reflections') 
arclen=Mylldistkm(H_geo(H_good,:)', C_geo(C_best,:)') ;
for i=1:length(best_dist), distance(i)=arclen(i,i); end
figure, plot(distance, best_dist/1000, '.')
title('Comparison between recomputed distance and geotimeloc distance')
% 
nbins=50; 
figure, histogram(10*log10(H_reflectivityLinear_1_L(H_good)),nbins)
hold on, histogram(real(10*log10(C_reflectivityLinear_1_L(C_best))),nbins)
legend('HydroGNSS', 'CyGNSS')
title('Colocated L1 Left reflectivity from HydroGNSS and CyGNSS')
xlabel('Reflectivity [dB]')
%
figure, histogram(H_SNR_1_L(H_good),nbins)
hold on, histogram(C_SNR_1_L(C_best),nbins)
legend('HydroGNSS', 'CyGNSS')
title('Colocated L1 Left SNR from HydroGNSS and CyGNSS')
xlabel('SNR=(Pr-N)/N [dB]')
%
% SNRThr=0.5 ; 
H_SNR_1_L_match=H_SNR_1_L(H_good) ;
C_SNR_1_L_match=C_SNR_1_L(C_best) ;
goodSNR=find(H_SNR_1_L_match>SNRThr & C_SNR_1_L_match> SNRThr) ;
H_match_dB=10*log10(H_reflectivityLinear_1_L(H_good));
C_match_dB=10*log10(C_reflectivityLinear_1_L(C_best)) ; 
figure, scatter(real(C_match_dB), H_match_dB, '.r')
title('Comparison of CyGNSS and HydroGNSS colocated reflectivity')
xlabel('CyGNSS reflectivity [dB]') ; ylabel('HydroGNSS reflectivity [dB]') ; 
xlim([-45 15]); ylim([-45 15]); 
hold on, scatter(real(C_match_dB(goodSNR)), H_match_dB(goodSNR), 'ob', 'filled')
legend('All colocations' , ['SNR>' char(string(SNRThr))])

    case 'fast'

Idx=knnsearch(C_geo,H_geo) ; 
figure, geoscatter(H_geo(:,1), H_geo(:,2), '.') 
hold on, geoscatter(C_geo(Idx,1), C_geo(Idx,2), '.r')
C_geonear=C_geo(Idx,:) ; 
arclen=[]; for i=1:H_length, latlon1=H_geo(i,:) ; latlon2=C_geo(Idx(i),:) ; arclen=[arclen, Mylldistkm(latlon1', latlon2')] ; end
NearPoints = find(arclen <= ThresholDist/1000) ;
figure,geoscatter(H_geo(NearPoints,1), H_geo(NearPoints,2), '.r')
hold on,geoscatter(C_geo(Idx(NearPoints),1), C_geo(Idx(NearPoints),2), '.b')
hold on,geoscatter(C_geo(Idx(NearPoints(10)),1), C_geo(Idx(NearPoints(10)),2), '*g')
% figure, scatter(10*log10(H_reflectivityLinear_1_L(NearPoints)),real(10*log10(C_reflectivityLinear_1_L(Idx(NearPoints)))), '.')
% HC_timedelay=C_time(Idx(NearPoints))-H_time(NearPoints) ; 
% NearTimes=find(abs(hours(HC_timedelay))<=ThresholdTimeDelay) ; 
HC_timedelay=C_time(Idx)-H_time ; 
NearTimes=find(abs(hours(HC_timedelay))<=ThresholdTimeDelay) ; 
NearSpaceTime=intersect(NearTimes, NearPoints) ; 

nbins=50; 
figure, histogram(10*log10(H_reflectivityLinear_1_L(NearSpaceTime)),nbins)
hold on, histogram(real(10*log10(C_reflectivityLinear_1_L(Idx(NearSpaceTime)))),nbins)
legend('HydroGNSS', 'CyGNSS')
title('Colocated L1 Left reflectivity from HydroGNSS and CyGNSS')
xlabel('Reflectivity [dB]')
figure, histogram(H_SNR_1_L(NearSpaceTime),nbins)
hold on, histogram(C_SNR_1_L(Idx(NearSpaceTime)),nbins)
legend('HydroGNSS', 'CyGNSS')
title('Colocated L1 Left SNR from HydroGNSS and CyGNSS')
xlabel('SNR=(Pr-N)/N [dB]')

goodSNR=find(H_SNR_1_L>SNRThr & C_SNR_1_L(Idx)>SNRThr); 
figure, scatter(real(10*log10(C_reflectivityLinear_1_L(Idx(NearSpaceTime)))), 10*log10(H_reflectivityLinear_1_L(NearSpaceTime)), '.r')
hold on, scatter(real(10*log10(C_reflectivityLinear_1_L(Idx(intersect(goodSNR, NearSpaceTime))))), 10*log10(H_reflectivityLinear_1_L(intersect(goodSNR, NearSpaceTime))), 'ob', 'filled')
ylabel('HydroGNSS Reflectivity L1 Left [dB]')
xlabel('CyGNSS Reflectivity L1 Left [dB]')
title(['Comparison HydroGNSS vs CyGNSS Reflectivity [dB]. SNR>' char(string(SNRThr)) 'dB'])
xlim([-45 15]); ylim([-45 15]); 
legend('All colocations' , ['SNR>' char(string(SNRThr))])

end

end