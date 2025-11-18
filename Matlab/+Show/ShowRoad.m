function [ ] = ShowRoad( hAxis, state, params )
	%SHOWROAD depict the "road".
	%let do-not-care be white, -1-s be red, and 1-s be green
	
	% basic size
	vlength_basic = params.vehicle_length;
	vwidth_basic = params.vehicle_width;
	bordersize_basic = 1;
	% sizes
	zoom_value = params.zoom_value;
	vlength = vlength_basic * zoom_value;
	vwidth = vwidth_basic * zoom_value;
	bordersize = bordersize_basic * zoom_value;
	% colors
	color_exit = params.color_exit;
	color_continue = params.color_continue;
	color_road = 0;
	
	patch_exit = FormVehiclePatchOfColor(vlength, vwidth, bordersize, color_exit, color_road);
	patch_continue = FormVehiclePatchOfColor(vlength, vwidth, bordersize, color_continue, color_road);
	
	if(params.do_horizontal_traversal)
		state.transpose();
	end
    [patch_length, patch_width] = Show.GetPatchSizes(vlength, vwidth, bordersize);
	visibleState = color_road * ones([state.sizes .* [patch_length, patch_width], 3]);
	visibleState_continue = zeros(size(visibleState));
	visibleState_exit = visibleState_continue;
	
    agent_count = size(state.agent_info, 1);
    offset_to_00_base = [1, 1];
    for agent_id=1:agent_count
        anchor_tl = ...
            uint32((state.agent_info(agent_id, 2:3) - offset_to_00_base) .* [patch_length, patch_width] + offset_to_00_base);
        anchor_br = anchor_tl + uint32([patch_length, patch_width] - [1, 1]); % not an offset
        if (state.agent_info(agent_id, 1) == params.vehicle_exit)
            visibleState_continue(anchor_tl(1):anchor_br(1), anchor_tl(2):anchor_br(2), :) = patch_exit;
        else
            visibleState_continue(anchor_tl(1):anchor_br(1), anchor_tl(2):anchor_br(2), :) = patch_continue;
        end
    end
    
% 	for colorchannel = 1:3
% 		visibleState_continue(:,:,colorchannel) = kron(state == params.vehicle_exit, patch_exit(:,:,colorchannel));
% 		visibleState_exit(:,:,colorchannel) = kron(state == params.vehicle_continue, patch_continue(:,:,colorchannel));
% 	end
	
	visibleState = 1 - (visibleState + visibleState_continue + visibleState_exit);
	imshow(visibleState, 'Parent', hAxis);
end

function [ patch ] = FormVehiclePatchOfColor(length, width, bordersize, color, colorborder)
    [patch_length, patch_width] = Show.GetPatchSizes(length, width, bordersize);
	patch = colorborder * ones(patch_length, patch_width, 3);
	for colorchannel = 1:3
		patch(bordersize + (1:length), bordersize + (1:width), colorchannel) = color(colorchannel);
	end
end
