#----------------------------------------------------------------------#
#- $Id: mpr.tcl,v 1.10 2007/11/30 09:57:49 letay Exp $
#----------------------------------------------------------------------#
#####################
#- initialization
#- load helpers
#-- get the project directory 
set CWD [pwd]
set CWD [file dirname $CWD]
set CWD [file dirname $CWD]
set CWD [file dirname $CWD]

source $CWD/../lib/compound_lib.tcl
source $CWD/../lib/helper.tcl

#- init variables
set ProcessFirst [list]
set CMD [lindex $argv 0]
set NODE    [regsub {pp([0-9]+)_.*} $CMD {\1}]
# set DEBUG 1
dbputs "CMD: $CMD NODE: $NODE"
puts "Reading $CMD"
source $CMD

####################
# find the pardb
# 1) looks whether a global tcl variable pardb is set
# 2) uses the environment variable $STPARDB
# 3) try to look at the default location $STDB/pardb
set ::pardb [getPardb]
#- tell user which global material db will be used
if {$pardb != ""} {
	puts "Material parameter database (pardb) found at: \"$pardb\""
} else {
	puts "no material parameter database (pardb) found."
	puts "If you would like to use a global material parameter database,"
	puts "please point the environment variable STPARDB to the corresponding directory."
}


####################
#- deal with the parFileMask
# if no parfilemask specified set it to a default value
if {![info exists parFileMask]} {set parFileMask {./npar/n${NODE}_${material}_${xMole}_${yMole}.par}}
# build map list which will convert all (entry) in ${entry} e.g. (xmole)-> ${xMole}
# in addition to the column names following variable add NODE xMole yMole to columnName
set maplist {}
dbputs "columnNames: $columnNames"
foreach e [concat $columnNames {NODE xMole yMole}] {
  set maplist [concat $maplist [list ([string tolower $e]) \$\{$e\}]]
}
dbputs "maplist: |$maplist|"
set parFileMask [string map -nocase $maplist $parFileMask]
set parFileMask [string trim $parFileMask]
dbputs "parFileMask: |$parFileMask|"
if {[string length $parFileMask] == 0} {
	puts stderr "Error: parFileMask \"$parFileMask\" empty"
	exit 1
}

####################
#-- Check if directory from parFileMask exists otherwise creates it.
set parDir [file dirname $parFileMask]
dbputs "parDir: $parDir"
if { [file isdirectory $parDir] == 0 } {
	file mkdir $parDir
	puts "Directory \"$parDir\" does not exists. Created it."
}

####################
puts "Analyze epi layer which files have to be generated..."
# define the list of preprocessed parfiles which will be printed in general parfile for sdevice.
# add materialwise definitions
set parEntryList [getLayerKeyList "matdef,*"] 

# add regionwise definitions if parFile is defined for it
foreach key [getLayerKeyList "region*"] {
	dbputs "key: $key"
	# if parfile not empty append to parEntryList 
	if {$epi($key,parFile)!= ""} {
		lappend parEntryList $key
	}
}
dbputs "parEntryList: $parEntryList"

# ensure that substrate is at first line
if {[info exists substrate]} {
	set substrate [string trim $substrate]
	if {[string length $substrate] > 0} {
		foreach e $parEntryList {
			if {[string equal $substrate $epi($e,material)]} {break}
		}
		set parIndex [lsearch $parEntryList $e]
		set parEntryList [concat $e [lreplace $parEntryList $parIndex $parIndex]]
	}
}
dbputs "parEntryList: $parEntryList"

# add materialwise interface definitions
set parEntryList [concat $parEntryList [getLayerKeyList "matintdef,*"]]

# add regionwise interface definitions
set parEntryList [concat $parEntryList [getLayerKeyList "regintdef,*"]]

# generate output file names
set ppList {}
set parOutList {}

foreach p $parEntryList {
	loadLayerVariables $p
	set region [string map {/ _} $region]
	set material [string map {/ _} $material]
	set cmd "set TCLout \"$parFileMask\""
  if {[catch "eval $cmd"]} {
    puts stderr "Error: in parFileMask \"$parFileMask\": $errorCode"
    exit 1
  }
	set TCLout [string map {__ _ _. .} $TCLout]
	set TCLout [string map {__ _ _. .} $TCLout]
	set TCLout [string map {__ _ _. .} $TCLout]
	dbputs "TCLout: $TCLout"
	lappend parOutList $TCLout
}
# determine unique list of parfiles (tcl and par) that have to be preprocessed 
set ppList [unique parOutList]

# check whether each region has a parfile defined including materialwise definitions
puts "region to file maping:"
foreach key [getLayerKeyList "region,*"]  {
	loadLayerVariables $key
	set ok 0
	# lookup region in parEntryList
	set i [lsearch $parEntryList $key]
	if {$i >= 0} {;# if entry exists in parEntryList then it's ok
		puts "$region -> \"[lindex $parOutList $i]\""
		set ok 1
	} else {
		set matdef [getLayerKeyList "matdef,*,material" "$material"]
		dbputs "matdef: $matdef"
		if {[llength $matdef] > 1} {
			set matdef [lindex $matdef 0]
			puts "WARNING for region \"$region\": several materialwise entries found for material \"$material\". taking first definition" 
		}
		if {[llength $matdef] == 1} {
			set i [lsearch $parEntryList $matdef]
			puts "$region -> material -> \"[lindex $parOutList $i]\""
			set ok 1
		}
	}
	if {!$ok} {
		puts "WARNING: no parfile defined for region \"$region\""
	}
}

# write general parfile for sdevice
puts "--------------------"
puts "writing general par file \"$parameterOutputFile\""
set FIDdesout [open $parameterOutputFile w]
foreach key $parEntryList pout $parOutList {
	loadLayerVariables $key
	if {[string match "region*" $key]} {
		puts $FIDdesout "Region = \"$region\" \{ Insert = \"[pwd]/$pout\" \}"
	} elseif {[string match "matdef*" $key]} {
		puts $FIDdesout "Material = \"$material\" \{ Insert = \"[pwd]/$pout\" \}"
	} elseif {[string match "regintdef*" $key]} {
		puts $FIDdesout "RegionInterface = \"$region\" \{ Insert = \"[pwd]/$pout\" \}"
	} elseif {[string match "matintdef*" $key]} {
		puts $FIDdesout "MaterialInterface = \"$material\" \{ Insert = \"[pwd]/$pout\" \}"
	}
}
close $FIDdesout

# go through each file to be preprocessed 
puts "--------------------"
dbputs "pardb: $pardb" 
foreach key $parEntryList pout $parOutList {
	loadLayerVariables $key
	#check whether par file exist
	set parFileFound [getParfileWithPath $parFile]
	if {$parFileFound == ""} {
		puts stderr "ERROR: could not find \"$parFile\", neither locally in ../par nor in global DB: \"$pardb\"."
		exit 1
	}
	dbputs "parFilefound: $parFileFound" 
	#check whether we have mole profile for tcl file
	if {[string match "*.tcl" "$parFileFound"]&&[regexp {[a-zA-Z]} $mole]} {
		puts stderr "ERROR: profiles are not supported yet!"
		exit 1
	}
	puts "Processing $parFileFound -> $pout"
	# read in parFile
	set TCLPP_FIDi  [open "$parFileFound" r]
	set TCLPP_DATA  [read $TCLPP_FIDi]
	close $TCLPP_FIDi 
	set TCLPP_FIDo [open "$pout" w]
	set Current 0
	#-- get parameters from gtree
	array set gparam [getparams $NODE $CWD]
	set swbparastr ""
	foreach n [array names gparam] {
		if {[lsearch [concat columnNames {NODE xMole yMole}] $n] >= 0} {
			puts stderr "ERROR: the swb-parameter \"$n\" has the same name as a column in the epi layer file."
			puts stderr "  Either rename the swb-parameter or the corresponing column in the epi layer file."
			exit 1
		}
		set ::$n $gparam($n)
		set swbparastr "$swbparastr $n=\"$gparam($n)\""
	}
	set layerparastr ""
	foreach c [concat $::columnNames {xMole yMole}] {
		if {[info exists ::epi($key,$c)]} {
			set layerparastr "$layerparastr $c=\"$::epi($key,$c)\""
		} else {
			set layerparastr "$layerparastr $c=\"\""
		}
	}
	puts "swb @-parameter: $swbparastr"
	puts "layer-parameter: $layerparastr"

	#- get constant values of mole column entry, which might be a profile
	set criticalCharMask {\\ \\\\ \{ \\\{ \[ \\\[ \} \\\} \] \\\] \$ \\\$ \" \\\" }
	while { [set TCLPP_TOKEN_START [string first "!(" $TCLPP_DATA $Current]] > -1 } {
		#-Copying TXT over from input data to output data
		set TCLPP_TXT_END [expr $TCLPP_TOKEN_START -1]
		set TCLPP_NOCMD [string range $TCLPP_DATA $Current $TCLPP_TXT_END]
		#- mask critical character
    set TCLPP_NOCMD [string map $criticalCharMask $TCLPP_NOCMD]
		#-replace @-parameters in non tcl blocks with tcl variables e.g. @xMole@->${::xMole}
		set TCLPP_NOCMD [regsub -all {@(\w*)@} $TCLPP_NOCMD {${::\1}}] 
		#-evaluate tcl variables to values
		dbputs "before tcl-block TCLPP_NOCMD: $TCLPP_NOCMD" 9
		set cmd "set TCLPP_NOCMD \"$TCLPP_NOCMD\""
		eval "$cmd"
		dbputs "after eval TCLPP_NOCMD: $TCLPP_NOCMD" 10
		print $TCLPP_NOCMD
		#-Updating Pointer move behind !(
		set Current [expr $TCLPP_TOKEN_START + 2] 
		#-Isolating CMD string
		set TCLPP_TOKEN_END [string first ")!" $TCLPP_DATA $Current]
		set TCLPP_CMD_END   [expr $TCLPP_TOKEN_END   - 1]
		set TCLPP_CMD [string range $TCLPP_DATA $Current $TCLPP_CMD_END]
		dbputs "in tcl-block before replace TCLPP_CMD: $TCLPP_CMD" 10
		set TCLPP_CMD [regsub -all {@(\w*)@} $TCLPP_CMD {${::\1}}]
		dbputs "in tcl-block after replaces TCLPP_CMD: $TCLPP_CMD" 9
		#-Executing TCL CMD
		eval $TCLPP_CMD
		#-Updating Pointer move behind )!
		set Current [expr $TCLPP_CMD_END + 3]
	}
	#-Saving the rest:
	# set DEBUG 5
	#-replace @-parameters with values
	set TCLPP_NOCMD [string range $TCLPP_DATA $Current end]
	#- mask critical character
	set TCLPP_NOCMD [string map $criticalCharMask $TCLPP_NOCMD]
	#-replace @-parameters in non tcl blocks with tcl variables e.g. @xMole@->${::xMole}
	set TCLPP_NOCMD [regsub -all {@(\w*)@} $TCLPP_NOCMD {${::\1}}] 
	set cmd "set TCLPP_NOCMD \"$TCLPP_NOCMD\""
	dbputs "end TCLPP_NOCMD: $TCLPP_NOCMD" 5
	eval "$cmd"
	# set DEBUG 0
	print $TCLPP_NOCMD
	close $TCLPP_FIDo
	puts "---"

}

puts "\nDone."
exit 0
