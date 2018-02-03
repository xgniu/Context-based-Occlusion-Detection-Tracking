function update_visualization_func = show_video(seq_name, img_files)
    %   This function returns an UPDATE_VISUALIZATION function handle, that
    %   can be called with a frame number and a bounding box [rows(height),
    %   cols(width), row, col], as soon as the results for a new frame have been calculated.
    %   This way, your results are shown in real-time, but they are also
    %   remembered so you can navigate and inspect the video afterwards.
    %   Press 'Esc' to send a stop signal (returned by UPDATE_VISUALIZATION).
    
    %store one instance per frame
    num_frames = numel(img_files);
    
    %create window
    [fig_h, axes_h, ~, scroll] = videofig(num_frames, @redraw, [], [], @on_key_press);
    set(fig_h, 'Name', 'Tracker - Alan')
    axis off;
    
    %image and rectangle handles start empty, they are initialized later
    im_h = [];
    rect_h = [];
    global ground_truth;
    global bboxes;
    global occ_bboxes;
    global patches;
    
    
    update_visualization_func = @update_visualization;
    stop_tracker = false;
    
    function stop = update_visualization(frame)
        %store the tracker instance for one frame, and show it. returns
        %true if processing should stop (user pressed 'Esc').
        scroll(frame);
        stop = stop_tracker;
    end
    
    function redraw(frame)
        
        %render main image
        im = imread([img_files{frame}]);
        im = insertShape(im, 'Rectangle', ground_truth(frame,:), 'Color', 'red', 'LineWidth',2 );
        str=[ 'Frame: ' num2str(frame)];
        im = insertText(im,[10 10],str);
        
        num_patches = numel(patches);
        for i=1:num_patches,
            if occ_bboxes(i),
                im = insertShape(im,'Rectangle', patches{i}.tracker.box,'Color','blue','LineWidth',2);
            end
        end
        occ_bboxes=zeros(1,num_patches);
        
        if isempty(im_h),  %create image
            im_h = imshow(im, 'Border','tight', 'InitialMag',200, 'Parent',axes_h);
        else  %just update it
            set(im_h, 'CData', im)
        end
        
        %render target bounding box for this frame
        if isempty(rect_h),  %create it for the first time
            rect_h = rectangle('Position',[0,0,1,1], 'EdgeColor','yellow', 'Parent',axes_h);
        end
        
        if ~isempty(bboxes(frame,:)),
            set(rect_h, 'EdgeColor','yellow', 'Visible', 'on', 'LineWidth',2, 'Position', bboxes(frame,:));
        else
            set(rect_h, 'Visible', 'off');
        end
        
        f=getframe(axes_h);
        img=frame2im(f);
        [I,map]=rgb2ind(img,256);
        gifname=['./Results1/' seq_name '.gif'];
        if frame==1,
            imwrite(I,map,gifname,'gif','LoopCount',Inf,'DelayTime',0.2);
        else
            imwrite(I,map,gifname,'gif','WriteMode','append','DelayTime',0.2);
        end
    end
    
    function on_key_press(key)
        if strcmp(key, 'escape'),  %stop on 'Esc'
            stop_tracker = true;
        end
    end
    
end

