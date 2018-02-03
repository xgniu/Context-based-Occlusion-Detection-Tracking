function x = get_features(im, cos_window)
    %GET_FEATURES
    %   Extracts dense features from image.
    %
    %   X = GET_FEATURES(IM, FEATURES, CELL_SIZE)
    %   Extracts features specified in struct FEATURES, from image IM. The
    %   features should be densely sampled, in cells or intervals of CELL_SIZE.
    %   The output has size [height in cells, width in cells, features].
    %
    %   To specify HOG features, set field 'hog' to true, and
    %   'hog_orientations' to the number of bins.
    %
    %   To experiment with other features simply add them to this function
    %   and include any needed parameters in the FEATURES struct. To allow
    %   combinations of features, stack them with x = cat(3, x, new_feat).
    %
    %   Joao F. Henriques, 2014
    %   http://www.isr.uc.pt/~henriques/
    
    global w2c;
    if isempty(w2c)
        % load the RGB to color name matrix if not in input
        temp = load('w2crs');
        w2c = temp.w2crs;
    end
    
    hog_cell_size=4;
    hog_orientations=9;
    %HOG features, from Piotr's Toolbox
    x = double(fhog(single(im) / 255, hog_cell_size, hog_orientations));
    x(:,:,end) = [];  %remove all-zeros channel ("truncation feature")
    
    % Color-Name features
    
    sz = size(x);
    im_patch = imresize(im, [sz(1) sz(2)]);
    out_npca = get_feature_map(im_patch, 'gray', w2c);
    out_pca = get_feature_map(im_patch, 'cn', w2c);
    
    x = cat(3,x,out_npca);
    x = cat(3,x,out_pca);
    
    %process with cosine window if needed
    if ~isempty(cos_window),
        x = bsxfun(@times, x, cos_window);
    end
    
end
