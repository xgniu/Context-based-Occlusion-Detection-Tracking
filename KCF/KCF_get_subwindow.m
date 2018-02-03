function out = get_subwindow(im, pos, sz)
%GET_SUBWINDOW Obtain sub-window from image, with replication-padding.
%   Returns sub-window of image IM centered at POS ([y, x] coordinates),
%   with size SZ ([height, width]). If any pixels are outside of the image,
%   they will replicate the values at the borders.
%
%   Joao F. Henriques, 2014
%   http://www.isr.uc.pt/~henriques/

if isscalar(sz),  %square sub-window
      sz = [sz, sz];
end

x_scale = floor( pos(2) ) + ( 1:sz(2) ) - floor( sz(2)/2 );
y_scale = floor( pos(1) ) + ( 1:sz(1) ) - floor( sz(1)/2 );

%check for out-of-bounds coordinates, and set them to the values at
%the borders
x_scale(x_scale < 1) = 1;
y_scale(y_scale < 1) = 1;
x_scale(x_scale > size(im,2)) = size(im,2);
y_scale(y_scale > size(im,1)) = size(im,1);

%extract image
out = im(y_scale, x_scale, :);

end

