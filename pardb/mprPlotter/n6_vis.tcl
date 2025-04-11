



create_plot -1d


load_file Lumb_BSR.csv -name TargDataset
create_curve -name Targ -dataset TargDataset -axisX x -axisY y
set_curve_prop Targ -label "Targ" -color blue -hide_line -show_markers -markers_size 10 -markers_type diamondf

load_file SimData.csv -name SimDataset
create_curve -name Sim -dataset SimDataset -axisX x -axisY y
set_curve_prop Sim -label "Sim" -color red -show_line -hide_markers -line_style solid \
		-line_width 3 



set_axis_prop -axis x -title {Variable} -title_font_size 16 -scale_font_size 14 -type log 
set_axis_prop -axis y -title {Output} \
	-title_font_size 16 -scale_font_size 14 -min 0.0 -max 1.0




