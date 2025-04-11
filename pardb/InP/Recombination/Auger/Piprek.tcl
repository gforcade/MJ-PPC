#----------------------------------------------------------------------#
# $Id: Piprek.tcl,v 1.1 2008/07/04 06:06:28 sameers Exp $ 
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
#! "Semiconductor Optoelectronic Devices: Introduction to Physics and Simulation", J. Piprek, Elsevier Science(USA), 2003
#! HISTORY:
#! Created on 2008/07/04 by Sameer Shah

namespace eval InP::Auger {
    proc init {} {
	    variable A_n 2.0e-31;    # Varies from 2e-31 to 1e-29 cm^6/s
	    variable A_p 2.0e-31;    # Varies from 2e-31 to 1e-29 cm^6/s   
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
