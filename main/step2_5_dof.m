function step2_5_dof(config)
%STEP2_5_DOF �˴���ʾ�йش˺�����ժҪ
%   �˴���ʾ��ϸ˵��
    dof_path = fullfile(config.save_path, 'DOF');
    if ~exist(dof_path, 'dir')
        mkdir(dof_path);
    end
    copyfile(config.save_path, dof_path);
end

