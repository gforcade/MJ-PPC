### Stitches the externally generated optical generation profile to the sentaurus mesh.
# any places with "####" you may want to change at one point


#setdep @node|RCWA@

source @pwd@/../lib/tdr_Manipulation_tdx.tcl

set node @node|sde@

#if "@OptiToSentaurus@" == "v2"

puts "convert coordinate system from UCS to DFISE \n\n"
TdrFileConvert -ts ../$node/n${node}_msh.tdr tdr_file.tdr

puts "convert tdr to dat and grd files \n \n"
TdrFileConvert --tdr2dfise tdr_file.tdr dfise_file

#stitchMesh input: inFileName,opticalGenFileName,outFileName
set output [exec python ../../../../Python/stitchMesh.py "dfise_file" "" "optgen"]
puts $output
puts " \n \n"

puts "convert dat file to tdr \n \n"
TdrFileConvert --dfise2tdr dfise_file.grd optgen.dat dfise_file.dat tdr_file

puts "convert coordinate system back to UCS \n \n"
TdrFileConvert -ts tdr_file.tdr optGen.tdr

#elif "@OptiToSentaurus@" == "v3"
## Use this version only. Others are depricated

set tdrInFileName ../$node/n${node}_msh.tdr
set tdrTdxFileName optGen.tdr

#copy tdr file into tdx directory
TdrFileOpen $tdrInFileName
TdrFileSave $tdrInFileName $tdrTdxFileName
TdrFileClose $tdrInFileName

#### You say which regions you which to include optical generation. Provide list of region names. 
set regions [list]
#sci_em regions are included
for {set Ridx 1} { $Ridx < @numSegments@+1 } { incr Ridx } {
lappend regions sc${Ridx}_em
}
#also include sc1_em2 if it has a nonzero thickness
if {@seg1_em2_t@ > 0.0} {
lappend regions sc1_em2
}


## loop through regions
foreach region $regions {

# export xyz data into files. Input: RegionName DatasetName FileDirectory/name.tdr
set dimensions [exportData_v2 $region OpticalGeneration $tdrTdxFileName]

#stitch Meshs between external optical software and sentaurus mesh. Input: regionNameForData,opticalGenFileName,deviceDimensions.
set output [exec python ../../../../Python/stitchMesh_v3.py $region "../@node|RCWA@/GenRate.csv" $dimensions]
puts $output
puts " \n \n"

# modify file to include optgen data: tdrInputFile OpticalGenerationInputDataList RegionNameForTheData
modifyOptGen_v2 $tdrTdxFileName ${region}_optGen.txt $region

} ; ## end regions loop

puts "\n\n TDR file rewriting is done."

#endif
