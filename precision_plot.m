function precisions = precision_plot(seqName,positions, ground_truth)
%PRECISION_PLOT
%   Calculates precision for a series of distance thresholds (percentage of
%   frames where the distance to the ground truth is within the threshold).
%   The results are shown in a new figure if SHOW is true.
%
%   Accepts positions and ground truth as Nx2 matrices (for N frames), and
%   a title string.
%
%   Joao F. Henriques, 2014
%   http://www.isr.uc.pt/~henriques/

	
	max_threshold = 50;  %used for graphs in the paper	
	precisions = zeros(max_threshold, 1);
	
	if size(positions,1) ~= size(ground_truth,1)	
		%just ignore any extra frames, in either results or ground truth
		n = min(size(positions,1), size(ground_truth,1));
		positions(n+1:end,:) = [];
		ground_truth(n+1:end,:) = [];
	end
	
	%calculate distances to ground truth over all frames
	distances = sqrt((positions(:,1) - ground_truth(:,1)).^2 + ...
				 	 (positions(:,2) - ground_truth(:,2)).^2);
	distances(isnan(distances)) = [];

	%compute precisions
	for p = 1:max_threshold,
		precisions(p) = nnz(distances <= p) / numel(distances);
	end
	%AUC=trapz(1:50,precisions)/50;
    
	%plot the precisions
%     plotName=['Precisions - ' seqName];
%     figure('Name',plotName)
%     plot(precisions, 'k-', 'LineWidth',2)
%     plotTitle=['SeqName: ' seqName ', Precision(20): ' num2str(precisions(20))];
%     title(plotTitle);
%     xlabel('Threshold'), ylabel('Precision')	
	
end

