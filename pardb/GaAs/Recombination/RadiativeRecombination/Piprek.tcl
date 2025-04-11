#----------------------------------------------------------------------#
# $Id: Piprek.tcl,v 1.1 2007/09/10 11:24:55 sameers Exp $ 
#----------------------------------------------------------------------#
#! MODEL: Room temperature Radiative Recombination model parameters from Levinshtein
#! MATERIAL: GaAs
#! PROPERTY: Radiative Recombination
#! EXPRESSION: 
#! Radiative recombination rate is calculated using
#! R_Radiative = C * (T/Tpar)^alpha * (n p - ni_eff^2)   
#! Temperature dependence is suppressed by setting alpha=0
#! CALCULATED PARAMETER: 
#! C and alpha 
#! VALIDITY: This model is valid only for T=300K
#! NOTES: 
#! SDEVICE: Recombination(Radiative)
#! REFERENCE: 
#! "Semiconductor Optoelectronic Devices: Introduction to Physics and Simulation", J. Piprek, Elsevier Science(USA), 2003
#! HISTORY:
#! Created on 2007/09/10 by Sameer Shah

namespace eval GaAs::RadiativeRecombination {
    proc init {} {
	    variable C 1.0e-10  ;# Varies from 1e-10 to 1e-9 cm^3/s in Piprek
    	variable alpha 0.0		
   }
    proc print {} {printPar::RadiativeRecombinationSection}    
}
GaAs::RadiativeRecombination::init
