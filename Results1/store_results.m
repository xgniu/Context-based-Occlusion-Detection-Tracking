function store_results()
    base_path ='D:\Visual Tracking\Benchmark\OTB13\';
    
    dirs = dir(base_path);
    videos = {dirs.name};
    videos(strcmp('.', videos) | strcmp('..', videos) | ...
        strcmp('anno', videos) | ~[dirs.isdir]) = [];
    
    for k = 1:numel(videos)
        if exist([videos{k} '_Ours.mat'],'file')==2
            tmp=load([videos{k} '_Ours.mat']);
            groundtruth = importdata([base_path videos{k} '/groundtruth_rect.txt']); %[x,y,width, height]
            results=cell(1,1);
            result=results{1,1};
            result.type='rect';
            result.res=tmp.bboxes;
            result.len=size(groundtruth,1);
            result.annoBegin=1;
            result.startFrame=1;
            if strcmp(videos{k},'David')
                result.annoBegin=300;
                result.startFrame=300;
            end
            result.anno=groundtruth;
            results{1,1}=result;
            save([videos{k} '_Ours.mat'],'results');
        end
    end
end