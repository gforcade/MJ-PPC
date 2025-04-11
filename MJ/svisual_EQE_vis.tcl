#setdep @node|EQE@

#To choose what to compare
#eSim_type: EQE, IQE, RS 


!( global wstart, wend, wsteps, intensity )!




# use maximum floating point precision
set tcl_precision 17

# make full Tcl library available
###set tcl_library "${::env(SENTAURUS)}/../tcad/current/lib/tcl8.6"
source [file join [info library] init.tcl]
source @pwd@/../lib/PhysicalConstants.tcl
source @pwd@/../lib/colorGradient.tcl

# load the interpolation package
package require math::interpolate
package require math::calculus

set eqedataset @pwd@/results/nodes/@node|EQE@/n@node|EQE@_des

#initializing plots
if { [info exists QEplot ] == 0 } {
set QEplot [create_plot -name P1 -1d]
set_axis_prop -plot P1 -axis x -title "Wavelength (<greek>m</greek>m)" -range {@wstart@ @wend@} -title_font_size 20 -scale_font_size 20
set_axis_prop -plot P1 -axis y -title "EQE"  -range [list 0.0 1.0] -title_font_size 20 -scale_font_size 20
set_axis_prop -plot P1 -axis y2 -title "Intensity"  -range [list 0.0 1.6] -title_font_size 20 -scale_font_size 20
set_legend_prop -location top_right -label_font_size 15
}

if { [info exists IQEplot ] == 0 } {
set IQEplot [create_plot -name P2 -1d]
set_axis_prop -plot P2 -axis x -title "Wavelength (<greek>m</greek>m)" -range {@wstart@ @wend@} -title_font_size 20 -scale_font_size 20
set_axis_prop -plot P2 -axis y -title "IQE"  -range [list 0.0 1.0] -title_font_size 20 -scale_font_size 20
set_axis_prop -plot P2 -axis y2 -title "Intensity"  -range [list 0.0 1.6] -title_font_size 20 -scale_font_size 20
set_legend_prop -location top_right -label_font_size 15
set_plot_prop -plot P2 -hide_legend
}

if { [info exists Rplot ] == 0 } {
set Rplot [create_plot -name P3 -1d]
set_axis_prop -plot P3 -axis x -title "Wavelength (<greek>m</greek>m)" -range {@wstart@ @wend@} -title_font_size 20 -scale_font_size 20
set_axis_prop -plot P3 -axis y -title "R"  -range [list 0.0 1.0] -title_font_size 20 -scale_font_size 20
set_axis_prop -plot P3 -axis y2 -title "Intensity"  -range [list 0.0 1.6] -title_font_size 20 -scale_font_size 20
set_legend_prop -location top_right -label_font_size 15
set_plot_prop -plot P3 -hide_legend
}

#plot names for the for loop
set plots {P1 P2 P3}
set plotNames {"EQE" "IQE" "RS"}





## colors of curves
proc getColor {} {
	if { [info exists ::colorindex] == 0} { set ::colorindex -1 }
	## gradient r g b darken. r,g,b 0-255. darken -1 to 1 for black to white
	###set plot_colors [list [gradient 255 0 0 0.0] "#44546A" "#348abd" "#a60628" "#7a68a6" "#467821" "#F79646" "#4BACC6" "#A2CD85"]
	set plot_colors [list "blue" "cyan" "#00ff00" "red"]
	
	

	if { $::colorindex < [expr [ llength $plot_colors] -1] } {
		incr ::colorindex
	} else {
		set ::colorindex -1 
	}
	return [lindex $plot_colors $::colorindex]
}

proc getColor_v2 {dim init} {
	if { [info exists ::colorindex] == 0} { set ::colorindex $init }
	if { [info exists ::dimNew] == 0} { set ::dimNew -1 }
	## gradient r g b darken. r,g,b 0-255. darken -1 to 1 for black to white
	set plot_colors_r [list 255 0 "#44546A" "#348abd" "#a60628" "#7a68a6" "#467821" "#F79646" "#4BACC6" "#A2CD85"]
	set plot_colors_g [list 0 255 "#44546A" "#348abd" "#a60628" "#7a68a6" "#467821" "#F79646" "#4BACC6" "#A2CD85"]
	set plot_colors_b [list 0 0 "#44546A" "#348abd" "#a60628" "#7a68a6" "#467821" "#F79646" "#4BACC6" "#A2CD85"]
	
	

	if { $::dimNew < [expr [ llength $plot_colors_r] -1] } {
		if { $::dimNew < [expr $dim -1]  } {
			incr ::dimNew
		} else {	
			set ::colorindex [expr {$::colorindex - 0.25}]
			set ::dimNew 0
		}
	} else {
		set ::dimNew 0 
	}
	return [gradient [lindex $plot_colors_r $::dimNew] [lindex $plot_colors_g $::dimNew] [lindex $plot_colors_b $::dimNew] $::colorindex]
}

## set the color order. v2,  Input: # of colors to use, initial color shading

set color [getColor ]


# load dataset
set ds [load_file ${eqedataset}.plt]

# load measured data
set dsMeas [load_file @pwd@/../Measurements/@measQEData@]
set wlname_meas "wavelength"


#global variables
set wlname "Device=,File=CommandFile/Physics,DefaultRegionPhysics,ModelParameter=Optics/Excitation/Wavelength"
set iname "Device=,File=CommandFile/Physics,DefaultRegionPhysics,ModelParameter=Optics/Excitation/Intensity"




# create curves
for {set plt 0} {$plt < 3} {incr plt} {

create_curve -plot [lindex $plots $plt] -name wl -dataset $ds -axisX $wlname -axisY $wlname

create_curve -plot [lindex $plots $plt] -name R1_@node@  -dataset $ds -axisX $wlname -axisY "LayerStack(W1) R_Total"
create_curve -plot [lindex $plots $plt] -name T_@node@  -dataset $ds -axisX $wlname -axisY "LayerStack(W1) T_Total"

create_curve -plot [lindex $plots $plt] -name J_cathode  -dataset $ds -axisX $wlname -axisY "cathode TotalCurrent"

##if {[info exists runVisualizerNodesTogether]} {
if {[lsearch [list_curves meas_] "meas_@measQEData@"] == -1} {
create_curve -plot [lindex $plots $plt] -name meas_@measQEData@ -dataset $dsMeas -axisX $wlname_meas -axisY [lindex $plotNames $plt]
set_curve_prop meas_@measQEData@ -plot [lindex $plots $plt] -label "Measured" -show_markers -markers_type diamond -color black -hide_line -markers_size 10
}
##}

create_curve -plot [lindex $plots $plt] -name J1 -function "<J_cathode>"


#if @wfrontc@ == 0.0
set FT @<1.0+Rfactor>@
#else
set FT @<(wtot-wfrontc)/wtot*(1.0+Rfactor)>@
#endif

# Contact reflectivity: 0 assumes no contact reflection. 1 assumes 100% contact reflection + collection (for measurements)
set R_cont 0.0


create_curve -plot [lindex $plots $plt] -name EQE_@node@ -function "($::h*$::c/$::q)*<J1>*$FT/(<wl>*1e-6*@intensity@)"
create_curve -plot [lindex $plots $plt] -name R_@node@ -function "$FT*<R1_@node@>+$R_cont*(1.0-$FT)"
create_curve -plot [lindex $plots $plt] -name IQE_@node@ -function "<EQE_@node@>/(1.0-<R_@node@>)"



if {[info exists runVisualizerNodesTogether]} {
set lineWidth 4
set_curve_prop -plot [lindex $plots $plt] EQE_@node@ -label "Simulation $leg" -show_markers -markers_type circle -color $color -line_width $lineWidth
set_curve_prop -plot [lindex $plots $plt] IQE_@node@ -label "IQE $leg" -show_markers -markers_type cross -color $color -line_style dash -line_width $lineWidth
set_curve_prop -plot [lindex $plots $plt] R_@node@ -label "Reflectivity $leg" -show_markers -markers_type plus -color $color -line_width $lineWidth
#set_curve_prop T_@node@ -label "Transmissivity" -show_markers -markers_type plus -color olive
}



##export_curves -plot [lindex $plots $plt] -filename EQE.csv {EQE_@node@} -overwrite
##export_curves -plot [lindex $plots $plt] -filename IQE.csv {IQE_@node@} -overwrite
##export_curves -plot [lindex $plots $plt] -filename RS.csv {R_@node@} -overwrite
##export_curves -plot [lindex $plots $plt] -filename T.csv {T_@node@} -overwrite




#end loop
}




remove_curves -plot P1 [ list J1 wl J_cathode R1_@node@ T_@node@ R_@node@ IQE_@node@ ]
remove_curves -plot P2 [ list J1 wl J_cathode R1_@node@ T_@node@ EQE_@node@ R_@node@]
remove_curves -plot P3 [ list J1 wl J_cathode R1_@node@ T_@node@ EQE_@node@ IQE_@node@]

for {set plt 0} {$plt < 3} {incr plt} {

set_axis_prop -plot [lindex $plots $plt] -axis y -range [list 0.0 1.0]
set_axis_prop -plot [lindex $plots $plt] -axis x -range [list @wstart@ @wend@]

}

export_variables -dataset $ds -filename data.csv -overwrite


### get device name
set IVmeasName [split @measIVData@ "/"]
set deviceName [lindex $IVmeasName 2]

if {[lindex $IVmeasName 1] == "dark" } {

export_curves -plot P1 -filename @pwd@/SimVsMeas/EQE_${deviceName} -overwrite
export_curves -plot P2 -filename @pwd@/SimVsMeas/IQE_${deviceName} -overwrite
export_curves -plot P3 -filename @pwd@/SimVsMeas/R_${deviceName} -overwrite

}

