image = imread('D:\final_project\images_for_analysis\color_image10.png');
imshow(image);
h = imrect;
position = wait(h);

% RGB color space
croppedImage_rgb = imcrop(image, position);
R_matrix = croppedImage_rgb(:,:,1);
R = R_matrix(:);
G_matrix = croppedImage_rgb(:,:,2);
G = G_matrix(:);
B_matrix = croppedImage_rgb(:,:,3);
B = B_matrix(:);
% figure; % plot
% subplot(3, 1, 1);
% histogram(R);
% grid on;
% title('Histogram of R channel');
% xlabel('R value');
% ylabel('Pixel Count');
% subplot(3, 1, 2);
% histogram(G);
% grid on;
% title('Histogram of G channel');
% xlabel('G value');
% ylabel('Pixel Count');
% subplot(3, 1, 3);
% histogram(B);
% grid on;
% title('Histogram of B channel');
% xlabel('B value');
% ylabel('Pixel Count');

% HSV color space
hsv_image = rgb2hsv(image);
croppedImage_hsv = imcrop(hsv_image, position);
H_matrix = croppedImage_hsv(:,:,1);
H = H_matrix(:);
S_matrix = croppedImage_hsv(:,:,2);
S = S_matrix(:);
V_matrix = croppedImage_hsv(:,:,3);
V = V_matrix(:);
% figure; % plot
% histogram(croppedImage_hsv);
% xlabel('HSV value');
% ylabel('Pixel Count');
% title('Histogram of HSV');

% L*a*b color space
cform = makecform('srgb2lab');
lab_image = applycform(image,cform);
croppedImage_lab = imcrop(lab_image, position);
L_matrix = croppedImage_lab(:,:,1);
L = L_matrix(:);
a_matrix = croppedImage_lab(:,:,2);
a = a_matrix(:);
b_matrix = croppedImage_lab(:,:,3);
b = b_matrix(:);
% figure; % plot
% subplot(3, 1, 1);
% histogram(L);
% grid on;
% title('Histogram of L channel');
% xlabel('L value');
% ylabel('Pixel Count');
% subplot(3, 1, 2);
% histogram(a);
% grid on;
% title('Histogram of A channel');
% xlabel('A value');
% ylabel('Pixel Count');
% subplot(3, 1, 3);
% histogram(b);
% grid on;
% title('Histogram of B channel');
% xlabel('B value');
% ylabel('Pixel Count');

color_space_matrix = [R,G,B,H,S,V,L,a,b];