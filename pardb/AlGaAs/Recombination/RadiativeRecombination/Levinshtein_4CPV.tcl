#----------------------------------------------------------------------#
# $Id: Levinshtein.tcl,v 1.1 2007/09/10 11:24:55 sameers Exp $ 
#----------------------------------------------------------------------#
#! MODEL: Room temperature Radiative Recombination model parameters from Levinshtein
#! MATERIAL: AlGaAs
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
#! "Handbook series on Semiconductor Parameters, Vol II"
#! M. Levenshtein, S. Rumyantsev, M. Shur, World Scientific, 1999
#! HISTORY:
#! Created on 2007/09/10 by Sameer Shah

namespace eval AlGaAs::RadiativeRecombination {
    proc init {} {
	    variable C 1.0e-10
    	variable alpha 0.0		
   }
    proc print {} {printPar::RadiativeRecombinationSection}    
}
AlGaAs::RadiativeRecombination::init
