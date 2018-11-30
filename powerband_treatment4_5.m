% Perform for treatment 4 media 1 - 10

% change the media name, and the participant number 

participant = 2;


for k = 1:10 
    start = [];
    ending = [];
    idx_s = [];
    idx_e = [];
    EEG_media = [];
    
    formatSpec = 'LS%d.jpeg';
    number = k;
    str = sprintf(formatSpec,number);
    
    n_table{4,k} = T(strcmp(T.MediaName,str),:);
    start = table2array(n_table{4,k}(1,12));
    ending = table2array(n_table{4,k}(end,12));

    % find the corresponding EEG index 
    idx_s = find(M(:,9) >= start, 1);
    idx_e = find(M(:,9) >= ending, 1); 

    % extract the EEG data for this media 
    % this is the EEG data for the first media LT system-paced version
    EEG_media = M(idx_s:idx_e,:);

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
   
        Summary_final((participant-1)*40+30+k,2*i+3) = array2table(alpha);
        Summary_final((participant-1)*40+30+k,2*i+4) = array2table(theta);
     end

 
end


formatname = 'EEGbyTreatmentMedia_p%d';
str3 = sprintf(formatname,participant);
save(str3, 'n_table');
save('BandPowerSummary','Summary_final');
clearvars
