classdef KCF < handle
    properties (SetAccess = private)
        interp_factor=0.02;
        
        kernel_sigma=0.5;
        
        padding=1.5;
        lambda=1e-4;
        output_sigma_factor=0.1;
        output_sigma;
        
        hog_cell_size = 4;
        hog_orientations = 9;
        
        center;
        target_sz;
        box;
        
        window_sz;
        cos_window;
        
        yf;
        
        model_xf;
        model_alphaf;
        
        current_im;
    end
    
    methods
        function tracker=KCF(im, center, target_sz)
            if size(im,3) > 1
                im = rgb2gray(im);
            end
            tracker.center = center;%(y,x)
            tracker.target_sz = target_sz;%(ys,xs)
            tracker.box = [ center([2 1]) - target_sz([2 1])/2, target_sz([2 1]) ];%(x,y,width,height)
            
            tracker.window_sz = floor(target_sz * (1 + tracker.padding));
            
            tracker.output_sigma = sqrt(prod(tracker.target_sz)) * tracker.output_sigma_factor / tracker.hog_cell_size;
            tracker.yf = single( fft2(gaussian_shaped_labels(tracker.output_sigma, tracker.window_sz / tracker.hog_cell_size) ) );%constant
            
            tracker.cos_window = hann(size(tracker.yf,1)) * hann(size(tracker.yf,2))';%constant
            
            patch = KCF_get_subwindow(im, tracker.center, tracker.window_sz);
            xf = fft2(KCF_get_features(patch, tracker.cos_window));
            tracker.model_xf = xf;
            
            %calculate response of the classifier at all shifts
            kf = gaussian_correlation(xf, xf, tracker.kernel_sigma);
            %kf = linear_correlation(xf, xf);
            alphaf = tracker.yf ./ (kf + tracker.lambda);   %equation for fast training
            tracker.model_alphaf = alphaf;
        end
        
        function [box, response] = track(self, im)
            if size(im,3) > 1
                im = rgb2gray(im);
            end
            self.current_im = im;
            
            patch = KCF_get_subwindow(im, self.center, self.window_sz);
            zf = fft2( KCF_get_features(patch, self.cos_window) );
            kzf = gaussian_correlation(zf, self.model_xf, self.kernel_sigma);
            %kzf = linear_correlation(zf, self.model_xf);
            response = real( ifft2(self.model_alphaf .* kzf) );  %equation for fast detection. Equation (22)
            
            [vert_delta, horiz_delta] = find( response == max( response(:) ), 1 );
            if vert_delta > size(zf,1) / 2  %wrap around to negative half-space of vertical axis
                vert_delta = vert_delta - size(zf,1);
            end
            if horiz_delta > size(zf,2) / 2  %same for horizontal axis
                horiz_delta = horiz_delta - size(zf,2);
            end
            self.center = self.center + self.hog_cell_size * [vert_delta - 1, horiz_delta - 1];
            
            position = self.center([2 1]) - self.target_sz([2 1])/2;
            box = [position, self.target_sz([2 1])];
            self.box = box;
        end
        
        function update(self)
            %obtain a subwindow for training at newly estimated target position
            patch = KCF_get_subwindow(self.current_im, self.center, self.window_sz);%not target_sz
            xf = fft2( KCF_get_features(patch, self.cos_window) ); % base sample vector x_hat
            self.model_xf = (1 - self.interp_factor) * self.model_xf + self.interp_factor * xf;
            
            % Calc auto-correlation of signal x_hat (in Fourier domain)
            kf = gaussian_correlation(xf, xf, self.kernel_sigma); % Using Equation (30)
            %kf = linear_correlation(xf, xf);
            alphaf = self.yf ./ (kf + self.lambda);   %equation for fast training. Equation (17). yf is constant(regression target).
            self.model_alphaf = (1 - self.interp_factor) * self.model_alphaf + self.interp_factor * alphaf;
        end
    end
end