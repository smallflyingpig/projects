function img_texture = get_texture(img);
% It gets the magnitute and the direction of the texture of the image,
% using the Gabor Wavelet
% Input:
%       img: input image
% Output: 
% img_texture: magnitude and direction of the texture
% img_texture(row, col, 1): texture magnitude of pixel at (row, col)
% img_texture(row, col, 2): texture direction of pixel at (row, col)
% img_texture(row, col, 3): if the pixel has a main direction

if (nargin ~= 1)        % Check correct number of arguments
    error('Please use the correct number of input arguments!')
end
    
img_size = size(img);
gaborArray = gaborFilterBank(5,180,img_size(1)/7.5,img_size(2)/7.5);
[featureVector gaborResult] = gaborFeatures(img,gaborArray,2,2);

img_texture = zeros(img_size(1),img_size(2),3);
gaborSize = size(gaborResult);

%get the mean of all scales
img_texture_scale_add = zeros(img_size(1), img_size(2), gaborSize(2));
for v = 1:gaborSize(2)
    for u = 1:gaborSize(1)
        img_texture_scale_add(:,:,v) = img_texture_scale_add(:,:,v)+gaborResult{u,v};
    end
end
img_texture_scale_add = img_texture_scale_add./gaborSize(1);

add_size = size(img_texture_scale_add);
%find max of all directions
[img_texture(:,:,1)  img_texture(:,:,2)] = max(img_texture_scale_add,[],3);
img_texture(:,:,1) = abs(img_texture(:,:,1));
img_texture(:,:,2) = img_texture(:,:,2);

%get the pixel which has main direction
add_sort = abs(sort(img_texture_scale_add, 3, 'descend'));
conf = 1 - mean(add_sort(:,:,5:15),3)./add_sort(:,:,1);
img_texture(:,:,3) = (conf > (min(conf(:))+0.35*(max(conf(:))-min(conf(:)))));

% delete the margin
img_texture(1:int32(img_size(1)/20),:,3) = 0;
img_texture(:,1:int32(img_size(2)/20),3) = 0;
img_texture(int32(img_size(1)*19/20):img_size(1),:,3) = 0;
img_texture(:,int32(img_size(2)*19/20):img_size(2),3) = 0;

% figure;
% img_texture1 = img_texture(:,:,1);
% imshow(img_texture1.*img_texture(:,:,3)./max(img_texture1(:)));

% %using hough transformation to delete some pixel
% hough_space = hough_transform(img_texture(:,:,3));
% 
% filter_kernel = fspecial('gaussian',[5 5],1);
% 
% hough_gaussian = conv2(hough_space, filter_kernel, 'same');
% 
% hough_gaussian_max = (imregionalmax(hough_gaussian,26) .* hough_gaussian);
% 
% 
% 
% [max_1 max_1_idx] = max(hough_gaussian_max(:)); 
% [max_1_idx_theta max_1_idx_r] = ind2sub(size(hough_gaussian_max), max_1_idx);
% hough_gaussian_max(max_1_idx_theta, max_1_idx_r) = 0;
% 
% max_2 = 0; 
% max_2_idx = 0; 
% max_2_idx_r = 0; 
% max_2_idx_theta = 0; 
% while true
%     [max_2 max_2_idx] = max(hough_gaussian_max(:)); 
%     [max_2_idx_theta max_2_idx_r] = ind2sub(size(hough_gaussian_max), max_2_idx); 
%     diff = max_2_idx_theta - max_1_idx_theta;
%     if diff<-90
%         diff = diff + 180;
%     else if diff <0
%             diff = -diff;
%         else if diff >90
%                 diff = 180 - diff;
%             end
%         end
%     end
%     
%     if diff < 20
%         hough_gaussian_max(max_2_idx_theta, max_2_idx_r) = 0; 
%         continue;
%     else
%         break;
%     end
% end
% %delete the voter above the cross point
% det_0 = det([sind(max_1_idx_theta) -cosd(max_1_idx_theta); sind(max_2_idx_theta) -cosd(max_2_idx_theta)]);
% det_x = det([max_1_idx_r-max(img_size(:)/2) cosd(max_1_idx_theta); max_2_idx_r-max(img_size(:)/2) -cosd(max_2_idx_theta)]);
% det_y = det([sind(max_1_idx_theta) max_1_idx_r-max(img_size(:)/2); sind(max_2_idx_theta) max_2_idx_r-max(img_size(:)/2)]);
% 
% cross_point = [ det_x/det_0+img_size(2)/2 det_y/det_0+img_size(1)/2];
% 
% if cross_point(2)<img_size(2)
% %    img_texture(:,int16(cross_point(2)+img_size(2)):img_size(2), 3) =
% %    0;%doesn't work
% end
%show the result
% figure;
% img_texture1 = img_texture(:,:,1);
% imshow(img_texture1.*img_texture(:,:,3)./max(img_texture1(:)));

end