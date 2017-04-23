function rtn = test();
src_dir = '../input/';
out_dir = '../output/';%be sure this fold exist 

for index = [1 2 3 4 5 6 7 8]
    disp (index);disp( ':start...');
    
    img_dir = strcat(src_dir,strcat(num2str(index),'.jpg'));
    img = imread(img_dir);
    img_size = size(img);
    img = imresize(img, 256/img_size(1));
    img_size = size(img);
    if size(img_size)>=3
        if img_size(3)>=3
            img_gray = rgb2gray(img(:,:,1:3));
        else
            img_gray = rgb2gray(img);
        end
    else
        img_gray = rgb2gray(img);
    end
    disp(index); disp(':get texture...');
    tic;
    img_texture = get_texture(img_gray);
    toc;
    
    disp(index); disp(':voting...');
    tic;
    [vp voting_map] = texture_voting(img_texture);
    toc;
    
    disp(index); disp(':road area detection...');
    tic;
    [vp_new road_angle] = road_area_detection(img_texture, vp, img_gray);
    toc;
    disp(index); disp(':save...');
    tic;
    %save to output
    line = int32([ vp_new(1)-(img_size(1)-vp_new(2)-1)/tand(double(road_angle(1))) img_size(1) vp_new  vp_new(1)-(img_size(1)-vp_new(2)-1)/tand(double(road_angle(2))) img_size(1)]);
    if ~isempty(find(line<1))
        if line(1)<0
            line(1:2) = [1 vp_new(2)+(vp_new(1)*tand(double(road_angle(1))))];
        end
        if line(5)>img_size(2)
            line(5:6) = [img_size(2) vp_new(2)-((img_size(2)-vp_new(1))*tand(double(road_angle(2))))];
        end
    end
        
    inserter = vision.ShapeInserter('Shape', 'Lines','BorderColor','Custom', 'CustomBorderColor', [0 255 0]);
    img = inserter.step(img, line);
    imwrite(img_texture(:,:,3), strcat(out_dir,strcat(num2str(index),'mask.jpg')));
    rect_length = 10;
    vp_rect = int32([vp-[rect_length/2 rect_length/2] rect_length+1 rect_length+1]);
    vp_new_rect = int32([vp_new-[rect_length/2 rect_length/2] rect_length+1 rect_length+1]);
    inserter = vision.ShapeInserter('Shape', 'Rectangles','BorderColor','Custom', 'CustomBorderColor', [0 0 255]);
    img = inserter.step(img, vp_rect);
    
    inserter = vision.ShapeInserter('Shape', 'Rectangles','BorderColor','Custom', 'CustomBorderColor', [255 0 0]);
    img = inserter.step(img, vp_new_rect);
    
    imwrite(img, strcat(out_dir,strcat(num2str(index),'.jpg')));
    
    inserter = vision.ShapeInserter('Shape', 'Rectangles');
    imwrite(inserter.step(repmat(voting_map/max(voting_map(:)),[1 1 3]),vp_rect), strcat(out_dir,strcat(num2str(index),'voting_map.jpg')));
    toc;
end
rtn = 0;
end