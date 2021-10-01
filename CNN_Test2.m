clc; clear all; close all;
rng(1)
%% Load Pre-Trained CNN
convnet = alexnet;  
layers = convnet.Layers; % Take a look at the layers

%% Load database and split into training and validation set
rootFolder = 'Database';
imds = imageDatastore(rootFolder, ...
    'IncludeSubfolders',true, ...
    'LabelSource','foldernames');

imds.ReadFcn = @readFunction; %see readFunction.m file

[trainingSet,testSet] = splitEachLabel(imds,0.8);

trainingSet_Size = size(trainingSet.Files,1);
testSet_Size = size(testSet.Files,1);

%% Activate fc7 layer of alexnet and extract image features from it
feat = [];
featureLayer = 'fc7';
trainingFeatures = activations(convnet, trainingSet, featureLayer);

%Convert 4D features to 2D
for ii = 1:trainingSet_Size
    temp = trainingFeatures(1,1,1:4096,ii);
    feat = [feat;temp(:)'];
end

%% Train SVM classifier from train features

t = templateSVM('BoxConstraint',[],'KernelFunction','polynomial',...
    'KernelScale','auto','polynomialorder',2);
classifier = fitcecoc(feat,trainingSet.Labels,'Learner',t);

%% Extract test features
testFeatures = activations(convnet, testSet, featureLayer);
feat2 = [];
for ii = 1:testSet_Size
    temp = testFeatures(1,1,1:4096,ii);
    feat2 = [feat2;temp(:)'];
end

%% Predict test features
[predictedLabels,score] = predict(classifier, feat2);

%%Plot confusion matrix
targets = (testSet.Labels == 'Benign')';
output = (predictedLabels == 'Benign')';
plotconfusion(testSet.Labels, predictedLabels);
save('mdl.mat','classifier')