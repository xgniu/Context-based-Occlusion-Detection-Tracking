function run_tracker_seq(seq_name)
    addpath('./SAMF');
    addpath('./KCF');
    base_path = 'D:\Visual Tracking\Benchmark\OTB13\';

    if nargin==0
        seq_name = choose_video(base_path);
    end
    
    % Loading seq info specified by 'seq_name'.
    %center: center of the target, (row, col);
    %target_sz: initial size of the target, (rows, cols)
    %ground_truth: [x(horizontal pos), y(vertical pos), width(horizontal range), height(vertical range)]. (col,row,cols,rows)
    global ground_truth;
    [img_files, center, target_sz, ground_truth] = load_seq_info(base_path,seq_name);
    disp(['Processing Sequence ' seq_name '...']);
    update_visualization = show_video(seq_name, img_files);
    
    %% Set parameters.
    num_patches = round(sqrt(prod(target_sz)));
    num_patches = num_patches + mod(num_patches,2); % num_patches should be even
    global patches;
    patches = cell(1,num_patches);
    global bboxes;   %tracking results
    bboxes = zeros( numel( img_files ), 4 );
    
    global occ_bboxes;
    occ_bboxes = zeros(1,num_patches);
    
    %% Tracking
    time = 0;  %to calculate FPS    
    for frame = 1:numel( img_files )
        im = imread(img_files{frame});
        
        tic();
        
        if frame == 1
            init_patches(im,center,target_sz);
            target.tracker = SAMF(im,center,target_sz);
        else
            track_output = target.tracker.track(im);        
            bboxes(frame,:) = track_output;
            
            occ = update_patch_trackers(track_output, im);
            if occ == 0
                target.tracker.update();
            end
            
        end
        time = time + toc();
        stop = update_visualization(frame);
        if stop, break, end  %user pressed Esc, stop early
        drawnow 
    end
    
    fps= frame/time;
    save(['./Results1/' seq_name '_Ours'],'bboxes');   
    fprintf('Seq: %s, FPS:% 4.2f\n', seq_name, fps)
    
end