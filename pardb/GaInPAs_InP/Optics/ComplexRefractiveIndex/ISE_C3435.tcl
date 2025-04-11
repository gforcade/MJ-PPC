#----------------------------------------------------------------------#
#! MODEL: Room temperature results from ISE Fraunhoffer
#! MATERIAL: InGaAs
#! PROPERTY: Complex Refractive Index 
#! EXPRESSION: 
#! Room temperature values of wavelength, refractive index and extinction coefficient are created
#! n: NRC data + shifted ISE data to follow NRC 
#! k: MegC5034_3B data
#! CALCULATED PARAMETER:
#! llist, nlist and klist return wavelength [um], absorption coefficient [cm^-1], refractive index and extinction coefficient respectively. 
#! VALIDITY: this model is valid only for T=300K
#! REFERENCE: 
#! HISTORY:
#! Gavin Forcade: adapted to output ComplexRefractiveIndex and NumericalTable format 2022-Feb-14

namespace eval GaInPAs_InP::ComplexRefractiveIndex {
    proc init {} {
	proc readTable {file tableType} {
	    set FID [open $file r]
	    set i 0
	    set llist [list]
	    set nlist [list]
	    set klist [list]
	    while {[gets $FID line] >= 0} {
		    if {[scan $line "%e,%e,%e" l n k] == 3 } {
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



	proc mltp {x a} {
		## multiply the list x by the value a
		set y [list ]
		foreach i $x {
			 lappend y [expr $i*$a]
		}
		return $y
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

            set scriptName [info script]
            set folderName [file rootname $scriptName]
            set dataFile $folderName/InGaAsP.dat
	    puts $dataFile
#-----------------------------------------------------------------------------------------------------
 
	set tableType TableODB
	set lnklist [readTable $dataFile $tableType]
	set llist [lindex $lnklist 0]
	set nlist [lindex $lnklist 1]
	set klist [lindex $lnklist 2]


	# shift k data
	set klist [mltp $klist [expr $::del_k + 1.0]]


	set Formula 1
    }
    proc print {} {printPar::ComplexRefractiveIndexSection} 
}
GaInPAs_InP::ComplexRefractiveIndex::init
