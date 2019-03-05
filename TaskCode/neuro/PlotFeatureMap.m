function PlotFeatureMap(ax,feature_vec,ch_layout,ttl_str)

% put feature_vec into mtrx according to ch_layout
Nch = max(ch_layout(:)); % channels
plot_mtrx = nan(size(ch_layout));
for ch=1:Nch,
    [r,c] = find(ch_layout == ch);
    plot_mtrx(r,c) = feature_vec(ch);  
end

% plot
imagesc(ax,plot_mtrx);
if exist('ttl_str','var'),
    title(ax,ttl_str);
end
drawnow;

end