clear all

global number_image
global path_images
global path_labeles
global path_tresh
global images
global final_accurecy

number_image; %number of the image
final_accurecy = [];

path_images = "D:\final_project\Data\5.5.2021\ground_truth\images\";
path_labeles = "D:\final_project\Data\5.5.2021\ground_truth\ground_true_skeleton\";
path_tresh = "D:\final_project\Data\5.5.2021\ground_truth\‏‏adaptive_treshold_skeleton\image";
images = ["10_14.png","10_37.png","13_11.png","13_14.png","16_28.png","16_30.png","16_33.png","10_39.png","10_40.png","10_41.png","13_30.png","13_33.png","13_37.png","16_2.png","16_23.png"];

create_mask_by_algorithm();

function calc_accuracy(i, masked_image)
    global path_tresh
    global images
    global number_image    
    global final_accurecy

    truth_mask = init_ground_truth(number_image);
    image_move_stem = remove_object(masked_image);
    imwrite(image_move_stem,path_tresh+images(i));
    [score,precision,recall] = bfscore(logical(image_move_stem),logical(truth_mask));
    info_image = [number_image,score,precision,recall];
    final_accurecy(number_image,:) = info_image;
end

function masked_image = remove_object(masked_image)
    biggest_area = bwpropfilt(masked_image, 'Area', [500, 1771]);
    masked_image = minus(masked_image,biggest_area);
end

function create_mask_by_algorithm()
    global number_image
    global path_images
    global images
    
    for i = 1:15
        number_image = i;
        image = imread(path_images+images(i));
        % define thresholds for channel 1
        first_min = 35;
        first_max = 200;
        % define thresholds for channel 2
        second_min = 49;
        second_max = 191;
        % define thresholds for channel 3
        third_min = 6;
        third_max = 210;
        % create mask based on chosen thresholds
        masked_image = (image(:,:,1) >= first_min ) & (image(:,:,1) <= first_max) & ...
            (image(:,:,2) >= second_min ) & (image(:,:,2) <= second_max) & ...
            (image(:,:,3) >= third_min ) & (image(:,:,3) <= third_max);
        masked_image = ~masked_image;
        calc_accuracy(i, masked_image);
    end
end

function binary_mask = init_ground_truth(i)
    global path_labeles
    global images
%     
%     % set the location of the image and pixel label data.
%     imDir = fullfile(path_images,images(i));
%     pxDir = fullfile(path_labeles,label_images(i));
%     % create an image datastore.
%     imds = imageDatastore(imDir);
%     % create a pixel label datastore.
%     classNames = "brenches";
%     pixelLabelID = 1;
%     pxds = pixelLabelDatastore(pxDir,classNames,pixelLabelID);
%     % read the image and pixel label data. read(pxds) returns a categorical matrix, C. 
%     % the element C(i,j) in the matrix is the categorical label assigned to the pixel at the location l(i,j).
%     I = read(imds);
%     C = read(pxds);
%     % overlay and display the pixel label data onto the image.
%     B = labeloverlay(I,C{1});
%     mask = imsubtract(uint8(I),uint8(B));
%     binary_mask = create_mask(mask);
      binary_mask = imread(path_labeles+images(i));
end