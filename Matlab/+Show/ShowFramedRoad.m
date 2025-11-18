function [ ] = ShowFramedRoad( hAxis, state, frame_sizes, params )
    Show.ShowRoad(hAxis, state, params);
    
    if(params.draw_frame)
        % basic size
        vlength_basic = params.vehicle_length;
        vwidth_basic = params.vehicle_width;
        bordersize_basic = 1;
        % sizes
        zoom_value = params.zoom_value;
        vlength = vlength_basic * zoom_value;
        vwidth = vwidth_basic * zoom_value;
        bordersize = bordersize_basic * zoom_value;

        [patch_length, patch_width] = Show.GetPatchSizes(vlength, vwidth, bordersize);

        axis_sizes = getpixelposition(hAxis);
        line_width = axis_sizes(4) / (10 * size(state, 1));
        hold on;
            accumulated_height = 0;
            for i = 1:size(frame_sizes, 1)
                if(i > 1)
                    yline(hAxis, accumulated_height * patch_length, 'b', 'LineWidth', line_width);
                end
                accumulated_height = accumulated_height + frame_sizes(i);
                %yline(accumulated_height * patch_length, 'b', 'LineWidth', zoom_value / 3);            
            end
        hold off;
    end
end
