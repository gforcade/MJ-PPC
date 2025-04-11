#----------------------------------------------------------------------#
# $Id:$
#----------------------------------------------------------------------#
#! MODEL: Room temperature model from Levinshtein
#! MATERIAL: GaInP
#! PROPERTY: Complex Refractive Index 
#! EXPRESSION: 
#! Room temperature values of wavelength, refractive index and extinction coefficient are created using Ga510In490P.dat in Schubert folder
#! CALCULATED PARAMETER:
#! llist, nlist and klist return wavelength [um], absorption coefficient [cm^-1], refractive index and extinction coefficient respectively. 
#! VALIDITY:
#! This model is valid only for Ga concentration of 0.51
#! NOTES:
#! REFERENCE:
#  Schubert M et al., J. Appl. Phys., Vol. 77, No. 7, (1995)
#! HISTORY:
#! Created by Gergoe Letay & Sameer Shah

namespace eval GaInP::TableODB {                
	proc init {} {
                variable llist
		variable nlist
		variable klist
                variable alist
                set scriptName [info script]
                set folderName [file rootname $scriptName]
                set dataFile $folderName/GaInP_nk_4CPV.csv
                puts $folderName
                puts $dataFile
                set tableType TableODB
		    	
		set FID [open $dataFile r]
		set i 0
		set llist [list]
		set alist [list]
		set nlist [list]
		set klist [list]
		while {[gets $FID line] >= 0} {
			if {[scan $line "%e,%e,%e" l n k] == 3 } {
				lappend llist [expr $l]
				lappend nlist $n
				lappend klist $k
				incr i
			}
		}
		close $FID
		proc print {} {printPar::TableODBSection} 
	}
}
GaInP::TableODB::init
