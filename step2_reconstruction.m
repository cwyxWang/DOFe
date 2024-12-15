function step2_reconstruction(config,ind)
%STEP2_RECONSTRUCTION 此处显示有关此函数的摘要
%   此处显示详细说明ind-i
    shift_vector = [config.l1_shift,0,config.l2_shift];
    for i = 1:size(config.iminfo,2)
        save_name = fullfile(config.save_path,sprintf('%04d-%04d.tif', ind,4-i));
        affine_matrix = get_affine(config.factor, config.theta);
        a = (ind-1) * config.slice_per_stack + 1;   % 取第i*60张图出来
        b = ind * config.slice_per_stack;
        stack = read_stack(config.iminfo{i},(a:b));
        result = imwarp(stack,affine3d(affine_matrix), 'linear');         % 'cubic','nearest'
%         depth = floor(size(result, 3)/2);
%         depth_goal = 3;
%         result = result(:,:,depth-depth_goal+1:depth+depth_goal);
        result = imtranslate(result,[0,shift_vector(i)]);
        
        if config.mean>0
            noise = uint16(randn(size(result))*config.std + config.mean);
            flag_ = result<config.mean-3*config.std;
            result(flag_) = noise(flag_);
        end
        result = uint16(result);
        deepth = size(result,3);
        for j = 1:deepth
            if j == 1
                imwrite(result(:,:,j), save_name);
            else
                imwrite(result(:,:,j), save_name,'WriteMode','append');
            end
        end
    end
end

%%
function affine_matrix = get_affine(factor, theta)
    affine_matrix = [0          1    0                          0
                    -1          0    sin(theta)/cos(theta)      0
                    factor      0    0                          0
                    0           0    0                          1];
end


%%
function stack = read_stack(iminfo,name_list)
n_slice  = size(name_list, 2);   % name_list是一个1*60的矩阵，读取第二个维度60给n_slice
if isempty(iminfo.data_path)
    stack = [];
    return
end

name_code = cell(1,n_slice);   % cell元胞数组，存字符串的数组，索引用{}大括号
slice_code = (1:n_slice)*0;
img_num = size(iminfo.stack_size_list);

for i = 1:n_slice
    for j = 1:img_num
        if name_list(i)<=sum(iminfo.stack_size_list(1:j))
            name_code{i} = iminfo.data_name{j};
            slice_code(i) = name_list(i)-sum(iminfo.stack_size_list(1:j-1));
            break
        end
    end
end

stack = zeros(iminfo.height, iminfo.width, n_slice);

for i = 1:n_slice
    try
        stack(:,:,i) = imread(fullfile(iminfo.data_path, name_code{i}), slice_code(i));
    catch
        warning('索引超出数组元素的数目.');
    end

end

end
