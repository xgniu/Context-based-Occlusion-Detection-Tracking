function OCC = update_patch_trackers(track_output,im)
    
    track_output_center = round( track_output([2 1])+track_output([4 3])/2 );%(y,x)
    
    global patches;
    global occ_bboxes;
    num_patches = numel(patches);
    
    % im: the current frame
    if size(im,3)~=1
        imgray = single(rgb2gray(im));
    else
        imgray = single(im);
    end
    
    for i = 1:num_patches
        patch = patches{i};
        [patch.box,response] = patch.tracker.track(imgray);
        if PSR(response)>50
            overlapRatio = rectint(patch.box,track_output) / (patch.box(3)*patch.box(4));
            if overlapRatio>0.3
                patch.tracker.update();
                occ_bboxes(i) = 1;
            else
                patch = reset_patch(imgray,track_output_center,track_output([4 3]),patch.tag);
            end
        else
            patch = reset_patch(imgray,track_output_center,track_output([4 3]),patch.tag);
        end
        patches{i} = patch;
    end
    
    idx = find(occ_bboxes==1);
    count = numel(idx);
    for k = 1:(count-1)
        if occ_bboxes(idx(k)) == 1
            for m = (k+1):count
                if bboxOverlapRatio(patches{idx(k)}.tracker.box,patches{idx(m)}.tracker.box)>0.6
                    occ_bboxes(idx(m))=0;
                end
            end
        end
    end
    
    % the value of OCC indicates OCC-status.
    OCC = ( numel(find((occ_bboxes==1))) > 5 );
end