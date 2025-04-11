#----------------------------------------------------------------------#
# $Id: MB.tcl,v 1.1 2008/09/23 20:17:53 sameers Exp $ 
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
#! This model is valid for Ga0.47In0.53As and and doping concentration of 1e18 cm^-3
#! NOTES:
#! SDEVICE: Recombination(SRH)
#! REFERENCE: 
#! "Handbook series on Semiconductor Parameters, Vol II"
#! M. Levenshtein, S. Rumyantsev, M. Shur, World Scientific, 1999
#! HISTORY:
#! Created on 2008/09/23 by Sameer Shah
#! Short liftime p-IGA

namespace eval InGaAs::Scharfetter {
    proc init {} {
    	variable Nref_n 1.0e18      ;# Ioffe
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
    	variable taumax_n @tau_SRH_e@    ;# Mod from 1e-7 # Longest lifetime of electrons for approximately 1e18 cm^-3
	variable taumax_p @tau_SRH_h@    ;# Mod from 1e-8 # Longest lifetime of holes for approximately 1e18 cm^-3
   }
    proc print {} {printPar::ScharfetterSection}    
}
InGaAs::Scharfetter::init
