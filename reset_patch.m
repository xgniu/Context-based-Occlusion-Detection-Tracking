function patch = reset_patch(im,center,target_sz,tag)
    
    % center:center of target, [row,col]([y x]). target_sz:[rows,cols].
    patchsz=[13, 13];%[ys, xs](height,width)
    
    center_upleft = max(1, round( center - target_sz/2 - patchsz/2 ) );
    center_upright= [max( 1, round( center(1)-target_sz(1)/2 - patchsz(1)/2) ), min( size(im,2),round(center(2)+target_sz(2)/2+patchsz(2)/2) )];
    center_bottomleft = [min( size(im,1), round(center(1)+target_sz(1)/2+patchsz(1)/2) ), max( 1,round(center(2)-target_sz(2)/2-patchsz(2)/2) )];
    center_bottomright= min( [size(im,1),size(im,2)], round(center + target_sz/2 + patchsz/2) );
    
    switch tag
        case 'left'
            % Generate left-side patches.
            cy=randi([center_upleft(1),center_bottomleft(1)]);
            patch.tag='left';
            patchcenter=[cy,center_upleft(2)];%(y,x)
            patch.tracker=KCF(im,patchcenter,patchsz);   
        case 'right'
            % Generate right-side patches.
            cy=randi([center_upright(1),center_bottomright(1)]);
            patch.tag='right';
            patchcenter=[cy,center_upright(2)];
            patch.tracker=KCF(im,patchcenter,patchsz);   
        case 'up'
            % Generate up-side patches.
            cx=randi([center_upleft(2),center_upright(2)]);
            patch.tag='up';
            patchcenter=[center_upleft(1),cx];
            patch.tracker=KCF(im,patchcenter,patchsz);   
        case 'bottom'
            % Generate bottom-side patches.
            cx=randi([center_bottomleft(2),center_bottomright(2)]);
            patch.tag='bottom';
            patchcenter=[center_bottomleft(1),cx];
            patch.tracker=KCF(im,patchcenter,patchsz);   
    end
end