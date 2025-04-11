#/raidC/gforc034/STDB/AirPower/1550_PPC/MJ/svisual_struct.tcl


#setdep @node|sde@

## Creates doping profile plot

#S-Visual: Output from Tcl commands history.
load_file @pwd@/results/nodes/@node|sde@/n@node|sde@_bnd.tdr
create_plot -dataset n@node|sde@_bnd
select_plots {Plot_n@node|sde@_bnd}


#create mesh 2D plot 
load_file @pwd@/results/nodes/@node|sde@/n@node|sde@_msh.tdr
create_plot -dataset n@node|sde@_msh
select_plots {Plot_n@node|sde@_msh}


# create 1D plot 
create_cutline -plot Plot_n@node|sde@_msh -type x -at @<wtot/2.0>@
create_plot -dataset C1(n@node|sde@_msh) -1d
select_plots {Plot_C1(n@node|sde@_msh)}


#setting axis properties
set_axis_prop -plot Plot_C1(n@node|sde@_msh) -axis y -type log -min 1e15 -min_fixed -max 1e19 -max_fixed -title "Concentration (cm-3)" -title_font_size 20 -scale_font_size 20
set_axis_prop -plot Plot_C1(n@node|sde@_msh) -axis x -range {0.3 0.5} -min_fixed -max_fixed -title "Cell Depth (um)" -title_font_size 20 -scale_font_size 20
set_legend_prop -location bottom_right -label_font_size 15


# create doping profile curves
create_curve -name pdopant -axisX Y -axisY BoronActiveConcentration -dataset {C1(n@node|sde@_msh)} -plot Plot_C1(n@node|sde@_msh)
create_curve -name ndopant -axisX Y -axisY ArsenicActiveConcentration -dataset {C1(n@node|sde@_msh)} -plot Plot_C1(n@node|sde@_msh)

# setting curve properties
set_curve_prop pdopant -label "p-dopant" -plot Plot_C1(n@node|sde@_msh) -line_width 7
set_curve_prop ndopant -label "n-dopant" -plot Plot_C1(n@node|sde@_msh) -line_width 7


# show regions in plot
set_plot_prop -plot {Plot_C1(n@node|sde@_msh)} -show_regions_bg


