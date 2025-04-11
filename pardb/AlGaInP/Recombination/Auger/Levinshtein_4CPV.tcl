#----------------------------------------------------------------------#
# $Id: Levinshtein.tcl,v 1.1 2008/06/30 13:49:32 sameers Exp $ 
#----------------------------------------------------------------------#
#! MODEL: Room temperature Auger Recombination model parameters from Levinshtein
#! MATERIAL: AlGaInP
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
#! "Handbook series on Semiconductor Parameters, Vol II"
#! M. Levinshtein, S. Rumyantsev, M. Shur, World Scientific, 1999
#! HISTORY:
#! Created on 2008/06/30 by Sameer Shah

namespace eval AlGaInP::Auger {
    proc init {} {
	    variable A_n 3e-30    ;# x=0.5 default values for both n and p are 3e-30
	    variable A_p 3e-30    ;# x=0.5
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
AlGaInP::Auger::init
