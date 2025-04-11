
#setdep @node|optics@

set node @node|optics@

puts "convert coordinate system from UCS to DFISE \n\n"
TdrFileConvert -ts ../$node/pv1_PV_n${node}_OptGen_des.tdr tdr_file.tdr

puts "convert tdr to dat and grd files \n \n"
TdrFileConvert --tdr2dfise tdr_file.tdr dfise_file

puts "convert dat file to tdr \n \n"
TdrFileConvert --dfise2tdr dfise_file.grd dfise_file.dat tdr_file

puts "convert coordinate system back to UCS \n \n"
TdrFileConvert -ts tdr_file.tdr tdr_file.tdr
