#----------------------------------------------------------------------#
# $Id: Madelung.tcl,v 1.1 2007/08/10 12:17:07 sameers Exp $ 
#----------------------------------------------------------------------#
#! MODEL: Temperature dependent model from Madelung
#! MATERIAL: GaAs
#! PROPERTY: Refractive Index
#! EXPRESSION: The temperature dependent refractive index is calculated using
#! refractiveindex(T) = refractiveindex(Tpar)*(1+alpha*(T-Tpar))
#! CALCULATED PARAMETER: 
#! refractive index
#! VALIDITY: 
#! NOTES: 
#! SDEVICE: 
#! REFERENCE: 
#! "Semiconductors: Data Handbook", O. Madelung, Springer-Verlag, 2004

namespace eval GaAs::RefractiveIndex {
    proc init {} {
# Parameters from Reference
	variable Tpar 0.0
	variable refractiveindex 3.255
	variable alpha 4.5e-5
	variable a0 0.0
	variable N0 1.e18

# Calculation of temperature dependent refractive index
	variable ri [expr {$refractiveindex*(1.0+$alpha*($::temp-$Tpar))}]
    }
    proc print {} {printPar::RefractiveIndexSection}    
}
GaAs::RefractiveIndex::init
