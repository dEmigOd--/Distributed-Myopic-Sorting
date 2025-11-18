function [patch_length, patch_width] = GetPatchSizes(length, width, bordersize)
    patch_length = length + 2 * bordersize;
    patch_width = width + 2 * bordersize;
end
