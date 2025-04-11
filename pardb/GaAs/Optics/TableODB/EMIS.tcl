#----------------------------------------------------------------------#
# $Id: EMIS.tcl,v 1.3 2008/09/23 00:33:36 sameers Exp $ 
#----------------------------------------------------------------------#
#! MODEL: Room temperature model from EMIS
#! MATERIAL: GaAs
#! PROPERTY: Complex Refractive Index
#! EXPRESSION: 
#! Room temperature values of wavelength, refractive index and extinction coefficient are created using EMIS.csv in EMIS folder
#! CALCULATED PARAMETER:
#! llist, nlist and klist return wavelength [um], refractive index and extinction coefficient respectively. 
#! VALIDITY: this model is valid only for T=300K
#! NOTES:
#! SDEVICE: 
#! REFERENCE: 
#! "Properties of Gallium Arsenide," EMIS Datareviews Series No. 2, INSPEC 1996, section 8.8

namespace eval GaAs::TableODB {
    proc init {} {
	variable llist
	variable nlist
	variable klist
    set scriptName [info script]
    set folderName [file rootname $scriptName]
    set dataFile $folderName/EMIS.csv

	set tableType TableODB
	set lnklist [::readTable $dataFile $tableType]
	set llist [lindex $lnklist 0]
	set nlist [lindex $lnklist 1]
	set klist [lindex $lnklist 2]
    }
    proc print {} {printPar::TableODBSection} 
}
GaAs::TableODB::init
