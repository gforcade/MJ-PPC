#----------------------------------------------------------------------#
# $Id: Default.tcl,v 1.2 2007/09/07 14:01:40 sameers Exp $
#----------------------------------------------------------------------#
#! MODEL: Model from sdevice
#! MATERIAL: InP
#! PROPERTY: Electron and hole masses
#! EXPRESSION: 
#! CALCULATED PARAMETER: 
#! ml, mh, me, offset, ShiftTemperature
#! VALIDITY: 
#! NOTES: 
#! SDEVICE: Schroedinger
#! REFERENCE: 
#! Sentaurus MaterialDB 2019.03 - Levinstein?
#! Modified from GaAs files by Meghan Beattie - 10/07/2019


namespace eval GaAs::SchroedingerParameters {
    proc init {} {
	variable formula_n 0
	variable formula_p 2
	variable ml 0.089
	variable mh 0.85
	variable me 0.0000e+00
	variable offset_n 0.0
	variable offset_p 0.0
	variable ShiftTemperature_n 1.0000e10
	variable ShiftTemperature_p 1.0000e10
    }
    proc print {} {printPar::SchroedingerParametersSection}    
}
GaAs::SchroedingerParameters::init
