function step3_registration(config)
%STEP3_REG 此处显示有关此函数的摘要
%   此处显示详细说明
    concat_d = round(config.zstep*1000/3/config.pixel_size);
       
    cache_path = fullfile(config.elastix_path, 'cache');
    if ~exist(cache_path, 'dir')
        mkdir(cache_path);
    end
    moved_name = fullfile(cache_path, 'result.0.tiff');
    result_name = fullfile(config.elastix_path, 'fixed.tif');
    moving_name = fullfile(config.elastix_path, 'moving.tif');

    temp = dir(fullfile(config.save_path,'*.tif'));
    data_name = {temp.name};
    data_num = size(data_name, 2);
    temp = imfinfo(fullfile(config.save_path, data_name{1}));
    d0 = size(temp,1);
    info = temp(1);
    h = info.Height;
    w = info.Width;
    
    stack = read_stack(fullfile(config.save_path, data_name{1}),h,w,d0);
    stack = add_d(stack, concat_d);
    write_img(stack,result_name);
    d = d0+concat_d;
    stitching_d = ceil(d0/2)+concat_d+1;
    for i = 2:data_num
        temp = zeros(w,h,d);
        corr = 0;
        if mod(i,3)==1
            corr = 4;
        end
        temp(:,:,d-d0+1-corr:d-corr) = read_stack(fullfile(config.save_path, data_name{i}),w,h,d0);
        write_img(temp,moving_name);
        system(['cd ',config.elastix_path, ' && elastix -f fixed.tif -m moving.tif -out cache -p p_3d.txt']);
        new_stack = read_stack(moved_name,w,h,d);
        if mod(i,3)==0
            new_stack = (new_stack-120)*1.5+120;
        end
        
        stack(:,:,d-stitching_d-1) = ((new_stack(:,:,d-stitching_d-1)+3*stack(:,:,d-stitching_d-1))/4-120)*1.3+120;
        stack(:,:,d-stitching_d) = ((new_stack(:,:,d-stitching_d)+stack(:,:,d-stitching_d))/2-120)*1.3+120;
        stack(:,:,d-stitching_d+1) = ((3*new_stack(:,:,d-stitching_d+1)+stack(:,:,d-stitching_d+1))/4-120)*1.3+120;
        %     stack(:,:,d-21) = (new_stack(:,:,d-21)+stack(:,:,d-21))/2;
        %     stack(:,:,d-22) = (new_stack(:,:,d-22)+stack(:,:,d-22))/2;
        
        stack(:,:,d-stitching_d+2:d) = new_stack(:,:,d-stitching_d+2:d);
        stack = add_d(stack, concat_d);
        write_img(stack,result_name);
        d = d+concat_d;
    end
    write_img(stack(:,:,d-concat_d+1:d),fullfile(config.view_path,'result.tif'));
end

%%
function stack = read_stack(name,h,w,d)
    stack = zeros(h,w,d);
    for i = 1:d
        stack(:,:,i) = imread(name,i);
    end
end
function write_img(stack,name)
stack = uint16(stack);
for j = 1:size(stack,3)
    if j == 1
        imwrite(stack(:,:,j), name);
    else
        imwrite(stack(:,:,j), name,'WriteMode','append');
    end
end
end

function new_stack = add_d(stack, d)
new_stack = zeros(size(stack,1),size(stack,2),size(stack,3)+d);
new_stack(:,:,1:size(stack,3)) = stack;
end