function [ ] = ShowMemoryMap( hAxis, memory, params )
	%SHOWMEMORYMAP depicts the "memory".
	
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
	gray = 15 / 16;
	colors = flag(2 ^ params.bits_in_coverage_algorithm);
	
	patch = zeros(vlength + 2 * bordersize, vwidth + 2 * bordersize);
	patch(bordersize+1:vlength+bordersize, bordersize+1:vwidth+bordersize) = 1;
	
	if(params.do_horizontal_traversal)
		memory = memory';
	end
	visibleState = zeros([size(memory) .* [vlength + 2 * bordersize, vwidth + 2 * bordersize], 3]);
	
	for colorchannel = 1:3
		visibleState(:,:,colorchannel) = kron(reshape(colors(2 ^ params.bits_in_coverage_algorithm + 1 - (memory + 1), colorchannel), params.n, params.m), patch);
	end
	
	background = ones([size(memory) .* [vlength + 2 * bordersize, vwidth + 2 * bordersize], 3]);
	for layer = 1:3
		background(:, :, layer) = gray * kron(ones(size(memory)), 1 - patch);
	end
	%visibleState = 1 - visibleState;
	imshow(visibleState + background, 'Parent', hAxis);
	title('Agents'' memory map');
	%legend
end
