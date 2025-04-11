#----------------------------------------------------------------------#
# $Id: Default.tcl,v 1.1 2022/08/13 G Forcade $ 
#----------------------------------------------------------------------#
#! MODEL: Auger Recombination model parameters from sdevice
#! MATERIAL: InGaAs
#! PROPERTY: Auger Recombination
#! EXPRESSION: 
#! Auger recombination rate is calculated using
#! R_Auger = ( C_n n + C_p p ) ( n p - ni_eff^2)
#! with C_n,p = (A + B (T/T0) + C (T/T0)^2) (1 + H exp(-{n,p}/N0))
#! CALCULATED PARAMETER: 
#! A_n, A_p, B_n, B_p, C_n, C_p, H_n, H_p, N0_n, N0_p
#! VALIDITY: 
#! NOTES: Measured auger coefficients for InGaAs. Negate Cn from C to calculate Cp from Hausser.
#! SDEVICE: Recombination(Auger)
#! REFERENCE: 
#! Hausser, "Auger recombination in bulk and quantum well InGaAs", 1990.
#! Metzer, "Auger recombination in low-bandgap n-type InGaAs", 2001
#! HISTORY:
#! Created on 2022/08/13 by Gavin Forcade - SUNLAB

namespace eval InGaAs::Auger {
    proc init {} {
	    variable A_n 1.8e-28 
	    variable A_p 1.4e-28
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
InGaAs::Auger::init
