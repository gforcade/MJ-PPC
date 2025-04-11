#----------------------------------------------------------------------#
# $Id: Default.tcl,v 1.3 2007/08/10 12:17:02 sameers Exp $ 
#----------------------------------------------------------------------#
#! MODEL: Table based Bandgap narrowing (BGN) model from sdevice
#! MATERIAL: GaAs
#! PROPERTY: Bandgap narrowing #! EXPRESSION: 
#! The BGN is specified for acceptors and donors seperately in tabular format
#! CALCULATED PARAMETER:
#! deltaEg_n returns BGN for donors
#! deltaEg_p return BGN for acceptors
#! VALIDITY: 
#! This model is valid for both n-GaAs and p-GaAs
#! NOTES:
#! SDEVICE: EffectiveIntrinsicDensity(TableBGN)
#! REFERENCE: 
#! Sentaurus Device User Guide

namespace eval GaAs::TableBGN {
    proc init {} {
	variable Na
	variable Nd
	variable deltaEg_n
	variable deltaEg_p
    
# set the path of data files  
# 	set dataFile $::pardb/GaAs/BandStructure/TableBGN/Default/bgn_donor.csv   
    set scriptName [info script]
    set folderName [file rootname $scriptName]
    set dataFile $folderName/bgn_donor.csv
   	set tableType TableBGN
	set bgnlist [readTable $dataFile $tableType]
	set Nd [lindex $bgnlist 0]
	set deltaEg_n [lindex $bgnlist 1]

#	set dataFile $::pardb/GaAs/BandStructure/TableBGN/Default/bgn_acceptor.csv
    set dataFile $folderName/bgn_acceptor.csv
	set tableType TableBGN
	set bgnlist [readTable $dataFile $tableType]
	set Na [lindex $bgnlist 0]
	set deltaEg_p [lindex $bgnlist 1]
    }
    proc print {} {printPar::TableBGNSection}
}
GaAs::TableBGN::init
