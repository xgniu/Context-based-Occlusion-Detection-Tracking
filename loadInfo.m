function [img, groundtruth_rect]=loadInfo(base_path,seqName)
    % Load video info.
    
    data_path=[base_path seqName];
    video_path=[data_path '/img/'];
    
    if strcmp(seqName,'David'),
        groundtruth_rect = importdata([data_path, '/groundtruth_rect.txt']); %[x,y,width, height]
        
        for i = 300 : 770
            img.names{i-299} = [video_path sprintf('%04d',i) '.jpg'];
        end
        
    elseif strcmp(seqName,'BlurCar4'),
        groundtruth_rect = importdata([data_path, '/groundtruth_rect.txt']); %[x,y,width, height]
        
        for i = 18 : 397
            img.names{i-17} = [video_path sprintf('%04d',i) '.jpg'];
        end
        
    elseif strcmp(seqName,'BlurCar3'),
        groundtruth_rect = importdata([data_path, '/groundtruth_rect.txt']); %[x,y,width, height]
        
        for i = 3 : 359
            img.names{i-2} = [video_path sprintf('%04d',i) '.jpg'];
        end
    elseif strcmp(seqName,'BlurCar1'),
        groundtruth_rect = importdata([data_path, '/groundtruth_rect.txt']); %[x,y,width, height]
        
        for i = 247 : 988
            img.names{i-246} = [video_path sprintf('%04d',i) '.jpg'];
        end
    elseif strcmp(seqName,'Freeman4'),
        groundtruth_rect = importdata([data_path, '/groundtruth_rect.txt']); %[x,y,width, height]
        groundtruth_rect = groundtruth_rect(1:283,:);
        
        for i = 1 : 283
            img.names{i} = [video_path sprintf('%04d',i) '.jpg'];
        end
        
    elseif strcmp(seqName,'Football1'),
        groundtruth_rect = importdata([data_path, '/groundtruth_rect.txt']); %[x,y,width, height]
        groundtruth_rect = groundtruth_rect(1:74,:);
        
        for i = 1 : 74
            img.names{i} = [video_path sprintf('%04d',i) '.jpg'];
        end
        
    elseif strcmp(seqName,'Freeman3'),
        groundtruth_rect = importdata([data_path, '/groundtruth_rect.txt']); %[x,y,width, height]
        groundtruth_rect = groundtruth_rect(1:460,:);
        
        for i = 1 : 460
            img.names{i} = [video_path sprintf('%04d',i) '.jpg'];
        end
        
    elseif strcmp(seqName,'Board'),
        groundtruth_rect = importdata([data_path, '/groundtruth_rect.txt']); %[x,y,width, height]
        
        d = dir([video_path, '*.jpg']);
        for i = 1 : size(d, 1)
            img.names{i} = [video_path sprintf('%05d',i) '.jpg'];
        end
        
    else
        groundtruth_rect = importdata([data_path, '/groundtruth_rect.txt']); %[x,y,width, height]
        
        d = dir([video_path, '*.jpg']);
        for i = 1 : size(d, 1)
            img.names{i} = [video_path sprintf('%04d',i) '.jpg'];
        end
    end
end