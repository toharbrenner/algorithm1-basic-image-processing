clear all

global number_image
global path_images
global path_labeles
global images
global opt_tresholds
global min_tresholds
global max_tresholds
global accuracy_rgb
global final_accurecy

number_image; %number of the image
opt_tresholds = []; % list of the opt tresholds 
min_tresholds = [];
max_tresholds = [];
accuracy_rgb = [];
final_accurecy = {};

path_images = "D:\final_project\Data\5.5.2021\ground_truth\images\";
path_labeles = "D:\final_project\Data\5.5.2021\ground_truth\ground_true_skeleton\";
images = ["10_14.png","10_37.png","13_11.png","13_14.png","16_28.png","16_30.png","16_33.png","10_39.png","10_40.png","10_41.png","13_30.png","13_33.png","13_37.png","16_2.png","16_23.png"];

main();

function main()
    global number_image
    global path_images
    global images

    for i = 1:floor(0.7*15)
        number_image = i;
        ground_truth_mask = init_ground_truth(i);
        [row, column] = find(ground_truth_mask > 0);
        rgb_image = imread(path_images+images(i));
        pixels_value = impixel(rgb_image, column, row);
        rgb_mask = bild_rgb_mask(pixels_value, row, column);
        sub_images = {};
        sub_images = rectangle_sub_images(sub_images, rgb_mask);
        for j = 1:size(sub_images,2)
            sub_image = sub_images(1,j);
            sub_image_entropy = calc_entropy(sub_image);
        end
        for k = 1:size(sub_image_entropy,2)
            calc_pixels_values(k, sub_image_entropy(1,k));
        end
    end
    adaptive_thresholding();
    find_best_treshold();
end

function rgb_mask = bild_rgb_mask(pixels_value, row, column)
    rgb_mask = zeros(480,640,3);
    for i = 1:size(pixels_value,1)
        red_value = pixels_value(i,1);
        green_value = pixels_value(i,2);
        blue_value = pixels_value(i,3);
        rgb_mask(row(i),column(i),1) = red_value;
        rgb_mask(row(i),column(i),2) = green_value;
        rgb_mask(row(i),column(i),3) = blue_value;
    end
end

function sub_images = rectangle_sub_images(sub_images, rgb_image) 
    % split the image to sub-images
    const_std = 15;
    min_size = 3072; % 1% of size image
    red_std = std2(rgb_image(:,:,1));
    green_std = std2(rgb_image(:,:,2));
    blue_std = std2(rgb_image(:,:,3));
    rows = size(rgb_image,1);
    columns = size(rgb_image,2);
    
    if (red_std < const_std && green_std < const_std && blue_std < const_std) || (rows*columns < min_size)
        sub_images{end+1} = rgb_image;
    else
        col1 = 1;
        col2 = floor(columns/2);
        col3 = col2 + 1;
        row1 = 1;
        row2 = floor(rows/2);
        row3 = row2 + 1;
        upper_left = imcrop(rgb_image, [col1 row1 col2 row2]);
        sub_images = rectangle_sub_images(sub_images, upper_left);
        upper_right = imcrop(rgb_image, [col3 row1 columns - col2 row2]);
        sub_images = rectangle_sub_images(sub_images, upper_right);
        lower_left = imcrop(rgb_image, [col1 row3 col2 row2]);
        sub_images = rectangle_sub_images(sub_images, lower_left);
        lower_right = imcrop(rgb_image, [col3 row3 columns - col2 rows - row2]);
        sub_images = rectangle_sub_images(sub_images, lower_right);
    end
end

function sub_image_entropy = calc_entropy(sub_images)
    % breaks each rectangle to several amorphous sub-images according to an entropy measure
    sub_image = sub_images{1,1};
    sub_image_entropy = {};
    entropy_const = 5;
    window_size = 10;
    for i = 1:window_size:size(sub_image,1)
        for j = 1:window_size:size(sub_image,2)
            if i > window_size && j < (size(sub_image,2) - window_size)
                if i + window_size > size(sub_image,1)
                    current_im = sub_image(i:size(sub_image,1), j:j+window_size,:);
                else
                    current_im = sub_image(i-window_size:i+window_size, j:j+window_size,:);
                end
                current_im_entropy = calc_entropy_current_im(current_im);
                if current_im_entropy < entropy_const
                    sub_image_entropy{end+1} = current_im;
                end
            end
            if j > window_size && i < (size(sub_image,1) - window_size)
                if j + window_size > size(sub_image,2)
                    current_im = sub_image(i:i+window_size, j:size(sub_image,2),:);
                else 
                    current_im = sub_image(i:i+window_size, j-window_size:j+window_size,:);
                end
                current_im_entropy = calc_entropy_current_im(current_im);
                if current_im_entropy < entropy_const
                    sub_image_entropy{end+1} = current_im;
                end
            end
            if i > (size(sub_image,1) - window_size) && j > (size(sub_image,2) - window_size)
                current_im = sub_image(i:size(sub_image,1), j:size(sub_image,2),:);
                current_im_entropy = calc_entropy_current_im(current_im);
                if current_im_entropy < entropy_const
                    sub_image_entropy{end+1} = current_im;
                end
            end   
        end
    end
end

function current_im_entropy = calc_entropy_current_im(current_im)
    sum_pixels_temp = sum(sum(current_im(:,:,:)));
    sum_pixels = sum(sum_pixels_temp(:));
    weight_red = rdivide(sum(sum(current_im(:,:,1))),sum_pixels);
    weight_green = rdivide(sum(sum(current_im(:,:,2))),sum_pixels);
    weight_blue = rdivide(sum(sum(current_im(:,:,3))),sum_pixels);
    entropy_red = entropy(current_im(:,:,1));
    entropy_green = entropy(current_im(:,:,2));
    entropy_blue = entropy(current_im(:,:,3));
    current_im_entropy = weight_red*entropy_red + weight_green*entropy_green + weight_blue*entropy_blue;
end

function pixels_value = find_values(channel)
    [row, column] = find(channel > 0);
    pixels_value = impixel(channel, column, row);
    pixels_value = pixels_value(:,1);
end

function calc_pixels_values(k, sub_image)
    sub_image = sub_image{1,1};
    % RGB color space
    red_channel = sub_image(:,:,1);
    values_red = find_values(red_channel);
    green_channel = sub_image(:,:,2);
    values_green = find_values(green_channel);
    blue_channel = sub_image(:,:,3);
    values_blue = find_values(blue_channel);
    find_tresholds(k, values_red, values_green, values_blue);
end

function find_tresholds(k, values_red, values_green, values_blue)
    global opt_tresholds % values_red, values_green, values_blue

    value = check_Null(min(values_red));
    opt_tresholds(k,1) = value;
    value = check_Null(min(values_green));
    opt_tresholds(k,2) = value;
    value = check_Null(min(values_blue));
    opt_tresholds(k,3) = value;
    value = check_Null(max(values_red));
    opt_tresholds(k,4) = value;
    value = check_Null(max(values_green));
    opt_tresholds(k,5) = value;
    value = check_Null(max(values_blue));
    opt_tresholds(k,6) = value;
end

function value = check_Null(number)
    if isempty(number)
        value = 0;
    else
        value = number;
    end
end

function find_min_max()
    % values_red, values_green, values_blue
    global opt_tresholds
    global min_tresholds
    global max_tresholds
    
    for i = 1:3
         min_tresholds(i) = min(opt_tresholds(:,i));
         max_tresholds(i) = max(opt_tresholds(:,(i+3)));
    end
end

function adaptive_thresholding()
    find_min_max();
    create_predict_mask(); 
end

function find_best_treshold()
    global accuracy_rgb
    
    row_start = 1;
    test_images = 5;
    row_finish = size(accuracy_rgb,1)/test_images;
    for i = 1:test_images
        find_best_each_image(i,row_start,row_finish)
        row_start = row_finish;
        row_finish = row_finish + size(accuracy_rgb,1)/test_images;
    end
end

function find_best_each_image(i,row_start,row_finish)
    global accuracy_rgb
    global final_accurecy
    
    % score,precision,recall
    temp = accuracy_rgb(row_start:row_finish,:);
    [best_score, index_score] = max(temp(:,8));
    [best_precision, index_precision] = max(temp(:,9));
    [best_recall, index_recall] = max(temp(:,10));
    final_accurecy{i}(1,:) = temp(index_score,:);
    final_accurecy{i}(2,:) = temp(index_precision,:);
    final_accurecy{i}(3,:) = temp(index_recall,:);
end

function create_predict_mask()
    global number_image
    global min_tresholds
    global max_tresholds
    global path_images
    global images
    
    column = 1;
    step_size = 10;
    iter = 0;
    for i = round(15-(0.3*15)):15
        number_image = i;
        image = imread(path_images+images(i));
        for first = min_tresholds(column):step_size:max_tresholds(column)
            for second = min_tresholds(column+1):step_size:max_tresholds(column+1)
                for third = min_tresholds(column+2):step_size:max_tresholds(column+2)
                    % define thresholds for channel 1
                    first_min = first;
                    first_max = max_tresholds(column);
                    % define thresholds for channel 2
                    second_min = second;
                    second_max = max_tresholds(column+1);
                    % define thresholds for channel 3
                    third_min = third;
                    third_max = max_tresholds(column+2);
                    % create mask based on chosen thresholds
                    masked_image = (image(:,:,1) >= first_min ) & (image(:,:,1) <= first_max) & ...
                        (image(:,:,2) >= second_min ) & (image(:,:,2) <= second_max) & ...
                        (image(:,:,3) >= third_min ) & (image(:,:,3) <= third_max);
                    tresholds = [first_min, first_max, second_min, second_max, third_min, third_max];
                    iter = iter + 1;
                    masked_image = ~masked_image;
                    calc_accuracy(i, iter, tresholds, masked_image);
                end
            end
        end
    end
end

function calc_accuracy(i, iter, tresholds, masked_image)
    global number_image    
    global accuracy_rgb

    truth_mask = init_ground_truth(i);
    %image_move_stem = remove_object(masked_image);
    [score,precision,recall] = bfscore(logical(masked_image),logical(truth_mask));
    info_image = [number_image,tresholds,score,precision,recall];
    accuracy_rgb(iter,:) = info_image;
end

function masked_image = remove_object(masked_image)
    biggest_area = bwpropfilt(masked_image, 'Area', [100, 1771]);
    masked_image = minus(masked_image,biggest_area);
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