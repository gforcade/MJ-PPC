#setdep @node|JV@

#creates recombination + band diagram + random plotter

#if "@eSim_type@" != "Jph"

#set xcut @<wtot/2.0>@
# make full Tcl library available
###set tcl_library "${::env(SENTAURUS)}/../tcad/current/lib/tcl8.6"
source [file join [info library] init.tcl]

if {@Pin@ > 0.0} {
set datasets {n@node|JV@BnddgmPoisson_des n@node|JV@BnddgmJsc_des n@node|JV@BnddgmMidV_des n@node|JV@BnddgmVoc_des }
} else {
set datasets {n@node|JV@BnddgmPoisson_des n@node|JV@BnddgmNegV_des n@node|JV@BnddgmZeroV_des n@node|JV@BnddgmMaxV_des}
}



foreach dataset $datasets {

if {[file exist @pwd@/results/nodes/@node|JV@/${dataset}.tdr] != 1} { continue }

load_file @pwd@/results/nodes/@node|JV@/${dataset}.tdr
set plot0 [create_plot -dataset ${dataset}]

# Make 1D cut and remove 2D plot
create_cutline -name C1_$dataset -plot $plot0 -type free -points {@xcut@ 0.0 0.5 @xcut@ 10.0 0.5}
remove_plots $plot0






#Make recombination plot + carrier concentration on right axis
create_plot -1d 


set_axis_prop  -axis x -title "Y Position (<greek>m</greek>m)"
create_curve -name "Auger" -dataset C1_$dataset -axisX "Y" -axisY "AugerRecombination"
create_curve -name "SRH" -dataset C1_$dataset -axisX "Y" -axisY "srhRecombination"
create_curve -name "tSRH" -dataset C1_$dataset -axisX "Y" -axisY "tSRHRecombination"
create_curve -name "Rad" -dataset C1_$dataset -axisX "Y" -axisY "RadiativeRecombination"
create_curve -name "Surf" -dataset C1_$dataset -axisX "Y" -axisY "SurfaceRecombination"
create_curve -name "TD" -dataset C1_$dataset  -axisX "Y" -axisY "eBarrierTunneling"
create_curve -name "eDensity" -dataset C1_$dataset -axisX "Y" -axisY2 "eDensity"
create_curve -name "hDensity" -dataset C1_$dataset -axisX "Y" -axisY2 "hDensity"

set_curve_prop "Auger" -label "Auger" -show_markers -line_width 3 -color Gray
set_curve_prop "SRH" -label "SRH" -show_markers -line_width 3 -color green
set_curve_prop "tSRH" -label "tSRH" -show_markers -line_width 3 -color purple
set_curve_prop "Rad" -label "Rad" -show_markers -line_width 3 -color black
set_curve_prop "Surf" -label "Surf" -show_markers -line_width 3 -color yellow
set_curve_prop "TD" -label "TD" -show_markers -line_width 3 -color cyan
set_curve_prop "eDensity" -label "eDensity" -show_markers -line_width 3 -color red
set_curve_prop "hDensity" -label "hDensity" -show_markers -line_width 3 -color blue

set_axis_prop -axis y -title "Generation-Recombination (cm<sup>-3</sup> s<sup>-1</sup>)" -type log -title_font_size 20 -scale_font_size 20 -min 1e16 -min_fixed -max 1e24 -max_fixed
set_axis_prop -axis y2 -title "Carrier concentration (cm<sup>-3</sup>)" -type log -title_font_size 20 -scale_font_size 20 -min 1e14 -min_fixed -max 1e20 -max_fixed
set_axis_prop -axis x -title "Y Position (<greek>m</greek>m)" -title_font_size 20 -scale_font_size 20
set_legend_prop -location bottom_right -label_font_size 20



#if @Pin@ > 0.0
create_curve -name "OptGen" -dataset C1_$dataset -axisX "Y" -axisY "OpticalGeneration"
set_curve_prop "OptGen" -label "OptGen" -show_markers -line_width 3 -color magenta
#endif


#if "@LC@" == "on"
 create_curve -name "LCGen" -dataset C1_$dataset -axisX "Y" -axisY "PMIeNonLocalRecombination"
set_curve_prop "LCGen" -label "LCGen" -show_markers -line_width 3 -color darkorange
#endif




## compare RCWA to TMM calculations
#if 1 == 0
set plot_TMM_RCWA [create_plot -1d ]
select_plots $plot_TMM_RCWA

## TMM
create_curve -name "OptGen" -dataset C1_$dataset -axisX "Y" -axisY "OpticalGeneration"
set_curve_prop "OptGen" -label "OptGen" -show_markers -color magenta -hide_line -markers_size 10

##RCWA 
set dsMeas [load_file @pwd@/results/nodes/@node|RCWA@/GenRate.csv]
set dsMeas_old $dsMeas
set sim_color "black"
create_curve -name "S4" -dataset $dsMeas -axisX "Depth(um)" -axisY "GenRate(cm-3s-1)"
set_curve_prop "S4" -label "RCWA" -color $sim_color -line_width 3

set_axis_prop -axis y -title "Generation Rate (cm<sup>-3</sup> s<sup>-1</sup>)" -type log -title_font_size 20 -scale_font_size 20 -min 5e21 -min_fixed -max 1e23 -max_fixed
set_axis_prop -axis x -title "Y Position (<greek>m</greek>m)" -title_font_size 20 -scale_font_size 20 
set_legend_prop -location bottom_right -label_font_size 20

#endif


# Make Band Diagram
set plot3 [create_plot -1d -dataset C1_$dataset]
select_plots $plot3

create_curve -name "Ev" -dataset C1_$dataset -axisX "Y" -axisY "ValenceBandEnergy"
create_curve -name "Ec" -dataset C1_$dataset -axisX "Y" -axisY "ConductionBandEnergy"
create_curve -name "Efn1" -dataset C1_$dataset -axisX "Y" -axisY "eQuasiFermiPotential"
create_curve -name "Efp1" -dataset C1_$dataset -axisX "Y" -axisY "hQuasiFermiPotential"
create_curve -name "Efn" -function "-<Efn1>"
create_curve -name "Efp" -function "-<Efp1>"

set_curve_prop "Ev" -label "E<sub>V</sub>" -color "black" -line_width 3
set_curve_prop "Ec" -label "E<sub>C</sub>" -color "black" -line_width 3
set_curve_prop "Efn" -label "E<sub>FN</sub>" -color "red" -line_width 3 -line_style "dash"
set_curve_prop "Efp" -label "E<sub>FP</sub>" -color "blue" -line_width 3  -line_style "dash"
set_curve_prop "Efn1" -hide
set_curve_prop "Efp1" -hide


set_axis_prop -axis y -title "Energy (eV)" -title_font_size 20 -scale_font_size 20
set_axis_prop -axis x -title "Y Position (<greek>m</greek>m)" -title_font_size 20 -scale_font_size 20
set_legend_prop -location top_right -label_font_size 20

export_variables -dataset C1_$dataset -filename @pwd@/BandDiag/1ddata_n@node@.csv -overwrite

}

create_plot -1d -dataset C1_n@node|JV@BnddgmPoisson_des

set_axis_prop  -axis y -title "various units" -title_font_size 20 -scale_font_size 20
set_axis_prop  -axis x -title "Y Position (<greek>m</greek>m)" -title_font_size 20 -scale_font_size 20
set_plot_prop -show_regions_bg

#endif
