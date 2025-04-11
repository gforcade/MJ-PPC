#----------------------------------------------------------------------#
# $Id: Default.tcl,v 1.2 2007/09/07 14:01:40 sameers Exp $
#----------------------------------------------------------------------#
#! MODEL: Model from sdevice
#! MATERIAL: GaAs
#! PROPERTY: Electron and hole masses
#! EXPRESSION: 
#! CALCULATED PARAMETER: 
#! ml, mh, me, offset, ShiftTemperature
#! VALIDITY: 
#! NOTES: 
#! SDEVICE: Schroedinger
#! REFERENCE: 
#! Sentaurus Device User

namespace eval GaAs::SchroedingerParameters {
    proc init {} {
	variable formula_n 0
	variable formula_p 2
	variable ml 0.074
	variable mh 0.62
	variable me 0.07
	variable offset_n 0.0
	variable offset_p 0.0
	variable ShiftTemperature_n 1.0000e10
	variable ShiftTemperature_p 1.0000e10
    }
    proc print {} {printPar::SchroedingerParametersSection}    
}
GaAs::SchroedingerParameters::init
