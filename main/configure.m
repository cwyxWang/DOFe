function configure(config)
    t1 = clock;
    temp = dir(fullfile(config.root,'dof_*'));
    View_name = {temp.name};
    view_num = size(View_name, 2); 

    for i = 1:view_num
        config.view_path = fullfile(config.root,View_name{i});
        ctxt_name = fullfile(config.view_path,'config.txt');
        fileID = fopen(ctxt_name);
        temp = textscan(fileID,'%s','Delimiter', '\n');
        line_num = size(temp{1},1);
        for j =1:line_num
            line_str = temp{1}{j};
            if size(line_str,2)<=7
                continue
            end
            switch line_str(1:7)
                case 'magnifi'
                    a = textscan(line_str(15:end),'%f');
                    config.m = a{1};
                case 'y shift'
                    a = textscan(line_str(9:end),'%f');
                    config.l1_shift = a{1}(1);
                    config.l2_shift = a{1}(3);
                case 'z shift'
                    a = textscan(line_str(9:end),'%f');
                    config.z_shift = a{1};
                case 'i shift'
                    a = textscan(line_str(9:end),'%f');
                    config.i_shift = a{1};
                case 'e shift'
                    a = textscan(line_str(9:end),'%f');
                    config.e_shift = a{1};
                case 's shift'
                    a = textscan(line_str(9:end),'%f');
                    config.s_shift = a{1};
                case 'x scan '
                    a = textscan(line_str(8:end),'%f');
                    config.slice_per_stack = a{1};
                case 'x step '
                    a = textscan(line_str(8:end),'%f');
                    config.stepsize = a{1};
                case 'z step '
                    a = textscan(line_str(8:end),'%f');
                    config.zstep = a{1};
            end
        end
        config.pixelsize = 6.5/config.m;
        config.dof = true;
        switch config.m
            case 100
                temp = 44;
                config.dof = false;
            case 60
                temp = 54;
            case 40
                temp = 45;
            case 30
                temp = 65;
            case 20
                temp = 66;
            case 10
                temp = 78;
            otherwise
                temp = 81;
        end
        config.theta = temp/180*pi;
        fclose(fileID);
        
        config.factor = config.stepsize / config.pixelsize;
        
        save_path = fullfile(config.view_path,'reconstructed');
        if ~exist(save_path, 'dir')
            mkdir(save_path);
        end
        config.save_path = save_path;
        
        fprintf([strrep(config.view_path,'\','/'),'\n']);
        step1_entry(config);
    end
    
    t2 = clock;
    dt1 = etime(t2,t1);
    m = floor(dt1/60);
    s = dt1-m*60;
    h = floor(m/60);
    m = m-h*60;
    fprintf(['Time consumption: ',num2str(h),'h',num2str(m),'m',num2str(s),'s\n'])

end

