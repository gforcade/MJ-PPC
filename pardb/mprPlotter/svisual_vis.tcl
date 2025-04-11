#----------------------------------------------------------------#
# Plot data as well as comparison/target data
#----------------------------------------------------------------#
#setdep @node|EgVsxMole@




create_plot -1d


## load and plot target data
load_file @targetFile@ -name TargDataset
create_curve -name Targ -dataset TargDataset -axisX x -axisY y
set_curve_prop Targ -label "Targ" -color blue -hide_line -show_markers -markers_size 10 -markers_type diamondf

## load and plot simulation data
load_file SimData.csv -name SimDataset
create_curve -name Sim -dataset SimDataset -axisX x -axisY y
set_curve_prop Sim -label "Sim" -color red -show_line -hide_markers -line_style solid \
		-line_width 3 



## plot details
set_axis_prop -axis x -title {Variable} -title_font_size 16 -scale_font_size 14 -type log 
set_axis_prop -axis y -title {Output} \
	-title_font_size 16 -scale_font_size 14 -min 0.0 -max 1.0



