function [vanish_point road_angle] = road_area_detection(img_texture, vanish_point, img_gray);
%
%main edge detection, update the vanishing point, localize another edge
%input:
% img_texture: magnitude and direction of the texture
% img_texture(row, col, 1): texture magnitude of pixel at (row, col)
% img_texture(row, col, 2): texture direction of pixel at (row, col)
% img_texture(row, col, 3): if the pixel has a main direction
% vanish_point = [vanish_row; vanish_col]
% output:
% road_angle = [left_edge_angle right_edge_angle]
img_size = size(img_texture(:,:,3));
[angle_main angle_other max_value]= main_edge_detection(img_texture, vanish_point, img_gray);
[vanish_point_new angle_other] = update_vanishing_point(img_texture, vanish_point, angle_main, angle_other, max_value, img_gray);
if angle_main < angle_other
  road_angle = [angle_main angle_other];
else
  road_angle = [angle_other angle_main];
end
% %show
% figure;
% imshow(img_texture(:,:,3));
% hold on;
% line_y=zeros(img_size(1)-vanish_point_new(2),2);
% for y = 1:(img_size(1)-vanish_point_new(2))
%     x = vanish_point_new(1) - ( (img_size(1)-vanish_point_new(2))-y )/tand(angle_main);
%     line_y(y,:)=[x, img_size(1)-y];
% end
% plot(line_y(:,1), line_y(:,2), 'LineWidth', 2, 'Color', 'blue');
% 
% line_y=zeros(img_size(1)-vanish_point_new(2),2);
% for y = 1:(img_size(1)-vanish_point_new(2))
%     x = vanish_point_new(1) - ( (img_size(1)-vanish_point_new(2))-y )/tand(double(angle_other));
%     line_y(y,:)=[x, img_size(1)-y];
% end
% plot(line_y(:,1), line_y(:,2), 'LineWidth', 2, 'Color', 'red');
% plot(vanish_point_new(1),vanish_point_new(2),'s','color','green');
% plot(vanish_point(1),vanish_point(2),'s','color','yellow');
% %show end

vanish_point = vanish_point_new;

end


function [angle_main angle_other max_value]= main_edge_detection(img_texture, vanish_point,img_gray);
img_size = size(img_texture(:,:,3));
dead_aera = 5;
angle_start = 5;
angle_end = 175;
angle_hist = generate_hist(img_texture, vanish_point, img_gray);
angle_hist(1:angle_start) = 0;
angle_hist(angle_end:181) = 0;
angle_hist(90-dead_aera:90+dead_aera) = 0;
[max_value angle_main] = max(angle_hist);
[max_value angle_other] = find_other_edge(angle_hist, angle_main, 20, 5);

end

function [vanish_point other_angle] = update_vanishing_point(img_texture, vanish_point, main_angle, other_angle_init, max_value_init, img_gray);
%estimate the point around the vanish_point, find the max

%parameter
step = 1;
count = 50;
min_edge_angle = 20;
para_n = 5;
dead_aera = 5;
angle_start = 5;
angle_end = 175;

img_size = size(img_texture(:,:,1));
other_angle = other_angle_init;
max_value = max_value_init;
angle_cos = cosd(main_angle);
angle_sin = sind(main_angle);
%calculate the init other angle
angle_hist = generate_hist(img_texture, vanish_point, img_gray);
vanish_point_new = vanish_point;
for i = 1:count
  candidate_x = vanish_point(1)+i*step*angle_cos;
  candidate_y = vanish_point(2)-i*step*angle_sin;
  if candidate_x<1 || candidate_x>img_size(1) || candidate_y<1 || candidate_y>img_size(2)
    ;
  else
    angle_hist = generate_hist(img_texture, [candidate_x; candidate_y], img_gray);
    angle_hist(1:angle_start) = 0;
    angle_hist(angle_end:181) = 0;
    angle_hist(90-dead_aera:90+dead_aera) = 0;
    [value angle] = find_other_edge(angle_hist, main_angle, min_edge_angle, para_n);
    if max_value<value
      max_value = value;
      other_angle = angle;
      vanish_point_new = [candidate_x candidate_y];
    end
  end
  candidate_x = vanish_point(1)-i*step*angle_cos;
  candidate_y = vanish_point(2)+i*step*angle_sin;
  if candidate_x<1 || candidate_x>img_size(1) || candidate_y<1 || candidate_y>img_size(2)
    ;
  else
    angle_hist = generate_hist(img_texture, [candidate_x; candidate_y], img_gray);
    angle_hist(1:angle_start) = 0;
    angle_hist(angle_end:181) = 0;
    angle_hist(90-dead_aera:90+dead_aera) = 0;
    [value angle] = find_other_edge(angle_hist, main_angle, min_edge_angle, para_n);
    if max_value<value
      max_value = value;
      other_angle = angle;
      vanish_point_new = [candidate_x candidate_y];
    end
  end
end
vanish_point = vanish_point_new;
angle_hist = generate_hist(img_texture, [vanish_point(1); vanish_point(2)], img_gray);
angle_hist(1:angle_start) = 0;
angle_hist(angle_end:181) = 0;
angle_hist(90-dead_aera:90+dead_aera) = 0;
[value angle] = find_other_edge(angle_hist, main_angle, min_edge_angle, 1);
other_angle = angle;

end


function angle_hist = generate_hist(img_texture, point, img_gray);

img_size = size(img_texture(:,:,1));
index_y = repmat((1:1:img_size(1)),img_size(2),1);
index_x = repmat((1:1:img_size(2))',1,img_size(1));
index = zeros([2 img_size(2) img_size(1)]);
index(1,:,:) = index_x;
index(2,:,:) = index_y;

%diff(P)
point_temp = repmat([point(1); img_size(1)-point(2)], [1 img_size(2) img_size(1)]);
alpha_map = atand((point_temp(2,:,:)-index(2,:,:))./(point_temp(1,:,:)-index(1,:,:)+eps));
alpha_map = reshape(alpha_map,[img_size(2) img_size(1)]);
%alpha_map = alpha_map';
alpha_map(alpha_map<0) = alpha_map(alpha_map<0)+180;
value_temp = img_texture(:,:,2);
value_temp = value_temp(img_size(1):-1:1,:);
value_temp = value_temp';
value_temp = abs(value_temp-alpha_map);
value_temp = exp(-value_temp);


angle_hist=zeros(181,1);
angle_hist_count = zeros(181,1);
for x=1:img_size(2)
    for y=1:img_size(1)-point(2)
        dis = [x-point(1) y-img_size(1)+point(2)];
        distance_sqare = dot(dis,dis);
        if distance_sqare<(0.55*img_size(1))*(0.55*img_size(1))
            angle_hist(int16(alpha_map(x,y))+1) = angle_hist(int16(alpha_map(x,y))+1)+value_temp(x,y);
            angle_hist_count(int16(alpha_map(x,y))+1) = angle_hist_count(int16(alpha_map(x,y))+1)+1;
        end
    end
end
angle_hist = angle_hist./(angle_hist_count+eps);
angle_hist(angle_hist_count<20)=0;
%diff(R1,R2), color sue,
%add codes here
% x0 = int8(point(1));
% y0 = int8(img_size(1)-point(2));
% step = [10 10];
% for theta=5:175
%     angle = theta;
%     line_ABC = [-sind(angle) cosd(angle) x0*sind(angle)-y0*cosd(angle)];
%     left_add = 0;
%     left_count = 0;
%     right_add = 0;
%     right_count = 0;
%     start_y = y0-step(2);
%     if start_y<1
%         start_y = 1;
%     end
%     end_y = y0;
%     for y=end_y:-1:start_y
%         line_x = int8(-(line_ABC(3)+line_ABC(2)*y)/line_ABC(1));
%         if line_x<1
%             break;
%         end
%         start_x = int8(max(line_x-step(1),1));
%         end_x = int8(min(line_x+step(1),img_size(2)));
%         left_add = left_add+sum(img_gray(img_size(1)-y,start_x:line_x));
%         left_count = left_count+(line_x-start_x+1);
%         right_add = right_add + sum(img_gray(img_size(1)-y, line_x:end_x));
%         right_count = right_count+(end_x-line_x+1);
%     end
%     if left_count>10 && right_count>10
%         left_mean = left_add/left_count;
%         right_mean = right_add/right_count;
%         if left_mean>right_mean
%             angle_hist(angle) = angle_hist(angle)*left_mean/right_mean;
%         else
%             angle_hist(angle) = angle_hist(angle)*right_mean/left_mean;
%         end
%     end
% end
end

function [max_value other_angle] = find_other_edge(angle_hist, main_angle, min_edge_angle, para_n);
%check the input
hist_size = size(angle_hist);
if hist_size(1) ~= 181
  disp 'angle hist is not avalible'
end
%angle_hist(1:20) = 0;
%angle_hist(161:181) = 0;

if main_angle<min_edge_angle
  angle_hist(1:main_angle) = 0;
  angle_hist(181-min_edge_angle+main_angle:181) = 0;
  angle_hist(main_angle:main_angle+min_edge_angle-1) = 0;
else if main_angle<181-min_edge_angle
      angle_hist(main_angle:main_angle+min_edge_angle-1) = 0;
      angle_hist(main_angle-min_edge_angle+1:main_angle) = 0;
    else
      angle_hist(main_angle-min_edge_angle+1:main_angle) = 0;
      angle_hist(main_angle:181) = 0;
      angle_hist(1:min_edge_angle-(181-main_angle)) = 0;
    end
end

other_angle_add = 0;
max_value_add = 0;
for i=1:int16(para_n)
  [max_value other_angle] = max(angle_hist);
  other_angle_add = other_angle_add + other_angle;
  max_value_add = max_value_add + max_value;
  angle_hist(int16(other_angle)) = 0;
end
other_angle = other_angle_add/int16(para_n);
max_value = max_value_add/int16(para_n);
end
