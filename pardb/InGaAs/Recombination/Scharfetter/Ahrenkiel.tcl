#----------------------------------------------------------------------#
# $Id: Levinshtein.tcl,v 1.1 2008/09/23 20:17:53 sameers Exp $ 
#----------------------------------------------------------------------#
#! MODEL: Temperature and Doping dependent model from sdevice
#! MATERIAL: InGaAs
#! PROPERTY: SRH Recombination 
#! EXPRESSION: 
#! Temperature and doping dependent minority carrier lifetime is calculated using,
#! tau = taumin + ( taumax - taumin ) / ( 1 + ( N/Nref )^gamma)
#! where,
#! tau(T) = tau * ( (T/300)^Talpha )  
#! or
#! tau(T) = tau * exp( Tcoeff * ((T/300)-1) )
#! CALCULATED PARAMETER: 
#! taumin_i, taumax_i, Nref_i, gamma_i, Talpha_i, Tcoeff_i, Etrap, 
#! where i is n for n-type or p for p-type
#! VALIDITY:
#! This model is valid for Ga0.47In0.53As and and doping concentration up to 1e18 cm^-3
#! NOTES:
#! The reference measured lifetimes for both holes and electons
#! SDEVICE: Recombination(SRH)
#! REFERENCE: 
#! Ahrenkiel, et al. "Recombination lifetime of as a function of doping density," APL, 1998.
#! HISTORY:
#! Created on 2022/03/29 by Gavin Forcade

namespace eval InGaAs::Scharfetter {
    proc init {} {
    	variable Nref_n 1.0e18      
	variable Nref_p 1.0e18
    	variable gamma_n 1.0
	variable gamma_p 1.0
    	variable Talpha_n 0.0
	variable Talpha_p 0.0
    	variable Tcoeff_n 0.0
	variable Tcoeff_p 0.0
    	variable Etrap 0.0	
	variable taumin_n 0.0
	variable taumin_p 0.0

# Parameters from Levinshtein        
    	variable taumax_n 4.0e-5    ;# electron lifetime
	variable taumax_p 4.0e-5    ;# hole lifetime they measured to be the same
   }
    proc print {} {printPar::ScharfetterSection}    
}
InGaAs::Scharfetter::init
