#----------------------------------------------------------------------#
# $Id: Levinshtein.tcl,v 1.1 2008/06/30 13:49:33 sameers Exp $ 
#----------------------------------------------------------------------#
#! MODEL: Room temperature Auger Recombination model parameters from Levinshtein
#! MATERIAL: InP
#! PROPERTY: Auger Recombination
#! EXPRESSION: 
#! Auger recombination rate is calculated using
#! R_Auger = ( C_n n + C_p p ) ( n p - ni_eff^2)
#! with C_n,p = (A + B (T/T0) + C (T/T0)^2) (1 + H exp(-{n,p}/N0))
#! CALCULATED PARAMETER: 
#! A_n, A_p, B_n, B_p, C_n, C_p, H_n, H_p, N0_n, N0_p
#! VALIDITY: This model is valid only at room temperature
#! NOTES: 
#! SDEVICE: Recombination(Auger)
#! REFERENCE: 
#! "Handbook series on Semiconductor Parameters, Vol I"
#! M. Levenshtein, S. Rumyantsev, M. Shur, World Scientific, 1996
#! HISTORY:
#! Created on 2008/06/30 by Sameer Shah

namespace eval InP::Auger {
    proc init {} {
	    variable A_n 9.0e-31
	    variable A_p 9.0e-31
	    variable B_n 0.0
	    variable B_p 0.0
	    variable C_n 0.0
	    variable C_p 0.0
	    variable H_n 0.0
	    variable H_p 0.0 
	    variable N0_n 1.0e18
	    variable N0_p 1.0e18
    }
    proc print {} {printPar::AugerSection}    
}
InP::Auger::init
