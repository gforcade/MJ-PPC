#----------------------------------------------------------------------#
# $Id: Default.tcl,v 1.6 2007/09/10 12:34:52 sameers Exp $ 
#----------------------------------------------------------------------#
#! MODEL: Auger Recombination model parameters from sdevice
#! MATERIAL: GaAs
#! PROPERTY: Auger Recombination
#! EXPRESSION: 
#! Auger recombination rate is calculated using
#! R_Auger = ( C_n n + C_p p ) ( n p - ni_eff^2)
#! with C_n,p = (A + B (T/T0) + C (T/T0)^2) (1 + H exp(-{n,p}/N0))
#! CALCULATED PARAMETER: 
#! A_n, A_p, B_n, B_p, C_n, C_p, H_n, H_p, N0_n, N0_p
#! VALIDITY: 
#! NOTES: 
#! SDEVICE: Recombination(Auger)
#! REFERENCE: 
#! Sentaurus Device User Guide 
#! HISTORY:
#! Created by Sameer Shah

namespace eval GaAs::Auger {
    proc init {} {
	    variable A_n 1.0e-30
	    variable A_p 1.0e-30
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
GaAs::Auger::init
