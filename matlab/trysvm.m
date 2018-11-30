
% Load training features and labels
data = csvread('classification_phase.csv');
x = data(:,1:15);
y = data(:,16);

% Libsvm options
% -s 0 : classification
% -t 2 : RBF kernel
% -g : gamma in the RBF kernel


% linear model
% model = svmtrain(y, x, '-s 0 -t 0 -c 100');
% non-linear model
model = svmtrain(y, x, '-s 0 -t 2 -g 1');

% Display training accuracy
[predicted_label, accuracy, decision_values] = svmpredict(y, x, model);

% Plot training data and decision boundary
% plotboundary(y, x, model);
