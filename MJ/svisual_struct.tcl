#/raidC/gforc034/STDB/AirPower/1550_PPC/MJ/svisual_struct.tcl
#S-Visual: Output from Tcl commands history.
load_file /raidC/gforc034/STDB/AirPower/1550_PPC/MJ/results/nodes/1936/n1936_bnd.tdr
create_plot -dataset n1936_bnd
select_plots {Plot_n1936_bnd}
#-> Plot_n1936_bnd
#-> Plot_n1936_bnd
#-> n1936_bnd
load_file /raidC/gforc034/STDB/AirPower/1550_PPC/MJ/results/nodes/1936/n1936_msh.tdr
create_plot -dataset n1936_msh
select_plots {Plot_n1936_msh}
#-> Plot_n1936_msh
#-> Plot_n1936_msh
#-> n1936_msh
set_field_prop BoronActiveConcentration -plot Plot_n1936_msh -geom n1936_msh -show_bands
#-> 0
create_cutline -plot Plot_n1936_msh -type x -at 0.521062
#-> C1(n1936_msh)
create_plot -dataset C1(n1936_msh) -1d
select_plots {Plot_C1(n1936_msh)}
#-> Plot_C1(n1936_msh)
#-> Plot_C1(n1936_msh)
set_axis_prop -plot Plot_C1(n1936_msh) -axis y -type log
#-> 0
create_curve -axisX Y -axisY BoronActiveConcentration -dataset {C1(n1936_msh)} -plot Plot_C1(n1936_msh)
#-> Curve_1
select_plots {Plot_n1936_msh}
#-> Plot_n1936_msh
set_field_prop ArsenicActiveConcentration -plot Plot_n1936_msh -geom n1936_msh -show_bands
#-> 0
create_cutline -plot Plot_n1936_msh -type x -at 0.459956
#-> C2(n1936_msh)
set_axis_prop -plot Plot_C1(n1936_msh) -axis y -type log
#-> 0
create_curve -axisX Y -axisY ArsenicActiveConcentration -dataset {C2(n1936_msh)} -plot Plot_C1(n1936_msh)
#-> Curve_2
select_plots {Plot_C1(n1936_msh)}
#-> Plot_C1(n1936_msh)
set_curve_prop {Curve_1} -plot Plot_C1(n1936_msh) -line_width 7
#-> 0
set_curve_prop {Curve_2} -plot Plot_C1(n1936_msh) -line_width 7
#-> 0
set_curve_prop {Curve_2} -plot Plot_C1(n1936_msh) -label ArsenicActiveConcentration(C2(n1936_msh))
#-> 0
set_plot_prop -plot {Plot_C1(n1936_msh)} -show_regions_bg
#-> 0

