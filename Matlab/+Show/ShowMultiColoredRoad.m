function [ ] = ShowMultiColoredRoad( hAxis, state, params )
	%SHOWROAD depict the "road".
	
	% basic size
	vlength_basic = params.vehicle_length;
	vwidth_basic = params.vehicle_width;
	bordersize_basic = 1;
	% sizes
	zoom_value = params.zoom_value;
	vlength = vlength_basic * zoom_value;
	vwidth = vwidth_basic * zoom_value;
	bordersize = bordersize_basic * zoom_value;
	% get colors
	colors = parula(2 + max(max(state)));
	colors(1:2, :) = [params.color_continue'; 0,0,0];
	
	patch = zeros(vlength + 2 * bordersize, vwidth + 2 * bordersize);
	patch(bordersize+1:vlength+bordersize, bordersize+1:vwidth+bordersize) = 1;
	
	if(params.do_horizontal_traversal)
		state = state';
	end
	visibleState = zeros([size(state) .* [vlength + 2 * bordersize, vwidth + 2 * bordersize], 3]);
	
	for colorchannel = 1:3
		visibleState(:,:,colorchannel) = kron(reshape(colors(state + 2, colorchannel), params.n, params.m), patch);
	end
	
	visibleState = 1 - visibleState;
	imshow(visibleState, 'Parent', hAxis);
end
