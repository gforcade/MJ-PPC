#----------------------------------------------------------------------#
# $Id: Bhattacharya.tcl,v 1.1 2008/09/23 01:01:26 sameers Exp $ 
#----------------------------------------------------------------------#
#! MODEL: Room temperature model from Bhattacharya
#! MATERIAL: InGaAs
#! PROPERTY: Complex Refractive Index
#! EXPRESSION: 
#! Room temperature values of wavelength, refractive index and extinction coefficient are created using Bhattacharya.csv in Bhattacharya folder
#! CALCULATED PARAMETER:
#! llist, nlist and klist return wavelength [um], refractive index and extinction coefficient respectively. 
#! VALIDITY: this model is valid only for T=300K and In mole fraction of 0.3
#! NOTES:
#! SDEVICE: 
#! REFERENCE: 
#! "Properties of Lattice-Matched and Strained Indium Gallium Arsenide,
#! (EMIS Datareviews Series No. 8)," Bhattacharya, P., INSPEC 1993

namespace eval InGaAs::TableODB {
    proc init {} {
	variable llist
	variable nlist
	variable klist
	set scriptName [info script]
	set folderName [file rootname $scriptName]
	set dataFile $folderName/In30Ga70As.csv

	set tableType TableODB
	set lnklist [::readTable $dataFile $tableType]
	set llist [lindex $lnklist 0]
	set nlist [lindex $lnklist 1]
	set klist [lindex $lnklist 2]
    }
    proc print {} {printPar::TableODBSection} 
}
InGaAs::TableODB::init
