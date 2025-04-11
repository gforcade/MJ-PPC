#----------------------------------------------------------------------#
# $Id: Palik.tcl,v 1.1 2008/04/09 11:33:32 sameers Exp $ 
#----------------------------------------------------------------------#
#! MODEL: Room temperature model from EMIS
#! MATERIAL: Ge
#! PROPERTY: Complex Refractive Index
#! EXPRESSION: 
#! Room temperature values of wavelength, refractive index and extinction coefficient are created using Palik.csv in Palik folder
#! CALCULATED PARAMETER:
#! llist, nlist and klist return wavelength [um], refractive index and extinction coefficient respectively. 
#! VALIDITY: this model is valid only for T=300K
#! NOTES:
#! SDEVICE: 
#! REFERENCE: 
#! "Handbook of Optical Constants of Solids, Vol I",Edward D. Palik, 1985
#! HISTORY:
#! Created on 2008/04/09 by Sameer Shah

namespace eval Ge::TableODB {
    proc init {} {
	variable llist
	variable nlist
	variable klist
    	set scriptName [info script]
    	set folderName [file rootname $scriptName]
    	set dataFile $folderName/Palik.csv

	set tableType TableODB
	set lnklist [readTable $dataFile $tableType]
	set llist [lindex $lnklist 0]
	set nlist [lindex $lnklist 1]
	set klist [lindex $lnklist 2]
    }
    proc print {} {printPar::TableODBSection} 
}
Ge::TableODB::init
