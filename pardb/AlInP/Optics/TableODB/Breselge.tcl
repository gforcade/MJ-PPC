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
	variable alist
        set scriptName [info script]
        set folderName [file rootname $scriptName]
        set dataFile $folderName/Al51IP.par
	set FID [open $dataFile r]
		set i 0
		set llist [list]
		set alist [list]
		set nlist [list]
		set klist [list]
		while {[gets $FID line] >= 0} {
			if {[scan $line "%e %e %e %e" l a n k] == 4 } {
				lappend llist [expr $l/1000.]
				lappend alist $a
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
