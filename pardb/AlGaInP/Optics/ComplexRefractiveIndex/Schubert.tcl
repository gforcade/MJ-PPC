#----------------------------------------------------------------------#
#! MODEL: Room temperature model from Schubert no doping dependence.
#! Shifted in energy according to parameter Eg_GaInP.
#! MATERIAL: GaInP
#! PROPERTY: Complex Refractive Index 
#! EXPRESSION: 
#! Room temperature values of wavelength, refractive index and extinction coefficient are created
#! CALCULATED PARAMETER:
#! llist, nlist and klist return wavelength [um], absorption coefficient [cm^-1], refractive index and extinction coefficient respectively. 
#! VALIDITY: this model is valid only for T=300K
#! REFERENCE: 
#! HISTORY:
#! M Wilkins: adapted to output ComplexRefractiveIndex and NumericalTable format 2015-Jan-14

namespace eval GaInP::ComplexRefractiveIndex {
    proc init {} {
	proc readTable {file tableType} {
	    set FID [open $file r]
	    set i 0
	    set llist [list]
	    set nlist [list]
	    set klist [list]
	    while {[gets $FID line] >= 0} {
		    if {[scan $line "%e %e %e %e" l a n k] == 4 } {
		        lappend llist $l
		        lappend nlist $n
		        lappend klist $k
	    	}
	    }
	    set lnklist [list $llist $nlist $klist]
            close $FID
	    return $lnklist
	}

    #---------------------------------------------------------------------------------------------------
	# Choose data file based on doping concentration and dopant type
    #---------------------------------------------------------------------------------------------------

            set scriptName [info script]
            set folderName [file rootname $scriptName]
            set dataFile $folderName/Ga51In49P.dat

	set tableType TableODB
	set lnklist [readTable $dataFile $tableType]
	variable llist [lindex $lnklist 0]
	variable nlist [lindex $lnklist 1]
	variable klist [lindex $lnklist 2]
	variable TableInterpolation Linear
	variable Formula 1

	# shift in energy according to bandgap.
#-----------------------------------------------------------------------------------------------------
	set base_bandgap 1.85
	set e_offset [expr $::Eg_GaInP - $base_bandgap]
 	set new_llist [list]
	foreach l $llist {
		set e [expr 1240/$l ]
		lappend new_llist [expr 1.24/($e + $e_offset) ]
	}
	set llist $new_llist
    }
    proc print {} {printPar::ComplexRefractiveIndexSection} 
}
GaInP::ComplexRefractiveIndex::init
