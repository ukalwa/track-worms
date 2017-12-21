function [ figure1 ] = plot_curvature( plotting_data, end_effects, tmin, tmax, gray_scale )
%PLOT_CURVATURE draws a heat map for the plotting data

%% Handles setting up the tmin and tmax values

	if(~tmin)
		tmin = 1;
	end

	if(~tmax)
	   tmax = size(plotting_data,1);
	end
	figure1 = figure(1);
	ax = gca;
	color_array = [0 0 1;0 1 1; 1 1 0; 1 0 0];
	if gray_scale
		c = transpose(linspace(0,1,10))*[1,1,1];
	else
		c = new_colormap(color_array,10);
	end
	colormap(c);
	if(size(plotting_data,2)>1)
		if(end_effects)
			pcolor(fix(size(plotting_data,2)*.1):size(plotting_data,2)-...
				fix(size(plotting_data,2)*.1),tmin:tmax,...
				plotting_data(tmin:tmax,fix(size(plotting_data,2)*.1):...
				size(plotting_data,2)-fix(size(plotting_data,2)*.1)));
			xlabel('Skeletal body coordinate, 10 - 90%');
		else
			hand = pcolor(tmin:tmax,1:size(plotting_data,2),transpose(plotting_data(tmin:tmax,:)));
			shading interp;
			set(hand, 'linestyle', 'none');
			set(ax,'Ydir','reverse');
			xlabel('Time (seconds)');
		end
		ylabel('Body coordinate, I/L');
		h = colorbar;
		set(h, 'ylim', [-0.04 0.05])
	else
		plot(transpose(plotting_data(tmin:tmax,:)));
		
		ylabel('Curvature value');
		
	end

