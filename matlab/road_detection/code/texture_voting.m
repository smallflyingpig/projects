function [canditate voting_map] = texture_voting(img_texture);
% obtain the VP canditate from image texture
% input:
% img_texture: magnitude and direction of the texture
% img_texture(row, col, 1): texture magnitude of pixel at (row, col)
% img_texture(row, col, 2): texture direction of pixel at (row, col)
% img_texture(row, col, 3): if the pixel has a main direction
% output:
% canditate, 1x2, x and y of the VP

img_size = size(img_texture(:,:,1));
I = img_texture(:,:,1);%intensity
D = img_texture(:,:,2);%direction
M = img_texture(:,:,3);%mask

voting_map = zeros(img_size);
for row = img_size(1)-1:-1:1
    for col = 1:img_size(2)
        if M(row, col)% 1
            voting_map = region_vote(voting_map,row,col,I(row, col), D(row, col));
        end
    end
end

[value canditate] = max(voting_map(:));
[canditate_row canditate_col] = ind2sub(img_size, canditate);
canditate = [ canditate_col canditate_row ];
% %visualize the result
% subplot(1,2,1);
% %figure 
% imshow(voting_map/value);
% hold on;
% plot(canditate(1),canditate(2),'s','color','black');
% subplot(1,2,2);
% imshow(M);
% hold on;
% plot(canditate(1),canditate(2),'s','color','red');

end

function voting_map = region_vote(voting_map,row,col,I_value, D_value);

img_size = size(voting_map);

if D_value>175 || D_value<5
    return;
end
%coordinate transformation
PK = 0.4*img_size(1);
PQ = 0.55*img_size(1);
KQ = PQ-PK;
theta = D_value;
sin_theta = sind(theta);
cos_theta = cosd(theta);
tolerance = 5;
P = [col; img_size(1)-row];
K = [P(1)+PK*cos_theta P(2)+PK*sin_theta];
Q = [P(1)+PQ*cos_theta P(2)+PQ*sin_theta];

PI1_ABC = [ sind(theta+tolerance/2) -cosd(theta+tolerance/2) -(P(1)*sind(theta+tolerance/2)-P(2)*cosd(theta+tolerance/2))  ];
PJ1_ABC = [ sind(theta-tolerance/2) -cosd(theta-tolerance/2) -(P(1)*sind(theta-tolerance/2)-P(2)*cosd(theta-tolerance/2))  ];

PQ_ABC = [ sind(theta) -cosd(theta) -(P(1)*sind(theta)-P(2)*cosd(theta))];%Ax+By+C=0
I1 = [P(1)+PK*sin_theta/tand(theta+tolerance/2) K(2)];
J1 = [P(1)+PK*sin_theta/tand(theta-tolerance/2) K(2)];
I2 = [I1(1)+KQ*cos_theta I1(2)+KQ*sin_theta];
J2 = [J1(1)+KQ*cos_theta J1(2)+KQ*sin_theta];
I1I2_ABC = [ I2(2)-I1(2) -(I2(1)-I1(1)) -I1(1)*(I2(2)-I1(2))+I1(2)*(I2(1)-I1(1)) ];
J1J2_ABC = [ J2(2)-J1(2) -(J2(1)-J1(1)) -J1(1)*(J2(2)-J1(2))+J1(2)*(J2(1)-J1(1)) ];

for y=P(2):Q(2)
    if y>=img_size(1)
        break;
    end
    if y<K(2)
        x_start = (-PI1_ABC(3)-y*PI1_ABC(2))/PI1_ABC(1);
        x_end = (-PJ1_ABC(3)-y*PJ1_ABC(2))/PJ1_ABC(1);
        x_middle = (-PQ_ABC(3)-y*PQ_ABC(2))/PQ_ABC(1);
    else
        x_start = (-I1I2_ABC(3)-y*I1I2_ABC(2))/I1I2_ABC(1);
        x_end = (-J1J2_ABC(3)-y*J1J2_ABC(2))/J1J2_ABC(1);
        x_middle = (-PQ_ABC(3)-y*PQ_ABC(2))/PQ_ABC(1);
    end
    x_step = 1;
    if x_start < x_end
        x_step = 1;
    else 
        x_step = -1;
    end
    for x=x_start:x_step:x_end
        if x<1 || x>=img_size(2)
            continue;
        end
        %calculate the vote value
        lambda = abs(x-x_middle);
        gamma = 180;
        d = norm([x-P(1); y-P(2)])/norm(img_size);
        o_row = img_size(1)-y;
        o_col = int16(x);
        vote_value = exp(-lambda/gamma)/(1+d*d);
        voting_map(o_row, o_col) = voting_map(o_row, o_col) +vote_value;
    end
end

end