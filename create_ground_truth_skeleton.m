global path_brenches
global path_stems
global path_ans
global images

path_brenches = "D:\final_project\Data\5.5.2021\ground_truth\brench_ground_truth\";
path_stems = "D:\final_project\Data\5.5.2021\ground_truth\stems_ground_truth\";
path_ans = "D:\final_project\Data\5.5.2021\ground_truth\ground_true_skeleton\";
images = ["10_14.png","10_37.png","13_11.png","13_14.png","16_28.png","16_30.png","16_33.png","10_39.png","10_40.png","10_41.png","13_30.png","13_33.png","13_37.png","16_2.png","16_23.png"];

for i = 1:15
    masked_branch = imread(path_brenches+images(i));
    masked_stem = imread(path_stems+images(i));
    masked_ans = masked_branch + masked_stem;
    imwrite(masked_ans,path_ans+images(i));
end