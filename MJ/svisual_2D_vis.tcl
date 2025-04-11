#setdep @node|sdevice@

# make full Tcl library available
set tcl_library "${::env(SENTAURUS)}/../tcad/current/lib/tcl8.6"
source [file join [info library] init.tcl]

set dataset n@node|sdevice@BnddgmJsc_des

load_file ${dataset}.tdr
set plot0 [create_plot -dataset ${dataset}]

set regions [list_regions]
echo $regions

set_axis_prop -axis x -title "X" -show_title -range {0 10} -scale_font_factor 1
set_axis_prop -axis y -title "Y" -show_title -range {0 10} -scale_font_factor 1
set_plot_prop -hide_legend -hide_title

set_region_prop $regions -hide_field -hide_mesh
set_region_prop [list JunctionLine DepletionRegion cathode anode] -hide_all


set plot1 [create_plot -dataset ${dataset}]
set_axis_prop -axis x -title "X" -show_title -range {2.1 2.5} -scale_font_factor 1
set_axis_prop -axis y -title "Y" -show_title -range {0 0.7} -scale_font_factor 1
set_plot_prop -hide_legend -hide_title


# draw rectangle on plot1 showing range of plot2
set rx [get_axis_prop -axis x -range]
set ry [get_axis_prop -axis y -range]
set p1x [lindex $rx 0]
set p1y [lindex $ry 0] 
set p2x [lindex $rx 1]
set p2y [lindex $ry 1]

set_material_prop -plot $plot0 [ list GaInP ] -color "#348ABD" -translucency_on -translucency_level 0.4
#set_material_prop -plot $plot0 [ list GaAs ] -color "#7A68A6" -translucency_on -translucency_level 0.4
#set_material_prop -plot $plot0 [ list InGaAs ] -color "#A60628" -translucency_on -translucency_level 0.4
set_material_prop -plot $plot1 [ list GaInP ] -color "#348ABD" -translucency_on -translucency_level 0.4
##set_material_prop -plot $plot1 [ list GaAs ] -color "#7A68A6" -translucency_on -translucency_level 0.4
#set_material_prop -plot $plot1 [ list InGaAs ] -color "#A60628" -translucency_on -translucency_level 0.4

set_region_prop $regions -hide_field -show_mesh
set_region_prop [list JunctionLine DepletionRegion cathode anode] -hide_all



