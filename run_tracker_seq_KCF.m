function run_tracker_seq_KCF(seq_name)
    addpath('./KCF');
    base_path = 'D:\Visual Tracking\Benchmark\OTB13\';
    
    if nargin==0,
        seq_name = choose_video(base_path);
    end
    % Loading seq info specified by 'seqName'.
    %pos: upleft corner of the target, (row, col);
    %target_sz: initial size of the target, (rows, cols)
    %ground_truth: [x, y, width, height]. (col,row,cols,rows)
    global ground_truth;
    [img_files, center, target_sz, ground_truth]=loadSeqInfo(base_path,seq_name);
    disp(['Processing Sequence ' seq_name '...']);
    update_visualization = show_video_noOD(seq_name, img_files);
        
    %% Tracking
    time = 0;  %to calculate FPS
    global bboxes;
    bboxes = zeros( numel( img_files ), 4 );  %tracking results
    for frame = 1:numel( img_files ),
        im=imread(img_files{frame});
        tic();
        
        if frame==1,
            target.tracker=KCF(im,center,target_sz);
        else
            track_output=target.tracker.track(im);
            bboxes( frame,:) = track_output;           
            target.tracker.update();          
        end
        time = time + toc();
        
        stop = update_visualization(frame);
        if stop, break, end  %user pressed Esc, stop early
        drawnow
    end
    
    fps= frame/time;
    fprintf('Seq: %s, FPS:% 4.2f\n', seq_name, fps);
    save(['./Results1/' seq_name '_Ours_KCF'],'bboxes');
    
end