#----------------------------------------------------------------------#
# $Id: Default.tcl,v 1.6 2021/11/30 G Forcade $ 
#----------------------------------------------------------------------#
#! MODEL: Temperature and Doping dependent model from sdevice
#! MATERIAL: GaInPAs_InP
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
#! NOTES:
#! SDEVICE: Recombination(SRH)
#! REFERENCE: 
#! P. Santhanam et al., "Controlling the dopant profile for SRH suppression at low current densities in  lambda˜1330 nm GaInAsP light-emitting diodes" 2020
#! Sentaurus Device User Guide 
#! HISTORY:
#! Created on 2021/11/30 Gavin Forcade - uOttawa SUNLAB

namespace eval GaInPAs_InP::Scharfetter {
     proc init {} {
    	variable Nref_n 1.0e18      ;# Default parameters from sdevice   
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

# Parameters from Levinshtein for InGaAs       
    	variable taumax_n 1.0e-8    ;# Longest lifetime of electrons for approximately 1e18 cm^-3
	variable taumax_p 3.0e-6    ;# Longest lifetime of holes for approximately 1e18 cm^-3
   }
    proc print {} {printPar::ScharfetterSection}    
}
GaInPAs_InP::Scharfetter::init
