#----------------------------------------------------------------------#
# $Id: Breselge.tcl,v 1.1 2008/09/23 00:05:00 sameers Exp $ 
#----------------------------------------------------------------------#
#! MODEL: Room temperature model from EMIS
#! MATERIAL: AlInP
#! PROPERTY: Complex Refractive Index
#! EXPRESSION: 
#! Room temperature values of wavelength, refractive index and extinction coefficient are created using EMIS.csv in EMIS folder
#! CALCULATED PARAMETER:
#! llist, nlist and klist return wavelength [um], refractive index and extinction coefficient respectively. 
#! alist returns absorption coefficient [cm^-1]
#! VALIDITY: 
#! This model is valid only for x=0.51
#! NOTES:
#! SDEVICE: 
#! REFERENCE: 
#! M. Breselge, "Simulation von III-V Kaskadensolarzellen und Charakterisierung optischer Materialparameter",
#! Master Thesis, 2003, Freiburg, Germany
#! HISTORY:
#! Created on 2008/09/23 by Gergoe Letay and Sameer Shah

namespace eval AlInP::TableODB {
    proc init {} {
	variable llist
	variable nlist
	variable klist
        set scriptName [info script]
        set folderName [file rootname $scriptName]
        set dataFile $folderName/AlInP_nk_4CPV_20121010.csv
	set FID [open $dataFile r]
		set i 0
		set llist [list]
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
    }
    proc print {} {printPar::TableODBSection} 
}
AlInP::TableODB::init
