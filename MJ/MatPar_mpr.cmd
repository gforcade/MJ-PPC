#- $Id: MatPar_mpr.cmd,v 1.4 2007/11/29 10:35:50 letay Exp $
#setdep @node|epi@
# global user variables for e.g. material processing
set temp @temp@

set substrate InP
set InGaAs_Bfactor @InGaAs_Bfactor@
set substrate_t @substrate_t@


puts stderr "substrate=$substrate"
source @pwd@/../lib/PhysicalConstants.tcl
source @pwd@/../lib/printPar.tcl

# load the layer variables. The epi tool saves the layer data typically in @[relpath ./n@node|epi@_epi.tcl]@
# layer data can be accessed through 
source "@[relpath @pwd@/results/nodes/@node|epi@/n@node|epi@_epi.tcl]@"

# generate snippets to be inserted in SDevice cmd file
# set FID [open "n@node@_S.cmd" w ]
# foreach key [getLayerKeyList "region,*,region" "qw*"] {
#	loadLayerVariables $key
#	puts $FID "Physics(Region=\"$region\") \{Active\}"
#	} 
# close $FID

# configure parameters for mpr.tcl library to generate parameter files
# Specify output parameter file name
set parameterOutputFile n@node@_mpr.par

## set parameter database directory for this particular project.
set PWD "@pwd@"
set PWD [file dirname $PWD]
puts $PWD
set ::pardb "$PWD/pardb"




# Convert SWB variables to Tcl variables which can be referenced as $gparam(<parameter name>)
# e.g. $gparam(model)
exportParams @node@
