#----------------------------------------------------------------------#
# $Id: Levinshtein.tcl,v 1.2 2008/04/08 13:13:49 sameers Exp $ 
#----------------------------------------------------------------------#
#! MODEL: Room temperature model from Adachi, with doping dependence from Casey
#! MATERIAL: GaAs
#! PROPERTY: Complex Refractive Index 
#! EXPRESSION: 
#! Room temperature values of wavelength, refractive index and extinction coefficient are created
#! using the data files from Levinshtein folder
#! CALCULATED PARAMETER:
#! llist, nlist and klist return wavelength [um], absorption coefficient [cm^-1], refractive index and extinction coefficient respectively. 
#! VALIDITY: this model is valid only for T=300K
#! REFERENCE: 
#! "Handbook series on Semiconductor Parameters, Vol I"
#! M. Levenshtein, S. Rumyantsev, M. Shur, World Scientific, 1996
#! HISTORY:
#! Gergoe Letay: Created Data files in Levinshtein folder
#! Sameer Shah: Created this script

namespace eval GaAs::ComplexRefractiveIndex {
    proc init {} {
	proc readTable {file tableType} {
	    set FID [open $file r]
	    set i 0
	    set llist [list]
	    set nlist [list]
	    set klist [list]
	    while {[gets $FID line] >= 0} {
		    if {[scan $line "%e %e %e" l n k] == 3 } {
		        lappend llist $l
		        lappend nlist $n
		        lappend klist $k
		        incr i
	    	}
	    }
	    set lnklist [list $llist $nlist $klist]
	    return $lnklist
        close $FID
	}

	variable llist
	variable nlist
	variable klist
	variable Formula

	# Format doping value so that it is consistent with data file names in Levinshtein folder
	set doping [format %1.2e $::doping]

    #---------------------------------------------------------------------------------------------------
	# Choose data file based on doping concentration and dopant type
    #---------------------------------------------------------------------------------------------------

	if {$::doping > 0.0} {
	    set dopantType n
	    # Verify that N-type dopant concentration is within range
	    if {($doping < 1.0e16)||($doping > 6.0e18)} {
		puts stderr "Warning: $::material:TableODB:Adachi_dop:"
		puts stderr "  N-type doping $doping is out of range(1.0e16 to 6.0e18 cm^-3)"
#		exit -1
	    }
	} elseif {$::doping < 0.0} {
	    set dopantType p
	    set doping [format %1.2e [expr -$doping]]
	    # Verify that P-type dopant concentration is within range
	    if {($doping < 1.0e16)||($doping > 1.0e19)} {
		puts stderr "Warning: $::material:TableODB:Adachi_dop:"
		puts stderr "  P-type doping $doping is out of range(1.0e16 to 1.0e19 cm^-3)"
#		exit -1
	    }	    
	} elseif {$::doping == 0.0} {
	    puts stderr "Doping = 0: Please enter a non-zero doping concentration"
#	    exit -1
	}
	set mantissa [lindex [split $doping e] 0]
	set exponent [lindex [split $doping e] 1]
    
#	if {$dopantType == "p"} {
	    set exponent [lindex [split $exponent +] 1]
#	}
    
	set tmp1 [lindex [split $mantissa .] 0]
	set tmp2 [lindex [split $mantissa .] 1]

	if {($tmp2 == 0.0) || ([llength $tmp2] == 0)} {
	    set mantissa $tmp1
	} else {
	    set tmp3 [expr $tmp2/10.0]
	    if {$tmp3 >= 0.5} {
		set tmp4 [expr $tmp1+1]
		if {$tmp4 == 10.0} {
		    set mantissa 1
		    set exponent [expr $exponent+1]
		} else {
		    set mantissa $tmp4
		}
	    } elseif {$tmp3 < 0.5} {
		set mantissa $tmp1
	    }
	}
	
	if {$doping < 1.0e16} {
	    set mantissa 1
	    set exponent 16
	} elseif {$doping > 6.0e18} {
	    set mantissa 6
	    set exponent 18
	}
	
#	data file name is of the format: levinshtein-n-1e16.par
#        	set dataFile $::pardb/GaAs/OpticalData/TableODB/Levinshtein/levinshtein-${dopantType}-${mantissa}e${exponent}.par
            set scriptName [info script]
            set folderName [file rootname $scriptName]
            set dataFile $folderName/Adachi_dop-${dopantType}-${mantissa}e${exponent}.dat
	    puts $dataFile
#-----------------------------------------------------------------------------------------------------
 
	set tableType TableODBLev
	set lnklist [readTable $dataFile $tableType]
	set llist [lindex $lnklist 0]
	set nlist [lindex $lnklist 1]
	set klist [lindex $lnklist 2]
	set Formula 1
    }
    proc print {} {printPar::ComplexRefractiveIndexSection} 
}
GaAs::ComplexRefractiveIndex::init
