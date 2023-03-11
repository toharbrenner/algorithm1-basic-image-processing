global path_images
global path_tresh
global final_accurecy
global images

path_images = "D:\final_project\Data\5.5.2021\ground_truth\images\";
path_tresh = "D:\final_project\Data\5.5.2021\ground_truth\‏‏adaptive_treshold_skeleton\image";
images = ["10_14.png","10_37.png","13_11.png","13_14.png","16_28.png","16_30.png","16_33.png","10_39.png","10_40.png","10_41.png","13_30.png","13_33.png","13_37.png","16_2.png","16_23.png"];
final_accurecy = [];
main();

function main()
    global path_tresh
    global images
    
    for i = 5
        image = imread(path_tresh+images(i));
        cc = bwconncomp(image); 
        prop = regionprops(cc,'Area','Orientation'); 
        idx1 = find([prop.Area] > 70 & [prop.Orientation] < 90); 
        BW2 = ismember(labelmatrix(cc),idx1);
        imshow(BW2);
        [H,T,R,image1] = canny_edge(BW2,i);
        hough_transform(H,T,R,image1);
    end
end

function [H,T,R,BWs] = canny_edge(image,i)
    global path_images
    global images
    
    basic_image = imread(path_images+images(i));
    basic_image = rgb2gray(basic_image);
    [~,threshold] = edge(basic_image,'sobel');
    fudgeFactor = 0.5;
    BWs = edge(image,'sobel',threshold * fudgeFactor);
    imshow(BWs);
    BWs = edge(image,'log');
    imshow(BWs);
    [H,T,R] = hough(BWs,'RhoResolution',0.9,'Theta',-45:0.1:45);
end

function hough_transform(H,T,R,image)

    subplot(2,1,1);
    imshow(image);
    title('image');
    subplot(2,1,2);
    imshow(imadjust(rescale(H)),'XData',T,'YData',R,...
          'InitialMagnification','fit');
    title('Hough transform of gantrycrane.png');
    xlabel('\theta'), ylabel('\rho');
    axis on, axis normal, hold on;
    colormap(gca,hot);
    P  = houghpeaks(H,9,'threshold',ceil(0.7*max(H(:))));
    x = T(P(:,2)); y = R(P(:,1));
    plot(x,y,'s','color','white');
    lines = houghlines(image,T,R,P,'FillGap',10,'MinLength',10);
    figure, imshow(image), hold on
    max_len = 0;
    for k = 1:length(lines)
       xy = [lines(k).point1; lines(k).point2];
       plot(xy(:,1),xy(:,2),'LineWidth',2,'Color','green');
       % Plot beginnings and ends of lines
       plot(xy(1,1),xy(1,2),'x','LineWidth',2,'Color','yellow');
       plot(xy(2,1),xy(2,2),'x','LineWidth',2,'Color','red');
       % Determine the endpoints of the longest line segment
       len = norm(lines(k).point1 - lines(k).point2);
       if ( len > max_len)
          max_len = len;
          xy_long = xy;
       end
    end
    plot(xy_long(:,1),xy_long(:,2),'LineWidth',2,'Color','cyan');
    title('Hough transform');
end
