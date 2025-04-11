#----------------------------------------------------------------------#
# $Id: Default.tcl,v 1.5 2007/09/10 11:24:55 sameers Exp $ 
#----------------------------------------------------------------------#
#! MODEL: Radiative Recombination model parameters from sdevice
#! MATERIAL: GaAs
#! PROPERTY: Radiative Recombination
#! EXPRESSION: 
#! Radiative recombination rate is calculated using
#! R_Radiative = C * (T/Tpar)^alpha * (n p - ni_eff^2)    
#! CALCULATED PARAMETER: 
#! C and alpha 
#! VALIDITY: 
#! NOTES: 
#! SDEVICE: Recombination(Radiative)
#! REFERENCE: 
#! Sentaurus Device User Guide
#! HISTORY:
#! Created by Sameer Shah

namespace eval MQW_eff::RadiativeRecombination {
    proc init {} {
	    variable C 1.3e-9
    	variable alpha 0.0		
   }
    proc print {} {printPar::RadiativeRecombinationSection}    
}
MQW_eff::RadiativeRecombination::init
