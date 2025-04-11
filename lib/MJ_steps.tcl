# This is to do processing for the tdx file 
# History: Gavin Forcade 2023



#if 0 == 0
set segm [regexp -all -inline -- {\d+(?=_)} $region]
!(
set LC_off @LC_off@
puts "if \{\$segm < \$LC_off\} \{"
puts "set mtpl \[expr @Jph${LC_off}_norm0@/@Jph${segm}_norm0@\]"
puts "\} else \{"
puts "set mtpl 1.0"
puts "\}"
)!
#endif
