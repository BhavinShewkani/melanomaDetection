function varargout = MAIN(varargin)
% MAIN MATLAB code for MAIN.fig
%      MAIN, by itself, creates a new MAIN or raises the existing
%      singleton*.
%
%      H = MAIN returns the handle to a new MAIN or the handle to
%      the existing singleton*.
%
%      MAIN('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MAIN.M with the given input arguments.
%
%      MAIN('Property','Value',...) creates a new MAIN or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before MAIN_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to MAIN_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help MAIN

% Last Modified by GUIDE v2.5 30-Nov-2018 15:15:50

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @MAIN_OpeningFcn, ...
                   'gui_OutputFcn',  @MAIN_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before MAIN is made visible.
function MAIN_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to MAIN (see VARARGIN)

% Choose default command line output for MAIN
handles.output = hObject;
cla(handles.axes1)
cla(handles.axes2)
cla(handles.axes3)

warning('off')
set(handles.text1,'String','')
set(handles.text2,'String','')
set(handles.pushbutton1,'Enable','On');
set(handles.pushbutton2,'Enable','Off');
set(handles.pushbutton3,'Enable','Off');
set(handles.pushbutton4,'Enable','Off');
set(handles.pushbutton5,'Enable','On');
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes MAIN wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = MAIN_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
cla(handles.axes1)
cla(handles.axes2)
cla(handles.axes3)

set(handles.text1,'String','')
set(handles.text2,'String','')

set(handles.pushbutton1,'Enable','Off');
set(handles.pushbutton2,'Enable','Off');
set(handles.pushbutton3,'Enable','Off');
set(handles.pushbutton4,'Enable','Off');
set(handles.pushbutton5,'Enable','Off');

%read Image
[fname, pthname] = uigetfile('.\Database\*.jpg', 'Select The Test Image');
imgpath = strcat(pthname,fname);
copyfile(imgpath,'temp/temp.jpg')
%read image
image = imread(imgpath);
%downsize the image
image_ds = imresize(image,[512,512]);
axes(handles.axes1);
imshow(image_ds,[])
handles.image_ds = image_ds;

set(handles.pushbutton1,'Enable','Off');
set(handles.pushbutton2,'Enable','On');
set(handles.pushbutton3,'Enable','Off');
set(handles.pushbutton4,'Enable','Off');
set(handles.pushbutton5,'Enable','On');
guidata(hObject, handles);

% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.pushbutton1,'Enable','Off');
set(handles.pushbutton2,'Enable','Off');
set(handles.pushbutton3,'Enable','Off');
set(handles.pushbutton4,'Enable','Off');
set(handles.pushbutton5,'Enable','Off');
image_ds = handles.image_ds;
%Median Filtering and CLAHE histogram equalization
image_filt = zeros(size(image_ds),'like',image_ds);

for kk = 1:3
    image_filt(:,:,kk) = medfilt2(image_ds(:,:,kk));
end

%convert the image to lab image
image_Lab = rgb2lab(image_filt);

%Get L,a,b components of the image
L_comp = double(image_Lab(:,:,1));
a_comp = double(image_Lab(:,:,2));
b_comp = double(image_Lab(:,:,3));

%Create Lab gray image for segmentation
Lab_gray = mat2gray(a_comp + b_comp - L_comp);
    
handles.Lab_gray = Lab_gray;
axes(handles.axes2);
imshow(Lab_gray,[])

set(handles.pushbutton1,'Enable','Off');
set(handles.pushbutton2,'Enable','Off');
set(handles.pushbutton3,'Enable','On');
set(handles.pushbutton4,'Enable','Off');
set(handles.pushbutton5,'Enable','On');

guidata(hObject, handles);
% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.pushbutton1,'Enable','Off');
set(handles.pushbutton2,'Enable','Off');
set(handles.pushbutton3,'Enable','Off');
set(handles.pushbutton4,'Enable','Off');
set(handles.pushbutton5,'Enable','Off');
%Kmenas
Lab_gray = handles.Lab_gray;
image_ds = handles.image_ds;
%Perform k means clustering
Labels = kmeans(Lab_gray(:),3,'start',[0.9041;0.1673;0.8702],'Maxiter',10);

%set tumor labes as '1' and other labels as '0', reshape it to image
%and performe morphological processing
Tumor_array = Labels == 3;

Tumor = reshape(Tumor_array,size(Lab_gray));

Tumor = imclearborder(Tumor);

Tumor = bwareafilt(Tumor,1);

Tumor = imfill(Tumor,'holes');

%track tumor boundries using active contours
Tumor = activecontour(image_ds,Tumor,10);

%multiply mask with color image
maskedRGB = bsxfun(@times,image_ds,cast(Tumor,'like',image_ds));

maskedRGB = imresize(maskedRGB, [227 227]);
axes(handles.axes3)
imshow(maskedRGB,[])

set(handles.pushbutton1,'Enable','Off');
set(handles.pushbutton2,'Enable','Off');
set(handles.pushbutton3,'Enable','off');
set(handles.pushbutton4,'Enable','On');
set(handles.pushbutton5,'Enable','On');
guidata(hObject, handles);

% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
f = waitbar(0,'Processing');
%load svm model
load('mdl.mat')
rng('default')
set(handles.pushbutton1,'Enable','Off');
set(handles.pushbutton2,'Enable','Off');
set(handles.pushbutton3,'Enable','Off');
set(handles.pushbutton4,'Enable','Off');
set(handles.pushbutton5,'Enable','Off');
%load alexnet
convnet = alexnet;
%Load the test image
Temp = imageDatastore('.\temp');
Temp.ReadFcn = @readFunction;
%Inset the image into CNN and axtract features from fc7 layer
featureLayer = 'fc7';
Features = activations(convnet, Temp, featureLayer);
%Convert the image from 4D to 1D
temp = Features(1,1,1:4096,1);
feat = temp(:)';
%Predict the type of tumor from those features
[predictedLabels,score] = predict(classifier, feat);
set(handles.text1,'String',char(predictedLabels))
f = waitbar(1,f,'Done');
pause(1)
close(f)
set(handles.pushbutton1,'Enable','On');
set(handles.pushbutton2,'Enable','Off');
set(handles.pushbutton3,'Enable','Off');
set(handles.pushbutton4,'Enable','Off');
set(handles.pushbutton5,'Enable','On');
guidata(hObject,handles)

% --- Executes on button press in pushbutton5.
function pushbutton5_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.pushbutton1,'Enable','Off');
set(handles.pushbutton2,'Enable','Off');
set(handles.pushbutton3,'Enable','Off');
set(handles.pushbutton4,'Enable','Off');
set(handles.pushbutton5,'Enable','Off');
warning('off')
f = waitbar(0,'Importing Network');
pause(0.5)
%load alexnet 
rng(1)
convnet = alexnet;  
layers = convnet.Layers; % Take a look at the layers
%%
f = waitbar(0.25,f,'Importing Dataset');
pause(0.5)
%load the image from training set and testing set using image datastore and
%extract the tumor using the readFunction.m file 
%% Load database and split into training and validation set
rootFolder = 'Database';
imds = imageDatastore(rootFolder, ...
    'IncludeSubfolders',true, ...
    'LabelSource','foldernames');

imds.ReadFcn = @readFunction; %see readFunction.m file

[trainingSet,testSet] = splitEachLabel(imds,0.8,'randomize');

trainingSet_Size = size(trainingSet.Files,1);
testSet_Size = size(testSet.Files,1);
%%
f = waitbar(0.50,f,'Inserting Images Into Neural Network');
pause(0.5)
feat = [];
%Extract features for all the training set images from layer fc7
feat = [];
featureLayer = 'fc7';
trainingFeatures = activations(convnet, trainingSet, featureLayer);

%Convert 4D features to 2D
for ii = 1:trainingSet_Size
    temp = trainingFeatures(1,1,1:4096,ii);
    feat = [feat;temp(:)'];
end

%Extract features for all the testing set images from layer fc7
testFeatures = activations(convnet, testSet, featureLayer);
%Convert the 4D features to 2D
feat2 = [];
for ii = 1:testSet_Size
    temp = testFeatures(1,1,1:4096,ii);
    feat2 = [feat2;temp(:)'];
end


f = waitbar(0.70,f,'Running Classifier');
pause(0.5)
%%Train SVM classifier from train features
rng(1)
t = templateSVM('BoxConstraint',[],'KernelFunction','polynomial',...
    'KernelScale','auto','polynomialorder',2);
classifier = fitcecoc(feat,trainingSet.Labels,'Learner',t);

%Save that model
save mdl.mat classifier

%%Predict test features
[predictedLabels,score] = predict(classifier, feat2);
%Create an array target where 'Benign' in testSet.Labels represent 1 and
%malignant represent 0 do the same for output labels
targets = (testSet.Labels == 'Benign')';
output = (predictedLabels == 'Benign')';
%Calculate accuracy
f = waitbar(1,f,'Done!');
pause(0.5)
close(f)
CP = classperf(targets, output);
Accuracy = CP.CorrectRate.*100;
Accuracy = sprintf('%0.2f%%',Accuracy);

figure,
plotconfusion(testSet.Labels, predictedLabels);

set(handles.text2,'String',Accuracy)
set(handles.pushbutton1,'Enable','On');
set(handles.pushbutton2,'Enable','Off');
set(handles.pushbutton3,'Enable','Off');
set(handles.pushbutton4,'Enable','Off');
set(handles.pushbutton5,'Enable','On');
guidata(hObject,handles)
