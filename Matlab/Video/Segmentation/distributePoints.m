function [ newPoints ] = distributePoints( points, N, mult )
% This function does a cubic spline interpolation of the given points 
% and extract new points from the smoothened curve
	if(mult==1)
		sy = points(1:end,1);
		sx = points(1:end,2);
	else
		sy = transpose(spline(1:size(points,1),transpose(points(1:end,1)),1:1/mult:size(points,1)));
		sx = transpose(spline(1:size(points,1),transpose(points(1:end,2)),1:1/mult:size(points,1)));
	end

	D = zeros(length(sy),1);
	for i = 2:length(sy)
		D(i,1) = D(i-1,1) + sqrt((sy(i-1)-sy(i))^2+(sx(i-1)-sx(i))^2);
	end

	d = D(end,1)/(N-1);

	newPoints = zeros(N,2);

	for i = 1:N
		t = abs(D-d*(i-1));
		[~,ind] = min(t);

		newPoints(i,1) = sy(ind,1);
		newPoints(i,2) = sx(ind,1);
	end

end

