function [img, init_center, target_sz, groundtruth_rect] = load_seq_info(data_path,seqName)
    % Load video info.    
    video_path=[data_path seqName '/img/'];
    
    groundtruth_rect = importdata([data_path seqName '/groundtruth_rect.txt']); %[x,y,width, height]
    initstate = groundtruth_rect(1,:); %initial rectangle [x,y,width, height]
    %center of the target, (row, col)
    init_center = [initstate(2)+initstate(4)/2 initstate(1)+initstate(3)/2];
    %initial size of the target, (rows, cols)
    target_sz = [initstate(4) initstate(3)];
    
    d = dir([video_path, '*.jpg']);
    for i = 1 : size(d, 1)
        img{i} = [video_path sprintf('%04d',i) '.jpg'];
    end

end