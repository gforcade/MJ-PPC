#----------------------------------------------------------------------#
# $Id: Levinshtein.tcl,v 1.1 2007/09/10 12:04:01 sameers Exp $ 
#----------------------------------------------------------------------#
#! MODEL: Room temperature Radiative Recombination model parameters from Levinshtein
#! MATERIAL: Ge
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
#! "Handbook series on Semiconductor Parameters, Vol I"
#! M. Levenshtein, S. Rumyantsev, M. Shur, World Scientific, 1996
#! HISTORY:
#! Created on 2007/09/10 by Sameer Shah

namespace eval Ge::RadiativeRecombination {
    proc init {} {
	    variable C 6.4e-14
	    variable alpha 0.0		
    }
    proc print {} {printPar::RadiativeRecombinationSection}    
}
Ge::RadiativeRecombination::init
