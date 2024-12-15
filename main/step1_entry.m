function step1_entry(config)
%STEP1_ENTRY 此处显示有关此函数的摘要
%   此处显示详细说明
    config.iminfo = cell(1,3);
    config.iminfo{1} = get_data_info(config, 'len_1');
    config.iminfo{2} = get_data_info(config, 'len_2');
    config.iminfo{3} = get_data_info(config, 'len_3');
    for i = 1:config.iminfo{1}.timepoint
        tic;
        fprintf([num2str(i),'\t\t']);   % 打印时间点
        
        step2_reconstruction(config, i);
        
        dt = toc;
        fprintf([num2str(dt), '\n']);   % 打印时间间隔
        
    end
    step3_registration(config);
end
%%
function datainfo = get_data_info(config, file_name)

data_path = fullfile(config.view_path, file_name);

datainfo = struct();
datainfo.data_path = data_path;
datainfo.data_name = {};
datainfo.stack_size_list = 0;
datainfo.width = 0;
datainfo.height = 0;
datainfo.bitdepth = 16;
datainfo.file_num = 0;
datainfo.timepoint = 0;

if isempty(data_path)
    return
end

if isfolder(data_path)
    temp = dir(fullfile(data_path,'*.tif'));   % *通配符，代表读取所有以.tif结尾的文件
    data_name = {temp.name};
    data_num = size(data_name, 2);  % data_num：有几张tif图
    stack_size_list = zeros(data_num,1);
    for i = 1:data_num
        temp = imfinfo(fullfile(data_path, data_name{i}));
        stack_size_list(i) = size(temp,1);   % 如有4张tif，则该列表保存了每张tif在z上的张数
    end
    info = temp(1);
    height   = info.Height;
    width    = info.Width;
    bitdepth = info.BitDepth;
end

file_num = sum(stack_size_list);
timepoint = ceil(file_num / config.slice_per_stack);   % floor向下取整

datainfo.data_name = data_name;
datainfo.stack_size_list = stack_size_list;
datainfo.width = width;
datainfo.height = height;
datainfo.bitdepth = bitdepth;
datainfo.file_num = file_num;
datainfo.timepoint = timepoint;

end
