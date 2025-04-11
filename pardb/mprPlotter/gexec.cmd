# project name
name mprPlotter
# execution graph
job 6 -d "3"  -post { extract_vars "$nodedir" n6_vis.out 6 }  -o n6_vis "svisual -b n6_vis.tcl"
job 3   -post { extract_vars "$nodedir" n3_ins.out 3 }  -o n3_ins "inspect -batch -f pp3_ins.cmd"
check EgVsxMole_ins.cmd 1650322231
check svisual_vis.tcl 1650381050
check global_tooldb 1616439366
check user_tooldb 1649371444
check gtree.dat 1650386130
# included files
