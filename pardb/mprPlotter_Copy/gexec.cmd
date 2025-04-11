# project name
name mprPlotter_Copy
# execution graph
job 3   -post { extract_vars "$nodedir" n3_ins.out 3 }  -o n3_ins "inspect -f pp3_ins.cmd"
job 4   -post { extract_vars "$nodedir" n4_ins.out 4 }  -o n4_ins "inspect -f pp4_ins.cmd"
job 5   -post { extract_vars "$wdir" n5_ins.out 5 }  -o n5_ins "inspect -f pp5_ins.cmd"
job 1   -post { extract_vars "$wdir" n1_ins.out 1 }  -o n1_ins "inspect -f pp1_ins.cmd"
job 2   -post { extract_vars "$wdir" n2_ins.out 2 }  -o n2_ins "inspect -f pp2_ins.cmd"
check EgVsT_ins.cmd 1636397178
check EbgnVsN_ins.cmd 1636397178
check EgVsxMole_ins.cmd 1637244008
check muVsNtemp_ins.cmd 1637096885
check nkVslambda_ins.cmd 1636397178
check global_tooldb 1616439366
check user_tooldb 1649371444
check gtree.dat 1636397178
# included files
