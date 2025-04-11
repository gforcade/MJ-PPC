#setdep @node|JV@

# makes JV curve, Jx/Jph, and Jx vs V plots

#if "@eSim_type@" == "IV"

# use maximum floating point precision
set tcl_precision 17

# make full Tcl library available
###set tcl_library "${::env(SENTAURUS)}/../tcad/current/lib/tcl8.6"
source [file join [info library] init.tcl]
source @pwd@/../lib/PhysicalConstants.tcl

# load the interpolation package
package require math::interpolate


set GentoA_av [expr 1e-4*$::q/@wtot@/@numSegments@]
set GentoA [expr 1e-4*$::q/@wtot@]
set dsVoltage "anode OuterVoltage"


set filename @[relpath n@node|JV@_des.plt]@

# create a plot if it doesn't already exist.  if several svisual nodes are run together,
# this section will only run for the first one, and curves from all nodes will be plotted together.
if {[info exists JVplot] == 0 } {
	set max_j 0.0
	set min_j 0.0
	
	#plot1
	set JVplot [create_plot -name P1 -1d]
	set_axis_prop -plot P1 -axis x -title "Bias Voltage (V)" -title_font_size 20 -scale_font_size 20
	if { @Pin@ == 0.0 } {
	 set_legend_prop -location top_left
	} else {
	 set_legend_prop -location bottom_left
	 set_axis_prop -plot P1 -axis y -min 0.0 -min_fixed
	}
	
	#plot2
	create_plot -name P2 -1d
	set_axis_prop -plot P2 -axis y -title "IRE" -title_font_size 20 -scale_font_size 20 -min 0.0 -min_fixed -max 1.0 -max_fixed
 	set_axis_prop -plot P2 -axis x -title "Voltage (V)"  -title_font_size 20 -scale_font_size 20
	
	#plot3
	set JVplot [create_plot -name P3 -1d]
	set_axis_prop -plot P3 -axis x -title "Voltage (V)"  -title_font_size 20 -scale_font_size 20


	#plot4
	set JVplot [create_plot -name P4 -1d]
	set_axis_prop -plot P4 -axis x -title "Voltage (V)"  -title_font_size 20 -scale_font_size 20

}


# load dataset.
set ds [load_file $filename]



select_plots {P1}


## plot measured data
#if "@sim_type@" == "fitOptimize"
set dsMeas [load_file @pwd@/../Measurements/@measIVData@]
if {[lsearch [list_curves meas_] "meas_@measIVData@"] == -1} {
set dsMeas_old $dsMeas
###set sim_color [get_curve_prop J_n@node@ -color]
set sim_color "black"
create_curve -plot P1 -name meas_@measIVData@ -dataset $dsMeas -axisX "Voltage(V)" -axisY "CurrentDensity(A/cm^2)"
set_curve_prop meas_@measIVData@ -plot P1 -label "Measured" -show_markers -markers_type diamond -color $sim_color -hide_line -markers_size 10
create_curve -plot P3 -name meas_@measIVData@ -dataset $dsMeas -axisX "Voltage(V)" -axisY "CurrentDensity(A/cm^2)"
set_curve_prop meas_@measIVData@ -plot P3 -label "Measured" -show_markers -markers_type diamond -color $sim_color -hide_line -markers_size 10
}
#endif


# create J-V curve
## post process series resistance
 create_variable -dataset $ds -function {<anode OuterVoltage:n@node|JV@_des>+<anode TotalCurrent:n@node|JV@_des>*@Rseries@} -name Voltage_w_Rseries
create_curve -name J0 -plot P1 -dataset $ds -axisX "Voltage_w_Rseries" -axisY "anode TotalCurrent"
create_curve -name V -plot P1 -dataset $ds -axisX "Voltage_w_Rseries" -axisY "Voltage_w_Rseries"
create_curve -name J_n@node@ -plot P1 -function "-<J0> - <V>/@Rshunt@"


# add Jph curves for each subcell
#if 1 == 0
!(
puts "set rmC \[list \]"
for { set i 1 } { $i < @<numSegments+1>@ } { incr i } {
if { (@seg1_em2_t@ > 0.0 && $i == 1) || (@seg2_em2_t@ > 0.0 && $i == 2) } {
puts "create_curve -name OptGen${i}_@node@ -plot P1 -dataset \$ds -axisX \$dsVoltage -axisY \"Integrsc${i}_emsc${i}_em2 OpticalGeneration\""
#if "@LC@" == "on"
puts "create_curve -name LC${i}_@node@ -plot P1 -dataset \$ds -axisX \$dsVoltage -axisY \"Integrsc${i}_emsc${i}_em2 PMIeNonLocalRecombination\""
puts "create_curve -name Rad${i}_@node@ -plot P1 -dataset \$ds -axisX \$dsVoltage -axisY \"Integrsc${i}_emsc${i}_em2 RadiativeRecombination\""
#endif
} else {
puts "create_curve -name OptGen${i}_@node@ -plot P1 -dataset \$ds -axisX \$dsVoltage -axisY \"Integrsc${i}_em OpticalGeneration\""
#if "@LC@" == "on"
puts "create_curve -name LC${i}_@node@ -plot P1 -dataset \$ds -axisX \$dsVoltage -axisY \"Integrsc${i}_em PMIeNonLocalRecombination\""
puts "create_curve -name Rad${i}_@node@ -plot P1 -dataset \$ds -axisX \$dsVoltage -axisY \"Integrsc${i}_em RadiativeRecombination\""
#endif
}
#if "@LC@" == "on"
if {$i > 10 } {
puts "create_curve -name oldJph${i}_@node@ -plot P1 -function \"(<OptGen${i}_@node@>)*\$GentoA*@numSegments@\""
} else {
puts "create_curve -name oldJph${i}_@node@ -plot P1 -function \"(<OptGen${i}_@node@> - <LC${i}_@node@> )*\$GentoA*@numSegments@\""
}
puts "create_curve -name Jph${i}_@node@ -plot P1 -function \"vecvaly(<oldJph${i}_@node@>,0)*<meas_@measIVData@>/<meas_@measIVData@>\""
#else
puts "create_curve -name Jph${i}_@node@ -plot P1 -function \"<OptGen${i}_@node@>*\$GentoA*@numSegments@\""
#endif
puts "set_curve_prop -plot P1 Jph${i}_@node@ -label \"Jph${i}\" -show_line -line_style solid -line_width 2" 
puts "lappend rmC OptGen${i}_@node@ LC${i}_@node@ oldJph${i}_@node@ Rad${i}_@node@"  
}
)!
remove_curves -plot P1 $rmC
#endif

if {[info exists runVisualizerNodesTogether]} {
set_curve_prop -plot P1 J_n@node@ -label "J $leg" -show_markers -markers_type plus -show_line -line_style solid -line_width 3 -markers_size 3
}

##set sim_color [get_curve_prop J_n@node@ -color]


# create Power and dP/dV curves
create_curve -plot P1 -name P -function "<J_n@node@>*<V>"
create_curve -plot P1 -name dPdV -function "diff(<P>)"


# Extract J-V metrics for display in Sentaurus Workbench tree view.  Not applicable to dark-current curves.
# We use two different interpolation methods.  ::math::interpolate uses cubic spline interpolation, so is more accurate 
# but requires x-values to be strictly increasing.  
# ::ext::ExtractValue uses linear interpolation but does not require x values to be increasing.

#if 1 == 0
if { @Pin@ > 0.0 } {

# 1. Get Jsc by cubic interpolation of J-V curve.
set coeffs [::math::interpolate::prepare-cubic-splines [get_curve_data J_n@node@ -axisX] [get_curve_data J_n@node@ -axisY]]
set Jsc    [::math::interpolate::interp-cubic-splines $coeffs 0.0]
puts "DOE: Jsc [format %0.5f $Jsc]"

# QE assuming equal absorption for all layers
set QE [expr $Jsc/(@Pin@/(1.24/1.55))*@numSegments@*100.0]
puts "DOE: QE [format %0.4f $QE]"

# 2. Get Voc by interpolation at J=0.
::ext::ExtractValue out= Voc name= noprint x= [get_curve_data J_n@node@ -axisY] y= [get_curve_data J_n@node@ -axisX] xo= 0.0
puts "DOE: Voc [format %0.4f $Voc]"

# 3. Find maximum power point voltage by interpolating point where dP/dV = 0
::ext::ExtractValue out= MPPV name= noprint x= [get_curve_data dPdV -axisY] y= [get_curve_data dPdV -axisX] xo= 0.0
puts "MPPV $MPPV"

# 4. Get max power by cubic interpolation of power curve at V = MPPV
set coeffs [::math::interpolate::prepare-cubic-splines [get_curve_data P -axisX] [get_curve_data P -axisY]]
set Pm   [::math::interpolate::interp-cubic-splines $coeffs $MPPV]

# 5. Get current density by cubic interpolation at V = MPPV
set coeffs [::math::interpolate::prepare-cubic-splines [get_curve_data J_n@node@ -axisX] [get_curve_data J_n@node@ -axisY]]
set MPPJ   [::math::interpolate::interp-cubic-splines $coeffs $MPPV]
puts "MPPJ $MPPJ"

set FF [expr $Pm*100.0/($Voc*$Jsc)]
set Eff [expr $Pm*100.0/@Pin@]

# output metrics for use by Sentaurus Workbench.
puts "DOE: FF [format %0.4f $FF]"
puts "DOE: Eff [format %0.5f $Eff]"

# plot markers at Jsc, Voc and max power operating points.
#create_variable -name xpoints_n@node@ -dataset a  -values [list 0.0 $MPPV $Voc ]
#create_variable -name ypoints_n@node@ -dataset a  -values [list $Jsc $MPPJ 0.0 ]

#create_curve -plot P1 -name points_n@node@ -dataset a -axisX xpoints_n@node@ -axisY ypoints_n@node@
#set_curve_prop -plot P1 points_n@node@ -hide_line -markers_type circle -markers_size 10 -show_markers -color black -label ""

} else {

#need this for aiirmap databasing to work
puts "DOE: Jsc 0.0"
puts "DOE: QE 0.0"
puts "DOE: Voc 0.0"
puts "DOE: FF 0.0"
puts "DOE: Eff 0.0"
puts "DOE: Pm 0.0"
}
#endif

# get max and min of J-V curve
ext::ExtractExtremum out= min name= noprint x= [get_curve_data J_n@node@ -axisX] y= [get_curve_data J_n@node@ -axisY] extremum= "min"
ext::ExtractExtremum out= max name= noprint x= [get_curve_data J_n@node@ -axisX] y= [get_curve_data J_n@node@ -axisY] extremum= "max"

# find max and min of all J-V curves
if { $min < $min_j } {set min_j [expr floor($min) ]}
if { $max > $max_j } {set max_j [expr ceil($max) ]}

remove_curves -plot P1 [list J0 V P dPdV ]



#create IRE curve
create_curve -name J0_@node@ -plot P2 -dataset $ds -axisX $dsVoltage -axisY "anode TotalCurrent"
create_curve -name J_@node@ -plot P2 -function "-<J0_@node@>"
create_curve -name OptGen_@node@ -plot P2 -dataset $ds -axisX $dsVoltage -axisY "IntegrSemiconductor OpticalGeneration"
create_curve -name Jph_@node@ -plot P2 -function "<OptGen_@node@>*$GentoA_av"
create_curve -name GenRad_@node@ -plot P2 -dataset $ds -axisX $dsVoltage -axisY "IntegrSemiconductor RadiativeRecombination"
create_curve -name Jrad_@node@ -plot P2 -function "<GenRad_@node@>*$GentoA_av"
create_curve -name GenAug_@node@ -plot P2 -dataset $ds -axisX $dsVoltage -axisY "IntegrSemiconductor AugerRecombination"
create_curve -name Jaug_@node@ -plot P2 -function "<GenAug_@node@>*$GentoA_av"
create_curve -name GenSRH_@node@ -plot P2 -dataset $ds -axisX $dsVoltage -axisY "IntegrSemiconductor srhRecombination"
create_curve -name JSRH_@node@ -plot P2 -function "<GenSRH_@node@>*$GentoA_av"
create_curve -name Gen_@node@  -plot P2 -dataset $ds -axisX $dsVoltage -axisY "IntegrSemiconductor OpticalGeneration"
create_curve -name GenT_@node@  -plot P2 -dataset $ds -axisX $dsVoltage -axisY "IntegrSemiconductor TotalRecombination"
create_curve -name Jratio_@node@ -plot P2 -function "<Jrad_@node@>/(<Jrad_@node@> + <Jaug_@node@> + <JSRH_@node@>)"


# get IRE 
::ext::ExtractValue out= IRE name= noprint x= [get_curve_data Jratio_@node@ -axisX -plot P2] y= [get_curve_data Jratio_@node@ -axisY -plot P2] xo= 0.0
puts "DOE: IRE [format %0.4f $IRE]"

set_curve_prop -plot P2 Jratio_@node@ -label "J" -show_markers -markers_type plus -line_style solid -line_width 3 


remove_curves -plot P2 [list GenRad_@node@ GenSRH_@node@ GenAug_@node@ OptGen_@node@ Gen_@node@ GenT_@node@ J_@node@ J0_@node@ Jrad_@node@ JSRH_@node@ Jaug_@node@ Jph_@node@]



#create JV curves of various recombination mechanisms
create_curve -name OptGen_@node@ -plot P3 -dataset $ds -axisX $dsVoltage -axisY "IntegrSemiconductor OpticalGeneration"
create_curve -name Jph_@node@ -plot P3 -function "<OptGen_@node@>*$GentoA_av"
create_curve -name J0_@node@ -plot P3 -dataset $ds -axisX $dsVoltage -axisY "anode TotalCurrent"
create_curve -name J_@node@ -plot P3 -function "-<J0_@node@>"
create_curve -name GenRad_@node@ -plot P3 -dataset $ds -axisX $dsVoltage -axisY "IntegrSemiconductor RadiativeRecombination"
create_curve -name Jrad_@node@ -plot P3 -function "<GenRad_@node@>*$GentoA_av"
create_curve -name GenAug_@node@ -plot P3 -dataset $ds -axisX $dsVoltage -axisY "IntegrSemiconductor AugerRecombination"
create_curve -name Jaug_@node@ -plot P3 -function "<GenAug_@node@>*$GentoA_av"
create_curve -name GenSRH_@node@ -plot P3 -dataset $ds -axisX $dsVoltage -axisY "IntegrSemiconductor srhRecombination"
create_curve -name Jsrh_@node@ -plot P3 -function "<GenSRH_@node@>*$GentoA_av"
create_curve -name GentSRH_@node@ -plot P3 -dataset $ds -axisX $dsVoltage -axisY "IntegrSemiconductor tSRHRecombination"
create_curve -name Jtsrh_@node@ -plot P3 -function "<GentSRH_@node@>*$GentoA_av"
create_curve -name GenB2B_@node@ -plot P3 -dataset $ds -axisX $dsVoltage -axisY "IntegrSemiconductor Band2BandGeneration"
create_curve -name Jb2b_@node@ -plot P3 -function "<GenB2B_@node@>*$GentoA_av"
create_curve -name GenSurfSRH_@node@ -plot P3 -dataset $ds -axisX $dsVoltage -axisY "Integr SurfaceRecombination"
create_curve -name JsSRH_@node@ -plot P3 -function "<GenSurfSRH_@node@>*$GentoA_av"


set_curve_prop -plot P3 Jaug_@node@ -label "Jaug,avg" -show_markers -markers_type squaref -show_line -line_style solid -line_width 3 
set_curve_prop -plot P3 Jrad_@node@ -label "Jrad,avg" -show_markers -markers_type diamondf -show_line -line_style solid -line_width 3 
set_curve_prop -plot P3 J_@node@ -label "J" -show_markers -markers_type circlef -line_style solid -show_line -line_width 3 
set_curve_prop -plot P3 Jsrh_@node@ -label "Jsrh,avg" -show_markers -markers_type cross -show_line -line_style solid -line_width 3 
set_curve_prop -plot P3 Jtsrh_@node@ -label "Jtsrh,avg" -show_markers -markers_type cross -show_line -line_style solid -line_width 3 
set_curve_prop -plot P3 Jb2b_@node@ -label "Jb2b,avg" -show_markers -markers_type cross -show_line -line_style solid -line_width 3 
set_curve_prop -plot P3 JsSRH_@node@ -label "Jssrh,avg" -show_markers -markers_type cross -show_line -line_style solid -line_width 3 
set_curve_prop -plot P3 Jph_@node@ -label "Jph,avg" -show_markers -markers_type plus -show_line -line_style solid -line_width 3 

if { @Pin@ == 0.0 } {
 set_axis_prop -plot P3 -axis y -title "Current Density (A/cm<sup>2</sup>)" -min 1e-10 -min_fixed -type log -title_font_size 20 -scale_font_size 20
 set_axis_prop -plot P1 -axis y -title "Current Density (A/cm<sup>2</sup>)" -type log -title_font_size 20 -scale_font_size 20
 remove_curves -plot P3 Jph_@node@
} else {
 set_axis_prop -plot P3 -axis y -title "Current Density (A/cm<sup>2</sup>)"  -min 0 -title_font_size 20 -scale_font_size 20
 set_axis_prop -plot P1 -axis y -title "Current Density (A/cm<sup>2</sup>)"  -min 0 -title_font_size 20 -scale_font_size 20
}

remove_curves -plot P3 [list GenRad_@node@ GenAug_@node@ GenSRH_@node@ GentSRH_@node@ GenB2B_@node@ OptGen_@node@ J0_@node@ GenSurfSRH_@node@]


create_curve -name J0_@node@ -plot P4 -dataset $ds -axisX $dsVoltage -axisY "anode TotalCurrent"
create_curve -name J_@node@ -plot P4 -function "-<J0_@node@>"
set_curve_prop -plot P4 J_@node@ -label "J" -show_markers -markers_type circlef -line_style solid -show_line -line_width 3 

!(
puts "set rmC \[list J0_@node@ \]"
for { set i 1 } { $i < @<numSegments+1>@ } { incr i } {
if { (@seg1_em2_t@ > 0.0 && $i == 1) || (@seg2_em2_t@ > 0.0 && $i == 2) } {
if { "@LC@" == "on"} {
puts "create_curve -name GenLC${i}_@node@ -plot P4 -dataset \$ds -axisX \$dsVoltage -axisY \"Integrsc${i}_emsc${i}_em2 PMIeNonLocalRecombination\""
}
puts "create_curve -name GenOpt${i}_@node@ -plot P4 -dataset \$ds -axisX \$dsVoltage -axisY \"Integrsc${i}_emsc${i}_em2 OpticalGeneration\""
puts "create_curve -name GenRad${i}_@node@ -plot P4 -dataset \$ds -axisX \$dsVoltage -axisY \"Integrsc${i}_emsc${i}_em2 RadiativeRecombination\""
puts "create_curve -name GenAug${i}_@node@ -plot P4 -dataset \$ds -axisX \$dsVoltage -axisY \"Integrsc${i}_emsc${i}_em2 AugerRecombination\""
puts "create_curve -name GenSRH${i}_@node@ -plot P4 -dataset \$ds -axisX \$dsVoltage -axisY \"Integrsc${i}_emsc${i}_em2 srhRecombination\""
} else {
if { "@LC@" == "on"} {
puts "create_curve -name GenLC${i}_@node@ -plot P4 -dataset \$ds -axisX \$dsVoltage -axisY \"Integrsc${i}_em PMIeNonLocalRecombination\""
}
puts "create_curve -name GenOpt${i}_@node@ -plot P4 -dataset \$ds -axisX \$dsVoltage -axisY \"Integrsc${i}_em OpticalGeneration\""
puts "create_curve -name GenRad${i}_@node@ -plot P4 -dataset \$ds -axisX \$dsVoltage -axisY \"Integrsc${i}_em RadiativeRecombination\""
puts "create_curve -name GenAug${i}_@node@ -plot P4 -dataset \$ds -axisX \$dsVoltage -axisY \"Integrsc${i}_em AugerRecombination\""
puts "create_curve -name GenSRH${i}_@node@ -plot P4 -dataset \$ds -axisX \$dsVoltage -axisY \"Integrsc${i}_em srhRecombination\""
}
if { "@LC@" == "on"} {
puts "create_curve -name JLC${i}_@node@ -plot P4 -function \"<GenLC${i}_@node@>*\$GentoA\""
puts "lappend rmC GenLC${i}_@node@"
}
puts "create_curve -name Jph${i}_@node@ -plot P4 -function \"<GenOpt${i}_@node@>*\$GentoA\""
puts "create_curve -name Jrad${i}_@node@ -plot P4 -function \"<GenRad${i}_@node@>*\$GentoA\""
puts "create_curve -name Jaug${i}_@node@ -plot P4 -function \"<GenAug${i}_@node@>*\$GentoA\""
puts "create_curve -name Jsrh${i}_@node@ -plot P4 -function \"<GenSRH${i}_@node@>*\$GentoA\""
puts "lappend rmC GenRad${i}_@node@ GenAug${i}_@node@ GenSRH${i}_@node@ GenOpt${i}_@node@"  
}
)!

remove_curves -plot P4 $rmC

### get device name
set deviceName [split @measIVData@ "/"]
set deviceName [lindex $deviceName end]

## save JV cuves
file mkdir @pwd@/SimVsMeas/
export_curves -plot P1 -filename @pwd@/SimVsMeas/JV_${deviceName} -overwrite
export_curves -plot P4 -filename @pwd@/SimVsMeas/J_${deviceName} -overwrite

#endif
