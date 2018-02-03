classdef SAMF < handle
    properties (SetAccess = private)
        padding = 1.5;  %extra area surrounding the target
        lambda = 1e-4;  %regularization
        output_sigma_factor = 0.1;  %spatial bandwidth (proportional to target)        
        interp_factor = 0.01;
        kernel_sigma = 0.5; %gaussian kernel bandwidth        
        hog_orientations = 9;
        hog_cell_size = 4;
        
        search_size = [1  0.985 0.99 0.995 1.005 1.01 1.015];
        szid = 1;
        
        center;
        target_sz;
        box;
        
        window_sz;
        output_sigma;
        yf;
        cos_window;
        response;
        
        model_alphaf;
        model_xf;
        current_im;
    end
    
    methods
        function tracker = SAMF(im, center, target_sz)
            tracker.current_im = im;
            tracker.center = center;
            tracker.target_sz = target_sz;
            tracker.box = [ center([2 1]) - target_sz([2 1])/2, target_sz([2 1]) ];%(x,y,width,height)
            
            tracker.window_sz = target_sz * (1 + tracker.padding);
            tracker.output_sigma = sqrt(prod(target_sz)) * tracker.output_sigma_factor / tracker.hog_cell_size;
            tracker.yf = fft2(gaussian_shaped_labels(tracker.output_sigma, floor(tracker.window_sz / tracker.hog_cell_size)));
            tracker.cos_window = hann(size(tracker.yf,1)) * hann(size(tracker.yf,2))';
            
            tracker.response = zeros(size(tracker.cos_window,1),size(tracker.cos_window,2),size(tracker.search_size,2));
            
            target_sz = target_sz * tracker.search_size(tracker.szid);
            tmp_sz = (target_sz * (1 + tracker.padding));
            patch = mexResize( get_subwindow(im,center,tmp_sz), tracker.window_sz, 'auto');
            xf = fft2(get_features(patch, tracker.cos_window));% appearance model
            kf = gaussian_correlation(xf, xf, tracker.kernel_sigma);
            alphaf = tracker.yf ./ (kf + tracker.lambda);   %equation for fast training
            tracker.model_xf = xf;
            tracker.model_alphaf = alphaf;
        end
        
        function box = track(self, im)
            self.current_im = im;
            for i=1:size(self.search_size,2)
                tmp_sz = (self.target_sz * (1 + self.padding)) * self.search_size(i);
                patch = mexResize( get_subwindow(im,self.center,tmp_sz), self.window_sz, 'auto');
                zf = fft2(get_features(patch, self.cos_window));
                kzf = gaussian_correlation(zf, self.model_xf, self.kernel_sigma);
                self.response(:,:,i) = real(ifft2(self.model_alphaf .* kzf));  %equation for fast detection
            end
            [vert_delta,tmp, horiz_delta] = find(self.response == max(self.response(:)), 1);
            
            self.szid = floor((tmp-1)/(size(self.cos_window,2)))+1;
            
            horiz_delta = tmp - ((self.szid -1)* size(self.cos_window,2));
            if vert_delta > size(zf,1) / 2,  %wrap around to negative half-space of vertical axis
                vert_delta = vert_delta - size(zf,1);
            end
            if horiz_delta > size(zf,2) / 2,  %same for horizontal axis
                horiz_delta = horiz_delta - size(zf,2);
            end
            
            tmp_sz = floor((self.target_sz * (1 + self.padding))*self.search_size(self.szid));
            current_size = tmp_sz(2)/self.window_sz(2);
            self.center = self.center + current_size * self.hog_cell_size * [vert_delta - 1, horiz_delta - 1];
            self.target_sz = self.target_sz * self.search_size(self.szid);
            position = self.center([2 1]) - self.target_sz([2 1])/2;
            box = [position, self.target_sz([2 1])];
            self.box=box;
        end
        
        function update(self)           
            tmp_sz = (self.target_sz * (1 + self.padding));
            patch = mexResize( get_subwindow(self.current_im,self.center,tmp_sz), self.window_sz, 'auto');
            xf = fft2(get_features(patch, self.cos_window));% appearance model
            kf = gaussian_correlation(xf, xf, self.kernel_sigma);
            alphaf = self.yf ./ (kf + self.lambda);   %equation for fast training
            
            self.model_alphaf = (1 - self.interp_factor) * self.model_alphaf + self.interp_factor * alphaf;
            self.model_xf = (1 - self.interp_factor) * self.model_xf + self.interp_factor * xf;
         
        end
    end
end
