load ETbyPhase.mat
load EEGbyPhase.mat
load BandPowerSummary.mat
load CogLoadSlide.mat
load CogLoadLM.mat 
load BasePower.mat

% EEG

% clean all matrix

m = [];
t = [];
b = [];
k = [];
n = [];


% define the participant #

participant = 39;

filename1 = 'p%d.csv';
str1 = sprintf(filename1,participant);


%read the EEG data file in%
m = csvread(str1, 1, 0);
%clean all the unuseful data in EEG file%
M = m(:,[3:7 11:12 14:16]);


% extract the baseline recording
eyeopen_start = find(M(:,7)==2 & M(:,6)==1);
eyeopen_end = find(M(:,7)==2 & M(:,6)==2);
baseline = M(eyeopen_start:eyeopen_end, 1:5);


%create new timestamp in milliseconds and delete orginal seperate timestamps%
M(:,11) = M(:,8)*1000 + M(:,9);
M = M(:,[1:6 10:11]);
%find the index of the beginning marker%
k = find(M(:,6)==11,1);
%check if the time stamp seems resonalble usually between 120 ~ 180s%
begintime = M(k,8)/1000;
%pull the record out for that row%
eeg_start = M(k,8);
%set the start time to zero to match eye-tracking data%
%create a new column with start time being zero%
M(:,9) = M(:,8)- eeg_start;

% create a table with variable name for future reference
colNames = {'AF3','T7','Pz','T8','AF4','MARKER','IntTimeStamp','TS_ms','NewTimestamp_ms'};
M_final = array2table(M,'VariableNames',colNames);



%Eye-tracking

filename2 = 'p%d-learning.csv';
str2 = sprintf(filename2,participant);

%read the ET data file in and clean some data %
t = readtable(str2);
T= t(:,2:12);
%name the columns for later refrence%
%colNames = {'MediaName','Timestamp_ms','LocalTimeStamp','ETTimeStamp','FixInd','SacInd',...
    %'GEtype','GEduration','SacAmp','PupLeft','PupRight'};
%t1_final = array2table(t1_1,'VariableNames',colNames);


%find the table of the beginning media of the marked media%
n = T(strcmp(T.MediaName,'LT1....wmv'),:);
% for group 1&3: LT1.jpeg
% group 2&4: LT1....wmv

%find the beginning time and set to zero 
%create new timestamp in table
et_start = table2array(n(1,2));
%set the start time to zero to match eeg data%
%create a new column with start time being zero%
T.NewTimestamp = T.RecordingTimestamp - et_start;



% treatment 1 
cell1 = [];

for k = 1:10 
    n =[];
    start = [];
    ending = [];
    idx_s = [];
    idx_e = [];
    EEG_media = [];
    
    formatSpec = 'LT%d....wmv';
    
    % for group 1&3: LT%d.jpeg
    % group 2&4: LT%d....wmv
    
    str = sprintf(formatSpec,k);
    
    % save baseline 
    EEGphase{participant,1} = baseline; 
    
    % calculate band power for baseline 
    for i = 1:5
        y = baseline(:,i);
        pxx = [];
        f = [];
        alpha1 =[];
        theta1 = [];
        
        [pxx, f] = pwelch(y,hann(length(y)),0,length(y),128);
        alpha1 = bandpower(pxx,f,[8 13],'psd');
        theta1 = bandpower(pxx,f,[4 8],'psd');
        
        BasePower(participant,2*i-1) = alpha1;
        BasePower(participant,2*i) = theta1;
    end 
    
    %find the new starting and ending time
    n_table{1,k} = T(strcmp(T.MediaName,str),:);
    start = table2array(n_table{1,k}(1,12));
    ending = table2array(n_table{1,k}(end,12));
    ETphase{participant,1} = n_table;

    % find the corresponding EEG index 
    idx_s = find(M(:,9) >= start, 1);
    idx_e = find(M(:,9) >= ending, 1); 

    % extract the EEG data for this media 
    % this is the EEG data for the first media LT system-paced version
    EEG_media = M(idx_s:idx_e,:);
    cell1{1,k} = EEG_media;
    EEGphase{participant,2} = cell1;
    

    for i = 1:5
        x = EEG_media(:,i);
        Fs = 128;
    
        pxx = [];
        f = [];
        alpha =[];
        theta = [];
        % perform stft transformation thourhg welch periodogram
        [pxx, f] = pwelch(x,hann(length(x)),0,length(x),Fs);
        

        % plot the frequency domain data for the media
        %plot(freq, 10*log10(psdx))
        %grid on
        %title('Welch Periodogram using SFFT')
        %xlabel('Frequency(Hz)')
        %ylabel('Power/Frequency(dB/Hz)')

        % calculate the band power of alpha AF3
        alpha = bandpower(pxx,f,[8 13],'psd');
        % calculate the band power of theta
        theta = bandpower(pxx,f,[4 8],'psd');
   
        Power_final((participant-1)*40+k,2*i+4) = array2table(alpha);
        Power_final((participant-1)*40+k,2*i+5) = array2table(theta);
        
        bl_alpha = BasePower(participant,2*i-1);
        bl_theta = BasePower(participant,2*i);
        CogLoad((participant-1)*40+k,2*i+4) = array2table((bl_alpha-alpha)/bl_alpha);
        CogLoad((participant-1)*40+k,2*i+5) = array2table((bl_theta-theta)/bl_theta);
        
        
    end

end


for i = 1:10
    cogload = [];
    cogload = table2array(CogLoad(participant*40-39:participant*40-30,i+5));
    AvgCogLoad(participant*4-3,i+4) = array2table(mean(cogload));
end


save('BasePower','BasePower')


% treatment 2
cell2 = [];

for k = 1:10 
    n =[];
    start = [];
    ending = [];
    idx_s = [];
    idx_e = [];
    EEG_media = [];
    
    formatSpec = 'PP%d.jpeg';
    
    % for Group1&3:  PP%d....wmv
    % Group 2&4: PP%d.jpeg
    
    str = sprintf(formatSpec,k);
    
    n_table{2,k} = T(strcmp(T.MediaName,str),:);
    start = table2array(n_table{2,k}(1,12));
    ending = table2array(n_table{2,k}(end,12));
    ETphase{participant,2} = n_table;
    
    % find the corresponding EEG index 
    idx_s = find(M(:,9) >= start, 1);
    idx_e = find(M(:,9) >= ending, 1); 

    % extract the EEG data for this media 
    % this is the EEG data for the first media LT system-paced version
    EEG_media = M(idx_s:idx_e,:);
    cell2{1,k} = EEG_media;
    EEGphase{participant,3} = cell2;

    for i = 1:5
        x = EEG_media(:,i);
        Fs = 128;
    
        pxx = [];
        f = [];
        alpha =[];
        theta = [];
        % perform stft transformation thourhg welch periodogram
        [pxx, f] = pwelch(x,hann(length(x)),0,length(x),Fs);

        % plot the frequency domain data for the media
        %plot(freq, 10*log10(psdx))
        %grid on
        %title('Welch Periodogram using SFFT')
        %xlabel('Frequency(Hz)')
        %ylabel('Power/Frequency(dB/Hz)')

        % calculate the band power of alpha AF3
        alpha = bandpower(pxx,f,[8 13],'psd');
        % calculate the band power of theta
        theta = bandpower(pxx,f,[4 8],'psd');
   
        Power_final((participant-1)*40+10+k,2*i+4) = array2table(alpha);
        Power_final((participant-1)*40+10+k,2*i+5) = array2table(theta);
        
        bl_alpha = BasePower(participant,2*i-1);
        bl_theta = BasePower(participant,2*i);
        CogLoad((participant-1)*40+10+k,2*i+4) = array2table((bl_alpha-alpha)/bl_alpha);
        CogLoad((participant-1)*40+10+k,2*i+5) = array2table((bl_theta-theta)/bl_theta);
     end

 
end

for i = 1:10
    cogload = [];
    cogload = table2array(CogLoad(participant*40-29:participant*40-20,i+5));
    AvgCogLoad(participant*4-2,i+4) = array2table(mean(cogload));
end



% treatment 3
cell3 = [];

for k = 1:10 
    n =[];
    start = [];
    ending = [];
    idx_s = [];
    idx_e = [];
    EEG_media = [];
    
    formatSpec = 'TC%d....wmv';
    
    % for group 1&3: TC%d.jpeg
    % group 2&4: TC%d....wmv
    
    
    str = sprintf(formatSpec,k);
    
    n_table{3,k} = T(strcmp(T.MediaName,str),:);
    start = table2array(n_table{3,k}(1,12));
    ending = table2array(n_table{3,k}(end,12));
    ETphase{participant,3} = n_table;

    % find the corresponding EEG index 
    idx_s = find(M(:,9) >= start, 1);
    idx_e = find(M(:,9) >= ending, 1); 

    % extract the EEG data for this media 
    % this is the EEG data for the first media LT system-paced version
    EEG_media = M(idx_s:idx_e,:);
    cell3{1,k} = EEG_media;
    EEGphase{participant,4} = cell3;


    for i = 1:5
        x = EEG_media(:,i);
        Fs = 128;
    
        pxx = [];
        f = [];
        alpha =[];
        theta = [];
        % perform stft transformation thourhg welch periodogram
        [pxx, f] = pwelch(x,hann(length(x)),0,length(x),Fs);

        % plot the frequency domain data for the media
        %plot(freq, 10*log10(psdx))
        %grid on
        %title('Welch Periodogram using SFFT')
        %xlabel('Frequency(Hz)')
        %ylabel('Power/Frequency(dB/Hz)')

        % calculate the band power of alpha AF3
        alpha = bandpower(pxx,f,[8 13],'psd');
        % calculate the band power of theta
        theta = bandpower(pxx,f,[4 8],'psd');
        
        Power_final((participant-1)*40+20+k,2*i+4) = array2table(alpha);
        Power_final((participant-1)*40+20+k,2*i+5) = array2table(theta);
        
        bl_alpha = BasePower(participant,2*i-1);
        bl_theta = BasePower(participant,2*i);
        CogLoad((participant-1)*40+20+k,2*i+4) = array2table((bl_alpha-alpha)/bl_alpha);
        CogLoad((participant-1)*40+20+k,2*i+5) = array2table((bl_theta-theta)/bl_theta);
     end

 
end

for i = 1:10
    cogload = [];
    cogload = table2array(CogLoad(participant*40-19:participant*40-10,i+5));
    AvgCogLoad(participant*4-1,i+4) = array2table(mean(cogload));
end


% treatment 4
cell4 = [];

for k = 1:10 
    start = [];
    ending = [];
    idx_s = [];
    idx_e = [];
    EEG_media = [];
    
    formatSpec = 'LS%d.jpeg';
    
    % for Group1&3:  LS%d....wmv
    % Group 2&4: LS%d.jpeg
    
    str = sprintf(formatSpec,k);
    
    n_table{4,k} = T(strcmp(T.MediaName,str),:);
    start = table2array(n_table{4,k}(1,12));
    ending = table2array(n_table{4,k}(end,12));
    ETphase{participant,4} = n_table;

    % find the corresponding EEG index 
    idx_s = find(M(:,9) >= start, 1);
    idx_e = find(M(:,9) >= ending, 1); 

    % extract the EEG data for this media 
    % this is the EEG data for the first media LT system-paced version
    EEG_media = M(idx_s:idx_e,:);
    cell4{1,k} = EEG_media;
    EEGphase{participant,5} = cell4;

    for i = 1:5
        x = EEG_media(:,i);
        Fs = 128;
    
        pxx = [];
        f = [];
        alpha =[];
        theta = [];
        % perform stft transformation through welch periodogram
        [pxx, f] = pwelch(x,hann(length(x)),0,length(x),Fs);

        % plot the frequency domain data for the media
        %plot(freq, 10*log10(psdx))
        %grid on
        %title('Welch Periodogram using SFFT')
        %xlabel('Frequency(Hz)')
        %ylabel('Power/Frequency(dB/Hz)')

        % calculate the band power of alpha AF3
        alpha = bandpower(pxx,f,[8 13],'psd');
        % calculate the band power of theta
        theta = bandpower(pxx,f,[4 8],'psd');
        
        Power_final((participant-1)*40+30+k,2*i+4) = array2table(alpha);
        Power_final((participant-1)*40+30+k,2*i+5) = array2table(theta);
        
        bl_alpha = BasePower(participant,2*i-1);
        bl_theta = BasePower(participant,2*i);
        CogLoad((participant-1)*40+30+k,2*i+4) = array2table((bl_alpha-alpha)/bl_alpha);
        CogLoad((participant-1)*40+30+k,2*i+5) = array2table((bl_theta-theta)/bl_theta);
     end

 
end

for i = 1:10
    cogload = [];
    cogload = table2array(CogLoad(participant*40-9:participant*40,i+5));
    AvgCogLoad(participant*4,i+4) = array2table(mean(cogload));
end


save('ETbyPhase', 'ETphase');
save('EEGbyPhase', 'EEGphase');
save('BandPowerSummary','Power_final');
save('CogLoadSlide', 'CogLoad');
save('CogLoadLM','AvgCogLoad')
clearvars
