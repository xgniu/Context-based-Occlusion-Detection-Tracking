function run_tracker_parallel()
    base_path ='D:\Visual Tracking\Benchmark\OTB13\';
    
    dirs = dir(base_path);
    videos = {dirs.name};
    videos(strcmp('.', videos) | strcmp('..', videos) | ...
        strcmp('anno', videos) | ~[dirs.isdir]) = [];
    
%     parfor k = 1:numel(videos)
%         disp(videos{k});
%         if exist(['.\Results1\' videos{k} '_Ours_KCF.mat'],'file')~=2
%             run_tracker_seq_KCF(videos{k});
%         end
%     end
%     
%     parfor k = 1:numel(videos)
%         disp(videos{k});
%         if exist(['.\Results1\' videos{k} '_Ours_SAMF.mat'],'file')~=2
%             run_tracker_seq_SAMF(videos{k});
%         end
%     end

    parfor k = 1:numel(videos)
        disp(videos{k});
        if exist(['.\Results1\' videos{k} '_Ours.mat'],'file')~=2
            run_tracker_seq(videos{k});
        end
    end
end
