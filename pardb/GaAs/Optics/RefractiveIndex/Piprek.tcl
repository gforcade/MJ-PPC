#----------------------------------------------------------------------#
# $Id: Piprek.tcl,v 1.1 2007/10/16 13:28:55 sameers Exp $ 
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
#! REFERENCE:
#! "Semiconductor Optoelectronic Devices: Introduction to Physics and Simulation", J. Piprek, Elsevier Science(USA), 2003
#! HISTORY:
#! Created on 2007/09/10 by Sameer Shah

namespace eval GaAs::RefractiveIndex {
    proc init {} {
# Parameters from Piprek
	    variable Tpar 0.0
    	variable refractiveindex 3.65   ;# refractive index at bandgap wavelength=0.87 um
	    variable alpha 4.5e-5
    	variable a0 0.0
	    variable N0 1.e18

# Calculate temperature dependent refractive index
    	variable ri [expr {$refractiveindex*(1.0+$alpha*($::temp-$Tpar))}]
    }
    proc print {} {printPar::RefractiveIndexSection}    
}
GaAs::RefractiveIndex::init
