#----------------------------------------------------------------------#
# $Id: Levinshtein.tcl,v 1.1 2008/09/23 20:02:02 sameers Exp $ 
#----------------------------------------------------------------------#
#! MODEL: Room temperature Radiative Recombination model parameters from Levinshtein
#! MATERIAL: InGaAs
#! PROPERTY: Radiative Recombination
#! EXPRESSION: 
#! Radiative recombination rate is calculated using
#! R_Radiative = C * (T/Tpar)^alpha * (n p - ni_eff^2)   
#! Temperature dependence is suppressed by setting alpha=0
#! CALCULATED PARAMETER: 
#! C and alpha 
#! VALIDITY: This model is valid only for T=300K and doping concentration of 1e18 cm^-3
#! NOTES: 
#! SDEVICE: Recombination(Radiative)
#! REFERENCE: 
#! "Handbook series on Semiconductor Parameters, Vol II"
#! M. Levenshtein, S. Rumyantsev, M. Shur, World Scientific, 1999
#! HISTORY:
#! Created on 2008/09/23 by Sameer Shah

namespace eval InGaAs_InAlAs::RadiativeRecombination {
    proc init {} {
	variable C 1e-10;   
    	variable alpha 0.0		
   }
    proc print {} {printPar::RadiativeRecombinationSection}    
}
InGaAs_InAlAs::RadiativeRecombination::init
