#----------------------------------------------------------------------#
#- $Id: epi.tcl,v 1.18 2007/11/30 16:31:35 letay Exp $
#----------------------------------------------------------------------#
# set DEBUG 1
#-- get the project directory 
set CWD [pwd]
set CWD [file dirname $CWD]
set CWD [file dirname $CWD]
set CWD [file dirname $CWD]

#-- use helper tcl files
source $CWD/../lib/helper.tcl
source $CWD/../lib/layers.tcl

#-- IO
set NODE    [regsub {pp([0-9]+)_.*} [lindex $argv 0] {\1}]
set File(csv) [lindex $argv 0]
set FIDcsv  [open $File(csv) r]
set File(scm) "n${NODE}_epi.scm"   
set File(var) "n${NODE}_epi.tcl"
set FIDscm [open $File(scm) w]
set FIDvar [open $File(var) w]

#-- Default global settings
set Xmin  0.0
set Xmax  1.0 
set dXmin 9999.0
set dXmax 9999.0
set Ytop  0.0
set dYmin 9999.0
set dYmax 9999.0
set Zmin  0.0
set Zmax  0.0
set dZmin 9999.0
set dZmax 9999.0
set generate "" ;# by default there should not be generated any grid file
set mesher "snmesh"
set meshOptions ""
set dimension ""
set topContact ""
set bottomContact ""
set globalVarNames {Xmin Xmax dXmin dXmax Ytop dYmin dYmax Zmin Zmax dZmin dZmax \
											generate mesher meshOptions dimension topContact bottomContact} 
#----------------------------------------------------------------------#
set columnNames [list region material parFile thickness doping \
									 mole refinement]
set layerDefs [list]  ;# Expanded list of layer definitions
set MODE "normal"     ;# MODE= normal|repeat. Repeat for repeated sequences

#----------------------------------------------------------------------#
#-- Reading the global parameter settings
puts "------------------------------------------------------------"
puts "Global settings:"
while { [gets $FIDcsv LINE] >= 0 } {
	set LINE [string trim $LINE]
	dbputs "LINE: $LINE"
	if { [string range $LINE 0 0] == "#" || [string length $LINE] == 0 || \
			 ![string match -nocase "\$global*" $LINE ] } {continue}
	#--Clip off $global
	set LINE [lrange $LINE 1 end]
	if {[string match -nocase "append*" $LINE]} {
		set LINE [string trim $LINE]
		dbputs "LINE: $LINE @[lindex $LINE 2]@"
		set par [string trim [lindex $LINE 1]]
		set val [string trim [lindex  $LINE 2]]
		set val [split $val ","]
		dbputs "par: @$par@ val: @$val@"
		if {![info exists $par]} {
			puts "Trying to append values to variable $par, which does not exist yet, created it."
			set $par ""
		}
		foreach e $val {
			set e [string trim $e]
			if {[string length $e] > 0 && [lsearch  $par $e] == -1} {
				lappend $par $e
			}
			}
		eval "set v \$$par";dbputs "$par: $v"
	} else {
		#-- Conversion CSV to Tcl list
		set GBs [csv2list $LINE ","]
		foreach GB $GBs {
			set GB [string trim $GB]
			dbputs "GB: $GB"
			if {[string match "*=*" $GB]} {
				set TMP [split $GB "="]
				dbputs "length TMP: [llength $TMP] TMP: $TMP"
				set par [lindex $TMP 0]
				set val [lindex $TMP 1]
				set $par "$val"
				dbputs "set $par $val"
				if {[lsearch $globalVarNames $par]==-1} {
					lappend globalVarNames $par
				}
			}
		}
	}
};# end while
dbputs "globalVarNames: [join $globalVarNames "|"]"

if { $Zmin != $Zmax } {
	if {$dimension != 2 && $dimension != 3} {set dimension 3}
	puts "Zmin != Zmax: A 3D device will be created!"
	puts "Wafer Dimensions:                    Xmin= $Xmin Xmax=$Xmax Zmin= $Zmin Zmax=$Zmax"
	puts "Top wafer coordinate:                Ytop= $Ytop"
	puts "Default Mesh spacing in X-direction: dXmax=$dXmax dXmin=$dXmin"
	puts "Default Mesh spacing in Y-direction: dYmax=$dYmax"
	puts "Default Mesh spacing in Z-direction: dZmax=$dZmax dZmin=$dZmin"
} else {
  if {$dimension != 2 && $dimension != 3} {set dimension 2}
	puts "Zmin=Zmax: 2D structure generation"
	puts "Wafer Dimensions:                    Xmin= $Xmin Xmax=$Xmax"
	puts "Top wafer coordinate:                Ytop= $Ytop"
	puts "Default Mesh spacing in X-direction: dXmax=$dXmax dXmin=$dXmin"
	puts "Default Mesh spacing in Y-direction: dYmax=$dYmax"
}
if {$topContact != ""|| $bottomContact!=""} {
		puts -nonewline "putting contacts: "
	if {$topContact != ""} {
		puts -nonewline "top = \"$topContact\" "
	}
	if {$bottomContact != ""} {
		puts -nonewline "bottom = \"$bottomContact\""
	}
	puts ""
}
# Test whether Xmin < Xmax and Zmin < Zmax
if {$Xmax <= $Xmin} {
	puts stderr "Xmax should be greater than Xmin!"
	exit 1
}
if {$dimension == 3 && $Zmax < $Zmin} {
	puts stderr "Zmax should be greater than Zmin!"
	exit 1
}

# reset sde, this eases life when debuging the generated scm script and copy pasting it into the GUI
#puts $FIDscm "(sde:clear)" ;# sometimes it is necessary to to something before loading the layer structure, an clear destroys every thing done before.
foreach par $globalVarNames {
	set val [evalVar "\$::${par}"]
	# write variable definition to scm source file
	if {[isNumber $val]} {
		puts $FIDscm "(define $par $val)"
	} else {
		puts $FIDscm "(define $par \"$val\")"
	}
	puts $FIDvar "set $par \"$val\"";# write variable definition to tcl var source file
}

#----------------------------------------------------------------------#
#- Reading CSV file for the layers line by line
#----------------------------------------------------------------------#
puts "------------------------------------------------------------"
seek $FIDcsv 0 ;#- go back to the begining of the CSV file
while { [gets $FIDcsv LINE] >= 0 } {
	set LINE [string trim $LINE]
	dbputs $LINE
	if { ![string match "\#*" $LINE] && ![string match "\$global*" $LINE] && [string length $LINE] > 0 } {
		if { [string match -nocase "\$repeat*" $LINE] } {
			#-- Detected start of sequence to be repeated
			set MODE "repeat" 
			set repeatLayers [list] ;# Initialize Stack of layers to be repeated
			set repeats 1
			set repeatStart 1
			set repeatIncrement 1
			set repeats [lindex $LINE 1] ;# Reading number of repeates
			if {[llength $LINE] >= 2 && [isNumber [lindex $LINE 1]]} {
				set repeats [lindex $LINE 1]
			}
			if {[llength $LINE] >= 3 && [isNumber [lindex $LINE 2]]} {
				set repeatStart [lindex $LINE 2]
			}
			if {[llength $LINE] >= 4 && [isNumber [lindex $LINE 3]]} {
				set repeatIncrement [lindex $LINE 3]
			}
			dbputs "repeats: $repeats repeatStart: $repeatStart repeatIncrement: $repeatIncrement"
		} elseif { [string match -nocase "\$end*" $LINE] } {
			dbputs "\$end detected"
			#-- Detected end of sequence to be repeated
			set MODE "normal" 
			#-- Executing repetition! 
			#-- !!!NOTE only $i is allowed for index if repeated layers!
			#-- !!!NOTE repeats cannot be nested!
			for { set i $repeatStart } { $i <= $repeats } { incr i $repeatIncrement } {
				foreach repeatLayer $repeatLayers {
					# puts "ORG=$repeatLayer"
					regsub -all {\$i} $repeatLayer $i TMP
					dbputs "append layer region: $TMP"
					# puts "TMP=$TMP"
					lappend layerDefs $TMP
				}
			}
			unset -nocomplain i
		} else {
			#-- Conversion CSV to Tcl list
			set layerDef [csv2list $LINE ","]
			#-- Append newly read layer to either repeat or regular layer list
			if { $MODE == "repeat" } {
				lappend repeatLayers $layerDef
			} else {
				lappend layerDefs $layerDef
			}
		}
	}
}
close $FIDcsv
# trim all items of layerDefs
set ll $layerDefs
set layerDefs {}
foreach l $ll {
	set layerDef {}
	foreach item $l {
		lappend layerDef [string trim $item]
	}
	lappend layerDefs $layerDef
}

#----------------------------------------------------------------------#
#- check layer data for consistency
#----------------------------------------------------------------------#
#initialize counter and saved for checking doublicates
set typList {region matdef matintdef regintdef}
foreach t $typList {
	set i($t) 1
	set saved($t) {}
}
set row 1
foreach layerDef $layerDefs {
	#-- Initializing the variables for the current layer definition:
	set str ""
	foreach columnName $columnNames entry $layerDef {
    set columnName [string trim $columnName] 
    set entry [string trim $entry] 
    set $columnName $entry 
		set str "${str} $columnName=\"$entry\""
	}
	dbputs "layerDef: $str"
	#check whether parFile exists
	if {![file exists [getParfileWithPath $parFile]]} {
		puts stderr "Warning: Could not find parameter file \"$parFile\"!"
		puts stderr "         Ensure that the file exists either in the "
		puts stderr "         local parameter directory \"./par\" or in the "
		puts stderr "         global parameter directory \"[getPardb]\""
	}
	#check whether region name is unique
	if {[string length $region] > 0&&[lsearch $saved(region) $region] > -1} {
		puts stderr "ERROR: Region name \"$region\" not unique!!!"
		exit -1
	}
	#check whether material definition is unique
	if {[string length $region] == 0&&[lsearch $saved(matdef) $material] > -1} {
		puts stderr "Warning: Two materialwise definition for \"$material\" exist. Must be unique!"
		puts stderr "         Check layer definition file"
	}
	# determine entry type region, matdef, ...
	if {[string length $region] > 0} {; # region wise
		if {[string first "/" $region]>-1} {; #interface definition
			set entryType regintdef
		} else {
			set entryType region
		}
	} else {; #material wise
		if {[string first "/" $material]>-1} {; #interface definition
			set entryType matintdef
		} else {
			set entryType matdef
		}
	}
	if {"$entryType" != "region"} {
		set epi($entryType,$i($entryType),i) $i($entryType)
		puts $FIDvar "set epi($entryType,$i($entryType),i) \{$i($entryType)\}"
	}
	# save layer data in variable epi in the epi.tcl file
	foreach columnName $columnNames entry $layerDef {
		if {[string length [string trim $columnName]] > 0} {
 			#- if we have a  profile for mole or doping definition look for the keyword (default <value>)
			#- to be used as variable value. And place the complete profile string in ${columnName}Profile
  		if {[string compare -nocase "$columnName" "doping"]||[string compare -nocase "$columnName" "mole"]} {
 				if {[string first "(" $entry] > -1} {;# starting with "("
 					set profileList [strToList $entry] ;# converts (...) to tcl list {1 2}
 					foreach profile  $profileList {
 						if {[string match -nocase "*[lindex $profile 0]*" "default"]} {
 							set entry [lindex $profile 1]
 							break
 						}
 					}
 				}
			} 
			if {[string length $region] == 0} {
				set epi($entryType,$i($entryType),$columnName) $entry
				puts $FIDvar "set epi($entryType,$i($entryType),$columnName) \{$entry\}"
			} else {
				set epi($entryType,$region,$columnName) $entry
				puts $FIDvar "set epi($entryType,$region,$columnName) \{$entry\}"
			}
		}
	}
	# append region and material names for checking doublicates
	# add field row to sort the layer entries when using getLayerKeyList
	if {[string length $region] == 0} {
		lappend saved($entryType) $material
	} else {
		lappend saved($entryType) $region
	}
	if {"$entryType" == "region"} {
		set epi($entryType,$region,row) $row
		puts $FIDvar "set epi($entryType,$region,row) \{$row\}"
	} else {
		set epi($entryType,$i($entryType),row) $row
		puts $FIDvar "set epi($entryType,$i($entryType),row) \{$row\}"
	}
	incr i($entryType)
	incr row
}
unset i
#--  save columnNames in tcl var file
	puts $FIDvar "set columnNames \{$columnNames\}"

#----------------------------------------------------------------------#
#- create the scm script scripts
#----------------------------------------------------------------------#
#- Initialization of Counters and Fields
set Y0 $Ytop
set Y1 $Y0
set i 1
set AxisAligned ""
#-- Loop over all layers
dbputs "keylist: [getLayerKeyList "region*"]"
foreach key [getLayerKeyList "region*"] {
	puts "Layer $i:"
	dbputs "key: $key"
	# load the layer data from epi(*) to the global columnName variables
	loadLayerVariables $key
	#-- Print current layer definition and save it in tcl var file
	set str ""
	foreach columnName $columnNames {
		if {[string length [string trim $columnName]] > 0} {
			set str "${str}${columnName}=\"$epi($key,$columnName)\" "
		}
	}
	puts "$str"

	#--if RegionName not empty
	if { $region != "" && $thickness != "" } { 
		#--------------------
		#-- Creating the region...
		set Y1 [expr $Y0 + $thickness];# Creating new bottom coordinate
    # save position variables to tcl
		puts $FIDvar "set epi(region,$region,y0) $Y0";# write variable definition to tcl var source file
		puts $FIDvar "set epi(region,$region,y1) $Y1";# write variable definition to tcl var source file
		#-- SCHEME START: save position variables to scm
		puts $FIDscm ";;-----------------------------------------"
		puts $FIDscm ";; Layer $i region=$region material=$material"
		puts $FIDscm "(define Y0_$region $Y0)"
		puts $FIDscm "(define Y1_$region $Y1)"
    # Creating the region...
		puts $FIDscm [layers::createRegion $region $material $dimension $Xmin $Y0 $Zmin $Xmax $Y1 $Zmax]
		#-- SCHEME END
	
		#--------------------
		#-- Doping for the current layer:
		if { $doping != "" } {
			puts $FIDscm ";;-- doping"
			if {[string first "(" $doping]== -1} {
				puts $FIDscm [layers::createProfile "doping" $region $doping $Xmin $Y0 $Zmin $Xmax $Y1 $Zmax]
			} elseif {[string first "(" $doping] > -1} {;# starting with "("
				set doping [strToList $doping] ;# converts (...) to tcl list {1 2}
				foreach dop $doping {
					if {[llength $dop] > 0} {
						if {[isNumber [lindex $dop 0]]} {;#(0.12)
							puts $FIDscm [layers::createProfile "doping" $region [lindex $dop 0] $Xmin $Y0 $Zmin $Xmax $Y1 $Zmax]
						} elseif {[string match -nocase "*[lindex $dop 0]*" "lin_erf_gauss"]} {
							puts $FIDscm [layers::createProfile "doping" $region $dop $Xmin $Y0 $Zmin $Xmax $Y1 $Zmax]
						} else {
							puts stderr "  ERROR in region \"$region\". Doping profile \"$doping\" is not supported yet"
							exit 1
						}
					} 
				}
			} else {
				puts stderr "Syntax error in $File(csv) for region \"$region\": $doping. It has to start with \"(\" or a number"
				exit 1
			}
		}

		#----------------------
		#-- Mole fractions the current layer:
		#-- Analyse mole fraction specification
		if { $mole !=""} {
			puts $FIDscm ";;-- mole"
			if {[string first "(" $mole] == -1} {;#0.12
				puts $FIDscm [layers::createProfile "xmole" $region $mole $Xmin $Y0 $Zmin $Xmax $Y1 $Zmax]
#				puts $FIDvar "set epi(region,$region,xMole) $mole"
			} elseif {[string first "(" $mole] > -1} {;# starting with "("
				set xMole [strToList $mole] ;# converts (...) to tcl list {1 2}
				foreach m $xMole {
					if {[llength $m] == 0} {continue}
					dbputs "mole m: $m isnumber: [isNumber $m] len: [llength $m] match: [string match -nocase "*[lindex $m 0]*" "lin_erf_gauss"]"
					set xymole "xmole"
					if {[string match -nocase "y*" "[lindex $m 0]"]} {;#(y ...)
						set m [lrange $m 1 end]
						set xymole "ymole"
					}
					if {[isNumber [lindex $m 0]]} {;#(0.12)
						puts $FIDscm [layers::createProfile "xmole" $region [lindex $m 0] $Xmin $Y0 $Zmin $Xmax $Y1 $Zmax]
#						puts $FIDvar "set epi(region,$region,xMole) [lindex $m 0]"
						if {[llength $m] > 1 && [isNumber [lindex $m 1]]} {;#(0.12 0.43)
							puts $FIDscm [layers::createProfile "ymole" $region [lindex $m 1] $Xmin $Y0 $Zmin $Xmax $Y1 $Zmax]
#							puts $FIDvar "set epi(region,$region,yMole) [lindex $m 0]"
            }
					} elseif {[string match -nocase "*[lindex $m 0]*" "lin_erf_gauss"]} {
						puts $FIDscm [layers::createProfile $xymole $region $m $Xmin $Y0 $Zmin $Xmax $Y1 $Zmax]
						if {[string match "*.tcl" $parFile]} {
							puts "  WARNING: in region \"$region\" tcl-parFile for mole profiles not supported."
							puts "           please specify an adequate par file you can convert tcl to par file"
							puts "           using the tcl2par converter, ask support."
					}
				} else {
						puts stderr "  ERROR in region \"$region\". Mole profile \"$mole\" is not yet supported!"
						exit 1						
				}
			}
		} else {
				puts stderr "Syntax error in $File(csv) for region \"$region\": $mole. It has to start with \"(\" or a number"
				exit 1
			}
#		} else {
#			puts $FIDvar "set epi(region,$region,xMole) \"\""
		}

		#--------------------
		#-- refinement for the current layer:
		if {$refinement != ""} {
			puts $FIDscm ";;-- refinement"
			if {[string first "(" $refinement] == -1} {;#no "(" e.g. 0.12
				puts "WARNING: no parenthesis in refinement for region $region found."
				puts "         use (yref ...) (mbox ...) commands."
			} else {
				array set constRef [list xmin 0 xmax [expr $Xmax-$Xmin] ymin 0 ymax [expr $Y1-$Y0] zmin 0 zmax [expr $Zmax-$Zmin]]
				set refinement [strToList $refinement] ;# converts (1 2) to tcl list {1 2}
				dbputs "refinement: $refinement ref1:[lindex $refinement 0]"
				foreach ref $refinement {
					if { [string match -nocase "xref" [lindex $ref 0]] } {;#- XREF
						if {[llength $ref] > 1} {
							if { [isNumber [lindex $ref 1]] } {;#- (XREF dxmin)
								set constRef(xmin) [lindex $ref 1] 
								if {[llength $ref] > 2&&[isNumber [lindex $ref 2]]} {
									set constRef(xmax) [lindex $ref 2]
								} else {
									set constRef(xmax) $constRef(xmin)
								}
							}
							dbputs "constRef(xmin): $constRef(xmin) constRef(xmax): $constRef(xmax)"
						} else {
							puts "WARNING: Syntax of refinement xref in region $region has to be (xref dxmin [dxmax])."
						}
					} elseif { [string match -nocase "yref" [lindex $ref 0]] } {;#- YREF
						if {[llength $ref] > 1} {
							if { [string match -nocase "qw" [lindex $ref 1]] } {;#- (YREF qw)
								#- the mid point is needed for 3D qw meshing
								if {[string match -nocase "snmesh" "$mesher"]} {
									set Ym  [expr 0.5*($Y0+$Y1)]
									append AxisAligned " $Y0 $Ym $Y1 "
								} elseif {[string match -nocase "mesh" "$mesher"]} {
									set dYm [expr 0.5*abs($Y0-$Y1)]
									set constRef(ymin) $dYm
									set constRef(ymax) $dYm
								} else {
									puts "Error: no valid mesher \"$mesher\""
									exit
								}
							} elseif { [isNumber [lindex $ref 1]] } {;#- (YREF dymin)
								set constRef(ymin) [lindex $ref 1] 
								if {[llength $ref] > 2&&[isNumber [lindex $ref 2]]} {
									set constRef(ymax) [lindex $ref 2]
								} else {
									set constRef(ymax) $constRef(ymin)
								}
							}
							dbputs "constRef(ymin): $constRef(ymin) constRef(ymax): $constRef(ymax)"
						} else {
							puts "WARNING: Syntax of refinement yref in region $region has to be (yref dymin [dymax]) or (yref qw)."
						}
					} elseif { [string match -nocase "zref" [lindex $ref 0]] } {;#- ZREF
						if {[llength $ref] > 1} {
							if { [isNumber [lindex $ref 1]] } {;#- (ZREF dzmin)
								set constRef(zmin) [lindex $ref 1] 
								if {[llength $ref] > 2&&[isNumber [lindex $ref 2]]} {
									set constRef(zmax) [lindex $ref 2]
								} else {
									set constRef(zmax) $constRef(zmin)
								}
							}
							dbputs "constRef(zmin): $constRef(zmin) constRef(zmax): $constRef(zmax)"
						} else {
							puts "WARNING: Syntax of refinement xref in region $region has to be (xref dxmin [dxmax])."
						}
					} elseif { [string match -nocase "mbox" [lindex $ref 0]] } {;#mbox
						if {[llength $ref] > 3} {
							set refmin [lindex $ref 1] 
							set ratio [lindex $ref 2] 
							if { [llength $ref] == 4 } { ;# Dir defaults to both!
								set direction [lindex $ref 3]
							} else {
								set direction "both"
							} 
							dbputs "refmin: $refmin ratio: $ratio direction: $direction"
							puts $FIDscm [layers::createMboxRefinement $region $dimension $Xmin $Y0 $Zmin $Xmax $Y1 $Zmax $refmin $ratio $direction]
						} else { 
							puts "WARNING: Syntax of refinement mbox in region $region has to be (mbox dymin ratio [direction])."
						}
					} else {
						puts "WARNING: Syntax of refinement in region $region wrong. Use (mbox ...) or (yref ...) statements."
					}
				};#end for ref
				if {(0<$constRef(xmax)&&$constRef(xmax)<[expr abs($Xmax-$Xmin)])|| \
							(0<$constRef(ymax)&&$constRef(ymax)<[expr abs($Y0-$Y1)])|| \
							(0<$constRef(zmax)&&$constRef(zmax)<[expr abs($Zmax-$Zmin)])} {
					puts $FIDscm [layers::createConstantRefinement $region $dimension $constRef(xmin) $constRef(ymin) $constRef(zmin) \
													$constRef(xmax) $constRef(ymax) $constRef(zmax)]
				}
			};#end if (yref...
		};# end if refinement
	};#end if region
	
	#-- Next Layer
	set Y0 $Y1
	incr i
	puts $FIDscm ""
}

puts "------------------------------------------------------------"
puts "postprocessing"
#-- Bottom Y-coordinate
puts $FIDscm "(define Ybot  $Y1)"

#-- define global refinement
if {$dXmin < 9999.0||$dYmin < 9999.0 ||$dZmin < 9999.0||$dXmax < 9999.0||$dYmax < 9999.0 ||$dZmax < 9999.0} {
	puts "adding global refinement"
	dbputs  "dXmin: $dXmin dYmin: $dYmin dZmin: $dZmin dXmax: $dXmax dYmax: $dYmax dZmax: $dZmax"
	puts $FIDscm ";;-- global refinement"
	puts $FIDscm [layers::createConstantRefinement "global" $dimension $dXmin $dYmin $dZmin $dXmax $dYmax $dZmax $Xmin $Ytop $Zmin $Xmax $Y1 $Zmax]
}

#-- add contacts if global variable topContact or bottomContact was specified
if {$topContact !="" || $bottomContact != ""} {
	puts "adding contacts"
	dbputs  "topContact: \"$topContact\" bottomContact: \"$bottomContact\""
	if {$topContact !=""} {
		puts $FIDscm ";;-- topcontact: $topContact"
		puts $FIDscm [layers::addContact $topContact "top" $dimension]
	}
	if {$bottomContact !=""} {
		puts $FIDscm ";;-- bottom contact: $bottomContact"
		puts $FIDscm [layers::addContact $bottomContact "bottom" $dimension]
	}
}


#-- postprocessing
puts $FIDscm ";-- postprocess"
if { $AxisAligned != "" } {
	puts "add axisaligned mesh statements for QW"
	set FIDaxa [open "n${NODE}_AxisAligned.txt" w]
	puts $FIDaxa "AxisAligned { yCuts = ( $AxisAligned ) }"
	close $FIDaxa
	puts $FIDscm "(sdedr:append-cmd-file \"n${NODE}_AxisAligned.txt\")"
}

close $FIDscm
close $FIDvar

puts "------------------------------------------------------------"
#-- generate a boundary or a grid?
dbputs "generate: $generate"
#if user specified grd or tdr but not bnd add bnd because it is needed for grd generation
if {([string match -nocase "*grd*" $generate]||[string match -nocase "*tdr*" $generate])&& ![string match -nocase "*bnd*" $generate]} {
	set generate "bnd_${generate}"
}
if {[string match -nocase "*bnd*" $generate]} {
	puts "generating boundary file ..."
	set File(gen) "n${NODE}_epi_gen.scm"   
	set File(genout) "n${NODE}_epi_gen.out"   
#	set File(bnd) "n${NODE}_epi_msh.bnd"   
	set File(bnd) "n${NODE}_epi_bnd.tdr"   
	set File(cmd) "n${NODE}_epi_msh.cmd"   
	set File(meshout) "n${NODE}_epi_msh.out"   
	set FIDgen [open $File(gen) w]
	puts $FIDgen "(load \"$File(scm)\")"
#	puts $FIDgen "(sdeio:save-2d-tdr-bnd \"all\" \"$File(bnd)\")"
	puts $FIDgen "(sdeio:save-tdr-bnd \"all\" \"$File(bnd)\")"
	puts $FIDgen "(sdedr:write-cmd-file \"$File(cmd)\")"
	close $FIDgen
	set cmd " sde -e -l $File(gen) > $File(genout)"
	dbputs "cmd: $cmd"
	if {[catch "exec $cmd" result]} {
		puts stderr "Error: while generating bnd file when executing sde."
		puts stderr "exec result: $result errorCode: $::errorCode"
		set FIDgenout [open $File(genout) r]
		puts stderr [read $FIDgenout]
		close $FIDgenout
		exit 1
	}
} 
if {[string match -nocase "*grd*" $generate]||[string match -nocase "*tdr*" $generate]} {
	puts "generating mesh ..."
	#	if {[string match -nocase "*tdr*" $generate]&& "$mesher" == "mesh"&& \
	#	![string match "*-F tdr*" $meshOptions]} {set meshOptions "$meshOptions -F tdr "}
	if {[string match -nocase "*tdr*" $generate]&& "$mesher" == "mesh" && \
				![string match "*-F tdr*" $meshOptions]} {set meshOptions "$meshOptions -discontinuousData -F tdr "}
	if {[string match -nocase "*grd*" $generate]&& "$mesher" == "mesh" } {
		set meshOptions "-discontinuousData"
	} elseif { [string match -nocase "*grd*" $generate] && "$mesher" == "snmesh" } { 
		puts stderr "snmesh cannot generate structure file in DF-ISE format" 
		exit 1
	}
	
	
	
	set cmd "$mesher $meshOptions [file rootname $File(bnd)] > $File(meshout)"
	dbputs "cmd: $cmd"
	if {[catch "exec $cmd" result]} {
		puts stderr "Error: while meshing."
		puts stderr "exec result: $result errorCode: $::errorCode"
		set FIDmeshout [open $File(meshout) r]
		puts stderr [read $FIDmeshout]
		close $FIDmeshout
		exit 1
	}
}
puts "done."

