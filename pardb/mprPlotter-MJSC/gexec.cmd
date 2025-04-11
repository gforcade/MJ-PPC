# project name
name mprPlotter-MJSC
# execution graph
job 2   -post { extract_vars "$wdir" n2_ins.out 2 }  -o n2_ins "inspect -f pp2_ins.cmd"
job 1   -post { extract_vars "$wdir" n1_ins.out 1 }  -o n1_ins "inspect -f pp1_ins.cmd"
job 3   -post { extract_vars "$wdir" n3_ins.out 3 }  -o n3_ins "inspect -f pp3_ins.cmd"
job 4   -post { extract_vars "$wdir" n4_ins.out 4 }  -o n4_ins "inspect -f pp4_ins.cmd"
check Absorption_ins.cmd 1372628967
check Mobility_ins.cmd 1372966874
check DiffusionLength_ins.cmd 1368651628
check InGaAsAbsorp_ins.cmd 1368651628
check global_tooldb 1336087542
check gtree.dat 1372629494
# included files
