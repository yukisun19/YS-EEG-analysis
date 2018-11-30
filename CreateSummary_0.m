
%Generate the table with information of treatment and participant
% with guiding questions - 1     without - 0 
% System-paced - 1               self-paced - 0
% participant number 

% two treatment coded 
Summary = [1 1 0 0 1 1 0 0 0 0 1 1 0 0 1 1;0 1 0 1 1 0 1 0 0 1 0 1 1 0 1 0];

Summary = transpose(Summary);

Summary = repelem(Summary,10,1);

Summary = repmat(Summary,8,1);

% media number

Media = [1 2 3 4];
Media = transpose(Media);
Media = repelem(Media,10,1);
Media = repmat(Media,32,1);

Summary(:,3) = Media;
Summary(:,4)= transpose(repmat(1:10,1,128));

% participants number 
Summary(:,5) = transpose(repelem(1:32,40));
Summary(:,6:15) = zeros(1280,10);

colNames = {'GuidingQuestions','Pacing','LearningMaterial','MediaNumber','Participant','alphaAF3','thetaAF3',...
    'alphaT7','thetaT7','alphaPz','thetaPz','alphaT8','thetaT8','alphaAF4','thetaAF4'};
Power_final = array2table(Summary,'VariableNames',colNames);
CogLoad = array2table(Summary,'VariableNames',colNames);




% create a table for average cognitive load 
Summary1 = [1 1 0 0 1 1 0 0 0 0 1 1 0 0 1 1;0 1 0 1 1 0 1 0 0 1 0 1 1 0 1 0];
Summary1 = transpose(Summary1);
Summary1 = repmat(Summary1,8,1);

Media1 = [1 2 3 4];
Media1 = transpose(Media1);
Media1 = repmat(Media1,32,1);

Summary1(:,3) = Media1;
Summary1(:,4) = transpose(repelem(1:32,4));
Summary1(:,5:14) = zeros(128,10);


colNames1 = {'GuidingQuestions','Pacing','LearningMaterial','Participant','alphaAF3','thetaAF3',...
    'alphaT7','thetaT7','alphaPz','thetaPz','alphaT8','thetaT8','alphaAF4','thetaAF4'};
AvgCogLoad = array2table(Summary1,'VariableNames',colNames1);



