#----------------------------------------------------------------------#
# $Id: Piprek.tcl,v 1.1 2008/07/04 06:06:28 sameers Exp $ 
#----------------------------------------------------------------------#
#! MODEL: Room temperature Radiative Recombination model parameters from Levinshtein
#! MATERIAL: InP
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
#! Created on 2008/07/04 by Sameer Shah

namespace eval InP::RadiativeRecombination {
    proc init {} {
	variable C 1.0e-10; #varies from 1e-10 to 3e-10 cm^3/s
    	variable alpha 0.0		
   }
    proc print {} {printPar::RadiativeRecombinationSection}    
}
InP::RadiativeRecombination::init
