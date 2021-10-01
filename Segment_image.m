clc;clear all;close all;

%Collect all the image in the image dataset
imgdst = imageDatastore('.\Database\','IncludeSubfolders',true,...
    'LabelSource','FolderNames');

%% loop through all the image
counter = 0;

while(hasdata(imgdst))
    
    %read image
    image = read(imgdst);
    
    %downsize the image
    image_ds = imresize(image,[512,512]);
    
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
    maskedRGB = bsxfun(@times,image_ds,cast(Tumor,'like',image_ds));

    maskedRGB = imresize(maskedRGB, [227 227]);
    
    imshow(maskedRGB)
end