function step2_5_dof(config)
%STEP2_5_DOF 此处显示有关此函数的摘要
%   此处显示详细说明
    dof_path = fullfile(config.save_path, 'DOF');
    if ~exist(dof_path, 'dir')
        mkdir(dof_path);
    end
    copyfile(config.save_path, dof_path);
end

