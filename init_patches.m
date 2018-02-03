function init_patches(im,center,target_sz)
    if size(im,3)~=1
        imgray=single(rgb2gray(im));
    else
        imgray=single(im);
    end
       
    % center:center of target, [row,col]([y x]). target_sz:[rows,cols].
    patchsz=[13,13];%[ys, xs](height,width)
    
    center_upleft = max(1, round( center - target_sz/2 - patchsz/2 ) );
    center_upright= [max( 1, round( center(1)-target_sz(1)/2 - patchsz(1)/2) ), min( size(imgray,2),round(center(2)+target_sz(2)/2+patchsz(2)/2) )];
    center_bottomleft = [min( size(imgray,1), round(center(1)+target_sz(1)/2+patchsz(1)/2) ), max( 1,round(center(2)-target_sz(2)/2-patchsz(2)/2) )];
    center_bottomright= min( [size(imgray,1),size(imgray,2)], round(center + target_sz/2 + patchsz/2) );
    
    global patches;
    numPatches = numel(patches);
    
    r  = target_sz(1)/target_sz(2);
    n1 = round( numPatches*0.5*r/(1+r) ); % num of patches in left and right side.
    n2 = numPatches*0.5-n1; % num of patches in up and bottom side.
       
    num=1;    
    % Generate left-side patches.
    cy=randi([center_upleft(1),center_bottomleft(1)],n1,1);
    for i=1:n1
        patch.tag='left';
        patchcenter=[cy(i),center_upleft(2)];%(y,x)
        patch.tracker=KCF(imgray,patchcenter,patchsz);
        patches{num}=patch;
        num=num+1;
    end
    
    % Generate right-side patches.
    cy=randi([center_upright(1),center_bottomright(1)],n1,1);
    for i=1:n1
        patch.tag='right';
        patchcenter=[cy(i),center_upright(2)];
        patch.tracker=KCF(imgray,patchcenter,patchsz);
        patches{num}=patch;
        num=num+1;
    end
    
    % Generate up-side patches.
    cx=randi([center_upleft(2),center_upright(2)],n2,1);
    for i=1:n2
        patch.tag='up';
        patchcenter=[center_upleft(1),cx(i)];
        patch.tracker=KCF(imgray,patchcenter,patchsz);
        patches{num}=patch;
        num=num+1;
    end
    
    % Generate bottom-side patches.
    cx=randi([center_bottomleft(2),center_bottomright(2)],n2,1);
    for i=1:n2
        patch.tag='bottom';
        patchcenter=[center_bottomleft(1),cx(i)];
        patch.tracker=KCF(imgray,patchcenter,patchsz);
        patches{num}=patch;
        num=num+1;
    end

end