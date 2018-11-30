%load ETbyPhase.mat
%load EEGbyPhase.mat
%load BandPowerSummary.mat
%load CogLoadSlide.mat
%load CogLoadLM.mat 

% EEG

% clean all matrix

m = [];
t = [];
b = [];
k = [];
n = [];


% define the participant #

participant = 2;

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







