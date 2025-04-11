#----------------------------------------------------------------------#
#! MODEL: Room temperature model from Adachi no doping dependence
#! MATERIAL: InP
#! PROPERTY: Complex Refractive Index 
#! EXPRESSION: 
#! Room temperature values of wavelength, refractive index and extinction coefficient are created
#! using the data file from Adachi folder
#! CALCULATED PARAMETER:
#! llist, nlist and klist return wavelength [um], absorption coefficient [cm^-1], refractive index and extinction coefficient respectively. 
#! VALIDITY: this model is valid only for T=300K
#! REFERENCE: 
#! HISTORY:
#! M Wilkins: adapted to output ComplexRefractiveIndex and NumericalTable format 2015-Jan-14

namespace eval InP::ComplexRefractiveIndex {
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

	variable llist
	variable nlist
	variable klist
	variable Formula
	variable TableInterpolation

	# Format doping value so that it is consistent with data file names in Levinshtein folder
	set doping [format %1.2e $::doping]

    #---------------------------------------------------------------------------------------------------
	# Choose data file based on doping concentration and dopant type
    #---------------------------------------------------------------------------------------------------

            set scriptName [info script]
            set folderName [file rootname $scriptName]
            set dataFile $folderName/InP.dat
	    puts $dataFile
#-----------------------------------------------------------------------------------------------------
 
	set tableType TableODB
	set lnklist [readTable $dataFile $tableType]
	set llist [lindex $lnklist 0]
	set nlist [lindex $lnklist 1]
	set klist [lindex $lnklist 2]
	set Formula 1
	set TableInterpolation Linear
    }
    proc print {} {printPar::ComplexRefractiveIndexSection} 
}
InP::ComplexRefractiveIndex::init
