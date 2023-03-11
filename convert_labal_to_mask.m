global path_images
global path_labeles
global images
global label_images

path_images = "D:\final_project\Data\5.5.2021\ground_truth\";
path_labeles = "D:\matlab\bin\PixelLabelData_Stem\";
images = ["10_14.png","10_37.png","10_39.png","10_40.png","10_41.png","13_11.png","13_14.png","13_30.png","13_33.png","13_37.png","16_2.png","16_23.png","16_28.png","16_30.png","16_33.png"];
label_images = ["Label_1.png","Label_2.png","Label_3.png","Label_4.png","Label_5.png","Label_6.png","Label_7.png","Label_8.png","Label_9.png","Label_10.png","Label_11.png","Label_12.png","Label_13.png","Label_14.png","Label_15.png"];

for i = 1:15
    binary_mask = init_ground_truth(i);
    imwrite(binary_mask,path_images+images(i));
end

function binary_mask = create_mask(mask)
    rows = 480;
    colums = 640;
    red_channel = mask(:, :, 1) > 0;
    green_channel = mask(:, :, 2) > 0;
    blue_channel = mask(:, :, 3) > 0;
    binary_mask = zeros(rows,colums);
    for j = 1:rows*colums
        if red_channel(j) > 0 || green_channel(j)  > 0 || blue_channel(j) > 0
            binary_mask(j) = 1;
        end
    end
end

function binary_mask = init_ground_truth(i)
    global path_images
    global path_labeles
    global images
    global label_images
    
    % set the location of the image and pixel label data.
    imDir = fullfile(path_images,images(i));
    pxDir = fullfile(path_labeles,label_images(i));
    % create an image datastore.
    imds = imageDatastore(imDir);
    % create a pixel label datastore.
    classNames = "brenches";
    pixelLabelID = 1;
    pxds = pixelLabelDatastore(pxDir,classNames,pixelLabelID);
    % read the image and pixel label data. read(pxds) returns a categorical matrix, C. 
    % the element C(i,j) in the matrix is the categorical label assigned to the pixel at the location l(i,j).
    I = read(imds);
    C = read(pxds);
    % overlay and display the pixel label data onto the image.
    B = labeloverlay(I,C{1});
    mask = imsubtract(uint8(I),uint8(B));
    binary_mask = create_mask(mask);
end