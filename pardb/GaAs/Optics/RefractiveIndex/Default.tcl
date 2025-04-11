#----------------------------------------------------------------------#
# $Id: Default.tcl,v 1.1 2007/08/10 12:17:07 sameers Exp $ 
#----------------------------------------------------------------------#
#! MODEL: Temperature dependent model from sdevice
#! MATERIAL: GaAs
#! PROPERTY: Refractive Index
#! EXPRESSION: The temperature dependent refractive index is calculated using
#! refractiveindex(T) = refractiveindex(Tpar) * (1 + alpha * (T-Tpar))
#! CALCULATED PARAMETER: 
#! refractive index
#! VALIDITY: 
#! NOTES:
#! SDEVICE: 
#! REFERENCE: 
#! Sentaurus Device User Guide

namespace eval GaAs::RefractiveIndex {
    proc init {} {
# Default sdevice parameters
	variable Tpar 300.0
	variable refractiveindex 3.5108
	variable alpha 4.0e-4
	variable a0 0.0
	variable N0 1.e18

# Calculation of temperature dependent refractive index
	variable ri [expr {$refractiveindex*(1.0+$alpha*($::temp-$Tpar))}]
    }
    proc print {} {printPar::RefractiveIndexSection}    
}
GaAs::RefractiveIndex::init
